import SwiftUI
import SwiftData
import Photos

@MainActor
final class ScanViewModeliOS: ObservableObject {
    @Published var isLoadingAlbums = false
    @Published var albums: [PhotoLibraryServiceiOS.Album] = []
    @Published var selectedAlbum: PhotoLibraryServiceiOS.Album?
    @Published var lastScanResult: ScanResult?

    weak var appState: AppStateiOS?
    var modelContext: ModelContext?

    struct ScanResult {
        let photosScanned: Int
        let duplicateGroups: Int
        let similarGroups: Int
        let lowQualityCount: Int
        let spaceRecoverable: Int64

        var formattedSpaceRecoverable: String {
            ByteCountFormatter.string(fromByteCount: spaceRecoverable, countStyle: .file)
        }
    }

    func loadAlbums() async {
        isLoadingAlbums = true
        albums = await PhotoLibraryServiceiOS.shared.fetchAlbums()
        selectedAlbum = albums.first
        isLoadingAlbums = false
    }

    func startScan() async {
        guard let appState = appState, let modelContext = modelContext else { return }

        appState.isScanning = true
        appState.resetScanStats()
        appState.scanPhase = .loading
        appState.statusMessage = "Loading photos..."

        let albumId = selectedAlbum?.id

        // Phase 1: Load asset identifiers
        let identifiers = await PhotoLibraryServiceiOS.shared.fetchAllAssetIdentifiers(albumId: albumId)
        let totalPhotos = identifiers.count

        guard totalPhotos > 0 else {
            appState.isScanning = false
            appState.scanPhase = .idle
            appState.statusMessage = "No photos found"
            return
        }

        appState.scanPhase = .analyzing
        appState.statusMessage = "Analyzing \(totalPhotos) photos..."

        // Phase 2: Process in batches
        let batchSize = 50
        var processedCount = 0
        var duplicateGroups: [[String]] = []
        var similarGroups: [[String]] = []
        var lowQualityIds: [String] = []
        var totalSpaceRecoverable: Int64 = 0

        for batchStart in stride(from: 0, to: totalPhotos, by: batchSize) {
            if Task.isCancelled { break }

            let batchEnd = min(batchStart + batchSize, totalPhotos)
            let batchIds = Array(identifiers[batchStart..<batchEnd])

            // Process batch
            let results = await BatchProcessingService.shared.processBatch(identifiers: batchIds)

            processedCount += batchIds.count
            appState.photosScanned = processedCount
            appState.scanProgress = Double(processedCount) / Double(totalPhotos)
            appState.statusMessage = "Analyzed \(processedCount) of \(totalPhotos) photos"

            // Incremental duplicate detection
            if let newDuplicates = await DuplicateDetectionService.shared.findDuplicatesInBatch(results) {
                duplicateGroups.append(contentsOf: newDuplicates)
                appState.duplicatesFound = duplicateGroups.count
            }

            // Incremental similar photo detection
            if let newSimilar = await SimilarityGroupingService.shared.findSimilarInBatch(results) {
                similarGroups.append(contentsOf: newSimilar)
                appState.similarGroupsFound = similarGroups.count
            }

            // Quality assessment
            for result in results {
                if let quality = result.qualityScore, quality < appState.qualityThreshold {
                    lowQualityIds.append(result.id)
                    appState.lowQualityFound = lowQualityIds.count
                }
            }
        }

        // Phase 3: Grouping
        appState.scanPhase = .grouping
        appState.statusMessage = "Finalizing groups..."

        // Calculate space recoverable
        for group in duplicateGroups {
            if group.count > 1 {
                let assets = PhotoLibraryServiceiOS.shared.fetchAssets(identifiers: Array(group.dropFirst()))
                for asset in assets {
                    totalSpaceRecoverable += PhotoLibraryServiceiOS.shared.getFileSize(for: asset)
                }
            }
        }

        appState.spaceRecoverable = totalSpaceRecoverable

        // Phase 4: Save to SwiftData
        await saveResults(
            duplicateGroups: duplicateGroups,
            similarGroups: similarGroups,
            lowQualityIds: lowQualityIds,
            modelContext: modelContext
        )

        // Complete
        appState.scanPhase = .complete
        appState.isScanning = false

        lastScanResult = ScanResult(
            photosScanned: processedCount,
            duplicateGroups: duplicateGroups.count,
            similarGroups: similarGroups.count,
            lowQualityCount: lowQualityIds.count,
            spaceRecoverable: totalSpaceRecoverable
        )
    }

    func cancelScan() {
        appState?.cancelScan()
    }

    private func saveResults(
        duplicateGroups: [[String]],
        similarGroups: [[String]],
        lowQualityIds: [String],
        modelContext: ModelContext
    ) async {
        // Save duplicate groups
        for group in duplicateGroups {
            let groupEntity = PhotoGroupEntity(groupType: "duplicate")
            for id in group {
                let photoEntity = PhotoAssetEntity(localIdentifier: id)
                groupEntity.photos.append(photoEntity)
                modelContext.insert(photoEntity)
            }
            modelContext.insert(groupEntity)
        }

        // Save similar groups
        for group in similarGroups {
            let groupEntity = PhotoGroupEntity(groupType: "similar")
            for id in group {
                let photoEntity = PhotoAssetEntity(localIdentifier: id)
                groupEntity.photos.append(photoEntity)
                modelContext.insert(photoEntity)
            }
            modelContext.insert(groupEntity)
        }

        try? modelContext.save()
    }
}
