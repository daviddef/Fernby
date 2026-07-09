import Foundation

/// Phase 3 of the synthetic-phonics sequence PhonicsBank started — two (or
/// three) letters making one new sound, rather than a new single-letter
/// sound. Reuses `LetterSoundEntry` unchanged since a digraph fits the same
/// shape (grapheme, sound, example word, picture) as a single letter does.
enum DigraphBank {
    static let all: [LetterSoundEntry] = [
        LetterSoundEntry(letter: "sh", sound: "sh", exampleWord: "Ship", emoji: "🚢"),
        LetterSoundEntry(letter: "ch", sound: "ch", exampleWord: "Chick", emoji: "🐤"),
        LetterSoundEntry(letter: "th", sound: "th", exampleWord: "Thumb", emoji: "👍"),
        LetterSoundEntry(letter: "ng", sound: "ng", exampleWord: "Ring", emoji: "💍"),
        LetterSoundEntry(letter: "ai", sound: "ai", exampleWord: "Rain", emoji: "🌧️"),
        LetterSoundEntry(letter: "ee", sound: "ee", exampleWord: "Bee", emoji: "🐝"),
        LetterSoundEntry(letter: "igh", sound: "igh", exampleWord: "Light", emoji: "💡"),
        LetterSoundEntry(letter: "oa", sound: "oa", exampleWord: "Boat", emoji: "⛵️"),
        LetterSoundEntry(letter: "oo", sound: "oo", exampleWord: "Spoon", emoji: "🥄"),
        LetterSoundEntry(letter: "ar", sound: "ar", exampleWord: "Car", emoji: "🚗"),
        LetterSoundEntry(letter: "or", sound: "or", exampleWord: "Fork", emoji: "🍴"),
        LetterSoundEntry(letter: "ur", sound: "ur", exampleWord: "Purse", emoji: "👛"),
        LetterSoundEntry(letter: "ow", sound: "ow", exampleWord: "Cow", emoji: "🐄"),
        LetterSoundEntry(letter: "oi", sound: "oi", exampleWord: "Coin", emoji: "🪙"),
    ]

    static func random(avoiding recent: Set<String> = []) -> LetterSoundEntry {
        all.random(avoiding: recent)
    }

    static func decoys(excluding target: LetterSoundEntry, count: Int) -> [LetterSoundEntry] {
        all.decoys(excluding: target, count: count)
    }
}
