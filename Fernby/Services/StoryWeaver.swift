import Foundation

struct StoryPage {
    let text: String
    /// Emoji to illustrate the page — the noun's own emoji from whichever
    /// content bank supplied it, or nil for pages with no noun (rendered
    /// as the companion instead, in StorybookView).
    let emoji: String?
}

struct Story {
    let title: String
    let pages: [StoryPage]
}

/// Generates a short, fully-decodable storybook from a child's own mastery
/// data — no two competitors in this space (see the "wow" research this
/// was built from) close the loop from "what a child has actually
/// mastered" to "a real story they can read cover to cover." Every word is
/// guaranteed either a mastered sight word (the connective tissue, see
/// StoryBank) or a mastered whole-word from a mastered noun bank — nothing
/// here can ever be a word the child hasn't already met, which is the
/// entire point: this is proof-of-reading, not another quiz.
@MainActor
enum StoryWeaver {
    /// Gates *any* story at all — without sight words there's no
    /// grammatical connective tissue to build a sentence from.
    private static let requiredNodeID = "reading.sightWords"

    /// Each noun bank is gated by the node that actually certifies fluent
    /// whole-word reading of it (not the sound-blending step before it) —
    /// see WordBuildingView's nodeID/bank pairing, which this mirrors.
    private static let nounSources: [(nodeID: String, title: String, words: [(word: String, emoji: String)])] = [
        ("reading.cvcWords", "CVC Words", WordBuildingBank.all.map { ($0.word, $0.emoji) }),
        ("reading.blendWords", "Blend Words", BlendWordBank.all.map { ($0.word, $0.emoji) }),
        ("reading.digraphWords", "Digraph Words", DigraphWordBank.all.map { ($0.word, $0.emoji) }),
    ]

    private static let pagesPerStory = 6

    static func availableNouns(progressStore: ProgressStore) -> [(word: String, emoji: String)] {
        nounSources
            .filter { progressStore.progress(for: $0.nodeID).mastered }
            .flatMap(\.words)
    }

    static func isReady(progressStore: ProgressStore) -> Bool {
        progressStore.progress(for: requiredNodeID).mastered && !availableNouns(progressStore: progressStore).isEmpty
    }

    /// What a child still needs to master before their first storybook
    /// unlocks — surfaced as an encouraging, concrete placeholder rather
    /// than a blank "not available yet."
    static func nextRequirementTitle(progressStore: ProgressStore) -> String {
        guard progressStore.progress(for: requiredNodeID).mastered else {
            return SkillGraph.node(id: requiredNodeID)?.title ?? "Sight Words"
        }
        // Sight words are mastered but no noun bank yet — name the nearest one.
        return nounSources.first.flatMap { SkillGraph.node(id: $0.nodeID)?.title } ?? "a few more words"
    }

    static func generate(progressStore: ProgressStore) -> Story? {
        guard isReady(progressStore: progressStore) else { return nil }

        var nounPool = availableNouns(progressStore: progressStore).shuffled()
        var nounTemplates = StoryBank.nounPageTemplates.shuffled()
        var noNounTemplates = StoryBank.noNounPageTemplates.shuffled()

        var pages: [StoryPage] = [StoryPage(text: StoryBank.openingLines.randomElement()!, emoji: nil)]

        for _ in 0..<pagesPerStory {
            if !nounPool.isEmpty {
                let noun = nounPool.removeFirst()
                if nounTemplates.isEmpty { nounTemplates = StoryBank.nounPageTemplates.shuffled() }
                let template = nounTemplates.removeFirst()
                pages.append(StoryPage(text: template.replacingOccurrences(of: "{noun}", with: noun.word), emoji: noun.emoji))
            } else {
                if noNounTemplates.isEmpty { noNounTemplates = StoryBank.noNounPageTemplates.shuffled() }
                pages.append(StoryPage(text: noNounTemplates.removeFirst(), emoji: nil))
            }
        }

        pages.append(StoryPage(text: StoryBank.closingLines.randomElement()!, emoji: "🎉"))

        return Story(title: "\(CompanionAbilityCatalog.companionName)'s Big Adventure", pages: pages)
    }
}
