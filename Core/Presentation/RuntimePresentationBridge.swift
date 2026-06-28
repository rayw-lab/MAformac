import Foundation

public enum DemoInteractionEventKind: String, Codable, CaseIterable, Equatable, Sendable {
    case textInput = "text_input"
    case micStart = "mic_start"
    case micEnd = "mic_end"
    case cardTap = "card_tap"
    case cancel
    case interruption
}

public struct DemoInteractionEvent: Codable, Equatable, Sendable {
    public var eventID: String
    public var traceID: String?
    public var kind: DemoInteractionEventKind
    public var text: String?
    public var cardKey: String?
    public var timestamp: Date

    public init(
        eventID: String,
        traceID: String? = nil,
        kind: DemoInteractionEventKind,
        text: String? = nil,
        cardKey: String? = nil,
        timestamp: Date = Date()
    ) {
        self.eventID = eventID
        self.traceID = traceID
        self.kind = kind
        self.text = text
        self.cardKey = cardKey
        self.timestamp = timestamp
    }
}

public enum DemoRuntimeResult: String, Codable, CaseIterable, Equatable, Sendable {
    case acceptedToolCall = "accepted_tool_call"
    case clarifyMissingSlot = "clarify_missing_slot"
    case refusalNoAvailableTool = "refusal_no_available_tool"
    case refusalSafetyOrPolicy = "refusal_safety_or_policy"
    case alreadyStateNoop = "already_state_noop"
    case runtimeError = "runtime_error"
    case cancelled
    case interrupted

    public init(behaviorClass: VehicleToolBehaviorClass) {
        switch behaviorClass {
        case .toolCall:
            self = .acceptedToolCall
        case .clarifyMissingSlot:
            self = .clarifyMissingSlot
        case .refusalNoAvailableTool:
            self = .refusalNoAvailableTool
        case .refusalSafetyOrPolicy:
            self = .refusalSafetyOrPolicy
        case .alreadyStateNoop:
            self = .alreadyStateNoop
        }
    }
}

public struct DemoRuntimeOutcome: Codable, Equatable, Sendable {
    public var result: DemoRuntimeResult
    public var behaviorClassSource: VehicleToolBehaviorClass?
    public var reason: String?
    public var missingSlot: String?
    public var scopeFailureReason: String?

    public init(
        result: DemoRuntimeResult,
        behaviorClassSource: VehicleToolBehaviorClass? = nil,
        reason: String? = nil,
        missingSlot: String? = nil,
        scopeFailureReason: String? = nil
    ) {
        self.result = result
        self.behaviorClassSource = behaviorClassSource
        self.reason = reason
        self.missingSlot = missingSlot
        self.scopeFailureReason = scopeFailureReason
    }

    public init(
        behaviorClass: VehicleToolBehaviorClass,
        reason: String? = nil,
        missingSlot: String? = nil,
        scopeFailureReason: String? = nil
    ) {
        self.init(
            result: DemoRuntimeResult(behaviorClass: behaviorClass),
            behaviorClassSource: behaviorClass,
            reason: reason,
            missingSlot: missingSlot,
            scopeFailureReason: scopeFailureReason
        )
    }
}

public enum PresentationProofClass: String, Codable, CaseIterable, Equatable, Sendable {
    case docsLocal = "docs_local"
    case openspecContract = "openspec_contract"
    case localStaticContract = "local_static_contract"
    case localUnit = "local_unit"
    case localShapeNoModel = "local_shape_no_model"
    case localReceiptConsistency = "local_receipt_consistency"
    case simulatorMock = "simulator_mock"
    case externalGPTProReview = "external_gptpro_review"

    public var displayCaps: Set<PresentationReadinessClaim> {
        []
    }
}

public enum PresentationReadinessClaim: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case runtimeReady = "runtime_ready"
    case endpointReady = "endpoint_ready"
    case voiceReady = "voice_ready"
    case modelReady = "model_ready"
    case goldenReady = "golden_ready"
    case mobileReady = "mobile_ready"
    case trueDeviceReady = "true_device_ready"
    case c6Ready = "c6_ready"
    case vPass = "V-PASS"
    case sPass = "S-PASS"
    case uPass = "U-PASS"
}

public enum PresentationVoiceDisplayState: String, Codable, CaseIterable, Equatable, Sendable {
    case unavailable
    case idle
    case listen
    case speak
}

public enum PresentationOrbDisplayState: String, Codable, CaseIterable, Equatable, Sendable {
    case idle
    case think
    case listen
    case speak
}

public struct TraceEnvelope: Codable, Equatable, Sendable {
    public var traceID: String
    public var entries: [TraceEntry]

    public init(traceID: String, entries: [TraceEntry]) {
        self.traceID = traceID
        self.entries = entries
    }
}

public struct PresentationSnapshot: Codable, Equatable, Sendable {
    public var traceID: String
    public var runtimeOutcome: DemoRuntimeOutcome
    public var cards: [DemoVehicleStateCell]
    public var dialogText: String?
    public var readbacks: [DemoActionReadback]
    public var scopeOrigin: ScopeOrigin?
    public var scopeFailureReason: String?
    public var voiceState: PresentationVoiceDisplayState?
    public var orbState: PresentationOrbDisplayState?
    public var proofClass: PresentationProofClass
    public var traceEnvelope: TraceEnvelope?
    public var isTerminal: Bool
    public var timestamp: Date

    public init(
        traceID: String,
        runtimeOutcome: DemoRuntimeOutcome,
        cards: [DemoVehicleStateCell],
        dialogText: String? = nil,
        readbacks: [DemoActionReadback] = [],
        scopeOrigin: ScopeOrigin? = nil,
        scopeFailureReason: String? = nil,
        voiceState: PresentationVoiceDisplayState? = nil,
        orbState: PresentationOrbDisplayState? = nil,
        proofClass: PresentationProofClass,
        traceEnvelope: TraceEnvelope? = nil,
        isTerminal: Bool,
        timestamp: Date = Date()
    ) {
        self.traceID = traceID
        self.runtimeOutcome = runtimeOutcome
        self.cards = cards
        self.dialogText = dialogText
        self.readbacks = readbacks
        self.scopeOrigin = scopeOrigin
        self.scopeFailureReason = scopeFailureReason
        self.voiceState = voiceState
        self.orbState = orbState
        self.proofClass = proofClass
        self.traceEnvelope = traceEnvelope
        self.isTerminal = isTerminal
        self.timestamp = timestamp
    }
}
