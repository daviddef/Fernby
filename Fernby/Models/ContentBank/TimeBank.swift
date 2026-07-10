import Foundation

/// K-1 telling-time scope: hour and half-hour only, matching the standard
/// CCSS sequence (nearest-5-minutes is a Grade 2 skill, deliberately not
/// attempted here). Distractors are the two real mistakes kids make:
/// same hour wrong half, or right half wrong (adjacent) hour.
struct TimeQuestion {
    let hour: Int
    let minute: Int
    let choices: [String]
    var correctText: String { TimeBank.format(hour: hour, minute: minute) }
}

enum TimeBank {
    static func random() -> TimeQuestion {
        let hour = Int.random(in: 1...12)
        let minute = Bool.random() ? 0 : 30
        let correct = format(hour: hour, minute: minute)

        var decoys: [String] = []
        let otherMinute = minute == 0 ? 30 : 0
        decoys.append(format(hour: hour, minute: otherMinute))

        let nextHour = hour == 12 ? 1 : hour + 1
        decoys.append(format(hour: nextHour, minute: minute))

        return TimeQuestion(hour: hour, minute: minute, choices: ([correct] + decoys).shuffled())
    }

    static func format(hour: Int, minute: Int) -> String {
        String(format: "%d:%02d", hour, minute)
    }

    static func spoken(hour: Int, minute: Int) -> String {
        minute == 0 ? "\(hour) o'clock" : "\(hour) thirty"
    }
}
