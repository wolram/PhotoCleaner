import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("duplicateThreshold") private var duplicateThreshold: Double = 0.5
    @AppStorage("similarityThreshold") private var similarityThreshold: Int = 8
    @AppStorage("qualityThreshold") private var qualityThreshold: Double = 0.3
    @AppStorage("maxConcurrentTasks") private var maxConcurrentTasks: Int = 8
    @AppStorage("enableCLIP") private var enableCLIP: Bool = true
    @AppStorage("autoSelectBest") private var autoSelectBest: Bool = true

    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            analysisSettings
                .tabItem {
                    Label("Analysis", systemImage: "waveform")
                }

            performanceSettings
                .tabItem {
                    Label("Performance", systemImage: "speedometer")
                }

            aboutView
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }

    // MARK: - General Settings

    private var generalSettings: some View {
        Form {
            Section("Behavior") {
                Toggle("Auto-select best photo in groups", isOn: $autoSelectBest)

                Toggle("Enable AI categorization (CLIP)", isOn: $enableCLIP)
            }

            Section("Photo Library") {
                Button("Re-request Photo Access") {
                    Task {
                        await PhotoLibraryService.shared.requestAuthorization()
                    }
                }

                Button("Clear Cache") {
                    ThumbnailLoader.clearCache()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Analysis Settings

    private var analysisSettings: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Duplicate Detection Threshold")
                        Spacer()
                        Text(String(format: "%.2f", duplicateThreshold))
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $duplicateThreshold, in: 0.3...0.7, step: 0.05)

                    Text("Lower values = stricter matching (fewer false positives)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Duplicate Detection")
            }

            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Similarity Threshold (Hamming Distance)")
                        Spacer()
                        Text("\(similarityThreshold)")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: .init(
                        get: { Double(similarityThreshold) },
                        set: { similarityThreshold = Int($0) }
                    ), in: 4...16, step: 1)

                    Text("Lower values = more similar photos required")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Similar Photo Detection")
            }

            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Quality Threshold")
                        Spacer()
                        Text(String(format: "%.0f%%", qualityThreshold * 100))
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $qualityThreshold, in: 0.1...0.5, step: 0.05)

                    Text("Photos below this quality score will be flagged")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Quality Assessment")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Performance Settings

    private var performanceSettings: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Concurrent Processing Tasks")
                        Spacer()
                        Text("\(maxConcurrentTasks)")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: .init(
                        get: { Double(maxConcurrentTasks) },
                        set: { maxConcurrentTasks = Int($0) }
                    ), in: 2...16, step: 1)

                    Text("Higher values = faster scanning but more memory usage")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Processing")
            }

            Section {
                HStack {
                    Text("Memory Usage")
                    Spacer()
                    Text(MemoryManager.shared.formatBytes(MemoryManager.shared.usedMemory))
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Available Memory")
                    Spacer()
                    Text(MemoryManager.shared.formatBytes(MemoryManager.shared.availableMemory))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Memory")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - About

    private var aboutView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.checkmark")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text("PhotoCleaner")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Version \(AppConfig.appVersion)")
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                featureRow("Duplicate Detection", description: "Apple Vision Framework")
                featureRow("Similar Photo Grouping", description: "Perceptual Hashing + DBSCAN")
                featureRow("Quality Assessment", description: "Aesthetics + Blur + Exposure")
                featureRow("AI Categorization", description: "MobileCLIP (Optional)")
            }

            Spacer()

            Text("Made with Swift & SwiftUI")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
    }

    private func featureRow(_ title: String, description: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
