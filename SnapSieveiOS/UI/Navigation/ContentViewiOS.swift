import SwiftUI

struct ContentViewiOS: View {
    @EnvironmentObject private var appState: AppStateiOS

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            PhotoLibraryViewiOS()
                .tabItem {
                    Label(AppStateiOS.TabSelection.library.title,
                          systemImage: AppStateiOS.TabSelection.library.icon)
                }
                .tag(AppStateiOS.TabSelection.library)

            ScanViewiOS()
                .tabItem {
                    Label(AppStateiOS.TabSelection.scan.title,
                          systemImage: AppStateiOS.TabSelection.scan.icon)
                }
                .tag(AppStateiOS.TabSelection.scan)

            DuplicatesViewiOS()
                .tabItem {
                    Label(AppStateiOS.TabSelection.duplicates.title,
                          systemImage: AppStateiOS.TabSelection.duplicates.icon)
                }
                .tag(AppStateiOS.TabSelection.duplicates)
                .badge(appState.duplicatesFound > 0 ? appState.duplicatesFound : 0)

            SimilarViewiOS()
                .tabItem {
                    Label(AppStateiOS.TabSelection.similar.title,
                          systemImage: AppStateiOS.TabSelection.similar.icon)
                }
                .tag(AppStateiOS.TabSelection.similar)
                .badge(appState.similarGroupsFound > 0 ? appState.similarGroupsFound : 0)

            SettingsViewiOS()
                .tabItem {
                    Label(AppStateiOS.TabSelection.settings.title,
                          systemImage: AppStateiOS.TabSelection.settings.icon)
                }
                .tag(AppStateiOS.TabSelection.settings)
        }
        .task {
            await checkPhotoLibraryAccess()
        }
    }

    private func checkPhotoLibraryAccess() async {
        appState.hasPhotoLibraryAccess = await PhotoLibraryServiceiOS.shared.requestAuthorization()
    }
}

#Preview {
    ContentViewiOS()
        .environmentObject(AppStateiOS())
}
