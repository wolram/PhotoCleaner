import Foundation

struct BestPhotoSelector {
    struct Weights {
        var quality: Float = 0.35
        var sharpness: Float = 0.25
        var resolution: Float = 0.15
        var recency: Float = 0.10
        var fileSize: Float = 0.10
        var aspectRatio: Float = 0.05

        static let `default` = Weights()

        static let qualityFocused = Weights(
            quality: 0.45,
            sharpness: 0.30,
            resolution: 0.10,
            recency: 0.05,
            fileSize: 0.05,
            aspectRatio: 0.05
        )

        static let resolutionFocused = Weights(
            quality: 0.20,
            sharpness: 0.20,
            resolution: 0.35,
            recency: 0.05,
            fileSize: 0.15,
            aspectRatio: 0.05
        )

        static let recentFocused = Weights(
            quality: 0.25,
            sharpness: 0.20,
            resolution: 0.10,
            recency: 0.35,
            fileSize: 0.05,
            aspectRatio: 0.05
        )
    }

    struct ScoredPhoto {
        let photo: PhotoAsset
        let totalScore: Float
        let breakdown: ScoreBreakdown
    }

    struct ScoreBreakdown {
        let quality: Float
        let sharpness: Float
        let resolution: Float
        let recency: Float
        let fileSize: Float
        let aspectRatio: Float
    }

    private let weights: Weights

    init(weights: Weights = .default) {
        self.weights = weights
    }

    // MARK: - Select Best

    func selectBest(from photos: [PhotoAsset]) -> PhotoAsset? {
        guard !photos.isEmpty else { return nil }
        return scorePhotos(photos).first?.photo
    }

    func selectBestId(from photos: [PhotoAsset]) -> String? {
        selectBest(from: photos)?.id
    }

    // MARK: - Score All Photos

    func scorePhotos(_ photos: [PhotoAsset]) -> [ScoredPhoto] {
        guard !photos.isEmpty else { return [] }

        // Calculate normalization values
        let maxResolution = photos.map { $0.dimensions.width * $0.dimensions.height }.max() ?? 1
        let maxFileSize = photos.map { $0.fileSize }.max() ?? 1
        let dates = photos.compactMap { $0.creationDate }
        let dateRange = (dates.min(), dates.max())

        return photos.map { photo in
            let breakdown = calculateBreakdown(
                photo: photo,
                maxResolution: maxResolution,
                maxFileSize: maxFileSize,
                dateRange: dateRange
            )

            let totalScore =
                breakdown.quality * weights.quality +
                breakdown.sharpness * weights.sharpness +
                breakdown.resolution * weights.resolution +
                breakdown.recency * weights.recency +
                breakdown.fileSize * weights.fileSize +
                breakdown.aspectRatio * weights.aspectRatio

            return ScoredPhoto(photo: photo, totalScore: totalScore, breakdown: breakdown)
        }
        .sorted { $0.totalScore > $1.totalScore }
    }

    // MARK: - Calculate Individual Scores

    private func calculateBreakdown(
        photo: PhotoAsset,
        maxResolution: CGFloat,
        maxFileSize: Int64,
        dateRange: (Date?, Date?)
    ) -> ScoreBreakdown {

        // Quality score (from aesthetics)
        let quality: Float
        if let qs = photo.qualityScore {
            quality = qs.isUtility ? 0 : (qs.composite + 1) / 2
        } else {
            quality = 0.5
        }

        // Sharpness (blur score)
        let sharpness = photo.qualityScore?.blurScore ?? 0.5

        // Resolution (normalized)
        let resolution = maxResolution > 0
            ? Float(photo.dimensions.width * photo.dimensions.height / maxResolution)
            : 0.5

        // Recency (newer is better)
        let recency: Float
        if let date = photo.creationDate,
           let minDate = dateRange.0,
           let maxDate = dateRange.1,
           maxDate > minDate {
            let range = maxDate.timeIntervalSince(minDate)
            let position = date.timeIntervalSince(minDate)
            recency = Float(position / range)
        } else {
            recency = 0.5
        }

        // File size (larger often means better quality)
        let fileSize = maxFileSize > 0
            ? Float(photo.fileSize) / Float(maxFileSize)
            : 0.5

        // Aspect ratio (prefer common ratios)
        let aspectRatio = calculateAspectRatioScore(photo.dimensions)

        return ScoreBreakdown(
            quality: quality,
            sharpness: sharpness,
            resolution: resolution,
            recency: recency,
            fileSize: fileSize,
            aspectRatio: aspectRatio
        )
    }

    private func calculateAspectRatioScore(_ dimensions: CGSize) -> Float {
        guard dimensions.height > 0 else { return 0.5 }

        let ratio = Float(dimensions.width / dimensions.height)

        // Common aspect ratios
        let commonRatios: [Float] = [
            1.0,      // Square
            4.0/3.0,  // Standard
            3.0/2.0,  // 35mm film
            16.0/9.0, // Widescreen
            3.0/4.0,  // Portrait standard
            2.0/3.0,  // Portrait 35mm
            9.0/16.0  // Portrait widescreen
        ]

        let minDistance = commonRatios.map { abs($0 - ratio) }.min() ?? 1.0
        return max(0, 1 - minDistance)
    }

    // MARK: - Batch Selection

    func selectBestFromGroups(_ groups: [PhotoGroup]) -> [String: String] {
        var selections: [String: String] = [:]

        for group in groups {
            if let bestId = selectBestId(from: group.photos) {
                selections[group.id.uuidString] = bestId
            }
        }

        return selections
    }

    // MARK: - Auto-select for Deletion

    func selectForDeletion(from photos: [PhotoAsset], keep: Int = 1) -> [String] {
        guard photos.count > keep else { return [] }

        let scored = scorePhotos(photos)
        let toKeep = Set(scored.prefix(keep).map { $0.photo.id })

        return photos.filter { !toKeep.contains($0.id) }.map { $0.id }
    }

    // MARK: - Explanation

    func explainSelection(for photo: PhotoAsset, in group: [PhotoAsset]) -> String {
        let scored = scorePhotos(group)

        guard let selected = scored.first(where: { $0.photo.id == photo.id }) else {
            return "Photo not found in group"
        }

        let rank = scored.firstIndex(where: { $0.photo.id == photo.id }).map { $0 + 1 } ?? 0
        let breakdown = selected.breakdown

        var reasons: [String] = []

        if breakdown.quality > 0.7 {
            reasons.append("High aesthetic quality")
        }
        if breakdown.sharpness > 0.7 {
            reasons.append("Sharp and clear")
        }
        if breakdown.resolution > 0.8 {
            reasons.append("Highest resolution")
        }
        if breakdown.recency > 0.8 {
            reasons.append("Most recent")
        }

        let explanation = reasons.isEmpty
            ? "Best overall combination of quality metrics"
            : reasons.joined(separator: ", ")

        return "Rank \(rank)/\(group.count): \(explanation) (Score: \(String(format: "%.2f", selected.totalScore)))"
    }
}
