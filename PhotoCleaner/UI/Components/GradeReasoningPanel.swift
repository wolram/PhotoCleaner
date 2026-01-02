import SwiftUI

// MARK: - Grade Reasoning Panel

struct GradeReasoningPanel: View {
    let qualityScore: QualityScore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Grade Header
            gradeHeader

            Divider()

            // Score Breakdown
            scoreBreakdown

            // Issues Section
            if !qualityScore.issues.isEmpty {
                Divider()
                issuesSection
            }

            Divider()

            // Explanation
            explanationSection
        }
        .padding()
        .frame(width: 300)
    }

    // MARK: - Grade Header

    private var gradeHeader: some View {
        HStack(spacing: 16) {
            // Large grade letter
            Text(qualityScore.grade.displayName)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(gradeColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(qualityScore.grade.description)
                    .font(.headline)

                Text(qualityScore.grade.scoreRange)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !qualityScore.isUtility {
                    Text("Score: \(Int(qualityScore.composite * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Score Breakdown

    private var scoreBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Breakdown")
                .font(.headline)

            if qualityScore.isUtility {
                Text("Utility images are not scored for quality.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                // Aesthetic Score (50% weight)
                scoreRow(
                    label: "Aesthetic",
                    value: normalizedAestheticScore,
                    weight: 50,
                    color: aestheticColor
                )

                // Sharpness Score (30% weight)
                scoreRow(
                    label: "Sharpness",
                    value: qualityScore.blurScore,
                    weight: 30,
                    color: sharpnessColor
                )

                // Exposure Score (20% weight)
                scoreRow(
                    label: "Exposure",
                    value: exposureQuality,
                    weight: 20,
                    color: exposureColor
                )
            }
        }
    }

    private func scoreRow(label: String, value: Float, weight: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("(\(weight)% weight)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(max(0, min(1, value))))
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Issues Section

    private var issuesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Issues Detected")
                .font(.headline)

            ForEach(qualityScore.issues, id: \.self) { issue in
                HStack(spacing: 8) {
                    Image(systemName: iconForIssue(issue))
                        .foregroundStyle(colorForIssue(issue))

                    Text(issue)
                        .font(.subheadline)

                    Spacer()
                }
            }
        }
    }

    private func iconForIssue(_ issue: String) -> String {
        switch issue {
        case "Blurry": return "camera.aperture"
        case "Overexposed": return "sun.max.fill"
        case "Underexposed": return "moon.fill"
        case "Utility image": return "doc.text"
        default: return "exclamationmark.triangle"
        }
    }

    private func colorForIssue(_ issue: String) -> Color {
        switch issue {
        case "Blurry": return .orange
        case "Overexposed": return .yellow
        case "Underexposed": return .purple
        case "Utility image": return .gray
        default: return .red
        }
    }

    // MARK: - Explanation Section

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why this grade?")
                .font(.headline)

            Text(gradeExplanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var gradeExplanation: String {
        if qualityScore.isUtility {
            return "This image appears to be a utility image (screenshot, document, etc.) and is categorized separately from regular photos."
        }

        var reasons: [String] = []

        // Aesthetic reasoning
        if normalizedAestheticScore >= 0.7 {
            reasons.append("The image has strong visual appeal and composition.")
        } else if normalizedAestheticScore >= 0.5 {
            reasons.append("The image has moderate visual appeal.")
        } else {
            reasons.append("The image has limited visual appeal or composition issues.")
        }

        // Sharpness reasoning
        if qualityScore.isBlurry {
            reasons.append("The image appears blurry or out of focus.")
        } else if qualityScore.isSharp {
            reasons.append("The image is sharp and well-focused.")
        }

        // Exposure reasoning
        if qualityScore.isOverexposed {
            reasons.append("The image is overexposed (too bright).")
        } else if qualityScore.isUnderexposed {
            reasons.append("The image is underexposed (too dark).")
        }

        return reasons.joined(separator: " ")
    }

    // MARK: - Helper Properties

    private var normalizedAestheticScore: Float {
        (qualityScore.aestheticScore + 1) / 2
    }

    private var exposureQuality: Float {
        1 - abs(qualityScore.exposureScore - 0.5) * 2
    }

    private var gradeColor: Color {
        switch qualityScore.grade {
        case .A: return .green
        case .B: return .blue
        case .C: return .yellow
        case .D: return .orange
        case .F: return .red
        case .U: return .gray
        }
    }

    private var aestheticColor: Color {
        switch normalizedAestheticScore {
        case 0.7...1.0: return .green
        case 0.5..<0.7: return .blue
        case 0.3..<0.5: return .yellow
        default: return .orange
        }
    }

    private var sharpnessColor: Color {
        switch qualityScore.blurScore {
        case 0.7...1.0: return .green
        case 0.5..<0.7: return .blue
        case 0.4..<0.5: return .yellow
        default: return .red
        }
    }

    private var exposureColor: Color {
        switch exposureQuality {
        case 0.7...1.0: return .green
        case 0.5..<0.7: return .blue
        case 0.3..<0.5: return .yellow
        default: return .orange
        }
    }
}

// MARK: - Grade Indicator with Popover

struct GradeIndicatorWithReasoning: View {
    let qualityScore: QualityScore
    var size: GradeIndicatorSize = .medium

    @State private var showingPopover = false

    enum GradeIndicatorSize {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return 28
            case .medium: return 40
            case .large: return 56
            }
        }

        var fontSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .title3
            case .large: return .title
            }
        }
    }

    var body: some View {
        Button {
            showingPopover.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(gradeColor.opacity(0.2))

                Circle()
                    .stroke(gradeColor, lineWidth: 2)

                Text(qualityScore.grade.displayName)
                    .font(size.fontSize)
                    .fontWeight(.bold)
                    .foregroundStyle(gradeColor)
            }
            .frame(width: size.dimension, height: size.dimension)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingPopover, arrowEdge: .trailing) {
            GradeReasoningPanel(qualityScore: qualityScore)
        }
        .help("Click to see grade reasoning")
    }

    private var gradeColor: Color {
        switch qualityScore.grade {
        case .A: return .green
        case .B: return .blue
        case .C: return .yellow
        case .D: return .orange
        case .F: return .red
        case .U: return .gray
        }
    }
}

