import SwiftUI

struct ScoreIndicator: View {
    let score: Float
    var showLabel: Bool = false
    var size: Size = .small

    enum Size {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 36
            case .large: return 48
            }
        }

        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .body
            }
        }
    }

    private var color: Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .orange
        default: return .red
        }
    }

    private var grade: String {
        switch score {
        case 0.8...1.0: return "A"
        case 0.6..<0.8: return "B"
        case 0.4..<0.6: return "C"
        case 0.2..<0.4: return "D"
        default: return "F"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)

                Circle()
                    .trim(from: 0, to: CGFloat(max(0, min(1, score))))
                    .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text(grade)
                    .font(size.fontSize)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
            .frame(width: size.dimension, height: size.dimension)

            if showLabel {
                Text("\(Int(score * 100))%")
                    .font(size.fontSize)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Quality Badge

struct QualityBadge: View {
    let grade: QualityScore.Grade

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: grade.icon)
            Text(grade.displayName)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundStyle(foregroundColor)
        .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch grade {
        case .excellent: return .green.opacity(0.2)
        case .good: return .blue.opacity(0.2)
        case .average: return .yellow.opacity(0.2)
        case .poor: return .orange.opacity(0.2)
        case .bad: return .red.opacity(0.2)
        case .utility: return .gray.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch grade {
        case .excellent: return .green
        case .good: return .blue
        case .average: return .yellow
        case .poor: return .orange
        case .bad: return .red
        case .utility: return .gray
        }
    }
}

// MARK: - Score Bar

struct ScoreBar: View {
    let label: String
    let value: Float
    var color: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(max(0, min(1, value))))
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ScoreIndicator(score: 0.9, showLabel: false, size: .small)
            ScoreIndicator(score: 0.7, showLabel: false, size: .medium)
            ScoreIndicator(score: 0.5, showLabel: true, size: .large)
        }

        HStack(spacing: 10) {
            QualityBadge(grade: .excellent)
            QualityBadge(grade: .good)
            QualityBadge(grade: .average)
            QualityBadge(grade: .poor)
        }

        VStack(spacing: 8) {
            ScoreBar(label: "Sharpness", value: 0.8, color: .green)
            ScoreBar(label: "Exposure", value: 0.5, color: .orange)
            ScoreBar(label: "Aesthetics", value: 0.6, color: .blue)
        }
        .padding()
    }
    .padding()
}
