import SwiftUI
import SwiftData

struct CategoriesView: View {
    @EnvironmentObject private var appState: AppState
    @Query private var photos: [PhotoAssetEntity]

    @State private var selectedCategory: String?
    @State private var searchText = ""

    private let categories = AppConfig.Categories.predefined

    var body: some View {
        Group {
            if categorizedPhotos.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .searchable(text: $searchText, prompt: "Search categories")
    }

    // MARK: - Views

    private var contentView: some View {
        HSplitView {
            // Category list
            List(filteredCategories, id: \.self, selection: $selectedCategory) { category in
                categoryRow(category)
            }
            .listStyle(.sidebar)
            .frame(minWidth: 220, maxWidth: 280)

            // Photos in category
            if let category = selectedCategory {
                categoryDetailView(category)
            } else {
                selectPrompt
            }
        }
    }

    private func categoryRow(_ category: String) -> some View {
        let count = photosInCategory(category).count

        return HStack {
            Image(systemName: iconFor(category))
                .foregroundStyle(colorFor(category))
                .frame(width: 24)

            Text(category)

            Spacer()

            Text("\(count)")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }

    private func categoryDetailView(_ category: String) -> some View {
        let categoryPhotos = photosInCategory(category)

        return VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: iconFor(category))
                    .font(.title2)
                    .foregroundStyle(colorFor(category))

                Text(category)
                    .font(.headline)

                Spacer()

                Text("\(categoryPhotos.count) photos")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)

            Divider()

            // Grid
            if categoryPhotos.isEmpty {
                VStack {
                    Text("No photos in this category")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 150, maximum: 200))],
                        spacing: 8
                    ) {
                        ForEach(categoryPhotos, id: \.localIdentifier) { entity in
                            categoryPhotoItem(entity)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func categoryPhotoItem(_ entity: PhotoAssetEntity) -> some View {
        VStack(spacing: 4) {
            CachedThumbnailImage(
                assetId: entity.localIdentifier,
                size: CGSize(width: 300, height: 300)
            )
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if let score = entity.primaryCategoryScore {
                Text("\(Int(score * 100))% match")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var selectPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Select a Category")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a category to view its photos")
                .foregroundStyle(.secondary)
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "folder",
            title: "No Categories Yet",
            message: "Run a scan with AI categorization enabled to organize your photos automatically.",
            actionTitle: "Start Scan"
        ) {
            appState.selectedDestination = .scan
        }
    }

    // MARK: - Helpers

    private var categorizedPhotos: [PhotoAssetEntity] {
        photos.filter { $0.primaryCategory != nil }
    }

    private var filteredCategories: [String] {
        if searchText.isEmpty {
            return categories.filter { !photosInCategory($0).isEmpty }
        }
        return categories.filter {
            $0.localizedCaseInsensitiveContains(searchText) &&
            !photosInCategory($0).isEmpty
        }
    }

    private func photosInCategory(_ category: String) -> [PhotoAssetEntity] {
        photos.filter { $0.primaryCategory == category }
    }

    private func iconFor(_ category: String) -> String {
        switch category {
        case "Nature & Landscapes": return "leaf"
        case "Portraits & People": return "person"
        case "Food & Drinks": return "fork.knife"
        case "Architecture & Buildings": return "building.2"
        case "Animals & Pets": return "pawprint"
        case "Travel & Vacation": return "airplane"
        case "Events & Celebrations": return "party.popper"
        case "Art & Design": return "paintpalette"
        case "Sports & Action": return "figure.run"
        case "Documents & Screenshots": return "doc.text"
        default: return "folder"
        }
    }

    private func colorFor(_ category: String) -> Color {
        switch category {
        case "Nature & Landscapes": return .green
        case "Portraits & People": return .blue
        case "Food & Drinks": return .orange
        case "Architecture & Buildings": return .purple
        case "Animals & Pets": return .brown
        case "Travel & Vacation": return .cyan
        case "Events & Celebrations": return .pink
        case "Art & Design": return .indigo
        case "Sports & Action": return .red
        case "Documents & Screenshots": return .gray
        default: return .secondary
        }
    }
}

#Preview {
    CategoriesView()
        .environmentObject(AppState())
}
