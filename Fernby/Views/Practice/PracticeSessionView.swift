import SwiftUI

/// One node, played on repeat with zero mastery pressure: `onFirstResponse`
/// is a no-op (so DifficultyEngine.recordResult is never called — nothing
/// about a node's difficulty or mastery state changes from practicing it),
/// and each correct answer immediately serves a fresh question of the same
/// node rather than advancing anywhere. "Done" is always one tap away, no
/// confirmation, no guilt-cue — the free-exit guardrail from the roadmap.
struct PracticeSessionView: View {
    let node: SkillNode
    let onDone: () -> Void

    @State private var round = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(node.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Done") { onDone() }
                    .buttonStyle(.bordered)
            }
            .padding()

            ActivityContainerView(
                node: node,
                instanceID: round,
                onFirstResponse: { _ in },
                onAdvance: { round += 1 }
            )
        }
    }
}
