import SwiftUI

struct LoadingOverlay: View {
    let message: String
    var progress: Double?
    var showCancel: Bool = false
    var onCancel: (() -> Void)?

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if let progress = progress {
                    CircularProgressView(progress: progress)
                } else {
                    ProgressView()
                        .controlSize(.large)
                }

                Text(message)
                    .font(.headline)
                    .foregroundStyle(.white)

                if let progress = progress {
                    Text("\(Int(progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

                if showCancel, let onCancel = onCancel {
                    Button("Cancel") {
                        onCancel()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

// MARK: - Circular Progress

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.3), lineWidth: 8)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
        .frame(width: 60, height: 60)
    }
}

// MARK: - Processing Overlay

struct ProcessingOverlay: View {
    let title: String
    let subtitle: String
    let progress: Double
    let stats: [(String, String)]
    var onCancel: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)

                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .monospacedDigit()
            }

            if !stats.isEmpty {
                HStack(spacing: 24) {
                    ForEach(stats, id: \.0) { stat in
                        VStack(spacing: 4) {
                            Text(stat.1)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(stat.0)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let onCancel = onCancel {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .keyboardShortcut(.escape)
            }
        }
        .padding(32)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 20)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .padding(40)
    }
}

#Preview("Loading") {
    LoadingOverlay(
        message: "Processing photos...",
        progress: 0.45,
        showCancel: true,
        onCancel: {}
    )
}

#Preview("Processing") {
    ProcessingOverlay(
        title: "Scanning Library",
        subtitle: "Analyzing photos for duplicates...",
        progress: 0.67,
        stats: [
            ("Scanned", "1,234"),
            ("Duplicates", "45"),
            ("Similar", "89")
        ],
        onCancel: {}
    )
    .frame(width: 400)
    .padding()
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "doc.on.doc",
        title: "No Duplicates Found",
        message: "Your photo library is clean! Run a scan to check for new duplicates.",
        actionTitle: "Start Scan",
        action: {}
    )
}
