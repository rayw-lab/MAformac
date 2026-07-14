import XCTest
@testable import MAformacCore

/// S1 production correlation factory + per-call runner isolation proofs.
///
/// Behavioral surface only (Core). App composition wiring lives in
/// `ProductOperatorCompositionRootTests` / containment source contracts.
@MainActor
final class ProductOperatorCorrelationWireTests: XCTestCase {

    // MARK: - Factory positives

    func testFactoryPositive_FreezesIdentityTupleAndOuterNestedSchemaV1() throws {
        let provider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "  turn-prod-1  ",
            sessionRef: " session-prod-A ",
            generationRef: " gen-7 ",
            groupOrdinal: 3
        )

        let frame = acPowerFrame(id: "frame-candidate-42", traceID: "unused-frame-trace")
        let correlation = try XCTUnwrap(
            provider.makeCorrelation(frame, "  trace-live-99  "),
            "valid non-blank trace must produce correlation"
        )

        XCTAssertEqual(correlation.route.routeTurnID.rawValue, "turn-prod-1")
        XCTAssertEqual(correlation.route.routeTraceID.rawValue, "trace-live-99")
        XCTAssertEqual(correlation.route.actionCandidateRef, "frame-candidate-42")
        XCTAssertNil(correlation.route.traceDigestRef)
        XCTAssertEqual(correlation.route.schemaVersion, .v1)

        XCTAssertEqual(correlation.dialogueGroupRef.sessionRef, "session-prod-A")
        XCTAssertEqual(correlation.dialogueGroupRef.generationRef, "gen-7")
        XCTAssertEqual(correlation.dialogueGroupRef.groupOrdinal, 3)

