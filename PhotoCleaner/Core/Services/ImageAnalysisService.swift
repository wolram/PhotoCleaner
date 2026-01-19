import Vision
import CoreImage

actor ImageAnalysisService {
    static let shared = ImageAnalysisService()

    private let context = CIContext()

    private init() {}

    // MARK: - Complete Analysis

    struct AnalysisResult {
        let featurePrint: VNFeaturePrintObservation?
        let aestheticScore: Float?
        let isUtility: Bool
        let blurScore: Float
        let exposureScore: Float
    }

    func analyzeImage(_ cgImage: CGImage) async throws -> AnalysisResult {
        async let featurePrint = generateFeaturePrint(cgImage)
        async let aesthetics = analyzeAesthetics(cgImage)
        async let blur = analyzeBlur(cgImage)
        async let exposure = analyzeExposure(cgImage)

        let (fp, aes, blurScore, exposureScore) = await (
            try? featurePrint,
            try? aesthetics,
            blur,
            exposure
        )

        return AnalysisResult(
            featurePrint: fp,
            aestheticScore: aes?.score,
            isUtility: aes?.isUtility ?? false,
            blurScore: blurScore,
            exposureScore: exposureScore
        )
    }

    // MARK: - Feature Print (for duplicate detection)

    func generateFeaturePrint(_ cgImage: CGImage) async throws -> VNFeaturePrintObservation {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNGenerateImageFeaturePrintRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observation = request.results?.first as? VNFeaturePrintObservation else {
                    continuation.resume(throwing: AnalysisError.noResults)
                    return
                }

                continuation.resume(returning: observation)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func computeDistance(_ fp1: VNFeaturePrintObservation, _ fp2: VNFeaturePrintObservation) throws -> Float {
        var distance: Float = 0
        try fp1.computeDistance(&distance, to: fp2)
        return distance
    }

    // MARK: - Aesthetics Analysis

    struct AestheticsResult {
        let score: Float
        let isUtility: Bool
    }

    func analyzeAesthetics(_ cgImage: CGImage) async throws -> AestheticsResult {
        // Using Vision's CalculateImageAestheticsScoresRequest (macOS 15+)
        if #available(macOS 15.0, *) {
            return try await analyzeAestheticsModern(cgImage)
        } else {
            // Fallback for older macOS
            return try await analyzeAestheticsLegacy(cgImage)
        }
    }

    @available(macOS 15.0, *)
    private func analyzeAestheticsModern(_ cgImage: CGImage) async throws -> AestheticsResult {
        let request = CalculateImageAestheticsScoresRequest()
        let result = try await request.perform(on: cgImage)

        return AestheticsResult(
            score: result.overallScore,
            isUtility: result.isUtility
        )
    }

    private func analyzeAestheticsLegacy(_ cgImage: CGImage) async throws -> AestheticsResult {
        // Simple heuristic based on image properties
        let width = cgImage.width
        let height = cgImage.height
        let aspectRatio = Float(width) / Float(height)

        // Prefer standard aspect ratios
        let standardRatios: [Float] = [1.0, 4/3, 3/2, 16/9]
        let ratioScore = standardRatios.map { abs($0 - aspectRatio) }.min() ?? 1.0
        let normalizedRatioScore = max(0, 1 - ratioScore)

        // Prefer higher resolution
        let megapixels = Float(width * height) / 1_000_000
        let resolutionScore = min(megapixels / 12.0, 1.0)

        let score = (normalizedRatioScore + resolutionScore) / 2 * 2 - 1 // Scale to -1 to 1

        return AestheticsResult(score: score, isUtility: false)
    }

    // MARK: - Blur Detection

    func analyzeBlur(_ cgImage: CGImage) async -> Float {
        let ciImage = CIImage(cgImage: cgImage)

        // Resize for faster processing
        let scale = min(512.0 / CGFloat(cgImage.width), 512.0 / CGFloat(cgImage.height))
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Apply Laplacian filter to detect edges
        guard let laplacianFilter = CIFilter(name: "CIConvolution3X3") else {
            return 0.5
        }

        // Laplacian kernel for edge detection
        let laplacianKernel = CIVector(values: [0, 1, 0, 1, -4, 1, 0, 1, 0], count: 9)
        laplacianFilter.setValue(scaledImage, forKey: kCIInputImageKey)
        laplacianFilter.setValue(laplacianKernel, forKey: "inputWeights")

        guard let outputImage = laplacianFilter.outputImage else {
            return 0.5
        }

        // Calculate variance of the Laplacian
        let extent = outputImage.extent
        guard extent.width > 0 && extent.height > 0 else { return 0.5 }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: extent.midX, y: extent.midY, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        // Higher variance = sharper image
        let variance = Float(bitmap[0]) / 255.0
        return min(variance * 4, 1.0) // Normalize to 0-1
    }

    // MARK: - Exposure Analysis

    func analyzeExposure(_ cgImage: CGImage) async -> Float {
        let ciImage = CIImage(cgImage: cgImage)

        // Get average luminance
        guard let filter = CIFilter(name: "CIAreaAverage") else {
            return 0.5
        }

        let extent = ciImage.extent
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")

        guard let outputImage = filter.outputImage else {
            return 0.5
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        // Calculate luminance from RGB
        let r = Float(bitmap[0]) / 255.0
        let g = Float(bitmap[1]) / 255.0
        let b = Float(bitmap[2]) / 255.0

        // Standard luminance formula
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b

        return luminance
    }

    // MARK: - Errors

    enum AnalysisError: Error, LocalizedError {
        case noResults
        case invalidImage
        case processingFailed

        var errorDescription: String? {
            switch self {
            case .noResults: return "No analysis results returned"
            case .invalidImage: return "Invalid image data"
            case .processingFailed: return "Image processing failed"
            }
        }
    }
}

