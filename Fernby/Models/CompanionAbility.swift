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
        CompanionAbility(nodeID: "reading.digraphSounds", verb: "say two-letter sounds like \"sh\" and \"ch\""),
        CompanionAbility(nodeID: "reading.blending", verb: "blend sounds into a word"),
        CompanionAbility(nodeID: "reading.blendWords", verb: "read words with blended sounds like \"frog\""),
        CompanionAbility(nodeID: "reading.sightWords", verb: "read tricky words on sight"),
        CompanionAbility(nodeID: "reading.sightWordsAdvanced", verb: "read even more tricky words on sight"),
        CompanionAbility(nodeID: "reading.cvcWords", verb: "read whole three-letter words"),
        CompanionAbility(nodeID: "reading.digraphWords", verb: "read words with two-letter sounds"),
        CompanionAbility(nodeID: "reading.sightWordsTier3", verb: "read a whole new set of tricky words"),
        CompanionAbility(nodeID: "reading.sightWordsTier4", verb: "read some of the trickiest words yet"),
        CompanionAbility(nodeID: "reading.sentences", verb: "read a whole sentence"),
        CompanionAbility(nodeID: "math.counting", verb: "count a group of objects"),
        CompanionAbility(nodeID: "math.numberID", verb: "match a number to its name"),
        CompanionAbility(nodeID: "math.shapes", verb: "name shapes like circles and triangles"),
        CompanionAbility(nodeID: "math.addition", verb: "add two numbers together"),
        CompanionAbility(nodeID: "math.skipCounting", verb: "count by 2s, 5s, and 10s"),
        CompanionAbility(nodeID: "math.subtraction", verb: "take away and find what's left"),
        CompanionAbility(nodeID: "math.placeValue", verb: "understand tens and ones"),
        CompanionAbility(nodeID: "math.measurement", verb: "compare which is longer or shorter"),
        CompanionAbility(nodeID: "math.time", verb: "tell time on a clock"),
        CompanionAbility(nodeID: "math.money", verb: "count coins and add up money"),
        CompanionAbility(nodeID: "math.dataGraphs", verb: "read a picture graph"),
        CompanionAbility(nodeID: "math.multiplication", verb: "count equal groups"),
        CompanionAbility(nodeID: "math.wordProblems", verb: "solve a story problem"),
    ]

    static func ability(for nodeID: String) -> CompanionAbility? {
        all.first { $0.nodeID == nodeID }
    }
}