        XCTAssertEqual(correlation.schemaVersion, .v1)
        XCTAssertEqual(correlation.route.schemaVersion, .v1)
        XCTAssertEqual(
            correlation.schemaVersion.rawValue,
            DialogueStateSchemaVersion.v1RawValue
        )
    }

    func testFactoryPositive_IdentityRemainsFrozenAcrossDistinctTraceAndFrameCalls() throws {
        let provider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-frozen",
            sessionRef: "session-frozen",
            generationRef: "gen-frozen",
            groupOrdinal: 11
        )

        let first = try XCTUnwrap(
            provider.makeCorrelation(
                acPowerFrame(id: "cand-1", traceID: "t1"),
                "trace-A"
            )
        )
        let second = try XCTUnwrap(
            provider.makeCorrelation(
                acPowerFrame(id: "cand-2", traceID: "t2"),
                "trace-B"
            )
        )

        XCTAssertEqual(first.route.routeTurnID.rawValue, "turn-frozen")
        XCTAssertEqual(second.route.routeTurnID.rawValue, "turn-frozen")
        XCTAssertEqual(first.dialogueGroupRef.sessionRef, "session-frozen")
        XCTAssertEqual(second.dialogueGroupRef.sessionRef, "session-frozen")
        XCTAssertEqual(first.dialogueGroupRef.generationRef, "gen-frozen")
        XCTAssertEqual(second.dialogueGroupRef.generationRef, "gen-frozen")
        XCTAssertEqual(first.dialogueGroupRef.groupOrdinal, 11)
        XCTAssertEqual(second.dialogueGroupRef.groupOrdinal, 11)

        XCTAssertEqual(first.route.routeTraceID.rawValue, "trace-A")
        XCTAssertEqual(second.route.routeTraceID.rawValue, "trace-B")
        XCTAssertEqual(first.route.actionCandidateRef, "cand-1")
        XCTAssertEqual(second.route.actionCandidateRef, "cand-2")
    }

    func testFactoryPositive_BlankFrameIDYieldsNilActionCandidateRef() throws {
        let provider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-blank-frame",
            sessionRef: "session-blank-frame",
            generationRef: "gen-blank-frame",
            groupOrdinal: 1
        )
        let correlation = try XCTUnwrap(
            provider.makeCorrelation(
                acPowerFrame(id: "   ", traceID: "t"),
                "trace-ok"
            )
        )
        XCTAssertNil(correlation.route.actionCandidateRef)
        XCTAssertEqual(correlation.route.routeTurnID.rawValue, "turn-blank-frame")
    }

    // MARK: - Factory negatives

    func testFactoryNegative_BlankRouteSessionGenerationFailClosed() {
        XCTAssertThrowsError(
            try ProductionRouteCorrelationProvider.make(
                routeTurnID: "   ",
                sessionRef: "session",
                generationRef: "gen",
                groupOrdinal: 1
            )
        ) { error in
            XCTAssertEqual(
                error as? ProductionRouteCorrelationProvider.FactoryError,
                .emptyRouteTurnID
            )
        }

        XCTAssertThrowsError(
            try ProductionRouteCorrelationProvider.make(
                routeTurnID: "turn",
                sessionRef: "\n\t ",
                generationRef: "gen",
                groupOrdinal: 1
            )
        ) { error in
            XCTAssertEqual(
                error as? ProductionRouteCorrelationProvider.FactoryError,
                .emptySessionRef
            )
        }

        XCTAssertThrowsError(
            try ProductionRouteCorrelationProvider.make(
                routeTurnID: "turn",
                sessionRef: "session",
                generationRef: "",
                groupOrdinal: 1
            )
        ) { error in
            XCTAssertEqual(
                error as? ProductionRouteCorrelationProvider.FactoryError,
                .emptyGenerationRef
            )
        }
    }

    func testFactoryNegative_BlankTraceReturnsNilCorrelation() throws {
        let provider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn",
            sessionRef: "session",
            generationRef: "gen",
            groupOrdinal: 2
        )
        XCTAssertNil(
            provider.makeCorrelation(
                acPowerFrame(id: "frame", traceID: "t"),
                "   "
            ),
            "blank/whitespace trace must fail closed at provider boundary"
        )
        XCTAssertNil(
            provider.makeCorrelation(
                acPowerFrame(id: "frame", traceID: "t"),
                ""
            )
        )
    }

    // MARK: - Per-call isolation (runner production surface)

    func testPerCallIsolation_TwoDistinctProvidersCannotCrossContaminate() async throws {
        let store = DemoVehicleStateStore()
        let runner = try DemoRuntimeSessionRunner(
            store: store,
            pipeline: makePipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in
                self.acPowerFrame(id: "shared-frame", traceID: "shared-trace")
            },
            alignsFrameStateRevisionToStore: true
            // constructor provider intentionally omitted (nil)
        )

        let providerA = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-A",
            sessionRef: "session-A",
            generationRef: "gen-A",
            groupOrdinal: 1
        )
        let providerB = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-B",
            sessionRef: "session-B",
            generationRef: "gen-B",
            groupOrdinal: 2
        )

        _ = try await runner.run(text: "打开空调", correlationProvider: providerA)
        _ = try await runner.run(text: "打开空调", correlationProvider: providerB)

        let window = runner.currentDialogueState.typedFactsWindow
        XCTAssertEqual(window.count, 2, "each per-call provider must land one fact")
        XCTAssertEqual(window[0].route.routeTurnID.rawValue, "turn-A")
        XCTAssertEqual(window[0].dialogueGroupRef.sessionRef, "session-A")
        XCTAssertEqual(window[0].dialogueGroupRef.generationRef, "gen-A")
        XCTAssertEqual(window[0].dialogueGroupRef.groupOrdinal, 1)

        XCTAssertEqual(window[1].route.routeTurnID.rawValue, "turn-B")
        XCTAssertEqual(window[1].dialogueGroupRef.sessionRef, "session-B")
        XCTAssertEqual(window[1].dialogueGroupRef.generationRef, "gen-B")
        XCTAssertEqual(window[1].dialogueGroupRef.groupOrdinal, 2)

        XCTAssertNotEqual(
            window[0].dialogueGroupRef.sessionRef,
            window[1].dialogueGroupRef.sessionRef
        )
        XCTAssertEqual(runner.lastTypedFactsRecordResult, .accepted(count: 1))
    }

    func testPerCallProviderOverridesConstructorBoundProviderForThatInvocationOnly() async throws {
        let constructorProvider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-ctor",
            sessionRef: "session-ctor",
            generationRef: "gen-ctor",
            groupOrdinal: 9
        )
        let perCallProvider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-per-call",
            sessionRef: "session-per-call",
            generationRef: "gen-per-call",
            groupOrdinal: 4
        )

        let runner = try DemoRuntimeSessionRunner(
            store: DemoVehicleStateStore(),
            pipeline: makePipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in
                self.acPowerFrame(id: "frame-override", traceID: "trace-override")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: constructorProvider
        )

        _ = try await runner.run(text: "打开空调", correlationProvider: perCallProvider)

        let window = runner.currentDialogueState.typedFactsWindow
        XCTAssertEqual(window.count, 1)
        XCTAssertEqual(window[0].route.routeTurnID.rawValue, "turn-per-call")
        XCTAssertEqual(window[0].dialogueGroupRef.sessionRef, "session-per-call")
        XCTAssertNotEqual(window[0].route.routeTurnID.rawValue, "turn-ctor")
    }

    func testLegacyHelperRunUsesConstructorProviderAndNilLeavesWindowEmpty() async throws {
        // Nil-provider unit/default surface (legacy helper).
        let nilRunner = try DemoRuntimeSessionRunner(
            store: DemoVehicleStateStore(),
            pipeline: makePipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in
                self.acPowerFrame(id: "frame-nil", traceID: "trace-nil")
            },
            alignsFrameStateRevisionToStore: true
        )
        _ = try await nilRunner.run(text: "打开空调")
        XCTAssertEqual(nilRunner.currentDialogueState.typedFactsWindow.count, 0)
        XCTAssertNil(nilRunner.lastTypedFactsRecordResult)

        // Constructor-bound provider is only consumed by the legacy helper surface.
        let ctorProvider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-legacy",
            sessionRef: "session-legacy",
            generationRef: "gen-legacy",
            groupOrdinal: 5
        )
        let ctorRunner = try DemoRuntimeSessionRunner(
            store: DemoVehicleStateStore(),
            pipeline: makePipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in
                self.acPowerFrame(id: "frame-legacy", traceID: "trace-legacy")
            },
            alignsFrameStateRevisionToStore: true,
            correlationProvider: ctorProvider
        )
        _ = try await ctorRunner.run(text: "打开空调")
        let window = ctorRunner.currentDialogueState.typedFactsWindow
        XCTAssertEqual(window.count, 1)
        XCTAssertEqual(window[0].route.routeTurnID.rawValue, "turn-legacy")
        XCTAssertEqual(window[0].dialogueGroupRef.sessionRef, "session-legacy")
    }

    func testProductionProviderBlankTraceDoesNotLandTypedFactsSuccess() async throws {
        let provider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: "turn-blank-trace",
            sessionRef: "session-blank-trace",
            generationRef: "gen-blank-trace",
            groupOrdinal: 1
        )
        // Force empty runner trace path by supplying empty id on the frame's
        // accompanying trace via a provider-level blank; use a custom provider
        // that wraps production factory then blanks the live trace.
        // Direct: invoke factory provider with blank is already unit-covered;
        // here exercise runner with a production-shaped provider that returns
        // nil on blank — same fail-closed contract.
        let blankTraceProvider = RuntimeSessionCorrelationProvider { frame, _ in
            provider.makeCorrelation(frame, "")
        }
        let runner = try DemoRuntimeSessionRunner(
            store: DemoVehicleStateStore(),
            pipeline: makePipeline(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            frameDecoder: { _ in
                self.acPowerFrame(id: "frame-blank-trace", traceID: "trace-ignored")
            },
            alignsFrameStateRevisionToStore: true
        )

        _ = try await runner.run(text: "打开空调", correlationProvider: blankTraceProvider)

        XCTAssertEqual(runner.currentDialogueState.typedFactsWindow.count, 0)
        XCTAssertEqual(runner.lastTypedFactsRecordResult, .accepted(count: 0))
        XCTAssertNil(runner.lastTypedFactsRefusal)
    }

    // MARK: - Helpers

    private func makePipeline() throws -> C3ExecutionPipeline {
        try DemoRuntimeContractBundle.singleCommandDemoDefault.makePipeline()
    }

    private func acPowerFrame(id: String, traceID: String) -> ToolCallFrame {
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
}
