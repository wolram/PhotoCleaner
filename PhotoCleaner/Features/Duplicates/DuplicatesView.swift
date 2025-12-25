import SwiftUI
import SwiftData

struct DuplicatesView: View {
    @EnvironmentObject private var appState: AppState
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "duplicate" })
    private var duplicateGroups: [PhotoGroupEntity]

    @State private var selectedGroup: PhotoGroupEntity?
    @State private var showDeleteConfirmation = false
    @State private var photosToDelete: [String] = []

    var body: some View {
        Group {
            if duplicateGroups.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle("Duplicates")
        .toolbar {
            ToolbarItemGroup {
                if !duplicateGroups.isEmpty {
                    Text("\(duplicateGroups.count) groups")
                        .foregroundStyle(.secondary)

                    Button {
                        autoSelectBest()
                    } label: {
                        Label("Auto-Select Best", systemImage: "wand.and.stars")
                    }

                    Button(role: .destructive) {
                        prepareDeleteAll()
                    } label: {
                        Label("Delete All Duplicates", systemImage: "trash")
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete \(photosToDelete.count) photos?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await deletePhotos()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. The photos will be moved to Recently Deleted.")
        }
    }

    // MARK: - Views

    private var contentView: some View {
        HSplitView {
            // Group list
            List(duplicateGroups, selection: $selectedGroup) { group in
                DuplicateGroupRow(group: group)
                    .tag(group)
            }
            .listStyle(.sidebar)
            .frame(minWidth: 280, maxWidth: 350)

            // Detail view
            if let group = selectedGroup {
                DuplicateDetailView(group: group)
            } else {
                selectGroupPrompt
            }
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "doc.on.doc",
            title: "No Duplicates Found",
            message: "Your photo library is clean! Run a scan to check for duplicates.",
            actionTitle: "Start Scan"
        ) {
            appState.selectedDestination = .scan
        }
    }

    private var selectGroupPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Select a Group")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a duplicate group from the sidebar to compare photos")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private func autoSelectBest() {
        let selector = BestPhotoSelector()
        for group in duplicateGroups {
            let photos = group.photos.map { PhotoAsset(from: $0) }
            if let bestId = selector.selectBestId(from: photos) {
                group.selectedPhotoId = bestId
            }
        }
    }

    private func prepareDeleteAll() {
        photosToDelete = duplicateGroups.flatMap { group in
            group.photosToDelete.map { $0.localIdentifier }
        }
        showDeleteConfirmation = true
    }

    private func deletePhotos() async {
        do {
            try await PhotoLibraryService.shared.deleteAssets(identifiers: photosToDelete)
            photosToDelete = []
        } catch {
            print("Delete error: \(error)")
        }
    }
}

// MARK: - Group Row

struct DuplicateGroupRow: View {
    let group: PhotoGroupEntity

    var body: some View {
        HStack(spacing: 12) {
            // Preview thumbnails
            ZStack {
                ForEach(Array(group.photos.prefix(3).enumerated()), id: \.offset) { index, photo in
                    CachedThumbnailImage(
                        assetId: photo.localIdentifier,
                        size: CGSize(width: 80, height: 80)
                    )
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .offset(x: CGFloat(index * 4), y: CGFloat(index * 4))
                }
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(group.photos.count) photos")
                    .fontWeight(.medium)

                Text(formattedSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if group.selectedPhotoId != nil {
                    Label("Best selected", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            Text(formattedRecoverable)
                .font(.caption)
                .foregroundStyle(.green)
        }
        .padding(.vertical, 4)
    }

    private var formattedSize: String {
        let total = group.photos.reduce(0) { $0 + $1.fileSize }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }

    private var formattedRecoverable: String {
        ByteCountFormatter.string(fromByteCount: group.spaceRecoverable, countStyle: .file)
    }
}

// MARK: - Detail View

struct DuplicateDetailView: View {
    @Bindable var group: PhotoGroupEntity
    @State private var selectedPhotoId: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(group.photos.count) Duplicate Photos")
                    .font(.headline)

                Spacer()

                Text("Space recoverable: \(formattedRecoverable)")
                    .foregroundStyle(.green)
            }
            .padding()
            .background(.regularMaterial)

            Divider()

            // Photo comparison
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 200, maximum: 300))],
                    spacing: 16
                ) {
                    ForEach(group.photos, id: \.localIdentifier) { entity in
                        let photo = PhotoAsset(from: entity)
                        let isBest = group.selectedPhotoId == entity.localIdentifier

                        PhotoComparisonItem(
                            photo: photo,
                            isSelected: selectedPhotoId == entity.localIdentifier,
                            isBest: isBest
                        )
                        .onTapGesture {
                            group.selectedPhotoId = entity.localIdentifier
                            selectedPhotoId = entity.localIdentifier
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Actions
            HStack {
                Button {
                    let selector = BestPhotoSelector()
                    let photos = group.photos.map { PhotoAsset(from: $0) }
                    group.selectedPhotoId = selector.selectBestId(from: photos)
                } label: {
                    Label("Auto-Select Best", systemImage: "wand.and.stars")
                }

                Spacer()

                if group.selectedPhotoId != nil {
                    Button(role: .destructive) {
                        // Delete non-selected photos
                    } label: {
                        Label("Delete Others", systemImage: "trash")
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
        }
    }

    private var formattedRecoverable: String {
        ByteCountFormatter.string(fromByteCount: group.spaceRecoverable, countStyle: .file)
    }
}

#Preview {
    DuplicatesView()
        .environmentObject(AppState())
}
