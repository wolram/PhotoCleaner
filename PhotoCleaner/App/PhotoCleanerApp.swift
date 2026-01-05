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
        
        // Configure the app - must be called after all stored properties are initialized
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(appState)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1200, height: 800)
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
    
    private func setupApp() {
        // Ensure bundle identifier is set
        if let bundleID = Bundle.main.bundleIdentifier {
            print("✅ App Bundle Identifier: \(bundleID)")
        } else {
            print("⚠️ Warning: Bundle identifier not found")
        }
    }
}
