import SwiftUI

/// Card detalhado com informações de qualidade da foto para o Battle Mode
/// Mostra scores individuais, recomendação e metadados
struct BattlePhotoInfoCard: View {
    let photo: PhotoAssetEntity
    let isRecommended: Bool

    // MARK: - Computed Properties

    private var photoAsset: PhotoAsset {
        PhotoAsset(from: photo)
    }

    private var qualityScore: QualityScore? {
        photoAsset.qualityScore
    }

    private var normalizedAesthetic: Float {
        guard let score = qualityScore else { return 0.5 }
        // Convert from [-1, 1] to [0, 1]
        return (score.aestheticScore + 1) / 2
    }

    private var normalizedExposure: Float {
        guard let score = qualityScore else { return 0.5 }
        // Show as distance from perfect: 0.5 = 100%, 0 or 1 = 0%
        return 1 - abs(score.exposureScore - 0.5) * 2
    }

    private var exposureColor: Color {
        guard let score = qualityScore else { return .gray }
        if score.isOverexposed || score.isUnderexposed {
            return .orange
        }
        return .green
    }

    private var exposureWarning: String? {
        guard let score = qualityScore else { return nil }
        if score.isOverexposed { return "Overexposed" }
        if score.isUnderexposed { return "Underexposed" }
        return nil
    }

    private var gradeColor: Color {
        guard let score = qualityScore else { return .gray }
        switch score.grade {
        case .A: return .green
        case .B: return .blue
        case .C: return .yellow
        case .D: return .orange
        case .F: return .red
        case .U: return .gray
        }
    }

    private var formattedDimensions: String {
        "\(Int(photo.pixelWidth)) × \(Int(photo.pixelHeight))"
    }

    private var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: photo.fileSize, countStyle: .file)
    }

    private var formattedDate: String {
        guard let date = photo.creationDate else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            // Header: Grade + Recomendação
            headerView

            // Score breakdown
            if let score = qualityScore {
                scoreBreakdownView(score)
            }

            // Metadados
            metadataView
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            // Grade badge
            if let score = qualityScore {
                HStack(spacing: 4) {
                    Text(score.grade.displayName)
                        .font(.title3.bold())
                    Text("\(Int(score.composite * 100))%")
                        .font(.title3)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(gradeColor.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(gradeColor, lineWidth: 2)
                }
            }

            Spacer()

            // Recommendation badge
            if isRecommended {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("RECOMMENDED")
                        .font(.caption.bold())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.yellow)
                .foregroundStyle(.black)
                .clipShape(Capsule())
                .shadow(color: .yellow.opacity(0.5), radius: 4)
            }
        }
    }

    // MARK: - Score Breakdown

    private func scoreBreakdownView(_ score: QualityScore) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quality Breakdown")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.8))

            Divider()
                .background(.white.opacity(0.2))

            scoreRow(
                icon: "paintpalette.fill",
                label: "Aesthetics",
                value: normalizedAesthetic,
                color: .blue
            )

            scoreRow(
                icon: "scope",
                label: "Sharpness",
                value: score.blurScore,
                color: score.isBlurry ? .orange : .green,
                warning: score.isBlurry ? "Blurry" : nil
            )

            scoreRow(
                icon: "sun.max.fill",
                label: "Exposure",
                value: normalizedExposure,
                color: exposureColor,
                warning: exposureWarning
            )
        }
    }

    private func scoreRow(
        icon: String,
        label: String,
        value: Float,
        color: Color,
        warning: String? = nil
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 80, alignment: .leading)

            ProgressView(value: Double(value))
                .tint(color)
                .frame(maxWidth: .infinity)

            Text("\(Int(value * 100))%")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 40, alignment: .trailing)

            if let warning = warning {
                Text(warning)
                    .font(.caption2.bold())
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.orange.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Metadata

    private var metadataView: some View {
        VStack(spacing: 6) {
            Divider()
                .background(.white.opacity(0.2))

            HStack(spacing: 12) {
                Label(formattedDimensions, systemImage: "aspectratio")
                Spacer()
                Label(formattedFileSize, systemImage: "doc.fill")
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))

            if photo.creationDate != nil {
                HStack {
                    Label(formattedDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        VStack(spacing: 20) {
            // Good photo with recommendation
            BattlePhotoInfoCard(
                photo: createMockPhoto(
                    aesthetic: 0.8,
                    blur: 0.9,
                    exposure: 0.5,
                    width: 4000,
                    height: 3000
                ),
                isRecommended: true
            )
            .frame(width: 400)

            // Blurry photo
            BattlePhotoInfoCard(
                photo: createMockPhoto(
                    aesthetic: 0.7,
                    blur: 0.3,
                    exposure: 0.5,
                    width: 3000,
                    height: 2000
                ),
                isRecommended: false
            )
            .frame(width: 400)
        }
    }
}

// Helper for preview
private func createMockPhoto(aesthetic: Float, blur: Float, exposure: Float, width: Int, height: Int) -> PhotoAssetEntity {
    let photo = PhotoAssetEntity(
        localIdentifier: UUID().uuidString,
        pixelWidth: width,
        pixelHeight: height,
        fileSize: Int64(width * height * 3)
    )
    photo.aestheticScore = aesthetic
    photo.blurScore = blur
    photo.exposureScore = exposure
    photo.isUtility = false
    photo.creationDate = Date()
    photo.fileName = "IMG_\(Int.random(in: 1000...9999)).jpg"
    return photo
}
