import Foundation

/// Drives the invisible first-quest calibration: no diagnostic test screen,
/// just a handful of normal-looking activities that decide where a child
/// starts. Per subject, 3 probes run a coarse probe-and-promote ladder — a
/// first-try-correct promotes the *next* probe to the next node in the
/// chain rather than repeating the same node; an incorrect first try keeps
/// probing the same node. After 3 probes per subject (6 items total), the
/// highest first-try-correct node becomes the unlocked-through point, and
/// everything below it is retroactively marked mastered so a child who
/// already knows the material doesn't have to repeat it.
///
/// This is intentionally coarse for MVP — a placement, not a full adaptive
/// test — and can be refined later if real usage shows kids landing in
/// clearly wrong spots.
@MainActor
final class PlacementEngine: ObservableObject {
    static let probesPerSubject = 3

    private var probesRemaining: [Subject: Int] = [.reading: probesPerSubject, .math: probesPerSubject]
    private var currentNode: [Subject: SkillNode] = [
        .reading: SkillGraph.firstNode(for: .reading),
        .math: SkillGraph.firstNode(for: .math),
    ]
    private var highestReached: [Subject: SkillNode] = [:]

    /// The node to probe next for a subject, or nil once that subject's probes are used up.
    func nextProbe(for subject: Subject) -> SkillNode? {
        guard (probesRemaining[subject] ?? 0) > 0 else { return nil }
        return currentNode[subject]
    }

    /// Record whether the learner's *first* response to the current probe was
    /// correct (in-activity retries don't count), and advance the ladder.
    func recordProbeResult(subject: Subject, firstTryCorrect: Bool) {
        guard let node = currentNode[subject] else { return }
        if firstTryCorrect {
            highestReached[subject] = node
            if let next = SkillGraph.node(after: node.id) {
                currentNode[subject] = next
            }
        }
        probesRemaining[subject] = max(0, (probesRemaining[subject] ?? 0) - 1)
    }

    var isComplete: Bool {
        (probesRemaining[.reading] ?? 0) == 0 && (probesRemaining[.math] ?? 0) == 0
    }

    /// Writes the placement result into ProgressStore and flips
    /// `hasCompletedPlacement`. Call once, after `isComplete`.
    func finalize() {
        for subject in [Subject.reading, .math] {
            guard let reached = highestReached[subject] else { continue }
            let chain = SkillGraph.chain(for: subject)
            for node in chain where node.order < reached.order {
                ProgressStore.shared.markMastered(nodeID: node.id)
            }
            var seeded = ProgressStore.shared.progress(for: reached.id)
            seeded.correctStreak = 1
            ProgressStore.shared.update(seeded)
        }
        ProgressStore.shared.markPlacementCompleted()
    }
}
