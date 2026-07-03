import SwiftUI

/// The single seam every activity type plugs into: a switch over
/// `SkillNode.activityKind`. Daily quests, placement probes, and (later)
/// any new activity all route through here so the surrounding quest flow
/// stays activity-agnostic.
///
/// Contract every activity view follows:
/// - `onFirstResponse(Bool)` fires exactly once, for the learner's first tap
///   on a fresh question — this is what difficulty/placement tracking uses.
/// - `onAdvance()` fires once the question has ultimately been answered
///   correctly (after as many gentle retries as needed) and it's time to
///   move to the next activity. Wrong answers never end an activity; they
///   just ask the same question again.
struct ActivityContainerView: View {
    let node: SkillNode
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @ObservedObject private var progressStore = ProgressStore.shared

    private var difficultyLevel: Int {
        progressStore.progress(for: node.id).difficultyLevel
    }

    var body: some View {
        Group {
            switch node.activityKind {
            case .letterSoundMatch:
                LetterSoundMatchView(onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .additionTap:
                AdditionTapView(difficultyLevel: difficultyLevel, onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .wordBuilding, .sightWordTap, .sentenceBuild, .countingTap, .numberIDTap, .subtractionTap, .wordProblemStep:
                // Not built yet (v0.2) — placeholder so the chain never dead-ends.
                ComingSoonActivityView(node: node, onAdvance: onAdvance)
            }
        }
        .id(node.id) // fresh identity per node so activity state resets between probes
    }
}

/// Stand-in for activity kinds not yet implemented (v0.2). Auto-advances so
/// the daily quest / placement flow can still be exercised end to end while
/// content is being built out.
private struct ComingSoonActivityView: View {
    let node: SkillNode
    let onAdvance: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("\(node.title) is on the way!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Button("Continue") { onAdvance() }
                .buttonStyle(.bigTap)
        }
        .padding()
    }
}
