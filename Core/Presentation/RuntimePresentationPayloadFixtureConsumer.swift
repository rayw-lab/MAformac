import Foundation

enum RuntimePresentationPayloadFixtureConsumerError: Error, Equatable, Sendable {
    case unknownTopLevelField(String)
    case unknownNestedField(path: String, field: String)
    case unknownResultKind(String)
    case unknownAvailability(String)
    case unknownValueSource(String)
    case unknownVisualState(String)
    case unknownScopeOrigin(String)
    case unknownCardRole(String)
    case unknownOrbState(String)
    case unknownVoiceState(String)
}

enum RuntimePresentationPayloadFixtureConsumer {
    static func consume(_ data: Data) throws -> StagePresentationSnapshot {
        try RuntimePresentationPayloadPrivateMarkerGuard.rejectForbiddenMarkers(in: data)

        let payload = try JSONDecoder().decode(RuntimePresentationPayloadFixture.self, from: data)
        return try payload.presentationSnapshot()
    }
}

private struct RuntimePresentationPayloadFixture: Decodable {
    var schemaVersion: String
    var traceID: String
    var turnID: String
    var eventID: String?
    var isTerminal: Bool
    var outcome: FixtureOutcome
    var proofClass: String
    var cards: [FixtureCard]
    var cardSemantics: [FixtureCardSemantics]?
    var readbacks: [FixtureReadback]
    var reconciliation: FixtureReconciliation
    var traceEnvelope: FixtureTraceEnvelope?
    var voiceState: String
    var orbState: String
    var mutationCount: Int

    private enum CodingKeys: String, CodingKey, CaseIterable {
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
        case voiceState
        case orbState
        case mutationCount
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "$",
            topLevel: true
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        try RuntimePresentationConsumerMapping.validatePayloadSchema(schemaVersion)
        traceID = try container.decode(String.self, forKey: .traceID)
        turnID = try container.decode(String.self, forKey: .turnID)
        eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        isTerminal = try container.decode(Bool.self, forKey: .isTerminal)
        outcome = try container.decode(FixtureOutcome.self, forKey: .outcome)
        proofClass = try container.decode(String.self, forKey: .proofClass)
        try RuntimePresentationConsumerMapping.validateProofClass(proofClass)
        cards = try container.decode([FixtureCard].self, forKey: .cards)
        cardSemantics = try container.decodeIfPresent([FixtureCardSemantics].self, forKey: .cardSemantics)
        readbacks = try container.decode([FixtureReadback].self, forKey: .readbacks)
        reconciliation = try container.decode(FixtureReconciliation.self, forKey: .reconciliation)
        traceEnvelope = try container.decodeIfPresent(FixtureTraceEnvelope.self, forKey: .traceEnvelope)
        voiceState = try container.decode(String.self, forKey: .voiceState)
        orbState = try container.decode(String.self, forKey: .orbState)
        mutationCount = try container.decode(Int.self, forKey: .mutationCount)
    }

    func presentationSnapshot() throws -> StagePresentationSnapshot {
        let resultKind = try outcome.localResultKind()
        let localReadbacks = try readbacks.map { try $0.demoReadback() }
        let localCards = try cards.map { try $0.demoCell() }
        let semantics = cardSemantics ?? []
        var scopeOrigins: [String: ScopeOrigin] = [:]
        var activeCells: [FamilyCardID: String] = [:]
        var refusedCell: String?

        for semantic in semantics {
            if let origin = try semantic.scopeOriginValue() {
                scopeOrigins[semantic.cellKey] = origin
            }
            let role = try semantic.roleValue()
            if role == "refused" {
                refusedCell = refusedCell ?? semantic.cellKey
            }
            if semantic.isActive, let family = FamilyCardIDMapper.familyCardID(forBase: semantic.baseCellKey) {
                activeCells[family] = semantic.cellKey
            }
        }

        for readback in localReadbacks {
            if let origin = readback.scopeOrigin {
                scopeOrigins[readback.key] = origin
            }
        }

        let dialogText = localReadbacks.map(\.spokenText).filter { !$0.isEmpty }.joined(separator: "；")
        let resolvedDialogText = dialogText.isEmpty ? (outcome.reason ?? DemoRuntimeResultPresentationMatrix.entry(for: resultKind).dialogText) : dialogText

        // Consume payload voice/orb truth directly (§3.3/§3.4); do not guess
        // from hasDialog or static matrix (AF5 finding #4).
        let resolvedOrbState = try RuntimePresentationPayloadFixtureConsumerBridge.orbState(
            payloadOrbState: orbState
        )
        let resolvedVoiceState = try RuntimePresentationPayloadFixtureConsumerBridge.voiceState(
            payloadVoiceState: voiceState
        )

        return FrontstageRuntimePresentationAdapter.fixtureSnapshot(
            traceID: traceID,
            storeCells: localCards,
            activeCells: activeCells,
            refusedCell: refusedCell,
            scopeOrigins: scopeOrigins,
            orbState: resolvedOrbState,
            voiceState: resolvedVoiceState,
            dialogText: resolvedDialogText,
            readbacks: localReadbacks,
            resultKind: resultKind,
            proofClass: try RuntimePresentationPayloadFixtureConsumerBridge.proofClass(for: proofClass)
        )
    }
}

