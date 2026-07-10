import SwiftUI

/// Coin recognition and combinations — the Grade 2 CCSS money skill.
/// Coins are drawn as labeled circles (see CoinView) rather than photo-
/// realistic imagery, since the actual skill is adding values together,
/// not visually identifying a specific coin design.
enum Coin: CaseIterable {
    case penny, nickel, dime, quarter

    var value: Int {
        switch self {
        case .penny: return 1
        case .nickel: return 5
        case .dime: return 10
        case .quarter: return 25
        }
    }

    var label: String { "\(value)¢" }

    var color: Color {
        switch self {
        case .penny: return Color(red: 0.72, green: 0.45, blue: 0.20)
        case .nickel: return Color(red: 0.62, green: 0.64, blue: 0.66)
        case .dime: return Color(red: 0.75, green: 0.76, blue: 0.78)
        case .quarter: return Color(red: 0.68, green: 0.70, blue: 0.73)
        }
    }

    var diameter: CGFloat {
        switch self {
        case .penny: return 46
        case .nickel: return 58
        case .dime: return 40
        case .quarter: return 54
        }
    }
}

struct MoneyQuestion {
    let coins: [Coin]
    let choices: [Int]
    var total: Int { coins.reduce(0) { $0 + $1.value } }
}

enum CoinBank {
    static func random(forDifficulty level: Int) -> MoneyQuestion {
        let coinCount = level <= 1 ? 2 : (level == 2 ? 3 : 4)
        let pool: [Coin] = level <= 1 ? [.penny, .nickel, .dime] : Coin.allCases
        let coins = (0..<coinCount).map { _ in pool.randomElement()! }
        let total = coins.reduce(0) { $0 + $1.value }

        var decoys: [Int] = []
        for offset in [1, 5, -1, -5, 10].shuffled() {
            let candidate = total + offset
            guard candidate >= 0, candidate != total, !decoys.contains(candidate) else { continue }
            decoys.append(candidate)
            if decoys.count == 2 { break }
        }
        while decoys.count < 2 {
            let filler = total + decoys.count + 2
            if !decoys.contains(filler) { decoys.append(filler) }
        }

        return MoneyQuestion(coins: coins, choices: ([total] + decoys).shuffled())
    }
}
