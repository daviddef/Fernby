import Foundation

/// Phase 4 of the sequence — consonant blends. No new sounds are taught
/// here (unlike PhonicsBank/DigraphBank), just new *combinations* of
/// sounds a learner already knows (s+t, f+r, c+r...), so this reuses
/// `BuildableWord` exactly like WordBuildingBank rather than introducing a
/// new content shape.
enum BlendWordBank {
    static let all: [BuildableWord] = [
        BuildableWord(word: "trap", emoji: "🪤", letters: ["t", "r", "a", "p"]),
        BuildableWord(word: "drum", emoji: "🥁", letters: ["d", "r", "u", "m"]),
        BuildableWord(word: "crab", emoji: "🦀", letters: ["c", "r", "a", "b"]),
        BuildableWord(word: "frog", emoji: "🐸", letters: ["f", "r", "o", "g"]),
        BuildableWord(word: "flag", emoji: "🚩", letters: ["f", "l", "a", "g"]),
        BuildableWord(word: "clap", emoji: "👏", letters: ["c", "l", "a", "p"]),
        BuildableWord(word: "glad", emoji: "😊", letters: ["g", "l", "a", "d"]),
        BuildableWord(word: "nest", emoji: "🪺", letters: ["n", "e", "s", "t"]),
        BuildableWord(word: "help", emoji: "🆘", letters: ["h", "e", "l", "p"]),
        BuildableWord(word: "milk", emoji: "🥛", letters: ["m", "i", "l", "k"]),
        BuildableWord(word: "hand", emoji: "✋", letters: ["h", "a", "n", "d"]),
        BuildableWord(word: "sand", emoji: "🏖️", letters: ["s", "a", "n", "d"]),
        BuildableWord(word: "stop", emoji: "🛑", letters: ["s", "t", "o", "p"]),
        BuildableWord(word: "spin", emoji: "🌀", letters: ["s", "p", "i", "n"]),
        BuildableWord(word: "stamp", emoji: "📮", letters: ["s", "t", "a", "m", "p"]),
        BuildableWord(word: "crib", emoji: "🛏️", letters: ["c", "r", "i", "b"]),
        // 12 more real blend words — same content-depth gap as
        // WordBuildingBank, same fix.
        BuildableWord(word: "trip", emoji: "🧳", letters: ["t", "r", "i", "p"]),
        BuildableWord(word: "drop", emoji: "💧", letters: ["d", "r", "o", "p"]),
        BuildableWord(word: "drag", emoji: "🛷", letters: ["d", "r", "a", "g"]),
        BuildableWord(word: "flap", emoji: "🦋", letters: ["f", "l", "a", "p"]),
        BuildableWord(word: "clip", emoji: "📎", letters: ["c", "l", "i", "p"]),
        BuildableWord(word: "clam", emoji: "🦪", letters: ["c", "l", "a", "m"]),
        BuildableWord(word: "band", emoji: "🎸", letters: ["b", "a", "n", "d"]),
        BuildableWord(word: "camp", emoji: "⛺", letters: ["c", "a", "m", "p"]),
        BuildableWord(word: "lamp", emoji: "💡", letters: ["l", "a", "m", "p"]),
        BuildableWord(word: "tent", emoji: "🏕️", letters: ["t", "e", "n", "t"]),
        BuildableWord(word: "desk", emoji: "🖥️", letters: ["d", "e", "s", "k"]),
        BuildableWord(word: "spot", emoji: "📍", letters: ["s", "p", "o", "t"]),
    ]

    static func random(avoiding recent: Set<String> = []) -> BuildableWord {
        all.random(avoiding: recent)
    }

    static func decoys(excluding target: BuildableWord, count: Int) -> [BuildableWord] {
        all.decoys(excluding: target, count: count)
    }
}
