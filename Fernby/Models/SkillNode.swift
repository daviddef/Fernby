import Foundation

enum Subject: String, Codable {
    case reading
    case math
}

/// Which activity view renders a given skill node.
enum ActivityKind: String, Codable {
    case letterTracing
    case letterSoundMatch
    case wordBuilding
    case sightWordTap
    case sentenceBuild
    case countingTap
    case numberIDTap
    case additionTap
    case subtractionTap
    case wordProblemStep
    case shapesTap
    case skipCountingTap
    case placeValueTap
    case measurementTap
}

struct SkillNode: Identifiable, Codable, Hashable {
    let id: String
    let subject: Subject
    let title: String
    let order: Int
    let activityKind: ActivityKind
}
