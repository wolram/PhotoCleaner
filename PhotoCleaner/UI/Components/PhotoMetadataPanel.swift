import SwiftUI

struct PhotoMetadataPanel: View {
    let photo: PhotoAsset

    private var formattedDate: String {
        guard let date = photo.creationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var formattedMegapixels: String {
        String(format: "%.1f MP", photo.megapixels)
    }

    var body: some View {
        HStack(spacing: 12) {
            // File name
            MetadataItem(
                icon: "doc.fill",
                value: photo.fileName ?? "Unknown"
            )

            Divider()
                .frame(height: 16)

            // File size
            MetadataItem(
                icon: "internaldrive.fill",
                value: photo.formattedFileSize
            )

            Divider()
                .frame(height: 16)

            // Dimensions
            MetadataItem(
                icon: "rectangle.dashed",
                value: photo.formattedDimensions
            )

            Divider()
                .frame(height: 16)

            // Megapixels
            MetadataItem(
                icon: "camera.fill",
                value: formattedMegapixels
            )

            Divider()
                .frame(height: 16)

            // Creation date
            MetadataItem(
                icon: "calendar",
                value: formattedDate
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Metadata Item

private struct MetadataItem: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.caption)
                .lineLimit(1)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8)

        VStack {
            Spacer()
            HStack {
                PhotoMetadataPanel(
                    photo: PhotoAsset(
                        id: "preview-1",
                        creationDate: Date(),
                        dimensions: CGSize(width: 4000, height: 3000),
                        fileSize: 2_500_000,
                        fileName: "IMG_1234.jpg"
                    )
                )
                Spacer()
            }
            .padding()
        }
    }
    .frame(width: 800, height: 600)
}
