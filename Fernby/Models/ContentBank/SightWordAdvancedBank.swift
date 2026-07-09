import Foundation

/// The Dolch Primer tier (52 words) — the next rung after SightWordBank's
/// pre-primer tier (40 core words). Same reasoning as that bank: these are
/// irregular/abstract words taught by whole-word recognition, not sounded
/// out.
enum SightWordAdvancedBank {
    static let all: [String] = [
        "all", "am", "are", "at", "ate", "be", "black", "brown", "but", "came",
        "did", "do", "eat", "four", "get", "good", "have", "he", "into", "like",
        "must", "new", "no", "now", "on", "our", "out", "please", "pretty", "ran",
        "ride", "saw", "say", "she", "so", "soon", "that", "there", "they", "this",
        "too", "under", "want", "was", "well", "went", "what", "white", "who", "will",
        "with", "yes",
    ]

    static func random(avoiding recent: Set<String> = []) -> String {
        all.randomWord(avoiding: recent)
    }

    static func decoys(excluding target: String, count: Int) -> [String] {
        all.decoyWords(excluding: target, count: count)
    }
}
