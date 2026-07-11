import SwiftUI

/// A daily quest: the learner's current node in each chain, repeated
/// `repsPerSubject` times and interleaved. `ActivityContainerView` is the
/// only place that knows how to render a given node; this view just
/// sequences steps and records results.
@MainActor
final class DailyQuestViewModel: ObservableObject {
    /// Multiple reps per subject per quest, rather than one, so mastering a
    /// node takes roughly one to two quests instead of the fifteen separate
    /// sessions the old one-rep pacing needed (see DifficultyEngine).
    /// Interleaved reading/math/reading/math/... rather than blocked, so a
    /// longer quest still feels varied rather than "all reading then all
    /// math."
    static let repsPerSubject = 3

    @Published var currentIndex: Int = 0
    @Published var sessionCorrectCount: Int = 0
    let activities: [SkillNode]
    let startedAt = Date()

    init() {
        let reading = ProgressStore.shared.currentNode(for: .reading)
        let math = ProgressStore.shared.currentNode(for: .math)
        activities = (0..<Self.repsPerSubject).flatMap { _ in [reading, math] }
    }

    var currentNode: SkillNode? {
        currentIndex < activities.count ? activities[currentIndex] : nil
    }

    var isComplete: Bool { currentIndex >= activities.count }

    func advance() {
        currentIndex += 1
    }
}

struct DailyQuestView: View {
    let onComplete: () -> Void

    @StateObject private var viewModel = DailyQuestViewModel()
    @State private var justMasteredNodeIDs: [String] = []
    @State private var justCompletedBiomes: [Biome] = []
    @State private var hasLoggedSession = false
    @State private var coachMomentNode: SkillNode?
    @State private var hasShownCoachMoment = false
    @State private var hasShownBonusRound = false
    // Placeholder — the real pick happens in onAppear, since it needs to
    // check Voice.shared.enabled (MainActor-isolated, not safe to read from
    // a property initializer) to exclude Listen and Point when muted: that
    // bonus game is audio-only by design (see ListenAndPointView), so it's
    // an unplayable dead end — no visual prompt, and "Hear it again" is
    // silent too — for anyone who's turned spoken instructions off.
    @State private var bonusGame: BonusGame = .matching

    var body: some View {
        Group {
            if let node = viewModel.currentNode {
                ActivityContainerView(
                    node: node,
                    instanceID: viewModel.currentIndex,
                    onFirstResponse: { correct in
                        if correct { viewModel.sessionCorrectCount += 1 }
                        let justMastered = DifficultyEngine.recordResult(nodeID: node.id, correct: correct)
                        if justMastered {
                            justMasteredNodeIDs.append(node.id)
                            if let biome = Biome.biomeCompleted(by: node.id, in: ProgressStore.shared) {
                                justCompletedBiomes.append(biome)
                            }
                            Haptics.shared.masteryUnlock()
                        }
                    },
                    onAdvance: {
                        ProgressStore.shared.recordActivityCompleted()
                        viewModel.advance()
                    }
                )
            } else if let coachNode = coachMomentNode, !hasShownCoachMoment {
                CoachMomentView(node: coachNode, onDone: { hasShownCoachMoment = true })
            } else if !hasShownBonusRound {
                bonusRoundView
            } else {
                QuestSummaryView(
                    correctCount: viewModel.sessionCorrectCount,
                    totalCount: viewModel.activities.count,
                    masteredNodeTitles: justMasteredNodeIDs.compactMap { SkillGraph.node(id: $0)?.title },
                    justCompletedBiomes: justCompletedBiomes,
                    onDone: onComplete
                )
                .onAppear { logSessionIfNeeded() }
            }
        }
        .onAppear {
            Haptics.shared.prepareAll()
            coachMomentNode = ReviewScheduler.dueNode()
            bonusGame = BonusGame.eligible(voiceEnabled: Voice.shared.enabled).randomElement()!
        }
    }

    private var bonusRoundView: some View {
        BonusGameContainerView(game: bonusGame, onDone: { hasShownBonusRound = true })
    }

    private func logSessionIfNeeded() {
        guard !hasLoggedSession else { return }
        hasLoggedSession = true
        SessionLog.shared.record(SessionEntry(
            nodeIDs: viewModel.activities.map(\.id),
            correctCount: viewModel.sessionCorrectCount,
            totalCount: viewModel.activities.count,
            durationSeconds: Date().timeIntervalSince(viewModel.startedAt)
        ))
    }
}
