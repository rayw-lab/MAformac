import Foundation

public enum DemoRuntimeSessionRunnerError: Error, Equatable {
    case multiFramePlanRequiresPartialExecution(frameIDs: [String])
}

/// D1 wire producer contract: given the accepted `ToolCallFrame` of a turn,
/// return a `RouteToDialogueCorrelation` binding W6 route identity
/// (`RouteTurnIdentifier` / `RouteTraceIdentifier`) with W7 dialogue group
/// identity (`DialogueSourceGroupRef`). Returning `nil` opts the turn out
/// of typed-facts recording without failing the run.
///
/// The producer must fully construct a schema-supported correlation — the
/// downstream reducer (`DialogueState.recordTypedFacts`) will fail-closed on
/// unsupported schema versions, missing identity fields, or version mismatch.
/// See `~/.claude/rules/claim-vs-reality-gap.md` 铁律 1 (enforce, not declare).
public struct RuntimeSessionCorrelationProvider {
    public let makeCorrelation: @MainActor (_ frame: ToolCallFrame, _ traceID: String) -> RouteToDialogueCorrelation?

    public init(
        _ makeCorrelation: @escaping @MainActor (_ frame: ToolCallFrame, _ traceID: String) -> RouteToDialogueCorrelation?
    ) {
        self.makeCorrelation = makeCorrelation
    }
}

/// Fail-closed diagnostic when the D1 wire reducer refuses a typed-facts batch.
/// Emitted via the trace logger's guard channel so operators can distinguish
/// "silently no-op'd" (provider returned nil) from "reducer refused" (correlation
/// was invalid at the schema/validator boundary).
public struct DemoRuntimeTypedFactsRecordDiagnostic: Equatable, Sendable {
    public let traceID: String
    public let reason: String

    public init(traceID: String, reason: String) {
        self.traceID = traceID
        self.reason = reason
    }
}

@MainActor
public final class DemoRuntimeSessionRunner {
    public typealias FrameDecoder = (String) async throws -> ToolCallFrame
    public typealias PlanDecoder = (String) async throws -> [ToolCallFrame]

    private let store: DemoVehicleStateStore
    private let pipeline: C3ExecutionPipeline
    private let traceLogger: any TraceLogger
    private let speech: any SpeechSynthesisEngine
    private let planDecoder: PlanDecoder
    private let alignsFrameStateRevisionToStore: Bool
    private let timestampProvider: () -> Date
    private var dialogueState: DialogueState
    private let correlationProvider: RuntimeSessionCorrelationProvider?

    /// Last typed-facts reducer outcome for the most recent completed turn.
    /// Nil when the current runner has no correlation provider or the turn
    /// produced no readback (readback-less refusal path). Test surface only.
    public private(set) var lastTypedFactsRecordResult: DialogueTypedFactsRecordResult?
    /// Last typed-facts refusal diagnostic (reducer said `.deniedContextInvalid`).
    /// Nil when the most recent typed-facts attempt was accepted or absent.
    public private(set) var lastTypedFactsRefusal: DemoRuntimeTypedFactsRecordDiagnostic?

    public init(
        store: DemoVehicleStateStore,
        pipeline: C3ExecutionPipeline,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine,
        frameDecoder: @escaping FrameDecoder = { try FastPathIntentEngine().decode($0) },
        alignsFrameStateRevisionToStore: Bool = true,
        dialogueState: DialogueState = DialogueState(),
        timestampProvider: @escaping () -> Date = Date.init,
        correlationProvider: RuntimeSessionCorrelationProvider? = nil
    ) {
        self.store = store
        self.pipeline = pipeline
        self.traceLogger = traceLogger
        self.speech = speech
        self.planDecoder = { text in [try await frameDecoder(text)] }
        self.alignsFrameStateRevisionToStore = alignsFrameStateRevisionToStore
        self.dialogueState = dialogueState
        self.timestampProvider = timestampProvider
        self.correlationProvider = correlationProvider
    }

