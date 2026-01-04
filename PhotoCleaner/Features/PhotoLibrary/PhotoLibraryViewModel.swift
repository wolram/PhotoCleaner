import SwiftUI
import Photos

@MainActor
final class PhotoLibraryViewModel: ObservableObject {
    @Published var photos: [PhotoAsset] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var error: Error?

    private let batchSize = 100
    private var currentOffset = 0
    private var allIdentifiers: [String] = []

    // MARK: - Loading

    func loadPhotos() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // Get all identifiers first
        allIdentifiers = await PhotoLibraryService.shared.fetchAllAssetIdentifiers()
        currentOffset = 0
        photos = []

        // Load first batch
        await loadBatch()
    }

    func loadMore() async {
        guard !isLoading, hasMore else { return }
        await loadBatch()
    }

    func refresh() async {
        photos = []
        currentOffset = 0
        hasMore = true
        await loadPhotos()
    }

    private func loadBatch() async {
        isLoading = true
        defer { isLoading = false }

        let endIndex = min(currentOffset + batchSize, allIdentifiers.count)
        guard currentOffset < endIndex else {
            hasMore = false
            return
        }

        let batchIdentifiers = Array(allIdentifiers[currentOffset..<endIndex])
        let assets = await PhotoLibraryService.shared.fetchAssets(identifiers: batchIdentifiers)

        let newPhotos = assets.map { asset in
            PhotoAsset(
                id: asset.localIdentifier,
                creationDate: asset.creationDate,
                modificationDate: asset.modificationDate,
                dimensions: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                fileSize: getFileSize(for: asset),
                fileName: getFileName(for: asset)
            )
        }

        photos.append(contentsOf: newPhotos)
        currentOffset = endIndex
        hasMore = currentOffset < allIdentifiers.count
    }

    // MARK: - Helpers

    private func getFileSize(for asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return 0 }
        return (resource.value(forKey: "fileSize") as? Int64) ?? 0
    }

    private func getFileName(for asset: PHAsset) -> String? {
        PHAssetResource.assetResources(for: asset).first?.originalFilename
    }

    // MARK: - Stats

    var totalCount: Int {
        allIdentifiers.count
    }

    var loadedCount: Int {
        photos.count
    }

    var totalSize: Int64 {
        photos.reduce(0) { $0 + $1.fileSize }
    }

    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}
