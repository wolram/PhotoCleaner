import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            MainSidebar()
        } detail: {
            ContentArea()
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 900, minHeight: 600)
        .task {
            await checkPhotoLibraryAccess()
        }
    }

    private func checkPhotoLibraryAccess() async {
        appState.hasPhotoLibraryAccess = await PhotoLibraryService.shared.requestAuthorization()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
