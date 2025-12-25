import Foundation

// MARK: - DBSCAN Clustering

struct DBSCANCluster<T: Hashable> {
    let id: Int
    var members: [T]
}

final class DBSCANClustering<T: Hashable> {
    typealias DistanceFunction = (T, T) -> Double

    private let epsilon: Double
    private let minPoints: Int
    private let distanceFunction: DistanceFunction

    init(epsilon: Double, minPoints: Int, distanceFunction: @escaping DistanceFunction) {
        self.epsilon = epsilon
        self.minPoints = minPoints
        self.distanceFunction = distanceFunction
    }

    func cluster(_ points: [T]) -> [DBSCANCluster<T>] {
        guard !points.isEmpty else { return [] }

        var labels = [T: Int]()  // -1 = noise, 0 = unvisited, >0 = cluster
        var clusterId = 0

        for point in points {
            guard labels[point] == nil else { continue }

            let neighbors = regionQuery(point, in: points)

            if neighbors.count < minPoints {
                labels[point] = -1  // Noise
            } else {
                clusterId += 1
                expandCluster(
                    point: point,
                    neighbors: neighbors,
                    points: points,
                    labels: &labels,
                    clusterId: clusterId
                )
            }
        }

        // Group by cluster
        var clusters: [Int: [T]] = [:]
        for (point, label) in labels where label > 0 {
            clusters[label, default: []].append(point)
        }

        return clusters.map { DBSCANCluster(id: $0.key, members: $0.value) }
            .sorted { $0.members.count > $1.members.count }
    }

    private func regionQuery(_ point: T, in points: [T]) -> [T] {
        points.filter { distanceFunction(point, $0) <= epsilon }
    }

    private func expandCluster(
        point: T,
        neighbors: [T],
        points: [T],
        labels: inout [T: Int],
        clusterId: Int
    ) {
        labels[point] = clusterId

        var queue = neighbors
        var visited = Set<T>()

        while !queue.isEmpty {
            let current = queue.removeFirst()
            guard !visited.contains(current) else { continue }
            visited.insert(current)

            if labels[current] == -1 {
                labels[current] = clusterId
            }

            guard labels[current] == nil else { continue }
            labels[current] = clusterId

            let currentNeighbors = regionQuery(current, in: points)
            if currentNeighbors.count >= minPoints {
                queue.append(contentsOf: currentNeighbors)
            }
        }
    }
}

// MARK: - Hierarchical Clustering

final class HierarchicalClustering<T> {
    typealias DistanceFunction = (T, T) -> Double

    enum LinkageMethod {
        case single   // Minimum distance
        case complete // Maximum distance
        case average  // Average distance
    }

    private let linkage: LinkageMethod
    private let distanceFunction: DistanceFunction

    init(linkage: LinkageMethod = .average, distanceFunction: @escaping DistanceFunction) {
        self.linkage = linkage
        self.distanceFunction = distanceFunction
    }

    func cluster(_ items: [T], threshold: Double) -> [[T]] {
        guard items.count > 1 else { return items.isEmpty ? [] : [items] }

        // Initialize clusters
        var clusters: [[T]] = items.map { [$0] }

        // Compute initial distance matrix
        var distances = buildDistanceMatrix(clusters)

        // Agglomerative clustering
        while clusters.count > 1 {
            // Find closest pair
            guard let (i, j, distance) = findClosestPair(distances) else { break }

            // Check threshold
            if distance > threshold { break }

            // Merge clusters
            let merged = clusters[i] + clusters[j]
            clusters.remove(at: max(i, j))
            clusters.remove(at: min(i, j))
            clusters.append(merged)

            // Update distance matrix
            distances = buildDistanceMatrix(clusters)
        }

        return clusters.filter { $0.count > 1 }
    }

    private func buildDistanceMatrix(_ clusters: [[T]]) -> [[Double]] {
        let n = clusters.count
        var matrix = [[Double]](repeating: [Double](repeating: Double.infinity, count: n), count: n)

        for i in 0..<n {
            for j in (i + 1)..<n {
                let distance = clusterDistance(clusters[i], clusters[j])
                matrix[i][j] = distance
                matrix[j][i] = distance
            }
        }

        return matrix
    }

    private func clusterDistance(_ a: [T], _ b: [T]) -> Double {
        var distances: [Double] = []

        for itemA in a {
            for itemB in b {
                distances.append(distanceFunction(itemA, itemB))
            }
        }

        switch linkage {
        case .single:
            return distances.min() ?? Double.infinity
        case .complete:
            return distances.max() ?? Double.infinity
        case .average:
            return distances.isEmpty ? Double.infinity : distances.reduce(0, +) / Double(distances.count)
        }
    }

    private func findClosestPair(_ matrix: [[Double]]) -> (Int, Int, Double)? {
        var minDistance = Double.infinity
        var minI = 0
        var minJ = 0

        for i in 0..<matrix.count {
            for j in (i + 1)..<matrix.count {
                if matrix[i][j] < minDistance {
                    minDistance = matrix[i][j]
                    minI = i
                    minJ = j
                }
            }
        }

        guard minDistance < Double.infinity else { return nil }
        return (minI, minJ, minDistance)
    }
}

// MARK: - Union-Find for fast grouping

final class UnionFind<T: Hashable> {
    private var parent: [T: T] = [:]
    private var rank: [T: Int] = [:]

    func find(_ x: T) -> T {
        if parent[x] == nil {
            parent[x] = x
            rank[x] = 0
        }

        if parent[x] != x {
            parent[x] = find(parent[x]!)  // Path compression
        }

        return parent[x]!
    }

    func union(_ x: T, _ y: T) {
        let rootX = find(x)
        let rootY = find(y)

        guard rootX != rootY else { return }

        // Union by rank
        let rankX = rank[rootX] ?? 0
        let rankY = rank[rootY] ?? 0

        if rankX < rankY {
            parent[rootX] = rootY
        } else if rankX > rankY {
            parent[rootY] = rootX
        } else {
            parent[rootY] = rootX
            rank[rootX] = rankX + 1
        }
    }

    func groups() -> [[T]] {
        var result: [T: [T]] = [:]

        for key in parent.keys {
            let root = find(key)
            result[root, default: []].append(key)
        }

        return Array(result.values).filter { $0.count > 1 }
    }
}
