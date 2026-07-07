import SwiftUI

/// A calm, static row of objects — no animation, no physics, just a count a
/// child can visually verify against an equation. Shared by every math
/// activity that offers concrete counters at low difficulty
/// (AdditionTapView, SubtractionTapView). Was plain colored dots; now a fun,
/// randomly-picked real object (see FunObjectBank) so the equation visibly
/// corresponds to a recognizable quantity of *something*, not an
/// abstraction — "4 balloons," not "4 dots."
struct DotGroup: View {
    let count: Int
    let emoji: String
    /// Objects at these zero-based indices are drawn faded with an X
    /// overlay instead of solid — used by subtraction to show removal
    /// without any motion or sound.
    var crossedOutIndices: Set<Int> = []

    private let columns = [GridItem(.adaptive(minimum: 30, maximum: 30), spacing: 4)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<max(count, 0), id: \.self) { index in
                Text(emoji)
                    .font(.system(size: 26))
                    .opacity(crossedOutIndices.contains(index) ? 0.25 : 1)
                    .overlay {
                        if crossedOutIndices.contains(index) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.fernbyWrong.opacity(0.8))
                        }
                    }
            }
        }
        .frame(width: 100)
    }
}
