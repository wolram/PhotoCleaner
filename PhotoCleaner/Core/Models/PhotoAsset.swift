import Foundation
import Vision
#if canImport(AppKit)
import AppKit
#endif

struct PhotoAsset: Identifiable, Hashable {
    let id: String // PHAsset.localIdentifier
    let creationDate: Date?
    let modificationDate: Date?
    let dimensions: CGSize
    let fileSize: Int64
    let fileName: String?

    #if canImport(AppKit)
    var thumbnail: NSImage?
    var fullImage: NSImage?
    #endif

    // Analysis results
    var featurePrint: VNFeaturePrintObservation?
    var perceptualHash: UInt64?
    var qualityScore: QualityScore?
    var embedding: [Float]?
    var categories: [(String, Float)]?

    var isAnalyzed: Bool {
        featurePrint != nil || perceptualHash != nil
    }

    init(
        id: String,
        creationDate: Date? = nil,
        modificationDate: Date? = nil,
        dimensions: CGSize = .zero,
        fileSize: Int64 = 0,
        fileName: String? = nil
    ) {
        self.id = id
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.dimensions = dimensions
        self.fileSize = fileSize
        self.fileName = fileName
    }

    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var formattedDimensions: String {
        "\(Int(dimensions.width)) × \(Int(dimensions.height))"
    }

    var aspectRatio: CGFloat {
        guard dimensions.height > 0 else { return 1 }
        return dimensions.width / dimensions.height
    }

    var megapixels: Double {
        (dimensions.width * dimensions.height) / 1_000_000
    }
}

extension PhotoAsset {
    init(from entity: PhotoAssetEntity) {
        self.id = entity.localIdentifier
        self.creationDate = entity.creationDate
        self.modificationDate = entity.modificationDate
        self.dimensions = CGSize(width: entity.pixelWidth, height: entity.pixelHeight)
        self.fileSize = entity.fileSize
        self.fileName = entity.fileName

        if let score = entity.aestheticScore {
            self.qualityScore = QualityScore(
                aestheticScore: score,
                isUtility: entity.isUtility,
                blurScore: entity.blurScore ?? 0.5,
                exposureScore: entity.exposureScore ?? 0.5
            )
        }

        self.perceptualHash = entity.perceptualHash
        self.embedding = entity.embedding
        self.categories = entity.categories
    }
}