    public init(
        store: DemoVehicleStateStore,
        pipeline: C3ExecutionPipeline,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine,
        planDecoder: @escaping PlanDecoder,
        alignsFrameStateRevisionToStore: Bool = true,
        dialogueState: DialogueState = DialogueState(),
        timestampProvider: @escaping () -> Date = Date.init,
        correlationProvider: RuntimeSessionCorrelationProvider? = nil
    ) {
        self.store = store
        self.pipeline = pipeline
        self.traceLogger = traceLogger
        self.speech = speech
        self.planDecoder = planDecoder
        self.alignsFrameStateRevisionToStore = alignsFrameStateRevisionToStore
        self.dialogueState = dialogueState
        self.timestampProvider = timestampProvider
        self.correlationProvider = correlationProvider
    }

    public static func defaultRunner(
        store: DemoVehicleStateStore,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine,
        modelBackend: any LLMBackend = FastPathDemoToolPlanBackend()
    ) throws -> DemoRuntimeSessionRunner {
        let bundle = DemoRuntimeContractBundle.singleCommandDemoDefault
        let router = DemoNLURouter(backend: modelBackend)
        return DemoRuntimeSessionRunner(
            store: store,
            pipeline: try bundle.makePipeline(),
            traceLogger: traceLogger,
            speech: speech,
            planDecoder: { text in try await router.decodePlan(text: text) }
        )
    }

    /// Unit/default helper surface. Uses the optional constructor-bound provider
    /// (typically `nil`). Not the App production surface.
    @discardableResult
    public func run(text: String) async throws -> RuntimePresentationPayload {
        try await executeRun(text: text, correlationProvider: correlationProvider)
    }

    /// App production surface: per-call non-optional correlation provider.
    /// The provider is selected for this invocation only and threaded to every
    /// normal/partial `consumeTypedFactsIfWired` call — no shared mutable override.
    @discardableResult
    public func run(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider
    ) async throws -> RuntimePresentationPayload {
        try await executeRun(text: text, correlationProvider: correlationProvider)
    }

