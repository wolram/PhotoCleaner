import SwiftUI
import Photos

struct PhotoLibraryViewiOS: View {
    @EnvironmentObject private var appState: AppStateiOS
    @StateObject private var viewModel = PhotoLibraryViewModeliOS()

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if !appState.hasPhotoLibraryAccess {
                    permissionView
                } else if viewModel.isLoading {
                    loadingView
                } else if viewModel.photos.isEmpty {
                    emptyView
                } else {
                    photoGridView
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $viewModel.sortOrder) {
                            Label("Newest First", systemImage: "arrow.down").tag(PhotoLibraryViewModeliOS.SortOrder.newest)
                            Label("Oldest First", systemImage: "arrow.up").tag(PhotoLibraryViewModeliOS.SortOrder.oldest)
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .task {
                if appState.hasPhotoLibraryAccess {
                    await viewModel.loadPhotos()
                }
            }
            .refreshable {
                await viewModel.loadPhotos()
            }
        }
    }

    private var photoGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.photos, id: \.localIdentifier) { asset in
                    NavigationLink {
                        PhotoDetailViewiOS(asset: asset)
                    } label: {
                        AsyncThumbnailImageiOS(
                            assetId: asset.localIdentifier,
                            size: CGSize(width: 200, height: 200)
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                    }
                }
            }

            if viewModel.hasMore {
                ProgressView()
                    .padding()
                    .onAppear {
                        Task {
                            await viewModel.loadMore()
                        }
                    }
            }
        }
    }

    private var permissionView: some View {
        ContentUnavailableView {
            Label("Photo Access Required", systemImage: "photo.on.rectangle.angled")
        } description: {
            Text("Snap Sieve needs access to your photo library to find duplicates and similar photos.")
        } actions: {
            Button("Grant Access") {
                Task {
                    appState.hasPhotoLibraryAccess = await PhotoLibraryServiceiOS.shared.requestAuthorization()
                    if appState.hasPhotoLibraryAccess {
                        await viewModel.loadPhotos()
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
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
final class PhotoLibraryViewModeliOS: ObservableObject {
    @Published var photos: [PHAsset] = []
    @Published var isLoading = false
    @Published var hasMore = true
    @Published var sortOrder: SortOrder = .newest {
        didSet {
            Task {
                await loadPhotos()
            }
        }
    }

    private let pageSize = 100
    private var currentOffset = 0

    enum SortOrder {
        case newest
        case oldest
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
        var loadedPhotos: [PHAsset] = []

        result.enumerateObjects { asset, _, _ in
            loadedPhotos.append(asset)
        }

        photos = loadedPhotos
        currentOffset = loadedPhotos.count
        hasMore = loadedPhotos.count == pageSize
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

        let startIndex = currentOffset
        let endIndex = min(currentOffset + pageSize, result.count)

        for i in startIndex..<endIndex {
            newPhotos.append(result.object(at: i))
        }

        photos.append(contentsOf: newPhotos)
        currentOffset = endIndex
        hasMore = newPhotos.count == pageSize
        isLoading = false
    }
}

// MARK: - Photo Detail View

struct PhotoDetailViewiOS: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: asset.localIdentifier) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.white)
                }
            }
        }
        .task {
            image = await PhotoLibraryServiceiOS.shared.loadFullImage(for: asset)
        }
    }
}

#Preview {
    PhotoLibraryViewiOS()
        .environmentObject(AppStateiOS())
}
