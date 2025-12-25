import SwiftUI
import SwiftData

@main
struct PhotoCleanerApp: App {
    let modelContainer: ModelContainer
    @StateObject private var appState = AppState()

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
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            SidebarCommands()
            ToolbarCommands()
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
