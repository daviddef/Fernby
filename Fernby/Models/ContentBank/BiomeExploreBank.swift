import Foundation

struct BiomeExploreDetail {
    let emoji: String
    let line: String
}

/// Three whimsical, tappable details per biome — purely decorative fun
/// once a biome is unlocked, no reading/math gating, no score, nothing to
/// get wrong. "Look around the place you built," not another lesson.
enum BiomeExploreBank {
    static func details(for biomeID: String) -> [BiomeExploreDetail] {
        table[biomeID] ?? []
    }

    private static let table: [String: [BiomeExploreDetail]] = [
        "whisperingWoods": [
            BiomeExploreDetail(emoji: "🐿️", line: "A squirrel says hello!"),
            BiomeExploreDetail(emoji: "🍄", line: "A tiny mushroom pops up!"),
            BiomeExploreDetail(emoji: "🦉", line: "An owl blinks slowly."),
        ],
        "sunnyMeadow": [
            BiomeExploreDetail(emoji: "🐝", line: "Buzzy bee says hi!"),
            BiomeExploreDetail(emoji: "🦋", line: "A butterfly flutters by!"),
            BiomeExploreDetail(emoji: "🐞", line: "A ladybug waves its spots!"),
        ],
        "pebbleCreek": [
            BiomeExploreDetail(emoji: "🐟", line: "A fish splashes!"),
            BiomeExploreDetail(emoji: "🦆", line: "A duck paddles past!"),
            BiomeExploreDetail(emoji: "🐢", line: "A turtle peeks out!"),
        ],
        "fireflyGrove": [
            BiomeExploreDetail(emoji: "✨", line: "Fireflies twinkle all around!"),
            BiomeExploreDetail(emoji: "🦔", line: "A hedgehog rolls by!"),
            BiomeExploreDetail(emoji: "🌙", line: "The moon peeks through the leaves!"),
        ],
        "starHollow": [
            BiomeExploreDetail(emoji: "⭐️", line: "A star twinkles just for you!"),
            BiomeExploreDetail(emoji: "🦉", line: "A sleepy owl hoots!"),
            BiomeExploreDetail(emoji: "🌌", line: "The whole sky sparkles!"),
        ],
        "moonlitMarsh": [
            BiomeExploreDetail(emoji: "🐸", line: "A frog croaks hello!"),
            BiomeExploreDetail(emoji: "🌙", line: "The moon glows softly!"),
            BiomeExploreDetail(emoji: "🦗", line: "A cricket chirps!"),
        ],
        "rainbowFalls": [
            BiomeExploreDetail(emoji: "🌈", line: "A rainbow shimmers!"),
            BiomeExploreDetail(emoji: "💧", line: "A waterdrop sparkles!"),
            BiomeExploreDetail(emoji: "🐠", line: "A colorful fish swims by!"),
        ],
        "coralCove": [
            BiomeExploreDetail(emoji: "🐚", line: "A shell hums like the ocean!"),
            BiomeExploreDetail(emoji: "🦀", line: "A crab scuttles by!"),
            BiomeExploreDetail(emoji: "🐙", line: "An octopus waves hello!"),
        ],
        "sandyDune": [
            BiomeExploreDetail(emoji: "🐪", line: "A camel strolls by!"),
            BiomeExploreDetail(emoji: "🌵", line: "A cactus stands tall!"),
            BiomeExploreDetail(emoji: "🦎", line: "A little lizard suns itself!"),
        ],
    ]
}
