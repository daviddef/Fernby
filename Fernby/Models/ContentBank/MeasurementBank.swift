import CoreGraphics

/// Length comparison — the K-1 measurement skill before a ruler or units
/// enter the picture at all: just "which one is longer/shorter," judged by
/// eye. The two bars are the actual tappable choices in MeasurementView,
/// not a separate multiple-choice row.
enum MeasurementPrompt {
    case longer, shorter
}

struct MeasurementQuestion {
    let prompt: MeasurementPrompt
    let widthA: CGFloat
    let widthB: CGFloat
    let correctIsA: Bool
}

enum MeasurementBank {
    static func random() -> MeasurementQuestion {
        let prompt: MeasurementPrompt = Bool.random() ? .longer : .shorter
        let a = CGFloat(Int.random(in: 60...220))
        var b = CGFloat(Int.random(in: 60...220))
        // Keep a clear visual gap — a near-tie isn't a fair "judge by eye" question.
        while abs(a - b) < 40 {
            b = CGFloat(Int.random(in: 60...220))
        }
        let aIsLonger = a > b
        let correctIsA = (prompt == .longer) ? aIsLonger : !aIsLonger
        return MeasurementQuestion(prompt: prompt, widthA: a, widthB: b, correctIsA: correctIsA)
    }
}
