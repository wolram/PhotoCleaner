import Photos
import AppKit
import Combine

actor PhotoLibraryService {
    static let shared = PhotoLibraryService()

    private let cachingManager = PHCachingImageManager()
    private var authorizationStatus: PHAuthorizationStatus = .notDetermined

    private init() {
        cachingManager.allowsCachingHighQualityImages = true
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status
        return status == .authorized || status == .limited
    }

    func checkAuthorizationStatus() -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    var isAuthorized: Bool {
        let status = checkAuthorizationStatus()
        return status == .authorized || status == .limited
    }

    // MARK: - Fetching Assets

    func fetchAllAssetIdentifiers() async -> [String] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false

        let result = PHAsset.fetchAssets(with: .image, options: options)
        var identifiers: [String] = []
        identifiers.reserveCapacity(result.count)

        result.enumerateObjects { asset, _, _ in
            identifiers.append(asset.localIdentifier)
        }

        return identifiers
    }

    func fetchAssets(limit: Int? = nil, offset: Int = 0) async -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false

        if let limit = limit {
            options.fetchLimit = offset + limit
        }

        let result = PHAsset.fetchAssets(with: .image, options: options)
        var assets: [PHAsset] = []

        let startIndex = min(offset, result.count)
        let endIndex = limit != nil ? min(offset + limit!, result.count) : result.count

        for i in startIndex..<endIndex {
            assets.append(result.object(at: i))
        }

        return assets
    }

    func fetchAsset(identifier: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        return result.firstObject
    }

    func fetchAssets(identifiers: [String]) -> [PHAsset] {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        var assets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }

    // MARK: - Image Loading

    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> NSImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = false
            options.isSynchronous = false
            options.resizeMode = .fast

            cachingManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func loadFullImage(for asset: PHAsset) async -> NSImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)

            cachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func loadCGImage(for asset: PHAsset, targetSize: CGSize) async -> CGImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = false
            options.isSynchronous = false
            options.resizeMode = .exact

            cachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                if !isDegraded {
                    if let image = image {
                        var rect = CGRect(origin: .zero, size: image.size)
                        continuation.resume(returning: image.cgImage(forProposedRect: &rect, context: nil, hints: nil))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }

    // MARK: - Caching

    func startCaching(assets: [PHAsset], size: CGSize) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = false

        cachingManager.startCachingImages(
            for: assets,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        )
    }

    func stopCaching(assets: [PHAsset], size: CGSize) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = false

        cachingManager.stopCachingImages(
            for: assets,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        )
    }

    func stopAllCaching() {
        cachingManager.stopCachingImagesForAllAssets()
    }

    // MARK: - Asset Information

    func getAssetInfo(_ asset: PHAsset) -> PhotoAsset {
        PhotoAsset(
            id: asset.localIdentifier,
            creationDate: asset.creationDate,
            modificationDate: asset.modificationDate,
            dimensions: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            fileSize: getFileSize(for: asset),
            fileName: getFileName(for: asset)
        )
    }

    private func getFileSize(for asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return 0 }

        if let size = resource.value(forKey: "fileSize") as? Int64 {
            return size
        }
        return 0
    }

    private func getFileName(for asset: PHAsset) -> String? {
        let resources = PHAssetResource.assetResources(for: asset)
        return resources.first?.originalFilename
    }

    // MARK: - Deletion

    func deleteAssets(identifiers: [String]) async throws {
        let assets = fetchAssets(identifiers: identifiers)
        guard !assets.isEmpty else { return }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }
    }

    // MARK: - Statistics

    func getLibraryStats() async -> (count: Int, totalSize: Int64) {
        let options = PHFetchOptions()
        options.includeHiddenAssets = false

        let result = PHAsset.fetchAssets(with: .image, options: options)
        var totalSize: Int64 = 0

        result.enumerateObjects { asset, _, _ in
            totalSize += self.getFileSize(for: asset)
        }

        return (result.count, totalSize)
    }
}
