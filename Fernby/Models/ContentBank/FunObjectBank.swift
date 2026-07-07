import Foundation

/// Fun, kid-recognizable objects standing in for abstract counters — "4
/// balloons + 2 balloons" makes the connection between an equation and a
/// real quantity vivid instead of "4 dots + 2 dots." A different object is
/// picked per question rather than fixed, which doubles as a small dose of
/// visual variety in what would otherwise be a repetitive drill. Generic,
/// unbranded objects only — no real-world product or character references.
enum FunObjectBank {
    static let objects = ["🧸", "🎈", "🍭", "🚗", "⚽️", "🍪", "🦆", "🌟", "🐝", "🍩"]

    static func random() -> String {
        objects.randomElement()!
    }
}
