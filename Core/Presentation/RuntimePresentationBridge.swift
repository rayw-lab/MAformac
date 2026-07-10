import Foundation

public enum DemoInteractionEventKind: String, Codable, CaseIterable, Equatable, Sendable {
    case textInput = "text_input"
    case micStart = "mic_start"
    case micEnd = "mic_end"
    case cardTap = "card_tap"
    case cancel
    case interruption
}

public enum DemoInteractionEventSource: String, Codable, CaseIterable, Equatable, Sendable {
    case user
    case system
    case demoHarness = "demo_harness"
    case runtimeAdapter = "runtime_adapter"
}

public struct DemoInteractionEvent: Codable, Equatable, Sendable {
    public var eventID: String
    public var traceID: String?
    public var kind: DemoInteractionEventKind
    public var source: DemoInteractionEventSource?
    public var text: String?
    public var cardKey: String?
    public var timestamp: Date

    public init(
        eventID: String,
        traceID: String? = nil,
        kind: DemoInteractionEventKind,
        source: DemoInteractionEventSource? = .user,
        text: String? = nil,
        cardKey: String? = nil,
        timestamp: Date = Date()
    ) {
        self.eventID = eventID
        self.traceID = traceID
        self.kind = kind
        self.source = source
        self.text = text
        self.cardKey = cardKey
        self.timestamp = timestamp
    }
}

public enum DemoRuntimeResult: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case acceptedToolCall = "accepted_tool_call"
    case clarifyMissingSlot = "clarify_missing_slot"
    case refusalNoAvailableTool = "refusal_no_available_tool"
    case refusalSafetyOrPolicy = "refusal_safety_or_policy"
    case alreadyStateNoop = "already_state_noop"
    case partialAcceptPartialRefuse = "partial_accept_partial_refuse"
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

private enum PresentationPayloadSanitizer {
    static let redactedTokens = [
        "DemoRuntimeAdapter",
        "RuntimeAdapterBox",
        "durableLedger",
        "persistentLedger",
        "adapterLedger",
        "local_durable_adapter_ledger",
        "requestFingerprint",
        "parentRequestFingerprint",
        "failureLedger",
        "successLedger",
        "settledParentPlan",
        "runtimeStore",
        "rawRuntimeStore",
        "rawModelOutput",
        "trainingReceipt"
    ]

    static func redacted(_ value: String, maxLength: Int = 160) -> String {
        var safeValue = value
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        for token in redactedTokens.sorted(by: { $0.count > $1.count }) where safeValue.range(of: token, options: options) != nil {
            safeValue = safeValue.replacingOccurrences(of: token, with: "[redacted]", options: options)
        }
        return String(safeValue.prefix(maxLength))
    }

    static func redactedOptional(_ value: String?, maxLength: Int = 160) -> String? {
        value.map { redacted($0, maxLength: maxLength) }
    }

    static func publicReason(_ value: String?, maxLength: Int = 160) -> String? {
        guard let value else { return nil }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let projection = RuntimePresentationReasonAuthority.projection(forFiniteReason: normalized) {
            return projection.safeReasonKind.rawValue
        }
        if let safeReasonKind = RuntimePresentationSafeReasonKind(rawValue: normalized) {
            return safeReasonKind.rawValue
        }
        return redacted(normalized, maxLength: maxLength)
    }

    static func publicPayloadReason(_ value: String?) -> String? {
        guard let value else { return nil }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let projection = RuntimePresentationReasonAuthority.projection(forFiniteReason: normalized) {
            return projection.safeReasonKind.rawValue
        }
        if let safeReasonKind = RuntimePresentationSafeReasonKind(rawValue: normalized) {
            return safeReasonKind.rawValue
        }
        if publicPayloadReasonPassthrough.contains(normalized) {
            return normalized
        }
        return RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue
    }

    private static let publicPayloadReasonPassthrough: Set<String> = [
        "backgrounding",
        "cancelled",
        "c2_readback_verified",
        "guard_denied",
        "interrupted",
        "missing_required_scope",
        "partial_accept_refuse",
        "partial_readback_verified",
        "readback_verified",
        "runtime_error",
        "timeout",
        "user_requested",
    ]
}

public struct TraceEnvelope: Codable, Equatable, Sendable {
    public let traceID: String
    public private(set) var entries: [TraceEntry]

    private enum CodingKeys: String, CodingKey {
        case traceID
        case entries
    }

