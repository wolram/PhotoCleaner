import SwiftUI
import SwiftData

@main
struct SnapSieveVisionApp: App {
    let modelContainer: ModelContainer
    @StateObject private var appState = AppStateVision()

    init() {
        do {
            let schema = Schema([
                PhotoAssetEntity.self,
                PhotoGroupEntity.self,
                ScanSessionEntity.self
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        // Main Window
        WindowGroup {
            ContentViewVision()
                .modelContainer(modelContainer)
                .environmentObject(appState)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 800)

        // Photo Comparison Volume
        WindowGroup(id: "photo-comparison", for: PhotoGroupEntity.ID.self) { $groupId in
            if let groupId = groupId {
                PhotoComparisonVolumeView(groupId: groupId)
                    .modelContainer(modelContainer)
                    .environmentObject(appState)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 0.5, in: .meters)

        // Immersive Photo Gallery
        ImmersiveSpace(id: "photo-gallery") {
            ImmersiveGalleryView()
                .modelContainer(modelContainer)
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
