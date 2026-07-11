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

private let relativeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter
}()

/// The flagship feature this app's "wow" gap research pointed to directly:
/// no competitor closes the loop from "what a child has actually mastered"
/// to "a real, ownable story they can read cover to cover" — see
/// StoryWeaver. Every generated story is saved to StoryLibrary immediately
/// (a shelf, not a disposable screen) — the point is a growing set of books
/// a family can reread and show off as concrete evidence of progress, not
/// another one-shot activity. This view is both the shelf and the reading
/// experience: page-by-page, word-by-word highlighting synced to narration
/// (karaoke-style, via AVSpeechSynthesizer's willSpeakRangeOfSpeechString),
/// and tap-any-word-to-hear-it-alone — the same "text is always fully
/// visible, audio is a bonus not a requirement" contract the rest of the
/// app follows for muted play.
struct StorybookView: View {
    let onDismiss: () -> Void

    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var library = StoryLibrary.shared
    @State private var openStory: Story?
    @State private var pageIndex = 0
    @State private var tokens: [StoryToken] = []
    @State private var highlightedTokenID: Int?

    private var isReadyForNewStory: Bool {
        StoryWeaver.isReady(progressStore: progressStore)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let openStory {
                    pageView(openStory)
                } else {
                    shelfView
                }
            }
            .navigationTitle(openStory?.title ?? "\(CompanionAbilityCatalog.companionName)'s Storybooks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if openStory != nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Shelf") {
                            Voice.shared.stop()
                            openStory = nil
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Voice.shared.stop()
                        onDismiss()
                    }
                }
            }
        }
    }

    // MARK: - Shelf

    private var shelfView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isReadyForNewStory {
                    Button {
                        startNewStory()
                    } label: {
                        Label("A New Story!", systemImage: "sparkles")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bigTap)
                    .padding(.horizontal)
                    .padding(.top, 20)
                } else {
                    VStack(spacing: 16) {
                        CompanionView(progressStore: progressStore, size: 100, bobs: false)
                        Text("A new story unlocks when you master \(StoryWeaver.nextRequirementTitle(progressStore: progressStore))!")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 20)
                }

                if library.stories.isEmpty {
                    if isReadyForNewStory {
                        Text("Your storybook shelf is empty — write your first story above!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 8)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Storybooks")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .padding(.horizontal)

                        ForEach(library.storiesNewestFirst) { story in
                            Button {
                                openSavedStory(story)
                            } label: {
                                HStack(spacing: 14) {
                                    Text(story.pages.first(where: { $0.emoji != nil })?.emoji ?? "📖")
                                        .font(.system(size: 30))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(story.title)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.primary)
                                        Text(relativeDateFormatter.localizedString(for: story.createdAt, relativeTo: Date()))
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }

                Spacer(minLength: 24)
            }
        }
    }

    private func startNewStory() {
        guard let story = StoryWeaver.generate(progressStore: progressStore) else { return }
        library.save(story)
        Haptics.shared.tap()
        pageIndex = 0
        openStory = story
    }

    private func openSavedStory(_ story: Story) {
        Haptics.shared.tap()
        pageIndex = 0
        openStory = story
    }

    // MARK: - Reading

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
                        openStory = nil
                    } label: {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 34))
                    }
                    .accessibilityLabel("Back to the shelf")
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
        guard let openStory, newIndex >= 0, newIndex < openStory.pages.count else { return }
        Haptics.shared.tap()
        Voice.shared.stop()
        pageIndex = newIndex
    }
}
