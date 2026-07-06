import Foundation

/// Rolling mastery tracking for a single skill node. `difficultyLevel` runs
/// 1...5 within the node; hitting the mastery streak at level 5 marks the
/// node mastered, which is what unlocks the next node in its chain.
struct NodeProgress: Codable {
    var nodeID: String
    var correctStreak: Int = 0
    var incorrectStreak: Int = 0
    var totalAttempts: Int = 0
    var totalCorrect: Int = 0
    var difficultyLevel: Int = 1
    var mastered: Bool = false
    var masteredAt: Date?
    /// When this node was last served as a Coach Moment review (see
    /// ReviewScheduler). Optional so it decodes safely against progress
    /// saved before this field existed — nil just means "never reviewed."
    var lastReviewedAt: Date?

    init(nodeID: String) {
        self.nodeID = nodeID
    }
}