private struct FixtureOutcome: Decodable {
    var result: String
    var behaviorClassSource: String?
    var reason: String?
    var missingSlot: String?
    var scopeFailureReason: String?

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case result
        case behaviorClassSource
        case reason
        case missingSlot
        case scopeFailureReason
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "outcome"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result = try container.decode(String.self, forKey: .result)
        behaviorClassSource = try container.decodeIfPresent(String.self, forKey: .behaviorClassSource)
        reason = try container.decodeIfPresent(String.self, forKey: .reason)
        missingSlot = try container.decodeIfPresent(String.self, forKey: .missingSlot)
        scopeFailureReason = try container.decodeIfPresent(String.self, forKey: .scopeFailureReason)
    }

    func localResultKind() throws -> DemoRuntimeResultKind {
        guard let kind = RuntimePresentationConsumerMapping.localResultKind(forMainlineResultName: result) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownResultKind(result)
        }
        return kind
    }
}

private struct FixtureCard: Decodable {
    var key: String
    var actualValue: String
    var desiredValue: String?
    var availability: String?
    var source: String?
    var revision: Int
    var visualState: String

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case key
        case actualValue
        case desiredValue
        case availability
        case source
        case revision
        case visualState
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "cards[]"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        actualValue = try container.decode(String.self, forKey: .actualValue)
        desiredValue = try container.decodeIfPresent(String.self, forKey: .desiredValue)
        availability = try container.decodeIfPresent(String.self, forKey: .availability)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        revision = try container.decode(Int.self, forKey: .revision)
        visualState = try container.decode(String.self, forKey: .visualState)
    }

    func demoCell() throws -> DemoVehicleStateCell {
        let resolvedAvailability = try availabilityValue()
        let resolvedSource = try sourceValue()
        let resolvedVisualState = try visualStateValue()
        return DemoVehicleStateCell(
            key: key,
            actualValue: actualValue,
            desiredValue: desiredValue,
            availability: resolvedAvailability,
            timestamp: Date(timeIntervalSince1970: 0),
            source: resolvedSource,
            revision: revision,
            visualState: resolvedVisualState
        )
    }

    private func availabilityValue() throws -> DemoVehicleAvailability {
        guard let availability else {
            return .available
        }
        guard let value = DemoVehicleAvailability(rawValue: availability) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownAvailability(availability)
        }
        return value
    }

    private func sourceValue() throws -> DemoVehicleValueSource {
        guard let source else {
            return .mock
        }
        guard let value = DemoVehicleValueSource(rawValue: source) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownValueSource(source)
        }
        return value
    }

    private func visualStateValue() throws -> DemoVisualState {
        guard let value = DemoVisualState(rawValue: visualState) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownVisualState(visualState)
        }
        return value
    }
}

private struct FixtureCardSemantics: Decodable {
    var cellKey: String
    var role: String
    var scopeOrigin: String?
    var reason: String?
    var isActive: Bool
    var siblingKeys: [String]

