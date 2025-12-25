import SwiftUI
import SwiftData

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var categories: [CategoryInfo] = []
    @Published var selectedCategory: String?
    @Published var photosInSelectedCategory: [PhotoAsset] = []
    @Published var isLoading = false
    @Published var error: Error?

    private var modelContext: ModelContext?

    struct CategoryInfo: Identifiable {
        let id: String
        let name: String
        let count: Int
        let icon: String
        let color: String

        init(name: String, count: Int) {
            self.id = name
            self.name = name
            self.count = count
            self.icon = Self.iconFor(name)
            self.color = Self.colorFor(name)
        }

        static func iconFor(_ category: String) -> String {
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

        static func colorFor(_ category: String) -> String {
            switch category {
            case "Nature & Landscapes": return "green"
            case "Portraits & People": return "blue"
            case "Food & Drinks": return "orange"
            case "Architecture & Buildings": return "purple"
            case "Animals & Pets": return "brown"
            case "Travel & Vacation": return "cyan"
            case "Events & Celebrations": return "pink"
            case "Art & Design": return "indigo"
            case "Sports & Action": return "red"
            case "Documents & Screenshots": return "gray"
            default: return "secondary"
            }
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Loading

    func loadCategories() async {
        guard let context = modelContext else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let descriptor = FetchDescriptor<PhotoAssetEntity>(
                predicate: #Predicate { $0.primaryCategory != nil }
            )

            let entities = try context.fetch(descriptor)

            // Count photos per category
            var counts: [String: Int] = [:]
            for entity in entities {
                if let category = entity.primaryCategory {
                    counts[category, default: 0] += 1
                }
            }

            // Create category infos
            categories = counts.map { CategoryInfo(name: $0.key, count: $0.value) }
                .sorted { $0.count > $1.count }

        } catch {
            self.error = error
        }
    }

    func loadPhotosForCategory(_ category: String) async {
        guard let context = modelContext else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let descriptor = FetchDescriptor<PhotoAssetEntity>(
                predicate: #Predicate { $0.primaryCategory == category },
                sortBy: [SortDescriptor(\.primaryCategoryScore, order: .reverse)]
            )

            let entities = try context.fetch(descriptor)
            photosInSelectedCategory = entities.map { PhotoAsset(from: $0) }

        } catch {
            self.error = error
        }
    }

    func selectCategory(_ category: String) {
        selectedCategory = category
        Task {
            await loadPhotosForCategory(category)
        }
    }

    // MARK: - Statistics

    var totalCategorized: Int {
        categories.reduce(0) { $0 + $1.count }
    }

    var categoryCount: Int {
        categories.count
    }

    var topCategories: [CategoryInfo] {
        Array(categories.prefix(5))
    }
}
