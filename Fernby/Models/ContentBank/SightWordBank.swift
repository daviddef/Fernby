import Foundation

/// Dolch pre-primer-tier words — chosen deliberately for being *irregular*
/// or too abstract to sound out (no picture makes sense for "the" or "is"),
/// which is exactly why sight words are taught as whole-word recognition
/// rather than through PhonicsBank's decode-by-sound path.
enum SightWordBank {
    static let all: [String] = [
        "the", "and", "a", "I", "to", "is", "it", "you", "see", "can",
        "go", "up", "in", "my", "look", "play", "run", "here", "little", "help",
    ]

    static func random(avoiding recent: Set<String> = []) -> String {
        let pool = all.filter { !recent.contains($0) }
        return (pool.isEmpty ? all : pool).randomElement()!
    }

    static func decoys(excluding target: String, count: Int) -> [String] {
        Array(all.filter { $0 != target }.shuffled().prefix(count))
    }
}
