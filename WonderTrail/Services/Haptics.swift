import UIKit

/// Thin wrapper over UIKit's feedback generators, adapted from Duck-n-Roll's
/// Haptics.swift. Generators are kept warm with prepare() for low-latency
/// taps. No-ops on the Simulator (no Taptic Engine) but works on device.
///
/// Deliberate difference from Duck-n-Roll: there is no `.error`-style
/// notification anywhere in this app. Wrong answers only ever get a soft
/// impact (`tryAgain()`), never a sharp error buzz — mistakes are never
/// punished, at the haptic layer or anywhere else.
final class Haptics {
    static let shared = Haptics()

    private let selection = UISelectionFeedbackGenerator()
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let notify = UINotificationFeedbackGenerator()

    /// Master switch, wired to the Settings screen's "Gentle taps" toggle.
    var enabled: Bool {
        didSet { UserDefaults.standard.set(enabled, forKey: "wt.hapticsEnabled") }
    }

    private init() {
        enabled = UserDefaults.standard.object(forKey: "wt.hapticsEnabled") as? Bool ?? true
    }

    func prepareAll() {
        guard enabled else { return }
        [soft, light].forEach { $0.prepare() }
        selection.prepare()
        notify.prepare()
    }

    /// Any button/tile tap.
    func tap() {
        guard enabled else { return }
        selection.selectionChanged()
        selection.prepare()
    }

    /// A correct answer within an activity.
    func correct() {
        guard enabled else { return }
        notify.notificationOccurred(.success)
        notify.prepare()
    }

    /// A wrong answer — gentle, never punishing.
    func tryAgain() {
        guard enabled else { return }
        soft.impactOccurred(intensity: 0.4)
        soft.prepare()
    }

    /// A skill node unlocks the next one — the bigger moment.
    func masteryUnlock() {
        guard enabled else { return }
        light.impactOccurred(intensity: 0.8)
        notify.notificationOccurred(.success)
        notify.prepare()
    }

    /// End of a full quest.
    func questComplete() {
        guard enabled else { return }
        notify.notificationOccurred(.success)
        notify.prepare()
    }
}
