import SwiftUI
import SwiftData
import Vision

@MainActor
final class ScanViewModel: ObservableObject {
    weak var appState: AppState?

    @Published var lastScanResult: ScanResult?
    @Published var error: Error?

    private var scanTask: Task<Void, Never>?

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

    // MARK: - Scan Control

    func startScan() async {
        guard let appState = appState else { return }

        appState.isScanning = true
        appState.resetScanStats()
        appState.scanPhase = .loading

        let startTime = Date()

        scanTask = Task {
            do {
                // Phase 1: Load all photo identifiers
                appState.statusMessage = "Loading photo library..."
                let identifiers = await PhotoLibraryService.shared.fetchAllAssetIdentifiers()
                let totalPhotos = identifiers.count

                guard !Task.isCancelled else { return }

                // Phase 2: Analyze photos
                appState.scanPhase = .analyzing
                let results = try await BatchProcessingService.shared.processPhotos(
                    identifiers: identifiers
                ) { progress, message in
                    appState.scanProgress = progress * 0.7 // 70% for analysis
                    appState.statusMessage = message
                    appState.photosScanned = Int(Double(totalPhotos) * progress)
                }

                guard !Task.isCancelled else { return }

                // Phase 3: Find duplicates and similar photos
                appState.scanPhase = .grouping
                appState.statusMessage = "Finding duplicates..."

                // Prepare feature prints for duplicate detection
                var featurePrints: [(id: String, featurePrint: VNFeaturePrintObservation)] = []
                var perceptualHashes: [(id: String, hash: UInt64)] = []
                var qualityScores: [(id: String, score: QualityScore)] = []

                for result in results {
                    if let fpData = result.featurePrintData,
                       let fp = try? NSKeyedUnarchiver.unarchivedObject(
                           ofClass: VNFeaturePrintObservation.self,
                           from: fpData
                       ) {
                        featurePrints.append((result.photoId, fp))
                    }

                    if let hash = result.perceptualHash {
                        perceptualHashes.append((result.photoId, hash))
                    }

                    if let aesthetic = result.aestheticScore {
                        let score = QualityScore(
                            aestheticScore: aesthetic,
                            isUtility: result.isUtility,
                            blurScore: result.blurScore ?? 0.5,
                            exposureScore: result.exposureScore ?? 0.5
                        )
                        qualityScores.append((result.photoId, score))
                    }
                }

                // Find duplicates
                let duplicateGroups = try await DuplicateDetectionService.shared.findDuplicates(
                    photos: featurePrints
                ) { [weak appState] progress in
                    Task { @MainActor in
                        appState?.scanProgress = 0.7 + progress * 0.15
                        appState?.statusMessage = "Finding duplicates... \(Int(progress * 100))%"
                    }
                }

                appState.duplicatesFound = duplicateGroups.count

                guard !Task.isCancelled else { return }

                // Find similar photos
                appState.statusMessage = "Finding similar photos..."
                let similarGroups = await SimilarityGroupingService.shared.findSimilarGroups(
                    photos: perceptualHashes
                ) { [weak appState] progress in
                    Task { @MainActor in
                        appState?.scanProgress = 0.85 + progress * 0.1
                    }
                }

                appState.similarGroupsFound = similarGroups.count

                // Find low quality
                let lowQuality = await QualityAssessmentService.shared.findLowQualityPhotos(
                    scores: qualityScores
                ) { [weak appState] progress in
                    Task { @MainActor in
                        appState?.scanProgress = 0.95 + progress * 0.05
                    }
                }

                appState.lowQualityFound = lowQuality.count

                // Calculate space recoverable
                var spaceRecoverable: Int64 = 0
                for group in duplicateGroups {
                    let groupResults = results.filter { group.contains($0.photoId) }
                    if groupResults.count > 1 {
                        // Keep largest, count rest as recoverable
                        // (simplified - actual implementation would use file sizes)
                        spaceRecoverable += Int64((groupResults.count - 1) * 2_000_000) // Estimate 2MB per photo
                    }
                }

                appState.spaceRecoverable = spaceRecoverable
                appState.scanProgress = 1.0
                appState.scanPhase = .complete
                appState.statusMessage = "Scan complete!"

                // Store result
                let duration = Date().timeIntervalSince(startTime)
                lastScanResult = ScanResult(
                    photosScanned: totalPhotos,
                    duplicateGroups: duplicateGroups.count,
                    similarGroups: similarGroups.count,
                    lowQualityCount: lowQuality.count,
                    spaceRecoverable: spaceRecoverable,
                    duration: duration
                )

            } catch {
                if !Task.isCancelled {
                    self.error = error
                    appState.statusMessage = "Error: \(error.localizedDescription)"
                }
            }

            appState.isScanning = false
        }
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
