import AppKit
import CoreImage

final class ImageProcessor: Sendable {
    static let shared = ImageProcessor()

    private let context: CIContext

    private init() {
        context = CIContext(options: [
            .useSoftwareRenderer: false,
            .highQualityDownsample: true
        ])
    }

    // MARK: - Resize

    func resize(_ image: NSImage, to size: CGSize) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        return resize(cgImage, to: size).flatMap { NSImage(cgImage: $0, size: size) }
    }

    func resize(_ cgImage: CGImage, to size: CGSize) -> CGImage? {
        let ciImage = CIImage(cgImage: cgImage)

        let scaleX = size.width / CGFloat(cgImage.width)
        let scaleY = size.height / CGFloat(cgImage.height)
        let scale = min(scaleX, scaleY)

        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        return context.createCGImage(scaledImage, from: scaledImage.extent)
    }

    func resizeToFit(_ cgImage: CGImage, maxDimension: CGFloat) -> CGImage? {
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        guard width > maxDimension || height > maxDimension else {
            return cgImage
        }

        let scale = maxDimension / max(width, height)
        let newSize = CGSize(width: width * scale, height: height * scale)

        return resize(cgImage, to: newSize)
    }

    // MARK: - Thumbnail

    func generateThumbnail(_ cgImage: CGImage, size: CGSize) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]

        guard let data = cgImage.dataProvider?.data,
              let source = CGImageSourceCreateWithData(data, nil) else {
            return resize(cgImage, to: size)
        }

        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    // MARK: - Color Space Conversion

    func convertToSRGB(_ cgImage: CGImage) -> CGImage? {
        let ciImage = CIImage(cgImage: cgImage)

        guard let srgbSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return cgImage
        }

        return context.createCGImage(ciImage, from: ciImage.extent, format: .RGBA8, colorSpace: srgbSpace)
    }

    // MARK: - Grayscale

    func convertToGrayscale(_ cgImage: CGImage) -> CGImage? {
        let ciImage = CIImage(cgImage: cgImage)

        guard let filter = CIFilter(name: "CIPhotoEffectMono") else {
            return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputImage = filter.outputImage else {
            return nil
        }

        return context.createCGImage(outputImage, from: outputImage.extent)
    }

    // MARK: - Histogram

    func calculateHistogram(_ cgImage: CGImage) -> [Int] {
        let ciImage = CIImage(cgImage: cgImage)

        guard let histogramFilter = CIFilter(name: "CIAreaHistogram") else {
            return []
        }

        let extent = ciImage.extent
        histogramFilter.setValue(ciImage, forKey: kCIInputImageKey)
        histogramFilter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        histogramFilter.setValue(256, forKey: "inputCount")

        guard let histogramImage = histogramFilter.outputImage else {
            return []
        }

        var histogram = [UInt8](repeating: 0, count: 256 * 4)
        context.render(
            histogramImage,
            toBitmap: &histogram,
            rowBytes: 256 * 4,
            bounds: CGRect(x: 0, y: 0, width: 256, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        // Return luminance histogram
        return (0..<256).map { i in
            Int(histogram[i * 4])
        }
    }

    // MARK: - Image Statistics

    struct ImageStats {
        let averageBrightness: Float
        let contrast: Float
        let saturation: Float
    }

    func calculateStats(_ cgImage: CGImage) -> ImageStats {
        let ciImage = CIImage(cgImage: cgImage)

        // Average color
        guard let avgFilter = CIFilter(name: "CIAreaAverage") else {
            return ImageStats(averageBrightness: 0.5, contrast: 0.5, saturation: 0.5)
        }

        let extent = ciImage.extent
        avgFilter.setValue(ciImage, forKey: kCIInputImageKey)
        avgFilter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")

        guard let avgOutput = avgFilter.outputImage else {
            return ImageStats(averageBrightness: 0.5, contrast: 0.5, saturation: 0.5)
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

        // Calculate brightness (luminance)
        let brightness = 0.299 * r + 0.587 * g + 0.114 * b

        // Calculate saturation
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let saturation = maxC > 0 ? (maxC - minC) / maxC : 0

        // Estimate contrast from histogram spread
        let histogram = calculateHistogram(cgImage)
        let contrast = estimateContrast(from: histogram)

        return ImageStats(
            averageBrightness: brightness,
            contrast: contrast,
            saturation: saturation
        )
    }

    private func estimateContrast(from histogram: [Int]) -> Float {
        guard !histogram.isEmpty else { return 0.5 }

        let total = histogram.reduce(0, +)
        guard total > 0 else { return 0.5 }

        // Find 5th and 95th percentile
        var cumulative = 0
        var low = 0
        var high = 255

        for (i, count) in histogram.enumerated() {
            cumulative += count
            if cumulative < total / 20 {
                low = i
            }
            if cumulative < total * 19 / 20 {
                high = i
            }
        }

        // Contrast is the spread of the histogram
        return Float(high - low) / 255.0
    }

    // MARK: - Comparison

    func visualDifference(_ image1: CGImage, _ image2: CGImage) -> Float {
        // Resize both to same size
        let size = CGSize(width: 64, height: 64)

        guard let resized1 = resize(image1, to: size),
              let resized2 = resize(image2, to: size) else {
            return 1.0
        }

        let ci1 = CIImage(cgImage: resized1)
        let ci2 = CIImage(cgImage: resized2)

        guard let diffFilter = CIFilter(name: "CIDifferenceBlendMode") else {
            return 1.0
        }

        diffFilter.setValue(ci1, forKey: kCIInputImageKey)
        diffFilter.setValue(ci2, forKey: kCIInputBackgroundImageKey)

        guard let diffImage = diffFilter.outputImage else {
            return 1.0
        }

        // Get average of difference
        guard let avgFilter = CIFilter(name: "CIAreaAverage") else {
            return 1.0
        }

        avgFilter.setValue(diffImage, forKey: kCIInputImageKey)
        avgFilter.setValue(CIVector(cgRect: diffImage.extent), forKey: "inputExtent")

        guard let avgOutput = avgFilter.outputImage else {
            return 1.0
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

        let avgDiff = (Float(pixel[0]) + Float(pixel[1]) + Float(pixel[2])) / (3 * 255)
        return avgDiff
    }
}
