import Foundation

/// Shared 1...10 range-and-word logic for the two counting-family
/// activities. Kept separate from MathFactBank because these two nodes
/// (`counting`, `numberID`) sit *before* addition in the math chain and
/// reason about a single quantity, not an operation between two.
enum NumberBank {
    private static let words = [
        1: "one", 2: "two", 3: "three", 4: "four", 5: "five",
        6: "six", 7: "seven", 8: "eight", 9: "nine", 10: "ten",
    ]

    /// The highest number in play at a given difficulty level — starts at 5
    /// objects/numerals and opens up to the full 1...10 range by level 5.
    static func maxNumber(forDifficulty level: Int) -> Int {
        let clamped = min(max(level, 1), 5)
        return [1: 5, 2: 6, 3: 8, 4: 9, 5: 10][clamped] ?? 5
    }

    static func word(for number: Int) -> String {
        words[number] ?? "\(number)"
    }

    /// A random target number in range, plus two nearby distractor numerals
    /// distinct from it — mirrors MathFactBank.distractors' "close, not
    /// trivially obvious" shape for a single quantity instead of a fact.
    static func randomTarget(forDifficulty level: Int) -> (target: Int, choices: [Int]) {
        let maxNumber = maxNumber(forDifficulty: level)
        let target = Int.random(in: 1...maxNumber)
        var candidates: [Int] = []
        for offset in [-2, -1, 1, 2].shuffled() {
            let candidate = target + offset
            guard candidate >= 1, candidate != target, !candidates.contains(candidate) else { continue }
            candidates.append(candidate)
            if candidates.count == 2 { break }
        }
        var filler = 1
        while candidates.count < 2 {
            let candidate = target + filler
            if candidate != target && candidate >= 1 && !candidates.contains(candidate) { candidates.append(candidate) }
            filler += 1
        }
        return (target, ([target] + candidates).shuffled())
    }
}
