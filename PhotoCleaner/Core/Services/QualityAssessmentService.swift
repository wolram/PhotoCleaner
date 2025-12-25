import Vision
import CoreImage
import AppKit

actor QualityAssessmentService {
    static let shared = QualityAssessmentService()

    private let context = CIContext()
    private var qualityThreshold: Float = 0.3

    private init() {}

    func setThreshold(_ value: Float) {
        qualityThreshold = max(0.0, min(1.0, value))
    }

    // MARK: - Full Quality Assessment

    func assessQuality(_ cgImage: CGImage) async -> QualityScore {
        async let aesthetics = analyzeAesthetics(cgImage)
        async let blur = analyzeBlur(cgImage)
        async let exposure = analyzeExposure(cgImage)

        let (aesResult, blurScore, exposureScore) = await (aesthetics, blur, exposure)

        return QualityScore(
            aestheticScore: aesResult.score,
            isUtility: aesResult.isUtility,
            blurScore: blurScore,
            exposureScore: exposureScore
        )
    }

    // MARK: - Aesthetics

    struct AestheticsResult {
        let score: Float
        let isUtility: Bool
    }

    func analyzeAesthetics(_ cgImage: CGImage) async -> AestheticsResult {
        if #available(macOS 15.0, *) {
            do {
                let request = CalculateImageAestheticsScoresRequest()
                let result = try await request.perform(on: cgImage)
                return AestheticsResult(score: result.overallScore, isUtility: result.isUtility)
            } catch {
                return estimateAesthetics(cgImage)
            }
        } else {
            return estimateAesthetics(cgImage)
        }
    }

    private func estimateAesthetics(_ cgImage: CGImage) -> AestheticsResult {
        // Heuristic-based estimation for older macOS
        let width = cgImage.width
        let height = cgImage.height

        // Resolution score
        let megapixels = Float(width * height) / 1_000_000
        let resScore = min(megapixels / 12.0, 1.0)

        // Aspect ratio score (prefer common ratios)
        let ratio = Float(width) / Float(height)
        let commonRatios: [Float] = [1.0, 4/3, 3/2, 16/9, 9/16, 3/4, 2/3]
        let ratioScore = 1.0 - (commonRatios.map { abs($0 - ratio) }.min() ?? 0.5)

        let score = (resScore * 0.4 + ratioScore * 0.6) * 2 - 1

        return AestheticsResult(score: score, isUtility: false)
    }

    // MARK: - Blur Detection

    func analyzeBlur(_ cgImage: CGImage) async -> Float {
        let ciImage = CIImage(cgImage: cgImage)

        // Resize for faster processing
        let maxDim: CGFloat = 512
        let scale = min(maxDim / CGFloat(cgImage.width), maxDim / CGFloat(cgImage.height), 1.0)
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Convert to grayscale
        guard let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono") else {
            return 0.5
        }
        grayscaleFilter.setValue(scaledImage, forKey: kCIInputImageKey)

        guard let grayImage = grayscaleFilter.outputImage else {
            return 0.5
        }

        // Apply Sobel edge detection
        let sobelKernelH: [CGFloat] = [-1, 0, 1, -2, 0, 2, -1, 0, 1]
        let sobelKernelV: [CGFloat] = [-1, -2, -1, 0, 0, 0, 1, 2, 1]

        guard let sobelH = CIFilter(name: "CIConvolution3X3"),
              let sobelV = CIFilter(name: "CIConvolution3X3") else {
            return 0.5
        }

        sobelH.setValue(grayImage, forKey: kCIInputImageKey)
        sobelH.setValue(CIVector(values: sobelKernelH, count: 9), forKey: "inputWeights")

        sobelV.setValue(grayImage, forKey: kCIInputImageKey)
        sobelV.setValue(CIVector(values: sobelKernelV, count: 9), forKey: "inputWeights")

        guard let edgeH = sobelH.outputImage,
              let edgeV = sobelV.outputImage else {
            return 0.5
        }

        // Combine edges and calculate variance
        let combinedEdges = edgeH.composited(over: edgeV)

        // Get statistics
        guard let statsFilter = CIFilter(name: "CIAreaMaximum") else {
            return 0.5
        }

        let extent = combinedEdges.extent
        statsFilter.setValue(combinedEdges, forKey: kCIInputImageKey)
        statsFilter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")

        guard let statsOutput = statsFilter.outputImage else {
            return 0.5
        }

        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(
            statsOutput,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        // Higher edge intensity = sharper image
        let maxEdge = Float(max(pixel[0], pixel[1], pixel[2])) / 255.0
        return min(maxEdge * 2, 1.0)
    }

    // MARK: - Exposure Analysis

    func analyzeExposure(_ cgImage: CGImage) async -> Float {
        let ciImage = CIImage(cgImage: cgImage)

        guard let histogramFilter = CIFilter(name: "CIAreaHistogram") else {
            return 0.5
        }

        let extent = ciImage.extent
        histogramFilter.setValue(ciImage, forKey: kCIInputImageKey)
        histogramFilter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        histogramFilter.setValue(256, forKey: "inputCount")

        guard let histogramData = histogramFilter.outputImage else {
            // Fallback to average luminance
            return await calculateAverageLuminance(ciImage)
        }

        // Analyze histogram distribution
        var pixels = [UInt8](repeating: 0, count: 256 * 4)
        context.render(
            histogramData,
            toBitmap: &pixels,
            rowBytes: 256 * 4,
            bounds: CGRect(x: 0, y: 0, width: 256, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        // Calculate weighted average (luminance channel)
        var totalWeight: Float = 0
        var weightedSum: Float = 0

        for i in 0..<256 {
            let value = Float(pixels[i * 4]) // Red channel of histogram
            totalWeight += value
            weightedSum += Float(i) * value
        }

        guard totalWeight > 0 else { return 0.5 }

        let averageBrightness = weightedSum / totalWeight / 255.0
        return averageBrightness
    }

    private func calculateAverageLuminance(_ ciImage: CIImage) async -> Float {
        guard let avgFilter = CIFilter(name: "CIAreaAverage") else {
            return 0.5
        }

        avgFilter.setValue(ciImage, forKey: kCIInputImageKey)
        avgFilter.setValue(CIVector(cgRect: ciImage.extent), forKey: "inputExtent")

        guard let avgOutput = avgFilter.outputImage else {
            return 0.5
        }

        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(
            avgOutput,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        let r = Float(pixel[0]) / 255.0
        let g = Float(pixel[1]) / 255.0
        let b = Float(pixel[2]) / 255.0

        return 0.299 * r + 0.587 * g + 0.114 * b
    }

    // MARK: - Find Low Quality Photos

    func findLowQualityPhotos(
        scores: [(id: String, score: QualityScore)],
        progress: (@Sendable (Double) -> Void)? = nil
    ) async -> [String] {
        var lowQuality: [String] = []
        let total = scores.count

        for (index, item) in scores.enumerated() {
            if item.score.composite < qualityThreshold || item.score.isUtility {
                lowQuality.append(item.id)
            }
            progress?(Double(index + 1) / Double(total))
        }

        return lowQuality
    }

    // MARK: - Categorize by Quality

    func categorizeByQuality(
        scores: [(id: String, score: QualityScore)]
    ) -> [QualityScore.Grade: [String]] {
        var categories: [QualityScore.Grade: [String]] = [:]

        for item in scores {
            let grade = item.score.grade
            categories[grade, default: []].append(item.id)
        }

        return categories
    }
}
