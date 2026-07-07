import Foundation

enum MathOperation: String, Codable {
    case add
    case subtract

    var symbol: String { self == .add ? "+" : "\u{2212}" }
}

struct MathFact: Codable, Equatable {
    let a: Int
    let b: Int
    let operation: MathOperation

    var answer: Int { operation == .add ? a + b : a - b }
    var displayText: String { "\(a) \(operation.symbol) \(b)" }
    var spokenText: String { "\(a) \(operation == .add ? "plus" : "minus") \(b)" }
}

/// Math facts are combinatorial, so this bank generates rather than hand-lists
/// entries — unlike the word banks, which are curated. Level 1 sums to 5,
/// level 3 (DifficultyEngine.maxDifficulty) sums to 20; subtraction stays
/// non-negative and borrow-free throughout so every fact is representable
/// with simple counters.
enum MathFactBank {
    private static let maxSumByLevel = [1: 5, 2: 10, 3: 20]

    static func facts(forDifficulty level: Int, operation: MathOperation) -> [MathFact] {
        let clampedLevel = min(max(level, 1), 3)
        let maxSum = maxSumByLevel[clampedLevel] ?? 5
        var facts: [MathFact] = []
        for a in 0...maxSum {
            for b in 0...maxSum {
                switch operation {
                case .add:
                    if a + b > 0 && a + b <= maxSum { facts.append(MathFact(a: a, b: b, operation: .add)) }
                case .subtract:
                    if a - b >= 0 && a <= maxSum { facts.append(MathFact(a: a, b: b, operation: .subtract)) }
                }
            }
        }
        return facts
    }

    static func randomFact(forDifficulty level: Int, operation: MathOperation) -> MathFact {
        facts(forDifficulty: level, operation: operation).randomElement()
            ?? MathFact(a: 1, b: 1, operation: operation)
    }

    /// Distractor answers close to the true answer (±1/±2) so the choice is
    /// meaningfully discriminating rather than trivially obvious.
    static func distractors(for fact: MathFact, count: Int = 2) -> [Int] {
        let answer = fact.answer
        var candidates: [Int] = []
        for offset in [-2, -1, 1, 2].shuffled() {
            let candidate = answer + offset
            guard candidate >= 0, candidate != answer, !candidates.contains(candidate) else { continue }
            candidates.append(candidate)
            if candidates.count == count { break }
        }
        var filler = count + 1
        while candidates.count < count {
            let candidate = answer + filler
            if candidate != answer && !candidates.contains(candidate) { candidates.append(candidate) }
            filler += 1
        }
        return candidates
    }
}
