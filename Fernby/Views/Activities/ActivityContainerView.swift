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
    /// Uniquely identifies this occurrence, distinct from `node.id` — a
    /// quest can serve the same node more than once in a row (multiple
    /// reps per subject, or a placement probe that repeats after a miss),
    /// and keying `.id()` on `node.id` alone would make SwiftUI treat two
    /// consecutive reps of the same node as the same view instance, so
    /// `onAppear` (and the fresh question it sets up) wouldn't refire.
    let instanceID: AnyHashable
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @ObservedObject private var progressStore = ProgressStore.shared

    private var difficultyLevel: Int {
        progressStore.progress(for: node.id).difficultyLevel
    }

    var body: some View {
        Group {
            switch node.activityKind {
            case .letterTracing:
                LetterTracingView(onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .letterSoundMatch:
                LetterSoundMatchView(onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .wordBuilding:
                WordBuildingView(nodeID: node.id, onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .sightWordTap:
                SightWordTapView(onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .sentenceBuild:
                SentenceBuildView(onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .countingTap:
                CountingTapView(difficultyLevel: difficultyLevel, onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .numberIDTap:
                NumberIDTapView(difficultyLevel: difficultyLevel, onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .additionTap:
                AdditionTapView(difficultyLevel: difficultyLevel, onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .subtractionTap:
                SubtractionTapView(difficultyLevel: difficultyLevel, onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            case .wordProblemStep:
                WordProblemStepView(difficultyLevel: difficultyLevel, onFirstResponse: onFirstResponse, onAdvance: onAdvance)
            }
        }
        .id(instanceID) // fresh identity per occurrence, even repeats of the same node
    }
}
