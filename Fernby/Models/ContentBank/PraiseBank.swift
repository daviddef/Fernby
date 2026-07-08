import Foundation

/// Every correct-answer line in the app opened with the literal word "Yes!"
/// — heard dozens of times a session, the single most-repeated line in the
/// whole experience. This is pure phrasing variety (never a reward
/// schedule, never withheld or delayed), so every answer still gets
/// celebrated immediately and every time.
enum PraiseBank {
    static let openers = ["Yes!", "That's right!", "You got it!", "Nice!", "Way to go!", "Exactly!"]

    static func random() -> String {
        openers.randomElement()!
    }
}
