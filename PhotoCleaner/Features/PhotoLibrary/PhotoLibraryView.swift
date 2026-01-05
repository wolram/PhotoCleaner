import SwiftUI
import Photos

struct PhotoLibraryView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @State private var selection = Set<String>()
    @State private var searchText = ""

    var body: some View {
        Group {
            if !appState.hasPhotoLibraryAccess {
                noAccessView
            } else if viewModel.isLoading && viewModel.photos.isEmpty {
                loadingView
            } else if viewModel.photos.isEmpty {
                emptyView
            } else {
                photoGridView
            }
        }
        .navigationTitle("All Photos")
        .toolbar {
            ToolbarItemGroup {
                if !selection.isEmpty {
                    Text("\(selection.count) selected")
                        .foregroundStyle(.secondary)

                    Button {
                        selection.removeAll()
                    } label: {
                        Text("Deselect All")
                    }
                }

                Spacer()

                Button {
                    Task {
                        await viewModel.refresh()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
            }
        }
        .searchable(text: $searchText, prompt: "Search photos")
        .task {
            if viewModel.photos.isEmpty {
                await viewModel.loadPhotos()
            }
        }
    }

    // MARK: - Views

    private var photoGridView: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 2)],
                spacing: 2
            ) {
                ForEach(filteredPhotos) { photo in
                    PhotoGridItem(
                        photo: photo,
                        isSelected: selection.contains(photo.id)
                    )
                    .onTapGesture {
                        toggleSelection(photo.id)
                    }
                }
            }
            .padding(2)

            if viewModel.hasMore {
                Button("Load More") {
                    Task {
                        await viewModel.loadMore()
                    }
                }
                .padding()
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.regular)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Loading photos...")
                .foregroundStyle(.secondary)
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "photo.on.rectangle",
            title: "No Photos",
            message: "Your photo library appears to be empty."
        )
    }

    private var noAccessView: some View {
        EmptyStateView(
            icon: "lock.shield",
            title: "Photo Access Required",
            message: "PhotoCleaner needs access to your photo library to help you organize and clean up your photos.",
            actionTitle: "Open Settings"
        ) {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Photos") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    // MARK: - Helpers

    private var filteredPhotos: [PhotoAsset] {
        if searchText.isEmpty {
            return viewModel.photos
        }
        return viewModel.photos.filter { photo in
            photo.fileName?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    private func toggleSelection(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }
}

#Preview {
    PhotoLibraryView()
        .environmentObject(AppState())
}
