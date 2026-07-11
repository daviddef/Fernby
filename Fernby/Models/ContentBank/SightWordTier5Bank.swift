import Foundation

/// Dolch 3rd Grade tier (41 words) — the fifth and final tier of the
/// official Dolch sight-word list. With this, Fernby now teaches the
/// complete Dolch progression: Pre-primer (SightWordBank, 20) → Primer
/// (SightWordAdvancedBank, 52) → 1st Grade (SightWordTier3Bank, 41) → 2nd
/// Grade (SightWordTier4Bank, 45) → 3rd Grade (this bank, 41) — 199 words
/// total, the same well-established reference list generations of
/// classrooms have used, not an arbitrary word count target.
enum SightWordTier5Bank {
    static let all: [String] = [
        "about", "better", "bring", "carry", "clean", "cut", "done", "draw",
        "drink", "eight", "fall", "far", "full", "got", "grow", "hold",
        "hot", "hurt", "if", "keep", "kind", "laugh", "light", "long",
        "much", "myself", "never", "only", "own", "pick", "seven", "shall",
        "show", "six", "small", "start", "ten", "today", "together", "try",
        "warm",
    ]

    static func random(avoiding recent: Set<String> = []) -> String {
        all.randomWord(avoiding: recent)
    }

    static func decoys(excluding target: String, count: Int) -> [String] {
        all.decoyWords(excluding: target, count: count)
    }
}
