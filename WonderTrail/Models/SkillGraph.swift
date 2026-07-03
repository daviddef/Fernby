import Foundation

/// The two skill chains a learner progresses through. Each chain is a simple
/// ordered list, not a general graph — one node unlocks the next in the same
/// subject, nothing branches. v0.1 only ships playable activities for
/// `reading.letterSounds` and `math.addition`; the rest of the chain exists so
/// placement and the world map have real structure to grow into.
enum SkillGraph {
    static let reading: [SkillNode] = [
        SkillNode(id: "reading.letterSounds", subject: .reading, title: "Letter Sounds", order: 0, activityKind: .letterSoundMatch),
        SkillNode(id: "reading.blending", subject: .reading, title: "Blending", order: 1, activityKind: .wordBuilding),
        SkillNode(id: "reading.sightWords", subject: .reading, title: "Sight Words", order: 2, activityKind: .sightWordTap),
        SkillNode(id: "reading.cvcWords", subject: .reading, title: "CVC Words", order: 3, activityKind: .wordBuilding),
        SkillNode(id: "reading.sentences", subject: .reading, title: "Simple Sentences", order: 4, activityKind: .sentenceBuild),
    ]

    static let math: [SkillNode] = [
        SkillNode(id: "math.counting", subject: .math, title: "Counting", order: 0, activityKind: .countingTap),
        SkillNode(id: "math.numberID", subject: .math, title: "Number ID", order: 1, activityKind: .numberIDTap),
        SkillNode(id: "math.addition", subject: .math, title: "Addition", order: 2, activityKind: .additionTap),
        SkillNode(id: "math.subtraction", subject: .math, title: "Subtraction", order: 3, activityKind: .subtractionTap),
        SkillNode(id: "math.wordProblems", subject: .math, title: "Word Problems", order: 4, activityKind: .wordProblemStep),
    ]

    static var all: [SkillNode] { reading + math }

    /// Nodes with a shipped, playable activity view. Everything else in the
    /// chain exists as data but isn't reachable in v0.1.
    static let playableIDs: Set<String> = ["reading.letterSounds", "math.addition"]

    static func chain(for subject: Subject) -> [SkillNode] {
        subject == .reading ? reading : math
    }

    static func node(id: String) -> SkillNode? {
        all.first { $0.id == id }
    }

    /// The next node in the same subject's chain, if any.
    static func node(after id: String) -> SkillNode? {
        guard let current = node(id: id) else { return nil }
        return chain(for: current.subject).first { $0.order == current.order + 1 }
    }

    /// The first node in a subject's chain — where placement always starts probing.
    static func firstNode(for subject: Subject) -> SkillNode {
        chain(for: subject).first { $0.order == 0 }!
    }
}
