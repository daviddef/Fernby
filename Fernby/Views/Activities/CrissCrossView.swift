import SwiftUI

/// Bonus round — a two-word mini crossword, adapted the way real K-1
/// "picture crosswords" work: picture clues instead of text clues, and
/// letters chosen from a bank rather than freely spelled (see
/// CrosswordBank). Fill order is fixed (the across word left-to-right,
/// then the down word top-to-bottom) so a shared cell is only ever placed
/// once; tapping any tray tile fills the next open cell, same "tap in
/// order" convention as LetterScrambleView.
struct CrissCrossView: View {
    let onDone: () -> Void

    private struct Cell: Identifiable {
        let id: String
        let row: Int
        let col: Int
        let correctLetter: String
    }

    private struct Tile: Identifiable {
        let id = UUID()
        let letter: String
        var isPlaced: Bool = false
    }

    private static let cellSize: CGFloat = 46

    @State private var puzzle: CrosswordPuzzle?
    @State private var cells: [Cell] = []
    @State private var fillSequence: [Cell] = []
    @State private var filledLetters: [String: String] = [:]
    @State private var tray: [Tile] = []
    @State private var feedback: AnswerFeedbackKind?
    @State private var isSolved = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Criss-Cross")
                .font(.system(size: 22, weight: .heavy, design: .rounded))

            if let puzzle {
                HStack(spacing: 28) {
                    VStack(spacing: 4) {
                        Text(puzzle.across.emoji).font(.system(size: 34))
                        Text("Across").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(.secondary)
                    }
                    VStack(spacing: 4) {
                        Text(puzzle.down.emoji).font(.system(size: 34))
                        Text("Down").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(.secondary)
                    }
                }

                grid

                HStack(spacing: 10) {
                    ForEach(tray) { tile in
                        Button {
                            place(tile)
                        } label: {
                            Text(tile.letter.uppercased())
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .frame(width: 46, height: 46)
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
            } else {
                Text("Learn a few more words and a criss-cross puzzle will be here!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Continue") { onDone() }
                    .buttonStyle(.bigTap)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUp() }
    }

    private var grid: some View {
        let maxRow = (cells.map(\.row).max() ?? 0)
        let maxCol = (cells.map(\.col).max() ?? 0)
        return ZStack(alignment: .topLeading) {
            ForEach(cells) { cell in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(filledLetters[cell.id] == nil ? 0.15 : 0.85))
                    .frame(width: Self.cellSize - 4, height: Self.cellSize - 4)
                    .overlay(
                        Text(filledLetters[cell.id]?.uppercased() ?? "")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    )
                    .offset(x: CGFloat(cell.col) * Self.cellSize, y: CGFloat(cell.row) * Self.cellSize)
            }
        }
        .frame(width: CGFloat(maxCol + 1) * Self.cellSize, height: CGFloat(maxRow + 1) * Self.cellSize)
    }

    private func setUp() {
        guard let newPuzzle = CrosswordBank.randomPuzzle() else {
            puzzle = nil
            return
        }
        puzzle = newPuzzle

        var seen = Set<String>()
        var builtCells: [Cell] = []
        var sequence: [Cell] = []

        for (i, letter) in newPuzzle.across.letters.enumerated() {
            let id = "\(newPuzzle.downIndex)_\(i)"
            let cell = Cell(id: id, row: newPuzzle.downIndex, col: i, correctLetter: letter)
            builtCells.append(cell)
            sequence.append(cell)
            seen.insert(id)
        }
        for (j, letter) in newPuzzle.down.letters.enumerated() {
            let id = "\(j)_\(newPuzzle.acrossIndex)"
            guard !seen.contains(id) else { continue }
            let cell = Cell(id: id, row: j, col: newPuzzle.acrossIndex, correctLetter: letter)
            builtCells.append(cell)
            sequence.append(cell)
            seen.insert(id)
        }

        cells = builtCells
        fillSequence = sequence
        filledLetters = [:]
        tray = sequence.map(\.correctLetter).shuffled().map { Tile(letter: $0) }
        feedback = nil
        isSolved = false
        Voice.shared.speak("Fill in the letters to finish both words!", interrupt: true)
    }

    private func place(_ tile: Tile) {
        guard let trayIndex = tray.firstIndex(where: { $0.id == tile.id }), !tray[trayIndex].isPlaced else { return }
        guard let nextCell = fillSequence.first(where: { filledLetters[$0.id] == nil }) else { return }
        Haptics.shared.tap()
        tray[trayIndex].isPlaced = true
        filledLetters[nextCell.id] = tray[trayIndex].letter

        if fillSequence.allSatisfy({ filledLetters[$0.id] != nil }) {
            checkAnswer()
        }
    }

    private func checkAnswer() {
        let allCorrect = fillSequence.allSatisfy { filledLetters[$0.id] == $0.correctLetter }
        if allCorrect {
            isSolved = true
            feedback = .correct
            Haptics.shared.correct()
            guard let puzzle else { return }
            Voice.shared.speak("\(PraiseBank.random()) \(puzzle.across.word) and \(puzzle.down.word)!")
        } else {
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Not quite — try another order!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                feedback = nil
                filledLetters = [:]
                for index in tray.indices { tray[index].isPlaced = false }
            }
        }
    }
}
