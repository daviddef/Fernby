import SwiftUI

/// Renders the companion at its current growth stage with a slow idle bob —
/// native SwiftUI animation, no Lottie, matching this developer's
/// zero-dependency convention across all sibling projects.
struct CompanionView: View {
    @ObservedObject var progressStore: ProgressStore
    var size: CGFloat = 140
    var showsName: Bool = false

    @State private var bobbing = false

    private var stage: CompanionStage {
        CompanionStage.stage(for: progressStore.companion.growthStage)
    }

    var body: some View {
        VStack(spacing: 6) {
            CompanionArtView(stage: stage, size: size)
                .offset(y: bobbing ? -4 : 4)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: bobbing)
                .onAppear { bobbing = true }

            if showsName {
                Text(stage.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
