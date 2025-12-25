import SwiftData
import Foundation

@Model
final class PhotoAssetEntity {
    @Attribute(.unique) var localIdentifier: String
    var creationDate: Date?
    var modificationDate: Date?
    var pixelWidth: Int
    var pixelHeight: Int
    var fileSize: Int64
    var fileName: String?
    var fileExtension: String?

    // Vision analysis results
    var featurePrintData: Data?
    var perceptualHash: UInt64?
    var aestheticScore: Float?
    var isUtility: Bool
    var blurScore: Float?
    var exposureScore: Float?

    // CLIP embedding (stored as Data for efficiency)
    var embeddingData: Data?

    // Categories (top 3 with scores)
    var primaryCategory: String?
    var primaryCategoryScore: Float?
    var secondaryCategory: String?
    var secondaryCategoryScore: Float?
    var tertiaryCategory: String?
    var tertiaryCategoryScore: Float?

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \PhotoGroupEntity.photos)
    var group: PhotoGroupEntity?

    var lastAnalyzedAt: Date?
    var analysisVersion: Int

    init(
        localIdentifier: String,
        pixelWidth: Int = 0,
        pixelHeight: Int = 0,
        fileSize: Int64 = 0
    ) {
        self.localIdentifier = localIdentifier
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.fileSize = fileSize
        self.isUtility = false
        self.analysisVersion = 1
    }

    var compositeQualityScore: Float {
        guard !isUtility else { return -1 }

        var score: Float = 0
        var weightSum: Float = 0

        if let aesthetic = aestheticScore {
            score += ((aesthetic + 1) / 2) * 0.5
            weightSum += 0.5
        }

        if let blur = blurScore {
            score += blur * 0.3
            weightSum += 0.3
        }

        if let exposure = exposureScore {
            let exposureQuality = 1 - abs(exposure - 0.5) * 2
            score += exposureQuality * 0.2
            weightSum += 0.2
        }

        return weightSum > 0 ? score / weightSum : 0
    }

    var embedding: [Float]? {
        get {
            guard let data = embeddingData else { return nil }
            return data.withUnsafeBytes { buffer in
                Array(buffer.bindMemory(to: Float.self))
            }
        }
        set {
            guard let newValue = newValue else {
                embeddingData = nil
                return
            }
            embeddingData = newValue.withUnsafeBytes { Data($0) }
        }
    }

    var categories: [(String, Float)] {
        var result: [(String, Float)] = []
        if let cat = primaryCategory, let score = primaryCategoryScore {
            result.append((cat, score))
        }
        if let cat = secondaryCategory, let score = secondaryCategoryScore {
            result.append((cat, score))
        }
        if let cat = tertiaryCategory, let score = tertiaryCategoryScore {
            result.append((cat, score))
        }
        return result
    }

    func setCategories(_ categories: [(String, Float)]) {
        let sorted = categories.sorted { $0.1 > $1.1 }
        if sorted.count > 0 {
            primaryCategory = sorted[0].0
            primaryCategoryScore = sorted[0].1
        }
        if sorted.count > 1 {
            secondaryCategory = sorted[1].0
            secondaryCategoryScore = sorted[1].1
        }
        if sorted.count > 2 {
            tertiaryCategory = sorted[2].0
            tertiaryCategoryScore = sorted[2].1
        }
    }
}
