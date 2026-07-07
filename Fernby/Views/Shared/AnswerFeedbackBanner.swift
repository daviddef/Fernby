import SwiftUI

/// A brief, on-screen confirmation of right/wrong that never depends on
/// audio. Settings lets a parent mute Voice entirely — this is what makes
/// that safe to do without the app going silent-and-unclear for the child.
/// Deliberately one calm pop-in banner, not confetti or a flash, matching
/// the existing no-flashing-rewards constraint (see BigButtonStyle,
/// QuestSummaryView).
enum AnswerFeedbackKind: Equatable {
    case correct
    case tryAgain
}

private struct AnswerFeedbackBanner: View {
    let kind: AnswerFeedbackKind

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: kind == .correct ? "checkmark.circle.fill" : "arrow.counterclockwise.circle.fill")
                .font(.system(size: 24, weight: .bold))
            Text(kind == .correct ? "Yes!" : "Try again!")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(Capsule().fill(kind == .correct ? Color.fernbyCorrect : Color.fernbyWrong))
        .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
    }
}

private struct AnswerFeedbackModifier: ViewModifier {
    let feedback: AnswerFeedbackKind?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let feedback {
                AnswerFeedbackBanner(kind: feedback)
                    .padding(.top, 12)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                    .id(feedback) // fresh pop-in even if the same kind repeats back-to-back
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.68), value: feedback)
    }
}

extension View {
    /// Shows a correct/try-again banner at the top of this view whenever
    /// `feedback` is non-nil. Pass `nil` to hide it.
    func answerFeedback(_ feedback: AnswerFeedbackKind?) -> some View {
        modifier(AnswerFeedbackModifier(feedback: feedback))
    }
}
