import SwiftData
import Foundation

@Model
final class PhotoGroupEntity {
    @Attribute(.unique) var id: UUID
    var groupType: String // "duplicate", "similar", "burst"
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var photos: [PhotoAssetEntity]

    var selectedPhotoId: String?
    var averageQualityScore: Float?

    init(groupType: GroupType = .duplicate) {
        self.id = UUID()
        self.groupType = groupType.rawValue
        self.createdAt = Date()
        self.photos = []
    }

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

        var icon: String {
            switch self {
            case .duplicate: return "doc.on.doc"
            case .similar: return "square.stack.3d.up"
            case .burst: return "square.stack"
            }
        }
    }

    var type: GroupType {
        GroupType(rawValue: groupType) ?? .duplicate
    }

    var spaceRecoverable: Int64 {
        guard photos.count > 1 else { return 0 }
        let sortedBySize = photos.sorted { $0.fileSize > $1.fileSize }
        return sortedBySize.dropFirst().reduce(0) { $0 + $1.fileSize }
    }

    var bestPhoto: PhotoAssetEntity? {
        if let selectedId = selectedPhotoId {
            return photos.first { $0.localIdentifier == selectedId }
        }
        return photos.max { $0.compositeQualityScore < $1.compositeQualityScore }
    }

    var photosToDelete: [PhotoAssetEntity] {
        guard let best = bestPhoto else { return [] }
        return photos.filter { $0.localIdentifier != best.localIdentifier }
    }

    func updateAverageQuality() {
        let scores = photos.compactMap { $0.aestheticScore }
        guard !scores.isEmpty else {
            averageQualityScore = nil
            return
        }
        averageQualityScore = scores.reduce(0, +) / Float(scores.count)
    }
}
