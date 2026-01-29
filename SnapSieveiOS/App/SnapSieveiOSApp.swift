import SwiftUI
import SwiftData

@main
struct SnapSieveiOSApp: App {
    let modelContainer: ModelContainer
    @StateObject private var appState = AppStateiOS()

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
        WindowGroup {
            ContentViewiOS()
                .modelContainer(modelContainer)
                .environmentObject(appState)
        }
    }
}
