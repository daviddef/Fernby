import Foundation

/// A single child using the app. Modeled as an array from day one — v0.1's UI
/// only ever shows the first profile, but "mixed starting levels" implies
/// more than one kid will eventually use this on the same device.
struct LearnerProfile: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var displayName: String
    var createdAt: Date
    var hasCompletedPlacement: Bool = false
}
