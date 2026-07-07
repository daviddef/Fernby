import SwiftUI

/// A tappable biome on the world map. Locked biomes are desaturated; the
/// current biome gets a single slow breathing-opacity pulse — deliberately
/// not a flash or a bounce, per the no-flashing-rewards constraint.
struct BiomeNodeView: View {
    let title: String
    let emoji: String
    let accentColor: Color
    let isLocked: Bool
    let isCurrent: Bool
    let action: () -> Void

    @State private var breathing = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Circle()
                    .fill(isLocked ? Color.secondary.opacity(0.2) : accentColor)
                    .frame(width: 116, height: 116)
                    .overlay(
                        Text(emoji)
                            .font(.system(size: 56))
                            .saturation(isLocked ? 0 : 1)
                            .opacity(isLocked ? 0.4 : 1)
                    )
                    .opacity(isCurrent ? (breathing ? 1.0 : 0.82) : 1.0)
                    .animation(
                        isCurrent ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true) : .default,
                        value: breathing
                    )

                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(isLocked ? .secondary : .primary)
            }
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
        .onAppear { breathing = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isLocked ? "\(title), locked" : title)
        .accessibilityHint(isLocked ? "Keep learning to unlock this place." : "Double tap to start your quest.")
        .accessibilityAddTraits(.isButton)
    }
}
