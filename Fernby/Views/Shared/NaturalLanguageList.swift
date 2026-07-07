import Foundation

extension Array where Element == String {
    /// "a, b, and c" — natural-language joining used anywhere a narrated
    /// summary lists node/biome names (QuestSummaryView, ParentDashboardView).
    func formattedList() -> String {
        switch count {
        case 0: return ""
        case 1: return self[0]
        case 2: return "\(self[0]) and \(self[1])"
        default: return dropLast().joined(separator: ", ") + ", and \(last!)"
        }
    }
}
