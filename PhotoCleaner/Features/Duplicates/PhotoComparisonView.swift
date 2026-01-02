import SwiftUI

private extension RawRepresentable where RawValue == Double {
    var rawValueAsDouble: Double? { rawValue }
}

private extension RawRepresentable where RawValue: BinaryFloatingPoint {
    var rawValueAsDouble: Double? { Double(rawValue) }
}

private extension RawRepresentable where RawValue: BinaryInteger {
    var rawValueAsDouble: Double? { Double(rawValue) }
}

private extension RawRepresentable {
    func extractRawValueAsDouble() -> Double? {
        // Attempt to access `rawValue` via Mirror and coerce common numeric types
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == "rawValue" {
                if let d = child.value as? Double { return d }
                if let f = child.value as? any BinaryFloatingPoint { return Double(f) }
                if let i = child.value as? any BinaryInteger { return Double(i) }
                break
            }
        }
        return nil
    }
}

struct PhotoComparisonView: View {
    let photos: [PhotoAsset]
    @Binding var selectedId: String?
    var bestId: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(photos) { photo in
                    comparisonCard(for: photo)
                }
            }
            .padding()
        }
    }

    private func comparisonCard(for photo: PhotoAsset) -> some View {
        let isSelected = selectedId == photo.id
        let isBest = bestId == photo.id

        return VStack(spacing: 12) {
            // Image with overlays
            ZStack {
                CachedThumbnailImage(
                    assetId: photo.id,
                    size: CGSize(width: 500, height: 500)
                )
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Best badge (top left)
                VStack {
                    HStack {
                        if isBest {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                Text("Best")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)

                // Grade indicator (top right)
                VStack {
                    HStack {
                        Spacer()
                        if let score = photo.qualityScore {
                            GradeIndicatorWithReasoning(
                                qualityScore: score,
                                size: .small
                            )
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }

            // Metadata panel
            PhotoMetadataPanel(photo: photo)

            // Select button
            Button {
                selectedId = photo.id
            } label: {
                Label(
                    isSelected ? "Selected" : "Keep This",
                    systemImage: isSelected ? "checkmark.circle.fill" : "circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(isSelected ? .green : .blue)
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        }
    }
}

// MARK: - Side by Side Comparison

struct SideBySideComparison: View {
    let photo1: PhotoAsset
    let photo2: PhotoAsset

    var body: some View {
        HStack(spacing: 0) {
            comparisonPane(for: photo1, side: .left)
            Divider()
            comparisonPane(for: photo2, side: .right)
        }
    }

    private func comparisonPane(for photo: PhotoAsset, side: Side) -> some View {
        VStack(spacing: 0) {
            // Image with grade indicator overlay
            ZStack(alignment: .topTrailing) {
                CachedThumbnailImage(
                    assetId: photo.id,
                    size: CGSize(width: 800, height: 800)
                )
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Grade indicator (top right)
                if let score = photo.qualityScore {
                    GradeIndicatorWithReasoning(
                        qualityScore: score,
                        size: .medium
                    )
                    .padding(12)
                }
            }

            // Metadata panel (bottom)
            PhotoMetadataPanel(photo: photo)
                .padding(8)
                .background(.regularMaterial)
        }
    }

    enum Side {
        case left, right
    }
}

// MARK: - Zoom Comparison

struct ZoomComparisonView: View {
    let photos: [PhotoAsset]
    @State private var selectedIndex = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            // Main image
            GeometryReader { geometry in
                CachedThumbnailImage(
                    assetId: photos[selectedIndex].id,
                    size: CGSize(width: 2000, height: 2000)
                )
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
            }

            // Thumbnail strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                        CachedThumbnailImage(
                            assetId: photo.id,
                            size: CGSize(width: 120, height: 120)
                        )
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(selectedIndex == index ? Color.accentColor : Color.clear, lineWidth: 2)
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedIndex = index
                                scale = 1.0
                                offset = .zero
                            }
                        }
                    }
                }
                .padding()
            }
            .background(.regularMaterial)
        }
    }
}

#Preview {
    PhotoComparisonView(
        photos: [
            PhotoAsset(id: "1", dimensions: CGSize(width: 4000, height: 3000)),
            PhotoAsset(id: "2", dimensions: CGSize(width: 3000, height: 2000))
        ],
        selectedId: .constant("1"),
        bestId: "1"
    )
}
// MARK: - Minimal Stubs to satisfy missing symbols

struct GradeIndicatorWithReasoning: View {
    enum Size {
        case small
        case medium
        case large

