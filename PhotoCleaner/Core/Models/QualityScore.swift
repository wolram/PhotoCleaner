import Foundation

struct QualityScore: Codable, Hashable {
    let aestheticScore: Float    // -1 to 1 (from Vision API)
    let isUtility: Bool          // Screenshot, document, etc.
    let blurScore: Float         // 0 to 1 (1 = sharp)
    let exposureScore: Float     // 0 to 1 (0.5 = ideal exposure)

    var composite: Float {
        guard !isUtility else { return -1 }

        // Normalize aesthetic score from [-1, 1] to [0, 1]
        let normalizedAesthetic = (aestheticScore + 1) / 2

        // Calculate exposure quality (closer to 0.5 is better)
        let exposureQuality = 1 - abs(exposureScore - 0.5) * 2

        // Weighted combination
        return normalizedAesthetic * 0.5 + blurScore * 0.3 + exposureQuality * 0.2
    }

    var grade: Grade {
        if isUtility { return .utility }
        let score = composite
        switch score {
        case 0.8...1.0: return .excellent
        case 0.6..<0.8: return .good
        case 0.4..<0.6: return .average
        case 0.2..<0.4: return .poor
        default: return .bad
        }
    }

    enum Grade: String, CaseIterable {
        case excellent
        case good
        case average
        case poor
        case bad
        case utility

        var displayName: String {
            switch self {
            case .excellent: return "Excellent"
            case .good: return "Good"
            case .average: return "Average"
            case .poor: return "Poor"
            case .bad: return "Bad"
            case .utility: return "Utility"
            }
        }

        var color: String {
            switch self {
            case .excellent: return "green"
            case .good: return "blue"
            case .average: return "yellow"
            case .poor: return "orange"
            case .bad: return "red"
            case .utility: return "gray"
            }
        }

        var icon: String {
            switch self {
            case .excellent: return "star.fill"
            case .good: return "hand.thumbsup.fill"
            case .average: return "minus.circle"
            case .poor: return "hand.thumbsdown"
            case .bad: return "xmark.circle"
            case .utility: return "doc.text"
            }
        }
    }

    var isSharp: Bool {
        blurScore >= 0.7
    }

    var isBlurry: Bool {
        blurScore < 0.4
    }

    var isOverexposed: Bool {
        exposureScore > 0.8
    }

    var isUnderexposed: Bool {
        exposureScore < 0.2
    }

    var issues: [String] {
        var result: [String] = []
        if isBlurry { result.append("Blurry") }
        if isOverexposed { result.append("Overexposed") }
        if isUnderexposed { result.append("Underexposed") }
        if isUtility { result.append("Utility image") }
        return result
    }

    static let placeholder = QualityScore(
        aestheticScore: 0,
        isUtility: false,
        blurScore: 0.5,
        exposureScore: 0.5
    )
}
