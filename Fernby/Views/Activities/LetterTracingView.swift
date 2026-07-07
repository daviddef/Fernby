import SwiftUI

/// The first "writing" activity in the app — and deliberately not a
/// handwriting grader. Precise stroke-order or shape-matching would punish
/// exactly the fine-motor imprecision this age group is still developing;
/// instead this checks for a genuine, letter-sized attempt (did the child's
/// finger cover a real portion of the guide letter's footprint) and
/// celebrates that, the same "effort over precision" posture as every
/// other activity's gentle-retry contract — just adapted for a gesture
/// instead of a tap. An insufficient attempt never clears the child's
/// work; it just asks them to keep tracing.
struct LetterTracingView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    private static let canvasSize: CGFloat = 260
    /// A trace must span at least this fraction of the canvas in both
    /// dimensions to count — generous enough that any real attempt at the
    /// letter's actual size passes, strict enough that a single tap or a
    /// tiny scribble in one corner doesn't.
    private static let minCoverageFraction: CGFloat = 0.35

    @State private var target = PhonicsBank.random(avoiding: RecentItemTracker.shared.recent(for: "letterTracing"))
    @State private var completedStrokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var hasRespondedFirstTime = false
    @State private var isDone = false
    @State private var feedback: AnswerFeedbackKind?
    @State private var encouragement: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Trace the letter \(target.letter.uppercased())")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

            ZStack {
                Text(target.letter.uppercased())
                    .font(.system(size: 220, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.secondary.opacity(0.22))

                Canvas { context, _ in
                    for stroke in completedStrokes + [currentStroke] {
                        guard let first = stroke.first else { continue }
                        var path = Path()
                        path.move(to: first)
                        for point in stroke.dropFirst() { path.addLine(to: point) }
                        context.stroke(
                            path,
                            with: .color(isDone ? .fernbyCorrect : .accentColor),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !isDone else { return }
                            currentStroke.append(value.location)
                        }
                        .onEnded { _ in
                            guard !isDone, !currentStroke.isEmpty else { return }
                            completedStrokes.append(currentStroke)
                            currentStroke = []
                        }
                )
            }
            .frame(width: Self.canvasSize, height: Self.canvasSize)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color(.secondarySystemBackground)))

            if let encouragement {
                Text(encouragement)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Button("Clear") { clearDrawing() }
                    .buttonStyle(.bordered)
                    .disabled(completedStrokes.isEmpty || isDone)

                Button("Done Tracing!") { checkTrace() }
                    .buttonStyle(.bigTap)
                    .disabled(completedStrokes.isEmpty || isDone)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUpQuestion() }
    }

    private func setUpQuestion() {
        target = PhonicsBank.random(avoiding: RecentItemTracker.shared.recent(for: "letterTracing"))
        RecentItemTracker.shared.record(target.letter, for: "letterTracing")
        completedStrokes = []
        currentStroke = []
        hasRespondedFirstTime = false
        isDone = false
        feedback = nil
        encouragement = nil
        Voice.shared.speak("Trace the letter \(target.letter).", interrupt: true)
    }

    private func clearDrawing() {
        completedStrokes = []
        currentStroke = []
        encouragement = nil
    }

    private func checkTrace() {
        let allPoints = completedStrokes.flatMap { $0 }
        guard let minX = allPoints.map(\.x).min(), let maxX = allPoints.map(\.x).max(),
              let minY = allPoints.map(\.y).min(), let maxY = allPoints.map(\.y).max() else { return }

        let coversWidth = (maxX - minX) >= Self.canvasSize * Self.minCoverageFraction
        let coversHeight = (maxY - minY) >= Self.canvasSize * Self.minCoverageFraction
        let goodAttempt = coversWidth && coversHeight

        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(goodAttempt)
        }

        if goodAttempt {
            isDone = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("Great tracing! That's \(target.letter).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                onAdvance()
            }
        } else {
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            encouragement = "Keep going — trace all the way over the letter!"
            Voice.shared.speak("Keep tracing, all the way over the letter.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                feedback = nil
            }
        }
    }
}
