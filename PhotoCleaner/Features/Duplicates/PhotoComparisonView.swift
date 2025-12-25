import SwiftUI

struct PhotoComparisonView: View {
    let photos: [PhotoAsset]
    @Binding var selectedId: String?
    var bestId: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(photos) { photo in
                    comparisonCard(for: photo)
                }
            }
            .padding()
        }
    }

    private func comparisonCard(for photo: PhotoAsset) -> some View {
        let isSelected = selectedId == photo.id
        let isBest = bestId == photo.id

        return VStack(spacing: 12) {
            // Image
            ZStack(alignment: .topLeading) {
                CachedThumbnailImage(
                    assetId: photo.id,
                    size: CGSize(width: 500, height: 500)
                )
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                if isBest {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("Best")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(8)
                }
            }

            // Info
            VStack(spacing: 4) {
                Text(photo.formattedDimensions)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(photo.formattedFileSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let date = photo.creationDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            // Quality scores
            if let score = photo.qualityScore {
                VStack(spacing: 6) {
                    ScoreBar(label: "Overall", value: score.composite, color: .blue)
                    ScoreBar(label: "Sharpness", value: score.blurScore, color: .green)
                    ScoreBar(label: "Exposure", value: 1 - abs(score.exposureScore - 0.5) * 2, color: .orange)
                }
                .frame(width: 200)
            }

            // Select button
            Button {
                selectedId = photo.id
            } label: {
                Label(
                    isSelected ? "Selected" : "Keep This",
                    systemImage: isSelected ? "checkmark.circle.fill" : "circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(isSelected ? .green : .blue)
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        }
    }
}

// MARK: - Side by Side Comparison

struct SideBySideComparison: View {
    let photo1: PhotoAsset
    let photo2: PhotoAsset

    var body: some View {
        HStack(spacing: 0) {
            comparisonPane(for: photo1, side: .left)
            Divider()
            comparisonPane(for: photo2, side: .right)
        }
    }

    private func comparisonPane(for photo: PhotoAsset, side: Side) -> some View {
        VStack(spacing: 0) {
            // Image
            CachedThumbnailImage(
                assetId: photo.id,
                size: CGSize(width: 800, height: 800)
            )
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Info bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(photo.formattedDimensions)
                        .font(.caption)
                    Text(photo.formattedFileSize)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let score = photo.qualityScore {
                    ScoreIndicator(score: score.composite, showLabel: true, size: .small)
                }
            }
            .padding()
            .background(.regularMaterial)
        }
    }

    enum Side {
        case left, right
    }
}

// MARK: - Zoom Comparison

struct ZoomComparisonView: View {
    let photos: [PhotoAsset]
    @State private var selectedIndex = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            // Main image
            GeometryReader { geometry in
                CachedThumbnailImage(
                    assetId: photos[selectedIndex].id,
                    size: CGSize(width: 2000, height: 2000)
                )
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
            }

            // Thumbnail strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                        CachedThumbnailImage(
                            assetId: photo.id,
                            size: CGSize(width: 120, height: 120)
                        )
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(selectedIndex == index ? Color.accentColor : Color.clear, lineWidth: 2)
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedIndex = index
                                scale = 1.0
                                offset = .zero
                            }
                        }
                    }
                }
                .padding()
            }
            .background(.regularMaterial)
        }
    }
}

#Preview {
    PhotoComparisonView(
        photos: [
            PhotoAsset(id: "1", dimensions: CGSize(width: 4000, height: 3000)),
            PhotoAsset(id: "2", dimensions: CGSize(width: 3000, height: 2000))
        ],
        selectedId: .constant("1"),
        bestId: "1"
    )
}
