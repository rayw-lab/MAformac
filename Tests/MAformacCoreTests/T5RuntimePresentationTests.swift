import XCTest
@testable import MAformacCore

final class T5RuntimePresentationTests: XCTestCase {
    func testSixRuntimeErrorsMapToVisualStatesAndReceiptRows() {
        let expectations: [(T5RuntimePresentationFault, DemoVisualState, Bool, T5ErrorScope, String)] = [
            (.timeout, .unknown, true, .globalRetryableCrash, "crash_retryable_timeout"),
            (.emptyResponse, .unknown, true, .globalRetryableCrash, "crash_retryable_empty"),
            (.malformedPayload, .unknown, true, .globalRetryableCrash, "crash_retryable_malformed"),
            (.unknownTool, .blocked_hard, false, .unsupportedLocked, "unsupported_unknown_tool"),
            (.safetyRefusal(cardKey: "door.tailgate"), .unsafe, false, .relatedCardOnly("door.tailgate"), "safety_related_card_only"),
            (.ttsFailure, .blocked_with_alternative, false, .ttsDegraded, "tts_degraded_non_crash")
        ]

        let rows = expectations.map { fault, visualState, retryable, scope, receiptKind in
            let row = T5RuntimeErrorVisualMapper.map(fault)
            XCTAssertEqual(row.visualState, visualState)
            XCTAssertEqual(row.isRetryable, retryable)
            XCTAssertEqual(row.scope, scope)
            XCTAssertEqual(row.receiptKind, receiptKind)
            return row
        }

        XCTAssertEqual(Set(rows.map(\.fault)).count, T5RuntimePresentationFault.allReceiptCases.count)
    }

    func testRuntimeEventWinsForceStateAndForceStateCarriesDemoForceMarker() {
        let orchestrator = T5PresentationOrchestrator()
        let resolver: any T5PresentationResolving = orchestrator
        let force = T5PresentationEvent.forceState(.unsafe)
        let runtime = T5PresentationEvent.runtime(
            snapshot: StagePresentationSnapshot(
                storeCells: [DemoVehicleStateCell(key: "ac.power", actualValue: "on", visualState: .satisfied)],
                activeCells: [.ac: "ac.power"],
                dialogText: "已打开空调"
            ),
            readbackID: "rb-runtime"
        )

        XCTAssertEqual(orchestrator.resolve(current: nil, incoming: orchestrator.firstFrame()).source, .idlePanorama)
        XCTAssertEqual(orchestrator.resolve(current: nil, incoming: force).source, .demoForce)
        XCTAssertEqual(orchestrator.resolve(current: force, incoming: runtime).source, .runtime)
        XCTAssertEqual(resolver.resolvePresentation(current: runtime, incoming: force).source, .runtime)
        XCTAssertEqual(force.sourceMarker, "DEMO_FORCE")
    }

    func testCardSchedulerMergesToLatestReadbackAndStaggersNonCriticalCards() {
        let scheduler = T5CardChangeScheduler()
        let scheduled = scheduler.schedule([
            T5CardChange(cardID: "ac", state: .changing, readbackID: "rb-old", revision: 1, readbackEpoch: 10),
            T5CardChange(cardID: "seat", state: .changing, readbackID: "rb-new", revision: 2, readbackEpoch: 20),
            T5CardChange(cardID: "screen", state: .satisfied, readbackID: "rb-new", revision: 2, readbackEpoch: 20)
        ])

        XCTAssertEqual(scheduled.map(\.readbackID), ["rb-new", "rb-new", "rb-new"])
        XCTAssertEqual(scheduled.map(\.delayMilliseconds), [120, 170, 220])
    }

    func testCardSchedulerBreaksEqualRevisionTiesByReadbackEpochThenInputOrder() {
        let scheduler = T5CardChangeScheduler()
        let scheduled = scheduler.schedule([
            T5CardChange(cardID: "ac", state: .changing, readbackID: "rb-first", revision: 7, readbackEpoch: 100),
            T5CardChange(cardID: "seat", state: .changing, readbackID: "rb-latest", revision: 7, readbackEpoch: 101),
            T5CardChange(cardID: "screen", state: .satisfied, readbackID: "rb-tie-last", revision: 7, readbackEpoch: 101)
        ])

        XCTAssertEqual(scheduled.map(\.readbackID), ["rb-tie-last", "rb-tie-last", "rb-tie-last"])
        XCTAssertEqual(scheduled.map(\.delayMilliseconds), [120, 170, 220])
    }

    func testCardSchedulerAppliesUnsafeAndCrashImmediately() {
        let scheduler = T5CardChangeScheduler()
        let scheduled = scheduler.schedule([
            T5CardChange(cardID: "door", state: .unsafe, readbackID: "rb-safety", revision: 3),
            T5CardChange(cardID: "runtime", state: .unknown, readbackID: "rb-crash", revision: 4, isCrash: true),
            T5CardChange(cardID: "ac", state: .changing, readbackID: "rb-crash", revision: 4)
        ])

        XCTAssertEqual(scheduled[0].delayMilliseconds, 0)
        XCTAssertEqual(scheduled[1].delayMilliseconds, 0)
        XCTAssertEqual(scheduled[2].delayMilliseconds, 120)
    }

    func testReadbackSpeechCoordinatorCancelsOldTTSAndUsesSharedTextID() {
        let engine = T5RecordingCancellableSpeechEngine()
        let coordinator = T5ReadbackSpeechCoordinator(engine: engine)

        _ = coordinator.handle(T5ReadbackText(id: "rb-1", text: "第一条"))
        let update = coordinator.handle(T5ReadbackText(id: "rb-2", text: "第二条"))

        XCTAssertEqual(engine.cancelledIDs, ["rb-1"])
        XCTAssertEqual(engine.spoken, [T5ReadbackText(id: "rb-1", text: "第一条"), T5ReadbackText(id: "rb-2", text: "第二条")])
        XCTAssertEqual(coordinator.activeTextID, "rb-2")
        XCTAssertEqual(update.cancelledTextID, "rb-1")
        XCTAssertEqual(update.pendingBadge, T5ReadbackPendingBadge(readbackID: "rb-2", isPending: true, receiptKind: "tts_readback_pending"))
        XCTAssertEqual(coordinator.pendingBadge?.readbackID, "rb-2")
        XCTAssertTrue(coordinator.markSpeechSynchronized(textID: "rb-2"))
        XCTAssertNil(coordinator.pendingBadge)
    }

    func testTTSPreflightRecordsFallbackAndMutedWithoutFailingForPremiumVoice() {
        let preflight = T5TTSPreflight.check(
            synthesizerAvailable: true,
            preferredVoiceAvailable: false,
            fallbackVoiceAvailable: true,
            outputMuted: true,
            premiumVoiceAvailable: false
        )

        XCTAssertEqual(preflight.status, .passWithWarnings)
        XCTAssertEqual(preflight.voiceRoute, .fallback)
        XCTAssertTrue(preflight.warnings.contains(.premiumVoiceMissing))
        XCTAssertTrue(preflight.warnings.contains(.outputMuted))
    }
}
