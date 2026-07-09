import Foundation

/// Whole words built from DigraphBank patterns — the fluency step after
/// meeting each digraph in isolation, same relationship WordBuildingBank
/// has to PhonicsBank.
enum DigraphWordBank {
    static let all: [BuildableWord] = [
        BuildableWord(word: "ship", emoji: "🚢", letters: ["sh", "i", "p"]),
        BuildableWord(word: "shop", emoji: "🏪", letters: ["sh", "o", "p"]),
        BuildableWord(word: "dish", emoji: "🍽️", letters: ["d", "i", "sh"]),
        BuildableWord(word: "chip", emoji: "🍟", letters: ["ch", "i", "p"]),
        BuildableWord(word: "bath", emoji: "🛁", letters: ["b", "a", "th"]),
        BuildableWord(word: "king", emoji: "👑", letters: ["k", "i", "ng"]),
        BuildableWord(word: "ring", emoji: "💍", letters: ["r", "i", "ng"]),
        BuildableWord(word: "rain", emoji: "🌧️", letters: ["r", "ai", "n"]),
        BuildableWord(word: "train", emoji: "🚂", letters: ["t", "r", "ai", "n"]),
        BuildableWord(word: "feet", emoji: "🦶", letters: ["f", "ee", "t"]),
        BuildableWord(word: "night", emoji: "🌙", letters: ["n", "igh", "t"]),
        BuildableWord(word: "coat", emoji: "🧥", letters: ["c", "oa", "t"]),
        BuildableWord(word: "pool", emoji: "🏊", letters: ["p", "oo", "l"]),
        BuildableWord(word: "star", emoji: "⭐️", letters: ["s", "t", "ar"]),
        BuildableWord(word: "corn", emoji: "🌽", letters: ["c", "or", "n"]),
        BuildableWord(word: "owl", emoji: "🦉", letters: ["ow", "l"]),
        BuildableWord(word: "coin", emoji: "🪙", letters: ["c", "oi", "n"]),
    ]

    static func random(avoiding recent: Set<String> = []) -> BuildableWord {
        all.random(avoiding: recent)
    }

    static func decoys(excluding target: BuildableWord, count: Int) -> [BuildableWord] {
        all.decoys(excluding: target, count: count)
    }
}