    private func executeRun(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider?
    ) async throws -> RuntimePresentationPayload {
        dialogueState.recordUserText(text)
        let frameResults: [ToolCallFrame]
        do {
            frameResults = try await planDecoder(text)
        } catch let failure as DDomainToolPlanFailure {
            return unsupportedPayload(
                finiteReason: failure.finiteReason,
                decodeFailureKind: failure.decodeFailureKind
            )
        } catch FastPathIntentError.noMatch {
            return unsupportedPayload(finiteReason: .fastPathNoMatch)
        }

        guard let frameResult = frameResults.first else {
            throw DemoNLURouterError.noToolPlanFrames
        }
        if frameResults.count > 1 {
            guard frameResults.allSatisfy(DemoRuntimePartialPlan.isReviewed) else {
                let traceID = frameResults.first?.traceID ?? UUID().uuidString
                traceLogger.recordGuard(
                    traceID: traceID,
                    message: "multi_frame_plan_rejected",
                    attributes: TraceAttributes(
                        toolCallCount: 0,
                        guardReason: "multi_frame_plan_requires_partial_execution"
                    )
                )
                throw DemoRuntimeSessionRunnerError.multiFramePlanRequiresPartialExecution(
                    frameIDs: frameResults.map(\.id)
                )
            }
            let partialResult = try DemoRuntimePartialPlan().execute(
                frames: frameResults,
                store: store,
                pipeline: pipeline,
                traceLogger: traceLogger,
                alignsFrameStateRevisionToStore: alignsFrameStateRevisionToStore
            )

            let acceptedReadbacks = partialResult.acceptedReadbacks
            let acceptedCards = PresentationCardOrdering.orderedForPresentation(
                acceptedReadbacks.compactMap { readback in store.cell(for: readback.key) }
            )
            let framesByID = Dictionary(uniqueKeysWithValues: frameResults.map { ($0.id, $0) })
            let refusedCardsBySubactionID: [String: DemoVehicleStateCell] = Dictionary(
                uniqueKeysWithValues: partialResult.subactions.compactMap { subaction in
                    guard subaction.disposition == .refused,
                          let frame = framesByID[subaction.frameID],
                          let executionCellID = pipeline.allowlist.entry(device: frame.device)?.executionRangeCell
                              ?? ToolContractStateApplier.deviceCellMap[frame.device] else {
                        return nil
                    }

                    let definition = pipeline.stateCells.cell(id: executionCellID)
                    let resolvedKey = definition.flatMap { definition in
                        try? C2ScopeResolver.resolve(frame: frame, cell: definition).keys.first
                    }
                    let explicitlyScopedKey = C2ScopeResolver.requestedScope(from: frame).map {
                        "\(executionCellID)[\($0)]"
                    }
                    let card = [resolvedKey, explicitlyScopedKey, executionCellID]
                        .compactMap { $0 }
                        .compactMap { store.cell(for: $0) }
                        .first
                        ?? store.cells.first { ScopedStateKey($0.key).base == executionCellID }
                        ?? definition.map {
                            DemoVehicleStateCell(
                                key: resolvedKey ?? executionCellID,
                                actualValue: $0.defaultValue ?? "unknown",
                                availability: .unknown
                            )
                        }
                    guard let card else {
                        return nil
                    }
                    return (subaction.frameID, card)
                }
            )
            let dialogText = acceptedReadbacks.map(\.spokenText).joined(separator: "；")
            let partialSpeechDidEnqueue = speakAcceptedDialogText(
                dialogText,
                traceID: partialResult.traceID
            )
            if !dialogText.isEmpty {
                dialogueState.recordAssistantText(dialogText)
                dialogueState.recordReadbacks(acceptedReadbacks)
                consumeTypedFactsIfWired(
                    frame: frameResult,
                    traceID: partialResult.traceID,
                    correlationProvider: correlationProvider
                )
            }

            let traceEnvelope = traceEnvelopeForCurrentTurn(traceID: partialResult.traceID)
            if partialResult.hasAccepted && partialResult.hasRefused {
                let snapshot = try RuntimePresentationTerminalSnapshotAdapter.partialAcceptRefuse(
                    executionResult: partialResult,
                    acceptedCards: acceptedCards,
                    refusedCardsBySubactionID: refusedCardsBySubactionID,
                    traceEnvelope: traceEnvelope,
                    timestamp: timestampProvider()
                )
                return RuntimePresentationPayload(
                    snapshot: snapshot,
                    turnID: frameResult.id,
                    eventID: "\(frameResult.id):runtime-presentation",
                    reconciliation: PresentationReconciliation(
                        status: .verified,
                        readbackKey: acceptedReadbacks.last?.key,
                        safeReason: "partial_readback_verified"
                    )
                )
            }

            if partialResult.hasAccepted {
                let semantics = acceptedCards.map { cell in
                    PresentationCardSemantics(
                        cellKey: cell.key,
                        role: .accepted,
                        scopeOrigin: acceptedReadbacks.first { $0.key == cell.key }?.scopeOrigin,
                        reason: "readback_verified",
                        isActive: true
                    )
                }
                // Visual-first: keep orb/dialog; freeze Core voice to .idle when
                // synthesis failed or speech text empty (AD-7 / S5 — never invent .speak).
                let coreVoiceState = Self.coreVoiceDisplayState(
                    dialogText: dialogText,
                    speechDidEnqueue: partialSpeechDidEnqueue
                )
                let snapshot = PresentationSnapshot(
                    traceID: partialResult.traceID,
                    runtimeOutcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: "readback_verified"),
                    cards: acceptedCards,
                    cardSemantics: semantics,
                    dialogText: dialogText.isEmpty ? nil : dialogText,
                    readbacks: acceptedReadbacks,
                    scopeOrigin: acceptedReadbacks.compactMap(\.scopeOrigin).first,
                    voiceState: coreVoiceState,
                    orbState: dialogText.isEmpty ? .idle : .speak,
                    proofClass: .localUnit,
                    traceEnvelope: traceEnvelope,
                    isTerminal: true,
                    timestamp: timestampProvider()
                )
                return RuntimePresentationPayload(
                    snapshot: snapshot,
                    turnID: frameResult.id,
                    eventID: "\(frameResult.id):runtime-presentation",
                    reconciliation: PresentationReconciliation(
                        status: .verified,
                        readbackKey: acceptedReadbacks.last?.key,
                        safeReason: "c2_readback_verified"
                    )
                )
            }

            let finiteReasons = partialResult.subactions.compactMap(\.finiteReason)
            let sharedFiniteReason = Set(finiteReasons).count == 1 ? finiteReasons[0] : nil
            let projection = sharedFiniteReason.map(RuntimePresentationReasonAuthority.projection(for:))
            let refusalReason = projection?.safeReasonKind.rawValue
                ?? RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue
            let refusalResult = projection?.result ?? .refusalNoAvailableTool
            let snapshot = PresentationSnapshot(
                traceID: partialResult.traceID,
                runtimeOutcome: DemoRuntimeOutcome(result: refusalResult, reason: refusalReason),
                cards: store.presentationCells,
                proofClass: .localUnit,
                traceEnvelope: traceEnvelope,
                isTerminal: true,
                timestamp: timestampProvider()
            )
            return RuntimePresentationPayload(
                snapshot: snapshot,
                turnID: frameResult.id,
                eventID: "\(frameResult.id):runtime-presentation",
                reconciliation: PresentationReconciliation(
                    status: .notApplicable,
                    safeReason: refusalReason
                )
             )
        }

