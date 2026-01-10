import SwiftUI
import SwiftData

struct BattleSelectionView: View {
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "duplicate" })
    private var duplicateGroups: [PhotoGroupEntity]

    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "similar" })
    private var similarGroups: [PhotoGroupEntity]

    @State private var selectedGroup: PhotoGroupEntity?
    @State private var showingBattle = false

    private var allGroups: [PhotoGroupEntity] {
        (duplicateGroups + similarGroups).filter { $0.photos.count >= 2 }
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.purple.opacity(0.2), Color.black.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if allGroups.isEmpty {
                emptyState
            } else {
                groupSelectionContent
            }
        }
        .sheet(isPresented: $showingBattle) {
            if let group = selectedGroup {
                BattleView(group: group)
                    .frame(minWidth: 1200, minHeight: 800)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 64))
                .foregroundStyle(.gray)

            Text("No Groups Available")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Run a scan first to find duplicate or similar photo groups to battle!")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Group Selection

    private var groupSelectionContent: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 15)

                Text("Photo Battle!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)

                Text("Choose a group to start the tournament")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.top, 40)

            // Group list
            ScrollView {
                LazyVStack(spacing: 16) {
                    if !duplicateGroups.isEmpty {
                        sectionHeader("Duplicate Groups", icon: "doc.on.doc.fill", color: .red)

                        ForEach(duplicateGroups.filter { $0.photos.count >= 2 }) { group in
                            groupCard(group: group, type: .duplicate)
                        }
                    }

                    if !similarGroups.isEmpty {
                        sectionHeader("Similar Groups", icon: "square.stack.3d.up.fill", color: .orange)
                            .padding(.top, duplicateGroups.isEmpty ? 0 : 16)

                        ForEach(similarGroups.filter { $0.photos.count >= 2 }) { group in
                            groupCard(group: group, type: .similar)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }

    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    private func groupCard(group: PhotoGroupEntity, type: GroupType) -> some View {
        Button {
            // Validate before showing battle
            let validPhotos = Array(group.photos).filter { photo in
                !photo.localIdentifier.isEmpty
            }
            
            if validPhotos.count < 2 {
                print("⚠️ Group has insufficient valid photos: \(validPhotos.count)")
                return
            }
            
            selectedGroup = group
            showingBattle = true
        } label: {
            HStack(spacing: 16) {
                // Preview thumbnails
                HStack(spacing: -20) {
                    ForEach(Array(group.photos.prefix(3).enumerated()), id: \.offset) { index, photo in
                        CachedThumbnailImage(
                            assetId: photo.localIdentifier,
                            size: CGSize(width: 100, height: 100)
                        )
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                        .zIndex(Double(3 - index))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(group.photos.count) photos")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(type == .duplicate ? "DUPE" : "SIMILAR")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(type == .duplicate ? Color.red.opacity(0.3) : Color.orange.opacity(0.3))
                            .foregroundStyle(type == .duplicate ? .red : .orange)
                            .clipShape(Capsule())
                    }

                    Text(roundsText(for: group.photos.count))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.purple)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func roundsText(for photoCount: Int) -> String {
        let rounds = Int(ceil(log2(Double(photoCount))))
        return "\(rounds) round\(rounds == 1 ? "" : "s") to championship"
    }

    private enum GroupType {
        case duplicate, similar
    }
}

#Preview {
    BattleSelectionView()
}
