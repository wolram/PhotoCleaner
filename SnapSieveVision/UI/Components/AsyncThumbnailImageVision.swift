import SwiftUI
import Photos

struct AsyncThumbnailImageVision: View {
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
                    .fill(.ultraThinMaterial)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.6)
                    )
            } else {
                Rectangle()
                    .fill(.ultraThinMaterial)
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

        image = await PhotoLibraryServiceVision.shared.loadThumbnail(for: asset, size: size)
        isLoading = false
    }
}

#Preview(windowStyle: .automatic) {
    AsyncThumbnailImageVision(assetId: "test", size: CGSize(width: 200, height: 200))
        .frame(width: 200, height: 200)
}
