import XCTest
@testable import SnapSieve

final class PerceptualHashTests: XCTestCase {

    func testHammingDistance() {
        // Identical hashes should have distance 0
        XCTAssertEqual(PerceptualHash.hammingDistance(0, 0), 0)
        XCTAssertEqual(PerceptualHash.hammingDistance(UInt64.max, UInt64.max), 0)

        // One bit difference
        XCTAssertEqual(PerceptualHash.hammingDistance(0b0001, 0b0000), 1)
        XCTAssertEqual(PerceptualHash.hammingDistance(0b1111, 0b1110), 1)

        // Multiple bit differences
        XCTAssertEqual(PerceptualHash.hammingDistance(0b1111, 0b0000), 4)
        XCTAssertEqual(PerceptualHash.hammingDistance(0b10101010, 0b01010101), 8)
    }

    func testSimilarity() {
        // Identical hashes should have similarity 1.0
        XCTAssertEqual(PerceptualHash.similarity(123456, 123456), 1.0)

        // Completely different hashes
        let hash1: UInt64 = 0xFFFFFFFFFFFFFFFF
        let hash2: UInt64 = 0x0000000000000000
        XCTAssertEqual(PerceptualHash.similarity(hash1, hash2), 0.0)
    }

    func testAreSimilar() {
        // Identical hashes are similar
        XCTAssertTrue(PerceptualHash.areSimilar(100, 100))

        // Hashes with small differences are similar
        XCTAssertTrue(PerceptualHash.areSimilar(0b11111111, 0b11111110, threshold: 1))

        // Hashes with large differences are not similar
        XCTAssertFalse(PerceptualHash.areSimilar(0xFFFF, 0x0000, threshold: 8))
    }
}
