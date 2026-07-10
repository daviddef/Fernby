import Foundation

/// Dolch 2nd Grade tier (46 words) — the next rung after
/// SightWordTier3Bank's 1st Grade tier.
enum SightWordTier4Bank {
    static let all: [String] = [
        "always", "around", "because", "been", "before", "best", "both", "buy", "call", "cold",
        "does", "don't", "fast", "first", "five", "found", "gave", "goes", "green", "its",
        "made", "many", "off", "or", "pull", "read", "right", "sing", "sit", "sleep",
        "tell", "their", "these", "those", "upon", "us", "use", "very", "wash", "which",
        "why", "wish", "work", "would", "write", "your",
    ]

    static func random(avoiding recent: Set<String> = []) -> String {
        all.randomWord(avoiding: recent)
    }

    static func decoys(excluding target: String, count: Int) -> [String] {
        all.decoyWords(excluding: target, count: count)
    }
}
