import XCTest
@testable import MAformacCore

/// D1 W7 production consumer wire — deliberate-negative + positive test bundle.
///
/// Anti-fixture-green suite (`~/.claude/rules/claim-vs-reality-gap.md` 铁律 2):
/// this file's job is to prove the wire is not "state field set". Positives
/// exercise the accept branch; negatives exercise the refuse branches
/// (schema unsupported, missing identity, version mismatch, atomic batch,
/// no-provider no-op). Reducer refusal is expected to leave `typedFactsWindow`
/// untouched and emit a `typed_facts_refused` guard entry on the trace channel.
final class D1TypedFactsWireDeliberateNegativeTests: XCTestCase {

    // MARK: - Fixtures

    private let supportedVersion = DialogueStateSchemaVersion.v1
    private let unsupportedVersion = DialogueStateSchemaVersion.unsupported(rawValue: "w7.dialogue-state/v99")

    private func validCorrelation(
        turnID: String = "turn-1",
        traceID: String = "trace-1",
        session: String = "session-A",
        generation: String = "gen-A",
        ordinal: UInt32 = 0,
        version: DialogueStateSchemaVersion? = nil,
        routeVersion: DialogueStateSchemaVersion? = nil
    ) -> RouteToDialogueCorrelation {
        let effectiveVersion = version ?? supportedVersion
        let effectiveRouteVersion = routeVersion ?? effectiveVersion
        return RouteToDialogueCorrelation(
            route: DialogueRouteAttribution(
                routeTurnID: RouteTurnIdentifier(turnID),
                routeTraceID: RouteTraceIdentifier(traceID),
                traceDigestRef: "digest-\(turnID)",
                actionCandidateRef: "candidate-\(turnID)",
                schemaVersion: effectiveRouteVersion
            ),
            dialogueGroupRef: DialogueSourceGroupRef(
                sessionRef: session,
                generationRef: generation,
                groupOrdinal: ordinal
            ),
            schemaVersion: effectiveVersion
        )
    }

