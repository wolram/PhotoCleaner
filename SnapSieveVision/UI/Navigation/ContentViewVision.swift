import SwiftUI

struct ContentViewVision: View {
    @EnvironmentObject private var appState: AppStateVision
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .task {
            await checkPhotoLibraryAccess()
        }
    }

    private var sidebarContent: some View {
        List(selection: $appState.selectedSection) {
            Section("Library") {
                sidebarItem(.library)
                sidebarItem(.scan)
            }

            Section("Cleanup") {
                sidebarItem(.duplicates)
                    .badge(appState.duplicatesFound)
                sidebarItem(.similar)
                    .badge(appState.similarGroupsFound)
                sidebarItem(.quality)
                    .badge(appState.lowQualityFound)
            }

            Section("Preferences") {
                sidebarItem(.settings)
            }

            Section("Experiences") {
                Button {
                    Task {
                        if appState.isImmersiveSpaceOpen {
                            await dismissImmersiveSpace()
                            appState.isImmersiveSpaceOpen = false
                        } else {
                            await openImmersiveSpace(id: "photo-gallery")
                            appState.isImmersiveSpaceOpen = true
                        }
                    }
                } label: {
                    Label(
                        appState.isImmersiveSpaceOpen ? "Exit Gallery" : "Immersive Gallery",
                        systemImage: appState.isImmersiveSpaceOpen ? "xmark.circle" : "visionpro"
                    )
                }
            }
        }
        .navigationTitle("Snap Sieve")
    }

    private func sidebarItem(_ section: AppStateVision.SectionType) -> some View {
        Label(section.rawValue, systemImage: section.icon)
            .tag(section)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch appState.selectedSection {
        case .library:
            PhotoLibraryViewVision()
        case .scan:
            ScanViewVision()
        case .duplicates:
            DuplicatesViewVision()
        case .similar:
            SimilarViewVision()
        case .quality:
            QualityViewVision()
        case .settings:
            SettingsViewVision()
        }
    }

    private func checkPhotoLibraryAccess() async {
        appState.hasPhotoLibraryAccess = await PhotoLibraryServiceVision.shared.requestAuthorization()
    }
}

#Preview(windowStyle: .automatic) {
    ContentViewVision()
        .environmentObject(AppStateVision())
}