    var baseCellKey: String {
        cellKey.split(separator: "[").first.map(String.init) ?? cellKey
    }

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case cellKey
        case role
        case scopeOrigin
        case reason
        case isActive
        case siblingKeys
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "cardSemantics[]"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cellKey = try container.decode(String.self, forKey: .cellKey)
        role = try container.decode(String.self, forKey: .role)
        scopeOrigin = try container.decodeIfPresent(String.self, forKey: .scopeOrigin)
        reason = try container.decodeIfPresent(String.self, forKey: .reason)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        siblingKeys = try container.decode([String].self, forKey: .siblingKeys)
    }

    func roleValue() throws -> String {
        let knownRoles = ["primary", "sibling", "accepted", "refused", "context"]
        guard knownRoles.contains(role) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownCardRole(role)
        }
        return role
    }

    func scopeOriginValue() throws -> ScopeOrigin? {
        guard let scopeOrigin else {
            return nil
        }
        guard let value = ScopeOrigin(rawValue: scopeOrigin) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownScopeOrigin(scopeOrigin)
        }
        return value
    }
}

private struct FixtureReadback: Decodable {
    var key: String
    var actualValue: String
    var revision: Int
    var spokenText: String
    var scopeOrigin: String?

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case key
        case actualValue
        case revision
        case spokenText
        case scopeOrigin
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "readbacks[]"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        actualValue = try container.decode(String.self, forKey: .actualValue)
        revision = try container.decode(Int.self, forKey: .revision)
        spokenText = try container.decode(String.self, forKey: .spokenText)
        scopeOrigin = try container.decodeIfPresent(String.self, forKey: .scopeOrigin)
    }

    func demoReadback() throws -> DemoActionReadback {
        DemoActionReadback(
            key: key,
            actualValue: actualValue,
            revision: revision,
            spokenText: spokenText,
            scopeOrigin: try scopeOriginValue()
        )
    }

    private func scopeOriginValue() throws -> ScopeOrigin? {
        guard let scopeOrigin else {
            return nil
        }
        guard let value = ScopeOrigin(rawValue: scopeOrigin) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownScopeOrigin(scopeOrigin)
        }
        return value
    }
}

private struct FixtureReconciliation: Decodable {
    var status: String
    var readbackKey: String?
    var mismatchClass: String?
    var safeReason: String?

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case status
        case readbackKey
        case mismatchClass
        case safeReason
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "reconciliation"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(String.self, forKey: .status)
        try RuntimePresentationConsumerMapping.validateReconciliationStatus(status)
        readbackKey = try container.decodeIfPresent(String.self, forKey: .readbackKey)
        mismatchClass = try container.decodeIfPresent(String.self, forKey: .mismatchClass)
        if let mismatchClass {
            try RuntimePresentationConsumerMapping.validateReconciliationMismatchClass(mismatchClass)
        }
        safeReason = try container.decodeIfPresent(String.self, forKey: .safeReason)
    }
}

private struct FixtureTraceEnvelope: Decodable {
    var traceID: String
    var entries: [FixtureTraceEntry]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case traceID
        case entries
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "traceEnvelope"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        traceID = try container.decode(String.self, forKey: .traceID)
        entries = try container.decode([FixtureTraceEntry].self, forKey: .entries)
    }
}

private struct FixtureTraceEntry: Decodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case stage
        case traceID
        case runId
        case parentSpanId
        case spanKind
        case message
        case attributes
        case timestamp
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "traceEnvelope.entries[]"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(String.self, forKey: .stage)
        _ = try container.decode(String.self, forKey: .traceID)
        _ = try container.decodeIfPresent(String.self, forKey: .runId)
        _ = try container.decodeIfPresent(String.self, forKey: .parentSpanId)
        _ = try container.decodeIfPresent(String.self, forKey: .spanKind)
        _ = try container.decode(String.self, forKey: .message)
        _ = try container.decodeIfPresent(FixtureTraceAttributes.self, forKey: .attributes)
        _ = try container.decodeIfPresent(FixtureTimestamp.self, forKey: .timestamp)
    }
}

