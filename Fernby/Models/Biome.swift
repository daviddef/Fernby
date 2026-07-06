import Foundation

/// A stop on the world map. v0.1 shipped exactly one biome as a hardcoded
/// view; this is the seam it said it would grow into (see WorldMapView's
/// original comment). Biomes don't yet gate distinct content — every biome
/// still opens the same reading/math quest pool from SkillGraph — this is
/// meta-progression scaffolding, honestly labeled as such, to test whether
/// map progression itself pulls a child back for a second session before
/// content is built to back it up.
struct Biome: Identifiable {
    let id: String
    let title: String
    let emoji: String
    /// Whether this biome is unlocked, given current progress.
    let isUnlocked: @MainActor (ProgressStore) -> Bool

    static let all: [Biome] = [
        Biome(id: "whisperingWoods", title: "Whispering Woods", emoji: "🌳", isUnlocked: { _ in true }),
        Biome(id: "sunnyMeadow", title: "Sunny Meadow", emoji: "🌻", isUnlocked: { store in
            store.nodeProgress.values.contains { $0.mastered }
        }),
    ]
}
