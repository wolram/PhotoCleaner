import SwiftUI
import SwiftData

struct DuplicatesViewiOS: View {
    @EnvironmentObject private var appState: AppStateiOS
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "duplicate" })
    private var duplicateGroups: [PhotoGroupEntity]

    @State private var selectedGroup: PhotoGroupEntity?
    @State private var showDeleteConfirmation = false
    @State private var photosToDelete: [String] = []

    var body: some View {
        NavigationStack {
            Group {
                if duplicateGroups.isEmpty {
                    emptyView
                } else {
                    groupListView
                }
            }
            .navigationTitle("Duplicates")
            .toolbar {
                if !duplicateGroups.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
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
                        } label: {
                            Image(systemName: "ellipsis.circle")
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
    }

    // MARK: - Views

    private var groupListView: some View {
        List {
            Section {
                summaryCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section("Duplicate Groups (\(duplicateGroups.count))") {
                ForEach(duplicateGroups, id: \.id) { group in
                    NavigationLink {
                        DuplicateDetailViewiOS(group: group)
                    } label: {
                        DuplicateGroupRowiOS(group: group)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(duplicateGroups.count)")
                        .font(.system(size: 36, weight: .bold))
                    Text("Duplicate Groups")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedTotalRecoverable)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.green)
                    Text("Space Recoverable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Duplicates", systemImage: "doc.on.doc")
        } description: {
            Text("Your photo library is clean! Run a scan to check for duplicates.")
        } actions: {
            Button("Start Scan") {
                appState.selectedTab = .scan
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var formattedTotalRecoverable: String {
        let total = duplicateGroups.reduce(Int64(0)) { $0 + $1.spaceRecoverable }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
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
            try await PhotoLibraryServiceiOS.shared.deleteAssets(identifiers: photosToDelete)
            photosToDelete = []
        } catch {
            print("Delete error: \(error)")
        }
    }
}

// MARK: - Group Row

struct DuplicateGroupRowiOS: View {
    let group: PhotoGroupEntity

    var body: some View {
        HStack(spacing: 12) {
            // Stacked thumbnails
            ZStack {
                ForEach(Array(group.photos.prefix(3).enumerated()), id: \.offset) { index, photo in
                    AsyncThumbnailImageiOS(
                        assetId: photo.localIdentifier,
                        size: CGSize(width: 100, height: 100)
                    )
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .offset(x: CGFloat(index * 3), y: CGFloat(index * 3))
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
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Best selected")
                    }
                    .font(.caption2)
                    .foregroundStyle(.green)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedRecoverable)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                Text("recoverable")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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

struct DuplicateDetailViewiOS: View {
    @Bindable var group: PhotoGroupEntity
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Info Header
                infoHeader

                // Photo Grid
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(group.photos, id: \.localIdentifier) { entity in
                        PhotoComparisonItemiOS(
                            entity: entity,
                            isBest: group.selectedPhotoId == entity.localIdentifier
                        )
                        .onTapGesture {
                            withAnimation {
                                group.selectedPhotoId = entity.localIdentifier
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Duplicate Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let selector = BestPhotoSelector()
                    let photos = group.photos.map { PhotoAsset(from: $0) }
                    group.selectedPhotoId = selector.selectBestId(from: photos)
                } label: {
                    Image(systemName: "wand.and.stars")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if group.selectedPhotoId != nil {
                deleteButton
            }
        }
        .confirmationDialog(
            "Delete \(group.photosToDelete.count) photos?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Move to Trash", role: .destructive) {
                Task {
                    await deleteNonSelected()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Space saved: \(formattedRecoverable)")
        }
    }

    private var infoHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(group.photos.count) Duplicates")
                    .font(.headline)
                Text("Tap to select the photo to keep")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(formattedRecoverable)
                    .font(.headline)
                    .foregroundStyle(.green)
                Text("recoverable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete \(group.photosToDelete.count) Others")
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .padding()
        .background(.ultraThinMaterial)
    }

    private func deleteNonSelected() async {
        let toDelete = group.photosToDelete.map { $0.localIdentifier }
        do {
            try await PhotoLibraryServiceiOS.shared.deleteAssets(identifiers: toDelete)
            dismiss()
        } catch {
            print("Delete error: \(error)")
        }
    }

    private var formattedRecoverable: String {
        ByteCountFormatter.string(fromByteCount: group.spaceRecoverable, countStyle: .file)
    }
}

// MARK: - Photo Comparison Item

struct PhotoComparisonItemiOS: View {
    let entity: PhotoAssetEntity
    let isBest: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AsyncThumbnailImageiOS(
                assetId: entity.localIdentifier,
                size: CGSize(width: 300, height: 300)
            )
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isBest ? Color.green : Color.clear, lineWidth: 4)
            )

            if isBest {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .background(Circle().fill(.white))
                    .padding(8)
            }
        }
    }
}

#Preview {
    DuplicatesViewiOS()
        .environmentObject(AppStateiOS())
}
