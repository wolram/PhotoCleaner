import SwiftData
import Foundation

@MainActor
final class GroupRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    func create(type: PhotoGroupEntity.GroupType) -> PhotoGroupEntity {
        let group = PhotoGroupEntity(groupType: type)
        modelContext.insert(group)
        return group
    }

    func fetch(id: UUID) -> PhotoGroupEntity? {
        let descriptor = FetchDescriptor<PhotoGroupEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func fetchAll(type: PhotoGroupEntity.GroupType? = nil) -> [PhotoGroupEntity] {
        let descriptor: FetchDescriptor<PhotoGroupEntity>

        if let type = type {
            let typeRaw = type.rawValue
            descriptor = FetchDescriptor<PhotoGroupEntity>(
                predicate: #Predicate { $0.groupType == typeRaw },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<PhotoGroupEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
        }

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func delete(_ group: PhotoGroupEntity) {
        modelContext.delete(group)
    }

    func deleteAll(type: PhotoGroupEntity.GroupType? = nil) {
        let groups = fetchAll(type: type)
        for group in groups {
            modelContext.delete(group)
        }
    }

    func save() throws {
        try modelContext.save()
    }

    // MARK: - Group Management

    func createDuplicateGroup(photoIds: [String]) -> PhotoGroupEntity {
        let group = create(type: .duplicate)

        let photoRepo = PhotoRepository(modelContext: modelContext)
        for id in photoIds {
            if let photo = photoRepo.fetch(localIdentifier: id) {
                group.photos.append(photo)
            }
        }

        group.updateAverageQuality()
        return group
    }

    func createSimilarGroup(photoIds: [String]) -> PhotoGroupEntity {
        let group = create(type: .similar)

        let photoRepo = PhotoRepository(modelContext: modelContext)
        for id in photoIds {
            if let photo = photoRepo.fetch(localIdentifier: id) {
                group.photos.append(photo)
            }
        }

        group.updateAverageQuality()
        return group
    }

    func addPhotoToGroup(_ group: PhotoGroupEntity, photoId: String) {
        let photoRepo = PhotoRepository(modelContext: modelContext)
        if let photo = photoRepo.fetch(localIdentifier: photoId) {
            group.photos.append(photo)
            group.updateAverageQuality()
        }
    }

    func removePhotoFromGroup(_ group: PhotoGroupEntity, photoId: String) {
        group.photos.removeAll { $0.localIdentifier == photoId }

        // Delete group if less than 2 photos remain
        if group.photos.count < 2 {
            modelContext.delete(group)
        } else {
            group.updateAverageQuality()
        }
    }

    func selectBestPhoto(_ group: PhotoGroupEntity, photoId: String) {
        group.selectedPhotoId = photoId
    }

    // MARK: - Batch Operations

    func createDuplicateGroups(from groupings: [[String]]) {
        for photoIds in groupings where photoIds.count > 1 {
            _ = createDuplicateGroup(photoIds: photoIds)
        }
    }

    func createSimilarGroups(from groupings: [[String]]) {
        for photoIds in groupings where photoIds.count > 1 {
            _ = createSimilarGroup(photoIds: photoIds)
        }
    }

    // MARK: - Queries

    func fetchDuplicateGroups() -> [PhotoGroupEntity] {
        fetchAll(type: .duplicate)
    }

    func fetchSimilarGroups() -> [PhotoGroupEntity] {
        fetchAll(type: .similar)
    }

    func fetchGroupsContaining(photoId: String) -> [PhotoGroupEntity] {
        let allGroups = fetchAll()
        return allGroups.filter { group in
            group.photos.contains { $0.localIdentifier == photoId }
        }
    }

    func fetchGroupsWithoutSelection() -> [PhotoGroupEntity] {
        let allGroups = fetchAll()
        return allGroups.filter { $0.selectedPhotoId == nil }
    }

    // MARK: - Statistics

    func duplicateGroupCount() -> Int {
        fetchDuplicateGroups().count
    }

    func similarGroupCount() -> Int {
        fetchSimilarGroups().count
    }

    func totalDuplicatePhotos() -> Int {
        fetchDuplicateGroups().reduce(0) { $0 + $1.photos.count }
    }

    func totalSpaceRecoverable() -> Int64 {
        fetchAll().reduce(0) { $0 + $1.spaceRecoverable }
    }

    func formattedSpaceRecoverable() -> String {
        ByteCountFormatter.string(fromByteCount: totalSpaceRecoverable(), countStyle: .file)
    }

    func groupsWithSelection() -> Int {
        fetchAll().filter { $0.selectedPhotoId != nil }.count
    }

    func selectionProgress() -> Double {
        let total = fetchAll().count
        guard total > 0 else { return 0 }
        return Double(groupsWithSelection()) / Double(total)
    }
}
