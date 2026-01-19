import XCTest
@testable import SnapSieve

final class DuplicateDetectionServiceTests: XCTestCase {

    // MARK: - Threshold Tests

    func testSetThreshold() async {
        let service = DuplicateDetectionService.shared

        // Set valid threshold
        await service.setThreshold(0.3)

        // Set threshold below minimum (should clamp to 0.1)
        await service.setThreshold(0.05)

        // Set threshold above maximum (should clamp to 1.0)
        await service.setThreshold(1.5)

        // All calls should succeed without throwing
        XCTAssertTrue(true)
    }

    // MARK: - Merge Overlapping Groups Tests

    func testMergeOverlappingGroupsNoOverlap() async {
        let service = DuplicateDetectionService.shared

        let groups = [
            ["photo1", "photo2"],
            ["photo3", "photo4"],
            ["photo5", "photo6"]
        ]

        let merged = await service.mergeOverlappingGroups(groups)

        // Should remain 3 separate groups
        XCTAssertEqual(merged.count, 3)

        // Verify each group contains exactly 2 elements
        for group in merged {
            XCTAssertEqual(group.count, 2)
        }
    }

    func testMergeOverlappingGroupsWithSingleOverlap() async {
        let service = DuplicateDetectionService.shared

        let groups = [
            ["photo1", "photo2"],
            ["photo2", "photo3"], // Overlaps with first group
            ["photo4", "photo5"]
        ]

        let merged = await service.mergeOverlappingGroups(groups)

        // Should merge first two groups, leaving 2 total
        XCTAssertEqual(merged.count, 2)

        // Find the merged group
        let mergedGroup = merged.first { $0.contains("photo1") }
        XCTAssertNotNil(mergedGroup)
        XCTAssertEqual(mergedGroup?.count, 3)
        XCTAssertTrue(mergedGroup?.contains("photo1") ?? false)
        XCTAssertTrue(mergedGroup?.contains("photo2") ?? false)
        XCTAssertTrue(mergedGroup?.contains("photo3") ?? false)
    }

    func testMergeOverlappingGroupsWithMultipleOverlaps() async {
        let service = DuplicateDetectionService.shared

        let groups = [
            ["photo1", "photo2"],
            ["photo2", "photo3"],
            ["photo3", "photo4"],
            ["photo5", "photo6"]
        ]

        let merged = await service.mergeOverlappingGroups(groups)

        // Should merge first three groups into one, leaving 2 total
        XCTAssertEqual(merged.count, 2)

        // Find the large merged group
        let largeGroup = merged.first { $0.contains("photo1") }
        XCTAssertNotNil(largeGroup)
        XCTAssertEqual(largeGroup?.count, 4)
        XCTAssertTrue(largeGroup?.contains("photo1") ?? false)
        XCTAssertTrue(largeGroup?.contains("photo2") ?? false)
        XCTAssertTrue(largeGroup?.contains("photo3") ?? false)
        XCTAssertTrue(largeGroup?.contains("photo4") ?? false)
    }

    func testMergeOverlappingGroupsWithComplexChain() async {
        let service = DuplicateDetectionService.shared

        let groups = [
            ["A", "B"],
            ["C", "D"],
            ["B", "C"], // Links first two groups
            ["E", "F"],
            ["D", "E"]  // Links to chain
        ]

        let merged = await service.mergeOverlappingGroups(groups)

        // All should merge into one group
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].count, 6)

        // Verify all elements are present
        let allPhotos = Set(["A", "B", "C", "D", "E", "F"])
        XCTAssertEqual(Set(merged[0]), allPhotos)
    }

    func testMergeOverlappingGroupsEmptyInput() async {
        let service = DuplicateDetectionService.shared

        let merged = await service.mergeOverlappingGroups([])

        XCTAssertTrue(merged.isEmpty)
    }

    func testMergeOverlappingGroupsSingleGroup() async {
        let service = DuplicateDetectionService.shared

        let groups = [["photo1", "photo2", "photo3"]]
        let merged = await service.mergeOverlappingGroups(groups)

        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].count, 3)
    }

    func testMergeOverlappingGroupsWithDuplicateElements() async {
        let service = DuplicateDetectionService.shared

        let groups = [
            ["photo1", "photo2", "photo1"], // Duplicate within group
            ["photo2", "photo3"]
        ]

        let merged = await service.mergeOverlappingGroups(groups)

        // Should merge and deduplicate
        XCTAssertEqual(merged.count, 1)

        // Should have 3 unique elements (photo1, photo2, photo3)
        let uniqueElements = Set(merged[0])
        XCTAssertEqual(uniqueElements.count, 3)
    }

    func testMergeOverlappingGroupsMultipleDisconnectedChains() async {
        let service = DuplicateDetectionService.shared

        let groups = [
            ["A", "B"],
            ["B", "C"],
            ["X", "Y"],
            ["Y", "Z"],
            ["1", "2"]
        ]

        let merged = await service.mergeOverlappingGroups(groups)

        // Should have 3 separate chains
        XCTAssertEqual(merged.count, 3)

        // Verify sizes
        let sizes = merged.map { $0.count }.sorted()
        XCTAssertEqual(sizes, [2, 3, 3])
    }
}
