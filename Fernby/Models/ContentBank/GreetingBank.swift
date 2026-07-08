import Foundation

/// A warm return greeting for the first visit of a new calendar day —
/// deliberately never a day count or streak number (see CompanionState:
/// "kept for future stats only — never surfaced as a streak"). The only
/// thing checked is *whether* today is a new day for a returning learner,
/// never *how many* days in a row, so there is nothing here that could
/// read as broken or lost if a day is skipped.
enum GreetingBank {
    private static let phrases = [
        "Welcome back!", "So glad you're here!", "Fern missed you!",
        "Great to see you again!", "Ready for today's quest?",
    ]

    @MainActor
    static func forReturningVisit(daysPlayed: Set<String>, totalActivitiesCompleted: Int) -> String? {
        guard totalActivitiesCompleted > 0, !daysPlayed.contains(ProgressStore.todayKey()) else { return nil }
        return phrases.randomElement()
    }
}
