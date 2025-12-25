import SwiftUI

struct ScanProgressView: View {
    let phase: AppState.ScanPhase
    let progress: Double
    let message: String
    let stats: ScanStats
    var onCancel: (() -> Void)?

    struct ScanStats {
        var photosScanned: Int = 0
        var duplicatesFound: Int = 0
        var similarGroupsFound: Int = 0
        var lowQualityFound: Int = 0
    }

    var body: some View {
        VStack(spacing: 32) {
            // Animated icon
            ZStack {
                Circle()
                    .stroke(.blue.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: progress)

                Image(systemName: phaseIcon)
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
            }

            // Phase and progress
            VStack(spacing: 8) {
                Text(phase.description)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(Int(progress * 100))%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            // Progress bar
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .frame(maxWidth: 400)

            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statItem("Scanned", value: stats.photosScanned, icon: "photo", color: .blue)
                statItem("Duplicates", value: stats.duplicatesFound, icon: "doc.on.doc", color: .red)
                statItem("Similar", value: stats.similarGroupsFound, icon: "square.stack.3d.up", color: .orange)
                statItem("Low Quality", value: stats.lowQualityFound, icon: "sparkles", color: .yellow)
            }
            .frame(maxWidth: 600)

            // Cancel button
            if let onCancel = onCancel {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .keyboardShortcut(.escape)
            }
        }
        .padding(40)
    }

    private var phaseIcon: String {
        switch phase {
        case .idle: return "play.circle"
        case .loading: return "arrow.down.circle"
        case .analyzing: return "eye.circle"
        case .grouping: return "rectangle.stack"
        case .complete: return "checkmark.circle"
        }
    }

    private func statItem(_ title: String, value: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Phase Stepper

struct PhaseStepper: View {
    let currentPhase: AppState.ScanPhase

    private let phases: [(AppState.ScanPhase, String, String)] = [
        (.loading, "Load", "folder"),
        (.analyzing, "Analyze", "eye"),
        (.grouping, "Group", "rectangle.stack"),
        (.complete, "Done", "checkmark")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                HStack(spacing: 0) {
                    // Step circle
                    ZStack {
                        Circle()
                            .fill(stepColor(for: phase.0))
                            .frame(width: 40, height: 40)

                        if currentPhase.rawValue > phase.0.rawValue {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                        } else if currentPhase == phase.0 {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(.white)
                        } else {
                            Image(systemName: phase.2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    // Connector line
                    if index < phases.count - 1 {
                        Rectangle()
                            .fill(lineColor(after: phase.0))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }

                if index < phases.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }

    private func stepColor(for phase: AppState.ScanPhase) -> Color {
        if currentPhase.rawValue >= phase.rawValue {
            return .blue
        }
        return .gray.opacity(0.3)
    }

    private func lineColor(after phase: AppState.ScanPhase) -> Color {
        if currentPhase.rawValue > phase.rawValue {
            return .blue
        }
        return .gray.opacity(0.3)
    }
}

#Preview {
    ScanProgressView(
        phase: .analyzing,
        progress: 0.45,
        message: "Analyzing photo 234 of 1000...",
        stats: ScanProgressView.ScanStats(
            photosScanned: 234,
            duplicatesFound: 12,
            similarGroupsFound: 8,
            lowQualityFound: 45
        ),
        onCancel: {}
    )
}
