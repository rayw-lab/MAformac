import AVFoundation
import Foundation

public protocol SpeechSynthesisEngine: Sendable {
    func speak(_ text: String) -> SpeechSynthesisResult
}

public enum SpeechSynthesisStatus: String, Codable, Equatable, Sendable {
    case enqueued
    case failed
}

public enum SpeechSynthesisRoute: String, Codable, Equatable, Sendable {
    case preferredChinese = "preferred_chinese"
    case fallbackChinese = "fallback_chinese"
    case systemDefault = "system_default"
    case testDouble = "test_double"
    case unavailable
}

public struct SpeechSynthesisResult: Codable, Equatable, Sendable {
    public var status: SpeechSynthesisStatus
    public var route: SpeechSynthesisRoute
    public var reason: String?

    public init(status: SpeechSynthesisStatus, route: SpeechSynthesisRoute, reason: String? = nil) {
        self.status = status
        self.route = route
        self.reason = reason
    }

    public static func enqueued(route: SpeechSynthesisRoute) -> SpeechSynthesisResult {
        SpeechSynthesisResult(status: .enqueued, route: route)
    }

    public static func failed(route: SpeechSynthesisRoute = .unavailable, reason: String) -> SpeechSynthesisResult {
        SpeechSynthesisResult(status: .failed, route: route, reason: reason)
    }

    public var didEnqueue: Bool {
        status == .enqueued
    }
}

public final class AVSpeechSynthesisEngine: NSObject, SpeechSynthesisEngine, @unchecked Sendable {
    private let synthesizer = AVSpeechSynthesizer()
    private let voiceProvider: @Sendable () -> AVSpeechSynthesisVoice?

    public init(voiceProvider: @escaping @Sendable () -> AVSpeechSynthesisVoice? = AVSpeechSynthesisEngine.bestChineseVoice) {
        self.voiceProvider = voiceProvider
        super.init()
    }

    public static func bestChineseVoice() -> AVSpeechSynthesisVoice? {
        if let preferred = AVSpeechSynthesisVoice(language: "zh-CN") {
            return preferred
        }
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("zh") }
            .sorted { lhs, rhs in
                if lhs.quality != rhs.quality {
                    return lhs.quality.rawValue > rhs.quality.rawValue
                }
                return lhs.language < rhs.language
            }
            .first
    }

    public func speak(_ text: String) -> SpeechSynthesisResult {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failed(reason: "empty_tts_text")
        }
        let utterance = AVSpeechUtterance(string: text)
        let voice = voiceProvider()
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
        guard let voice else {
            return .enqueued(route: .systemDefault)
        }
        return .enqueued(route: voice.language == "zh-CN" ? .preferredChinese : .fallbackChinese)
    }
}

public final class RecordingSpeechSynthesisEngine: SpeechSynthesisEngine, @unchecked Sendable {
    public private(set) var spokenTexts: [String] = []
    public var nextResult: SpeechSynthesisResult

    public init(nextResult: SpeechSynthesisResult = .enqueued(route: .testDouble)) {
        self.nextResult = nextResult
    }

    public func speak(_ text: String) -> SpeechSynthesisResult {
        spokenTexts.append(text)
        return nextResult
    }
}
