import Foundation

@MainActor
public final class DemoRuntimeSessionRunner {
    public typealias FrameDecoder = (String) throws -> ToolCallFrame

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
        speech: any SpeechSynthesisEngine
    ) throws -> DemoRuntimeSessionRunner {
        let bundle = DemoRuntimeContractBundle.singleCommandDemoDefault
        return DemoRuntimeSessionRunner(
            store: store,
            pipeline: try bundle.makePipeline(),
            traceLogger: traceLogger,
            speech: speech
        )
    }

    @discardableResult
    public func run(text: String) async throws -> RuntimePresentationPayload {
        var frame = try frameDecoder(text)
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

    private func traceEnvelopeForCurrentTurn(traceID: String) -> TraceEnvelope? {
        guard let inMemory = traceLogger as? InMemoryTraceLogger else {
            return nil
        }
        let entries = inMemory.entries.filter { $0.traceID == traceID }
        return TraceEnvelope(traceID: traceID, entries: entries)
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
        """,
        stateCellsYAML: """
        cells:
          - id: ac.power
            type: enum
            values: [off, on]
            default: off
            readback_zh: 空调{已关闭|已打开}
        """,
        riskPolicyYAML: """
        forbidden:
        """,
        allowlistYAML: """
        allowlist:
        """
    )
}
