import SwiftUI

enum PawTheme {
    static let cobalt = Color(red: 47 / 255, green: 107 / 255, blue: 255 / 255)
    static let cobaltPressed = Color(red: 31 / 255, green: 78 / 255, blue: 214 / 255)
    static let ink = Color(red: 28 / 255, green: 25 / 255, blue: 23 / 255)
    static let secondary = Color(red: 87 / 255, green: 83 / 255, blue: 78 / 255)
    static let line = Color(red: 231 / 255, green: 226 / 255, blue: 218 / 255)
    static let card = Color.white
    static let mapBackdrop = Color(red: 246 / 255, green: 243 / 255, blue: 238 / 255)
    static let amber = Color(red: 217 / 255, green: 119 / 255, blue: 6 / 255)
}

struct PawCardModifier: ViewModifier {
    @Environment(\.colorSchemeContrast) private var contrast
    var radius: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .background(PawTheme.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(PawTheme.line, lineWidth: contrast == .increased ? 1.5 : 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
}

extension View {
    func pawCard(radius: CGFloat = 22) -> some View {
        modifier(PawCardModifier(radius: radius))
    }
}

struct PawPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                configuration.isPressed ? PawTheme.cobaltPressed : PawTheme.cobalt,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
    }
}

struct ChipButtonStyle: ButtonStyle {
    var selected: Bool
    @Environment(\.colorSchemeContrast) private var contrast

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(selected ? Color.white : PawTheme.ink)
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background(selected ? PawTheme.cobalt : Color.white, in: Capsule())
            .overlay(
                Capsule().strokeBorder(
                    selected ? Color.clear : PawTheme.line,
                    lineWidth: contrast == .increased ? 1.5 : 1
                )
            )
            .shadow(color: Color.black.opacity(selected ? 0.14 : 0.06), radius: 8, y: 3)
            .opacity(configuration.isPressed ? 0.84 : 1)
    }
}
