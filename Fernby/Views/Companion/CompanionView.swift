import SwiftUI

/// Renders the companion at its current growth stage with a slow idle bob —
/// native SwiftUI animation, no Lottie, matching this developer's
/// zero-dependency convention across all sibling projects.
struct CompanionView: View {
    @ObservedObject var progressStore: ProgressStore
    var size: CGFloat = 140
    var showsName: Bool = false
    /// Off by default wherever a sibling view changes shape shortly after
    /// appearing (e.g. CoachMomentView's brief ProgressView-to-question
    /// transition) — starting this continuous offset animation before the
    /// surrounding layout has settled leaves the rendered layer visually
    /// stuck at its pre-transition position even though the view tree (and
    /// hit-testing) correctly reflects the new layout, a real bug caught
    /// from an on-device screenshot: the companion's face appeared detached
    /// from its own frame, overlapping unrelated text below it.
    var bobs: Bool = true

    @State private var bobbing = false

    private var stage: CompanionStage {
        CompanionStage.stage(for: progressStore.companion.growthStage)
    }

    var body: some View {
        VStack(spacing: 6) {
            CompanionArtView(stage: stage, size: size)
                .overlay(alignment: .top) {
                    if let emoji = progressStore.companion.selectedAccessory.emoji {
                        Text(emoji)
                            .font(.system(size: size * 0.32))
                            .offset(y: -size * 0.12)
                            .accessibilityHidden(true)
                    }
                }
                .offset(y: bobs && bobbing ? -4 : 4)
                .animation(bobs ? .easeInOut(duration: 1.6).repeatForever(autoreverses: true) : nil, value: bobbing)
                .onAppear { if bobs { bobbing = true } }

            if showsName {
                Text(stage.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showsName ? "Your companion, \(stage.name)" : "Your companion")
    }
}
