import Foundation

struct LetterSoundEntry: Codable, Equatable {
    let letter: String
    /// Text handed to the speech synthesizer for the isolated phoneme. System
    /// TTS pronunciation of isolated sounds is inconsistent across iOS voice
    /// versions — this is a known MVP risk, worth a manual listening pass per
    /// entry before this app is used for real teaching.
    let sound: String
    let exampleWord: String
    let emoji: String
}

/// Ordered by synthetic-phonics teaching sequence (s, a, t, p, i, n…), not
/// alphabetically — this order lets a beginner start blending real words
/// (sat, tap, pin) after only a handful of letters, which alphabetical order
/// would not.
enum PhonicsBank {
    static let tier1: [LetterSoundEntry] = [
        LetterSoundEntry(letter: "s", sound: "sss", exampleWord: "Sun", emoji: "☀️"),
        LetterSoundEntry(letter: "a", sound: "a", exampleWord: "Apple", emoji: "🍎"),
        LetterSoundEntry(letter: "t", sound: "t", exampleWord: "Tiger", emoji: "🐯"),
        LetterSoundEntry(letter: "p", sound: "p", exampleWord: "Pig", emoji: "🐷"),
        LetterSoundEntry(letter: "i", sound: "ih", exampleWord: "Igloo", emoji: "🧊"),
        LetterSoundEntry(letter: "n", sound: "n", exampleWord: "Net", emoji: "🥅"),
    ]

    static var all: [LetterSoundEntry] { tier1 }

    static func entry(for letter: String) -> LetterSoundEntry? {
        all.first { $0.letter == letter }
    }

    /// A random entry to probe/practice, optionally avoiding recently seen ones.
    static func random(avoiding recent: Set<String> = []) -> LetterSoundEntry {
        let pool = all.filter { !recent.contains($0.letter) }
        return (pool.isEmpty ? all : pool).randomElement()!
    }

    /// `count` decoy entries distinct from the target — the wrong-answer tiles.
    static func decoys(excluding target: LetterSoundEntry, count: Int) -> [LetterSoundEntry] {
        Array(all.filter { $0.letter != target.letter }.shuffled().prefix(count))
    }
}
