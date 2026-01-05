import SwiftUI
import SwiftData
import Vision

@MainActor
final class ScanViewModel: ObservableObject {
    weak var appState: AppState?
    var modelContext: ModelContext?

    @Published var lastScanResult: ScanResult?
    @Published var error: Error?
    @Published var processedCount: Int = 0
    @Published var errorCount: Int = 0

    // Album selection
    @Published var albums: [PhotoLibraryService.Album] = []
    @Published var selectedAlbum: PhotoLibraryService.Album?
    @Published var isLoadingAlbums: Bool = false

    private var scanTask: Task<Void, Never>?

    // Incremental detection state
    private var accumulatedFeaturePrints: [(id: String, featurePrint: VNFeaturePrintObservation)] = []
    private var accumulatedHashes: [(id: String, hash: UInt64)] = []
    private var accumulatedQualityScores: [(id: String, score: QualityScore)] = []
    private var currentDuplicateGroups: [[String]] = []
    private var currentSimilarGroups: [[String]] = []
    private var duplicateThreshold: Float = 0.5

    struct ScanResult {
        let photosScanned: Int
        let duplicateGroups: Int
        let similarGroups: Int
        let lowQualityCount: Int
        let spaceRecoverable: Int64
        let duration: TimeInterval

        var formattedSpaceRecoverable: String {
            ByteCountFormatter.string(fromByteCount: spaceRecoverable, countStyle: .file)
        }

