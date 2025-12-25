import Foundation

struct PhotoGroup: Identifiable {
    let id: UUID
    let type: GroupType
    var photos: [PhotoAsset]
    var bestPhotoId: String?
    var createdAt: Date

    enum GroupType: String, Codable, CaseIterable {
        case duplicate
        case similar
        case burst

        var displayName: String {
            switch self {
            case .duplicate: return "Duplicate"
            case .similar: return "Similar"
            case .burst: return "Burst"
            }
        }

        var pluralName: String {
            switch self {
            case .duplicate: return "Duplicates"
            case .similar: return "Similar Photos"
            case .burst: return "Burst Photos"
            }
        }

        var icon: String {
            switch self {
            case .duplicate: return "doc.on.doc"
            case .similar: return "square.stack.3d.up"
            case .burst: return "square.stack"
            }
        }

        var description: String {
            switch self {
            case .duplicate: return "Exact or near-exact copies"
            case .similar: return "Visually similar photos"
            case .burst: return "Photos taken in quick succession"
            }
        }
    }

    init(
        id: UUID = UUID(),
        type: GroupType,
        photos: [PhotoAsset] = [],
        bestPhotoId: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.photos = photos
        self.bestPhotoId = bestPhotoId
        self.createdAt = createdAt
    }

    var count: Int {
        photos.count
    }

    var spaceRecoverable: Int64 {
        guard photos.count > 1 else { return 0 }
        let sortedBySize = photos.sorted { $0.fileSize > $1.fileSize }
        return sortedBySize.dropFirst().reduce(0) { $0 + $1.fileSize }
    }

    var formattedSpaceRecoverable: String {
        ByteCountFormatter.string(fromByteCount: spaceRecoverable, countStyle: .file)
    }

    var totalSize: Int64 {
        photos.reduce(0) { $0 + $1.fileSize }
    }

    var bestPhoto: PhotoAsset? {
        if let selectedId = bestPhotoId {
            return photos.first { $0.id == selectedId }
        }
        return photos.max {
            ($0.qualityScore?.composite ?? 0) < ($1.qualityScore?.composite ?? 0)
        }
    }

    var photosToDelete: [PhotoAsset] {
        guard let best = bestPhoto else { return [] }
        return photos.filter { $0.id != best.id }
    }

    var averageQuality: Float {
        let scores = photos.compactMap { $0.qualityScore?.composite }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / Float(scores.count)
    }

    var dateRange: (earliest: Date?, latest: Date?) {
        let dates = photos.compactMap { $0.creationDate }
        return (dates.min(), dates.max())
    }

    mutating func selectBest(_ photoId: String) {
        bestPhotoId = photoId
    }

    mutating func addPhoto(_ photo: PhotoAsset) {
        photos.append(photo)
    }

    mutating func removePhoto(id: String) {
        photos.removeAll { $0.id == id }
    }
}

extension PhotoGroup {
    init(from entity: PhotoGroupEntity) {
        self.id = entity.id
        // Convert entity enum to model enum via rawValue
        self.type = GroupType(rawValue: entity.type.rawValue) ?? .duplicate
        self.photos = entity.photos.map { PhotoAsset(from: $0) }
        self.bestPhotoId = entity.selectedPhotoId
        self.createdAt = entity.createdAt
    }
}
