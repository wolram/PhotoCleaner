import Foundation

struct ScanSession: Identifiable {
    let id: UUID
    let startedAt: Date
    var completedAt: Date?
    var photosScanned: Int
    var duplicatesFound: Int
    var similarGroupsFound: Int
    var lowQualityFound: Int
    var spaceRecoverable: Int64
    var status: Status
    var errorMessage: String?

    enum Status: String, Codable {
        case inProgress
        case completed
        case cancelled
        case failed

        var displayName: String {
            switch self {
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            case .failed: return "Failed"
            }
        }

        var icon: String {
            switch self {
            case .inProgress: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            case .cancelled: return "xmark.circle"
            case .failed: return "exclamationmark.triangle.fill"
            }
        }

        var isTerminal: Bool {
            self != .inProgress
        }
    }

    init(
        id: UUID = UUID(),
        startedAt: Date = Date()
    ) {
        self.id = id
        self.startedAt = startedAt
        self.photosScanned = 0
        self.duplicatesFound = 0
        self.similarGroupsFound = 0
        self.lowQualityFound = 0
        self.spaceRecoverable = 0
        self.status = .inProgress
    }

    var duration: TimeInterval? {
        guard let completed = completedAt else {
            return Date().timeIntervalSince(startedAt)
        }
        return completed.timeIntervalSince(startedAt)
    }

    var formattedDuration: String {
        guard let duration = duration else { return "Unknown" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return formatter.string(from: duration) ?? "\(Int(duration))s"
    }

    var formattedSpaceRecoverable: String {
        ByteCountFormatter.string(fromByteCount: spaceRecoverable, countStyle: .file)
    }

    var summary: String {
        var parts: [String] = []
        parts.append("\(photosScanned) photos scanned")
        if duplicatesFound > 0 {
            parts.append("\(duplicatesFound) duplicate groups")
        }
        if similarGroupsFound > 0 {
            parts.append("\(similarGroupsFound) similar groups")
        }
        if lowQualityFound > 0 {
            parts.append("\(lowQualityFound) low quality")
        }
        if spaceRecoverable > 0 {
            parts.append("\(formattedSpaceRecoverable) recoverable")
        }
        return parts.joined(separator: " • ")
    }

    mutating func complete() {
        completedAt = Date()
        status = .completed
    }

    mutating func cancel() {
        completedAt = Date()
        status = .cancelled
    }

    mutating func fail(with error: String) {
        completedAt = Date()
        status = .failed
        errorMessage = error
    }
}

extension ScanSession {
    init(from entity: ScanSessionEntity) {
        self.id = entity.id
        self.startedAt = entity.startedAt
        self.completedAt = entity.completedAt
        self.photosScanned = entity.photosScanned
        self.duplicatesFound = entity.duplicatesFound
        self.similarGroupsFound = entity.similarGroupsFound
        self.lowQualityFound = entity.lowQualityFound
        self.spaceRecoverable = entity.spaceRecoverable
        // Convert entity enum to model enum via rawValue
        self.status = Status(rawValue: entity.scanStatus.rawValue) ?? .inProgress
        self.errorMessage = entity.errorMessage
    }
}
