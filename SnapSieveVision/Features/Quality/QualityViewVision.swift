import SwiftUI
import SwiftData

struct QualityViewVision: View {
    @EnvironmentObject private var appState: AppStateVision
    @Query(filter: #Predicate<PhotoAssetEntity> { $0.compositeQualityScore < 0.3 })
    private var lowQualityPhotos: [PhotoAssetEntity]

    @State private var selectedPhoto: PhotoAssetEntity?

    var body: some View {
        NavigationSplitView {
            photoListView
        } detail: {
            if let photo = selectedPhoto {
                QualityDetailViewVision(photo: photo)
            } else {
                selectPromptView
            }
        }
        .navigationTitle("Quality Review")
    }

    private var photoListView: some View {
        Group {
            if lowQualityPhotos.isEmpty {
                emptyView
            } else {
                List(selection: $selectedPhoto) {
                    Section {
                        summaryCard
                    }
                    .listRowBackground(Color.clear)

                    Section("\(lowQualityPhotos.count) Low Quality Photos") {
                        ForEach(lowQualityPhotos, id: \.localIdentifier) { photo in
                            QualityPhotoRowVision(photo: photo)
                                .tag(photo)
                        }
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(lowQualityPhotos.count)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.yellow)
                Text("Issues Found")
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 60)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "camera.metering.unknown")
                        .foregroundStyle(.orange)
                    Text("Blur detected in some photos")
                        .font(.caption)
                }
                HStack {
                    Image(systemName: "sun.max")
                        .foregroundStyle(.yellow)
                    Text("Exposure issues identified")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Quality Issues", systemImage: "sparkles")
        } description: {
            Text("All your photos look great!")
        } actions: {
            Button("Scan Again") {
                appState.selectedSection = .scan
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var selectPromptView: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.left.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Select a Photo")
                .font(.title)

            Text("Choose a photo to see quality details")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Photo Row

struct QualityPhotoRowVision: View {
    let photo: PhotoAssetEntity

    var body: some View {
        HStack(spacing: 16) {
            AsyncThumbnailImageVision(
                assetId: photo.localIdentifier,
                size: CGSize(width: 100, height: 100)
            )
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                if let date = photo.creationDate {
                    Text(date, style: .date)
                        .font(.headline)
                }

                HStack(spacing: 8) {
                    QualityBadgeVision(type: .blur, score: photo.blurScore)
                    QualityBadgeVision(type: .exposure, score: photo.exposureScore)
                }
            }

            Spacer()

            // Quality grade
            Text(gradeText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(gradeColor)
        }
        .padding(.vertical, 4)
        .hoverEffect(.highlight)
    }

    private var gradeText: String {
        let score = photo.compositeQualityScore
        switch score {
        case 0.8...: return "A"
        case 0.6..<0.8: return "B"
        case 0.4..<0.6: return "C"
        case 0.2..<0.4: return "D"
        default: return "F"
        }
    }

    private var gradeColor: Color {
        let score = photo.compositeQualityScore
        switch score {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .orange
        default: return .red
        }
    }
}

struct QualityBadgeVision: View {
    enum QualityType {
        case blur
        case exposure

        var icon: String {
            switch self {
            case .blur: return "camera.metering.unknown"
            case .exposure: return "sun.max"
            }
        }
    }

    let type: QualityType
    let score: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.caption2)
            Text(scoreText)
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(scoreColor.opacity(0.2), in: Capsule())
        .foregroundStyle(scoreColor)
    }

    private var scoreText: String {
        switch score {
        case 0.8...: return "Good"
        case 0.5..<0.8: return "Fair"
        default: return "Poor"
        }
    }

    private var scoreColor: Color {
        switch score {
        case 0.8...: return .green
        case 0.5..<0.8: return .yellow
        default: return .red
        }
    }
}

// MARK: - Detail View

struct QualityDetailViewVision: View {
    let photo: PhotoAssetEntity
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Large preview
                AsyncThumbnailImageVision(
                    assetId: photo.localIdentifier,
                    size: CGSize(width: 800, height: 800)
                )
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxHeight: 500)

                // Quality Scores
                HStack(spacing: 24) {
                    QualityScoreCardVision(
                        title: "Aesthetics",
                        score: photo.aestheticScore,
                        icon: "star",
                        color: .purple
                    )

                    QualityScoreCardVision(
                        title: "Sharpness",
                        score: photo.blurScore,
                        icon: "camera.metering.spot",
                        color: .blue
                    )

                    QualityScoreCardVision(
                        title: "Exposure",
                        score: photo.exposureScore,
                        icon: "sun.max",
                        color: .orange
                    )

                    QualityScoreCardVision(
                        title: "Overall",
                        score: photo.compositeQualityScore,
                        icon: "sparkles",
                        color: .green
                    )
                }

                // Recommendations
                VStack(alignment: .leading, spacing: 12) {
                    Text("Analysis")
                        .font(.headline)

                    if photo.blurScore < 0.5 {
                        RecommendationRowVision(
                            icon: "camera.metering.unknown",
                            text: "This photo appears blurry. Consider keeping a sharper version.",
                            severity: .warning
                        )
                    }

                    if photo.exposureScore < 0.5 {
                        RecommendationRowVision(
                            icon: "sun.max",
                            text: "Exposure issues detected. The photo may be too dark or too bright.",
                            severity: .warning
                        )
                    }

                    if photo.compositeQualityScore >= 0.5 {
                        RecommendationRowVision(
                            icon: "checkmark.circle",
                            text: "This photo meets quality standards.",
                            severity: .good
                        )
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                // Actions
                HStack(spacing: 16) {
                    Button {
                        // Keep photo action
                    } label: {
                        Label("Keep Photo", systemImage: "checkmark")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Photo", systemImage: "trash")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .padding()
        }
        .confirmationDialog("Delete this photo?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    try? await PhotoLibraryServiceVision.shared.deleteAssets(identifiers: [photo.localIdentifier])
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct QualityScoreCardVision: View {
    let title: String
    let score: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: score)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                    Text("\(Int(score * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 100)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct RecommendationRowVision: View {
    enum Severity {
        case good, warning, error

        var color: Color {
            switch self {
            case .good: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
    }

    let icon: String
    let text: String
    let severity: Severity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(severity.color)

            Text(text)
                .font(.subheadline)

            Spacer()
        }
    }
}

#Preview(windowStyle: .automatic) {
    QualityViewVision()
        .environmentObject(AppStateVision())
}
