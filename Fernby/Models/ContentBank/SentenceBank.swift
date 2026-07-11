import Foundation

struct BuildableSentence: Codable, Equatable {
    /// Words in correct reading order, trailing punctuation attached to the
    /// last word — every sentence is exactly 4 tiles so the drop-zone
    /// layout never has to vary.
    let words: [String]
    var spoken: String { words.joined(separator: " ") }
}

/// The capstone reading node — every sentence is built entirely from words
/// already introduced by SightWordBank (tier1) or the CVC/blend/digraph
/// word banks, so nothing here asks a child to read a word they haven't
/// met before. Originally only 4 sentences — with RecentItemTracker only
/// avoiding *immediate* repeats, a pool that small was fully exhausted and
/// visibly repeating within a couple of quests. Expanded to 41 (verified
/// against the exact same guaranteed-vocabulary contract StoryBank uses)
/// so the capstone node has real variety instead of memorized answers.
enum SentenceBank {
    static let all: [BuildableSentence] = [
        BuildableSentence(words: ["I", "see", "a", "pan."]),
        BuildableSentence(words: ["You", "see", "a", "pin."]),
        BuildableSentence(words: ["I", "see", "the", "ant."]),
        BuildableSentence(words: ["You", "can", "see", "it."]),
        BuildableSentence(words: ["I", "see", "a", "cat."]),
        BuildableSentence(words: ["I", "see", "a", "dog."]),
        BuildableSentence(words: ["You", "see", "a", "pig."]),
        BuildableSentence(words: ["I", "see", "a", "bug."]),
        BuildableSentence(words: ["I", "can", "see", "it."]),
        BuildableSentence(words: ["I", "can", "help", "you."]),
        BuildableSentence(words: ["The", "dog", "can", "run."]),
        BuildableSentence(words: ["The", "cat", "can", "run."]),
        BuildableSentence(words: ["My", "dog", "can", "run."]),
        BuildableSentence(words: ["My", "cat", "is", "little."]),
        BuildableSentence(words: ["The", "pig", "is", "little."]),
        BuildableSentence(words: ["I", "see", "my", "hat."]),
        BuildableSentence(words: ["You", "see", "my", "cap."]),
        BuildableSentence(words: ["You", "can", "go", "up."]),
        BuildableSentence(words: ["I", "can", "play", "here."]),
        BuildableSentence(words: ["You", "can", "play", "here."]),
        BuildableSentence(words: ["I", "see", "a", "frog."]),
        BuildableSentence(words: ["I", "see", "a", "crab."]),
        BuildableSentence(words: ["You", "see", "a", "hen."]),
        BuildableSentence(words: ["I", "see", "the", "sun."]),
        BuildableSentence(words: ["I", "see", "my", "bed."]),
        BuildableSentence(words: ["You", "see", "my", "nest."]),
        BuildableSentence(words: ["I", "see", "a", "ship."]),
        BuildableSentence(words: ["I", "see", "a", "train."]),
        BuildableSentence(words: ["You", "see", "a", "king."]),
        BuildableSentence(words: ["I", "see", "the", "rain."]),
        BuildableSentence(words: ["I", "see", "my", "coat."]),
        BuildableSentence(words: ["You", "see", "a", "star."]),
        BuildableSentence(words: ["I", "see", "a", "coin."]),
        BuildableSentence(words: ["I", "see", "the", "owl."]),
        BuildableSentence(words: ["I", "see", "the", "corn."]),
        BuildableSentence(words: ["You", "see", "the", "pool."]),
        BuildableSentence(words: ["I", "see", "my", "milk."]),
        BuildableSentence(words: ["The", "hen", "is", "little."]),
        BuildableSentence(words: ["The", "bug", "is", "little."]),
        BuildableSentence(words: ["Look", "I", "see", "it."]),
        BuildableSentence(words: ["Look", "up", "and", "see."]),
    ]

    static func random(avoiding recent: Set<[String]> = []) -> BuildableSentence {
        let pool = all.filter { !recent.contains($0.words) }
        return (pool.isEmpty ? all : pool).randomElement()!
    }
}
