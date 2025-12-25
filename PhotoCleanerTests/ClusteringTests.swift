import XCTest
@testable import PhotoCleaner

final class ClusteringTests: XCTestCase {

    func testUnionFind() {
        let uf = UnionFind<String>()

        // Initially, each element is its own parent
        XCTAssertEqual(uf.find("a"), "a")
        XCTAssertEqual(uf.find("b"), "b")

        // Union two elements
        uf.union("a", "b")
        XCTAssertEqual(uf.find("a"), uf.find("b"))

        // Add more elements
        uf.union("c", "d")
        uf.union("b", "c")

        // All should be in same group now
        XCTAssertEqual(uf.find("a"), uf.find("d"))
    }

    func testUnionFindGroups() {
        let uf = UnionFind<Int>()

        // Create group 1: 1, 2, 3
        uf.union(1, 2)
        uf.union(2, 3)

        // Create group 2: 4, 5
        uf.union(4, 5)

        // Single element: 6
        _ = uf.find(6)

        let groups = uf.groups()

        // Should have 2 groups (groups with single element are filtered)
        XCTAssertEqual(groups.count, 2)

        // Group sizes
        let sizes = groups.map { $0.count }.sorted()
        XCTAssertEqual(sizes, [2, 3])
    }

    func testDBSCANClustering() {
        struct Point: Hashable {
            let x: Double
            let y: Double
        }

        let dbscan = DBSCANClustering<Point>(
            epsilon: 1.5,
            minPoints: 2
        ) { p1, p2 in
            sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
        }

        let points = [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0, y: 1),
            Point(x: 10, y: 10),
            Point(x: 11, y: 10),
            Point(x: 100, y: 100) // Noise point
        ]

        let clusters = dbscan.cluster(points)

        // Should find 2 clusters
        XCTAssertEqual(clusters.count, 2)

        // Cluster sizes
        let sizes = clusters.map { $0.members.count }.sorted()
        XCTAssertEqual(sizes, [2, 3])
    }

    func testHierarchicalClustering() {
        let clustering = HierarchicalClustering<Int>(
            linkage: .single
        ) { a, b in
            Double(abs(a - b))
        }

        let items = [1, 2, 3, 10, 11, 12]
        let clusters = clustering.cluster(items, threshold: 3.0)

        // Should find 2 clusters
        XCTAssertEqual(clusters.count, 2)

        // Each cluster should have 3 elements
        for cluster in clusters {
            XCTAssertEqual(cluster.count, 3)
        }
    }
}
