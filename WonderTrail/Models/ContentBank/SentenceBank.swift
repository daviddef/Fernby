import Foundation

struct BuildableSentence: Codable, Equatable {
    /// Words in correct reading order, trailing punctuation attached to the
    /// last word — every sentence is exactly 4 tiles so the drop-zone
    /// layout never has to vary.
    let words: [String]
    var spoken: String { words.joined(separator: " ") }
}

/// The capstone reading node — every sentence is built entirely from words
/// already introduced by SightWordBank or WordBuildingBank, so nothing here
/// asks a child to read a word they haven't met before.
enum SentenceBank {
    static let all: [BuildableSentence] = [
        BuildableSentence(words: ["I", "see", "a", "pan."]),
        BuildableSentence(words: ["You", "see", "a", "pin."]),
        BuildableSentence(words: ["I", "see", "the", "ant."]),
        BuildableSentence(words: ["You", "can", "see", "it."]),
    ]

    static func random(avoiding recent: Set<[String]> = []) -> BuildableSentence {
        let pool = all.filter { !recent.contains($0.words) }
        return (pool.isEmpty ? all : pool).randomElement()!
    }
}
