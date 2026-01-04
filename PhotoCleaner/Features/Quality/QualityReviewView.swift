import SwiftUI
import SwiftData

struct QualityReviewView: View {
    @EnvironmentObject private var appState: AppState
    @Query private var photos: [PhotoAssetEntity]

    @State private var selectedGrade: QualityScore.Grade?
    @State private var selection = Set<String>()
    @State private var sortOrder: SortOrder = .qualityAsc

    enum SortOrder: String, CaseIterable {
        case qualityAsc = "Lowest Quality First"
        case qualityDesc = "Highest Quality First"
        case dateAsc = "Oldest First"
        case dateDesc = "Newest First"

        var icon: String {
            switch self {
            case .qualityAsc, .dateAsc: return "arrow.up"
            case .qualityDesc, .dateDesc: return "arrow.down"
            }
        }
    }

    var body: some View {
        Group {
            if filteredPhotos.isEmpty && selectedGrade == nil {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle("Quality Review")
        .toolbar {
            ToolbarItemGroup {
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }

                if !selection.isEmpty {
                    Text("\(selection.count) selected")
                        .foregroundStyle(.secondary)

                    Button(role: .destructive) {
                        // Delete selected
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    // MARK: - Views

    private var contentView: some View {
        HStack(spacing: 0) {
            // Grade filter sidebar
            VStack(alignment: .leading, spacing: 0) {
                Text("Filter by Quality")
                    .font(.headline)
                    .padding()

                ForEach(QualityScore.Grade.allCases, id: \.self) { grade in
                    gradeFilterRow(grade)
                }

                Spacer()

                // Statistics
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.headline)

                    ForEach(gradeStats, id: \.grade) { stat in
                        HStack {
                            Text(stat.grade.displayName)
                            Spacer()
                            Text("\(stat.count)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
                .padding()
                .background(.regularMaterial)
            }
            .frame(width: 200)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Photo grid
            if filteredPhotos.isEmpty {
                VStack {
                    Text("No photos match this filter")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 150, maximum: 200))],
                        spacing: 8
                    ) {
                        ForEach(sortedPhotos) { photo in
                            qualityPhotoItem(photo)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func gradeFilterRow(_ grade: QualityScore.Grade) -> some View {
        let count = photos.filter { gradeFor($0) == grade }.count

        return Button {
            if selectedGrade == grade {
                selectedGrade = nil
            } else {
                selectedGrade = grade
            }
        } label: {
            HStack {
                Image(systemName: grade.icon)
                    .foregroundStyle(colorFor(grade))

                Text(grade.displayName)

                Spacer()

                Text("\(count)")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(selectedGrade == grade ? Color.accentColor.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private func qualityPhotoItem(_ entity: PhotoAssetEntity) -> some View {
        _ = PhotoAsset(from: entity)
        let isSelected = selection.contains(entity.localIdentifier)
        let grade = gradeFor(entity)

        return VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                CachedThumbnailImage(
                    assetId: entity.localIdentifier,
                    size: CGSize(width: 300, height: 300)
                )
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                QualityBadge(grade: grade)
                    .padding(4)
            }

            if let score = entity.aestheticScore {
                ScoreIndicator(score: (score + 1) / 2, showLabel: true, size: .small)
            }

            // Issues
            if entity.isUtility {
                Text("Utility Image")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            } else if let blur = entity.blurScore, blur < 0.4 {
                Text("Blurry")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .padding(8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        }
        .onTapGesture {
            if selection.contains(entity.localIdentifier) {
                selection.remove(entity.localIdentifier)
            } else {
                selection.insert(entity.localIdentifier)
            }
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "sparkles",
            title: "No Quality Data",
            message: "Run a scan to analyze photo quality in your library.",
            actionTitle: "Start Scan"
        ) {
            appState.selectedDestination = .scan
        }
    }

    // MARK: - Helpers

    private var filteredPhotos: [PhotoAssetEntity] {
        if let grade = selectedGrade {
            return photos.filter { gradeFor($0) == grade }
        }
        return photos.filter { $0.aestheticScore != nil }
    }

    private var sortedPhotos: [PhotoAssetEntity] {
        switch sortOrder {
        case .qualityAsc:
            return filteredPhotos.sorted { ($0.aestheticScore ?? 0) < ($1.aestheticScore ?? 0) }
        case .qualityDesc:
            return filteredPhotos.sorted { ($0.aestheticScore ?? 0) > ($1.aestheticScore ?? 0) }
        case .dateAsc:
            return filteredPhotos.sorted { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }
        case .dateDesc:
            return filteredPhotos.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        }
    }

    private func gradeFor(_ entity: PhotoAssetEntity) -> QualityScore.Grade {
        if entity.isUtility { return .U }
        guard entity.aestheticScore != nil else { return .C }

        let composite = entity.compositeQualityScore
        switch composite {
        case 0.8...1.0: return .A
        case 0.6..<0.8: return .B
        case 0.4..<0.6: return .C
        case 0.2..<0.4: return .D
        default: return .F
        }
    }

    private func colorFor(_ grade: QualityScore.Grade) -> Color {
        switch grade {
        case .A: return .green
        case .B: return .blue
        case .C: return .yellow
        case .D: return .orange
        case .F: return .red
        case .U: return .gray
        }
    }

    private var gradeStats: [(grade: QualityScore.Grade, count: Int)] {
        QualityScore.Grade.allCases.map { grade in
            (grade, photos.filter { gradeFor($0) == grade }.count)
        }
    }
}

#Preview {
    QualityReviewView()
        .environmentObject(AppState())
}
