import SwiftUI

/// The invisible first-quest calibration. Deliberately looks and feels like
/// any other quest — no "test" framing, no progress bar labeled
/// "assessment" — while PlacementEngine silently decides where the child
/// starts. Interleaves reading and math probes rather than blocking them,
/// so it plays like a normal mixed quest.
struct PlacementQuestView: View {
    let onComplete: () -> Void

    @StateObject private var engine = PlacementEngine()
    @State private var probeOrder: [Subject] = [.reading, .math, .reading, .math, .reading, .math]
    @State private var probeIndex = 0
    @State private var currentNode: SkillNode?

    var body: some View {
        VStack {
            if let node = currentNode {
                ProgressDots(total: probeOrder.count, completed: probeIndex)
                    .padding(.top, 12)

                ActivityContainerView(
                    node: node,
                    onFirstResponse: { correct in
                        engine.recordProbeResult(subject: node.subject, firstTryCorrect: correct)
                    },
                    onAdvance: advance
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            currentNode = engine.nextProbe(for: probeOrder[probeIndex])
            Voice.shared.speak("Let's start your first quest!", interrupt: true)
        }
    }

    private func advance() {
        probeIndex += 1
        guard probeIndex < probeOrder.count, !engine.isComplete else {
            engine.finalize()
            onComplete()
            return
        }
        currentNode = engine.nextProbe(for: probeOrder[probeIndex])
    }
}

/// A quiet "how far along" indicator — dots, not a labeled progress bar, so
/// this never reads as a test.
private struct ProgressDots: View {
    let total: Int
    let completed: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
