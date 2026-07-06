import AVFoundation

/// System text-to-speech, adapted from Vexed's KidVoice.swift (verified rate
/// and pitch tuning carried over as-is). Every instruction, button, and piece
/// of feedback in this app is spoken through here — pre-readers and early
/// readers can't be expected to read UI copy, only hear it.
///
/// MVP uses system TTS everywhere rather than recorded audio: it's free and
/// instant for every current and future content-bank string, where recorded
/// VO would need re-recording every time a word or fact bank grows. The
/// known tradeoff is isolated-phoneme pronunciation quality (see
/// PhonicsBank.sound) — worth a manual QA pass before this is used for real
/// teaching, since a mispronounced phoneme actively teaches the wrong sound.
@MainActor
final class Voice {
    static let shared = Voice()

    private let synthesizer = AVSpeechSynthesizer()
    var enabled: Bool {
        didSet { UserDefaults.standard.set(enabled, forKey: "wt.voiceEnabled") }
    }

    private init() {
        enabled = UserDefaults.standard.object(forKey: "wt.voiceEnabled") as? Bool ?? true
    }

    func speak(_ text: String, interrupt: Bool = true) {
        guard enabled else { return }
        if interrupt { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.42
        utterance.pitchMultiplier = 1.25
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
