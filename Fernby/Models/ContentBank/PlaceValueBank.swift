import Foundation

/// "3 tens and 4 ones make what number?" — place value within 100.
/// Distractors are the two real mistakes kids actually make here: reading
/// the digits in swapped order, or landing one off.
struct PlaceValueQuestion {
    let tens: Int
    let ones: Int
    let answer: Int
    let choices: [Int]
}

enum PlaceValueBank {
    static func random(forDifficulty level: Int) -> PlaceValueQuestion {
        let maxTens = level <= 1 ? 3 : (level == 2 ? 6 : 9)
        let tens = Int.random(in: 1...maxTens)
        let ones = Int.random(in: 0...9)
        let answer = tens * 10 + ones

        var candidates: [Int] = []
        let swapped = ones * 10 + tens
        if swapped != answer { candidates.append(swapped) }
        candidates.append(contentsOf: [answer + 1, answer - 1, answer + 10, answer - 10])

        var decoys: [Int] = []
        for candidate in candidates {
            guard candidate >= 0, candidate != answer, !decoys.contains(candidate) else { continue }
            decoys.append(candidate)
            if decoys.count == 2 { break }
        }

        return PlaceValueQuestion(tens: tens, ones: ones, answer: answer, choices: ([answer] + decoys).shuffled())
    }
}
