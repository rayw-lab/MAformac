import AVFoundation
import Foundation

public protocol SpeechSynthesisEngine: Sendable {
    func speak(_ text: String)
}

public final class AVSpeechSynthesisEngine: NSObject, SpeechSynthesisEngine, @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer()

    public override init() {
        super.init()
    }

    public func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}

public final class RecordingSpeechSynthesisEngine: SpeechSynthesisEngine, @unchecked Sendable {
    public private(set) var spokenTexts: [String] = []

    public init() {}

    public func speak(_ text: String) {
        spokenTexts.append(text)
    }
}

