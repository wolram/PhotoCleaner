import SwiftUI
import SwiftData

@MainActor
final class DuplicatesViewModel: ObservableObject {
    @Published var groups: [PhotoGroup] = []
    @Published var selectedGroupId: UUID?
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
                predicate: #Predicate { $0.groupType == "duplicate" },
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
    }

    // MARK: - Auto-Select Best

    func autoSelectBestForAll() {
        let selector = BestPhotoSelector()

        for i in groups.indices {
            if let bestId = selector.selectBestId(from: groups[i].photos) {
                groups[i].bestPhotoId = bestId
                updateEntitySelection(groupId: groups[i].id, photoId: bestId)
            }
        }
    }

    func autoSelectBest(for groupId: UUID) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }

        let selector = BestPhotoSelector()
        if let bestId = selector.selectBestId(from: groups[index].photos) {
            groups[index].bestPhotoId = bestId
            updateEntitySelection(groupId: groupId, photoId: bestId)
        }
    }

    private func updateEntitySelection(groupId: UUID, photoId: String) {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<PhotoGroupEntity>(
            predicate: #Predicate { $0.id == groupId }
        )

        if let entity = try? context.fetch(descriptor).first {
            entity.selectedPhotoId = photoId
            try? context.save()
        }
    }

    // MARK: - Selection Management

    func selectPhoto(_ photoId: String, in groupId: UUID) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        groups[index].bestPhotoId = photoId
        updateEntitySelection(groupId: groupId, photoId: photoId)
    }

    // MARK: - Deletion

    func getPhotosToDelete(for groupId: UUID) -> [String] {
        guard let group = groups.first(where: { $0.id == groupId }) else { return [] }
        return group.photosToDelete.map { $0.id }
    }

    func getAllPhotosToDelete() -> [String] {
        groups.flatMap { $0.photosToDelete.map { $0.id } }
    }

    func deleteNonSelected(in groupId: UUID) async throws {
        let toDelete = getPhotosToDelete(for: groupId)
        try await PhotoLibraryService.shared.deleteAssets(identifiers: toDelete)

        // Remove from local state
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].photos.removeAll { toDelete.contains($0.id) }

            // If only one photo left, remove the group
            if groups[index].photos.count <= 1 {
                removeGroup(at: index)
            }
        }
    }

    func deleteAllNonSelected() async throws {
        let toDelete = getAllPhotosToDelete()
        try await PhotoLibraryService.shared.deleteAssets(identifiers: toDelete)

        // Reload groups
        await loadGroups()
    }

    private func removeGroup(at index: Int) {
        guard let context = modelContext else { return }

        let groupId = groups[index].id
        let descriptor = FetchDescriptor<PhotoGroupEntity>(
            predicate: #Predicate { $0.id == groupId }
        )

        if let entity = try? context.fetch(descriptor).first {
            context.delete(entity)
            try? context.save()
        }

        groups.remove(at: index)
    }

    // MARK: - Statistics

    var totalGroups: Int {
        groups.count
    }

    var totalDuplicates: Int {
        groups.reduce(0) { $0 + $1.count - 1 }
    }

    var totalSpaceRecoverable: Int64 {
        groups.reduce(0) { $0 + $1.spaceRecoverable }
    }

    var formattedSpaceRecoverable: String {
        ByteCountFormatter.string(fromByteCount: totalSpaceRecoverable, countStyle: .file)
    }

    var groupsWithSelection: Int {
        groups.filter { $0.bestPhotoId != nil }.count
    }

    var selectionProgress: Double {
        guard totalGroups > 0 else { return 0 }
        return Double(groupsWithSelection) / Double(totalGroups)
    }
}
