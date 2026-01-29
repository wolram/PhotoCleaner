import SwiftUI

struct SettingsViewiOS: View {
    @EnvironmentObject private var appState: AppStateiOS
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                // Detection Settings
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Duplicate Sensitivity")
                            Spacer()
                            Text(duplicateSensitivityLabel)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $appState.duplicateThreshold, in: 0.1...0.9, step: 0.1)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Similarity Threshold")
                            Spacer()
                            Text("\(appState.similarityThreshold)")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(appState.similarityThreshold) },
                            set: { appState.similarityThreshold = Int($0) }
                        ), in: 4...16, step: 1)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Quality Threshold")
                            Spacer()
                            Text(qualityThresholdLabel)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $appState.qualityThreshold, in: 0.1...0.5, step: 0.05)
                    }
                } header: {
                    Text("Detection")
                } footer: {
                    Text("Adjust these settings to control how strictly photos are matched.")
                }

                // Performance Settings
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Concurrent Tasks")
                            Spacer()
                            Text("\(appState.maxConcurrentTasks)")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(appState.maxConcurrentTasks) },
                            set: { appState.maxConcurrentTasks = Int($0) }
                        ), in: 2...8, step: 1)
                    }
                } header: {
                    Text("Performance")
                } footer: {
                    Text("Higher values scan faster but use more battery.")
                }

                // Library Info
                Section("Library") {
                    LibraryInfoRowiOS()
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }

                // Reset
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset All Settings")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset all settings to defaults?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    resetToDefaults()
                }
                Button("Cancel", role: .cancel) {}
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
        appState.maxConcurrentTasks = 4
    }
}

// MARK: - Library Info Row

struct LibraryInfoRowiOS: View {
    @State private var stats: (count: Int, totalSize: Int64)?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                HStack {
                    Text("Loading...")
                    Spacer()
                    ProgressView()
                }
            } else if let stats = stats {
                HStack {
                    Text("Photos")
                    Spacer()
                    Text("\(stats.count)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Total Size")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: stats.totalSize, countStyle: .file))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            stats = await PhotoLibraryServiceiOS.shared.getLibraryStats()
            isLoading = false
        }
    }
}

#Preview {
    SettingsViewiOS()
        .environmentObject(AppStateiOS())
}
