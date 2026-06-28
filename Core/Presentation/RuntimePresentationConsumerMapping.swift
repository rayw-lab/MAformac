import Foundation

enum RuntimePresentationConsumerDisposition: String, Equatable, Sendable {
    case consumesStableMainlineName = "consumes_stable_mainline_name"
    case localPolicyOnly = "local_policy_only"
    case deferredMainlineOwner = "deferred_mainline_owner"
    case spikeBeforeImplementation = "spike_before_implementation"
}

struct RuntimePresentationResultConsumerEntry: Equatable, Sendable {
    let mainlineResultName: String
    let uiueResultKind: DemoRuntimeResultKind
    let visualState: DemoVisualState
    let motionKind: PresentationMotionKind
    let structuredSource: String
    let note: String
}

struct RuntimePresentationRowDisposition: Equatable, Sendable {
    let rowID: String
    let disposition: RuntimePresentationConsumerDisposition
    let owner: String
    let note: String
}

enum RuntimePresentationConsumerMapping {
    static let stableMainlineEventKinds = [
        "text_input",
        "mic_start",
        "mic_end",
        "card_tap",
        "cancel",
        "interruption"
    ]

    static let stableMainlineEventSources = [
        "user",
        "system",
        "demo_harness",
        "runtime_adapter"
    ]

    static let proofCaps = [
        "docs_local",
        "local_unit",
        "simulator_mock"
    ]

    static let terminalStopResultNames: [String: String] = [
        "cancelled": "cancelled",
        "interrupted": "interrupted",
        "backgrounding": "interrupted",
        "timeout": "runtime_error"
    ]

    static let resultEntries: [RuntimePresentationResultConsumerEntry] = [
        resultEntry("accepted_tool_call", localKind: .acceptedToolCall),
        resultEntry("clarify_missing_slot", localKind: .clarifyMissingSlot),
        resultEntry("refusal_no_available_tool", localKind: .refusalNoAvailableTool),
        resultEntry("refusal_safety_or_policy", localKind: .refusalSafetyOrPolicy),
        resultEntry("already_state_noop", localKind: .alreadyStateNoop),
        resultEntry("runtime_error", localKind: .runtimeError),
        resultEntry("cancelled", localKind: .cancelled),
        resultEntry(
            "interrupted",
            localKind: .cancelled,
            note: "UIUE renders the interruption terminal result with the existing cancelled visual surface while preserving the source result name."
        )
    ]

    static let rowDispositions: [RuntimePresentationRowDisposition] = [
        RuntimePresentationRowDisposition(
            rowID: "C034",
            disposition: .localPolicyOnly,
            owner: "UIUE",
            note: "Reduce Motion remains a UIUE presentation policy backed by local unit tests, not runtime proof."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C155",
            disposition: .localPolicyOnly,
            owner: "UIUE",
            note: "Accepted customer-facing policy wording only; no shared field or runtime payload is introduced."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C172",
            disposition: .localPolicyOnly,
            owner: "UIUE",
            note: "Accepted customer-facing policy wording only; no shared field or runtime payload is introduced."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C194",
            disposition: .localPolicyOnly,
            owner: "UIUE",
            note: "Accepted customer-facing policy wording only; no shared field or runtime payload is introduced."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C005",
            disposition: .deferredMainlineOwner,
            owner: "mainline runtime adapter",
            note: "Runtime write ownership is not proven by UIUE consumer mapping."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C018",
            disposition: .deferredMainlineOwner,
            owner: "mainline Core config",
            note: "SceneMacroRegistry/Core config is not consumed as hidden UIUE shared authority."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C052",
            disposition: .deferredMainlineOwner,
            owner: "mainline force-state lane",
            note: "Force-state behavior is not implemented or promoted by UIUE."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C061",
            disposition: .deferredMainlineOwner,
            owner: "mainline runtime adapter",
            note: "Retry/idempotency/no-double-write remains future execution proof."
        ),
        RuntimePresentationRowDisposition(
            rowID: "C082",
            disposition: .spikeBeforeImplementation,
            owner: "future spike",
            note: "K1 ledger row only."
        ),
        RuntimePresentationRowDisposition(rowID: "C083", disposition: .spikeBeforeImplementation, owner: "future spike", note: "K1 ledger row only."),
        RuntimePresentationRowDisposition(rowID: "C096", disposition: .spikeBeforeImplementation, owner: "future spike", note: "K1 ledger row only."),
        RuntimePresentationRowDisposition(rowID: "C117", disposition: .spikeBeforeImplementation, owner: "future spike", note: "K1 ledger row only."),
        RuntimePresentationRowDisposition(rowID: "C182", disposition: .spikeBeforeImplementation, owner: "future spike", note: "K1 ledger row only."),
        RuntimePresentationRowDisposition(rowID: "C197", disposition: .spikeBeforeImplementation, owner: "future spike", note: "K1 ledger row only."),
        RuntimePresentationRowDisposition(rowID: "C207", disposition: .spikeBeforeImplementation, owner: "future spike", note: "K1 ledger row only."),
        RuntimePresentationRowDisposition(rowID: "C208", disposition: .spikeBeforeImplementation, owner: "future spike", note: "K1 ledger row only.")
    ]

    static func localResultKind(forMainlineResultName name: String) -> DemoRuntimeResultKind? {
        resultEntries.first { $0.mainlineResultName == name }?.uiueResultKind
    }

    static func disposition(for rowID: String) -> RuntimePresentationRowDisposition? {
        rowDispositions.first { $0.rowID == rowID }
    }

    private static func resultEntry(
        _ mainlineResultName: String,
        localKind: DemoRuntimeResultKind,
        note: String = "Direct UIUE visual projection from the stable mainline result name."
    ) -> RuntimePresentationResultConsumerEntry {
        let presentation = DemoRuntimeResultPresentationMatrix.entry(for: localKind)
        return RuntimePresentationResultConsumerEntry(
            mainlineResultName: mainlineResultName,
            uiueResultKind: localKind,
            visualState: presentation.visualState,
            motionKind: presentation.motionKind,
            structuredSource: "mainline_structured_runtime_result",
            note: note
        )
    }
}
