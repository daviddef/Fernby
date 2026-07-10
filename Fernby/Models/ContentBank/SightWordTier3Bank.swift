import Foundation

/// Dolch 1st Grade tier (41 words) — the next rung after
/// SightWordAdvancedBank's Primer tier.
enum SightWordTier3Bank {
    static let all: [String] = [
        "after", "again", "an", "any", "as", "ask", "by", "could", "every", "fly",
        "from", "give", "going", "had", "has", "her", "him", "his", "how", "just",
        "know", "let", "live", "may", "of", "old", "once", "open", "over", "put",
        "round", "some", "stop", "take", "thank", "them", "then", "think", "walk", "were",
        "when",
    ]

    static func random(avoiding recent: Set<String> = []) -> String {
        all.randomWord(avoiding: recent)
    }

    static func decoys(excluding target: String, count: Int) -> [String] {
        all.decoyWords(excluding: target, count: count)
    }
}
