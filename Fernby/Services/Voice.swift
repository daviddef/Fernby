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
final class Voice: NSObject {
    static let shared = Voice()

    private let synthesizer = AVSpeechSynthesizer()
    var enabled: Bool {
        didSet { UserDefaults.standard.set(enabled, forKey: "wt.voiceEnabled") }
    }

    /// Only used by `speakWithWordHighlighting` — fired from the delegate
    /// callbacks below as an utterance progresses/ends, so StorybookView can
    /// highlight the word currently being spoken in sync with narration.
    private var wordRangeHandler: ((NSRange) -> Void)?
    private var finishHandler: (() -> Void)?

    private override init() {
        enabled = UserDefaults.standard.object(forKey: "wt.voiceEnabled") as? Bool ?? true
        super.init()
        synthesizer.delegate = self

        // Real bug, reported from a real device: with no audio session
        // category configured, iOS defaults to `.soloAmbient`, which gets
        // completely silenced by the phone's physical Ring/Silent switch —
        // every spoken instruction in the app would be inaudible whenever
        // that switch is flipped, with no in-app indication anything was
        // wrong. `.playback` is what audio/video apps use specifically so
        // content-critical sound isn't at the mercy of a hardware switch a
        // parent might have flipped for an unrelated reason — appropriate
        // here since spoken instructions aren't decorative, pre-readers
        // depend on them to use the app at all.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Falls back to default session behavior — better to keep
            // running than crash over an audio session configuration issue.
        }
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

    /// Speaks `text` and reports, in real time, the character range of the
    /// word currently being spoken — the mechanism behind Storybook's
    /// karaoke-style word highlighting. `onWordRange` fires once per word as
    /// AVSpeechSynthesizer's delegate reports it; `onFinish` fires exactly
    /// once, whether the utterance completed or was cancelled. If voice is
    /// muted, calls `onFinish` immediately: story text is always fully
    /// visible on its own — narration sits on top of reading, it's never a
    /// requirement for it.
    func speakWithWordHighlighting(_ text: String, onWordRange: @escaping (NSRange) -> Void, onFinish: @escaping () -> Void) {
        guard enabled else {
            onFinish()
            return
        }
        synthesizer.stopSpeaking(at: .immediate)
        wordRangeHandler = onWordRange
        finishHandler = onFinish
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.25
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        wordRangeHandler = nil
        finishHandler = nil
    }
}

extension Voice: AVSpeechSynthesizerDelegate {
    // AVSpeechSynthesizerDelegate callbacks aren't guaranteed to arrive on
    // the main thread, but Voice's own state (wordRangeHandler,
    // finishHandler) is @MainActor-isolated — nonisolated + an explicit hop
    // is the standard pattern for a MainActor class adopting a plain
    // (non-actor-isolated) delegate protocol.
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.wordRangeHandler?(characterRange)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.finishHandler?()
            self.finishHandler = nil
            self.wordRangeHandler = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.finishHandler?()
            self.finishHandler = nil
            self.wordRangeHandler = nil
        }
    }
}
