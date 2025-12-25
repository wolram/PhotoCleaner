import SwiftUI
import SwiftData

@MainActor
final class QualityReviewViewModel: ObservableObject {
    @Published var photos: [PhotoAsset] = []
    @Published var selectedGrade: QualityScore.Grade?
    @Published var selection = Set<String>()
    @Published var isLoading = false
    @Published var error: Error?

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Loading

    func loadPhotos() async {
        guard let context = modelContext else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let descriptor = FetchDescriptor<PhotoAssetEntity>(
                predicate: #Predicate { $0.aestheticScore != nil },
                sortBy: [SortDescriptor(\.aestheticScore, order: .forward)]
            )

            let entities = try context.fetch(descriptor)
            photos = entities.map { PhotoAsset(from: $0) }
        } catch {
            self.error = error
        }
    }

    // MARK: - Filtering

    var filteredPhotos: [PhotoAsset] {
        guard let grade = selectedGrade else { return photos }
        return photos.filter { $0.qualityScore?.grade == grade }
    }

    func filterByGrade(_ grade: QualityScore.Grade?) {
        selectedGrade = grade
    }

    // MARK: - Selection

    func toggleSelection(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }

    func selectAllFiltered() {
        selection = Set(filteredPhotos.map { $0.id })
    }

    func selectLowQuality(threshold: Float = 0.3) {
        selection = Set(
            photos.filter { ($0.qualityScore?.composite ?? 1) < threshold }
                .map { $0.id }
        )
    }

    func selectBlurry(threshold: Float = 0.4) {
        selection = Set(
            photos.filter { ($0.qualityScore?.blurScore ?? 1) < threshold }
                .map { $0.id }
        )
    }

    func selectUtility() {
        selection = Set(
            photos.filter { $0.qualityScore?.isUtility == true }
                .map { $0.id }
        )
    }

    func deselectAll() {
        selection.removeAll()
    }

    // MARK: - Actions

    func deleteSelected() async throws {
        let toDelete = Array(selection)
        try await PhotoLibraryService.shared.deleteAssets(identifiers: toDelete)

        photos.removeAll { toDelete.contains($0.id) }
        selection.removeAll()
    }

    // MARK: - Statistics

    var gradeDistribution: [QualityScore.Grade: Int] {
        var distribution: [QualityScore.Grade: Int] = [:]

        for grade in QualityScore.Grade.allCases {
            distribution[grade] = photos.filter { $0.qualityScore?.grade == grade }.count
        }

        return distribution
    }

    var lowQualityCount: Int {
        photos.filter { ($0.qualityScore?.composite ?? 1) < 0.3 }.count
    }

    var blurryCount: Int {
        photos.filter { ($0.qualityScore?.blurScore ?? 1) < 0.4 }.count
    }

    var utilityCount: Int {
        photos.filter { $0.qualityScore?.isUtility == true }.count
    }

    var averageQuality: Float {
        guard !photos.isEmpty else { return 0 }
        let total = photos.compactMap { $0.qualityScore?.composite }.reduce(0, +)
        return total / Float(photos.count)
    }

    // MARK: - Sorting

    enum SortOption: CaseIterable {
        case qualityAscending
        case qualityDescending
        case dateAscending
        case dateDescending
        case sizeAscending
        case sizeDescending

        var label: String {
            switch self {
            case .qualityAscending: return "Lowest Quality"
            case .qualityDescending: return "Highest Quality"
            case .dateAscending: return "Oldest First"
            case .dateDescending: return "Newest First"
            case .sizeAscending: return "Smallest First"
            case .sizeDescending: return "Largest First"
            }
        }
    }

    func sort(by option: SortOption) {
        switch option {
        case .qualityAscending:
            photos.sort { ($0.qualityScore?.composite ?? 0) < ($1.qualityScore?.composite ?? 0) }
        case .qualityDescending:
            photos.sort { ($0.qualityScore?.composite ?? 0) > ($1.qualityScore?.composite ?? 0) }
        case .dateAscending:
            photos.sort { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }
        case .dateDescending:
            photos.sort { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        case .sizeAscending:
            photos.sort { $0.fileSize < $1.fileSize }
        case .sizeDescending:
            photos.sort { $0.fileSize > $1.fileSize }
        }
    }
}
