import Foundation

/// Equal groups / repeated addition — the Grade 2 CCSS early-multiplication
/// foundation, deliberately framed as "how many in total" rather than with
/// a × symbol, which isn't introduced yet at this stage.
struct GroupsQuestion {
    let groupCount: Int
    let itemsPerGroup: Int
    let emoji: String
    let answer: Int
    let choices: [Int]
}

enum MultiplicationBank {
    static func random(forDifficulty level: Int) -> GroupsQuestion {
        let maxFactor = level <= 1 ? 3 : (level == 2 ? 4 : 5)
        let groupCount = Int.random(in: 2...maxFactor)
        let itemsPerGroup = Int.random(in: 2...maxFactor)
        let answer = groupCount * itemsPerGroup
        let emoji = FunObjectBank.random()

        var decoys: [Int] = []
        for offset in [-2, -1, 1, 2].shuffled() {
            let candidate = answer + offset
            guard candidate >= 0, candidate != answer, !decoys.contains(candidate) else { continue }
            decoys.append(candidate)
            if decoys.count == 2 { break }
        }
        while decoys.count < 2 {
            let filler = answer + decoys.count + 3
            if !decoys.contains(filler) { decoys.append(filler) }
        }

        return GroupsQuestion(
            groupCount: groupCount, itemsPerGroup: itemsPerGroup, emoji: emoji,
            answer: answer, choices: ([answer] + decoys).shuffled()
        )
    }
}
