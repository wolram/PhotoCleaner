import SwiftUI

struct ContentArea: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.selectedDestination {
            case .library:
                PhotoLibraryView()
            case .scan:
                ScanView()
            case .duplicates:
                DuplicatesView()
            case .similar:
                SimilarPhotosView()
            case .quality:
                QualityReviewView()
            case .battle:
                BattleSelectionView()
            case .categories:
                CategoriesView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentArea()
        .environmentObject(AppState())
}
