import SwiftUI
import SwiftData

struct ScanView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ScanViewModel()

    var body: some View {
        Group {
            if appState.isScanning {
                scanningView
            } else if viewModel.lastScanResult != nil {
                resultView
            } else {
                startView
            }
        }
        .onAppear {
            viewModel.appState = appState
            viewModel.modelContext = modelContext
            Task {
                await viewModel.loadAlbums()
            }
        }
    }

    // MARK: - Start View

    private var startView: some View {
        VStack(spacing: 32) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            VStack(spacing: 8) {
                Text("Scan Your Photo Library")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Find duplicates, similar photos, and low-quality images")
                    .foregroundStyle(.secondary)
            }

            // Album Picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Album to Scan")
                    .font(.headline)

                if viewModel.isLoadingAlbums {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Loading albums...")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Picker("Album", selection: $viewModel.selectedAlbum) {
                        ForEach(viewModel.albums) { album in
                            HStack {
                                albumIcon(for: album.type)
                                Text("\(album.title) (\(album.count))")
                            }
                            .tag(album as PhotoLibraryService.Album?)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 300)

                    if let album = viewModel.selectedAlbum {
                        Text("\(album.count) photos will be scanned")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 16) {
                scanOptionRow(
                    icon: "doc.on.doc",
                    title: "Duplicate Detection",
                    description: "Find exact and near-exact copies"
                )

                scanOptionRow(
                    icon: "square.stack.3d.up",
                    title: "Similar Photos",
                    description: "Group visually similar images"
                )

                scanOptionRow(
                    icon: "sparkles",
                    title: "Quality Analysis",
                    description: "Identify blurry and poorly exposed photos"
                )

                scanOptionRow(
                    icon: "folder",
                    title: "AI Categorization",
                    description: "Organize photos by content"
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                Task {
                    await viewModel.startScan()
                }
            } label: {
                Label("Start Scan", systemImage: "play.fill")
                    .font(.headline)
                    .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.selectedAlbum == nil)
        }
        .padding(40)
    }

    private func albumIcon(for type: PhotoLibraryService.Album.AlbumType) -> some View {
        Image(systemName: {
            switch type {
            case .allPhotos: return "photo.on.rectangle.angled"
            case .smartAlbum: return "gearshape"
            case .userAlbum: return "folder"
            }
        }())
        .foregroundStyle(.blue)
    }

    private func scanOptionRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }

    // MARK: - Scanning View

    private var scanningView: some View {
        VStack(spacing: 32) {
            // Phase indicators
            HStack(spacing: 24) {
                phaseIndicator(
                    title: "Loading",
                    phase: .loading,
                    current: appState.scanPhase
                )
                phaseIndicator(
                    title: "Analyzing",
                    phase: .analyzing,
                    current: appState.scanPhase
                )
                phaseIndicator(
                    title: "Grouping",
                    phase: .grouping,
                    current: appState.scanPhase
                )
            }

            // Progress
            VStack(spacing: 12) {
                ProgressView(value: appState.scanProgress)
                    .progressViewStyle(.linear)

                HStack {
                    Text(appState.statusMessage)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(appState.scanProgress * 100))%")
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 40)

            // Stats
            HStack(spacing: 32) {
                StatCard(
                    title: "Scanned",
                    value: "\(appState.photosScanned)",
                    icon: "photo",
                    color: .blue
                )

                StatCard(
                    title: "Duplicates",
                    value: "\(appState.duplicatesFound)",
                    icon: "doc.on.doc",
                    color: .red
                )

                StatCard(
                    title: "Similar",
                    value: "\(appState.similarGroupsFound)",
                    icon: "square.stack.3d.up",
                    color: .orange
                )

                StatCard(
                    title: "Low Quality",
                    value: "\(appState.lowQualityFound)",
                    icon: "sparkles",
                    color: .yellow
                )
            }

            Button("Cancel Scan") {
                viewModel.cancelScan()
            }
            .buttonStyle(.bordered)
            .keyboardShortcut(.escape)
        }
        .padding(40)
    }

    private func phaseIndicator(
        title: String,
        phase: AppState.ScanPhase,
        current: AppState.ScanPhase
    ) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(current >= phase ? Color.blue : Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 40, height: 40)

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

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Scan Complete!")
                .font(.title)
                .fontWeight(.semibold)

            if let result = viewModel.lastScanResult {
                VStack(spacing: 16) {
                    resultRow("Photos Scanned", value: "\(result.photosScanned)")
                    resultRow("Duplicate Groups", value: "\(result.duplicateGroups)")
                    resultRow("Similar Groups", value: "\(result.similarGroups)")
                    resultRow("Low Quality", value: "\(result.lowQualityCount)")
                    resultRow("Space Recoverable", value: result.formattedSpaceRecoverable, highlight: true)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            HStack(spacing: 16) {
                Button("Scan Again") {
                    Task {
                        await viewModel.startScan()
                    }
                }
                .buttonStyle(.bordered)

                Button("Review Results") {
                    appState.selectedDestination = .duplicates
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
    }

    private func resultRow(_ label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(highlight ? .bold : .medium)
                .foregroundStyle(highlight ? .green : .primary)
        }
    }
}

#Preview {
    ScanView()
        .environmentObject(AppState())
}
