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

    /// Continues the same synthetic-phonics sequence tier1 started —
    /// s,a,t,p,i,n,m,d,g,o,c,k is the standard Phase 2 set, chosen because
    /// these twelve letters alone can already spell dozens of real CVC
    /// words (see WordBuildingBank). "c" is deliberately taught with the
    /// same sound as "k" — that's the real early-phonics point (two
    /// spellings, one sound), not a data-entry mistake.
    static let tier2: [LetterSoundEntry] = [
        LetterSoundEntry(letter: "m", sound: "mmm", exampleWord: "Moon", emoji: "🌙"),
        LetterSoundEntry(letter: "d", sound: "d", exampleWord: "Duck", emoji: "🦆"),
        LetterSoundEntry(letter: "g", sound: "g", exampleWord: "Goat", emoji: "🐐"),
        LetterSoundEntry(letter: "o", sound: "o", exampleWord: "Octopus", emoji: "🐙"),
        LetterSoundEntry(letter: "c", sound: "k", exampleWord: "Cat", emoji: "🐱"),
        LetterSoundEntry(letter: "k", sound: "k", exampleWord: "Kite", emoji: "🪁"),
    ]

    /// Completes the real Phase 2 set (tier1+tier2+tier3 = 19 letters,
    /// matching the standard synthetic-phonics scope) rather than stopping
    /// at 12 — these seven letters are what turn WordBuildingBank from "a
    /// dozen 3-letter words" into genuine blend-word territory (run, hat,
    /// bed, help, frog, milk...), since blends need more raw letters than
    /// s/a/t/p/i/n/m/d/g/o/c/k alone can spell.
    static let tier3: [LetterSoundEntry] = [
        LetterSoundEntry(letter: "e", sound: "eh", exampleWord: "Egg", emoji: "🥚"),
        LetterSoundEntry(letter: "u", sound: "uh", exampleWord: "Umbrella", emoji: "☂️"),
        LetterSoundEntry(letter: "r", sound: "rrr", exampleWord: "Rabbit", emoji: "🐰"),
        LetterSoundEntry(letter: "h", sound: "h", exampleWord: "Hat", emoji: "🎩"),
        LetterSoundEntry(letter: "b", sound: "b", exampleWord: "Ball", emoji: "⚽️"),
        LetterSoundEntry(letter: "f", sound: "f", exampleWord: "Fish", emoji: "🐟"),
        LetterSoundEntry(letter: "l", sound: "l", exampleWord: "Leaf", emoji: "🍃"),
    ]

    static var all: [LetterSoundEntry] { tier1 + tier2 + tier3 }

    static func entry(for letter: String) -> LetterSoundEntry? {
        all.first { $0.letter == letter }
    }

    /// A random entry to probe/practice, optionally avoiding recently seen ones.
    static func random(avoiding recent: Set<String> = []) -> LetterSoundEntry {
        all.random(avoiding: recent)
    }

    /// `count` decoy entries distinct from the target — the wrong-answer tiles.
    static func decoys(excluding target: LetterSoundEntry, count: Int) -> [LetterSoundEntry] {
        all.decoys(excluding: target, count: count)
    }
}
