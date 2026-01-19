import SwiftUI
import SwiftData

struct SimilarPhotosView: View {
    @EnvironmentObject private var appState: AppState
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "similar" })
    private var similarGroups: [PhotoGroupEntity]

    @State private var selectedGroup: PhotoGroupEntity?
    @State private var viewMode: ViewMode = .grid

    enum ViewMode: String, CaseIterable {
        case grid = "Grid"
        case stack = "Stack"

        var icon: String {
            switch self {
            case .grid: return "square.grid.2x2"
            case .stack: return "square.stack.3d.up"
            }
        }
    }

    var body: some View {
        Group {
            if similarGroups.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .onAppear {
            print("SimilarPhotosView appeared. Found \(similarGroups.count) groups.")
            // Auto-select first group if none selected
            if selectedGroup == nil && !similarGroups.isEmpty {
                selectedGroup = similarGroups.first
            }
        }
        .toolbar {
            ToolbarItemGroup {
                if !similarGroups.isEmpty {
                    Text("\(similarGroups.count) groups")
                        .foregroundStyle(.secondary)

                    Picker("View", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    // MARK: - Views

    private var contentView: some View {
        HSplitView {
            // Group list
            List(similarGroups, selection: $selectedGroup) { group in
                SimilarGroupRow(group: group)
                    .tag(group)
            }
            .listStyle(.sidebar)
            .frame(minWidth: 280, maxWidth: 350)

            // Detail view
            if let group = selectedGroup {
                SimilarGroupDetailView(group: group, viewMode: viewMode)
            } else {
                selectPrompt
            }
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "square.stack.3d.up",
            title: "No Similar Photos Found",
            message: "Run a scan to find groups of similar photos in your library.",
            actionTitle: "Start Scan"
        ) {
            appState.selectedDestination = .scan
        }
    }

    private var selectPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Select a Group")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a group of similar photos to review")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Group Row

struct SimilarGroupRow: View {
    let group: PhotoGroupEntity

    var body: some View {
        HStack(spacing: 12) {
            // Stacked preview
            ZStack {
                ForEach(Array(group.photos.prefix(4).enumerated()), id: \.offset) { index, photo in
                    CachedThumbnailImage(
                        assetId: photo.localIdentifier,
                        size: CGSize(width: 100, height: 100)
                    )
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .offset(x: CGFloat(index * 3), y: CGFloat(index * 3))
                    .shadow(radius: 1)
                }
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(group.photos.count) similar photos")
                    .fontWeight(.medium)

                if let date = group.photos.first?.creationDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail View

struct SimilarGroupDetailView: View {
    let group: PhotoGroupEntity
    let viewMode: SimilarPhotosView.ViewMode
    @State private var selection = Set<String>()
    @State private var showDeleteConfirmation = false
    @State private var deleteMode: DeleteMode = .selected

    enum DeleteMode {
        case selected
        case unselected
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(group.photos.count) Similar Photos")
                    .font(.headline)

                Spacer()

                if !selection.isEmpty {
                    Text("\(selection.count) selected")
                        .foregroundStyle(.secondary)

                    Button("Deselect All") {
                        selection.removeAll()
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding()
            .background(.regularMaterial)

            Divider()

            // Content
            ScrollView {
                switch viewMode {
                case .grid:
                    gridView
                case .stack:
                    stackView
                }
            }

            // Actions
            if !selection.isEmpty {
                Divider()
                actionBar
            }
        }
        .confirmationDialog(
            deleteMode == .selected ? "Delete \(selection.count) photos?" : "Delete \(group.photos.count - selection.count) photos?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Move to Trash", role: .destructive) {
                Task {
                    await deletePhotos()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if deleteMode == .selected {
                Text("The selected photos will be moved to Recently Deleted.")
            } else {
                Text("The selected photos will be kept. All others will be moved to Recently Deleted.")
            }
        }
    }

    private var gridView: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 150, maximum: 200))],
            spacing: 8
        ) {
            ForEach(group.photos, id: \.localIdentifier) { entity in
                let photo = PhotoAsset(from: entity)

                PhotoGridItem(
                    photo: photo,
                    isSelected: selection.contains(entity.localIdentifier),
                    showCheckbox: true
                )
                .onTapGesture {
                    if selection.contains(entity.localIdentifier) {
                        selection.remove(entity.localIdentifier)
                    } else {
                        selection.insert(entity.localIdentifier)
                    }
                }
            }
        }
        .padding()
    }

    private var stackView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(group.photos, id: \.localIdentifier) { entity in
                    let photo = PhotoAsset(from: entity)
                    let isSelected = selection.contains(entity.localIdentifier)

                    VStack {
                        CachedThumbnailImage(
                            assetId: entity.localIdentifier,
                            size: CGSize(width: 400, height: 400)
                        )
                        .frame(width: 250, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            }
                        }

                        Text(photo.formattedDimensions)
                            .font(.caption)

                        Button {
                            if isSelected {
                                selection.remove(entity.localIdentifier)
                            } else {
                                selection.insert(entity.localIdentifier)
                            }
                        } label: {
                            Label(
                                isSelected ? "Selected" : "Select",
                                systemImage: isSelected ? "checkmark.circle.fill" : "circle"
                            )
                        }
                        .buttonStyle(.bordered)
                        .tint(isSelected ? .green : .secondary)
                    }
                }
            }
            .padding()
        }
    }

    private var actionBar: some View {
        HStack {
            Text("\(selection.count) photos selected")
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                deleteMode = .unselected
                showDeleteConfirmation = true
            } label: {
                Label("Delete Others (\(group.photos.count - selection.count))", systemImage: "trash")
            }
            .disabled(selection.count == group.photos.count)

            Button(role: .destructive) {
                deleteMode = .selected
                showDeleteConfirmation = true
            } label: {
                Label("Delete Selected (\(selection.count))", systemImage: "trash.fill")
            }
        }
        .padding()
        .background(.regularMaterial)
    }

    private func deletePhotos() async {
        let toDelete: [String]

        if deleteMode == .selected {
            toDelete = Array(selection)
        } else {
            toDelete = group.photos
                .map { $0.localIdentifier }
                .filter { !selection.contains($0) }
        }

        do {
            try await PhotoLibraryService.shared.deleteAssets(identifiers: toDelete)
            selection.removeAll()
        } catch {
            print("❌ Delete error: \(error)")
        }
    }
}

#Preview {
    SimilarPhotosView()
        .environmentObject(AppState())
}
