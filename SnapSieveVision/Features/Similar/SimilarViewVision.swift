import SwiftUI
import SwiftData

struct SimilarViewVision: View {
    @EnvironmentObject private var appState: AppStateVision
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "similar" })
    private var similarGroups: [PhotoGroupEntity]

    @State private var selectedGroup: PhotoGroupEntity?

    var body: some View {
        NavigationSplitView {
            groupListView
        } detail: {
            if let group = selectedGroup {
                SimilarDetailViewVision(group: group)
            } else {
                selectPromptView
            }
        }
        .navigationTitle("Similar Photos")
        .toolbar {
            if !similarGroups.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        autoSelectBest()
                    } label: {
                        Label("Auto-Select Best", systemImage: "wand.and.stars")
                    }
                }
            }
        }
    }

    private var groupListView: some View {
        Group {
            if similarGroups.isEmpty {
                emptyView
            } else {
                List(selection: $selectedGroup) {
                    Section {
                        summaryCard
                    }
                    .listRowBackground(Color.clear)

                    ForEach(similarGroups, id: \.id) { group in
                        SimilarGroupRowVision(group: group)
                            .tag(group)
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(similarGroups.count)")
                    .font(.system(size: 48, weight: .bold))
                Text("Groups")
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(totalPhotos)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.orange)
                Text("Photos")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Similar Photos", systemImage: "square.stack.3d.up")
        } description: {
            Text("Run a scan to find similar photos")
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

            Text("Choose a similar photos group from the sidebar")
                .foregroundStyle(.secondary)
        }
    }

    private var totalPhotos: Int {
        similarGroups.reduce(0) { $0 + $1.photos.count }
    }

    private func autoSelectBest() {
        let selector = BestPhotoSelector()
        for group in similarGroups {
            let photos = group.photos.map { PhotoAsset(from: $0) }
            if let bestId = selector.selectBestId(from: photos) {
                group.selectedPhotoId = bestId
            }
        }
    }
}

// MARK: - Group Row

struct SimilarGroupRowVision: View {
    let group: PhotoGroupEntity

    var body: some View {
        HStack(spacing: 16) {
            // Circular photo stack
            HStack(spacing: -12) {
                ForEach(Array(group.photos.prefix(4).enumerated()), id: \.offset) { index, photo in
                    AsyncThumbnailImageVision(
                        assetId: photo.localIdentifier,
                        size: CGSize(width: 80, height: 80)
                    )
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                    .zIndex(Double(4 - index))
                }

                if group.photos.count > 4 {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text("+\(group.photos.count - 4)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        )
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(group.photos.count) similar")
                    .font(.headline)

                if let date = group.photos.first?.creationDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if group.selectedPhotoId != nil {
                    Label("Best selected", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .hoverEffect(.highlight)
    }
}

// MARK: - Detail View

struct SimilarDetailViewVision: View {
    @Bindable var group: PhotoGroupEntity
    @State private var viewMode: ViewMode = .grid

    enum ViewMode {
        case grid
        case carousel
    }

    private let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // View Mode Picker
            Picker("View", selection: $viewMode) {
                Label("Grid", systemImage: "square.grid.3x3").tag(ViewMode.grid)
                Label("Carousel", systemImage: "rectangle.split.2x1").tag(ViewMode.carousel)
            }
            .pickerStyle(.segmented)
            .padding()

            if viewMode == .grid {
                gridView
            } else {
                carouselView
            }
        }
        .navigationTitle("Similar Photos")
    }

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(group.photos, id: \.localIdentifier) { entity in
                    AsyncThumbnailImageVision(
                        assetId: entity.localIdentifier,
                        size: CGSize(width: 300, height: 300)
                    )
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(group.selectedPhotoId == entity.localIdentifier ? Color.green : Color.clear, lineWidth: 3)
                    )
                    .overlay(alignment: .topTrailing) {
                        if group.selectedPhotoId == entity.localIdentifier {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .background(Circle().fill(.white))
                                .padding(8)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            group.selectedPhotoId = entity.localIdentifier
                        }
                    }
                    .hoverEffect(.lift)
                }
            }
            .padding()
        }
    }

    private var carouselView: some View {
        TabView {
            ForEach(group.photos, id: \.localIdentifier) { entity in
                VStack(spacing: 24) {
                    AsyncThumbnailImageVision(
                        assetId: entity.localIdentifier,
                        size: CGSize(width: 800, height: 800)
                    )
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)

                    // Photo info
                    HStack(spacing: 32) {
                        if let date = entity.creationDate {
                            Label(date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        }

                        if entity.pixelWidth > 0 {
                            Label("\(entity.pixelWidth)×\(entity.pixelHeight)", systemImage: "aspectratio")
                        }

                        if entity.fileSize > 0 {
                            Label(ByteCountFormatter.string(fromByteCount: entity.fileSize, countStyle: .file), systemImage: "doc")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Button {
                        withAnimation {
                            group.selectedPhotoId = entity.localIdentifier
                        }
                    } label: {
                        Label(
                            group.selectedPhotoId == entity.localIdentifier ? "Selected as Best" : "Select as Best",
                            systemImage: group.selectedPhotoId == entity.localIdentifier ? "checkmark.circle.fill" : "circle"
                        )
                        .frame(minWidth: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(group.selectedPhotoId == entity.localIdentifier ? .green : .blue)
                }
                .padding()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

#Preview(windowStyle: .automatic) {
    SimilarViewVision()
        .environmentObject(AppStateVision())
}
