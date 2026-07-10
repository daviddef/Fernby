import SwiftUI

/// A stop on the trail — and, unlike v0.1's two placeholder biomes, a real
/// gate: each one unlocks when a specific pair of skill nodes (one reading,
/// one math, the pair a learner naturally reaches together) is mastered.
/// Biomes don't hold separate content of their own — `ProgressStore.
/// currentNode(for:)` already walks the same linear chains in the same
/// order — so this is a presentation layer over real progress, not a
/// second progression system to keep in sync with the first.
struct Biome: Identifiable {
    let id: String
    let title: String
    let emoji: String
    let accentColor: Color
    /// Nodes that must BOTH be mastered for this biome to unlock. Empty
    /// means "always unlocked" — the trailhead.
    let gateNodeIDs: [String]

    @MainActor
    func isUnlocked(_ store: ProgressStore) -> Bool {
        gateNodeIDs.allSatisfy { store.progress(for: $0).mastered }
    }

    static let all: [Biome] = [
        Biome(
            id: "whisperingWoods", title: "Whispering Woods", emoji: "🌳",
            accentColor: Color(red: 0.36, green: 0.62, blue: 0.42),
            gateNodeIDs: []
        ),
        Biome(
            id: "sunnyMeadow", title: "Sunny Meadow", emoji: "🌻",
            accentColor: Color(red: 0.93, green: 0.72, blue: 0.28),
            gateNodeIDs: ["reading.letterSounds", "math.counting"]
        ),
        Biome(
            id: "pebbleCreek", title: "Pebble Creek", emoji: "🐚",
            accentColor: Color(red: 0.33, green: 0.66, blue: 0.71),
            gateNodeIDs: ["reading.digraphSounds", "math.numberID"]
        ),
        Biome(
            id: "fireflyGrove", title: "Firefly Grove", emoji: "✨",
            accentColor: Color(red: 0.54, green: 0.46, blue: 0.74),
            gateNodeIDs: ["reading.blending", "math.shapes"]
        ),
        Biome(
            id: "starHollow", title: "Star Hollow", emoji: "⭐️",
            accentColor: Color(red: 0.82, green: 0.5, blue: 0.18),
            gateNodeIDs: ["reading.blendWords", "math.addition"]
        ),
        Biome(
            id: "moonlitMarsh", title: "Moonlit Marsh", emoji: "🌙",
            accentColor: Color(red: 0.28, green: 0.32, blue: 0.58),
            gateNodeIDs: ["reading.sightWords", "math.skipCounting"]
        ),
        Biome(
            id: "rainbowFalls", title: "Rainbow Falls", emoji: "🌈",
            accentColor: Color(red: 0.93, green: 0.44, blue: 0.55),
            gateNodeIDs: ["reading.sightWordsAdvanced", "math.subtraction"]
        ),
        Biome(
            id: "coralCove", title: "Coral Cove", emoji: "🪸",
            accentColor: Color(red: 0.86, green: 0.45, blue: 0.38),
            gateNodeIDs: ["reading.cvcWords", "math.placeValue"]
        ),
        Biome(
            id: "sandyDune", title: "Sandy Dune", emoji: "🏜️",
            accentColor: Color(red: 0.78, green: 0.65, blue: 0.42),
            gateNodeIDs: ["reading.digraphWords", "math.measurement"]
        ),
        Biome(
            id: "twilightTerrace", title: "Twilight Terrace", emoji: "🌆",
            accentColor: Color(red: 0.65, green: 0.45, blue: 0.55),
            gateNodeIDs: ["reading.sightWordsTier3", "math.time"]
        ),
        Biome(
            id: "goldenHarbor", title: "Golden Harbor", emoji: "🪙",
            accentColor: Color(red: 0.85, green: 0.68, blue: 0.32),
            gateNodeIDs: ["reading.sightWordsTier4", "math.money"]
        ),
    ]

    /// The last biome has no 6th biome to gate, so its own "finish line" is
    /// this capstone pair instead of a `gateNodeIDs` list belonging to a
    /// biome further down the trail.
    static let capstoneNodeIDs = ["reading.sentences", "math.wordProblems"]

    /// What finishes THIS biome — the next biome's gate pair, or the
    /// capstone pair if this is the last biome. Note this is deliberately
    /// *not* `gateNodeIDs`, which is the pair that unlocks entry into this
    /// biome (i.e. what finished the *previous* one).
    private var completionNodeIDs: [String] {
        guard let index = Biome.all.firstIndex(where: { $0.id == id }) else { return [] }
        let nextIndex = index + 1
        return nextIndex < Biome.all.count ? Biome.all[nextIndex].gateNodeIDs : Biome.capstoneNodeIDs
    }

    /// The biome whose completion line `nodeID` sits on, if any — call
    /// right after a node masters to check whether that mastery just
    /// finished a whole biome, not only a single node.
    @MainActor
    static func biomeCompleted(by nodeID: String, in store: ProgressStore) -> Biome? {
        all.first { biome in
            biome.completionNodeIDs.contains(nodeID)
                && biome.completionNodeIDs.allSatisfy { store.progress(for: $0).mastered }
        }
    }
}
