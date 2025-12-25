import Foundation

actor SimilarityGroupingService {
    static let shared = SimilarityGroupingService()

    private var hammingThreshold: Int = 8

    private init() {}

    func setThreshold(_ value: Int) {
        hammingThreshold = max(1, min(32, value))
    }

    // MARK: - Find Similar Photos

    func findSimilarGroups(
        photos: [(id: String, hash: UInt64)],
        progress: (@Sendable (Double) -> Void)? = nil
    ) async -> [[String]] {
        guard photos.count > 1 else { return [] }

        var groups: [[String]] = []
        var processed = Set<String>()
        let total = photos.count

        for (index, photo) in photos.enumerated() {
            guard !processed.contains(photo.id) else { continue }

            var group = [photo.id]
            processed.insert(photo.id)

            for candidate in photos[(index + 1)...] {
                guard !processed.contains(candidate.id) else { continue }

                let distance = hammingDistance(photo.hash, candidate.hash)

                if distance <= hammingThreshold {
                    group.append(candidate.id)
                    processed.insert(candidate.id)
                }
            }

            if group.count > 1 {
                groups.append(group)
            }

            progress?(Double(index + 1) / Double(total))
        }

        return groups
    }

    // MARK: - DBSCAN Clustering

    func clusterDBSCAN(
        photos: [(id: String, hash: UInt64)],
        epsilon: Int = 8,
        minPoints: Int = 2
    ) async -> [[String]] {
        guard photos.count >= minPoints else { return [] }

        var labels = [Int](repeating: -1, count: photos.count) // -1 = unvisited
        var clusterId = 0

        for i in 0..<photos.count {
            guard labels[i] == -1 else { continue }

            let neighbors = regionQuery(photos: photos, pointIndex: i, epsilon: epsilon)

            if neighbors.count < minPoints {
                labels[i] = 0 // Noise
            } else {
                clusterId += 1
                expandCluster(
                    photos: photos,
                    labels: &labels,
                    pointIndex: i,
                    neighbors: neighbors,
                    clusterId: clusterId,
                    epsilon: epsilon,
                    minPoints: minPoints
                )
            }
        }

        // Group by cluster ID
        var clusters: [Int: [String]] = [:]
        for (index, label) in labels.enumerated() where label > 0 {
            clusters[label, default: []].append(photos[index].id)
        }

        return Array(clusters.values).filter { $0.count >= minPoints }
    }

    private func regionQuery(
        photos: [(id: String, hash: UInt64)],
        pointIndex: Int,
        epsilon: Int
    ) -> [Int] {
        var neighbors: [Int] = []
        let pointHash = photos[pointIndex].hash

        for (index, photo) in photos.enumerated() {
            if hammingDistance(pointHash, photo.hash) <= epsilon {
                neighbors.append(index)
            }
        }

        return neighbors
    }

    private func expandCluster(
        photos: [(id: String, hash: UInt64)],
        labels: inout [Int],
        pointIndex: Int,
        neighbors: [Int],
        clusterId: Int,
        epsilon: Int,
        minPoints: Int
    ) {
        labels[pointIndex] = clusterId

        var queue = neighbors
        var visited = Set<Int>()

        while !queue.isEmpty {
            let currentIndex = queue.removeFirst()
            guard !visited.contains(currentIndex) else { continue }
            visited.insert(currentIndex)

            if labels[currentIndex] == 0 { // Was noise
                labels[currentIndex] = clusterId
            }

            guard labels[currentIndex] == -1 else { continue }
            labels[currentIndex] = clusterId

            let currentNeighbors = regionQuery(
                photos: photos,
                pointIndex: currentIndex,
                epsilon: epsilon
            )

            if currentNeighbors.count >= minPoints {
                queue.append(contentsOf: currentNeighbors)
            }
        }
    }

    // MARK: - Hamming Distance

    func hammingDistance(_ a: UInt64, _ b: UInt64) -> Int {
        return (a ^ b).nonzeroBitCount
    }

    // MARK: - Combined Similarity (Hash + Embedding)

    func findSimilarWithEmbeddings(
        photos: [(id: String, hash: UInt64, embedding: [Float]?)],
        hashThreshold: Int = 10,
        embeddingThreshold: Float = 0.85,
        progress: (@Sendable (Double) -> Void)? = nil
    ) async -> [[String]] {
        guard photos.count > 1 else { return [] }

        var groups: [[String]] = []
        var processed = Set<String>()
        let total = photos.count

        for (index, photo) in photos.enumerated() {
            guard !processed.contains(photo.id) else { continue }

            var group = [photo.id]
            processed.insert(photo.id)

            for candidate in photos[(index + 1)...] {
                guard !processed.contains(candidate.id) else { continue }

                // First check hash (fast)
                let hashDist = hammingDistance(photo.hash, candidate.hash)

                if hashDist <= hashThreshold {
                    // If hashes are close, check embeddings for confirmation
                    if let emb1 = photo.embedding, let emb2 = candidate.embedding {
                        let similarity = cosineSimilarity(emb1, emb2)
                        if similarity >= embeddingThreshold {
                            group.append(candidate.id)
                            processed.insert(candidate.id)
                        }
                    } else {
                        // No embeddings, use hash only
                        group.append(candidate.id)
                        processed.insert(candidate.id)
                    }
                }
            }

            if group.count > 1 {
                groups.append(group)
            }

            progress?(Double(index + 1) / Double(total))
        }

        return groups
    }

    // MARK: - Cosine Similarity

    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }

        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0

        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }

        let denominator = sqrt(normA) * sqrt(normB)
        guard denominator > 0 else { return 0 }

        return dotProduct / denominator
    }
}
