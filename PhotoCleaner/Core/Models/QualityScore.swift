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
        if isUtility { return .U }
        let score = composite
        switch score {
        case 0.8...1.0: return .A
        case 0.6..<0.8: return .B
        case 0.4..<0.6: return .C
        case 0.2..<0.4: return .D
        default: return .F
        }
    }

    enum Grade: String, CaseIterable {
        case A
        case B
        case C
        case D
        case F
        case U

        var displayName: String {
            switch self {
            case .A: return "A"
            case .B: return "B"
            case .C: return "C"
            case .D: return "D"
            case .F: return "F"
            case .U: return "U"
            }
        }

        var description: String {
            switch self {
            case .A: return "Excellent"
            case .B: return "Good"
            case .C: return "Average"
            case .D: return "Poor"
            case .F: return "Bad"
            case .U: return "Utility"
            }
        }

        var color: String {
            switch self {
            case .A: return "green"
            case .B: return "blue"
            case .C: return "yellow"
            case .D: return "orange"
            case .F: return "red"
            case .U: return "gray"
            }
        }

        var icon: String {
            switch self {
            case .A: return "star.fill"
            case .B: return "hand.thumbsup.fill"
            case .C: return "minus.circle"
            case .D: return "hand.thumbsdown"
            case .F: return "xmark.circle"
            case .U: return "doc.text"
            }
        }

        var scoreRange: String {
            switch self {
            case .A: return "80-100%"
            case .B: return "60-80%"
            case .C: return "40-60%"
            case .D: return "20-40%"
            case .F: return "<20%"
            case .U: return "N/A"
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
