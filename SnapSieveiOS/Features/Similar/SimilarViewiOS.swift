import SwiftUI
import SwiftData

struct SimilarViewiOS: View {
    @EnvironmentObject private var appState: AppStateiOS
    @Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "similar" })
    private var similarGroups: [PhotoGroupEntity]

    @State private var selectedGroup: PhotoGroupEntity?

    var body: some View {
        NavigationStack {
            Group {
                if similarGroups.isEmpty {
                    emptyView
                } else {
                    groupListView
                }
            }
            .navigationTitle("Similar Photos")
            .toolbar {
                if !similarGroups.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                autoSelectBest()
                            } label: {
                                Label("Auto-Select Best", systemImage: "wand.and.stars")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }

    private var groupListView: some View {
        List {
            Section {
                summaryCard
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section("Similar Groups (\(similarGroups.count))") {
                ForEach(similarGroups, id: \.id) { group in
                    NavigationLink {
                        SimilarDetailViewiOS(group: group)
                    } label: {
                        SimilarGroupRowiOS(group: group)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var summaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(similarGroups.count)")
                    .font(.system(size: 36, weight: .bold))
                Text("Similar Groups")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(totalPhotos)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.orange)
                Text("Total Photos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
            Label("No Similar Photos", systemImage: "square.stack.3d.up")
        } description: {
            Text("Run a scan to find groups of similar photos.")
        } actions: {
            Button("Start Scan") {
                appState.selectedTab = .scan
            }
            .buttonStyle(.borderedProminent)
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

struct SimilarGroupRowiOS: View {
    let group: PhotoGroupEntity

    var body: some View {
        HStack(spacing: 12) {
            // Horizontal photo strip
            HStack(spacing: -8) {
                ForEach(Array(group.photos.prefix(4).enumerated()), id: \.offset) { index, photo in
                    AsyncThumbnailImageiOS(
                        assetId: photo.localIdentifier,
                        size: CGSize(width: 80, height: 80)
                    )
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                    .zIndex(Double(4 - index))
                }

                if group.photos.count > 4 {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("+\(group.photos.count - 4)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        )
                        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(group.photos.count) similar photos")
                    .fontWeight(.medium)

                if let date = group.photos.first?.creationDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

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

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail View

struct SimilarDetailViewiOS: View {
    @Bindable var group: PhotoGroupEntity
    @State private var viewMode: ViewMode = .grid
    @State private var currentIndex = 0

    enum ViewMode {
        case grid
        case compare
    }

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // View Mode Picker
            Picker("View Mode", selection: $viewMode) {
                Image(systemName: "square.grid.3x3").tag(ViewMode.grid)
                Image(systemName: "rectangle.split.2x1").tag(ViewMode.compare)
            }
            .pickerStyle(.segmented)
            .padding()

            if viewMode == .grid {
                gridView
            } else {
                compareView
            }
        }
        .navigationTitle("Similar Photos")
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
    }

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(group.photos, id: \.localIdentifier) { entity in
                    AsyncThumbnailImageiOS(
                        assetId: entity.localIdentifier,
                        size: CGSize(width: 200, height: 200)
                    )
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(group.selectedPhotoId == entity.localIdentifier ? Color.green : Color.clear, lineWidth: 3)
                    )
                    .overlay(alignment: .topTrailing) {
                        if group.selectedPhotoId == entity.localIdentifier {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .background(Circle().fill(.white))
                                .padding(4)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            group.selectedPhotoId = entity.localIdentifier
                        }
                    }
                }
            }
        }
    }

    private var compareView: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(group.photos.enumerated()), id: \.offset) { index, entity in
                VStack {
                    AsyncThumbnailImageiOS(
                        assetId: entity.localIdentifier,
                        size: CGSize(width: 600, height: 600)
                    )
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()

                    // Photo info
                    VStack(spacing: 8) {
                        if let date = entity.creationDate {
                            Label(date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        }

                        if entity.pixelWidth > 0 && entity.pixelHeight > 0 {
                            Label("\(entity.pixelWidth) x \(entity.pixelHeight)", systemImage: "aspectratio")
                        }

                        Button {
                            withAnimation {
                                group.selectedPhotoId = entity.localIdentifier
                            }
                        } label: {
                            HStack {
                                Image(systemName: group.selectedPhotoId == entity.localIdentifier ? "checkmark.circle.fill" : "circle")
                                Text(group.selectedPhotoId == entity.localIdentifier ? "Selected as Best" : "Select as Best")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(group.selectedPhotoId == entity.localIdentifier ? .green : .blue)
                        .padding(.horizontal)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

#Preview {
    SimilarViewiOS()
        .environmentObject(AppStateiOS())
}
