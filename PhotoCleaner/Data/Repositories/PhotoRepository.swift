import SwiftData
import Foundation

@MainActor
final class PhotoRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    func fetchOrCreate(localIdentifier: String) -> PhotoAssetEntity {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.localIdentifier == localIdentifier }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let new = PhotoAssetEntity(localIdentifier: localIdentifier)
        modelContext.insert(new)
        return new
    }

    func fetch(localIdentifier: String) -> PhotoAssetEntity? {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.localIdentifier == localIdentifier }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func fetchAll() -> [PhotoAssetEntity] {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchUnanalyzed(limit: Int = 100) -> [PhotoAssetEntity] {
        var descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.lastAnalyzedAt == nil },
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func delete(_ entity: PhotoAssetEntity) {
        modelContext.delete(entity)
    }

    func delete(localIdentifiers: [String]) {
        for id in localIdentifiers {
            if let entity = fetch(localIdentifier: id) {
                modelContext.delete(entity)
            }
        }
    }

    func save() throws {
        try modelContext.save()
    }

    // MARK: - Batch Operations

    func updateAnalysisResults(
        localIdentifier: String,
        featurePrintData: Data?,
        perceptualHash: UInt64?,
        aestheticScore: Float?,
        isUtility: Bool,
        blurScore: Float?,
        exposureScore: Float?
    ) {
        let entity = fetchOrCreate(localIdentifier: localIdentifier)
        entity.featurePrintData = featurePrintData
        entity.perceptualHash = perceptualHash
        entity.aestheticScore = aestheticScore
        entity.isUtility = isUtility
        entity.blurScore = blurScore
        entity.exposureScore = exposureScore
        entity.lastAnalyzedAt = Date()
    }

    func updateCategories(
        localIdentifier: String,
        categories: [(String, Float)]
    ) {
        let entity = fetchOrCreate(localIdentifier: localIdentifier)
        entity.setCategories(categories)
    }

    func updateEmbedding(
        localIdentifier: String,
        embedding: [Float]
    ) {
        let entity = fetchOrCreate(localIdentifier: localIdentifier)
        entity.embedding = embedding
    }

    // MARK: - Queries

    func fetchWithFeaturePrint() -> [PhotoAssetEntity] {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.featurePrintData != nil }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchWithPerceptualHash() -> [PhotoAssetEntity] {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.perceptualHash != nil }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchByCategory(_ category: String) -> [PhotoAssetEntity] {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.primaryCategory == category },
            sortBy: [SortDescriptor(\.primaryCategoryScore, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchLowQuality(threshold: Float = 0.3) -> [PhotoAssetEntity] {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { entity in
                entity.aestheticScore != nil
            },
            sortBy: [SortDescriptor(\.aestheticScore, order: .forward)]
        )

        let all = (try? modelContext.fetch(descriptor)) ?? []
        return all.filter { $0.compositeQualityScore < threshold }
    }

    func fetchBlurry(threshold: Float = 0.4) -> [PhotoAssetEntity] {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { entity in
                entity.blurScore != nil
            }
        )

        let all = (try? modelContext.fetch(descriptor)) ?? []
        return all.filter { ($0.blurScore ?? 1) < threshold }
    }

    func fetchUtility() -> [PhotoAssetEntity] {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.isUtility == true }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Statistics

    func count() -> Int {
        let descriptor = FetchDescriptor<PhotoAssetEntity>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    func analyzedCount() -> Int {
        let descriptor = FetchDescriptor<PhotoAssetEntity>(
            predicate: #Predicate { $0.lastAnalyzedAt != nil }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    func totalSize() -> Int64 {
        fetchAll().reduce(0) { $0 + $1.fileSize }
    }

    func categoryDistribution() -> [String: Int] {
        var distribution: [String: Int] = [:]

        for entity in fetchAll() {
            if let category = entity.primaryCategory {
                distribution[category, default: 0] += 1
            }
        }

        return distribution
    }

    func qualityDistribution() -> [QualityScore.Grade: Int] {
        var distribution: [QualityScore.Grade: Int] = [:]

        for entity in fetchAll() {
            let grade: QualityScore.Grade
            if entity.isUtility {
                grade = .utility
            } else {
                let composite = entity.compositeQualityScore
                switch composite {
                case 0.8...1.0: grade = .excellent
                case 0.6..<0.8: grade = .good
                case 0.4..<0.6: grade = .average
                case 0.2..<0.4: grade = .poor
                default: grade = .bad
                }
            }
            distribution[grade, default: 0] += 1
        }

        return distribution
    }
}
