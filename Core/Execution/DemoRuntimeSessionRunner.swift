import Foundation

@MainActor
public final class DemoRuntimeSessionRunner {
    public typealias FrameDecoder = (String) async throws -> ToolCallFrame

    private let store: DemoVehicleStateStore
    private let pipeline: C3ExecutionPipeline
    private let traceLogger: any TraceLogger
    private let speech: any SpeechSynthesisEngine
    private let frameDecoder: FrameDecoder
    private let alignsFrameStateRevisionToStore: Bool
    private let timestampProvider: () -> Date

    public init(
        store: DemoVehicleStateStore,
        pipeline: C3ExecutionPipeline,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine,
        frameDecoder: @escaping FrameDecoder = { try FastPathIntentEngine().decode($0) },
        alignsFrameStateRevisionToStore: Bool = true,
        timestampProvider: @escaping () -> Date = Date.init
    ) {
        self.store = store
        self.pipeline = pipeline
        self.traceLogger = traceLogger
        self.speech = speech
        self.frameDecoder = frameDecoder
        self.alignsFrameStateRevisionToStore = alignsFrameStateRevisionToStore
        self.timestampProvider = timestampProvider
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
            frameDecoder: { text in try await router.decode(text: text) }
        )
    }

    @discardableResult
    public func run(text: String) async throws -> RuntimePresentationPayload {
        let frameResult: ToolCallFrame
        do {
            frameResult = try await frameDecoder(text)
        } catch let failure as DDomainToolPlanFailure {
            return unsupportedPayload(finiteReason: failure.finiteReason)
        } catch FastPathIntentError.noMatch {
            return unsupportedPayload(finiteReason: "fast_path_no_match")
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
        if !dialogText.isEmpty {
            speech.speak(dialogText)
        }

        let traceEnvelope = traceEnvelopeForCurrentTurn(traceID: result.traceID)
        let snapshot = PresentationSnapshot(
            traceID: result.traceID,
            runtimeOutcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: "readback_verified"),
            cards: cards,
            cardSemantics: semantics,
            dialogText: dialogText.isEmpty ? nil : dialogText,
            readbacks: result.readbacks,
            scopeOrigin: result.readbacks.compactMap(\.scopeOrigin).first,
            voiceState: dialogText.isEmpty ? .idle : .speak,
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

    private func unsupportedPayload(finiteReason: String) -> RuntimePresentationPayload {
        let traceID = UUID().uuidString
        let turnID = "unsupported-\(traceID)"
        let dialogText = "这个我先记下来，稍后帮您处理"
        traceLogger.recordGuard(
            traceID: traceID,
            message: "unsupported_tool_plan",
            attributes: TraceAttributes(
                guardReason: "unsupported_tool_plan",
                finiteReason: finiteReason
            )
        )
        speech.speak(dialogText)
        let traceEnvelope = traceEnvelopeForCurrentTurn(traceID: traceID)
        return RuntimePresentationPayload(
            traceID: traceID,
            turnID: turnID,
            eventID: "\(turnID):runtime-presentation",
            isTerminal: true,
            outcome: DemoRuntimeOutcome(result: .refusalNoAvailableTool, reason: finiteReason),
            proofClass: .localUnit,
            cards: store.presentationCells,
            readbacks: [],
            reconciliation: PresentationReconciliation(
                status: .notApplicable,
                safeReason: finiteReason
            ),
            traceEnvelope: traceEnvelope,
            timestamp: timestampProvider()
        )
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

    public static let singleCommandDemoDefault = DemoRuntimeContractBundle(
        semanticJSONL: """
        {"contract_row_id":"runtime_app_ac_power_on","device":"ac","action_primitive":"power_on","slot":"device","slot_keys":[],"clarify_tag":"explicit","risk":"","exec_tier":"L1","execution_range_ref":"ac.power","value":{"ref":"","direct":"","offset":"on","type":"STATE"}}
        {"contract_row_id":"runtime_app_ac_temperature_adjust_to_number","device":"ac_temperature","action_primitive":"adjust_to_number","slot":"temperature","slot_keys":[],"clarify_tag":"explicit","risk":"","exec_tier":"L1","execution_range_ref":"ac.temp_setpoint","value":{"ref":"","direct":"","offset":"","type":""}}
        """,
        stateCellsYAML: """
        cells:
          - id: ac.power
            type: enum
            values: [off, on]
            default: off
            readback_zh: 空调{已关闭|已打开}
          - id: ac.temp_setpoint
            type: int
            unit: celsius
            scope: [主驾, 副驾, 左后, 右后, 全车]
            default_scope: 主驾
            execution_range: {min: 18, max: 32, step: 1}
            default: 24
            readback_zh: "{温区}空调温度{值}度"
        """,
        riskPolicyYAML: """
        forbidden:
        """,
        allowlistYAML: """
        allowlist:
        """
    )
}