    private func acPowerFrame(id: String, traceID: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.toggle",
            toolName: "set_vehicle_control",
            device: "ac",
            actionPrimitive: "power_on",
            value: ContractValue(offset: "on", type: "STATE"),
            stateRevision: 0,
            candidateSource: .fastPath
        )
    }

    // MARK: - POSITIVE 1 — no provider means zero side effect on window

    @MainActor
    func testPositive_NoProviderLeavesTypedFactsWindowEmptyAcrossRuns() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                self!.acPowerFrame(id: "turn-\(UUID().uuidString.prefix(6))", traceID: UUID().uuidString)
            },
            alignsFrameStateRevisionToStore: true
            // correlationProvider omitted = nil
        )

        _ = try await runner.run(text: "打开空调")
        _ = try await runner.run(text: "打开空调")

        XCTAssertEqual(runner.currentDialogueState.typedFactsWindow.count, 0,
                       "no-provider default must not populate typedFactsWindow")
        XCTAssertNil(runner.lastTypedFactsRecordResult,
                     "no-provider default must not surface a recorder outcome")
        XCTAssertFalse(trace.entries.contains { $0.message == "typed_facts_refused" },
                       "no-provider default must not emit typed_facts_refused guard")
    }

    // MARK: - POSITIVE 2 — provider returning nil records "accepted count 0"

    @MainActor
    func testPositive_ProviderReturningNilLeavesWindowUnchangedAndAccountsTurn() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let provider = RuntimeSessionCorrelationProvider { _, _ in nil }
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                self!.acPowerFrame(id: "turn-fixed", traceID: "trace-fixed")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: provider
        )

        _ = try await runner.run(text: "打开空调")

        XCTAssertEqual(runner.currentDialogueState.typedFactsWindow.count, 0,
                       "provider-returns-nil path must not append")
        XCTAssertEqual(runner.lastTypedFactsRecordResult, .accepted(count: 0),
                       "provider-returns-nil path must surface an explicit accounted no-op")
        XCTAssertNil(runner.lastTypedFactsRefusal,
                     "no correlation was constructed, so no refusal to report")
    }

    // MARK: - POSITIVE 3 — valid correlation lands in window with content

    @MainActor
    func testPositive_ValidCorrelationLandsInTypedFactsWindow() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        var callCount = 0
        let provider = RuntimeSessionCorrelationProvider { [weak self] frame, traceID in
            guard let self else { return nil }
            callCount += 1
            return self.validCorrelation(
                turnID: frame.id,
                traceID: traceID,
                session: "session-live",
                generation: "gen-live",
                ordinal: UInt32(callCount)
            )
        }
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                self!.acPowerFrame(id: "turn-live", traceID: "trace-live")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: provider
        )

        _ = try await runner.run(text: "打开空调")

        let window = runner.currentDialogueState.typedFactsWindow
        XCTAssertEqual(window.count, 1, "valid correlation must be appended")
        XCTAssertEqual(window.first?.dialogueGroupRef.sessionRef, "session-live")
        XCTAssertEqual(window.first?.dialogueGroupRef.generationRef, "gen-live")
        XCTAssertEqual(runner.lastTypedFactsRecordResult, .accepted(count: 1))
        XCTAssertFalse(trace.entries.contains { $0.message == "typed_facts_refused" },
                       "valid correlation must not emit typed_facts_refused guard")
    }

    // MARK: - POSITIVE 4 — two turns preserve ordering

    @MainActor
    func testPositive_TwoTurnsPreserveWindowOrderingAndCorrelateEachTurnDistinctly() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        var seen = 0
        let provider = RuntimeSessionCorrelationProvider { [weak self] frame, traceID in
            guard let self else { return nil }
            seen += 1
            return self.validCorrelation(
                turnID: frame.id,
                traceID: traceID,
                session: "session-two",
                generation: "gen-two",
                ordinal: UInt32(seen)
            )
        }
        var turnCounter = 0
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                turnCounter += 1
                return self!.acPowerFrame(id: "turn-\(turnCounter)", traceID: "trace-\(turnCounter)")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: provider
        )

        _ = try await runner.run(text: "打开空调")
        _ = try await runner.run(text: "打开空调")

        let window = runner.currentDialogueState.typedFactsWindow
        XCTAssertEqual(window.count, 2, "two turns must both land typed facts")
        XCTAssertEqual(window.map(\.dialogueGroupRef.groupOrdinal), [1, 2],
                       "window must preserve append order across turns")
        XCTAssertNotEqual(window[0].route.routeTurnID, window[1].route.routeTurnID,
                          "each turn must land with a distinct route identity")
    }

    // MARK: - POSITIVE 5 — maxTypedFacts trims window suffix

    @MainActor
    func testPositive_MaxTypedFactsTrimsWindowToSuffix() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        var counter: UInt32 = 0
        let provider = RuntimeSessionCorrelationProvider { [weak self] _, traceID in
            guard let self else { return nil }
            counter += 1
            return self.validCorrelation(
                turnID: "turn-\(counter)",
                traceID: traceID,
                ordinal: counter
            )
        }
        var turnCounter = 0
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                turnCounter += 1
                return self!.acPowerFrame(id: "turn-trim-\(turnCounter)", traceID: "trace-trim-\(turnCounter)")
            },
            alignsFrameStateRevisionToStore: true,
            dialogueState: DialogueState(maxTypedFacts: 2),
            correlationProvider: provider
        )

        _ = try await runner.run(text: "打开空调")
        _ = try await runner.run(text: "打开空调")
        _ = try await runner.run(text: "打开空调")

        let window = runner.currentDialogueState.typedFactsWindow
        XCTAssertEqual(window.count, 2, "window must be trimmed to maxTypedFacts")
        XCTAssertEqual(window.map(\.dialogueGroupRef.groupOrdinal), [2, 3],
                       "trim must keep suffix (last 2 turns), not prefix")
    }

    // MARK: - DELIBERATE NEGATIVE 1 — unsupported schema version fails closed

    @MainActor
    func testNegative_UnsupportedSchemaVersionRefusedByReducerAndTraceGuardEmitted() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let provider = RuntimeSessionCorrelationProvider { [weak self] frame, traceID in
            guard let self else { return nil }
            return self.validCorrelation(
                turnID: frame.id,
                traceID: traceID,
                version: self.unsupportedVersion,
                routeVersion: self.unsupportedVersion
            )
        }
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                self!.acPowerFrame(id: "turn-refuse", traceID: "trace-refuse")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: provider
        )

        _ = try await runner.run(text: "打开空调")

        XCTAssertEqual(runner.currentDialogueState.typedFactsWindow.count, 0,
                       "unsupported schema version must not append")
        if case .deniedContextInvalid(let reason) = runner.lastTypedFactsRecordResult {
            XCTAssertEqual(reason, "unsupported_schema_version",
                           "reducer must surface stable reason tag")
        } else {
            XCTFail("expected .deniedContextInvalid, got \(String(describing: runner.lastTypedFactsRecordResult))")
        }
        let guardHit = trace.entries.first { $0.message == "typed_facts_refused" }
        XCTAssertNotNil(guardHit, "reducer refusal must emit typed_facts_refused guard")
        XCTAssertEqual(guardHit?.attributes.guardReason, "typed_facts_refused:unsupported_schema_version")
    }

    // MARK: - DELIBERATE NEGATIVE 2 — missing route turn id fails closed

    @MainActor
    func testNegative_MissingRouteTurnIDRefusedByReducer() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let provider = RuntimeSessionCorrelationProvider { [weak self] _, traceID in
            guard let self else { return nil }
            // Force empty turn id — validator must fail on it.
            return self.validCorrelation(
                turnID: "",
                traceID: traceID
            )
        }
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                self!.acPowerFrame(id: "turn-missing", traceID: "trace-missing")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: provider
        )

        _ = try await runner.run(text: "打开空调")

        XCTAssertEqual(runner.currentDialogueState.typedFactsWindow.count, 0)
        XCTAssertEqual(runner.lastTypedFactsRecordResult,
                       .deniedContextInvalid(reason: "missing_route_turn_id"))
        XCTAssertEqual(runner.lastTypedFactsRefusal?.reason, "missing_route_turn_id")
    }

    // MARK: - DELIBERATE NEGATIVE 3 — route/correlation version mismatch fails closed

    @MainActor
    func testNegative_RouteAndCorrelationVersionMismatchRefusedByReducer() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let providerVersionMismatch = RuntimeSessionCorrelationProvider { [weak self] frame, traceID in
            guard let self else { return nil }
            return self.validCorrelation(
                turnID: frame.id,
                traceID: traceID,
                version: self.supportedVersion,
                routeVersion: self.unsupportedVersion
            )
        }
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                self!.acPowerFrame(id: "turn-vers-mism", traceID: "trace-vers-mism")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: providerVersionMismatch
        )

        _ = try await runner.run(text: "打开空调")

        // Reducer refuses (route.schemaVersion.isSupported == false surfaces first
        // as unsupported_schema_version); window must remain empty either way.
        XCTAssertEqual(runner.currentDialogueState.typedFactsWindow.count, 0,
                       "any refusal path must leave window unchanged")
        if case .deniedContextInvalid = runner.lastTypedFactsRecordResult {
            // OK — the exact tag depends on which branch fires first, both are refusals.
        } else {
            XCTFail("mismatched version pair must produce a reducer refusal, got \(String(describing: runner.lastTypedFactsRecordResult))")
        }
        XCTAssertNotNil(runner.lastTypedFactsRefusal,
                        "refusal must be observable to downstream operators")
    }

    // MARK: - DELIBERATE NEGATIVE 4 — direct reducer batch atomicity (bad in a good batch refuses all)

    func testNegative_ReducerRefusesEntireBatchOnFirstInvalidFact() {
        var state = DialogueState(maxTypedFacts: 8)
        let good1 = validCorrelation(turnID: "t1", traceID: "r1", ordinal: 1)
        let bad = validCorrelation(turnID: "", traceID: "r2", ordinal: 2)
        let good2 = validCorrelation(turnID: "t3", traceID: "r3", ordinal: 3)

        let result = state.recordTypedFacts([good1, bad, good2])

        XCTAssertEqual(result, .deniedContextInvalid(reason: "missing_route_turn_id"),
                       "one bad fact in the middle must fail the whole batch")
        XCTAssertEqual(state.typedFactsWindow.count, 0,
                       "reducer must not append the good ones from a refused batch (atomic)")
    }

    // MARK: - DELIBERATE NEGATIVE 5 — anti-fixture-green: no-provider run has NO refusal telemetry

    @MainActor
    func testNegative_NoProviderRunProducesNoRefusalTelemetryOrGuardEntry() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makeD1Pipeline(),
            traceLogger: trace,
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { [weak self] _ in
                self!.acPowerFrame(id: "turn-inert", traceID: "trace-inert")
            },
            alignsFrameStateRevisionToStore: true
        )

        _ = try await runner.run(text: "打开空调")

        // Anti-fixture-green: the wire must not surface *any* typed-facts telemetry
        // in the no-provider case, because the wire is inert.
        XCTAssertNil(runner.lastTypedFactsRecordResult)
        XCTAssertNil(runner.lastTypedFactsRefusal)
        XCTAssertFalse(trace.entries.contains { $0.message == "typed_facts_refused" })
        // The wire also must not accidentally scribble on the store or the
        // legacy dialogue turns path.
        XCTAssertGreaterThan(runner.currentDialogueState.turns.count, 0,
                             "legacy turns path must still work unaltered by the wire")
    }

    // MARK: - Helpers

    private func makeD1Pipeline() throws -> C3ExecutionPipeline {
        try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline()
    }
}
