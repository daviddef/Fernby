import SwiftUI

/// A single word in a story page, with its character range in the page's
/// text — computed once per page so narration's word-range callbacks (see
/// Voice.speakWithWordHighlighting) can be matched back to a specific
/// tappable word chip for real-time karaoke-style highlighting.
private struct StoryToken: Identifiable {
    let id: Int
    let word: String
    let range: NSRange
}

private func tokenize(_ text: String) -> [StoryToken] {
    let ns = text as NSString
    var tokens: [StoryToken] = []
    var searchFrom = 0
    for (index, word) in text.split(separator: " ").enumerated() {
        let word = String(word)
        let searchRange = NSRange(location: searchFrom, length: ns.length - searchFrom)
        let found = ns.range(of: word, options: [], range: searchRange)
        guard found.location != NSNotFound else { continue }
        tokens.append(StoryToken(id: index, word: word, range: found))
        searchFrom = found.location + found.length
    }
    return tokens
}

/// The flagship feature this app's "wow" gap research pointed to directly:
/// no competitor closes the loop from "what a child has actually mastered"
/// to "a real, ownable story they can read cover to cover" — see
/// StoryWeaver. This view is the reading experience itself: page-by-page,
/// word-by-word highlighting synced to narration (karaoke-style, via
/// AVSpeechSynthesizer's willSpeakRangeOfSpeechString), and tap-any-word-
/// to-hear-it-alone — the same "text is always fully visible, audio is a
/// bonus not a requirement" contract the rest of the app follows for muted
/// play.
struct StorybookView: View {
    let onDismiss: () -> Void

    @ObservedObject private var progressStore = ProgressStore.shared
    @State private var story: Story?
    @State private var pageIndex = 0
    @State private var tokens: [StoryToken] = []
    @State private var highlightedTokenID: Int?

    var body: some View {
        NavigationStack {
            Group {
                if let story {
                    pageView(story)
                } else {
                    notReadyView
                }
            }
            .navigationTitle(story?.title ?? "Storybook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        Voice.shared.stop()
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            story = StoryWeaver.generate(progressStore: progressStore)
        }
    }

    private var notReadyView: some View {
        VStack(spacing: 20) {
            CompanionView(progressStore: progressStore, size: 120, bobs: false)
            Text("\(CompanionAbilityCatalog.companionName)'s storybook is almost ready!")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
            Text("Master \(StoryWeaver.nextRequirementTitle(progressStore: progressStore)) to unlock your first story.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func pageView(_ story: Story) -> some View {
        let page = story.pages[pageIndex]
        let isLastPage = pageIndex == story.pages.count - 1

        return VStack(spacing: 24) {
            Group {
                if let emoji = page.emoji {
                    Text(emoji).font(.system(size: 84))
                } else {
                    CompanionView(progressStore: progressStore, size: 84, bobs: false)
                }
            }
            .frame(height: 100)

            WrapLayout(spacing: 8, lineSpacing: 10) {
                ForEach(tokens) { token in
                    Text(token.word)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(highlightedTokenID == token.id ? Color.accentColor.opacity(0.35) : .clear)
                        )
                        .onTapGesture {
                            Voice.shared.speak(token.word.trimmingCharacters(in: .punctuationCharacters))
                        }
                        .accessibilityLabel(token.word)
                        .accessibilityHint("Double tap to hear this word")
                }
            }
            .padding(.horizontal, 24)

            if isLastPage {
                Text("The End!")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            HStack(spacing: 28) {
                Button {
                    goToPage(pageIndex - 1)
                } label: {
                    Image(systemName: "chevron.left.circle.fill").font(.system(size: 34))
                }
                .disabled(pageIndex == 0)
                .accessibilityLabel("Previous page")

                Button {
                    narrateCurrentPage(story)
                } label: {
                    Image(systemName: "speaker.wave.2.circle.fill").font(.system(size: 44))
                }
                .accessibilityLabel("Read this page aloud")

                if isLastPage {
                    Button {
                        Voice.shared.stop()
                        onDismiss()
                    } label: {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 34))
                    }
                    .accessibilityLabel("Finish storybook")
                } else {
                    Button {
                        goToPage(pageIndex + 1)
                    } label: {
                        Image(systemName: "chevron.right.circle.fill").font(.system(size: 34))
                    }
                    .accessibilityLabel("Next page")
                }
            }
            .foregroundStyle(Color.accentColor)
            .padding(.bottom, 12)

            Text("Page \(pageIndex + 1) of \(story.pages.count)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { setUpPage(story) }
        .onChange(of: pageIndex) { setUpPage(story) }
    }

    private func setUpPage(_ story: Story) {
        tokens = tokenize(story.pages[pageIndex].text)
        highlightedTokenID = nil
        narrateCurrentPage(story)
    }

    private func narrateCurrentPage(_ story: Story) {
        let text = story.pages[pageIndex].text
        Voice.shared.speakWithWordHighlighting(text, onWordRange: { range in
            highlightedTokenID = tokens.first { token in
                range.location >= token.range.location && range.location < token.range.location + max(token.range.length, 1)
            }?.id
        }, onFinish: {
            highlightedTokenID = nil
        })
    }

    private func goToPage(_ newIndex: Int) {
        guard let story, newIndex >= 0, newIndex < story.pages.count else { return }
        Haptics.shared.tap()
        Voice.shared.stop()
        pageIndex = newIndex
    }
}
