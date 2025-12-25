import SwiftUI
import SwiftData

@MainActor
final class SimilarPhotosViewModel: ObservableObject {
    @Published var groups: [PhotoGroup] = []
    @Published var selectedGroupId: UUID?
    @Published var selection = Set<String>()
    @Published var isLoading = false
    @Published var error: Error?

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Loading

    func loadGroups() async {
        guard let context = modelContext else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let descriptor = FetchDescriptor<PhotoGroupEntity>(
                predicate: #Predicate { $0.groupType == "similar" },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )

            let entities = try context.fetch(descriptor)
            groups = entities.map { PhotoGroup(from: $0) }
        } catch {
            self.error = error
        }
    }

    // MARK: - Selection

    var selectedGroup: PhotoGroup? {
        groups.first { $0.id == selectedGroupId }
    }

    func selectGroup(_ id: UUID) {
        selectedGroupId = id
        selection.removeAll()
    }

    func togglePhotoSelection(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }

    func selectAllExceptFirst() {
        guard let group = selectedGroup else { return }
        selection = Set(group.photos.dropFirst().map { $0.id })
    }

    func deselectAll() {
        selection.removeAll()
    }

    // MARK: - Actions

    func keepSelectedDeleteRest() async throws {
        guard let group = selectedGroup else { return }

        let toDelete = group.photos
            .filter { !selection.contains($0.id) }
            .map { $0.id }

        try await PhotoLibraryService.shared.deleteAssets(identifiers: toDelete)

        // Update local state
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].photos.removeAll { toDelete.contains($0.id) }

            if groups[index].photos.count <= 1 {
                removeGroup(groups[index].id)
            }
        }

        selection.removeAll()
    }

    func deleteSelected() async throws {
        let toDelete = Array(selection)
        try await PhotoLibraryService.shared.deleteAssets(identifiers: toDelete)

        // Update local state
        if let groupId = selectedGroupId,
           let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].photos.removeAll { toDelete.contains($0.id) }

            if groups[index].photos.count <= 1 {
                removeGroup(groupId)
            }
        }

        selection.removeAll()
    }

    private func removeGroup(_ id: UUID) {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<PhotoGroupEntity>(
            predicate: #Predicate { $0.id == id }
        )

        if let entity = try? context.fetch(descriptor).first {
            context.delete(entity)
            try? context.save()
        }

        groups.removeAll { $0.id == id }
        if selectedGroupId == id {
            selectedGroupId = groups.first?.id
        }
    }

    // MARK: - Statistics

    var totalGroups: Int {
        groups.count
    }

    var totalPhotos: Int {
        groups.reduce(0) { $0 + $1.count }
    }

    var potentialDeletions: Int {
        groups.reduce(0) { $0 + max(0, $1.count - 1) }
    }
}
