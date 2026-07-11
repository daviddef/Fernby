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
        // 20 more real CVC words from the same 19 taught letters — the
        // original 27 were exhausted quickly by RecentItemTracker's
        // avoid-immediate-repeat window, since a pool that small starts
        // visibly cycling within a single quest.
        BuildableWord(word: "red", emoji: "🔴", letters: ["r", "e", "d"]),
        BuildableWord(word: "fan", emoji: "🪭", letters: ["f", "a", "n"]),
        BuildableWord(word: "hop", emoji: "🐇", letters: ["h", "o", "p"]),
        BuildableWord(word: "hug", emoji: "🤗", letters: ["h", "u", "g"]),
        BuildableWord(word: "ham", emoji: "🍖", letters: ["h", "a", "m"]),
        BuildableWord(word: "kid", emoji: "🧒", letters: ["k", "i", "d"]),
        BuildableWord(word: "lip", emoji: "👄", letters: ["l", "i", "p"]),
        BuildableWord(word: "mat", emoji: "🟫", letters: ["m", "a", "t"]),
        BuildableWord(word: "mop", emoji: "🧹", letters: ["m", "o", "p"]),
        BuildableWord(word: "mud", emoji: "🥾", letters: ["m", "u", "d"]),
        BuildableWord(word: "mug", emoji: "☕", letters: ["m", "u", "g"]),
        BuildableWord(word: "nut", emoji: "🥜", letters: ["n", "u", "t"]),
        BuildableWord(word: "pot", emoji: "🍲", letters: ["p", "o", "t"]),
        BuildableWord(word: "pet", emoji: "🐾", letters: ["p", "e", "t"]),
        BuildableWord(word: "pen", emoji: "🖊️", letters: ["p", "e", "n"]),
        BuildableWord(word: "rag", emoji: "🧻", letters: ["r", "a", "g"]),
        BuildableWord(word: "rat", emoji: "🐀", letters: ["r", "a", "t"]),
        BuildableWord(word: "rug", emoji: "🟪", letters: ["r", "u", "g"]),
        BuildableWord(word: "tub", emoji: "🛁", letters: ["t", "u", "b"]),
        BuildableWord(word: "cup", emoji: "🧋", letters: ["c", "u", "p"]),
    ]

    static func random(avoiding recent: Set<String> = []) -> BuildableWord {
        all.random(avoiding: recent)
    }

    static func decoys(excluding target: BuildableWord, count: Int) -> [BuildableWord] {
        all.decoys(excluding: target, count: count)
    }
}
