import SwiftUI

/// A short daily quest: one reading activity, one math activity (v0.1 —
/// v0.2 adds a third, blended word-problem activity once WordProblemStep
/// ships). `ActivityContainerView` is the only place that knows how to
/// render a given node; this view just sequences nodes and records results.
@MainActor
final class DailyQuestViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var sessionCorrectCount: Int = 0
    let activities: [SkillNode]
    let startedAt = Date()

    init() {
        // v0.1: reading + math only, each the learner's current (first
        // non-mastered) node in its chain. A third, blended activity slot
        // joins here once WordProblemStep is built (v0.2).
        activities = [
            ProgressStore.shared.currentNode(for: .reading),
            ProgressStore.shared.currentNode(for: .math),
        ]
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
    @State private var justMasteredNodeID: String?
    @State private var hasLoggedSession = false

    var body: some View {
        Group {
            if let node = viewModel.currentNode {
                ActivityContainerView(
                    node: node,
                    onFirstResponse: { correct in
                        if correct { viewModel.sessionCorrectCount += 1 }
                        let justMastered = DifficultyEngine.recordResult(nodeID: node.id, correct: correct)
                        if justMastered {
                            justMasteredNodeID = node.id
                            Haptics.shared.masteryUnlock()
                        }
                    },
                    onAdvance: {
                        ProgressStore.shared.recordActivityCompleted()
                        viewModel.advance()
                    }
                )
            } else {
                QuestSummaryView(
                    correctCount: viewModel.sessionCorrectCount,
                    totalCount: viewModel.activities.count,
                    masteredNodeTitle: SkillGraph.node(id: justMasteredNodeID ?? "")?.title,
                    onDone: onComplete
                )
                .onAppear { logSessionIfNeeded() }
            }
        }
        .onAppear { Haptics.shared.prepareAll() }
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
