import SwiftUI

struct SettingsViewVision: View {
    @EnvironmentObject private var appState: AppStateVision
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                // Detection Settings
                Section("Detection Settings") {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Duplicate Sensitivity", systemImage: "doc.on.doc")
                                Spacer()
                                Text(duplicateSensitivityLabel)
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $appState.duplicateThreshold, in: 0.1...0.9, step: 0.1)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Similarity Threshold", systemImage: "square.stack.3d.up")
                                Spacer()
                                Text("\(appState.similarityThreshold)")
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: Binding(
                                get: { Double(appState.similarityThreshold) },
                                set: { appState.similarityThreshold = Int($0) }
                            ), in: 4...16, step: 1)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Quality Threshold", systemImage: "sparkles")
                                Spacer()
                                Text(qualityThresholdLabel)
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $appState.qualityThreshold, in: 0.1...0.5, step: 0.05)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Performance
                Section("Performance") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Concurrent Tasks", systemImage: "cpu")
                            Spacer()
                            Text("\(appState.maxConcurrentTasks)")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(appState.maxConcurrentTasks) },
                            set: { appState.maxConcurrentTasks = Int($0) }
                        ), in: 2...8, step: 1)
                        Text("Higher values process faster but use more resources")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                // Library Stats
                Section("Library") {
                    LibraryInfoRowVision()
                }

                // About
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Build", systemImage: "hammer")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Platform", systemImage: "visionpro")
                        Spacer()
                        Text("visionOS")
                            .foregroundStyle(.secondary)
                    }
                }

                // Reset
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Reset All Settings", systemImage: "arrow.counterclockwise")
                            Spacer()
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset all settings?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    resetToDefaults()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will restore all settings to their default values.")
            }
        }
    }

    private var duplicateSensitivityLabel: String {
        switch appState.duplicateThreshold {
        case ..<0.3: return "Very Strict"
        case 0.3..<0.5: return "Strict"
        case 0.5..<0.7: return "Normal"
        case 0.7...: return "Relaxed"
        default: return "Normal"
        }
    }

    private var qualityThresholdLabel: String {
        String(format: "%.0f%%", appState.qualityThreshold * 100)
    }

    private func resetToDefaults() {
        appState.duplicateThreshold = 0.5
        appState.similarityThreshold = 8
        appState.qualityThreshold = 0.3
        appState.maxConcurrentTasks = 6
    }
}

// MARK: - Library Info

struct LibraryInfoRowVision: View {
    @State private var stats: (count: Int, totalSize: Int64)?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                HStack {
                    Label("Loading...", systemImage: "photo.on.rectangle")
                    Spacer()
                    ProgressView()
                }
            } else if let stats = stats {
                HStack {
                    Label("Photos", systemImage: "photo.on.rectangle")
                    Spacer()
                    Text("\(stats.count)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Total Size", systemImage: "internaldrive")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: stats.totalSize, countStyle: .file))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            stats = await PhotoLibraryServiceVision.shared.getLibraryStats()
            isLoading = false
        }
    }
}

#Preview(windowStyle: .automatic) {
    SettingsViewVision()
        .environmentObject(AppStateVision())
}
