import XCTest
@testable import MAformacCore

/// G4：RuntimeTurnLease identity / isCurrent、cancelPendingSpeech、sequence overflow、
/// 刀2 Runner Door-1/Door-2 重入双门。完整 6 RED 场景留给刀4；本文件须独立 GREEN。
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

    /// Controllable async gate — no `Task.sleep`. Decoder parks until `release()`.
    private final class DecoderGate: @unchecked Sendable {
        private let lock = NSLock()
        private var continuation: CheckedContinuation<Void, Never>?
        private var parked = false

        func park() async {
            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                lock.lock()
                continuation = cont
                parked = true
                lock.unlock()
            }
        }

        var isParked: Bool {
            lock.lock(); defer { lock.unlock() }
            return parked && continuation != nil
        }

        func release() {
            lock.lock()
            let cont = continuation
            continuation = nil
            parked = false
            lock.unlock()
            cont?.resume()
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

    // MARK: - G4 刀2 Door-1 / Door-2

    @MainActor
    func testKnife2_staleAfterDecoder_door1_zeroMutation() async throws {
        let store = DemoVehicleStateStore()
        let initialRevision = store.currentRevision
        let initialPower = store.cell(for: "ac.power")?.actualValue
        let speech = RecordingSpeechSynthesisEngine()
        let trace = InMemoryTraceLogger()
        let flag = CurrentFlag(true)
        let lease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 1,
            turnID: UUID(),
            isCurrent: { flag.isCurrent }
        )
        let gate = DecoderGate()
        let frame = try FastPathIntentEngine().decode("打开空调")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: trace,
            speech: speech,
            planDecoder: { _ in
                await gate.park()
                return try RuntimePlan(
                    traceID: frame.traceID,
                    frames: [.tool(frame)],
                    executionPolicy: .atomic
                )
            }
        )

        async let payloadTask = runner.run(text: "打开空调", lease: lease)

        // Spin-yield until decoder is parked (no sleep).
        var spins = 0
        while !gate.isParked {
            spins += 1
            XCTAssertLessThan(spins, 10_000, "decoder never parked")
            await Task.yield()
        }

        // Preempt after decode suspension: old turn loses lease before Door-1.
        flag.set(false)
        gate.release()

        let payload = try await payloadTask
        XCTAssertEqual(payload.outcome.result, .cancelled)
        XCTAssertEqual(payload.outcome.reason, "cancelled")
        XCTAssertEqual(payload.mutationCount, 0)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertTrue(speech.spokenTexts.isEmpty)
        XCTAssertEqual(store.currentRevision, initialRevision)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, initialPower)
        XCTAssertTrue(
            trace.entries.contains {
                $0.stage == .guard
                    && $0.message == "turn_lease_cancelled"
                    && $0.attributes.guardReason == "turn_lease_stale:door1_after_decoder"
            }
        )
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
    }

    @MainActor
    func testKnife2_staleBeforeExecutePlan_door2_zeroMutation() throws {
        let store = DemoVehicleStateStore()
        let initialRevision = store.currentRevision
        let initialPower = store.cell(for: "ac.power")?.actualValue
        let speech = RecordingSpeechSynthesisEngine()
        let trace = InMemoryTraceLogger()
        let flag = CurrentFlag(false) // already stale → Door-2 rejects
        let lease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 2,
            turnID: UUID(),
            isCurrent: { flag.isCurrent }
        )
        let frame = try FastPathIntentEngine().decode("打开空调")
        let plan = try RuntimePlan(
            traceID: frame.traceID,
            frames: [.tool(frame)],
            executionPolicy: .atomic
        )
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: trace,
            speech: speech
        )

        let payload = try runner.run(
            predecodedPlan: plan,
            customerText: "打开空调",
            lease: lease
        )

        XCTAssertEqual(payload.outcome.result, .cancelled)
        XCTAssertEqual(payload.mutationCount, 0)
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertTrue(speech.spokenTexts.isEmpty)
        XCTAssertEqual(store.currentRevision, initialRevision)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, initialPower)
        XCTAssertTrue(
            trace.entries.contains {
                $0.stage == .guard
                    && $0.message == "turn_lease_cancelled"
                    && $0.attributes.guardReason == "turn_lease_stale:door2_before_execute"
            }
        )
        XCTAssertFalse(trace.entries.contains { $0.stage == .execute || $0.stage == .readback })
    }

    @MainActor
    func testKnife2_currentLease_stillMutatesNormally() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let lease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 3,
            turnID: UUID(),
            isCurrent: { true }
        )
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )

        let payload = try await runner.run(text: "打开空调", lease: lease)

        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(payload.readbacks.first?.key, "ac.power")
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
    }
}
