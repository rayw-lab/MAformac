import XCTest
@testable import MAformacCore

final class RuntimePresentationBridgeTests: XCTestCase {
    func testBehaviorClassMapsToBridgeRuntimeResultWithoutRenamingC6Source() {
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .toolCall), .acceptedToolCall)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .clarifyMissingSlot), .clarifyMissingSlot)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .refusalNoAvailableTool), .refusalNoAvailableTool)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .refusalSafetyOrPolicy), .refusalSafetyOrPolicy)
        XCTAssertEqual(DemoRuntimeResult(behaviorClass: .alreadyStateNoop), .alreadyStateNoop)

        let outcome = DemoRuntimeOutcome(behaviorClass: .toolCall)
        XCTAssertEqual(outcome.result, .acceptedToolCall)
        XCTAssertEqual(outcome.behaviorClassSource, .toolCall)
    }

    func testMissingScopeTravelsAsReasonNotCoreScopeOriginCase() {
        XCTAssertNil(ScopeOrigin(rawValue: "missing"))

        let snapshot = PresentationSnapshot(
            traceID: "trace-1",
            runtimeOutcome: DemoRuntimeOutcome(
                result: .clarifyMissingSlot,
                missingSlot: "direction",
                scopeFailureReason: "missing_required_scope"
            ),
            cards: [],
            scopeOrigin: nil,
            scopeFailureReason: "missing_required_scope",
            proofClass: .openspecContract,
            isTerminal: true
        )

        XCTAssertNil(snapshot.scopeOrigin)
        XCTAssertEqual(snapshot.scopeFailureReason, "missing_required_scope")
        XCTAssertEqual(snapshot.runtimeOutcome.missingSlot, "direction")
    }

    func testProofClassUnknownValuesFailClosedAndDoNotGrantReadinessClaims() throws {
        for proofClass in PresentationProofClass.allCases {
            XCTAssertTrue(proofClass.displayCaps.isEmpty)
        }

        let data = Data(#""runtime_ready""#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(PresentationProofClass.self, from: data))
    }

    func testPresentationSnapshotIsCodableAndCarriesPresentationSafeTraceEnvelope() throws {
        let timestamp = Date(timeIntervalSince1970: 1_800_000_000)
        let traceEntry = TraceEntry(
            stage: .readback,
            traceID: "trace-2",
            message: "空调已打开",
            attributes: TraceAttributes(readbackResult: .verified),
            timestamp: timestamp
        )
        let readback = DemoActionReadback(
            key: "ac.power",
            actualValue: "on",
            revision: 1,
            spokenText: "空调已打开",
            scopeOrigin: .explicit
        )
        let snapshot = PresentationSnapshot(
            traceID: "trace-2",
            runtimeOutcome: DemoRuntimeOutcome(behaviorClass: .toolCall),
            cards: [
                DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied)
            ],
            dialogText: "已打开空调",
            readbacks: [readback],
            scopeOrigin: .explicit,
            voiceState: .unavailable,
            orbState: .speak,
            proofClass: .localUnit,
            traceEnvelope: try XCTUnwrap(TraceEnvelope(traceID: "trace-2", entries: [traceEntry])),
            isTerminal: true,
            timestamp: timestamp
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(PresentationSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
        XCTAssertEqual(decoded.traceEnvelope?.entries.first?.attributes.readbackResult, .verified)
    }

    func testGuardDenialProjectsToTerminalPresentationSafeRefusalSnapshot() throws {
        let snapshot = RuntimePresentationTerminalSnapshotAdapter.guardDenial(
            traceID: "trace-guard",
            reason: "risk_policy_refuse",
            cards: [
                DemoVehicleStateCell(key: "door.lock", actualValue: "locked", visualState: .unsafe)
            ],
            proofClass: .localUnit
        )

        XCTAssertTrue(snapshot.isTerminal)
        XCTAssertEqual(snapshot.traceID, "trace-guard")
        XCTAssertEqual(snapshot.runtimeOutcome.result, .refusalSafetyOrPolicy)
        XCTAssertEqual(snapshot.runtimeOutcome.reason, "risk_policy_refuse")
        XCTAssertEqual(snapshot.proofClass, .localUnit)
        XCTAssertEqual(snapshot.cards.first?.visualState, .unsafe)

        let data = try JSONEncoder().encode(snapshot)
        let encoded = String(decoding: data, as: UTF8.self)
        XCTAssertFalse(encoded.contains("rawModelOutput"))
        XCTAssertFalse(encoded.contains("trainingReceipt"))
        XCTAssertFalse(encoded.contains("runtimeStore"))
    }

    func testThrownErrorProjectsToTerminalRuntimeErrorSnapshotWithTraceIdentity() {
        let snapshot = RuntimePresentationTerminalSnapshotAdapter.thrownError(
            traceID: "trace-error",
            reason: "semantic_invalid"
        )

        XCTAssertTrue(snapshot.isTerminal)
        XCTAssertEqual(snapshot.traceID, "trace-error")
        XCTAssertEqual(snapshot.runtimeOutcome.result, .runtimeError)
        XCTAssertEqual(snapshot.runtimeOutcome.reason, "semantic_invalid")
        XCTAssertEqual(snapshot.proofClass, .localUnit)
    }

    func testPartialAcceptRefuseCarriesMixedCardsAndCompositeReadback() {
        let acceptedReadback = DemoActionReadback(
            key: "window.driver",
            actualValue: "closed",
            revision: 2,
            spokenText: "主驾车窗已关闭",
            scopeOrigin: .explicit
        )
        let snapshot = RuntimePresentationTerminalSnapshotAdapter.partialAcceptRefuse(
            traceID: "trace-partial",
            acceptedReadbacks: [acceptedReadback],
            acceptedCards: [
                DemoVehicleStateCell(key: "window.driver", actualValue: "closed", revision: 2, visualState: .satisfied)
            ],
            refusedCards: [
                DemoVehicleStateCell(key: "door.lock", actualValue: "locked", revision: 1, visualState: .unsafe)
            ],
            reason: "partial_accept_refuse"
        )

        XCTAssertTrue(snapshot.isTerminal)
        XCTAssertEqual(snapshot.traceID, "trace-partial")
        XCTAssertEqual(snapshot.runtimeOutcome.result, .refusalSafetyOrPolicy)
        XCTAssertEqual(snapshot.runtimeOutcome.reason, "partial_accept_refuse")
        XCTAssertEqual(snapshot.readbacks, [acceptedReadback])
        XCTAssertEqual(snapshot.cards.map(\.visualState), [.satisfied, .unsafe])
    }

    func testCancelInterruptionTimeoutAndBackgroundingProduceTerminalSnapshots() {
        let cancelled = RuntimePresentationTerminalSnapshotAdapter.terminalStop(
            traceID: "trace-cancel",
            stopReason: .cancelled
        )
        let interrupted = RuntimePresentationTerminalSnapshotAdapter.terminalStop(
            traceID: "trace-interrupt",
            stopReason: .interrupted
        )
        let timeout = RuntimePresentationTerminalSnapshotAdapter.terminalStop(
            traceID: "trace-timeout",
            stopReason: .timeout
        )
        let backgrounding = RuntimePresentationTerminalSnapshotAdapter.terminalStop(
            traceID: "trace-background",
            stopReason: .backgrounding
        )

        XCTAssertTrue(cancelled.isTerminal)
        XCTAssertTrue(interrupted.isTerminal)
        XCTAssertTrue(timeout.isTerminal)
        XCTAssertTrue(backgrounding.isTerminal)
        XCTAssertEqual(cancelled.runtimeOutcome.result, .cancelled)
        XCTAssertEqual(interrupted.runtimeOutcome.result, .interrupted)
        XCTAssertEqual(timeout.runtimeOutcome.result, .runtimeError)
        XCTAssertEqual(backgrounding.runtimeOutcome.result, .interrupted)
        XCTAssertEqual(cancelled.runtimeOutcome.reason, "cancelled")
        XCTAssertEqual(interrupted.runtimeOutcome.reason, "interrupted")
        XCTAssertEqual(timeout.runtimeOutcome.reason, "timeout")
        XCTAssertEqual(backgrounding.runtimeOutcome.reason, "backgrounding")
        XCTAssertEqual([cancelled, interrupted, timeout, backgrounding].map(\.proofClass), Array(repeating: .localUnit, count: 4))
    }

    func testTimeoutIsTerminalStopNotInteractionEventKind() {
        XCTAssertFalse(DemoInteractionEventKind.allCases.map(\.rawValue).contains("timeout"))

        let timeout = RuntimePresentationTerminalSnapshotAdapter.terminalStop(
            traceID: "trace-timeout-contract",
            stopReason: .timeout
        )

        XCTAssertTrue(timeout.isTerminal)
        XCTAssertEqual(timeout.runtimeOutcome.result, .runtimeError)
        XCTAssertEqual(timeout.runtimeOutcome.reason, "timeout")
    }

    func testEventSourceAndSnapshotScopeRemainSeparate() {
        let event = DemoInteractionEvent(
            eventID: "event-1",
            traceID: "trace-provenance",
            kind: .cardTap,
            source: .user,
            cardKey: "ac.power"
        )
        let snapshot = PresentationSnapshot(
            traceID: "trace-provenance",
            runtimeOutcome: DemoRuntimeOutcome(behaviorClass: .toolCall),
            cards: [],
            scopeOrigin: .explicit,
            proofClass: .localUnit,
            isTerminal: true
        )

        XCTAssertEqual(event.source, .user)
        XCTAssertEqual(event.cardKey, "ac.power")
        XCTAssertNil(event.text)
        XCTAssertEqual(snapshot.scopeOrigin, .explicit)
    }

    func testTraceEnvelopePresentationSafeRedactsAndAppendRequiresMonotonicSameTrace() throws {
        let firstTimestamp = Date(timeIntervalSince1970: 1_800_000_010)
        let secondTimestamp = Date(timeIntervalSince1970: 1_800_000_011)
        let first = TraceEntry(
            stage: .decode,
            traceID: "trace-redact",
            message: "rawModelOutput:secret trainingReceipt runtimeStore",
            timestamp: firstTimestamp
        )
        let envelope = try XCTUnwrap(TraceEnvelope(traceID: "trace-redact", entries: [first]))
        let safe = envelope.presentationSafe()

        XCTAssertEqual(safe.traceID, "trace-redact")
        XCTAssertFalse(safe.entries[0].message.contains("rawModelOutput"))
        XCTAssertFalse(safe.entries[0].message.contains("trainingReceipt"))
        XCTAssertFalse(safe.entries[0].message.contains("runtimeStore"))
        XCTAssertTrue(safe.entries[0].message.contains("[redacted]"))

        let validAppend = TraceEntry(
            stage: .readback,
            traceID: "trace-redact",
            message: "readback_ok",
            timestamp: secondTimestamp
        )
        let wrongTrace = TraceEntry(
            stage: .readback,
            traceID: "trace-other",
            message: "readback_ok",
            timestamp: secondTimestamp
        )
        let nonMonotonic = TraceEntry(
            stage: .readback,
            traceID: "trace-redact",
            message: "readback_old",
            timestamp: firstTimestamp.addingTimeInterval(-1)
        )

        XCTAssertEqual(envelope.appending(validAppend)?.entries.map(\.message), ["rawModelOutput:secret trainingReceipt runtimeStore", "readback_ok"])
        XCTAssertNil(envelope.appending(wrongTrace))
        XCTAssertNil(envelope.appending(nonMonotonic))
    }

    func testTraceEnvelopeInitializerRejectsWrongTraceAndNonMonotonicEntries() {
        let firstTimestamp = Date(timeIntervalSince1970: 1_800_000_020)
        let secondTimestamp = Date(timeIntervalSince1970: 1_800_000_021)
        let first = TraceEntry(stage: .decode, traceID: "trace-strict", message: "decode", timestamp: firstTimestamp)
        let second = TraceEntry(stage: .readback, traceID: "trace-strict", message: "readback", timestamp: secondTimestamp)
        let wrongTrace = TraceEntry(stage: .readback, traceID: "trace-other", message: "readback", timestamp: secondTimestamp)
        let nonMonotonic = TraceEntry(stage: .readback, traceID: "trace-strict", message: "old", timestamp: firstTimestamp.addingTimeInterval(-1))

        XCTAssertNotNil(TraceEnvelope(traceID: "trace-strict", entries: [first, second]))
        XCTAssertNil(TraceEnvelope(traceID: "trace-strict", entries: [first, wrongTrace]))
        XCTAssertNil(TraceEnvelope(traceID: "trace-strict", entries: [first, nonMonotonic]))
    }

    func testTerminalSnapshotAdapterSanitizesTraceEnvelopeAtBoundary() throws {
        let traceEntry = TraceEntry(
            stage: .decode,
            traceID: "trace-boundary",
            message: "rawModelOutput:secret trainingReceipt runtimeStore",
            attributes: TraceAttributes(
                stopReason: "rawModelOutput:stop",
                guardReason: "trainingReceipt:guard runtimeStore"
            ),
            timestamp: Date(timeIntervalSince1970: 1_800_000_030)
        )
        let rawEnvelope = try XCTUnwrap(TraceEnvelope(traceID: "trace-boundary", entries: [traceEntry]))
        let snapshot = RuntimePresentationTerminalSnapshotAdapter.guardDenial(
            traceID: "trace-boundary",
            reason: "rawModelOutput:secret trainingReceipt runtimeStore",
            traceEnvelope: rawEnvelope
        )

        let encoded = String(decoding: try JSONEncoder().encode(snapshot), as: UTF8.self)
        XCTAssertFalse(encoded.contains("rawModelOutput"))
        XCTAssertFalse(encoded.contains("trainingReceipt"))
        XCTAssertFalse(encoded.contains("runtimeStore"))
        XCTAssertEqual(snapshot.runtimeOutcome.reason, "[redacted]:secret [redacted] [redacted]")
        XCTAssertEqual(snapshot.traceEnvelope?.entries.first?.message, "[redacted]:secret [redacted] [redacted]")
        XCTAssertEqual(snapshot.traceEnvelope?.entries.first?.attributes.stopReason, "[redacted]:stop")
        XCTAssertEqual(snapshot.traceEnvelope?.entries.first?.attributes.guardReason, "[redacted]:guard [redacted]")
    }

    func testTraceEnvelopeDecoderRejectsInvalidEntryIdentityAndOrdering() throws {
        let firstTimestamp = Date(timeIntervalSince1970: 1_800_000_040)
        let secondTimestamp = Date(timeIntervalSince1970: 1_800_000_041)
        let first = TraceEntry(stage: .decode, traceID: "trace-decode", message: "decode", timestamp: firstTimestamp)
        let wrongTrace = TraceEntry(stage: .readback, traceID: "trace-other", message: "wrong", timestamp: secondTimestamp)
        let nonMonotonic = TraceEntry(stage: .readback, traceID: "trace-decode", message: "old", timestamp: firstTimestamp.addingTimeInterval(-1))

        let wrongTraceData = try JSONEncoder().encode(UnsafeTraceEnvelope(traceID: "trace-decode", entries: [first, wrongTrace]))
        let nonMonotonicData = try JSONEncoder().encode(UnsafeTraceEnvelope(traceID: "trace-decode", entries: [first, nonMonotonic]))

        XCTAssertThrowsError(try JSONDecoder().decode(TraceEnvelope.self, from: wrongTraceData))
        XCTAssertThrowsError(try JSONDecoder().decode(TraceEnvelope.self, from: nonMonotonicData))
    }

    func testCardOrderingAndSemanticsCarryMachineReadableFields() {
        let satisfied = DemoVehicleStateCell(
            key: "window.driver",
            actualValue: "closed",
            visualState: .satisfied
        )
        let refused = DemoVehicleStateCell(
            key: "door.lock",
            actualValue: "locked",
            visualState: .unsafe
        )
        let snapshot = PresentationSnapshot(
            traceID: "trace-card-semantics",
            runtimeOutcome: DemoRuntimeOutcome(result: .refusalSafetyOrPolicy, reason: "partial_accept_refuse"),
            cards: PresentationCardOrdering.orderedForPresentation([satisfied, refused]),
            cardSemantics: [
                PresentationCardSemantics(
                    cellKey: "door.lock",
                    role: .refused,
                    scopeOrigin: .explicit,
                    reason: "risk_policy_refuse",
                    isActive: true,
                    siblingKeys: ["window.driver"]
                ),
                PresentationCardSemantics(
                    cellKey: "window.driver",
                    role: .accepted,
                    scopeOrigin: .explicit,
                    isActive: false
                )
            ],
            proofClass: .localUnit,
            isTerminal: true
        )

        XCTAssertEqual(snapshot.cards.map(\.key), ["door.lock", "window.driver"])
        XCTAssertEqual(snapshot.cardSemantics?.first?.role, .refused)
        XCTAssertEqual(snapshot.cardSemantics?.first?.reason, "risk_policy_refuse")
        XCTAssertEqual(snapshot.cardSemantics?.first?.siblingKeys, ["window.driver"])
        XCTAssertEqual(snapshot.cardSemantics?.first?.isActive, true)
    }

    private struct UnsafeTraceEnvelope: Codable {
        var traceID: String
        var entries: [TraceEntry]
    }
}
