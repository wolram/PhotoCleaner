import SwiftUI
import Photos

struct AsyncThumbnailImage: View {
    let assetId: String
    let size: CGSize

    @State private var image: NSImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "photo")
                                .foregroundStyle(.tertiary)
                        }
                    }
            }
        }
        .task(id: assetId) {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        guard image == nil else { return }
        isLoading = true
        defer { isLoading = false }

        guard let asset = await PhotoLibraryService.shared.fetchAsset(identifier: assetId) else {
            return
        }

        image = await PhotoLibraryService.shared.loadThumbnail(for: asset, size: size)
    }
}

// MARK: - Cached Version

struct CachedThumbnailImage: View {
    let assetId: String
    let size: CGSize

    @StateObject private var loader = ThumbnailLoader()

    var body: some View {
        Group {
            if let image = loader.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        if loader.isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "photo")
                                .foregroundStyle(.tertiary)
                        }
                    }
            }
        }
        .task(id: assetId) {
            await loader.load(assetId: assetId, size: size)
        }
    }
}

@MainActor
final class ThumbnailLoader: ObservableObject {
    @Published var image: NSImage?
    @Published var isLoading = false

    private static var cache = NSCache<NSString, NSImage>()

    init() {
        Self.cache.countLimit = 500
    }

    func load(assetId: String, size: CGSize) async {
        let cacheKey = "\(assetId)_\(Int(size.width))x\(Int(size.height))" as NSString

        // Check cache
        if let cached = Self.cache.object(forKey: cacheKey) {
            image = cached
            return
        }

        isLoading = true
        defer { isLoading = false }

        guard let asset = await PhotoLibraryService.shared.fetchAsset(identifier: assetId),
              let loadedImage = await PhotoLibraryService.shared.loadThumbnail(for: asset, size: size) else {
            return
        }

        Self.cache.setObject(loadedImage, forKey: cacheKey)
        image = loadedImage
    }

    static func clearCache() {
        cache.removeAllObjects()
    }
}

#Preview {
    AsyncThumbnailImage(assetId: "test", size: CGSize(width: 200, height: 200))
        .frame(width: 200, height: 200)
}
