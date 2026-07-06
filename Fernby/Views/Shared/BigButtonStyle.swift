import SwiftUI

/// A large, single-purpose tap target sized for developing fine motor
/// control (research puts the minimum comfortable target for this age at
/// 60-80pt, well above the standard 44pt). A gentle scale-down on press is
/// the only feedback here — anticipation, not celebration, per the
/// no-flashing-rewards constraint.
struct BigButtonStyle: ButtonStyle {
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .frame(minWidth: 88, minHeight: 88)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(tint)
            )
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BigButtonStyle {
    static var bigTap: BigButtonStyle { BigButtonStyle() }
    static func bigTap(tint: Color) -> BigButtonStyle { BigButtonStyle(tint: tint) }
}
