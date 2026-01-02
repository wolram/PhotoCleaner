import SwiftUI

struct BattleSelectionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "flame.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .symbolEffect(.pulse)
            Text("Battle Selection")
                .font(.title)
                .bold()
            Text("This is a placeholder for the Battle selection screen.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BattleSelectionView()
}
