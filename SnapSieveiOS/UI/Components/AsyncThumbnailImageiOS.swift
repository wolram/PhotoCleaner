import SwiftUI
import Photos

struct AsyncThumbnailImageiOS: View {
    let assetId: String
    let size: CGSize

    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.5)
                    )
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    )
            }
        }
        .task(id: assetId) {
            await loadImage()
        }
    }

    private func loadImage() async {
        isLoading = true

        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject else {
            isLoading = false
            return
        }

        image = await PhotoLibraryServiceiOS.shared.loadThumbnail(for: asset, size: size)
        isLoading = false
    }
}

// MARK: - Cached Thumbnail Image

struct CachedThumbnailImageiOS: View {
    let assetId: String
    let size: CGSize

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
            }
        }
        .task(id: assetId) {
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject else { return }
            image = await PhotoLibraryServiceiOS.shared.loadThumbnail(for: asset, size: size)
        }
    }
}

#Preview {
    AsyncThumbnailImageiOS(assetId: "test", size: CGSize(width: 100, height: 100))
        .frame(width: 100, height: 100)
}
