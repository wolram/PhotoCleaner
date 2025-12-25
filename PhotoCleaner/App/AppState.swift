import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isScanning = false
    @Published var scanProgress: Double = 0
    @Published var scanPhase: ScanPhase = .idle
    @Published var statusMessage: String = ""

    @Published var photosScanned: Int = 0
    @Published var duplicatesFound: Int = 0
    @Published var similarGroupsFound: Int = 0
    @Published var lowQualityFound: Int = 0
    @Published var spaceRecoverable: Int64 = 0

    @Published var hasPhotoLibraryAccess = false
    @Published var selectedDestination: NavigationDestination = .library

    @AppStorage("duplicateThreshold") var duplicateThreshold: Double = 0.5
    @AppStorage("similarityThreshold") var similarityThreshold: Int = 8
    @AppStorage("qualityThreshold") var qualityThreshold: Double = 0.3
    @AppStorage("maxConcurrentTasks") var maxConcurrentTasks: Int = 8

    private var scanTask: Task<Void, Never>?

    enum ScanPhase: Int, Comparable {
        case idle = 0
        case loading = 1
        case analyzing = 2
        case grouping = 3
        case complete = 4

        static func < (lhs: ScanPhase, rhs: ScanPhase) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        var description: String {
            switch self {
            case .idle: return "Ready"
            case .loading: return "Loading photos..."
            case .analyzing: return "Analyzing images..."
            case .grouping: return "Grouping similar photos..."
            case .complete: return "Scan complete"
            }
        }
    }

    func resetScanStats() {
        photosScanned = 0
        duplicatesFound = 0
        similarGroupsFound = 0
        lowQualityFound = 0
        spaceRecoverable = 0
        scanProgress = 0
        scanPhase = .idle
        statusMessage = ""
    }

    func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        isScanning = false
        scanPhase = .idle
        statusMessage = "Scan cancelled"
    }

    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
