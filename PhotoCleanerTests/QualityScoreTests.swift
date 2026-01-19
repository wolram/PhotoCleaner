import XCTest
@testable import SnapSieve

final class QualityScoreTests: XCTestCase {

    func testCompositeScore() {
        // High quality score
        let highQuality = QualityScore(
            aestheticScore: 0.8,
            isUtility: false,
            blurScore: 0.9,
            exposureScore: 0.5
        )
        XCTAssertGreaterThan(highQuality.composite, 0.7)

        // Low quality score
        let lowQuality = QualityScore(
            aestheticScore: -0.5,
            isUtility: false,
            blurScore: 0.2,
            exposureScore: 0.1
        )
        XCTAssertLessThan(lowQuality.composite, 0.4)

        // Utility images always return -1
        let utility = QualityScore(
            aestheticScore: 0.8,
            isUtility: true,
            blurScore: 0.9,
            exposureScore: 0.5
        )
        XCTAssertEqual(utility.composite, -1)
    }

    func testGradeAssignment() {
        let excellent = QualityScore(aestheticScore: 0.9, isUtility: false, blurScore: 0.95, exposureScore: 0.5)
        XCTAssertEqual(excellent.grade, .A)

        let good = QualityScore(aestheticScore: 0.4, isUtility: false, blurScore: 0.8, exposureScore: 0.5)
        XCTAssertEqual(good.grade, .B)

        let utility = QualityScore(aestheticScore: 0.9, isUtility: true, blurScore: 0.95, exposureScore: 0.5)
        XCTAssertEqual(utility.grade, .U)
    }

    func testBlurDetection() {
        let sharp = QualityScore(aestheticScore: 0, isUtility: false, blurScore: 0.9, exposureScore: 0.5)
        XCTAssertTrue(sharp.isSharp)
        XCTAssertFalse(sharp.isBlurry)

        let blurry = QualityScore(aestheticScore: 0, isUtility: false, blurScore: 0.2, exposureScore: 0.5)
        XCTAssertFalse(blurry.isSharp)
        XCTAssertTrue(blurry.isBlurry)
    }

    func testExposureDetection() {
        let normal = QualityScore(aestheticScore: 0, isUtility: false, blurScore: 0.5, exposureScore: 0.5)
        XCTAssertFalse(normal.isOverexposed)
        XCTAssertFalse(normal.isUnderexposed)

        let overexposed = QualityScore(aestheticScore: 0, isUtility: false, blurScore: 0.5, exposureScore: 0.9)
        XCTAssertTrue(overexposed.isOverexposed)

        let underexposed = QualityScore(aestheticScore: 0, isUtility: false, blurScore: 0.5, exposureScore: 0.1)
        XCTAssertTrue(underexposed.isUnderexposed)
    }

    func testIssuesDetection() {
        let perfect = QualityScore(aestheticScore: 0.5, isUtility: false, blurScore: 0.8, exposureScore: 0.5)
        XCTAssertTrue(perfect.issues.isEmpty)

        let problematic = QualityScore(aestheticScore: 0, isUtility: false, blurScore: 0.2, exposureScore: 0.9)
        XCTAssertTrue(problematic.issues.contains("Blurry"))
        XCTAssertTrue(problematic.issues.contains("Overexposed"))
    }
}