        var dimensions: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 28
            case .large: return 40
            }
        }

        var font: Font {
            switch self {
            case .small: return .system(size: 10, weight: .semibold)
            case .medium: return .system(size: 12, weight: .semibold)
            case .large: return .system(size: 14, weight: .semibold)
            }
        }
    }

    let qualityScore: Double
    let size: Size
    var reasoning: String? = nil

    // Convenience initializer to accept QualityScore types from the model layer
    init(qualityScore: QualityScore, size: Size, reasoning: String? = nil) {
        if let extracted = Self.extractDouble(from: qualityScore) {
            self.qualityScore = extracted
        } else {
            self.qualityScore = 0
        }
        self.size = size
        self.reasoning = reasoning
    }

    private static func extractDouble(from anyValue: Any) -> Double? {
        // 1) Direct numeric types
        if let d = anyValue as? Double { return d }
        if let f = anyValue as? any BinaryFloatingPoint { return Double(f) }
        if let i = anyValue as? any BinaryInteger { return Double(i) }

        // 2) RawRepresentable with a numeric rawValue (accessed via Mirror to avoid generic constraints on unknown type)
        if Mirror(reflecting: anyValue).displayStyle == .struct || Mirror(reflecting: anyValue).displayStyle == .enum || Mirror(reflecting: anyValue).displayStyle == .class {
            let mirror = Mirror(reflecting: anyValue)
            for child in mirror.children {
                if child.label == "rawValue" {
                    if let d = child.value as? Double { return d }
                    if let f = child.value as? any BinaryFloatingPoint { return Double(f) }
                    if let i = child.value as? any BinaryInteger { return Double(i) }
                    break
                }
            }
        }

        // 3) Fallback: search common property names via Mirror
        let mirror2 = Mirror(reflecting: anyValue)
        for child in mirror2.children {
            switch child.label {
            case "value", "score", "normalized", "fraction", "ratio":
                if let d = child.value as? Double { return d }
                if let f = child.value as? any BinaryFloatingPoint { return Double(f) }
                if let i = child.value as? any BinaryInteger { return Double(i) }
            case "percentage":
                if let p = child.value as? Double { return p / 100.0 }
                if let f = child.value as? any BinaryFloatingPoint { return Double(f) / 100.0 }
                if let i = child.value as? any BinaryInteger { return Double(i) / 100.0 }
            default:
                break
            }
        }
        return nil
    }

    private var normalizedScore: Double {
        min(max(qualityScore, 0), 1)
    }

    private var color: Color {
        switch normalizedScore {
        case 0.8...: return .green
        case 0.5..<0.8: return .yellow
        default: return .red
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
            Circle()
                .stroke(color, lineWidth: 2)
            Text("\(Int(normalizedScore * 100))%")
                .font(size.font)
                .foregroundStyle(color)
        }
        .frame(width: size.dimensions, height: size.dimensions)
        .accessibilityLabel("Quality score \(Int(normalizedScore * 100)) percent")
    }
}

struct PhotoMetadataPanel: View {
    let photo: PhotoAsset

    var body: some View {
        // Precompute score percent outside of ViewBuilder to avoid control-flow in result builders
        func extractPercent(from score: Any) -> Int {
            // Attempt to coerce QualityScore to Double (0...1)
            if let d = score as? Double {
                return Int(min(max(d, 0), 1) * 100)
            } else if let f = score as? any BinaryFloatingPoint {
                return Int(min(max(Double(f), 0), 1) * 100)
            } else if let i = score as? any BinaryInteger {
                return Int(min(max(Double(i), 0), 1) * 100)
            } else {
                // Mirror-based fallback similar to GradeIndicatorWithReasoning
                var extracted: Double? = nil
                let mirror = Mirror(reflecting: score)
                if mirror.displayStyle == .struct || mirror.displayStyle == .enum || mirror.displayStyle == .class {
                    for child in mirror.children {
                        if child.label == "rawValue" {
                            if let d = child.value as? Double { extracted = d; break }
                            if let f = child.value as? any BinaryFloatingPoint { extracted = Double(f); break }
                            if let i = child.value as? any BinaryInteger { extracted = Double(i); break }
                        }
                    }
                }
                if extracted == nil {
                    for child in mirror.children {
                        switch child.label {
                        case "value", "score", "normalized", "fraction", "ratio":
                            if let d = child.value as? Double { extracted = d }
                            else if let f = child.value as? any BinaryFloatingPoint { extracted = Double(f) }
                            else if let i = child.value as? any BinaryInteger { extracted = Double(i) }
                        case "percentage":
                            if let p = child.value as? Double { extracted = p / 100.0 }
                            else if let f = child.value as? any BinaryFloatingPoint { extracted = Double(f) / 100.0 }
                            else if let i = child.value as? any BinaryInteger { extracted = Double(i) / 100.0 }
                        default:
                            break
                        }
                        if extracted != nil { break }
                    }
                }
                let normalized = min(max(extracted ?? 0, 0), 1)
                return Int(normalized * 100)
            }
        }

        let percentText: String? = {
            guard let score = photo.qualityScore else { return nil }
            let percent = extractPercent(from: score)
            return "Score: \(percent)%"
        }()

        return VStack(alignment: .leading, spacing: 4) {
            let dims = photo.dimensions
            Text("\(Int(dims.width)) × \(Int(dims.height))")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let percentText {
                Text(percentText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


