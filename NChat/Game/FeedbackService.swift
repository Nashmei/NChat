import UIKit
import AVFoundation

@MainActor
final class FeedbackService {
    static let shared = FeedbackService()
    private var player: AVAudioPlayer?

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func systemTone(_ id: SystemSoundID = 1104) {
        AudioServicesPlaySystemSound(id)
    }
}
