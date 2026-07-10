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

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