    public init?(traceID: String, entries: [TraceEntry]) {
        guard TraceEnvelope.entriesAreValid(entries, traceID: traceID) else {
            return nil
        }
        self.traceID = traceID
        self.entries = entries
    }

    public init(validatedTraceID traceID: String, entries: [TraceEntry] = []) {
        precondition(TraceEnvelope.entriesAreValid(entries, traceID: traceID), "TraceEnvelope entries must match traceID and be monotonic")
        self.traceID = traceID
        self.entries = entries
    }

    public func appending(_ entry: TraceEntry) -> TraceEnvelope? {
        guard entry.traceID == traceID else {
            return nil
        }
        guard let previous = entries.last else {
            return TraceEnvelope(traceID: traceID, entries: [entry])
        }
        guard entry.timestamp >= previous.timestamp else {
            return nil
        }

        var newEntries = entries
        newEntries.append(entry)
        return TraceEnvelope(traceID: traceID, entries: newEntries)
    }

    public func presentationSafe(
        redactedTokens: [String] = [
            "DemoRuntimeAdapter",
            "RuntimeAdapterBox",
            "durableLedger",
            "persistentLedger",
            "adapterLedger",
            "local_durable_adapter_ledger",
            "requestFingerprint",
            "parentRequestFingerprint",
            "failureLedger",
            "successLedger",
            "settledParentPlan",
            "runtimeStore",
            "rawRuntimeStore",
            "rawModelOutput",
            "trainingReceipt"
        ],
        maxMessageLength: Int = 160
    ) -> TraceEnvelope {
        let safeTraceID = TraceAttributes.redacted(
            traceID,
            redactedTokens: redactedTokens,
            maxMessageLength: maxMessageLength
        )
        let safeEntries = entries.map { entry in
            var copy = entry
            copy.traceID = safeTraceID
            copy.runId = copy.runId.map {
                TraceAttributes.redacted($0, redactedTokens: redactedTokens, maxMessageLength: maxMessageLength)
            }
            copy.parentSpanId = copy.parentSpanId.map {
                TraceAttributes.redacted($0, redactedTokens: redactedTokens, maxMessageLength: maxMessageLength)
            }
            var message = copy.message
            let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            for token in redactedTokens.sorted(by: { $0.count > $1.count }) where message.range(of: token, options: options) != nil {
                message = message.replacingOccurrences(of: token, with: "[redacted]", options: options)
            }
            copy.message = String(message.prefix(maxMessageLength))
            copy.attributes = copy.attributes.presentationSafe(
                redactedTokens: redactedTokens,
                maxMessageLength: maxMessageLength
            )
            return copy
        }
        return TraceEnvelope(validatedTraceID: safeTraceID, entries: safeEntries)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let traceID = try container.decode(String.self, forKey: .traceID)
        let entries = try container.decode([TraceEntry].self, forKey: .entries)
        guard TraceEnvelope.entriesAreValid(entries, traceID: traceID) else {
            throw DecodingError.dataCorruptedError(
                forKey: .entries,
                in: container,
                debugDescription: "TraceEnvelope entries must match traceID and be monotonic"
            )
        }
        self.traceID = traceID
        self.entries = entries
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(traceID, forKey: .traceID)
        try container.encode(entries, forKey: .entries)
    }

    private static func entriesAreValid(_ entries: [TraceEntry], traceID: String) -> Bool {
        var previousTimestamp: Date?
        for entry in entries {
            guard entry.traceID == traceID else {
                return false
            }
            if let previousTimestamp, entry.timestamp < previousTimestamp {
                return false
            }
            previousTimestamp = entry.timestamp
        }
        return true
    }
}

public enum PresentationCardRole: String, Codable, CaseIterable, Equatable, Sendable {
    case primary
    case sibling
    case accepted
    case refused
    case context
}

public struct PresentationCardSemantics: Codable, Equatable, Sendable {
    public var cellKey: String
    public var role: PresentationCardRole
    public var scopeOrigin: ScopeOrigin?
    public var reason: String?
    public var isActive: Bool
    public var siblingKeys: [String]

    public init(
        cellKey: String,
        role: PresentationCardRole,
        scopeOrigin: ScopeOrigin? = nil,
        reason: String? = nil,
        isActive: Bool = false,
        siblingKeys: [String] = []
    ) {
        self.cellKey = cellKey
        self.role = role
        self.scopeOrigin = scopeOrigin
        self.reason = reason
        self.isActive = isActive
        self.siblingKeys = siblingKeys
    }
}

