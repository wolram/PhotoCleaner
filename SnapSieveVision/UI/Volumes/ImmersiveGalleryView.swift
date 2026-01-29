import SwiftUI
import SwiftData
import RealityKit

struct ImmersiveGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppStateVision
    @State private var photos: [PhotoAssetEntity] = []
    @State private var selectedPhotoId: String?

    // Gallery layout constants
    private let columns = 5
    private let rows = 3
    private let spacing: Float = 0.4
    private let photoSize: Float = 0.3

    var body: some View {
        RealityView { content in
            // Create anchor for the gallery
            let anchor = AnchorEntity(world: [0, 1.5, -2])

            // Add gallery photos
            await addGalleryPhotos(to: anchor)

            content.add(anchor)
        } update: { content in
            // Update when photos change
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .task {
            await loadPhotos()
        }
    }

    private func addGalleryPhotos(to anchor: AnchorEntity) async {
        for (index, photo) in photos.prefix(columns * rows).enumerated() {
            let row = index / columns
            let col = index % columns

            // Calculate position in curved gallery
            let angle = Float(col - columns/2) * 0.2 // Radians
            let radius: Float = 2.5

            let x = sin(angle) * radius
            let y = Float(rows/2 - row) * spacing
            let z = -cos(angle) * radius

            // Create photo entity
            let photoEntity = await createPhotoEntity(for: photo, size: photoSize)
            photoEntity.position = [x, y, z]
            photoEntity.look(at: [0, y, 0], from: photoEntity.position, relativeTo: nil)

            anchor.addChild(photoEntity)
        }
    }

    private func createPhotoEntity(for photo: PhotoAssetEntity, size: Float) async -> ModelEntity {
        // Create a plane mesh for the photo
        let mesh = MeshResource.generatePlane(width: size, height: size, cornerRadius: 0.02)

        // Create material (placeholder - would load actual texture)
        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.9))

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = photo.localIdentifier

        // Add collision for tap detection
        entity.generateCollisionShapes(recursive: true)
        entity.components.set(InputTargetComponent())

        // Add hover effect
        entity.components.set(HoverEffectComponent())

        return entity
    }

    private func handleTap(on entity: Entity) {
        selectedPhotoId = entity.name
    }

    private func loadPhotos() async {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        photos = (try? modelContext.fetch(descriptor)) ?? []
    }
}

// MARK: - Components

struct HoverEffectComponent: Component {
    var isHovered = false
}

#Preview(immersionStyle: .mixed) {
    ImmersiveGalleryView()
        .environmentObject(AppStateVision())
}
