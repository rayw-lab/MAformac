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

public struct DemoSliceReadOnlyOutcome: Equatable, Sendable {
    public let classification: DemoSliceClassification
    public let payload: RuntimePresentationPayload
    public let runnerCallCount: Int

    public init(
        classification: DemoSliceClassification,
        payload: RuntimePresentationPayload,
        runnerCallCount: Int
    ) {
        self.classification = classification
        self.payload = payload
        self.runnerCallCount = runnerCallCount
    }
}

public struct DemoSliceRouteResult: Equatable, Sendable {
    public let classification: DemoSliceClassification
    public let execution: DemoSliceExecution?
    public let rejection: DemoSliceAdmissionRejection?
    public let readOnly: DemoSliceReadOnlyOutcome?

    public init(
        classification: DemoSliceClassification,
        execution: DemoSliceExecution? = nil,
        rejection: DemoSliceAdmissionRejection? = nil,
        readOnly: DemoSliceReadOnlyOutcome? = nil
    ) {
        let filled = [execution != nil, rejection != nil, readOnly != nil].filter { $0 }.count
        precondition(filled == 1)
        self.classification = classification
        self.execution = execution
        self.rejection = rejection
        self.readOnly = readOnly
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
    /// Last successfully committed command lease identity (for post-commit `算了` → cancelTooLate).
    public private(set) var lastCommittedTurn: RuntimeTurnIdentity?
    /// Set when composition preempts an in-flight ingress Task (pre-commit cancel link target).
    public private(set) var preemptedInFlightTurn: RuntimeTurnIdentity?

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

    /// Composition notes the preempted in-flight turn before routing `算了`.
    public func notePreemptedInFlight(_ identity: RuntimeTurnIdentity) {
        preemptedInFlightTurn = identity
    }

    /// Unit/default helper surface. Invokes the runner without a production
    /// correlation provider (constructor default / nil). Not the App production surface.
    public func route(
        text: String,
        lease: RuntimeTurnLease? = nil
    ) async throws -> DemoSliceRouteResult {
        try await routeBody(text: text, correlationProvider: nil, lease: lease)
    }

    /// App production surface: per-call non-optional correlation provider.
    /// Optional `lease` threads G4 Door-1/Door-2 fencing into the runner.
    public func route(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider,
        lease: RuntimeTurnLease? = nil
    ) async throws -> DemoSliceRouteResult {
        try await routeBody(
            text: text,
            correlationProvider: correlationProvider,
            lease: lease
        )
    }

    private func routeBody(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider?,
        lease: RuntimeTurnLease?
    ) async throws -> DemoSliceRouteResult {
        let classification = catalog.classify(for: text)
        switch classification {
        case let .command(admission):
            return try await routeCommand(
                admission: admission,
                classification: classification,
                text: text,
                correlationProvider: correlationProvider,
                lease: lease
            )
        case let .stateQuery(spec):
            return try routeStateQuery(spec: spec, classification: classification)
        case let .capabilityQuery(spec):
            return try routeCapabilityQuery(spec: spec, classification: classification)
        case .clarification:
            return DemoSliceRouteResult(
                classification: classification,
                rejection: .clarifyMissingSlot
            )
        case let .contractRefusal(reason):
            return DemoSliceRouteResult(
                classification: classification,
                rejection: reason
            )
        case let .cancel(target):
            return routeCancel(
                target: target,
                classification: classification,
                lease: lease
            )
        }
    }

    /// Round 6 Q3: `算了` terminates before runner (runnerCallCount unchanged).
    /// Pre-commit (preempted in-flight): cancelled ack linked to preempted identity.
    /// Post-commit (no in-flight, lastCommitted set): cancelTooLate no-action; store untouched.
    private func routeCancel(
        target: String?,
        classification: DemoSliceClassification,
        lease: RuntimeTurnLease?
    ) -> DemoSliceRouteResult {
        _ = target
        let preempted = preemptedInFlightTurn
        preemptedInFlightTurn = nil

        let linked: RuntimeTurnIdentity?
        let cancelTooLate: Bool
        if let preempted {
            linked = preempted
            cancelTooLate = false
        } else if let committed = lastCommittedTurn {
            linked = committed
            cancelTooLate = true
        } else {
            linked = lease.map(RuntimeTurnIdentity.init)
            cancelTooLate = false
        }

        let traceID = UUID().uuidString
        let linkToken = linked?.linkToken ?? "none"
        let result: DemoRuntimeResult
        let reason: String
        let dialogText: String
        let eventPrefix: String
        let safeReason: String
        if cancelTooLate {
            // Presentation allowlist keeps `no_action`; cancelTooLate detail in eventID (G5 owns typed copy).
            result = .noAction
            reason = "no_action"
            dialogText = "命令已执行，如需撤销请说完整反向指令"
            eventPrefix = "cancel-too-late"
            safeReason = "no_action"
        } else {
            result = .cancelled
            reason = "cancelled"
            dialogText = "已取消"
            eventPrefix = "cancel-preempt"
            safeReason = "cancelled"
        }

        let snapshot = PresentationSnapshot(
            traceID: traceID,
            runtimeOutcome: DemoRuntimeOutcome(result: result, reason: reason),
            cards: store.presentationCells,
            dialogText: dialogText,
            readbacks: [],
            voiceState: .idle,
            orbState: .idle,
            mutationCount: 0,
            proofClass: .localUnit,
            isTerminal: true
        )
        let turnID = "\(eventPrefix)-\(traceID)"
        let payload = RuntimePresentationPayload(
            snapshot: snapshot,
            turnID: turnID,
            eventID: "\(eventPrefix):\(linkToken)",
            reconciliation: PresentationReconciliation(
                status: .notApplicable,
                safeReason: safeReason
            )
        )
        // runnerCallCount NOT incremented — cancel terminates before runner.
        return DemoSliceRouteResult(
            classification: classification,
            readOnly: DemoSliceReadOnlyOutcome(
                classification: classification,
                payload: payload,
                runnerCallCount: runnerCallCount
            )
        )
    }

    private func routeCommand(
        admission: DemoSliceAdmission,
        classification: DemoSliceClassification,
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider?,
        lease: RuntimeTurnLease?
    ) async throws -> DemoSliceRouteResult {
        // Reuse the same scope resolution as C3. Defaulted scopes (for example,
        // ac.temp_setpoint[主驾]) must not miss the pre-run no-op gate.
        let projection = try DemoSliceAdmissionCatalog.targetProjection(
            for: admission,
            stateCells: stateCells
        )
        // row167 projection already includes ac.power; other ac_temperature
        // frames still require the implicit power gate.
        let isRow167 = admission.entry.contractRowID == "c1_airControl_000167"
        let implicitPowerTargetSatisfied =
            isRow167
            || admission.frame.device != "ac_temperature"
            || admission.frame.actionPrimitive == "query"
            || admission.frame.doNotAutoPowerOn
            || store.cell(for: "ac.power")?.actualValue == "on"

        let allTargetsSatisfied = projection.allSatisfy { target in
            store.cell(for: target.key)?.actualValue == target.desired
        }

        if implicitPowerTargetSatisfied, allTargetsSatisfied {
            // Already at target state: short-circuit before runner, no mutation, no TTS
            let traceID = UUID().uuidString
            let readbacks = projection.compactMap { target -> DemoActionReadback? in
                guard let cell = store.cell(for: target.key) else { return nil }
                return DemoActionReadback(
                    key: cell.key,
                    actualValue: cell.actualValue,
                    revision: cell.revision,
                    spokenText: DemoVehicleStateStore.spokenText(for: cell)
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
                classification: classification,
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
            payload = try await runner.run(
                text: text,
                correlationProvider: correlationProvider,
                lease: lease
            )
        } else {
            payload = try await runner.run(text: text, lease: lease)
        }
        if payload.outcome.result == .acceptedToolCall, let lease {
            lastCommittedTurn = RuntimeTurnIdentity(lease)
        }
        return DemoSliceRouteResult(
            classification: classification,
            execution: DemoSliceExecution(
                admission: admission,
                payload: payload,
                runnerCallCount: runnerCallCount
            )
        )
    }

    private func routeStateQuery(
        spec: StateQuerySpec,
        classification: DemoSliceClassification
    ) throws -> DemoSliceRouteResult {
        guard let definition = stateCells.cell(id: spec.stateBase) else {
            throw ToolExecutionError.semanticInvalid("state_cell_not_found")
        }
        let scope = spec.scopeHint ?? definition.defaultScope
        let key: String
        if let scope, !definition.scope.isEmpty {
            key = "\(spec.stateBase)[\(scope)]"
        } else {
            key = spec.stateBase
        }
        guard let cell = store.cell(for: key) else {
            throw ToolExecutionError.semanticInvalid("state_cell_missing_in_store")
        }
        let readback = DemoActionReadback(
            key: cell.key,
            actualValue: cell.actualValue,
            revision: cell.revision,
            spokenText: DemoVehicleStateStore.spokenText(for: cell)
        )
        let traceID = UUID().uuidString
        let snapshot = PresentationSnapshot(
            traceID: traceID,
            runtimeOutcome: DemoRuntimeOutcome(
                result: .noAction,
                reason: "state_query"
            ),
            cards: store.presentationCells,
            readbacks: [readback],
            voiceState: .idle,
            orbState: .idle,
            mutationCount: 0,
            proofClass: .localUnit,
            isTerminal: true
        )
        let payload = RuntimePresentationPayload(
            snapshot: snapshot,
            turnID: traceID,
            eventID: "\(traceID):state-query",
            reconciliation: PresentationReconciliation(
                status: .verified,
                readbackKey: readback.key,
                safeReason: "state_query"
            )
        )
        return DemoSliceRouteResult(
            classification: classification,
            readOnly: DemoSliceReadOnlyOutcome(
                classification: classification,
                payload: payload,
                runnerCallCount: runnerCallCount
            )
        )
    }

    private func routeCapabilityQuery(
        spec: CapabilityQuerySpec,
        classification: DemoSliceClassification
    ) throws -> DemoSliceRouteResult {
        guard let definition = stateCells.cell(id: spec.stateBase) else {
            throw ToolExecutionError.semanticInvalid("state_cell_not_found")
        }
        guard let range = definition.executionRange else {
            throw ToolExecutionError.semanticInvalid("capability_range_missing")
        }
        let unit = definition.unit ?? "celsius"
        let evidence = "\(spec.stateBase):\(range.min)...\(range.max) step=\(range.step) unit=\(unit)"
        let digest = C6Hash.sha256Hex(Data(evidence.utf8))
        let traceID = UUID().uuidString
        let snapshot = PresentationSnapshot(
            traceID: traceID,
            runtimeOutcome: DemoRuntimeOutcome(
                result: .noAction,
                reason: "capability_query"
            ),
            cards: store.presentationCells,
            readbacks: [],
            voiceState: .idle,
            orbState: .idle,
            proofClass: .localUnit,
            isTerminal: true
        )
        let payload = RuntimePresentationPayload(
            snapshot: snapshot,
            turnID: traceID,
            eventID: "\(traceID):capability-query",
            reconciliation: PresentationReconciliation(
                status: .verified,
                readbackKey: nil,
                safeReason: "capability_query:\(digest)"
            )
        )
        return DemoSliceRouteResult(
            classification: classification,
            readOnly: DemoSliceReadOnlyOutcome(
                classification: classification,
                payload: payload,
                runnerCallCount: runnerCallCount
            )
        )
    }
}
