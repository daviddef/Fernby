import Foundation

/// One pair for the matching game — two cards that belong together (a
/// letter and its sound-emoji, or a numeral and its word). `id` groups them;
/// `left`/`right` are what's printed on each of the two cards once flipped.
struct MatchPair {
    let id: String
    let left: String
    let right: String
}

/// Content for the matching-pairs bonus round — reuses PhonicsBank and
/// NumberBank exactly as their own activities do, so a bonus round never
/// tests material a child wasn't actually taught through the normal quest
/// loop. Two themes, picked randomly, so the bonus round itself varies
/// quest to quest rather than always being the same game.
enum MatchGameBank {
    static func randomPairs(count: Int = 3) -> [MatchPair] {
        Bool.random() ? phonicsPairs(count: count) : numberPairs(count: count)
    }

    private static func phonicsPairs(count: Int) -> [MatchPair] {
        PhonicsBank.all.shuffled().prefix(count).map {
            MatchPair(id: "letter.\($0.letter)", left: $0.letter.uppercased(), right: $0.emoji)
        }
    }

    private static func numberPairs(count: Int) -> [MatchPair] {
        Array(1...10).shuffled().prefix(count).map {
            MatchPair(id: "number.\($0)", left: "\($0)", right: NumberBank.word(for: $0))
        }
    }
}
