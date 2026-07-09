import Foundation

/// The companion grows from cumulative activities completed, never from
/// consecutive days — so a missed day doesn't cost anything and there is
/// nothing here shaped like a streak to protect or lose.
struct CompanionState: Codable {
    var totalActivitiesCompleted: Int = 0
    var daysPlayed: Set<String> = []   // ISO "yyyy-MM-dd" strings, kept for future stats only — never surfaced as a streak
    var selectedAccessory: CompanionAccessory = .none

    static let stageCount = 5
    static let activitiesPerStage = 15

    var growthStage: Int {
        min(totalActivitiesCompleted / Self.activitiesPerStage, Self.stageCount - 1)
    }
}
