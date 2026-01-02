import SwiftUI

struct PhotoGridItem: View {
    let photo: PhotoAsset
    let isSelected: Bool
    var showCheckbox: Bool = false
    var showQuality: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                // Thumbnail
                CachedThumbnailImage(
                    assetId: photo.id,
                    size: CGSize(width: geometry.size.width * 2, height: geometry.size.width * 2)
                )
                .frame(width: geometry.size.width, height: geometry.size.width)
                .clipped()

                // Selection overlay
                if isSelected {
                    Rectangle()
                        .fill(.blue.opacity(0.3))

                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .padding(6)
                } else if showCheckbox {
                    Circle()
                        .stroke(.white.opacity(0.8), lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .shadow(radius: 2)
                        .padding(6)
                }

                // Quality indicator
                if showQuality, let score = photo.qualityScore {
                    VStack {
                        Spacer()
                        HStack {
                            ScoreIndicator(score: score.composite, size: .small)
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                            Spacer()
                        }
                    }
                    .padding(4)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
        }
    }
}

// MARK: - Comparison Item

struct PhotoComparisonItem: View {
    let photo: PhotoAsset
    let isSelected: Bool
    let isBest: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                CachedThumbnailImage(
                    assetId: photo.id,
                    size: CGSize(width: 400, height: 400)
                )
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                }

                // Best badge (top left)
                VStack {
                    HStack {
                        if isBest {
                            Label("Best", systemImage: "star.fill")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.green)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)

                // Grade indicator (top right)
                VStack {
                    HStack {
                        Spacer()
                        if let score = photo.qualityScore {
                            ScoreIndicator(score: score.composite, size: .small)
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }

            // Photo metadata panel (bottom)
            HStack {
                Text("\(Int(photo.dimensions.width))×\(Int(photo.dimensions.height))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack {
        PhotoGridItem(
            photo: PhotoAsset(id: "test1", dimensions: CGSize(width: 4000, height: 3000)),
            isSelected: false
        )
        .frame(width: 150, height: 150)

        PhotoGridItem(
            photo: PhotoAsset(id: "test2", dimensions: CGSize(width: 4000, height: 3000)),
            isSelected: true
        )
        .frame(width: 150, height: 150)
    }
    .padding()
}

