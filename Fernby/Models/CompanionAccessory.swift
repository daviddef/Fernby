import Foundation

/// Earned-not-random cosmetic unlocks for the companion — the one new
/// engagement mechanic the research flagged as legitimate as long as it's
/// earned rather than gacha'd (CHI 2025 avatar-ethics research draws
/// exactly this line). Every unlock is a deterministic function of
/// `CompanionState.totalActivitiesCompleted`, the same counter growth
/// stages already use — same action always yields the same result, no
/// randomness anywhere in this file.
enum CompanionAccessory: String, Codable, CaseIterable, Identifiable {
    case none
    case cap
    case bow
    case scarf
    case crown
    case flowerCrown

    var id: String { rawValue }

    var emoji: String? {
        switch self {
        case .none: return nil
        case .cap: return "🧢"
        case .bow: return "🎀"
        case .scarf: return "🧣"
        case .crown: return "👑"
        case .flowerCrown: return "🌸"
        }
    }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .cap: return "Cap"
        case .bow: return "Bow"
        case .scarf: return "Scarf"
        case .crown: return "Crown"
        case .flowerCrown: return "Flower Crown"
        }
    }

    /// Activities completed before this unlocks. `.none` is always
    /// available since it's just "no accessory," not a reward.
    var unlockThreshold: Int {
        switch self {
        case .none: return 0
        case .cap: return 10
        case .bow: return 25
        case .scarf: return 40
        case .crown: return 60
        case .flowerCrown: return 90
        }
    }

    func isUnlocked(totalActivitiesCompleted: Int) -> Bool {
        totalActivitiesCompleted >= unlockThreshold
    }
}
