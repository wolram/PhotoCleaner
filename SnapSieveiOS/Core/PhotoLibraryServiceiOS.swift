import Photos
import UIKit

actor PhotoLibraryServiceiOS {
    static let shared = PhotoLibraryServiceiOS()

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

    // MARK: - Albums

    struct Album: Identifiable, Hashable {
        let id: String
        let title: String
        let count: Int
        let type: AlbumType

        enum AlbumType: String {
            case allPhotos = "all"
            case smartAlbum = "smart"
            case userAlbum = "user"
        }
    }

    func fetchAlbums() async -> [Album] {
        var albums: [Album] = []

        // Add "All Photos" option
        let allPhotosCount = PHAsset.fetchAssets(with: .image, options: nil).count
        albums.append(Album(
            id: "all-photos",
            title: "All Photos",
            count: allPhotosCount,
            type: .allPhotos
        ))

        // Smart Albums (Favorites, Screenshots, etc.)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil
        )

        smartAlbums.enumerateObjects { collection, _, _ in
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            if assets.count > 0 {
                albums.append(Album(
                    id: collection.localIdentifier,
                    title: collection.localizedTitle ?? "Untitled",
                    count: assets.count,
                    type: .smartAlbum
                ))
            }
        }

        // User Albums
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil
        )

        userAlbums.enumerateObjects { collection, _, _ in
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            if assets.count > 0 {
                albums.append(Album(
                    id: collection.localIdentifier,
                    title: collection.localizedTitle ?? "Untitled",
                    count: assets.count,
                    type: .userAlbum
                ))
            }
        }

        return albums
    }

    // MARK: - Fetching Assets

    func fetchAllAssetIdentifiers(albumId: String? = nil) async -> [String] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false

        let result: PHFetchResult<PHAsset>

        if let albumId = albumId, albumId != "all-photos" {
            let collections = PHAssetCollection.fetchAssetCollections(
                withLocalIdentifiers: [albumId],
                options: nil
            )
            if let collection = collections.firstObject {
                result = PHAsset.fetchAssets(in: collection, options: options)
            } else {
                return []
            }
        } else {
            result = PHAsset.fetchAssets(with: .image, options: options)
        }

        var identifiers: [String] = []
        identifiers.reserveCapacity(result.count)

        result.enumerateObjects { asset, _, _ in
            identifiers.append(asset.localIdentifier)
        }

        return identifiers
    }

    func fetchAsset(identifier: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        return result.firstObject
    }

    nonisolated func fetchAssets(identifiers: [String]) -> [PHAsset] {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        var assets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }

    // MARK: - Image Loading

    func loadThumbnail(for asset: PHAsset, size: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = false
            options.isSynchronous = false
            options.resizeMode = .fast

            var hasResumed = false

            cachingManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                guard !hasResumed else { return }

                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                if !isDegraded {
                    hasResumed = true
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func loadFullImage(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            var hasResumed = false

            cachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                guard !hasResumed else { return }

                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                if !isDegraded {
                    hasResumed = true
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func loadCGImage(for asset: PHAsset, targetSize: CGSize) async -> CGImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            options.resizeMode = .exact

            var hasResumed = false

            cachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                guard !hasResumed else { return }

                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                let error = info?[PHImageErrorKey] as? Error
                let cancelled = info?[PHImageCancelledKey] as? Bool ?? false

                if !isDegraded || error != nil || cancelled {
                    hasResumed = true
                    continuation.resume(returning: image?.cgImage)
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

    nonisolated func getFileSize(for asset: PHAsset) -> Int64 {
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
