import XCTest
@testable import MAformacCore

/// G4 刀1：RuntimeTurnLease identity / isCurrent、cancelPendingSpeech、sequence overflow 防护。
/// 完整 6 RED 场景留给刀4；本文件须独立 GREEN。
final class TurnLeaseCancellationTests: XCTestCase {
    private final class CurrentFlag: @unchecked Sendable {
        private let lock = NSLock()
        private var value: Bool

        init(_ value: Bool) {
            self.value = value
        }

        var isCurrent: Bool {
            lock.lock(); defer { lock.unlock() }
            return value
        }

        func set(_ value: Bool) {
            lock.lock(); defer { lock.unlock() }
            self.value = value
        }
    }

    func testLeaseIdentityHoldsSessionSequenceAndTurnID() {
        let sessionID = UUID()
        let turnID = UUID()
        let sequence: UInt64 = 42
        let lease = RuntimeTurnLease(
            sessionID: sessionID,
            sequence: sequence,
            turnID: turnID,
            isCurrent: { true }
        )

        XCTAssertEqual(lease.sessionID, sessionID)
        XCTAssertEqual(lease.sequence, sequence)
        XCTAssertEqual(lease.turnID, turnID)
    }

    @MainActor
    func testLeaseIsCurrentReflectsProviderCapability() {
        let flag = CurrentFlag(true)
        let lease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 1,
            turnID: UUID(),
            isCurrent: { flag.isCurrent }
        )

        XCTAssertTrue(lease.isCurrent)
        flag.set(false)
        XCTAssertFalse(lease.isCurrent)
        flag.set(true)
        XCTAssertTrue(lease.isCurrent)
    }

    func testCancelPendingSpeechOnRecordingEngineIncrementsCountWithoutBreakingSpeak() {
        let speech = RecordingSpeechSynthesisEngine(nextResult: .enqueued(route: .testDouble))

        let spoken = speech.speak("空调已打开")
        XCTAssertTrue(spoken.didEnqueue)
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
        XCTAssertEqual(speech.cancelPendingSpeechCallCount, 0)

        speech.cancelPendingSpeech()
        speech.cancelPendingSpeech()

        XCTAssertEqual(speech.cancelPendingSpeechCallCount, 2)
        // speak contract unchanged after cancel.
        let again = speech.speak("再试一次")
        XCTAssertTrue(again.didEnqueue)
        XCTAssertEqual(speech.spokenTexts, ["空调已打开", "再试一次"])
    }

    func testAVSpeechEngineCancelPendingSpeechIsInvocable() {
        let engine = AVSpeechSynthesisEngine(voiceProvider: { nil })
        // Must be a no-op-safe synchronous cutover even with nothing enqueued.
        engine.cancelPendingSpeech()
    }

    func testSequenceOverflowFailClosedWithTypedSessionError() throws {
        let session = FrontstageVoiceSession(
            sessionID: "overflow-session",
            startingSequence: Int.max
        )

        XCTAssertThrowsError(
            try session.issueIngressRequest(.init(source: .text, rawText: "打开空调"))
        ) { error in
            XCTAssertEqual(error as? FrontstageVoiceSessionError, .sequenceExhausted)
        }

        XCTAssertThrowsError(
            try session.submitContainment(utterance: "打开空调")
        ) { error in
            XCTAssertEqual(error as? FrontstageVoiceSessionError, .sequenceExhausted)
        }
    }

    func testSequenceCheckedIncrementAdvancesUntilExhausted() throws {
        let session = FrontstageVoiceSession(
            sessionID: "near-max",
            startingSequence: Int.max - 1
        )

        let request = try session.issueIngressRequest(.init(source: .text, rawText: "ok"))
        XCTAssertEqual(request.sequence, Int.max)

        XCTAssertThrowsError(
            try session.issueIngressRequest(.init(source: .text, rawText: "next"))
        ) { error in
            XCTAssertEqual(error as? FrontstageVoiceSessionError, .sequenceExhausted)
        }
    }

    func testCustomerIngressMapsSequenceExhaustionToUnavailableWithoutMutation() {
        let ingress = FrontstageCustomerIngress(
            session: FrontstageVoiceSession(sessionID: "session-1", startingSequence: Int.max)
        )

        let result = ingress.submit(.init(source: .text, rawText: "打开空调"))
        guard case let .rejected(rejected) = result else {
            return XCTFail("expected rejection on sequence exhaustion")
        }
        XCTAssertEqual(rejected.reason, .unavailable)
        XCTAssertFalse(rejected.stateMutation)
        XCTAssertTrue(rejected.readbacks.isEmpty)
    }
}
