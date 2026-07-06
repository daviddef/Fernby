import SwiftUI

/// A listening pass over every phonics entry the app will actually speak to
/// a child. `PhonicsBank` flags isolated-phoneme TTS accuracy as an
/// unverified MVP risk — this screen exists so a human (a parent, a teacher,
/// whoever runs the first playtest) can play each sound in isolation and in
/// its example word before the app is trusted to teach it. Not a debug menu
/// hidden behind a gesture — it's reachable from Settings because the QA
/// pass it enables is a real pre-playtest requirement, not a developer tool.
struct PhonicsPreviewView: View {
    var body: some View {
        List(PhonicsBank.all, id: \.letter) { entry in
            HStack(spacing: 16) {
                Text(entry.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.letter.uppercased())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(entry.exampleWord)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Voice.shared.speak(entry.sound, interrupt: true)
                } label: {
                    Label("Sound", systemImage: "play.circle.fill")
                }
                .buttonStyle(.borderless)

                Button {
                    Voice.shared.speak(entry.exampleWord, interrupt: true)
                } label: {
                    Label("Word", systemImage: "text.bubble.fill")
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Preview Letter Sounds")
        .safeAreaInset(edge: .bottom) {
            Text("Listen to every sound before a child does. Isolated-phoneme pronunciation from system speech varies by device and language settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .background(.thinMaterial)
        }
    }
}