private struct FixtureTraceAttributes: Decodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case candidateSource
        case toolCallCount
        case stopReason
        case repairUsed
        case guardReason
        case readbackResult
    }

    init(from decoder: any Decoder) throws {
        try RuntimePresentationPayloadStrictDecoder.validateKnownKeys(
            decoder,
            codingKeys: CodingKeys.self,
            path: "traceEnvelope.entries[].attributes"
        )
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decodeIfPresent(String.self, forKey: .candidateSource)
        _ = try container.decodeIfPresent(Int.self, forKey: .toolCallCount)
        _ = try container.decodeIfPresent(String.self, forKey: .stopReason)
        _ = try container.decodeIfPresent(Bool.self, forKey: .repairUsed)
        _ = try container.decodeIfPresent(String.self, forKey: .guardReason)
        _ = try container.decodeIfPresent(String.self, forKey: .readbackResult)
    }
}

private struct FixtureTimestamp: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() || (try? container.decode(Double.self)) != nil || (try? container.decode(String.self)) != nil {
            return
        }
        throw DecodingError.typeMismatch(
            FixtureTimestamp.self,
            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected timestamp number or string")
        )
    }
}

private enum RuntimePresentationPayloadFixtureConsumerBridge {
    static func proofClass(for mainlineName: String) throws -> StagePresentationProofClass {
        switch mainlineName {
        case "local_unit":
            return .localMock
        case "docs_local", "openspec_contract", "local_static_contract", "local_shape_no_model", "local_receipt_consistency":
            return .staticPreview
        case "simulator_mock":
            return .simulatorMock
        case "external_gptpro_review":
            return .operatorReview
        default:
            throw RuntimePresentationConsumerValidationError.unknownProofClass(mainlineName)
        }
    }

    static func orbState(payloadOrbState: String) throws -> PresentationOrbState {
        guard let value = PresentationOrbState(rawValue: payloadOrbState) else {
            throw RuntimePresentationPayloadFixtureConsumerError.unknownOrbState(payloadOrbState)
        }
        return value
    }

    static func voiceState(payloadVoiceState: String) throws -> PresentationVoiceState {
        // Map PresentationVoiceDisplayState raw values (speak/idle/listen/unavailable)
        // to the App PresentationVoiceState surface (§3.3).
        switch payloadVoiceState {
        case "speak":
            return .speaking
        case "idle":
            return .idle
        case "listen":
            return .listening
        case "unavailable":
            return .idle
        default:
            throw RuntimePresentationPayloadFixtureConsumerError.unknownVoiceState(payloadVoiceState)
        }
    }
}

private enum RuntimePresentationPayloadStrictDecoder {
    static func validateKnownKeys<Key: CodingKey & CaseIterable>(
        _ decoder: any Decoder,
        codingKeys: Key.Type,
        path: String,
        topLevel: Bool = false
    ) throws {
        let container = try decoder.container(keyedBy: RuntimePresentationPayloadAnyCodingKey.self)
        let allowedNames = Set(codingKeys.allCases.map(\.stringValue))
        for key in container.allKeys {
            try RuntimePresentationConsumerMapping.rejectForbiddenConsumerName(key.stringValue)
            guard allowedNames.contains(key.stringValue) else {
                if topLevel {
                    throw RuntimePresentationPayloadFixtureConsumerError.unknownTopLevelField(key.stringValue)
                }
                throw RuntimePresentationPayloadFixtureConsumerError.unknownNestedField(path: path, field: key.stringValue)
            }
        }
    }
}

private enum RuntimePresentationPayloadPrivateMarkerGuard {
    static func rejectForbiddenMarkers(in data: Data) throws {
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return
        }
        try scan(json)
    }

    private static func scan(_ value: Any) throws {
        if let string = value as? String {
            try rejectForbiddenMarkers(in: string)
        } else if let array = value as? [Any] {
            for item in array {
                try scan(item)
            }
        } else if let dictionary = value as? [String: Any] {
            for (key, value) in dictionary {
                try rejectForbiddenMarkers(in: key)
                try scan(value)
            }
        }
    }

    private static func rejectForbiddenMarkers(in value: String) throws {
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        if let forbidden = RuntimePresentationConsumerMapping.forbiddenPrivateNames.first(where: { value.range(of: $0, options: options) != nil }) {
            throw RuntimePresentationConsumerValidationError.forbiddenPrivateName(forbidden)
        }
    }
}

private struct RuntimePresentationPayloadAnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