// MARK: - Expandable Grade Panel

struct ExpandableGradePanel: View {
    let qualityScore: QualityScore

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    // Grade circle
                    ZStack {
                        Circle()
                            .fill(gradeColor.opacity(0.2))

                        Circle()
                            .stroke(gradeColor, lineWidth: 2)

                        Text(qualityScore.grade.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(gradeColor)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(qualityScore.grade.description)
                            .font(.headline)

                        if !qualityScore.isUtility {
                            Text("Score: \(Int(qualityScore.composite * 100))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal)

                    // Score breakdown
                    if !qualityScore.isUtility {
                        VStack(alignment: .leading, spacing: 8) {
                            scoreBarCompact(label: "Aesthetic", value: normalizedAestheticScore, weight: "50%")
                            scoreBarCompact(label: "Sharpness", value: qualityScore.blurScore, weight: "30%")
                            scoreBarCompact(label: "Exposure", value: exposureQuality, weight: "20%")
                        }
                        .padding(.horizontal)
                    }

                    // Issues
                    if !qualityScore.issues.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(qualityScore.issues, id: \.self) { issue in
                                Text(issue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundStyle(.orange)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func scoreBarCompact(label: String, value: Float, weight: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .frame(width: 60, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForValue(value))
                        .frame(width: geometry.size.width * CGFloat(max(0, min(1, value))))
                }
            }
            .frame(height: 4)

            Text("\(Int(value * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 35, alignment: .trailing)
        }
    }

    private func colorForValue(_ value: Float) -> Color {
        switch value {
        case 0.7...1.0: return .green
        case 0.5..<0.7: return .blue
        case 0.3..<0.5: return .yellow
        default: return .orange
        }
    }

    private var normalizedAestheticScore: Float {
        (qualityScore.aestheticScore + 1) / 2
    }

    private var exposureQuality: Float {
        1 - abs(qualityScore.exposureScore - 0.5) * 2
    }

    private var gradeColor: Color {
        switch qualityScore.grade {
        case .A: return .green
        case .B: return .blue
        case .C: return .yellow
        case .D: return .orange
        case .F: return .red
        case .U: return .gray
        }
    }
}

// MARK: - Preview

#Preview("Grade Reasoning Panel") {
    VStack(spacing: 20) {
        GradeReasoningPanel(
            qualityScore: QualityScore(
                aestheticScore: 0.7,
                isUtility: false,
                blurScore: 0.85,
                exposureScore: 0.5
            )
        )
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}

#Preview("Grade Indicator with Popover") {
    HStack(spacing: 20) {
        GradeIndicatorWithReasoning(
            qualityScore: QualityScore(
                aestheticScore: 0.8,
                isUtility: false,
                blurScore: 0.9,
                exposureScore: 0.5
            ),
            size: .small
        )

        GradeIndicatorWithReasoning(
            qualityScore: QualityScore(
                aestheticScore: 0.4,
                isUtility: false,
                blurScore: 0.7,
                exposureScore: 0.5
            ),
            size: .medium
        )

        GradeIndicatorWithReasoning(
            qualityScore: QualityScore(
                aestheticScore: -0.2,
                isUtility: false,
                blurScore: 0.3,
                exposureScore: 0.9
            ),
            size: .large
        )
    }
    .padding()
}

#Preview("Expandable Grade Panel") {
    VStack(spacing: 20) {
        ExpandableGradePanel(
            qualityScore: QualityScore(
                aestheticScore: 0.6,
                isUtility: false,
                blurScore: 0.75,
                exposureScore: 0.5
            )
        )

        ExpandableGradePanel(
            qualityScore: QualityScore(
                aestheticScore: -0.3,
                isUtility: false,
                blurScore: 0.2,
                exposureScore: 0.15
            )
        )

        ExpandableGradePanel(
            qualityScore: QualityScore(
                aestheticScore: 0.5,
                isUtility: true,
                blurScore: 0.8,
                exposureScore: 0.5
            )
        )
    }
    .padding()
    .frame(width: 350)
}
