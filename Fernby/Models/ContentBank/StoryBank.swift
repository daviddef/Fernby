import Foundation

/// Sentence templates for Storybook Weaver. Every fixed word in every
/// template here is deliberately drawn *only* from SightWordBank.all (the
/// pre-primer tier — "the", "and", "a", "I", "to", "is", "it", "you", "see",
/// "can", "go", "up", "in", "my", "look", "play", "run", "here", "little",
/// "help") plus the companion's own name, "Fern". That restriction is the
/// whole point: StoryWeaver only ever offers a story once `reading.
/// sightWords` is mastered, so every connecting word here is guaranteed to
/// already be something the child can read — nothing here should ever be a
/// word they haven't met. `{noun}` is the one open slot, filled from
/// whichever noun banks (CVC/blend/digraph words) are mastered. ("The End!"
/// is deliberately kept out of this contract — StorybookView shows it as a
/// fixed closing banner, not as generated, tap-to-hear body text, the same
/// way every picture book's closing convention is understood well before a
/// child can decode it letter by letter.)
enum StoryBank {
    static let openingLines: [String] = [
        "Look! Fern is here.",
        "Fern can go and play.",
        "Here is Fern. Look, look!",
    ]

    static let closingLines: [String] = [
        "Fern and you can play!",
        "Look! You can help Fern.",
        "You and Fern play here.",
    ]

    static let nounPageTemplates: [String] = [
        "Look! Fern can see a {noun}.",
        "Fern and a {noun} play here.",
        "You can help Fern and the {noun}.",
        "Fern is little, and the {noun} is little.",
        "The {noun} can run and play.",
        "Fern can go up. Fern can see a {noun}!",
        "Up here, Fern can see a {noun}!",
        "Fern and I play here. Look, a {noun}!",
        "Look here! It is a little {noun}.",
        "My {noun} can go in here.",
        "It is my little {noun}.",
    ]

    static let noNounPageTemplates: [String] = [
        "Fern and I run and play.",
        "Look! You can see it here.",
        "Fern can go and help you.",
    ]
}
