import Foundation

public struct DemoSliceExecution: Equatable, Sendable {
    public let admission: DemoSliceAdmission
    public let payload: RuntimePresentationPayload
    public let runnerCallCount: Int

    public init(admission: DemoSliceAdmission, payload: RuntimePresentationPayload, runnerCallCount: Int) {
        self.admission = admission
        self.payload = payload
        self.runnerCallCount = runnerCallCount
    }
}

public struct DemoSliceRouteResult: Equatable, Sendable {
    public let execution: DemoSliceExecution?
    public let rejection: DemoSliceAdmissionRejection?

    public init(execution: DemoSliceExecution? = nil, rejection: DemoSliceAdmissionRejection? = nil) {
        precondition((execution == nil) != (rejection == nil))
        self.execution = execution
        self.rejection = rejection
    }
}

/// Customer-facing route for the finite reviewed literal catalog. Every
/// unmatched utterance remains fail-closed before execution.
@MainActor
public final class DemoSliceRoute {
    public let catalog: DemoSliceAdmissionCatalog
    private let runner: DemoRuntimeSessionRunner
    private let store: DemoVehicleStateStore
    private let stateCells: StateCellContractLookup
    public private(set) var runnerCallCount = 0

    public init(
        store: DemoVehicleStateStore,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine,
        catalog: DemoSliceAdmissionCatalog = DemoSliceAdmissionCatalog()
    ) throws {
        self.catalog = catalog
        self.store = store
        let bundle = DemoRuntimeContractBundle.singleCommandDemoDefault
        let pipeline = try bundle.makePipeline()
        self.stateCells = pipeline.stateCells
        self.runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: pipeline,
            traceLogger: traceLogger,
            speech: speech,
            planDecoder: { text in
                guard let admission = catalog.admission(for: text) else {
                    throw FastPathIntentError.noMatch(text)
                }
                return try RuntimePlan(
                    traceID: admission.frame.traceID,
                    frames: [.tool(admission.frame)],
                    executionPolicy: .atomic
                )
            }
        )
    }

    /// Unit/default helper surface. Invokes the runner without a production
    /// correlation provider (constructor default / nil). Not the App production surface.
    public func route(text: String) async throws -> DemoSliceRouteResult {
        try await routeBody(text: text, correlationProvider: nil)
    }

    /// App production surface: per-call non-optional correlation provider.
    public func route(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider
    ) async throws -> DemoSliceRouteResult {
        try await routeBody(text: text, correlationProvider: correlationProvider)
    }

    private func routeBody(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider?
    ) async throws -> DemoSliceRouteResult {
        guard let admission = catalog.admission(for: text) else {
            return DemoSliceRouteResult(
                rejection: catalog.rejection(for: text) ?? .notInCatalog
            )
        }

        // Reuse the same scope resolution as C3. Defaulted scopes (for example,
        // ac.temp_setpoint[主驾]) must not miss the pre-run no-op gate.
        let projection = try DemoSliceAdmissionCatalog.targetProjection(
            for: admission,
            stateCells: stateCells
        )
        let desiredValue = projection.desiredValue
        let currentCells = projection.targetKeys.compactMap { store.cell(for: $0) }
        let implicitPowerTargetSatisfied =
            admission.frame.device != "ac_temperature"
            || admission.frame.actionPrimitive == "query"
            || admission.frame.doNotAutoPowerOn
            || store.cell(for: "ac.power")?.actualValue == "on"

        if implicitPowerTargetSatisfied,
           currentCells.count == projection.targetKeys.count,
           currentCells.allSatisfy({ $0.actualValue == desiredValue }) {
            // Already at target state: short-circuit before runner, no mutation, no TTS
            let traceID = UUID().uuidString
            let readbacks = currentCells.map {
                DemoActionReadback(
                    key: $0.key,
                    actualValue: $0.actualValue,
                    revision: $0.revision,
                    spokenText: DemoVehicleStateStore.spokenText(for: $0)
                )
            }
            let snapshot = RuntimePresentationTerminalSnapshotAdapter.alreadyStateNoop(
                traceID: traceID,
                cards: store.presentationCells,
                readbacks: readbacks,
                proofClass: .localUnit
            )
            let payload = RuntimePresentationPayload(
                snapshot: snapshot,
                turnID: admission.frame.id,
                eventID: "\(admission.frame.id):runtime-presentation",
                reconciliation: PresentationReconciliation(
                    status: .verified,
                    readbackKey: readbacks.first?.key,
                    safeReason: "already_state_noop"
                )
            )
            // runnerCallCount NOT incremented; no runner/TTS invocation
            return DemoSliceRouteResult(
                execution: DemoSliceExecution(
                    admission: admission,
                    payload: payload,
                    runnerCallCount: runnerCallCount
                )
            )
        }

        // Not at target: proceed to runner
        runnerCallCount += 1
        let payload: RuntimePresentationPayload
        if let correlationProvider {
            payload = try await runner.run(text: text, correlationProvider: correlationProvider)
        } else {
            payload = try await runner.run(text: text)
        }
        return DemoSliceRouteResult(
            execution: DemoSliceExecution(
                admission: admission,
                payload: payload,
                runnerCallCount: runnerCallCount
            )
        )
    }
}