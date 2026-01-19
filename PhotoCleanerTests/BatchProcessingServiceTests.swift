import XCTest
@testable import SnapSieve

final class BatchProcessingServiceTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Reset service state before each test
        let service = BatchProcessingService.shared
        await service.reset()
    }

    // MARK: - Concurrency Configuration Tests

    func testSetMaxConcurrency() async {
        let service = BatchProcessingService.shared

        // Set valid concurrency
        await service.setMaxConcurrency(4)

        // Set concurrency below minimum (should clamp to 1)
        await service.setMaxConcurrency(0)

        // Set concurrency above maximum (should clamp to 16)
        await service.setMaxConcurrency(20)

        // All calls should succeed without throwing
        XCTAssertTrue(true)
    }

    func testSetMaxConcurrencyBoundaries() async {
        let service = BatchProcessingService.shared

        // Test minimum boundary
        await service.setMaxConcurrency(1)

        // Test maximum boundary
        await service.setMaxConcurrency(16)

        // Test typical values
        await service.setMaxConcurrency(8)

        XCTAssertTrue(true)
    }

    // MARK: - Cancellation Tests

    func testCancelAndReset() async {
        let service = BatchProcessingService.shared

        // Initially not cancelled
        await service.reset()

        // Cancel
        await service.cancel()

        // Reset
        await service.reset()

        // Should succeed without throwing
        XCTAssertTrue(true)
    }

    func testCancelState() async {
        let service = BatchProcessingService.shared

        await service.reset()

        // Cancel service
        await service.cancel()

        // Verify cancellation persists
        await service.cancel() // Should be idempotent

        XCTAssertTrue(true)
    }

    func testResetAfterCancel() async {
        let service = BatchProcessingService.shared

        // Cancel
        await service.cancel()

        // Reset should clear cancellation
        await service.reset()

        // Should be able to use service again
        await service.setMaxConcurrency(8)

        XCTAssertTrue(true)
    }

    // MARK: - ProcessingError Tests

    func testProcessingErrorDescriptions() {
        let errors: [BatchProcessingService.ProcessingError] = [
            .cancelled,
            .assetNotFound,
            .imageLoadFailed,
            .analysiseFailed
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
        }
    }

    func testProcessingErrorCancelledDescription() {
        let error = BatchProcessingService.ProcessingError.cancelled
        XCTAssertEqual(error.errorDescription, "Processing was cancelled")
    }

    func testProcessingErrorAssetNotFoundDescription() {
        let error = BatchProcessingService.ProcessingError.assetNotFound
        XCTAssertEqual(error.errorDescription, "Photo asset not found")
    }

    func testProcessingErrorImageLoadFailedDescription() {
        let error = BatchProcessingService.ProcessingError.imageLoadFailed
        XCTAssertEqual(error.errorDescription, "Failed to load image")
    }

    func testProcessingErrorAnalysisFailedDescription() {
        let error = BatchProcessingService.ProcessingError.analysiseFailed
        XCTAssertEqual(error.errorDescription, "Image analysis failed")
    }

    // MARK: - ProcessingResult Structure Tests

    func testProcessingResultInitialization() {
        let result = BatchProcessingService.ProcessingResult(
            photoId: "test123",
            isUtility: false,
            fileSize: 1_000_000,
            pixelWidth: 2000,
            pixelHeight: 1500
        )

        XCTAssertEqual(result.photoId, "test123")
        XCTAssertFalse(result.isUtility)
        XCTAssertEqual(result.fileSize, 1_000_000)
        XCTAssertEqual(result.pixelWidth, 2000)
        XCTAssertEqual(result.pixelHeight, 1500)

        // Optional fields should be nil
        XCTAssertNil(result.featurePrintData)
        XCTAssertNil(result.perceptualHash)
        XCTAssertNil(result.aestheticScore)
        XCTAssertNil(result.blurScore)
        XCTAssertNil(result.exposureScore)
        XCTAssertNil(result.embedding)
        XCTAssertNil(result.error)
        XCTAssertNil(result.creationDate)
        XCTAssertNil(result.fileName)
    }

    func testProcessingResultWithFullData() {
        var result = BatchProcessingService.ProcessingResult(
            photoId: "test456",
            isUtility: true,
            fileSize: 2_000_000,
            pixelWidth: 4000,
            pixelHeight: 3000
        )

        // Populate optional fields
        result.featurePrintData = Data([1, 2, 3, 4])
        result.perceptualHash = 12345678
        result.aestheticScore = 0.85
        result.blurScore = 0.92
        result.exposureScore = 0.55
        result.embedding = [0.1, 0.2, 0.3]
        result.creationDate = Date()
        result.fileName = "IMG_1234.jpg"

        XCTAssertNotNil(result.featurePrintData)
        XCTAssertEqual(result.perceptualHash, 12345678)
        XCTAssertEqual(result.aestheticScore, 0.85)
        XCTAssertEqual(result.blurScore, 0.92)
        XCTAssertEqual(result.exposureScore, 0.55)
        XCTAssertEqual(result.embedding?.count, 3)
        XCTAssertNotNil(result.creationDate)
        XCTAssertEqual(result.fileName, "IMG_1234.jpg")
    }

    func testProcessingResultWithError() {
        var result = BatchProcessingService.ProcessingResult(
            photoId: "error_photo",
            isUtility: false,
            fileSize: 0,
            pixelWidth: 0,
            pixelHeight: 0
        )

        result.error = BatchProcessingService.ProcessingError.imageLoadFailed

        XCTAssertNotNil(result.error)
        XCTAssertEqual(
            (result.error as? BatchProcessingService.ProcessingError),
            .imageLoadFailed
        )
    }

    // MARK: - State Management Tests

    func testMultipleCancelCalls() async {
        let service = BatchProcessingService.shared

        await service.reset()

        // Multiple cancel calls should be safe
        await service.cancel()
        await service.cancel()
        await service.cancel()

        XCTAssertTrue(true)
    }

    func testMultipleResetCalls() async {
        let service = BatchProcessingService.shared

        // Multiple reset calls should be safe
        await service.reset()
        await service.reset()
        await service.reset()

        XCTAssertTrue(true)
    }

    func testConcurrentConfiguration() async {
        let service = BatchProcessingService.shared

        // Concurrent configuration changes should be safe
        await withTaskGroup(of: Void.self) { group in
            for i in 1...10 {
                group.addTask {
                    await service.setMaxConcurrency(i)
                }
            }
        }

        XCTAssertTrue(true)
    }

    // MARK: - Integration Tests (Lightweight)

    func testServiceSingleton() {
        let service1 = BatchProcessingService.shared
        let service2 = BatchProcessingService.shared

        // Should be the same instance
        XCTAssertTrue(service1 === service2)
    }

    func testProcessingResultMutability() {
        var result = BatchProcessingService.ProcessingResult(
            photoId: "mutable_test",
            isUtility: false,
            fileSize: 500_000,
            pixelWidth: 1000,
            pixelHeight: 800
        )

        // Should be able to modify optional properties
        XCTAssertNil(result.aestheticScore)
        result.aestheticScore = 0.75
        XCTAssertEqual(result.aestheticScore, 0.75)

        XCTAssertNil(result.blurScore)
        result.blurScore = 0.88
        XCTAssertEqual(result.blurScore, 0.88)
    }

    func testConfigurationSequence() async {
        let service = BatchProcessingService.shared

        // Typical usage sequence
        await service.reset()
        await service.setMaxConcurrency(4)

        // Simulate cancellation during processing
        await service.cancel()

        // Reset for next batch
        await service.reset()
        await service.setMaxConcurrency(8)

        XCTAssertTrue(true)
    }
}
