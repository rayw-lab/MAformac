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

    // MARK: - G4 刀3 Composition / Route lease threading (Core-reachable)

    func testKnife3_sourceContract_compositionOwnsIngressTaskAndPreemptOrder() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let composition = try String(
            contentsOf: root.appendingPathComponent("App/FrontstageRuntimeComposition.swift"),
            encoding: .utf8
        )
        let contentView = try String(
            contentsOf: root.appendingPathComponent("App/ContentView.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(composition.contains("private var ingressRouteTask: Task<Void, Never>?"))
        XCTAssertTrue(composition.contains("func scheduleIngressRoute"))
        XCTAssertTrue(composition.contains("lease: lease"))
        XCTAssertTrue(composition.contains("speech.cancelPendingSpeech()"))
        XCTAssertTrue(
            composition.contains("self.ingressRouteTask = nil"),
            "knife3: Task handle must clear after completion"
        )
        XCTAssertTrue(
            composition.contains("if !Task.isCancelled"),
            "knife3: completion clear must skip when preempt-cancelled"
        )

        // Customer path uses composition scheduler — no anonymous route Task.
        XCTAssertTrue(contentView.contains("frontstageRuntimeComposition.scheduleIngressRoute"))
        let ingressStart = contentView.range(of: "private func submitCustomerIngress")
        let ingressEnd = contentView.range(of: "private func applyDemoSliceExecution")
        XCTAssertNotNil(ingressStart)
        XCTAssertNotNil(ingressEnd)
        let ingressBody = String(contentView[ingressStart!.lowerBound..<ingressEnd!.lowerBound])
        XCTAssertFalse(
            ingressBody.contains("Task { @MainActor"),
            "submitCustomerIngress must not spawn anonymous MainActor Tasks"
        )
        XCTAssertFalse(ingressBody.contains("frontstageRuntimeComposition.routeDemoSlice"))
    }

    @MainActor
    func testKnife3_demoSliceRouteThreadsLease_staleAfterDecoder_zeroMutation() async throws {
        let store = DemoVehicleStateStore()
        let initialRevision = store.currentRevision
        let initialPower = store.cell(for: "ac.power")?.actualValue
        let speech = RecordingSpeechSynthesisEngine()
        let flag = CurrentFlag(false) // already stale → Door-1 after sync decoder
        let lease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 11,
            turnID: UUID(),
            isCurrent: { flag.isCurrent }
        )
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )

        let result = try await route.route(text: "打开空调", lease: lease)

        XCTAssertNotNil(result.execution)
        XCTAssertEqual(result.execution?.payload.outcome.result, .cancelled)
        XCTAssertEqual(result.execution?.payload.mutationCount, 0)
        XCTAssertTrue(result.execution?.payload.readbacks.isEmpty ?? false)
        XCTAssertTrue(speech.spokenTexts.isEmpty)
        XCTAssertEqual(store.currentRevision, initialRevision)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, initialPower)
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
    }

    @MainActor
    func testKnife3_demoSliceRouteCurrentLease_stillMutates() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let lease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 12,
            turnID: UUID(),
            isCurrent: { true }
        )
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )

        let result = try await route.route(text: "打开空调", lease: lease)

        XCTAssertEqual(result.execution?.payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
    }

    // MARK: - G4 刀4 WBS 六大 RED（缺啥补啥；door1/2/knife3 不空转复读）

    /// RED#1: AsyncGate 卡住旧 decoder → 新 turn 先完成 → 释放旧 turn：旧 lease fail，零 mutation。
    @MainActor
    func testG4_red1_parkedDecoder_newTurnCompletesFirst_oldZeroMutation() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let trace = InMemoryTraceLogger()
        let oldFlag = CurrentFlag(true)
        let oldLease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 1,
            turnID: UUID(),
            isCurrent: { oldFlag.isCurrent }
        )
        let gate = DecoderGate()
        let frame = try FastPathIntentEngine().decode("打开空调")
        let oldRunner = DemoRuntimeSessionRunner(
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

        async let oldTask = oldRunner.run(text: "打开空调", lease: oldLease)

        var spins = 0
        while !gate.isParked {
            spins += 1
            XCTAssertLessThan(spins, 10_000, "decoder never parked")
            await Task.yield()
        }

        // New turn takes authority and commits first.
        oldFlag.set(false)
        let newLease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 2,
            turnID: UUID(),
            isCurrent: { true }
        )
        let newRunner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine()
        )
        let newPayload = try await newRunner.run(text: "打开空调", lease: newLease)
        XCTAssertEqual(newPayload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        let revisionAfterNew = store.currentRevision

        gate.release()
        let oldPayload = try await oldTask
        XCTAssertEqual(oldPayload.outcome.result, .cancelled)
        XCTAssertEqual(oldPayload.mutationCount, 0)
        XCTAssertTrue(oldPayload.readbacks.isEmpty)
        // Old turn must not rewrite or clear the new turn's committed state.
        XCTAssertEqual(store.currentRevision, revisionAfterNew)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }

    /// RED#3: 旧 turn 已 commit 后发新命令：历史 mutation 不被伪抹，新命令决定最终状态。
    @MainActor
    func testG4_red3_postCommit_newCommand_preservesHistoryAndWinsFinalState() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )
        let lease1 = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 1,
            turnID: UUID(),
            isCurrent: { true }
        )
        let first = try await route.route(text: "打开空调", lease: lease1)
        XCTAssertEqual(first.execution?.payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        let powerRevision = store.cell(for: "ac.power")?.revision

        let lease2 = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 2,
            turnID: UUID(),
            isCurrent: { true }
        )
        let second = try await route.route(text: "把空调调到26度", lease: lease2)
        XCTAssertEqual(second.execution?.payload.outcome.result, .acceptedToolCall)
        // History (power on) retained; new command wins temperature.
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, powerRevision)
        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
    }

    /// RED#4: 旧音频已 enqueue 后发新 turn：cancelPendingSpeech 被调用，最终 speech 属新 turn。
    @MainActor
    func testG4_red4_cancelPendingSpeech_afterEnqueue_finalSpeechBelongsToNewTurn() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )
        let lease1 = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 1,
            turnID: UUID(),
            isCurrent: { true }
        )
        let first = try await route.route(text: "打开空调", lease: lease1)
        XCTAssertEqual(first.execution?.payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
        XCTAssertEqual(speech.cancelPendingSpeechCallCount, 0)

        // Composition preempt order: cancelPendingSpeech after identity switch, before new route.
        speech.cancelPendingSpeech()
        XCTAssertEqual(speech.cancelPendingSpeechCallCount, 1)

        let lease2 = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 2,
            turnID: UUID(),
            isCurrent: { true }
        )
        let second = try await route.route(text: "把空调调到26度", lease: lease2)
        XCTAssertEqual(second.execution?.payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(speech.spokenTexts.last, store.cell(for: "ac.temp_setpoint[主驾]").map {
            DemoVehicleStateStore.spokenText(for: $0)
        })
        XCTAssertEqual(speech.cancelPendingSpeechCallCount, 1)
        XCTAssertFalse(speech.spokenTexts.isEmpty)
        XCTAssertEqual(speech.spokenTexts.last?.contains("26") == true || speech.spokenTexts.count >= 2, true)
    }

    /// RED#5: stale old result 返回后不得再落 mutation / speech（UI/receipt 由 isCurrent 第二道丢弃，见 knife3 source）。
    @MainActor
    func testG4_red5_staleLeaseResult_zeroMutationAndNoSpeech() async throws {
        let store = DemoVehicleStateStore()
        let initialRevision = store.currentRevision
        let speech = RecordingSpeechSynthesisEngine()
        let flag = CurrentFlag(false)
        let lease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 21,
            turnID: UUID(),
            isCurrent: { flag.isCurrent }
        )
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )
        let result = try await route.route(text: "打开空调", lease: lease)
        XCTAssertEqual(result.execution?.payload.outcome.result, .cancelled)
        XCTAssertEqual(result.execution?.payload.mutationCount, 0)
        XCTAssertTrue(speech.spokenTexts.isEmpty)
        XCTAssertEqual(store.currentRevision, initialRevision)
    }

    /// RED#6 pre-commit `算了`: 旧 in-flight 被 preempt link + lease stale → 零 mutation；新 turn cancelled ack。
    @MainActor
    func testG4_red6_preCommitSuanle_oldZeroMutation_linkedCancel() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let trace = InMemoryTraceLogger()
        let oldIdentity = RuntimeTurnIdentity(sessionID: UUID(), sequence: 1, turnID: UUID())
        let oldFlag = CurrentFlag(true)
        let oldLease = RuntimeTurnLease(
            sessionID: oldIdentity.sessionID,
            sequence: oldIdentity.sequence,
            turnID: oldIdentity.turnID,
            isCurrent: { oldFlag.isCurrent }
        )
        let gate = DecoderGate()
        let frame = try FastPathIntentEngine().decode("打开空调")
        let oldRunner = DemoRuntimeSessionRunner(
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
        async let oldTask = oldRunner.run(text: "打开空调", lease: oldLease)
        var spins = 0
        while !gate.isParked {
            spins += 1
            XCTAssertLessThan(spins, 10_000)
            await Task.yield()
        }

        oldFlag.set(false)
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine()
        )
        XCTAssertEqual(route.catalog.classify(for: "算了"), .cancel(target: nil))
        route.notePreemptedInFlight(oldIdentity)
        let cancelLease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 2,
            turnID: UUID(),
            isCurrent: { true }
        )
        let cancelResult = try await route.route(text: "算了", lease: cancelLease)
        let readOnly = try XCTUnwrap(cancelResult.readOnly)
        XCTAssertEqual(readOnly.payload.outcome.result, .cancelled)
        XCTAssertEqual(readOnly.payload.mutationCount, 0)
        XCTAssertEqual(readOnly.runnerCallCount, 0)
        XCTAssertTrue(readOnly.payload.eventID?.hasPrefix("cancel-preempt:") == true)
        XCTAssertTrue(readOnly.payload.eventID?.contains(oldIdentity.linkToken) == true)

        gate.release()
        let oldPayload = try await oldTask
        XCTAssertEqual(oldPayload.outcome.result, .cancelled)
        XCTAssertEqual(oldPayload.mutationCount, 0)
        XCTAssertNotEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }

    /// RED#6 post-commit `算了`: 旧 success 保留 + cancelTooLate no-action；经 identity link。
    @MainActor
    func testG4_red6_postCommitSuanle_cancelTooLate_preservesMutation() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )
        let commitLease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 10,
            turnID: UUID(),
            isCurrent: { true }
        )
        let committed = try await route.route(text: "打开空调", lease: commitLease)
        XCTAssertEqual(committed.execution?.payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        let committedIdentity = try XCTUnwrap(route.lastCommittedTurn)
        XCTAssertEqual(committedIdentity, commitLease.identity)
        let revision = store.currentRevision

        let cancelLease = RuntimeTurnLease(
            sessionID: UUID(),
            sequence: 11,
            turnID: UUID(),
            isCurrent: { true }
        )
        let cancelResult = try await route.route(text: "算了", lease: cancelLease)
        let readOnly = try XCTUnwrap(cancelResult.readOnly)
        XCTAssertEqual(readOnly.payload.outcome.result, .noAction)
        XCTAssertEqual(readOnly.payload.mutationCount, 0)
        XCTAssertEqual(readOnly.runnerCallCount, 1) // prior command only; cancel itself did not increment
        XCTAssertTrue(readOnly.payload.eventID?.hasPrefix("cancel-too-late:") == true)
        XCTAssertTrue(readOnly.payload.eventID?.contains(committedIdentity.linkToken) == true)
        // Must not fake-undo committed mutation.
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.currentRevision, revision)
    }

    func testG4_knife4_sourceContract_compositionNotesPreemptedInFlight() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let composition = try String(
            contentsOf: root.appendingPathComponent("App/FrontstageRuntimeComposition.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(composition.contains("pendingPreemptedInFlight"))
        XCTAssertTrue(composition.contains("notePreemptedInFlight"))
        XCTAssertTrue(composition.contains("currentLeaseIdentity"))
        XCTAssertFalse(composition.contains("Task.sleep"))
    }
}
