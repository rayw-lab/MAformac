import XCTest
@testable import MAformacCore

final class SpeechSynthesisEngineTests: XCTestCase {
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
    }
}