        var formattedDuration: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
            return formatter.string(from: duration) ?? "\(Int(duration))s"
        }
    }

    // MARK: - Album Loading

    func loadAlbums() async {
        isLoadingAlbums = true
        albums = await PhotoLibraryService.shared.fetchAlbums()
        if selectedAlbum == nil, let firstAlbum = albums.first {
            selectedAlbum = firstAlbum
        }
        isLoadingAlbums = false
    }

    // MARK: - Scan Control

    func startScan() async {
        guard let appState = appState else { return }

        appState.isScanning = true
        appState.resetScanStats()
        appState.scanPhase = .loading

        // Reset incremental state
        accumulatedFeaturePrints = []
        accumulatedHashes = []
        accumulatedQualityScores = []
        currentDuplicateGroups = []
        currentSimilarGroups = []

        let startTime = Date()

        scanTask = Task {
            do {
                // Phase 1: Load photo identifiers from selected album
                let albumName = selectedAlbum?.title ?? "All Photos"
                appState.statusMessage = "Loading \(albumName)..."

                let identifiers = await PhotoLibraryService.shared.fetchAllAssetIdentifiers(
                    albumId: selectedAlbum?.id
                )
                let totalPhotos = identifiers.count

                guard !Task.isCancelled else { return }

                // Phase 2: Analyze photos with incremental detection
                appState.scanPhase = .analyzing
                appState.statusMessage = "Analyzing photos..."

                let results = try await processPhotosIncrementally(
                    identifiers: identifiers,
                    appState: appState,
                    totalPhotos: totalPhotos
                )

                guard !Task.isCancelled else { return }

                // Phase 3: Final grouping pass (refine groups)
                appState.scanPhase = .grouping
                appState.statusMessage = "Finalizing groups..."
                appState.scanProgress = 0.95

                // Find low quality photos
                let lowQuality = await QualityAssessmentService.shared.findLowQualityPhotos(
                    scores: accumulatedQualityScores
                ) { _ in }

                appState.lowQualityFound = lowQuality.count

                // PERSIST RESULTS TO SWIFTDATA
                appState.statusMessage = "Saving results..."

                if let modelContext = self.modelContext {
                    let photoRepo = PhotoRepository(modelContext: modelContext)
                    let groupRepo = GroupRepository(modelContext: modelContext)

                    // Clear old groups first
                    groupRepo.deleteAll()

                    // Persist photo analysis results
                    for result in results {
                        photoRepo.updateAnalysisResults(
                            localIdentifier: result.photoId,
                            featurePrintData: result.featurePrintData,
                            perceptualHash: result.perceptualHash,
                            aestheticScore: result.aestheticScore,
                            isUtility: result.isUtility,
                            blurScore: result.blurScore,
                            exposureScore: result.exposureScore,
                            fileSize: result.fileSize,
                            pixelWidth: result.pixelWidth,
                            pixelHeight: result.pixelHeight,
                            creationDate: result.creationDate,
                            fileName: result.fileName
                        )
                    }

                    // Persist duplicate groups
                    groupRepo.createDuplicateGroups(from: currentDuplicateGroups)

                    // Persist similar groups
                    groupRepo.createSimilarGroups(from: currentSimilarGroups)

                    // Save to disk
                    try? modelContext.save()

                    #if DEBUG
                    print("✅ Saved \(results.count) photos, \(currentDuplicateGroups.count) duplicate groups, \(currentSimilarGroups.count) similar groups")
                    #endif
                } else {
                    #if DEBUG
                    print("⚠️ No modelContext - results not persisted!")
                    #endif
                }

                // Calculate space recoverable using actual file sizes
                var spaceRecoverable: Int64 = 0
                for group in currentDuplicateGroups {
                    // Get file sizes for photos in this group
                    let groupSizes = group.compactMap { photoId -> Int64? in
                        results.first { $0.photoId == photoId }?.fileSize
                    }.sorted(by: >)

                    // Sum all but the largest (which we keep)
                    if groupSizes.count > 1 {
                        spaceRecoverable += groupSizes.dropFirst().reduce(0, +)
                    }
                }

                appState.spaceRecoverable = spaceRecoverable
                appState.scanProgress = 1.0
                appState.scanPhase = .complete
                appState.statusMessage = "Scan complete!"

                // Store result
                let duration = Date().timeIntervalSince(startTime)
                self.processedCount = results.filter { $0.error == nil }.count
                self.errorCount = results.filter { $0.error != nil }.count

                lastScanResult = ScanResult(
                    photosScanned: totalPhotos,
                    duplicateGroups: currentDuplicateGroups.count,
                    similarGroups: currentSimilarGroups.count,
                    lowQualityCount: lowQuality.count,
                    spaceRecoverable: spaceRecoverable,
                    duration: duration
                )

                #if DEBUG
                print("📊 Scan complete: \(self.processedCount) processed, \(self.errorCount) errors")
                #endif

            } catch {
                if !Task.isCancelled {
                    self.error = error
                    appState.statusMessage = "Error: \(error.localizedDescription)"
                }
            }

            appState.isScanning = false
        }
    }

    // MARK: - Incremental Processing

    private func processPhotosIncrementally(
        identifiers: [String],
        appState: AppState,
        totalPhotos: Int
    ) async throws -> [BatchProcessingService.ProcessingResult] {

        var results: [BatchProcessingService.ProcessingResult] = []
        let batchSize = 50 // Process in batches for better incremental updates

        for batchStart in stride(from: 0, to: identifiers.count, by: batchSize) {
            guard !Task.isCancelled else { break }

            let batchEnd = min(batchStart + batchSize, identifiers.count)
            let batchIds = Array(identifiers[batchStart..<batchEnd])

            // Process this batch
            let batchResults = try await BatchProcessingService.shared.processPhotos(
                identifiers: batchIds
            ) { _, _ in }

            results.append(contentsOf: batchResults)

            // Incremental duplicate and similar detection for this batch
            for result in batchResults {
                await processResultIncrementally(result, appState: appState)
            }

            // Update progress and counts in a single batch update
            await MainActor.run {
                let progress = Double(batchEnd) / Double(totalPhotos)
                appState.scanProgress = progress * 0.95
                appState.photosScanned = batchEnd
                appState.duplicatesFound = currentDuplicateGroups.count
                appState.similarGroupsFound = currentSimilarGroups.count
                appState.statusMessage = "Analyzing \(batchEnd)/\(totalPhotos) - Found \(currentDuplicateGroups.count) duplicate groups"
            }
        }

        return results
    }

    private func processResultIncrementally(
        _ result: BatchProcessingService.ProcessingResult,
        appState: AppState
    ) async {
        // Extract and store feature print
        if let fpData = result.featurePrintData,
           let fp = try? NSKeyedUnarchiver.unarchivedObject(
               ofClass: VNFeaturePrintObservation.self,
               from: fpData
           ) {
            // Check for duplicates against existing feature prints
            await checkForDuplicates(id: result.photoId, featurePrint: fp)
            accumulatedFeaturePrints.append((result.photoId, fp))
        }

        // Extract and store hash
        if let hash = result.perceptualHash {
            // Check for similar photos against existing hashes
            checkForSimilar(id: result.photoId, hash: hash)
            accumulatedHashes.append((result.photoId, hash))
        }

        // Extract and store quality score
        if let aesthetic = result.aestheticScore {
            let score = QualityScore(
                aestheticScore: aesthetic,
                isUtility: result.isUtility,
                blurScore: result.blurScore ?? 0.5,
                exposureScore: result.exposureScore ?? 0.5
            )
            accumulatedQualityScores.append((result.photoId, score))
        }
    }

    private func checkForDuplicates(
        id: String,
        featurePrint: VNFeaturePrintObservation
    ) async {
        var foundDuplicateGroupIndex: Int? = nil

        for (existingId, existingFp) in accumulatedFeaturePrints {
            do {
                var distance: Float = 0
                try featurePrint.computeDistance(&distance, to: existingFp)

                if distance < duplicateThreshold {
                    // Found a duplicate! Check if existing photo is already in a group
                    for (index, group) in currentDuplicateGroups.enumerated() {
                        if group.contains(existingId) {
                            foundDuplicateGroupIndex = index
                            break
                        }
                    }
                    break
                }
            } catch {
                continue
            }
        }

        if let groupIndex = foundDuplicateGroupIndex {
            // Add to existing group
            currentDuplicateGroups[groupIndex].append(id)
        } else {
            // Check if we found any duplicate (need to search again for the match)
            for (existingId, existingFp) in accumulatedFeaturePrints {
                do {
                    var distance: Float = 0
                    try featurePrint.computeDistance(&distance, to: existingFp)

                    if distance < duplicateThreshold {
                        // Create new group
                        currentDuplicateGroups.append([existingId, id])
                        return
                    }
                } catch {
                    continue
                }
            }
        }
    }

    private func checkForSimilar(
        id: String,
        hash: UInt64
    ) {
        let similarityThreshold = 8 // Hamming distance threshold

        var foundSimilarGroupIndex: Int? = nil

        for (existingId, existingHash) in accumulatedHashes {
            let distance = hammingDistance(hash, existingHash)

            if distance <= similarityThreshold && distance > 0 {
                // Found similar! Check if existing photo is already in a group
                for (index, group) in currentSimilarGroups.enumerated() {
                    if group.contains(existingId) {
                        foundSimilarGroupIndex = index
                        break
                    }
                }

                if let groupIndex = foundSimilarGroupIndex {
                    // Add to existing group if not already there
                    if !currentSimilarGroups[groupIndex].contains(id) {
                        currentSimilarGroups[groupIndex].append(id)
                    }
                } else {
                    // Create new group
                    currentSimilarGroups.append([existingId, id])
                }

                return
            }
        }
    }

    private func hammingDistance(_ a: UInt64, _ b: UInt64) -> Int {
        return (a ^ b).nonzeroBitCount
    }

    func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        Task {
            await BatchProcessingService.shared.cancel()
        }
        appState?.cancelScan()
    }
}
