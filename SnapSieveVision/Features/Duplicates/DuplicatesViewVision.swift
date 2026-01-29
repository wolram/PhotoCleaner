import SwiftUI
import SwiftData

struct DuplicatesViewVision: View {
    @EnvironmentObject private var appState: AppStateVision
    @Environment(\.openWindow) private var openWindow
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "duplicate" })
    private var duplicateGroups: [PhotoGroupEntity]

    @State private var selectedGroup: PhotoGroupEntity?

    var body: some View {
        NavigationSplitView {
            groupListView
        } detail: {
            if let group = selectedGroup {
                DuplicateDetailViewVision(group: group)
            } else {
                selectPromptView
            }
        }
        .navigationTitle("Duplicates")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !duplicateGroups.isEmpty {
                    Button {
                        autoSelectBest()
                    } label: {
                        Label("Auto-Select Best", systemImage: "wand.and.stars")
                    }

                    if let group = selectedGroup {
                        Button {
                            openWindow(id: "photo-comparison", value: group.id)
                        } label: {
                            Label("Compare in 3D", systemImage: "cube")
                        }
                    }
                }
            }
        }
    }

    private var groupListView: some View {
        Group {
            if duplicateGroups.isEmpty {
                emptyView
            } else {
                List(selection: $selectedGroup) {
                    Section {
                        summaryCard
                    }
                    .listRowBackground(Color.clear)

                    ForEach(duplicateGroups, id: \.id) { group in
                        DuplicateGroupRowVision(group: group)
                            .tag(group)
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(duplicateGroups.count)")
                    .font(.system(size: 48, weight: .bold))
                Text("Groups")
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedTotalRecoverable)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.green)
                Text("Recoverable")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Duplicates", systemImage: "doc.on.doc")
        } description: {
            Text("Run a scan to find duplicate photos")
        } actions: {
            Button("Start Scan") {
                appState.selectedSection = .scan
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var selectPromptView: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.left.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Select a Group")
                .font(.title)

            Text("Choose a duplicate group from the sidebar")
                .foregroundStyle(.secondary)
        }
    }

    private var formattedTotalRecoverable: String {
        let total = duplicateGroups.reduce(Int64(0)) { $0 + $1.spaceRecoverable }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }

    private func autoSelectBest() {
        let selector = BestPhotoSelector()
        for group in duplicateGroups {
            let photos = group.photos.map { PhotoAsset(from: $0) }
            if let bestId = selector.selectBestId(from: photos) {
                group.selectedPhotoId = bestId
            }
        }
    }
}

// MARK: - Group Row

struct DuplicateGroupRowVision: View {
    let group: PhotoGroupEntity

    var body: some View {
        HStack(spacing: 16) {
            // Stacked thumbnails with 3D effect
            ZStack {
                ForEach(Array(group.photos.prefix(3).enumerated()), id: \.offset) { index, photo in
                    AsyncThumbnailImageVision(
                        assetId: photo.localIdentifier,
                        size: CGSize(width: 100, height: 100)
                    )
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                    .offset(x: CGFloat(index * 5), y: CGFloat(index * 5))
                    .rotation3DEffect(
                        .degrees(Double(index) * 2),
                        axis: (x: 0, y: 1, z: 0)
                    )
                }
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(group.photos.count) duplicates")
                    .font(.headline)

                Text(formattedSize)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if group.selectedPhotoId != nil {
                    Label("Best selected", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedRecoverable)
                    .font(.headline)
                    .foregroundStyle(.green)
                Text("save")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .hoverEffect(.highlight)
    }

    private var formattedSize: String {
        let total = group.photos.reduce(Int64(0)) { $0 + $1.fileSize }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }

    private var formattedRecoverable: String {
        ByteCountFormatter.string(fromByteCount: group.spaceRecoverable, countStyle: .file)
    }
}

// MARK: - Detail View

struct DuplicateDetailViewVision: View {
    @Bindable var group: PhotoGroupEntity
    @State private var showDeleteConfirmation = false

    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 350), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(group.photos.count) Duplicates")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Tap to select the best photo")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(formattedRecoverable)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        Text("space recoverable")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                // Photo Grid
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(group.photos, id: \.localIdentifier) { entity in
                        PhotoCardVision(
                            entity: entity,
                            isSelected: group.selectedPhotoId == entity.localIdentifier
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                group.selectedPhotoId = entity.localIdentifier
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            if group.selectedPhotoId != nil {
                HStack {
                    Button {
                        let selector = BestPhotoSelector()
                        let photos = group.photos.map { PhotoAsset(from: $0) }
                        group.selectedPhotoId = selector.selectBestId(from: photos)
                    } label: {
                        Label("Auto-Select", systemImage: "wand.and.stars")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete \(group.photosToDelete.count) Others", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .confirmationDialog(
            "Delete \(group.photosToDelete.count) photos?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await deleteNonSelected()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Photos will be moved to Recently Deleted")
        }
    }

    private func deleteNonSelected() async {
        let toDelete = group.photosToDelete.map { $0.localIdentifier }
        try? await PhotoLibraryServiceVision.shared.deleteAssets(identifiers: toDelete)
    }

    private var formattedRecoverable: String {
        ByteCountFormatter.string(fromByteCount: group.spaceRecoverable, countStyle: .file)
    }
}

// MARK: - Photo Card

struct PhotoCardVision: View {
    let entity: PhotoAssetEntity
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            AsyncThumbnailImageVision(
                assetId: entity.localIdentifier,
                size: CGSize(width: 400, height: 400)
            )
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Info bar
            HStack {
                if entity.pixelWidth > 0 {
                    Text("\(entity.pixelWidth)×\(entity.pixelHeight)")
                        .font(.caption)
                }

                Spacer()

                if entity.fileSize > 0 {
                    Text(ByteCountFormatter.string(fromByteCount: entity.fileSize, countStyle: .file))
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 4)
        )
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .background(Circle().fill(.white))
                    .padding(12)
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .hoverEffect(.lift)
    }
}

#Preview(windowStyle: .automatic) {
    DuplicatesViewVision()
        .environmentObject(AppStateVision())
}
