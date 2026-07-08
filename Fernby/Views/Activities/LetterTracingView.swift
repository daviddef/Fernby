import SwiftUI
import UIKit

/// The first "writing" activity in the app — and deliberately not a
/// handwriting grader. Precise stroke-*order* matching would punish exactly
/// the fine-motor imprecision this age group is still developing; instead
/// this checks that the finger actually followed the letter's shape (not
/// just moved around inside its bounding box — an early version scored
/// pure bounding-box coverage and passed a scribble that didn't resemble
/// the letter at all, caught from a real TestFlight screenshot) and
/// celebrates that, the same "effort over precision" posture as every
/// other activity's gentle-retry contract, just adapted for a gesture
/// instead of a tap. An insufficient attempt never clears the child's
/// work; it just asks them to keep tracing.
struct LetterTracingView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    private static let canvasSize: CGFloat = 260
    /// Cell size for the coverage grid — coarse enough to be forgiving of
    /// wobble (a stroke drawn 16pt wide already has slop built in), fine
    /// enough to actually distinguish "traced the curve" from "scribbled
    /// somewhere nearby."
    private static let gridStep = 14
    /// Fraction of the letter's own "ink" cells that must be visited by the
    /// trace to count. Generous on purpose — this is coverage of the real
    /// shape, not a stroke-order or precision grade.
    private static let minInkCoverage = 0.5
    /// Fraction of the *drawn* cells that must actually be on the letter's
    /// ink. Without this, coverage alone is gameable: a scribble that fills
    /// most of the canvas trivially touches enough ink cells to pass,
    /// because it touches almost everything (caught from a real TestFlight
    /// screenshot — a solid colored-in blob was marked correct). This is
    /// the same check in the other direction: most of what was drawn has
    /// to land on the letter, not just some of the letter get touched.
    private static let minPrecision = 0.5

    private struct GridCell: Hashable {
        let row: Int
        let col: Int
    }

    @State private var target = PhonicsBank.random(avoiding: RecentItemTracker.shared.recent(for: "letterTracing"))
    @State private var completedStrokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var inkCells: Set<GridCell> = []
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
        inkCells = Self.computeInkCells(for: target.letter)
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
        let (recall, precision) = coverageFractions()
        let goodAttempt = recall >= Self.minInkCoverage && precision >= Self.minPrecision

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
            encouragement = "Keep going — trace along the letter's shape!"
            Voice.shared.speak("Keep tracing, right along the letter.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                feedback = nil
            }
        }
    }

    /// Two independent fractions, both required: `recall` is how much of
    /// the guide letter's own ink the drawn stroke actually passed through
    /// (real shape coverage, not just "moved around somewhere in the
    /// box"); `precision` is how much of what was actually drawn landed on
    /// that ink, rather than scribbled broadly across the canvas. A wobbly
    /// but real trace scores well on both; a scribble or solid fill scores
    /// well on recall alone, which is exactly the gap precision closes.
    private func coverageFractions() -> (recall: Double, precision: Double) {
        guard !inkCells.isEmpty else { return (0, 0) }
        var drawnCells: Set<GridCell> = []
        for point in completedStrokes.flatMap({ $0 }) {
            drawnCells.insert(GridCell(row: Int(point.y) / Self.gridStep, col: Int(point.x) / Self.gridStep))
        }
        guard !drawnCells.isEmpty else { return (0, 0) }
        let hitCells = drawnCells.intersection(inkCells)
        let recall = Double(hitCells.count) / Double(inkCells.count)
        let precision = Double(hitCells.count) / Double(drawnCells.count)
        return (recall, precision)
    }

    /// Rasterizes the guide letter — same font/size/weight as the on-screen
    /// Text — into a coarse grid of "ink present" cells. Done once per
    /// question rather than per pixel-perfect comparison, so this stays
    /// fast and just as generous as intended: a whole cell (14pt) counts as
    /// covered the moment any part of the stroke passes through it.
    private static func computeInkCells(for letter: String) -> Set<GridCell> {
        let size = Int(canvasSize)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2),
              let context = CGContext(
                data: nil, width: size, height: size,
                bitsPerComponent: 8, bytesPerRow: 0,
                space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue
              ) else { return [] }

        context.setFillColor(gray: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        UIGraphicsPushContext(context)
        let descriptor = UIFont.systemFont(ofSize: 220, weight: .heavy).fontDescriptor.withDesign(.rounded)
        let font = descriptor.map { UIFont(descriptor: $0, size: 220) } ?? UIFont.systemFont(ofSize: 220, weight: .heavy)
        let string = letter.uppercased() as NSString
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        let stringSize = string.size(withAttributes: attributes)
        let origin = CGPoint(x: (CGFloat(size) - stringSize.width) / 2, y: (CGFloat(size) - stringSize.height) / 2)
        string.draw(at: origin, withAttributes: attributes)
        UIGraphicsPopContext()

        guard let data = context.data else { return [] }
        // Don't assume bytesPerRow == width — passing bytesPerRow: 0 lets
        // CG choose its own (possibly padded) row stride.
        let bytesPerRow = context.bytesPerRow
        let buffer = data.bindMemory(to: UInt8.self, capacity: bytesPerRow * size)

        var cells: Set<GridCell> = []
        let columns = size / gridStep
        for row in 0..<columns {
            for col in 0..<columns {
                var hasInk = false
                rowScan: for dy in 0..<gridStep {
                    let y = row * gridStep + dy
                    guard y < size else { break }
                    for dx in 0..<gridStep {
                        let x = col * gridStep + dx
                        guard x < size else { continue }
                        if buffer[y * bytesPerRow + x] < 200 {
                            hasInk = true
                            break rowScan
                        }
                    }
                }
                if hasInk { cells.insert(GridCell(row: row, col: col)) }
            }
        }
        return cells
    }
}
