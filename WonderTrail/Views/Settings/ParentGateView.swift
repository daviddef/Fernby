import SwiftUI

/// A standard "grown-up check" gate: a two-digit addition problem that
/// requires regrouping, well past what the app's own placement/difficulty
/// range ever presents to a child, so it isn't solvable by guessing the way
/// through the app itself. Blocks entry to Settings, not a COPPA consent
/// mechanism on its own — just keeps a curious child from wandering into
/// toggles meant for a parent.
struct ParentGateView: View {
    let onPassed: () -> Void
    let onCancel: () -> Void

    @State private var a = Int.random(in: 23...58)
    @State private var b = Int.random(in: 14...49)
    @State private var choices: [Int] = []
    @State private var showedWrongHint = false

    private var answer: Int { a + b }

    var body: some View {
        VStack(spacing: 20) {
            Text("Grown-Ups Only")
                .font(.system(size: 22, weight: .heavy, design: .rounded))

            Text("Solve this to continue:")
                .foregroundStyle(.secondary)

            Text("\(a) + \(b) = ?")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .padding(.vertical, 4)

            VStack(spacing: 12) {
                ForEach(choices, id: \.self) { choice in
                    Button("\(choice)") {
                        if choice == answer {
                            onPassed()
                        } else {
                            showedWrongHint = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
            }

            if showedWrongHint {
                Text("Not quite — try the math again.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button("Cancel", role: .cancel, action: onCancel)
                .padding(.top, 8)
        }
        .padding()
        .onAppear { setUpChoices() }
    }

    private func setUpChoices() {
        var options = Set([answer])
        while options.count < 4 {
            options.insert(Int.random(in: max(0, answer - 15)...(answer + 15)))
        }
        choices = Array(options).shuffled()
    }
}
