import SwiftUI

/// Bonus round — a word-scramble, adapted the way research on this age
/// group actually recommends: never blind unscrambling. The picture clue
/// stays on screen the whole time, and letters are tapped in order into a
/// waiting row rather than freely typed, following the same "tap, don't
/// type" convention every other activity in this app already uses. Tapping
/// a filled slot returns that letter to the tray — undo is free, there's
/// no penalty for a wrong order, just gentle correction.
struct LetterScrambleView: View {
    let onDone: () -> Void

    private struct Tile: Identifiable {
        let id = UUID()
        let letter: String
        var isPlaced: Bool = false
    }

    @State private var target = WordBuildingBank.random()
    @State private var tray: [Tile] = []
    @State private var slots: [Tile?] = []
    @State private var feedback: AnswerFeedbackKind?
    @State private var isSolved = false

    var body: some View {
        VStack(spacing: 28) {
            Text("Letter Scramble")
                .font(.system(size: 22, weight: .heavy, design: .rounded))

            Text(target.emoji)
                .font(.system(size: 64))

            HStack(spacing: 8) {
                ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                    Button {
                        returnToTray(slotIndex: index)
                    } label: {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.accentColor.opacity(slot == nil ? 0.15 : 0.85))
                            .frame(width: 44, height: 52)
                            .overlay(
                                Text(slot?.letter.uppercased() ?? "")
                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(slot == nil || isSolved)
                }
            }

            HStack(spacing: 10) {
                ForEach(tray) { tile in
                    Button {
                        place(tile)
                    } label: {
                        Text(tile.letter.uppercased())
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .frame(width: 48, height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.16))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(tile.isPlaced || isSolved)
                    .opacity(tile.isPlaced ? 0 : 1)
                }
            }

            Button("Continue") { onDone() }
                .buttonStyle(.bigTap)
                .disabled(!isSolved)
                .opacity(isSolved ? 1 : 0.35)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUp() }
    }

    private func setUp() {
        let pool = WordBuildingBank.all + BlendWordBank.all + DigraphWordBank.all
        target = pool.randomElement() ?? WordBuildingBank.random()
        tray = target.letters.shuffled().map { Tile(letter: $0) }
        // Guard against a shuffle that happens to land in the solved order —
        // re-shuffle once so there's always an actual scramble to solve.
        if tray.map(\.letter) == target.letters, tray.count > 1 {
            tray.shuffle()
        }
        slots = Array(repeating: nil, count: target.letters.count)
        feedback = nil
        isSolved = false
        Voice.shared.speak("Put the letters in order to spell the word!", interrupt: true)
    }

    private func place(_ tile: Tile) {
        guard let trayIndex = tray.firstIndex(where: { $0.id == tile.id }), !tray[trayIndex].isPlaced else { return }
        guard let slotIndex = slots.firstIndex(where: { $0 == nil }) else { return }
        Haptics.shared.tap()
        tray[trayIndex].isPlaced = true
        slots[slotIndex] = tray[trayIndex]

        if !slots.contains(where: { $0 == nil }) {
            checkAnswer()
        }
    }

    private func returnToTray(slotIndex: Int) {
        guard !isSolved, let tile = slots[slotIndex] else { return }
        Haptics.shared.tap()
        slots[slotIndex] = nil
        if let trayIndex = tray.firstIndex(where: { $0.id == tile.id }) {
            tray[trayIndex].isPlaced = false
        }
    }

    private func checkAnswer() {
        let assembled = slots.compactMap { $0?.letter }
        if assembled == target.letters {
            isSolved = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("\(PraiseBank.random()) \(target.word)!")
        } else {
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Not quite — try another order!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                feedback = nil
                slots = Array(repeating: nil, count: target.letters.count)
                for index in tray.indices { tray[index].isPlaced = false }
            }
        }
    }
}
