import Foundation

struct BuildableWord: Codable, Equatable {
    let word: String
    let emoji: String
    /// Individual letters in order — every letter here must exist in
    /// PhonicsBank, since blending only makes sense over sounds a child has
    /// actually been taught.
    let letters: [String]
}

/// Every word here is spelled entirely from PhonicsBank letters — a
/// blending word bank can only ever be as large as the phonics bank
/// backing it, so this grows in lockstep as more letters are added there.
/// The tier1 set (s,a,t,p,i,n) originally supported 7 words; tier2
/// (m,d,g,o,c,k) unlocks these 10 more real CVC words.
enum WordBuildingBank {
    static let all: [BuildableWord] = [
        BuildableWord(word: "pan", emoji: "🍳", letters: ["p", "a", "n"]),
        BuildableWord(word: "nap", emoji: "😴", letters: ["n", "a", "p"]),
        BuildableWord(word: "pin", emoji: "📌", letters: ["p", "i", "n"]),
        BuildableWord(word: "tin", emoji: "🥫", letters: ["t", "i", "n"]),
        BuildableWord(word: "sip", emoji: "🥤", letters: ["s", "i", "p"]),
        BuildableWord(word: "ant", emoji: "🐜", letters: ["a", "n", "t"]),
        BuildableWord(word: "tap", emoji: "🚰", letters: ["t", "a", "p"]),
        BuildableWord(word: "cat", emoji: "🐱", letters: ["c", "a", "t"]),
        BuildableWord(word: "dog", emoji: "🐶", letters: ["d", "o", "g"]),
        BuildableWord(word: "pig", emoji: "🐷", letters: ["p", "i", "g"]),
        BuildableWord(word: "mad", emoji: "😠", letters: ["m", "a", "d"]),
        BuildableWord(word: "sad", emoji: "😢", letters: ["s", "a", "d"]),
        BuildableWord(word: "dad", emoji: "👨", letters: ["d", "a", "d"]),
        BuildableWord(word: "map", emoji: "🗺️", letters: ["m", "a", "p"]),
        BuildableWord(word: "dig", emoji: "⛏️", letters: ["d", "i", "g"]),
        BuildableWord(word: "cap", emoji: "🧢", letters: ["c", "a", "p"]),
        BuildableWord(word: "man", emoji: "🧑", letters: ["m", "a", "n"]),
        // Unlocked by PhonicsBank.tier3 (e, u, r, h, b, f, l).
        BuildableWord(word: "run", emoji: "🏃", letters: ["r", "u", "n"]),
        BuildableWord(word: "hat", emoji: "🎩", letters: ["h", "a", "t"]),
        BuildableWord(word: "bat", emoji: "🦇", letters: ["b", "a", "t"]),
        BuildableWord(word: "big", emoji: "🐘", letters: ["b", "i", "g"]),
        BuildableWord(word: "bug", emoji: "🐛", letters: ["b", "u", "g"]),
        BuildableWord(word: "hen", emoji: "🐔", letters: ["h", "e", "n"]),
        BuildableWord(word: "bed", emoji: "🛏️", letters: ["b", "e", "d"]),
        BuildableWord(word: "leg", emoji: "🦵", letters: ["l", "e", "g"]),
        BuildableWord(word: "log", emoji: "🪵", letters: ["l", "o", "g"]),
        BuildableWord(word: "sun", emoji: "☀️", letters: ["s", "u", "n"]),
    ]

    static func random(avoiding recent: Set<String> = []) -> BuildableWord {
        all.random(avoiding: recent)
    }

    static func decoys(excluding target: BuildableWord, count: Int) -> [BuildableWord] {
        all.decoys(excluding: target, count: count)
    }
}
