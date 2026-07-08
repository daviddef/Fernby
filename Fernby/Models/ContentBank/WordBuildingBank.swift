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
    ]

    static func random(avoiding recent: Set<String> = []) -> BuildableWord {
        let pool = all.filter { !recent.contains($0.word) }
        return (pool.isEmpty ? all : pool).randomElement()!
    }

    static func decoys(excluding target: BuildableWord, count: Int) -> [BuildableWord] {
        Array(all.filter { $0.word != target.word }.shuffled().prefix(count))
    }
}
