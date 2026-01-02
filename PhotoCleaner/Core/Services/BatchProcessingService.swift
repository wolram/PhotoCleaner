import Foundation
import Photos

actor BatchProcessingService {
    static let shared = BatchProcessingService()

    private var maxConcurrency: Int = 8
    private var isCancelled = false

    private init() {}

    func setMaxConcurrency(_ value: Int) {
        maxConcurrency = max(1, min(16, value))
    }

    func cancel() {
        isCancelled = true
    }

    func reset() {
        isCancelled = false
    }

    // MARK: - Process All Photos

    struct ProcessingResult {
        let photoId: String
        var featurePrintData: Data?
        var perceptualHash: UInt64?
        var aestheticScore: Float?
        var isUtility: Bool
        var blurScore: Float?
        var exposureScore: Float?
        var embedding: [Float]?
        var error: Error?

        // Asset metadata
        var fileSize: Int64
        var pixelWidth: Int
        var pixelHeight: Int
        var creationDate: Date?
        var fileName: String?
    }

    func processPhotos(
        identifiers: [String],
        progress: @MainActor @Sendable (Double, String) -> Void
    ) async throws -> [ProcessingResult] {
        isCancelled = false
        var results: [ProcessingResult] = []
        results.reserveCapacity(identifiers.count)

        let total = identifiers.count
        var completed = 0

        try await withThrowingTaskGroup(of: ProcessingResult.self) { group in
            var iterator = identifiers.makeIterator()

            // Start initial batch
            for _ in 0..<maxConcurrency {
                if let id = iterator.next() {
                    group.addTask {
                        await self.processPhoto(id: id)
                    }
                }
            }

            // Process results and add new tasks
            for try await result in group {
                guard !isCancelled else {
                    group.cancelAll()
                    throw ProcessingError.cancelled
                }

                results.append(result)
                completed += 1

                await progress(
                    Double(completed) / Double(total),
                    "Processing \(completed)/\(total)"
                )

                // Add next task
                if let nextId = iterator.next() {
                    group.addTask {
                        await self.processPhoto(id: nextId)
                    }
                }
            }
        }

        return results
    }

    // MARK: - Process Single Photo

    private func processPhoto(id: String) async -> ProcessingResult {
        var result = ProcessingResult(
            photoId: id,
            isUtility: false,
            fileSize: 0,
            pixelWidth: 0,
            pixelHeight: 0
        )

        do {
            // Get asset
            guard let asset = await PhotoLibraryService.shared.fetchAsset(identifier: id) else {
                result.error = ProcessingError.assetNotFound
                print("⚠️ Asset not found: \(id)")
                return result
            }

            // Get asset metadata
            let assetInfo = await PhotoLibraryService.shared.getAssetInfo(asset)
            result.fileSize = assetInfo.fileSize
            result.pixelWidth = Int(assetInfo.dimensions.width)
            result.pixelHeight = Int(assetInfo.dimensions.height)
            result.creationDate = assetInfo.creationDate
            result.fileName = assetInfo.fileName

            // Load image
            let targetSize = AppConfig.Processing.analysisImageSize
            guard let cgImage = await PhotoLibraryService.shared.loadCGImage(
                for: asset,
                targetSize: targetSize
            ) else {
                result.error = ProcessingError.imageLoadFailed
                print("⚠️ Image load failed: \(id) - may be iCloud only or corrupted")
                return result
            }

            // Run analysis
            let analysisResult = try await ImageAnalysisService.shared.analyzeImage(cgImage)

            // Store results
            if let featurePrint = analysisResult.featurePrint {
                result.featurePrintData = try? NSKeyedArchiver.archivedData(
                    withRootObject: featurePrint,
                    requiringSecureCoding: true
                )
            }

            result.perceptualHash = await PerceptualHash.compute(cgImage)
            result.aestheticScore = analysisResult.aestheticScore
            result.isUtility = analysisResult.isUtility
            result.blurScore = analysisResult.blurScore
            result.exposureScore = analysisResult.exposureScore

        } catch {
            result.error = error
            print("⚠️ Analysis failed for \(id): \(error.localizedDescription)")
        }

        return result
    }

    // MARK: - Batch Analysis

    func analyzeForDuplicates(
        identifiers: [String],
        progress: @MainActor @Sendable (Double, String) -> Void
    ) async throws -> [(id: String, featurePrint: Data)] {
        isCancelled = false
        var results: [(id: String, featurePrint: Data)] = []

        let total = identifiers.count
        var completed = 0

        try await withThrowingTaskGroup(of: (String, Data?).self) { group in
            var iterator = identifiers.makeIterator()

            for _ in 0..<maxConcurrency {
                if let id = iterator.next() {
                    group.addTask {
                        await self.extractFeaturePrint(id: id)
                    }
                }
            }

            for try await (id, data) in group {
                guard !isCancelled else {
                    group.cancelAll()
                    throw ProcessingError.cancelled
                }

                if let data = data {
                    results.append((id, data))
                }

                completed += 1
                await progress(
                    Double(completed) / Double(total),
                    "Analyzing \(completed)/\(total)"
                )

                if let nextId = iterator.next() {
                    group.addTask {
                        await self.extractFeaturePrint(id: nextId)
                    }
                }
            }
        }

        return results
    }

    private func extractFeaturePrint(id: String) async -> (String, Data?) {
        guard let asset = await PhotoLibraryService.shared.fetchAsset(identifier: id),
              let cgImage = await PhotoLibraryService.shared.loadCGImage(
                for: asset,
                targetSize: AppConfig.Processing.analysisImageSize
              ) else {
            return (id, nil)
        }

        do {
            let featurePrint = try await ImageAnalysisService.shared.generateFeaturePrint(cgImage)
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: featurePrint,
                requiringSecureCoding: true
            )
            return (id, data)
        } catch {
            return (id, nil)
        }
    }

    // MARK: - Errors

    enum ProcessingError: Error, LocalizedError {
        case cancelled
        case assetNotFound
        case imageLoadFailed
        case analysiseFailed

        var errorDescription: String? {
            switch self {
            case .cancelled: return "Processing was cancelled"
            case .assetNotFound: return "Photo asset not found"
            case .imageLoadFailed: return "Failed to load image"
            case .analysiseFailed: return "Image analysis failed"
            }
        }
    }
}
