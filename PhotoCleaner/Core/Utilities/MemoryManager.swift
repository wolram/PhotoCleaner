import Foundation
import os.log

final class MemoryManager {
    static let shared = MemoryManager()

    private let logger = Logger(subsystem: "com.photocleaner", category: "Memory")
    private let warningThreshold: UInt64 = 500_000_000  // 500 MB
    private let criticalThreshold: UInt64 = 200_000_000 // 200 MB

    private var memoryPressureSource: DispatchSourceMemoryPressure?
    private var onMemoryWarning: (() -> Void)?
    private var onCriticalMemory: (() -> Void)?

    private init() {
        setupMemoryPressureMonitoring()
    }

    deinit {
        memoryPressureSource?.cancel()
    }

    // MARK: - Memory Info

    var availableMemory: UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }

        // Get physical memory and subtract used
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let usedMemory = UInt64(info.resident_size)

        return totalMemory - usedMemory
    }

    var usedMemory: UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }
        return UInt64(info.resident_size)
    }

    var memoryUsagePercentage: Double {
        let total = ProcessInfo.processInfo.physicalMemory
        let used = usedMemory
        return Double(used) / Double(total) * 100
    }

    var isMemoryLow: Bool {
        availableMemory < warningThreshold
    }

    var isMemoryCritical: Bool {
        availableMemory < criticalThreshold
    }

    // MARK: - Memory Pressure Monitoring

    private func setupMemoryPressureMonitoring() {
        memoryPressureSource = DispatchSource.makeMemoryPressureSource(
            eventMask: [.warning, .critical],
            queue: .main
        )

        memoryPressureSource?.setEventHandler { [weak self] in
            guard let self = self else { return }

            let event = self.memoryPressureSource?.data ?? []

            if event.contains(.critical) {
                self.logger.warning("Critical memory pressure detected")
                self.onCriticalMemory?()
            } else if event.contains(.warning) {
                self.logger.info("Memory pressure warning")
                self.onMemoryWarning?()
            }
        }

        memoryPressureSource?.resume()
    }

    func onMemoryWarning(_ handler: @escaping () -> Void) {
        onMemoryWarning = handler
    }

    func onCriticalMemory(_ handler: @escaping () -> Void) {
        onCriticalMemory = handler
    }

    // MARK: - Memory Management

    func checkMemoryAndWait() async {
        while isMemoryCritical {
            logger.warning("Waiting for memory to be freed...")
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
    }

    func suggestBatchSize(for itemSize: Int, maxItems: Int) -> Int {
        let available = availableMemory
        let safeToUse = available / 2  // Use at most half of available memory

        let suggestedCount = Int(safeToUse) / max(itemSize, 1)
        return min(suggestedCount, maxItems)
    }

    // MARK: - Formatting

    func formatBytes(_ bytes: UInt64) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
    }

    var memoryStatus: String {
        """
        Used: \(formatBytes(usedMemory))
        Available: \(formatBytes(availableMemory))
        Usage: \(String(format: "%.1f", memoryUsagePercentage))%
        Status: \(isMemoryCritical ? "CRITICAL" : isMemoryLow ? "WARNING" : "OK")
        """
    }

    // MARK: - Cleanup Helpers

    func performWithMemoryCheck<T>(_ operation: () async throws -> T) async throws -> T {
        await checkMemoryAndWait()
        return try await operation()
    }

    func autoreleasePooled<T>(_ operation: () -> T) -> T {
        autoreleasepool {
            operation()
        }
    }
}

// MARK: - Memory Statistics

extension MemoryManager {
    struct MemoryStats {
        let used: UInt64
        let available: UInt64
        let total: UInt64
        let percentage: Double

        var formattedUsed: String {
            ByteCountFormatter.string(fromByteCount: Int64(used), countStyle: .memory)
        }

        var formattedAvailable: String {
            ByteCountFormatter.string(fromByteCount: Int64(available), countStyle: .memory)
        }

        var formattedTotal: String {
            ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .memory)
        }
    }

    var stats: MemoryStats {
        let total = ProcessInfo.processInfo.physicalMemory
        let used = usedMemory
        let available = total - used

        return MemoryStats(
            used: used,
            available: available,
            total: total,
            percentage: Double(used) / Double(total) * 100
        )
    }
}
