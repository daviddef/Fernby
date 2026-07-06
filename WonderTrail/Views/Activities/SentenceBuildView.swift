import SwiftUI
import UniformTypeIdentifiers

/// The one activity that isn't 3-choice tap: word tiles move from a
/// shuffled tray into ordered slots, either by dragging or — since
/// drag-and-drop precision is a real fine-motor ask at this age, and the
/// two need to be equally supported, not one primary and one apology — by
/// tapping a tray word to send it to the next empty slot. Deliberately
/// fixed at 4 slots across every sentence in SentenceBank so the drop-zone
/// layout never shifts mid-activity. A wrong arrangement never ends the
/// activity — the tiles return to the tray and the same sentence is
/// offered again, matching every other activity's gentle-retry contract.
struct SentenceBuildView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var sentence = SentenceBank.random()
    @State private var slots: [String?] = [nil, nil, nil, nil]
    @State private var trayWords: [String] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var showedWrongHint = false

    var body: some View {
        VStack(spacing: 28) {
            Text("Drag the words into order")
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            HStack(spacing: 10) {
                ForEach(0..<slots.count, id: \.self) { index in
                    slotView(index)
                }
            }

            HStack(spacing: 12) {
                ForEach(trayWords, id: \.self) { word in
                    tileView(word)
                        .onDrag { NSItemProvider(object: word as NSString) }
                        .onTapGesture { placeInNextEmptySlot(word) }
                }
            }
            .frame(minHeight: 60)

            if showedWrongHint {
                Text("Not quite that order — the words went back to the tray.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .onAppear { setUpQuestion() }
    }

    private func slotView(_ index: Int) -> some View {
        Group {
            if let word = slots[index] {
                tileView(word)
                    .onTapGesture { returnToTray(from: index) }
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .frame(width: 64, height: 60)
            }
        }
        .onDrop(of: [.plainText], isTargeted: nil) { providers in
            handleDrop(providers, into: index)
            return true
        }
    }

    private func tileView(_ word: String) -> some View {
        Text(word)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .frame(minWidth: 64, minHeight: 60)
            .padding(.horizontal, 10)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.accentColor.opacity(0.85)))
            .foregroundStyle(.white)
    }

    private func handleDrop(_ providers: [NSItemProvider], into index: Int) {
        guard let provider = providers.first else { return }
        _ = provider.loadObject(ofClass: NSString.self) { reading, _ in
            guard let word = reading as? String else { return }
            DispatchQueue.main.async { place(word, into: index) }
        }
    }

    private func place(_ word: String, into index: Int) {
        guard !justAnsweredCorrectly else { return }
        // Pull the word out of wherever it currently is (tray or another slot).
        if let trayIndex = trayWords.firstIndex(of: word) {
            trayWords.remove(at: trayIndex)
        } else if let sourceSlot = slots.firstIndex(of: word) {
            slots[sourceSlot] = nil
        }
        // Whatever already occupied the target slot goes back to the tray.
        if let displaced = slots[index] {
            trayWords.append(displaced)
        }
        slots[index] = word
        showedWrongHint = false

        if slots.allSatisfy({ $0 != nil }) {
            checkAnswer()
        }
    }

    private func placeInNextEmptySlot(_ word: String) {
        guard !justAnsweredCorrectly, let nextEmpty = slots.firstIndex(where: { $0 == nil }) else { return }
        place(word, into: nextEmpty)
    }

    private func returnToTray(from index: Int) {
        guard !justAnsweredCorrectly, let word = slots[index] else { return }
        slots[index] = nil
        trayWords.append(word)
        showedWrongHint = false
    }

    private func checkAnswer() {
        let attempt = slots.compactMap { $0 }
        let correct = attempt == sentence.words

        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            Haptics.shared.correct()
            Voice.shared.speak("Yes! \(sentence.spoken)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                onAdvance()
            }
        } else {
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's try that again.")
            showedWrongHint = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                trayWords = sentence.words.shuffled()
                slots = Array(repeating: nil, count: sentence.words.count)
            }
        }
    }

    private func setUpQuestion() {
        sentence = SentenceBank.random()
        trayWords = sentence.words.shuffled()
        slots = Array(repeating: nil, count: sentence.words.count)
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        showedWrongHint = false
        Voice.shared.speak("Build this sentence: \(sentence.spoken)", interrupt: true)
    }
}
