import SwiftUI

/// Bonus round — pure exploration, no right or wrong answer at all: tap
/// any word to see it enlarge and hear it spoken, Endless-Alphabet-style,
/// except every word here is free and already something the child has
/// met through the normal quest loop, not gated behind a purchase. There's
/// nothing to complete; "Continue" is available immediately and always.
struct WordExplorerView: View {
    let onDone: () -> Void

    @State private var words: [BuildableWord] = []
    @State private var revealed: BuildableWord?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 24) {
            Text("Word Explorer")
                .font(.system(size: 22, weight: .heavy, design: .rounded))

            Text("Tap a word to explore it!")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(words, id: \.word) { word in
                    Button {
                        reveal(word)
                    } label: {
                        Text(word.emoji)
                            .font(.system(size: 40))
                            .frame(width: 88, height: 88)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.16))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Explore the word \(word.word)")
                }
            }

            Button("Continue") { onDone() }
                .buttonStyle(.bigTap)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if let revealed {
                revealCard(revealed)
            }
        }
        .onAppear { setUp() }
    }

    private func revealCard(_ word: BuildableWord) -> some View {
        VStack(spacing: 16) {
            Text(word.emoji).font(.system(size: 80))
            Text(word.word)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.accentColor)
        }
        .padding(36)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(radius: 16)
        )
        .transition(.scale.combined(with: .opacity))
        .onTapGesture { withAnimation { self.revealed = nil } }
    }

    private func setUp() {
        let pool = WordBuildingBank.all + BlendWordBank.all + DigraphWordBank.all
        words = Array(pool.shuffled().prefix(6))
        revealed = nil
        Voice.shared.speak("Tap a word to explore it!", interrupt: true)
    }

    private func reveal(_ word: BuildableWord) {
        Haptics.shared.tap()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            revealed = word
        }
        Voice.shared.speak(word.word, interrupt: true)
    }
}
