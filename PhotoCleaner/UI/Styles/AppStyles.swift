import SwiftUI

// MARK: - Colors

extension Color {
    static let appPrimary = Color.accentColor
    static let appSecondary = Color.secondary
    static let appBackground = Color(nsColor: .windowBackgroundColor)
    static let appGroupBackground = Color(nsColor: .controlBackgroundColor)

    static let qualityExcellent = Color.green
    static let qualityGood = Color.blue
    static let qualityAverage = Color.yellow
    static let qualityPoor = Color.orange
    static let qualityBad = Color.red
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isEnabled ? Color.accentColor : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.quaternary)
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.1))
            .foregroundStyle(.red)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    static var destructive: DestructiveButtonStyle { DestructiveButtonStyle() }
}

// MARK: - Card Style

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
}

// MARK: - Photo Grid Item Style

struct PhotoGridItemStyle: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.accentColor, lineWidth: 3)
                }
            }
            .shadow(color: .black.opacity(isSelected ? 0.2 : 0.1), radius: isSelected ? 4 : 2)
    }
}

extension View {
    func photoGridItemStyle(isSelected: Bool) -> some View {
        modifier(PhotoGridItemStyle(isSelected: isSelected))
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    var icon: String?
    var color: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 80)
        .padding()
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var action: (() -> Void)?
    var actionLabel: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let action = action, let label = actionLabel {
                Button(label, action: action)
                    .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Toolbar Button

struct ToolbarButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderless)
            .padding(8)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

extension View {
    func toolbarButtonStyle() -> some View {
        modifier(ToolbarButtonStyle())
    }
}

// MARK: - Preview

#Preview("Buttons") {
    VStack(spacing: 16) {
        Button("Primary Button") {}
            .buttonStyle(.primary)

        Button("Secondary Button") {}
            .buttonStyle(.secondary)

        Button("Delete") {}
            .buttonStyle(.destructive)
    }
    .padding()
}

#Preview("Cards") {
    HStack(spacing: 16) {
        StatCard(title: "Photos", value: "1,234", icon: "photo", color: .blue)
        StatCard(title: "Duplicates", value: "45", icon: "doc.on.doc", color: .red)
        StatCard(title: "Space", value: "2.3 GB", icon: "arrow.down.circle", color: .green)
    }
    .padding()
}