public enum PresentationCardOrdering {
    public static func orderedForPresentation(_ cells: [DemoVehicleStateCell]) -> [DemoVehicleStateCell] {
        cells.sorted { lhs, rhs in
            let lhsPriority = priority(for: lhs.visualState)
            let rhsPriority = priority(for: rhs.visualState)
            if lhsPriority == rhsPriority {
                return lhs.key < rhs.key
            }
            return lhsPriority < rhsPriority
        }
    }

    private static func priority(for visualState: DemoVisualState) -> Int {
        switch visualState {
        case .unsafe, .blocked_hard:
            0
        case .blocked_with_alternative:
            1
        case .changing:
            2
        case .satisfied:
            3
        case .normal:
            4
        case .unknown:
            5
        }
    }
}

public struct PresentationSnapshot: Codable, Equatable, Sendable {
    public var traceID: String
    public var runtimeOutcome: DemoRuntimeOutcome
    public var cards: [DemoVehicleStateCell]
    public var cardSemantics: [PresentationCardSemantics]?
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
        cardSemantics: [PresentationCardSemantics]? = nil,
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
        self.cardSemantics = cardSemantics
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

public enum RuntimePresentationPayloadSchema: String, Codable, CaseIterable, Equatable, Sendable {
    case v1 = "r5_runtime_presentation_payload_v1"
}

public enum PresentationReconciliationStatus: String, Codable, CaseIterable, Equatable, Sendable {
    case verified
    case mismatch
    case unavailable
    case notApplicable = "not_applicable"
}

public enum PresentationReconciliationMismatchClass: String, Codable, CaseIterable, Equatable, Sendable {
    case missingReadback = "missing_readback"
    case valueMismatch = "value_mismatch"
    case revisionRegression = "revision_regression"
    case scopeMismatch = "scope_mismatch"
    case unknown
}

public struct PresentationReconciliation: Codable, Equatable, Sendable {
    public var status: PresentationReconciliationStatus
    public var readbackKey: String?
    public var mismatchClass: PresentationReconciliationMismatchClass?
    public var safeReason: String?

    public init(
        status: PresentationReconciliationStatus,
        readbackKey: String? = nil,
        mismatchClass: PresentationReconciliationMismatchClass? = nil,
        safeReason: String? = nil
    ) {
        self.status = status
        self.readbackKey = readbackKey.map { PresentationPayloadSanitizer.redacted($0) }
        self.mismatchClass = mismatchClass
        self.safeReason = PresentationPayloadSanitizer.publicReason(safeReason)
    }
}

public struct RuntimePresentationPayload: Codable, Equatable, Sendable {
    public var schemaVersion: RuntimePresentationPayloadSchema
    public var traceID: String
    public var turnID: String
    public var eventID: String?
    public var isTerminal: Bool
    public var outcome: DemoRuntimeOutcome
    public var proofClass: PresentationProofClass
    public var cards: [DemoVehicleStateCell]
    public var cardSemantics: [PresentationCardSemantics]?
    public var readbacks: [DemoActionReadback]
    public var reconciliation: PresentationReconciliation
    public var traceEnvelope: TraceEnvelope?
    public var timestamp: Date

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case traceID
        case turnID
        case eventID
        case isTerminal
        case outcome
        case proofClass
        case cards
        case cardSemantics
        case readbacks
        case reconciliation
        case traceEnvelope
        case timestamp
    }

    public init(
        schemaVersion: RuntimePresentationPayloadSchema = .v1,
        traceID: String,
        turnID: String,
        eventID: String? = nil,
        isTerminal: Bool,
        outcome: DemoRuntimeOutcome,
        proofClass: PresentationProofClass,
        cards: [DemoVehicleStateCell],
        cardSemantics: [PresentationCardSemantics]? = nil,
        readbacks: [DemoActionReadback] = [],
        reconciliation: PresentationReconciliation,
        traceEnvelope: TraceEnvelope? = nil,
        timestamp: Date = Date()
    ) {
        self.schemaVersion = schemaVersion
        self.traceID = PresentationPayloadSanitizer.redacted(traceID)
        self.turnID = PresentationPayloadSanitizer.redacted(turnID)
        self.eventID = eventID.map { PresentationPayloadSanitizer.redacted($0) }
        self.isTerminal = isTerminal
        self.outcome = RuntimePresentationPayload.presentationSafe(outcome)
        self.proofClass = proofClass
        self.cards = cards.map(RuntimePresentationPayload.presentationSafe)
        self.cardSemantics = cardSemantics?.map(RuntimePresentationPayload.presentationSafe)
        self.readbacks = readbacks.map(RuntimePresentationPayload.presentationSafe)
        self.reconciliation = RuntimePresentationPayload.presentationSafe(reconciliation)
        self.traceEnvelope = traceEnvelope?.presentationSafe()
        self.timestamp = timestamp
    }

