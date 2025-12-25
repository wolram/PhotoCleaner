import Vision
import Foundation

actor DuplicateDetectionService {
    static let shared = DuplicateDetectionService()

    private var threshold: Float = 0.5

    private init() {}

    func setThreshold(_ value: Float) {
        threshold = max(0.1, min(1.0, value))
    }

    // MARK: - Duplicate Detection

    struct DuplicateGroup {
        let photos: [String] // Local identifiers
        let distances: [Float] // Pairwise distances
    }

    func findDuplicates(
        photos: [(id: String, featurePrint: VNFeaturePrintObservation)],
        progress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> [[String]] {
        guard photos.count > 1 else { return [] }

        var groups: [[String]] = []
        var processed = Set<String>()
        let total = photos.count

        for (index, photo) in photos.enumerated() {
            guard !processed.contains(photo.id) else { continue }

            var group = [photo.id]
            processed.insert(photo.id)

            // Compare with remaining photos
            for candidate in photos[(index + 1)...] {
                guard !processed.contains(candidate.id) else { continue }

                do {
                    var distance: Float = 0
                    try photo.featurePrint.computeDistance(&distance, to: candidate.featurePrint)

                    if distance < threshold {
                        group.append(candidate.id)
                        processed.insert(candidate.id)
                    }
                } catch {
                    continue
                }
            }

            if group.count > 1 {
                groups.append(group)
            }

            progress?(Double(index + 1) / Double(total))
        }

        return groups
    }

    // MARK: - Optimized Detection with Spatial Index

    func findDuplicatesOptimized(
        photos: [(id: String, featurePrint: VNFeaturePrintObservation)],
        progress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> [[String]] {
        // For very large libraries, use a more efficient algorithm
        // This implementation uses a simple approach with early termination

        guard photos.count > 1 else { return [] }

        // Build distance matrix for small sets
        if photos.count < 1000 {
            return try await findDuplicates(photos: photos, progress: progress)
        }

        // For larger sets, use batch comparison
        return try await findDuplicatesBatched(photos: photos, progress: progress)
    }

    private func findDuplicatesBatched(
        photos: [(id: String, featurePrint: VNFeaturePrintObservation)],
        batchSize: Int = 100,
        progress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> [[String]] {
        var groups: [[String]] = []
        var processed = Set<String>()
        let total = photos.count

        for batchStart in stride(from: 0, to: photos.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, photos.count)
            let batch = Array(photos[batchStart..<batchEnd])

            for photo in batch {
                guard !processed.contains(photo.id) else { continue }

                var group = [photo.id]
                processed.insert(photo.id)

                // Compare with all unprocessed photos
                for candidate in photos where !processed.contains(candidate.id) {
                    do {
                        var distance: Float = 0
                        try photo.featurePrint.computeDistance(&distance, to: candidate.featurePrint)

                        if distance < threshold {
                            group.append(candidate.id)
                            processed.insert(candidate.id)
                        }
                    } catch {
                        continue
                    }
                }

                if group.count > 1 {
                    groups.append(group)
                }
            }

            progress?(Double(batchEnd) / Double(total))
        }

        return groups
    }

    // MARK: - Compare Two Photos

    func areDuplicates(
        _ fp1: VNFeaturePrintObservation,
        _ fp2: VNFeaturePrintObservation
    ) throws -> Bool {
        var distance: Float = 0
        try fp1.computeDistance(&distance, to: fp2)
        return distance < threshold
    }

    func getDistance(
        _ fp1: VNFeaturePrintObservation,
        _ fp2: VNFeaturePrintObservation
    ) throws -> Float {
        var distance: Float = 0
        try fp1.computeDistance(&distance, to: fp2)
        return distance
    }

    // MARK: - Merge Groups

    func mergeOverlappingGroups(_ groups: [[String]]) -> [[String]] {
        guard !groups.isEmpty else { return [] }

        var merged: [[String]] = []
        var used = Set<Int>()

        for (i, group) in groups.enumerated() {
            guard !used.contains(i) else { continue }

            var currentGroup = Set(group)
            used.insert(i)

            // Check for overlaps with other groups
            var foundOverlap = true
            while foundOverlap {
                foundOverlap = false
                for (j, otherGroup) in groups.enumerated() {
                    guard !used.contains(j) else { continue }

                    let otherSet = Set(otherGroup)
                    if !currentGroup.isDisjoint(with: otherSet) {
                        currentGroup.formUnion(otherSet)
                        used.insert(j)
                        foundOverlap = true
                    }
                }
            }

            merged.append(Array(currentGroup))
        }

        return merged
    }
}
