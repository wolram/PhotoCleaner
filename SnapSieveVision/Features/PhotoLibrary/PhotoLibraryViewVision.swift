import SwiftUI
import Photos

struct PhotoLibraryViewVision: View {
    @EnvironmentObject private var appState: AppStateVision
    @StateObject private var viewModel = PhotoLibraryViewModelVision()

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if !appState.hasPhotoLibraryAccess {
                    permissionView
                } else if viewModel.isLoading && viewModel.photos.isEmpty {
                    loadingView
                } else if viewModel.photos.isEmpty {
                    emptyView
                } else {
                    photoGridView
                }
            }
            .navigationTitle("Photo Library")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Picker("Sort", selection: $viewModel.sortOrder) {
                        Label("Newest", systemImage: "arrow.down").tag(PhotoLibraryViewModelVision.SortOrder.newest)
                        Label("Oldest", systemImage: "arrow.up").tag(PhotoLibraryViewModelVision.SortOrder.oldest)
                    }
                    .pickerStyle(.menu)

                    Button {
                        Task { await viewModel.loadPhotos() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            .task {
                if appState.hasPhotoLibraryAccess {
                    await viewModel.loadPhotos()
                }
            }
        }
    }

    private var photoGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.photos, id: \.localIdentifier) { asset in
                    NavigationLink {
                        PhotoDetailViewVision(asset: asset)
                    } label: {
                        AsyncThumbnailImageVision(
                            assetId: asset.localIdentifier,
                            size: CGSize(width: 300, height: 300)
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .hoverEffect(.lift)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            if viewModel.hasMore {
                ProgressView()
                    .padding()
                    .onAppear {
                        Task { await viewModel.loadMore() }
                    }
            }
        }
    }

    private var permissionView: some View {
        ContentUnavailableView {
            Label("Photo Access Required", systemImage: "photo.on.rectangle.angled")
        } description: {
            Text("Snap Sieve needs access to your photo library to find duplicates and similar photos. All processing happens locally on your device.")
        } actions: {
            Button {
                Task {
                    appState.hasPhotoLibraryAccess = await PhotoLibraryServiceVision.shared.requestAuthorization()
                    if appState.hasPhotoLibraryAccess {
                        await viewModel.loadPhotos()
                    }
                }
            } label: {
                Label("Grant Access", systemImage: "lock.open")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading photos...")
                .foregroundStyle(.secondary)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Photos", systemImage: "photo.on.rectangle")
        } description: {
            Text("Your photo library is empty.")
        }
    }
}

// MARK: - ViewModel

@MainActor
final class PhotoLibraryViewModelVision: ObservableObject {
    @Published var photos: [PHAsset] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var sortOrder: SortOrder = .newest {
        didSet {
            Task { await loadPhotos() }
        }
    }

    private let pageSize = 100
    private var currentOffset = 0

    enum SortOrder {
        case newest, oldest
    }

    func loadPhotos() async {
        isLoading = true
        currentOffset = 0
        photos = []

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: sortOrder == .oldest)
        ]
        options.fetchLimit = pageSize

        let result = PHAsset.fetchAssets(with: .image, options: options)
        var loaded: [PHAsset] = []

        result.enumerateObjects { asset, _, _ in
            loaded.append(asset)
        }

        photos = loaded
        currentOffset = loaded.count
        hasMore = loaded.count == pageSize
        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoading else { return }
        isLoading = true

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: sortOrder == .oldest)
        ]
        options.fetchLimit = currentOffset + pageSize

        let result = PHAsset.fetchAssets(with: .image, options: options)
        var newPhotos: [PHAsset] = []

        let start = currentOffset
        let end = min(currentOffset + pageSize, result.count)

        for i in start..<end {
            newPhotos.append(result.object(at: i))
        }

        photos.append(contentsOf: newPhotos)
        currentOffset = end
        hasMore = newPhotos.count == pageSize
        isLoading = false
    }
}

// MARK: - Photo Detail View

struct PhotoDetailViewVision: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(asset.creationDate?.formatted(date: .abbreviated, time: .shortened) ?? "Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        // Share action
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        Task {
                            try? await PhotoLibraryServiceVision.shared.deleteAssets(identifiers: [asset.localIdentifier])
                            dismiss()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            image = await PhotoLibraryServiceVision.shared.loadFullImage(for: asset)
        }
    }
}

#Preview(windowStyle: .automatic) {
    PhotoLibraryViewVision()
        .environmentObject(AppStateVision())
}
