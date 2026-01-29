import SwiftUI
import SwiftData

struct ScanViewVision: View {
    @EnvironmentObject private var appState: AppStateVision
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ScanViewModelVision()

    var body: some View {
        NavigationStack {
            Group {
                if appState.isScanning {
                    scanningView
                } else if viewModel.lastScanResult != nil {
                    resultView
                } else {
                    startView
                }
            }
            .navigationTitle("Scan Library")
            .onAppear {
                viewModel.appState = appState
                viewModel.modelContext = modelContext
                Task {
                    await viewModel.loadAlbums()
                }
            }
        }
    }

    // MARK: - Start View

    private var startView: some View {
        VStack(spacing: 40) {
            // 3D Icon with glass effect
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 160)

                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
            }
            .rotation3DEffect(.degrees(10), axis: (x: 1, y: 0, z: 0))

            VStack(spacing: 12) {
                Text("Scan Your Photo Library")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Find duplicates, similar photos, and low-quality images using AI")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 500)
            }

            // Album Picker with glass material
            VStack(alignment: .leading, spacing: 16) {
                Label("Select Album", systemImage: "folder")
                    .font(.headline)

                if viewModel.isLoadingAlbums {
                    HStack {
                        ProgressView()
                        Text("Loading albums...")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Picker("Album", selection: $viewModel.selectedAlbum) {
                        ForEach(viewModel.albums) { album in
                            Text("\(album.title) (\(album.count))")
                                .tag(album as PhotoLibraryServiceVision.Album?)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 400)

                    if let album = viewModel.selectedAlbum {
                        Text("\(album.count) photos will be analyzed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: 450)

            // Feature Cards
            HStack(spacing: 20) {
                FeatureCardVision(
                    icon: "doc.on.doc",
                    title: "Duplicates",
                    description: "Find exact copies",
                    color: .red
                )

                FeatureCardVision(
                    icon: "square.stack.3d.up",
                    title: "Similar",
                    description: "Group similar photos",
                    color: .orange
                )

                FeatureCardVision(
                    icon: "sparkles",
                    title: "Quality",
                    description: "Detect blur & issues",
                    color: .yellow
                )

                FeatureCardVision(
                    icon: "brain",
                    title: "AI Categories",
                    description: "Smart organization",
                    color: .purple
                )
            }
            .padding(.horizontal)

            // Start Button
            Button {
                Task {
                    await viewModel.startScan()
                }
            } label: {
                Label("Start Scan", systemImage: "play.fill")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(minWidth: 200)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .disabled(viewModel.selectedAlbum == nil)
        }
        .padding(40)
    }

    // MARK: - Scanning View

    private var scanningView: some View {
        VStack(spacing: 48) {
            // 3D Progress Orb
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)

                // Progress ring
                Circle()
                    .trim(from: 0, to: appState.scanProgress)
                    .stroke(
                        AngularGradient(
                            colors: [.blue, .purple, .blue],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: appState.scanProgress)

                // Inner glass sphere
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 160)

                VStack(spacing: 4) {
                    Text("\(Int(appState.scanProgress * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    Text(appState.scanPhase.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .rotation3DEffect(.degrees(15), axis: (x: 1, y: 0, z: 0))

            // Status
            VStack(spacing: 8) {
                Text(appState.statusMessage)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                // Phase indicators
                HStack(spacing: 32) {
                    PhaseIndicatorVision(title: "Load", phase: .loading, current: appState.scanPhase)
                    PhaseIndicatorVision(title: "Analyze", phase: .analyzing, current: appState.scanPhase)
                    PhaseIndicatorVision(title: "Group", phase: .grouping, current: appState.scanPhase)
                }
            }

            // Stats Grid
            HStack(spacing: 24) {
                StatOrbVision(title: "Scanned", value: "\(appState.photosScanned)", color: .blue)
                StatOrbVision(title: "Duplicates", value: "\(appState.duplicatesFound)", color: .red)
                StatOrbVision(title: "Similar", value: "\(appState.similarGroupsFound)", color: .orange)
                StatOrbVision(title: "Low Quality", value: "\(appState.lowQualityFound)", color: .yellow)
            }

            Button("Cancel Scan") {
                viewModel.cancelScan()
            }
            .buttonStyle(.bordered)
        }
        .padding(40)
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 40) {
            // Success Icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 140)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
            }
            .rotation3DEffect(.degrees(10), axis: (x: 1, y: 0, z: 0))

            Text("Scan Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let result = viewModel.lastScanResult {
                // Results Cards
                HStack(spacing: 20) {
                    ResultCardVision(
                        title: "Photos",
                        value: "\(result.photosScanned)",
                        icon: "photo",
                        color: .blue
                    )

                    ResultCardVision(
                        title: "Duplicates",
                        value: "\(result.duplicateGroups)",
                        icon: "doc.on.doc",
                        color: .red,
                        actionable: result.duplicateGroups > 0
                    )

                    ResultCardVision(
                        title: "Similar",
                        value: "\(result.similarGroups)",
                        icon: "square.stack.3d.up",
                        color: .orange,
                        actionable: result.similarGroups > 0
                    )

                    ResultCardVision(
                        title: "Low Quality",
                        value: "\(result.lowQualityCount)",
                        icon: "sparkles",
                        color: .yellow,
                        actionable: result.lowQualityCount > 0
                    )
                }

                // Space Recoverable
                VStack(spacing: 8) {
                    Text("Space Recoverable")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(result.formattedSpaceRecoverable)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.green)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }

            // Actions
            HStack(spacing: 16) {
                Button("Scan Again") {
                    Task {
                        await viewModel.startScan()
                    }
                }
                .buttonStyle(.bordered)

                Button {
                    appState.selectedSection = .duplicates
                } label: {
                    Label("Review Duplicates", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
                .disabled(appState.duplicatesFound == 0)
            }
        }
        .padding(40)
    }
}

// MARK: - Supporting Views

struct FeatureCardVision: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(title)
                .font(.headline)

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .hoverEffect(.lift)
    }
}

struct PhaseIndicatorVision: View {
    let title: String
    let phase: AppStateVision.ScanPhase
    let current: AppStateVision.ScanPhase

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(current >= phase ? Color.blue : Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 44, height: 44)

                if current > phase {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.bold)
                } else if current == phase {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(current >= phase ? .primary : .secondary)
        }
    }
}

struct StatOrbVision: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)

                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ResultCardVision: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var actionable: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            if actionable {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 120, height: 140)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .hoverEffect(.lift)
    }
}

#Preview(windowStyle: .automatic) {
    ScanViewVision()
        .environmentObject(AppStateVision())
}
