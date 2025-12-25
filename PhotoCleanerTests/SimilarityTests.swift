import XCTest
@testable import PhotoCleaner

final class SimilarityTests: XCTestCase {

    func testCosineSimilarity() async {
        let service = SimilarityGroupingService.shared

        // Identical vectors should have similarity 1.0
        let v1: [Float] = [1, 0, 0]
        let result1 = await service.cosineSimilarity(v1, v1)
        XCTAssertEqual(result1, 1.0, accuracy: 0.001)

        // Orthogonal vectors should have similarity 0.0
        let v2: [Float] = [0, 1, 0]
        let result2 = await service.cosineSimilarity(v1, v2)
        XCTAssertEqual(result2, 0.0, accuracy: 0.001)

        // Opposite vectors should have similarity -1.0
        let v3: [Float] = [-1, 0, 0]
        let result3 = await service.cosineSimilarity(v1, v3)
        XCTAssertEqual(result3, -1.0, accuracy: 0.001)
    }

    func testHammingDistanceGrouping() async {
        let service = SimilarityGroupingService.shared

        let photos: [(id: String, hash: UInt64)] = [
            ("a", 0b11111111),
            ("b", 0b11111110), // 1 bit different from a
            ("c", 0b11111100), // 2 bits different from a
            ("d", 0b00000000), // 8 bits different from a
        ]

        // With threshold 2, a, b, c should be grouped
        await service.setThreshold(2)
        let groups = await service.findSimilarGroups(photos: photos)

        // Should find at least one group containing a, b, c
        XCTAssertFalse(groups.isEmpty)

        let foundGroup = groups.first { $0.contains("a") }
        XCTAssertNotNil(foundGroup)
        XCTAssertTrue(foundGroup?.contains("b") ?? false)
        XCTAssertTrue(foundGroup?.contains("c") ?? false)
        XCTAssertFalse(foundGroup?.contains("d") ?? true)
    }

    func testEmptyInput() async {
        let service = SimilarityGroupingService.shared

        let emptyGroups = await service.findSimilarGroups(photos: [])
        XCTAssertTrue(emptyGroups.isEmpty)

        let singleGroups = await service.findSimilarGroups(photos: [("a", 123)])
        XCTAssertTrue(singleGroups.isEmpty)
    }
}
