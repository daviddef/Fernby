import Foundation

/// The mechanic this whole app is built to test: the companion doesn't grow
/// from a points counter, it grows because it can now genuinely *do*
/// something new — one line per skill node, unlocked the moment that node's
/// NodeProgress flips to mastered. Nothing here is separately persisted;
/// an ability exists exactly when its node is mastered, so there is no way
/// for the companion to know something the child hasn't actually learned.
struct CompanionAbility {
    let nodeID: String
    /// What the companion can now do, phrased as something the child taught
    /// it — read aloud and shown in the Companion Journal.
    let verb: String
}

enum CompanionAbilityCatalog {
    /// The companion's name is fixed for now — letting a child name their
    /// own companion is a natural next step, not this pass.
    static let companionName = "Fern"

    static let all: [CompanionAbility] = [
        CompanionAbility(nodeID: "reading.letterTracing", verb: "trace the shape of a letter"),
        CompanionAbility(nodeID: "reading.letterSounds", verb: "say letter sounds out loud"),
        CompanionAbility(nodeID: "reading.blending", verb: "blend sounds into a word"),
        CompanionAbility(nodeID: "reading.sightWords", verb: "read tricky words on sight"),
        CompanionAbility(nodeID: "reading.cvcWords", verb: "read whole three-letter words"),
        CompanionAbility(nodeID: "reading.sentences", verb: "read a whole sentence"),
        CompanionAbility(nodeID: "math.counting", verb: "count a group of objects"),
        CompanionAbility(nodeID: "math.numberID", verb: "match a number to its name"),
        CompanionAbility(nodeID: "math.addition", verb: "add two numbers together"),
        CompanionAbility(nodeID: "math.subtraction", verb: "take away and find what's left"),
        CompanionAbility(nodeID: "math.wordProblems", verb: "solve a story problem"),
    ]

    static func ability(for nodeID: String) -> CompanionAbility? {
        all.first { $0.nodeID == nodeID }
    }
}
