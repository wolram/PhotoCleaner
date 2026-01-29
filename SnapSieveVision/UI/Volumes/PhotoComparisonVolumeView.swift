import SwiftUI
import SwiftData
import RealityKit

struct PhotoComparisonVolumeView: View {
    let groupId: PhotoGroupEntity.ID
    @Environment(\.modelContext) private var modelContext
    @State private var group: PhotoGroupEntity?
    @State private var currentIndex = 0
    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader3D { geometry in
            ZStack {
                if let group = group {
                    // 3D Photo carousel
                    ForEach(Array(group.photos.enumerated()), id: \.offset) { index, photo in
                        photoCard(for: photo, at: index, total: group.photos.count)
                    }

                    // Controls ornament
                    VStack {
                        Spacer()

                        HStack(spacing: 32) {
                            Button {
                                withAnimation(.spring(response: 0.5)) {
                                    currentIndex = max(0, currentIndex - 1)
                                    rotation -= 360.0 / Double(group.photos.count)
                                }
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 44))
                            }
                            .buttonStyle(.plain)
                            .disabled(currentIndex == 0)

                            VStack(spacing: 4) {
                                Text("\(currentIndex + 1) of \(group.photos.count)")
                                    .font(.headline)

                                if group.selectedPhotoId == group.photos[currentIndex].localIdentifier {
                                    Label("Best", systemImage: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.caption)
                                }
                            }

                            Button {
                                withAnimation(.spring(response: 0.5)) {
                                    currentIndex = min(group.photos.count - 1, currentIndex + 1)
                                    rotation += 360.0 / Double(group.photos.count)
                                }
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 44))
                            }
                            .buttonStyle(.plain)
                            .disabled(currentIndex == group.photos.count - 1)
                        }
                        .padding()
                        .background(.regularMaterial, in: Capsule())
                    }
                    .padding(.bottom, 50)
                } else {
                    ProgressView("Loading...")
                }
            }
        }
        .task {
            loadGroup()
        }
    }

    @ViewBuilder
    private func photoCard(for photo: PhotoAssetEntity, at index: Int, total: Int) -> some View {
        let angle = (360.0 / Double(total)) * Double(index) + rotation
        let radians = angle * .pi / 180
        let radius: Double = 0.3 // meters

        AsyncThumbnailImageVision(
            assetId: photo.localIdentifier,
            size: CGSize(width: 600, height: 600)
        )
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    group?.selectedPhotoId == photo.localIdentifier ? Color.green : Color.clear,
                    lineWidth: 4
                )
        )
        .overlay(alignment: .topTrailing) {
            if group?.selectedPhotoId == photo.localIdentifier {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.green)
                    .background(Circle().fill(.white))
                    .padding(12)
            }
        }
        .rotation3DEffect(
            .degrees(-angle),
            axis: (x: 0, y: 1, z: 0)
        )
        .offset(
            x: CGFloat(sin(radians) * radius * 1000),
            z: CGFloat(cos(radians) * radius * 1000)
        )
        .opacity(index == currentIndex ? 1.0 : 0.6)
        .scaleEffect(index == currentIndex ? 1.0 : 0.8)
        .animation(.spring(response: 0.5), value: currentIndex)
        .onTapGesture {
            withAnimation {
                group?.selectedPhotoId = photo.localIdentifier
            }
        }
    }

    private func loadGroup() {
        let descriptor = FetchDescriptor<PhotoGroupEntity>(
            predicate: #Predicate { $0.id == groupId }
        )
        group = try? modelContext.fetch(descriptor).first
    }
}

#Preview(windowStyle: .volumetric) {
    PhotoComparisonVolumeView(groupId: UUID())
        .environmentObject(AppStateVision())
}