        var frame = frameResult
        recordProjectionTraceIfNeeded(for: frame)
        if alignsFrameStateRevisionToStore {
            frame.stateRevision = store.currentRevision
        }

        let result = try pipeline.execute(frame, store: store, traceLogger: traceLogger)
        let cards = PresentationCardOrdering.orderedForPresentation(
            result.readbacks.compactMap { store.cell(for: $0.key) }
        )
        let semantics = cards.map { cell in
            PresentationCardSemantics(
                cellKey: cell.key,
                role: .accepted,
                scopeOrigin: result.readbacks.first { $0.key == cell.key }?.scopeOrigin,
                reason: "readback_verified",
                isActive: true
            )
        }
        let dialogText = result.readbacks.map(\.spokenText).joined(separator: "；")
        let fullSpeechDidEnqueue = speakAcceptedDialogText(
            dialogText,
            traceID: result.traceID
        )
        if !dialogText.isEmpty {
            dialogueState.recordAssistantText(dialogText)
            dialogueState.recordReadbacks(result.readbacks)
            consumeTypedFactsIfWired(
                frame: frame,
                traceID: result.traceID,
                correlationProvider: correlationProvider
            )
        }

        let traceEnvelope = traceEnvelopeForCurrentTurn(traceID: result.traceID)
        // Visual-first: keep orb/dialog; freeze Core voice to .idle when
        // synthesis failed or speech text empty (AD-7 / S5 — never invent .speak).
        let coreVoiceState = Self.coreVoiceDisplayState(
            dialogText: dialogText,
            speechDidEnqueue: fullSpeechDidEnqueue
        )
        let snapshot = PresentationSnapshot(
            traceID: result.traceID,
            runtimeOutcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: "readback_verified"),
            cards: cards,
            cardSemantics: semantics,
            dialogText: dialogText.isEmpty ? nil : dialogText,
            readbacks: result.readbacks,
            scopeOrigin: result.readbacks.compactMap(\.scopeOrigin).first,
            voiceState: coreVoiceState,
            orbState: dialogText.isEmpty ? .idle : .speak,
            proofClass: .localUnit,
            traceEnvelope: traceEnvelope,
            isTerminal: true,
            timestamp: timestampProvider()
        )

        return RuntimePresentationPayload(
            snapshot: snapshot,
            turnID: frame.id,
            eventID: "\(frame.id):runtime-presentation",
            reconciliation: PresentationReconciliation(
                status: .verified,
                readbackKey: result.readbacks.last?.key,
                safeReason: "c2_readback_verified"
            )
        )
    }

    private func unsupportedPayload(
        finiteReason: RuntimeFiniteReason,
        decodeFailureKind: DDomainDecodeFailureKind? = nil
    ) -> RuntimePresentationPayload {
        let traceID = UUID().uuidString
        let turnID = "unsupported-\(traceID)"
        let userText = dialogueState.turns.last(where: { $0.role == .user })?.text
        let context = FallbackContext.resolve(userText: userText, finiteReason: finiteReason)
        dialogueState.recordAssistantText(context.dialogText)
        traceLogger.recordGuard(
            traceID: traceID,
            message: "unsupported_tool_plan",
            attributes: TraceAttributes(
                guardReason: "unsupported_tool_plan",
                finiteReason: finiteReason,
                decodeFailureKind: decodeFailureKind
            )
        )
        // Unsupported/fallback speech is fail-open visually, but must not invent
        // voice success when synthesis fails (AD-7 / S5).
        _ = speakAcceptedDialogText(context.ttsText, traceID: traceID)
        return RuntimePresentationPayload(
            traceID: traceID,
            turnID: turnID,
            eventID: "\(turnID):runtime-presentation",
            isTerminal: true,
            outcome: DemoRuntimeOutcome(
                result: context.runtimeResult,
                reason: context.outcome.safeReasonKind.rawValue
            ),
            proofClass: .localUnit,
            cards: store.presentationCells,
            readbacks: [],
            reconciliation: PresentationReconciliation(
                status: .notApplicable,
                safeReason: context.outcome.safeReasonKind.rawValue
            ),
            traceEnvelope: nil,
            timestamp: timestampProvider()
        )
    }

    /// Speak accepted/fallback dialog text. Returns whether synthesis enqueued.
    /// Empty text is a no-op and reports not enqueued so Core voice freezes idle.
    /// Synthesis failure is observable on the existing readback trace surface.
    @discardableResult
    private func speakAcceptedDialogText(_ dialogText: String, traceID: String) -> Bool {
        guard !dialogText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        let speechResult = speech.speak(dialogText)
        if !speechResult.didEnqueue {
            traceLogger.recordReadback(
                traceID: traceID,
                message: "tts_fail_open:\(speechResult.reason ?? "unknown")",
                attributes: TraceAttributes(readbackResult: .failed)
            )
            return false
        }
        return true
    }

    /// Core `PresentationVoiceDisplayState` for accepted payload construction.
    /// Synthesis failure / empty speech → `.idle` (never `.speak`).
    private static func coreVoiceDisplayState(
        dialogText: String,
        speechDidEnqueue: Bool
    ) -> PresentationVoiceDisplayState {
        if dialogText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .idle
        }
        return speechDidEnqueue ? .speak : .idle
    }

    public var currentDialogueState: DialogueState {
        dialogueState
    }

    /// D1 wire consumer. Called after `recordReadbacks` on both the partial-plan
    /// and single-frame paths. Fail-closed producer + reducer boundary:
    ///   - no provider  -> no-op, state hash unchanged (default runner path)
    ///   - provider returns nil                 -> tracked as "no correlation this turn",
    ///                                             typedFactsWindow unchanged
    ///   - provider returns invalid correlation -> reducer refuses, guard emitted
    ///                                             on the trace channel, window unchanged
    ///   - provider returns valid correlation   -> reducer appends, window bounded
    /// See `~/.claude/rules/claim-vs-reality-gap.md` 铁律 2 — deliberate negatives
    /// present downstream to prove the wire is not just "recorded a field".
    private func consumeTypedFactsIfWired(
        frame: ToolCallFrame,
        traceID: String,
        correlationProvider: RuntimeSessionCorrelationProvider?
    ) {
        guard let provider = correlationProvider else {
            lastTypedFactsRecordResult = nil
            lastTypedFactsRefusal = nil
            return
        }
        guard let correlation = provider.makeCorrelation(frame, traceID) else {
            lastTypedFactsRecordResult = .accepted(count: 0)
            lastTypedFactsRefusal = nil
            return
        }
        let result = dialogueState.recordTypedFacts([correlation])
        lastTypedFactsRecordResult = result
        switch result {
        case .accepted:
            lastTypedFactsRefusal = nil
        case .deniedContextInvalid(let reason):
            let diagnostic = DemoRuntimeTypedFactsRecordDiagnostic(
                traceID: traceID,
                reason: reason
            )
            lastTypedFactsRefusal = diagnostic
            traceLogger.recordGuard(
                traceID: traceID,
                message: "typed_facts_refused",
                attributes: TraceAttributes(
                    guardReason: "typed_facts_refused:\(reason)"
                )
            )
        }
    }

    private func recordProjectionTraceIfNeeded(for frame: ToolCallFrame) {
        guard rawPayloadBool(frame.rawPayload, key: "slot_projected") == true else {
            return
        }
        traceLogger.recordDecode(
            traceID: frame.traceID,
            message: "slot_projected",
            attributes: TraceAttributes(
                candidateSource: frame.candidateSource,
                rawPayloadHash: rawPayloadString(frame.rawPayload, key: "raw_arguments_sha256"),
                slotProjected: true
            )
        )
    }

    private func traceEnvelopeForCurrentTurn(traceID: String) -> TraceEnvelope? {
        guard let inMemory = traceLogger as? InMemoryTraceLogger else {
            return nil
        }
        let entries = inMemory.entries.filter { $0.traceID == traceID }
        return TraceEnvelope(traceID: traceID, entries: entries)
    }

    private func rawPayloadString(_ value: JSONValue, key: String) -> String? {
        guard case .object(let object) = value,
              case .string(let string)? = object[key] else {
            return nil
        }
        return string
    }

    private func rawPayloadBool(_ value: JSONValue, key: String) -> Bool? {
        guard case .object(let object) = value,
              case .bool(let bool)? = object[key] else {
            return nil
        }
        return bool
    }
}

public struct DemoRuntimeContractBundle: Sendable {
    public var semanticJSONL: String
    public var stateCellsYAML: String
    public var riskPolicyYAML: String
    public var allowlistYAML: String

    public init(
        semanticJSONL: String,
        stateCellsYAML: String,
        riskPolicyYAML: String,
        allowlistYAML: String
    ) {
        self.semanticJSONL = semanticJSONL
        self.stateCellsYAML = stateCellsYAML
        self.riskPolicyYAML = riskPolicyYAML
        self.allowlistYAML = allowlistYAML
    }

    public func makePipeline(intentConfirmed: @escaping @Sendable () -> Bool = { true }) throws -> C3ExecutionPipeline {
        C3ExecutionPipeline(
            semantic: try SemanticContractLookup(jsonl: semanticJSONL),
            stateCells: try StateCellContractLookup(yaml: stateCellsYAML),
            riskPolicy: try RiskPolicyLookup(yaml: riskPolicyYAML),
            allowlist: try L1DemoAllowlistLookup(yaml: allowlistYAML),
            intentConfirmed: intentConfirmed
        )
    }

    public static var singleCommandDemoDefault: DemoRuntimeContractBundle {
        DemoRuntimeContractBundleCatalog.generatedDefault
    }
}
