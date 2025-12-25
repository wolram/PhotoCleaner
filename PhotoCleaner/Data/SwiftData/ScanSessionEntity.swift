import SwiftData
import Foundation

@Model
final class ScanSessionEntity {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var completedAt: Date?
    var photosScanned: Int
    var duplicatesFound: Int
    var similarGroupsFound: Int
    var lowQualityFound: Int
    var spaceRecoverable: Int64
    var status: String // "inProgress", "completed", "cancelled", "failed"
    var errorMessage: String?

    init() {
        self.id = UUID()
        self.startedAt = Date()
        self.photosScanned = 0
        self.duplicatesFound = 0
        self.similarGroupsFound = 0
        self.lowQualityFound = 0
        self.spaceRecoverable = 0
        self.status = ScanStatus.inProgress.rawValue
    }

    enum ScanStatus: String, Codable {
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
            case .completed: return "checkmark.circle"
            case .cancelled: return "xmark.circle"
            case .failed: return "exclamationmark.triangle"
            }
        }
    }

    var scanStatus: ScanStatus {
        get { ScanStatus(rawValue: status) ?? .inProgress }
        set { status = newValue.rawValue }
    }

    var duration: TimeInterval? {
        guard let completed = completedAt else { return nil }
        return completed.timeIntervalSince(startedAt)
    }

    var formattedDuration: String {
        guard let duration = duration else { return "In progress..." }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "\(Int(duration))s"
    }

    func complete() {
        completedAt = Date()
        scanStatus = .completed
    }

    func cancel() {
        completedAt = Date()
        scanStatus = .cancelled
    }

    func fail(with error: String) {
        completedAt = Date()
        scanStatus = .failed
        errorMessage = error
    }
}
