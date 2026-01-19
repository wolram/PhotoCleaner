import XCTest
@testable import SnapSieve

final class BestPhotoSelectorTests: XCTestCase {

    func testSelectBestByQuality() {
        let selector = BestPhotoSelector(weights: .qualityFocused)

        let photos = [
            createPhoto(id: "low", quality: 0.2),
            createPhoto(id: "medium", quality: 0.5),
            createPhoto(id: "high", quality: 0.9)
        ]

        let best = selector.selectBest(from: photos)

        XCTAssertEqual(best?.id, "high")
    }

    func testSelectBestByResolution() {
        let selector = BestPhotoSelector(weights: .resolutionFocused)

        let photos = [
            createPhoto(id: "small", dimensions: CGSize(width: 1000, height: 1000)),
            createPhoto(id: "medium", dimensions: CGSize(width: 2000, height: 2000)),
            createPhoto(id: "large", dimensions: CGSize(width: 4000, height: 4000))
        ]

        let best = selector.selectBest(from: photos)

        XCTAssertEqual(best?.id, "large")
    }

    func testSelectForDeletion() {
        let selector = BestPhotoSelector()

        let photos = [
            createPhoto(id: "1", quality: 0.9),
            createPhoto(id: "2", quality: 0.5),
            createPhoto(id: "3", quality: 0.3)
        ]

        let toDelete = selector.selectForDeletion(from: photos, keep: 1)

        XCTAssertEqual(toDelete.count, 2)
        XCTAssertFalse(toDelete.contains("1"))
        XCTAssertTrue(toDelete.contains("2"))
        XCTAssertTrue(toDelete.contains("3"))
    }

    func testScorePhotos() {
        let selector = BestPhotoSelector()

        let photos = [
            createPhoto(id: "1", quality: 0.8),
            createPhoto(id: "2", quality: 0.4)
        ]

        let scored = selector.scorePhotos(photos)

        XCTAssertEqual(scored.count, 2)
        XCTAssertGreaterThan(scored[0].totalScore, scored[1].totalScore)
    }

    func testEmptyInput() {
        let selector = BestPhotoSelector()

        XCTAssertNil(selector.selectBest(from: []))
        XCTAssertTrue(selector.selectForDeletion(from: [], keep: 1).isEmpty)
    }

    // MARK: - Helpers

    private func createPhoto(
        id: String,
        quality: Float = 0.5,
        dimensions: CGSize = CGSize(width: 2000, height: 1500)
    ) -> PhotoAsset {
        var photo = PhotoAsset(
            id: id,
            creationDate: Date(),
            dimensions: dimensions,
            fileSize: Int64(dimensions.width * dimensions.height)
        )

        photo.qualityScore = QualityScore(
            aestheticScore: quality * 2 - 1, // Convert 0-1 to -1 to 1
            isUtility: false,
            blurScore: quality,
            exposureScore: 0.5
        )

        return photo
    }
}
