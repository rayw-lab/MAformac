import AVFoundation
import XCTest
@testable import MAformacCore

final class SpeechSynthesisEngineTests: XCTestCase {
    private final class CallCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var value = 0
        var count: Int {
            lock.lock(); defer { lock.unlock() }
            return value
        }
        func increment() {
            lock.lock(); defer { lock.unlock() }
            value += 1
        }
    }

    func testAVSpeechSynthesisEngineRejectsBlankTextBeforeVoiceLookup() {
        let engine = AVSpeechSynthesisEngine(voiceProvider: {
            XCTFail("blank text must fail before voice lookup")
            return nil
        })

        let result = engine.speak("  \n\t  ")

        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.route, .unavailable)
        XCTAssertEqual(result.reason, "empty_tts_text")
        XCTAssertFalse(result.didEnqueue)
        XCTAssertNotEqual(result.route, .systemDefault)
    }

    /// S5 / N-S5-c: nil Chinese voice fails closed — never silent systemDefault success.
    func testAVSpeechSynthesisEngineNilChineseVoiceFailsWithoutEnqueueOrSystemDefault() {
        let providerCalls = CallCounter()
        let engine = AVSpeechSynthesisEngine(voiceProvider: {
            providerCalls.increment()
            return nil
        })

        let result = engine.speak("打开空调")

        XCTAssertEqual(providerCalls.count, 1)
        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.reason, "chinese_voice_unavailable")
        XCTAssertEqual(result.route, .unavailable)
        XCTAssertFalse(result.didEnqueue)
        XCTAssertNotEqual(result.route, .systemDefault)
        XCTAssertNotEqual(result.status, .enqueued)
    }

    /// S5 positive path when OS can provide a Chinese (or any injectable) voice.
    func testAVSpeechSynthesisEngineInjectedVoiceEnqueuesPreferredOrFallbackChinese() {
        guard let voice = AVSpeechSynthesisVoice(language: "zh-CN")
            ?? AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language.hasPrefix("zh") })
        else {
            // No zh voice on this host: hard-gate failure path is covered above.
            return
        }

        let engine = AVSpeechSynthesisEngine(voiceProvider: { voice })
        let result = engine.speak("空调已打开")

        XCTAssertTrue(result.didEnqueue)
        XCTAssertEqual(result.status, .enqueued)
        XCTAssertNotEqual(result.route, .systemDefault)
        XCTAssertTrue(result.route == .preferredChinese || result.route == .fallbackChinese)
    }

    func testRecordingSpeechSynthesisEngineSurfacesConfiguredFailureAndEnqueue() {
        let failed = RecordingSpeechSynthesisEngine(
            nextResult: .failed(reason: "chinese_voice_unavailable")
        )
        let failResult = failed.speak("x")
        XCTAssertEqual(failed.spokenTexts, ["x"])
        XCTAssertFalse(failResult.didEnqueue)
        XCTAssertEqual(failResult.reason, "chinese_voice_unavailable")

        let ok = RecordingSpeechSynthesisEngine(
            nextResult: .enqueued(route: .testDouble)
        )
        let okResult = ok.speak("y")
        XCTAssertTrue(okResult.didEnqueue)
        XCTAssertEqual(okResult.route, .testDouble)
    }
}
