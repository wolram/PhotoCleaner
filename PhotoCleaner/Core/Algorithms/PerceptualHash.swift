import Foundation
import CoreImage
import Accelerate

enum PerceptualHash {
    private static let hashSize = 8  // 8x8 = 64 bits
    private static let dctSize = 32  // DCT computed on 32x32 image

    // MARK: - Compute Hash

    static func compute(_ cgImage: CGImage) async -> UInt64 {
        // 1. Resize to 32x32
        guard let resized = resize(cgImage, to: CGSize(width: dctSize, height: dctSize)) else {
            return 0
        }

        // 2. Convert to grayscale
        let grayscale = toGrayscale(resized)

        // 3. Compute DCT
        let dct = computeDCT(grayscale)

        // 4. Extract top-left 8x8 (excluding DC component)
        let lowFreq = extractLowFrequency(dct)

        // 5. Compute median
        let median = computeMedian(lowFreq)

        // 6. Generate hash
        return generateHash(lowFreq, median: median)
    }

    // MARK: - Resize

    private static func resize(_ image: CGImage, to size: CGSize) -> CGImage? {
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(size.width) * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        context?.interpolationQuality = .medium
        context?.draw(image, in: CGRect(origin: .zero, size: size))

        return context?.makeImage()
    }

    // MARK: - Grayscale

    private static func toGrayscale(_ image: CGImage) -> [Float] {
        let width = image.width
        let height = image.height
        let count = width * height

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return [Float](repeating: 0, count: count)
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else {
            return [Float](repeating: 0, count: count)
        }

        let pixels = data.bindMemory(to: UInt8.self, capacity: count * 4)
        var grayscale = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let offset = i * 4
            let r = Float(pixels[offset]) / 255.0
            let g = Float(pixels[offset + 1]) / 255.0
            let b = Float(pixels[offset + 2]) / 255.0
            grayscale[i] = 0.299 * r + 0.587 * g + 0.114 * b
        }

        return grayscale
    }

    // MARK: - DCT (Discrete Cosine Transform)

    private static func computeDCT(_ pixels: [Float]) -> [Float] {
        let n = dctSize
        guard pixels.count == n * n else { return pixels }

        var result = [Float](repeating: 0, count: n * n)

        // Simple 2D DCT implementation
        for u in 0..<n {
            for v in 0..<n {
                var sum: Float = 0

                for x in 0..<n {
                    for y in 0..<n {
                        let pixel = pixels[y * n + x]
                        let cosX = cos(Float.pi * Float(2 * x + 1) * Float(u) / Float(2 * n))
                        let cosY = cos(Float.pi * Float(2 * y + 1) * Float(v) / Float(2 * n))
                        sum += pixel * cosX * cosY
                    }
                }

                let cu: Float = u == 0 ? 1.0 / sqrt(2.0) : 1.0
                let cv: Float = v == 0 ? 1.0 / sqrt(2.0) : 1.0

                result[v * n + u] = 0.25 * cu * cv * sum
            }
        }

        return result
    }

    // MARK: - Extract Low Frequency

    private static func extractLowFrequency(_ dct: [Float]) -> [Float] {
        var lowFreq = [Float](repeating: 0, count: hashSize * hashSize - 1)
        var index = 0

        // Extract top-left 8x8, excluding (0,0) DC component
        for y in 0..<hashSize {
            for x in 0..<hashSize {
                if x == 0 && y == 0 { continue }
                if index < lowFreq.count {
                    lowFreq[index] = dct[y * dctSize + x]
                    index += 1
                }
            }
        }

        return lowFreq
    }

    // MARK: - Compute Median

    private static func computeMedian(_ values: [Float]) -> Float {
        let sorted = values.sorted()
        let count = sorted.count

        if count == 0 { return 0 }
        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2
        } else {
            return sorted[count / 2]
        }
    }

    // MARK: - Generate Hash

    private static func generateHash(_ values: [Float], median: Float) -> UInt64 {
        var hash: UInt64 = 0

        for (index, value) in values.prefix(64).enumerated() {
            if value > median {
                hash |= (1 << index)
            }
        }

        return hash
    }

    // MARK: - Compare Hashes

    static func hammingDistance(_ hash1: UInt64, _ hash2: UInt64) -> Int {
        return (hash1 ^ hash2).nonzeroBitCount
    }

    static func similarity(_ hash1: UInt64, _ hash2: UInt64) -> Float {
        let distance = hammingDistance(hash1, hash2)
        return 1.0 - (Float(distance) / 64.0)
    }

    static func areSimilar(_ hash1: UInt64, _ hash2: UInt64, threshold: Int = 8) -> Bool {
        return hammingDistance(hash1, hash2) <= threshold
    }
}

// MARK: - Average Hash (faster alternative)

extension PerceptualHash {
    static func computeAverageHash(_ cgImage: CGImage) async -> UInt64 {
        // 1. Resize to 8x8
        guard let resized = resize(cgImage, to: CGSize(width: 8, height: 8)) else {
            return 0
        }

        // 2. Convert to grayscale
        let grayscale = toGrayscale(resized)

        // 3. Compute average
        let average = grayscale.reduce(0, +) / Float(grayscale.count)

        // 4. Generate hash
        var hash: UInt64 = 0
        for (index, value) in grayscale.prefix(64).enumerated() {
            if value > average {
                hash |= (1 << index)
            }
        }

        return hash
    }
}

// MARK: - Difference Hash (another alternative)

extension PerceptualHash {
    static func computeDifferenceHash(_ cgImage: CGImage) async -> UInt64 {
        // 1. Resize to 9x8
        guard let resized = resize(cgImage, to: CGSize(width: 9, height: 8)) else {
            return 0
        }

        // 2. Convert to grayscale
        let grayscale = toGrayscale(resized)

        // 3. Compute differences
        var hash: UInt64 = 0
        var bitIndex = 0

        for y in 0..<8 {
            for x in 0..<8 {
                let left = grayscale[y * 9 + x]
                let right = grayscale[y * 9 + x + 1]

                if left > right {
                    hash |= (1 << bitIndex)
                }
                bitIndex += 1
            }
        }

        return hash
    }
}
