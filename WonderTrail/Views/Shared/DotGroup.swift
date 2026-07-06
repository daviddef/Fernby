import SwiftUI

/// A calm, static row of dots — no animation, no physics, just a count a
/// child can visually verify against an equation. Shared by every math
/// activity that offers concrete counters at low difficulty
/// (AdditionTapView, SubtractionTapView).
struct DotGroup: View {
    let count: Int
    let color: Color
    /// Dots at these zero-based indices are drawn hollow (crossed-out feel
    /// for "take away") instead of filled — used by subtraction to show
    /// removal without any motion or sound.
    var crossedOutIndices: Set<Int> = []

    private let columns = [GridItem(.adaptive(minimum: 18, maximum: 18), spacing: 6)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<max(count, 0), id: \.self) { index in
                if crossedOutIndices.contains(index) {
                    Circle()
                        .strokeBorder(color.opacity(0.5), lineWidth: 2)
                        .frame(width: 16, height: 16)
                } else {
                    Circle().fill(color).frame(width: 16, height: 16)
                }
            }
        }
        .frame(width: 70)
    }
}