    public init(
        snapshot: PresentationSnapshot,
        turnID: String,
        eventID: String? = nil,
        reconciliation: PresentationReconciliation
    ) {
        self.init(
            traceID: snapshot.traceID,
            turnID: turnID,
            eventID: eventID,
            isTerminal: snapshot.isTerminal,
            outcome: snapshot.runtimeOutcome,
            proofClass: snapshot.proofClass,
            cards: snapshot.cards,
            cardSemantics: snapshot.cardSemantics,
            readbacks: snapshot.readbacks,
            reconciliation: reconciliation,
            traceEnvelope: snapshot.traceEnvelope,
            timestamp: snapshot.timestamp
        )
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            schemaVersion: try container.decode(RuntimePresentationPayloadSchema.self, forKey: .schemaVersion),
            traceID: try container.decode(String.self, forKey: .traceID),
            turnID: try container.decode(String.self, forKey: .turnID),
            eventID: try container.decodeIfPresent(String.self, forKey: .eventID),
            isTerminal: try container.decode(Bool.self, forKey: .isTerminal),
            outcome: try container.decode(DemoRuntimeOutcome.self, forKey: .outcome),
            proofClass: try container.decode(PresentationProofClass.self, forKey: .proofClass),
            cards: try container.decode([DemoVehicleStateCell].self, forKey: .cards),
            cardSemantics: try container.decodeIfPresent([PresentationCardSemantics].self, forKey: .cardSemantics),
            readbacks: try container.decode([DemoActionReadback].self, forKey: .readbacks),
            reconciliation: try container.decode(PresentationReconciliation.self, forKey: .reconciliation),
            traceEnvelope: try container.decodeIfPresent(TraceEnvelope.self, forKey: .traceEnvelope),
            timestamp: try container.decode(Date.self, forKey: .timestamp)
        )
    }

    public func encode(to encoder: any Encoder) throws {
        let safe = RuntimePresentationPayload(
            schemaVersion: schemaVersion,
            traceID: traceID,
            turnID: turnID,
            eventID: eventID,
            isTerminal: isTerminal,
            outcome: outcome,
            proofClass: proofClass,
            cards: cards,
            cardSemantics: cardSemantics,
            readbacks: readbacks,
            reconciliation: reconciliation,
            traceEnvelope: traceEnvelope,
            timestamp: timestamp
        )
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(safe.schemaVersion, forKey: .schemaVersion)
        try container.encode(safe.traceID, forKey: .traceID)
        try container.encode(safe.turnID, forKey: .turnID)
        try container.encodeIfPresent(safe.eventID, forKey: .eventID)
        try container.encode(safe.isTerminal, forKey: .isTerminal)
        try container.encode(safe.outcome, forKey: .outcome)
        try container.encode(safe.proofClass, forKey: .proofClass)
        try container.encode(safe.cards, forKey: .cards)
        try container.encodeIfPresent(safe.cardSemantics, forKey: .cardSemantics)
        try container.encode(safe.readbacks, forKey: .readbacks)
        try container.encode(safe.reconciliation, forKey: .reconciliation)
        try container.encodeIfPresent(safe.traceEnvelope, forKey: .traceEnvelope)
        try container.encode(safe.timestamp, forKey: .timestamp)
    }

    private static func presentationSafe(_ outcome: DemoRuntimeOutcome) -> DemoRuntimeOutcome {
        let projection = outcome.reason.flatMap {
            RuntimePresentationReasonAuthority.projection(
                forFiniteReason: $0.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        return DemoRuntimeOutcome(
            result: projection?.result ?? outcome.result,
            behaviorClassSource: outcome.behaviorClassSource,
            reason: projection?.safeReasonKind.rawValue ?? PresentationPayloadSanitizer.publicPayloadReason(outcome.reason),
            missingSlot: PresentationPayloadSanitizer.redactedOptional(outcome.missingSlot),
            scopeFailureReason: PresentationPayloadSanitizer.publicPayloadReason(outcome.scopeFailureReason)
        )
    }

    private static func presentationSafe(_ cell: DemoVehicleStateCell) -> DemoVehicleStateCell {
        DemoVehicleStateCell(
            key: PresentationPayloadSanitizer.redacted(cell.key),
            actualValue: PresentationPayloadSanitizer.redacted(cell.actualValue),
            revision: cell.revision,
            visualState: cell.visualState
        )
    }

    private static func presentationSafe(_ semantics: PresentationCardSemantics) -> PresentationCardSemantics {
        PresentationCardSemantics(
            cellKey: PresentationPayloadSanitizer.redacted(semantics.cellKey),
            role: semantics.role,
            scopeOrigin: semantics.scopeOrigin,
            reason: PresentationPayloadSanitizer.publicPayloadReason(semantics.reason),
            isActive: semantics.isActive,
            siblingKeys: semantics.siblingKeys.map { PresentationPayloadSanitizer.redacted($0) }
        )
    }

    private static func presentationSafe(_ readback: DemoActionReadback) -> DemoActionReadback {
        DemoActionReadback(
            key: PresentationPayloadSanitizer.redacted(readback.key),
            actualValue: PresentationPayloadSanitizer.redacted(readback.actualValue),
            revision: readback.revision,
            spokenText: PresentationPayloadSanitizer.redacted(readback.spokenText),
            scopeOrigin: readback.scopeOrigin
        )
    }

    private static func presentationSafe(_ reconciliation: PresentationReconciliation) -> PresentationReconciliation {
        PresentationReconciliation(
            status: reconciliation.status,
            readbackKey: reconciliation.readbackKey,
            mismatchClass: reconciliation.mismatchClass,
            safeReason: PresentationPayloadSanitizer.publicPayloadReason(reconciliation.safeReason)
        )
    }
}

public enum TerminalSnapshotStopReason: String, Codable, CaseIterable, Equatable, Sendable {
    case cancelled
    case interrupted
    case timeout
    case backgrounding
}

public enum RuntimePresentationPartialProjectionError: Error, Equatable, Sendable {
    case invalidComposition
    case acceptedSubactionMissingReadback(frameID: String)
    case acceptedReadbackMissingCard(key: String)
    case acceptedCardMissingReadback(key: String)
    case refusedSubactionMissingCard(frameID: String)
    case refusedSubactionMissingReason(frameID: String)
    case unknownFiniteReason(frameID: String, reason: String)
    case proofClassUpgrade(PresentationProofClass)
}

public enum RuntimePresentationTerminalSnapshotAdapter {
    public static func guardDenial(
        traceID: String,
        reason: String,
        cards: [DemoVehicleStateCell] = [],
        readbacks: [DemoActionReadback] = [],
        scopeOrigin: ScopeOrigin? = nil,
        proofClass: PresentationProofClass = .localUnit,
        traceEnvelope: TraceEnvelope? = nil,
        timestamp: Date = Date()
    ) -> PresentationSnapshot {
        terminalSnapshot(
            traceID: traceID,
            outcome: DemoRuntimeOutcome(
                result: .refusalSafetyOrPolicy,
                reason: normalizedReason(reason, fallback: "guard_denied")
            ),
            cards: cards,
            readbacks: readbacks,
            scopeOrigin: scopeOrigin,
            proofClass: proofClass,
            traceEnvelope: traceEnvelope,
            timestamp: timestamp
        )
    }

    public static func thrownError(
        traceID: String,
        reason: String,
        cards: [DemoVehicleStateCell] = [],
        readbacks: [DemoActionReadback] = [],
        proofClass: PresentationProofClass = .localUnit,
        traceEnvelope: TraceEnvelope? = nil,
        timestamp: Date = Date()
    ) -> PresentationSnapshot {
        terminalSnapshot(
            traceID: traceID,
            outcome: DemoRuntimeOutcome(
                result: .runtimeError,
                reason: normalizedReason(reason, fallback: "runtime_error")
            ),
            cards: cards,
            readbacks: readbacks,
            proofClass: proofClass,
            traceEnvelope: traceEnvelope,
            timestamp: timestamp
        )
    }

    public static func partialAcceptRefuse(
        executionResult: DemoRuntimePartialPlanResult,
        acceptedCards: [DemoVehicleStateCell],
        refusedCardsBySubactionID: [String: DemoVehicleStateCell],
        proofClass: PresentationProofClass = .localUnit,
        traceEnvelope: TraceEnvelope? = nil,
        timestamp: Date = Date()
    ) throws -> PresentationSnapshot {
        guard proofClass == .localUnit else {
            throw RuntimePresentationPartialProjectionError.proofClassUpgrade(proofClass)
        }
        guard executionResult.hasAccepted, executionResult.hasRefused else {
            throw RuntimePresentationPartialProjectionError.invalidComposition
        }

        let acceptedSubactions = executionResult.subactions.filter { $0.disposition == .accepted }
        for subaction in acceptedSubactions where subaction.readbacks.isEmpty {
            throw RuntimePresentationPartialProjectionError.acceptedSubactionMissingReadback(
                frameID: subaction.frameID
            )
        }

        let acceptedReadbacks = acceptedSubactions.flatMap(\.readbacks)
        let acceptedCardsByKey = Dictionary(uniqueKeysWithValues: acceptedCards.map { ($0.key, $0) })
        let acceptedReadbackKeys = Set(acceptedReadbacks.map(\.key))
        for readback in acceptedReadbacks where acceptedCardsByKey[readback.key] == nil {
            throw RuntimePresentationPartialProjectionError.acceptedReadbackMissingCard(key: readback.key)
        }
        for card in acceptedCards where !acceptedReadbackKeys.contains(card.key) {
            throw RuntimePresentationPartialProjectionError.acceptedCardMissingReadback(key: card.key)
        }

        var refusedCards: [DemoVehicleStateCell] = []
        var refusedReasonKinds: [RuntimePresentationSafeReasonKind] = []
        for subaction in executionResult.subactions where subaction.disposition == .refused {
            guard let card = refusedCardsBySubactionID[subaction.frameID] else {
                throw RuntimePresentationPartialProjectionError.refusedSubactionMissingCard(
                    frameID: subaction.frameID
                )
            }
            guard let finiteReason = subaction.finiteReason else {
                throw RuntimePresentationPartialProjectionError.refusedSubactionMissingReason(
                    frameID: subaction.frameID
                )
            }
            let reasonKind = RuntimePresentationSafeReasonKind(finiteReason: finiteReason)

            var projectedCard = card
            projectedCard.visualState = reasonKind == .safetyPolicy ? .unsafe : .blocked_with_alternative
            refusedCards.append(projectedCard)
            refusedReasonKinds.append(reasonKind)
        }

        let cards = PresentationCardOrdering.orderedForPresentation(acceptedCards + refusedCards)
        let readbacksByKey = Dictionary(grouping: acceptedReadbacks, by: \.key)
        let cardKeys = cards.map(\.key)
        var unmatchedRefusedIndices = Array(refusedCards.indices)
        let semantics = cards.map { card in
            let siblingKeys = cardKeys.filter { $0 != card.key }
            if let offset = unmatchedRefusedIndices.firstIndex(where: { refusedCards[$0] == card }) {
                let refusedIndex = unmatchedRefusedIndices.remove(at: offset)
                return PresentationCardSemantics(
                    cellKey: card.key,
                    role: .refused,
                    reason: refusedReasonKinds[refusedIndex].rawValue,
                    siblingKeys: siblingKeys
                )
            }

            let readback = readbacksByKey[card.key]?.last
            return PresentationCardSemantics(
                cellKey: card.key,
                role: .accepted,
                scopeOrigin: readback?.scopeOrigin,
                reason: "readback_verified",
                isActive: true,
                siblingKeys: siblingKeys
            )
        }

        return terminalSnapshot(
            traceID: executionResult.traceID,
            outcome: DemoRuntimeOutcome(
                result: .partialAcceptPartialRefuse,
                reason: "partial_accept_refuse"
            ),
            cards: cards,
            cardSemantics: semantics,
            readbacks: acceptedReadbacks,
            proofClass: proofClass,
            traceEnvelope: traceEnvelope,
            timestamp: timestamp
        )
    }

    static func canProjectPartialRefusalIdentity(
        executionResult: DemoRuntimePartialPlanResult,
        refusedCardsBySubactionID: [String: DemoVehicleStateCell]
    ) -> Bool {
        return executionResult.subactions
            .filter { $0.disposition == .refused }
            .allSatisfy { subaction in
                guard subaction.finiteReason != nil,
                      refusedCardsBySubactionID[subaction.frameID] != nil else {
                    return false
                }
                return true
            }
    }

    public static func terminalStop(
        traceID: String,
        stopReason: TerminalSnapshotStopReason,
        reason: String? = nil,
        cards: [DemoVehicleStateCell] = [],
        readbacks: [DemoActionReadback] = [],
        proofClass: PresentationProofClass = .localUnit,
        traceEnvelope: TraceEnvelope? = nil,
        timestamp: Date = Date()
    ) -> PresentationSnapshot {
        let result: DemoRuntimeResult = switch stopReason {
        case .cancelled:
            .cancelled
        case .interrupted, .backgrounding:
            .interrupted
        case .timeout:
            .runtimeError
        }

        return terminalSnapshot(
            traceID: traceID,
            outcome: DemoRuntimeOutcome(
                result: result,
                reason: normalizedReason(reason ?? stopReason.rawValue, fallback: stopReason.rawValue)
            ),
            cards: cards,
            readbacks: readbacks,
            proofClass: proofClass,
            traceEnvelope: traceEnvelope,
            timestamp: timestamp
        )
    }

    private static func terminalSnapshot(
        traceID: String,
        outcome: DemoRuntimeOutcome,
        cards: [DemoVehicleStateCell],
        cardSemantics: [PresentationCardSemantics]? = nil,
        readbacks: [DemoActionReadback],
        scopeOrigin: ScopeOrigin? = nil,
        proofClass: PresentationProofClass,
        traceEnvelope: TraceEnvelope?,
        timestamp: Date
    ) -> PresentationSnapshot {
        PresentationSnapshot(
            traceID: traceID,
            runtimeOutcome: outcome,
            cards: cards,
            cardSemantics: cardSemantics,
            readbacks: readbacks,
            scopeOrigin: scopeOrigin,
            proofClass: proofClass,
            traceEnvelope: traceEnvelope?.presentationSafe(),
            isTerminal: true,
            timestamp: timestamp
        )
    }

    private static func normalizedReason(_ reason: String, fallback: String) -> String {
        let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        var safeReason = trimmed.isEmpty ? fallback : trimmed
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        for token in unsafeReasonTokens.sorted(by: { $0.count > $1.count }) where safeReason.range(of: token, options: options) != nil {
            safeReason = safeReason.replacingOccurrences(of: token, with: "[redacted]", options: options)
        }
        return PresentationPayloadSanitizer.publicReason(String(safeReason.prefix(160))) ?? fallback
    }

    private static let unsafeReasonTokens = PresentationPayloadSanitizer.redactedTokens
}

private extension TraceAttributes {
    func presentationSafe(redactedTokens: [String], maxMessageLength: Int) -> TraceAttributes {
        var copy = self
        copy.stopReason = copy.stopReason.map {
            if let projection = RuntimePresentationReasonAuthority.projection(forFiniteReason: $0) {
                return projection.safeReasonKind.rawValue
            }
            return TraceAttributes.redacted($0, redactedTokens: redactedTokens, maxMessageLength: maxMessageLength)
        }
        if let finiteReason = copy.finiteReason {
            copy.guardReason = RuntimePresentationSafeReasonKind(finiteReason: finiteReason).rawValue
            copy.finiteReason = nil
        } else {
            copy.guardReason = copy.guardReason.map {
                if let projection = RuntimePresentationReasonAuthority.projection(forFiniteReason: $0) {
                    return projection.safeReasonKind.rawValue
                }
                if $0.range(
                    of: #"^[a-z][a-z0-9]*(?:_[a-z0-9]+)+$"#,
                    options: .regularExpression
                ) != nil {
                    return RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue
                }
                return TraceAttributes.redacted($0, redactedTokens: redactedTokens, maxMessageLength: maxMessageLength)
            }
        }
        copy.decodeFailureKind = nil
        return copy
    }

    static func redacted(_ value: String, redactedTokens: [String], maxMessageLength: Int) -> String {
        var safeValue = value
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        for token in redactedTokens.sorted(by: { $0.count > $1.count }) where safeValue.range(of: token, options: options) != nil {
            safeValue = safeValue.replacingOccurrences(of: token, with: "[redacted]", options: options)
        }
        return String(safeValue.prefix(maxMessageLength))
    }
}
