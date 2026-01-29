import SwiftUI
import SwiftData

struct ScanViewiOS: View {
    @EnvironmentObject private var appState: AppStateiOS
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ScanViewModeliOS()

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
            .navigationTitle("Scan")
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
        ScrollView {
            VStack(spacing: 24) {
                // Hero Icon
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    Text("Scan Your Library")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Find duplicates, similar photos, and low-quality images")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Album Picker
                albumPickerCard

                // Features
                featuresCard

                // Start Button
                Button {
                    Task {
                        await viewModel.startScan()
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Scan")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.selectedAlbum == nil)
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
    }

    private var albumPickerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Select Album", systemImage: "folder")
                .font(.headline)

            if viewModel.isLoadingAlbums {
                HStack {
                    ProgressView()
                    Text("Loading albums...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                Picker("Album", selection: $viewModel.selectedAlbum) {
                    ForEach(viewModel.albums) { album in
                        Text("\(album.title) (\(album.count))")
                            .tag(album as PhotoLibraryServiceiOS.Album?)
                    }
                }
                .pickerStyle(.navigationLink)

                if let album = viewModel.selectedAlbum {
                    Text("\(album.count) photos will be scanned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private var featuresCard: some View {
        VStack(spacing: 0) {
            featureRow(icon: "doc.on.doc", title: "Duplicate Detection",
                       description: "Find exact and near-exact copies", color: .red)
            Divider().padding(.leading, 56)
            featureRow(icon: "square.stack.3d.up", title: "Similar Photos",
                       description: "Group visually similar images", color: .orange)
            Divider().padding(.leading, 56)
            featureRow(icon: "sparkles", title: "Quality Analysis",
                       description: "Identify blurry photos", color: .yellow)
            Divider().padding(.leading, 56)
            featureRow(icon: "folder", title: "AI Categorization",
                       description: "Organize by content", color: .purple)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func featureRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 44)

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
        .padding()
    }

    // MARK: - Scanning View

    private var scanningView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Animated Progress
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: appState.scanProgress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: appState.scanProgress)

                VStack(spacing: 4) {
                    Text("\(Int(appState.scanProgress * 100))%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    Text(appState.scanPhase.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Status
            Text(appState.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCardiOS(title: "Scanned", value: "\(appState.photosScanned)",
                            icon: "photo", color: .blue)
                StatCardiOS(title: "Duplicates", value: "\(appState.duplicatesFound)",
                            icon: "doc.on.doc", color: .red)
                StatCardiOS(title: "Similar", value: "\(appState.similarGroupsFound)",
                            icon: "square.stack.3d.up", color: .orange)
                StatCardiOS(title: "Low Quality", value: "\(appState.lowQualityFound)",
                            icon: "sparkles", color: .yellow)
            }
            .padding(.horizontal)

            Spacer()

            // Cancel Button
            Button("Cancel Scan") {
                viewModel.cancelScan()
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .padding(.top, 32)

                Text("Scan Complete!")
                    .font(.title)
                    .fontWeight(.bold)

                if let result = viewModel.lastScanResult {
                    VStack(spacing: 0) {
                        resultRow("Photos Scanned", value: "\(result.photosScanned)")
                        Divider().padding(.leading)
                        resultRow("Duplicate Groups", value: "\(result.duplicateGroups)",
                                  badge: result.duplicateGroups > 0 ? .red : nil)
                        Divider().padding(.leading)
                        resultRow("Similar Groups", value: "\(result.similarGroups)",
                                  badge: result.similarGroups > 0 ? .orange : nil)
                        Divider().padding(.leading)
                        resultRow("Low Quality", value: "\(result.lowQualityCount)",
                                  badge: result.lowQualityCount > 0 ? .yellow : nil)
                        Divider().padding(.leading)
                        resultRow("Space Recoverable", value: result.formattedSpaceRecoverable,
                                  highlight: true)
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        appState.selectedTab = .duplicates
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Review Duplicates")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(appState.duplicatesFound == 0)

                    Button {
                        appState.selectedTab = .similar
                    } label: {
                        HStack {
                            Image(systemName: "square.stack.3d.up")
                            Text("Review Similar Photos")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(appState.similarGroupsFound == 0)

                    Button("Scan Again") {
                        Task {
                            await viewModel.startScan()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }

    private func resultRow(_ label: String, value: String, badge: Color? = nil, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 8) {
                if let badge = badge {
                    Circle()
                        .fill(badge)
                        .frame(width: 8, height: 8)
                }
                Text(value)
                    .fontWeight(highlight ? .bold : .medium)
                    .foregroundStyle(highlight ? .green : .primary)
            }
        }
        .padding()
    }
}

// MARK: - Stat Card

struct StatCardiOS: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ScanViewiOS()
        .environmentObject(AppStateiOS())
}
