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
        // 12 more words from the original 14 digraph patterns.
        BuildableWord(word: "shed", emoji: "🏚️", letters: ["sh", "e", "d"]),
        BuildableWord(word: "chin", emoji: "😐", letters: ["ch", "i", "n"]),
        BuildableWord(word: "path", emoji: "🛤️", letters: ["p", "a", "th"]),
        BuildableWord(word: "sing", emoji: "🎤", letters: ["s", "i", "ng"]),
        BuildableWord(word: "long", emoji: "📏", letters: ["l", "o", "ng"]),
        BuildableWord(word: "tail", emoji: "🐒", letters: ["t", "ai", "l"]),
        BuildableWord(word: "tree", emoji: "🌳", letters: ["t", "r", "ee"]),
        BuildableWord(word: "light", emoji: "🔆", letters: ["l", "igh", "t"]),
        BuildableWord(word: "boat", emoji: "⛵", letters: ["b", "oa", "t"]),
        BuildableWord(word: "moon", emoji: "🌕", letters: ["m", "oo", "n"]),
        BuildableWord(word: "fur", emoji: "🐻", letters: ["f", "ur"]),
        BuildableWord(word: "cow", emoji: "🐄", letters: ["c", "ow"]),
        // 12 more from the 5 new patterns just added to DigraphBank (ay,
        // oy, aw, wh, ea) — every new phoneme gets real words to read, not
        // just an isolated-sound flashcard.
        BuildableWord(word: "day", emoji: "📅", letters: ["d", "ay"]),
        BuildableWord(word: "boy", emoji: "👦", letters: ["b", "oy"]),
        BuildableWord(word: "toy", emoji: "🧸", letters: ["t", "oy"]),
        BuildableWord(word: "saw", emoji: "🪚", letters: ["s", "aw"]),
        BuildableWord(word: "paw", emoji: "🐾", letters: ["p", "aw"]),
        BuildableWord(word: "wheel", emoji: "🛞", letters: ["wh", "ee", "l"]),
        BuildableWord(word: "tea", emoji: "🍵", letters: ["t", "ea"]),
        BuildableWord(word: "pea", emoji: "🫛", letters: ["p", "ea"]),
        BuildableWord(word: "sea", emoji: "🌊", letters: ["s", "ea"]),
        BuildableWord(word: "leaf", emoji: "🍃", letters: ["l", "ea", "f"]),
        BuildableWord(word: "beach", emoji: "🏖️", letters: ["b", "ea", "ch"]),
        BuildableWord(word: "peach", emoji: "🍑", letters: ["p", "ea", "ch"]),
    ]

    static func random(avoiding recent: Set<String> = []) -> BuildableWord {
        all.random(avoiding: recent)
    }

    static func decoys(excluding target: BuildableWord, count: Int) -> [BuildableWord] {
        all.decoys(excluding: target, count: count)
    }
}
