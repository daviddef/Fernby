import Foundation

/// Picks which mastered node, if any, should get a Coach Moment this quest.
/// Deliberately simple: among mastered nodes whose kind CoachMomentGenerator
/// can build a question for, pick the one reviewed longest ago (or never).
/// This is a Leitner-style "oldest first" rotation, not real spaced
/// repetition with calendar-day intervals — same "coarse for MVP, refine
/// once real usage exists" posture as PlacementEngine took on placement.
@MainActor
enum ReviewScheduler {
    static func dueNode() -> SkillNode? {
        let candidates = SkillGraph.all.filter { node in
            let progress = ProgressStore.shared.progress(for: node.id)
            return progress.mastered && CoachMomentGenerator.supports(node.activityKind)
        }
        return candidates.min { lhs, rhs in
            let lhsDate = referenceDate(for: lhs.id)
            let rhsDate = referenceDate(for: rhs.id)
            return lhsDate < rhsDate
        }
    }

    static func markReviewed(_ nodeID: String) {
        var progress = ProgressStore.shared.progress(for: nodeID)
        progress.lastReviewedAt = Date()
        ProgressStore.shared.update(progress)
    }

    private static func referenceDate(for nodeID: String) -> Date {
        let progress = ProgressStore.shared.progress(for: nodeID)
        return progress.lastReviewedAt ?? progress.masteredAt ?? .distantPast
    }
}
