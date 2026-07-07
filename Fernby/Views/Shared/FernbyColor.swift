import SwiftUI

/// Deliberately chosen right/wrong colors, used everywhere instead of raw
/// `.orange`/`.green`. AccentColor is a warm peach (0.98, 0.67, 0.48) — a
/// wrong-answer tint of plain `.orange` sits almost on top of that hue and
/// reads as barely-different from "untapped," which is exactly the bug
/// that made wrong answers invisible without Voice. `wrong` is a cool
/// rose-red, as far from the peach accent as `correct`'s green already is.
extension Color {
    static let fernbyCorrect = Color(red: 0.24, green: 0.62, blue: 0.35)
    static let fernbyWrong = Color(red: 0.82, green: 0.27, blue: 0.36)
}
