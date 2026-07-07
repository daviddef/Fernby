import Foundation

/// Rule-based, per-item difficulty adjustment and mastery gate. No ML —
/// two in a row correct steps difficulty up (and masters the node at the
/// top of its range); three in a row wrong gently steps difficulty back
/// down. Never goes below level 1.
///
/// Originally masteryStreak=3, maxDifficulty=5 — 15 correct first-attempts
/// to master one node, and a quest only gave one first-attempt per
/// subject, so mastering a single node took 15 separate quest sessions.
/// With 11 nodes total, later content (subtraction, sentences, the last
/// two biomes) was practically unreachable in any real playtest. Now 6
/// correct first-attempts per node (masteryStreak=2 × maxDifficulty=3),
/// paired with multiple reps per subject per quest (see DailyQuestView),
/// so a node masters in roughly one to two quests instead of fifteen.
///
/// In-activity retries of the *same* question (see activity views) are not
/// reported here as a fresh incorrect result — only the learner's first
/// response to a given item counts, so a slip never cascades into a
/// demotion. This is what keeps failure low-stakes end to end, not just
/// visually.
@MainActor
enum DifficultyEngine {
    static let masteryStreak = 2
    static let demoteStreak = 3
    static let maxDifficulty = 3
    static let minDifficulty = 1

    /// Returns true if this result just mastered the node (i.e. unlocked the next one).
    @discardableResult
    static func recordResult(nodeID: String, correct: Bool) -> Bool {
        var progress = ProgressStore.shared.progress(for: nodeID)
        progress.totalAttempts += 1

        var justMastered = false

        if correct {
            progress.totalCorrect += 1
            progress.correctStreak += 1
            progress.incorrectStreak = 0

            if progress.correctStreak >= masteryStreak {
                if progress.difficultyLevel < maxDifficulty {
                    progress.difficultyLevel += 1
                    progress.correctStreak = 0
                } else {
                    progress.mastered = true
                    progress.masteredAt = Date()
                    justMastered = true
                }
            }
        } else {
            progress.incorrectStreak += 1
            progress.correctStreak = 0

            if progress.incorrectStreak >= demoteStreak, progress.difficultyLevel > minDifficulty {
                progress.difficultyLevel -= 1
                progress.incorrectStreak = 0
            }
        }

        ProgressStore.shared.update(progress)
        return justMastered
    }
}
