import Foundation

public enum TraceStage: String, Codable, Equatable, Sendable {
    case decode
    case plan
    case `guard`
    case execute
    case readback
}

public enum TraceSpanKind: String, Codable, Equatable, Sendable {
    case root
    case stage
    case `internal`
}

/// readback 段的强类型结果。pending/failed/unknown/mismatch 不得被当成 verified。
/// spec tool-execution:135 + tasks.md:48。
public enum TraceReadbackResult: String, Codable, Equatable, Sendable {
    case verified
    case mismatch
    case pending
    case failed
    case unknown
    case notApplicable = "n/a"
}

/// 每段 trace 的强类型 attributes。
/// tasks.md:48 + spec tool-execution:157 要求记录:
/// candidate_source / tool_call_count / stop_reason / repair_used / guard_reason / readback_result。
/// 全字段可空,只有相关段填对应字段,默认值保证旧 record 调用向后兼容。
public struct TraceAttributes: Codable, Equatable, Sendable {
    public var candidateSource: ToolCandidateSource?
    public var toolCallCount: Int?
    public var stopReason: String?
    public var repairUsed: Bool?
    public var guardReason: String?
    public var readbackResult: TraceReadbackResult?
    public var finiteReason: RuntimeFiniteReason?
    public var decodeFailureKind: DDomainDecodeFailureKind?
    public var rawPayloadHash: String?
    public var slotProjected: Bool?

    public init(
        candidateSource: ToolCandidateSource? = nil,
        toolCallCount: Int? = nil,
        stopReason: String? = nil,
        repairUsed: Bool? = nil,
        guardReason: String? = nil,
        readbackResult: TraceReadbackResult? = nil,
        finiteReason: RuntimeFiniteReason? = nil,
        decodeFailureKind: DDomainDecodeFailureKind? = nil,
        rawPayloadHash: String? = nil,
        slotProjected: Bool? = nil
    ) {
        self.candidateSource = candidateSource
        self.toolCallCount = toolCallCount
        self.stopReason = stopReason
        self.repairUsed = repairUsed
        self.guardReason = guardReason
        self.readbackResult = readbackResult
        self.finiteReason = finiteReason
        self.decodeFailureKind = decodeFailureKind
        self.rawPayloadHash = rawPayloadHash
        self.slotProjected = slotProjected
    }
}

public struct TraceEntry: Codable, Equatable, Sendable {
    public var stage: TraceStage
    public var traceID: String
    public var runId: String?
    public var parentSpanId: String?
    public var spanKind: TraceSpanKind
    public var message: String
    public var attributes: TraceAttributes
    public var timestamp: Date

    private enum CodingKeys: String, CodingKey {
        case stage
        case traceID
        case runId
        case parentSpanId
        case spanKind
        case message
        case attributes
        case timestamp
    }

    public init(
        stage: TraceStage,
        traceID: String,
        runId: String? = nil,
        parentSpanId: String? = nil,
        spanKind: TraceSpanKind = .stage,
        message: String,
        attributes: TraceAttributes = TraceAttributes(),
        timestamp: Date = Date()
    ) {
        self.stage = stage
        self.traceID = traceID
        self.runId = runId
        self.parentSpanId = parentSpanId
        self.spanKind = spanKind
        self.message = message
        self.attributes = attributes
        self.timestamp = timestamp
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stage = try container.decode(TraceStage.self, forKey: .stage)
        traceID = try container.decode(String.self, forKey: .traceID)
        runId = try container.decodeIfPresent(String.self, forKey: .runId)
        parentSpanId = try container.decodeIfPresent(String.self, forKey: .parentSpanId)
        spanKind = try container.decodeIfPresent(TraceSpanKind.self, forKey: .spanKind) ?? .stage
        message = try container.decode(String.self, forKey: .message)
        attributes = try container.decodeIfPresent(TraceAttributes.self, forKey: .attributes) ?? TraceAttributes()
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stage, forKey: .stage)
        try container.encode(traceID, forKey: .traceID)
        try container.encodeIfPresent(runId, forKey: .runId)
        try container.encodeIfPresent(parentSpanId, forKey: .parentSpanId)
        try container.encode(spanKind, forKey: .spanKind)
        try container.encode(message, forKey: .message)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

public protocol TraceLogger: Sendable {
    func recordDecode(traceID: String, message: String, attributes: TraceAttributes)
    func recordPlan(traceID: String, message: String, attributes: TraceAttributes)
    func recordGuard(traceID: String, message: String, attributes: TraceAttributes)
    func recordExecute(traceID: String, message: String, attributes: TraceAttributes)
    func recordReadback(traceID: String, message: String, attributes: TraceAttributes)
}

/// 默认参数扩展:旧 record(traceID:message:) 调用无需改即可继续编译。
public extension TraceLogger {
    func recordDecode(traceID: String, message: String) {
        recordDecode(traceID: traceID, message: message, attributes: TraceAttributes())
    }
    func recordPlan(traceID: String, message: String) {
        recordPlan(traceID: traceID, message: message, attributes: TraceAttributes())
    }
    func recordGuard(traceID: String, message: String) {
        recordGuard(traceID: traceID, message: message, attributes: TraceAttributes())
    }
    func recordExecute(traceID: String, message: String) {
        recordExecute(traceID: traceID, message: message, attributes: TraceAttributes())
    }
    func recordReadback(traceID: String, message: String) {
        recordReadback(traceID: traceID, message: message, attributes: TraceAttributes())
    }
}

public final class InMemoryTraceLogger: TraceLogger, @unchecked Sendable {
    public private(set) var entries: [TraceEntry] = []
    private let runId: String?
    private let parentSpanId: String?
    private let spanKind: TraceSpanKind

    public init(
        runId: String? = nil,
        parentSpanId: String? = nil,
        spanKind: TraceSpanKind = .stage
    ) {
        self.runId = runId
        self.parentSpanId = parentSpanId
        self.spanKind = spanKind
    }

    public func recordDecode(traceID: String, message: String, attributes: TraceAttributes) {
        append(.decode, traceID: traceID, message: message, attributes: attributes)
    }

    public func recordPlan(traceID: String, message: String, attributes: TraceAttributes) {
        append(.plan, traceID: traceID, message: message, attributes: attributes)
    }

    public func recordGuard(traceID: String, message: String, attributes: TraceAttributes) {
        append(.guard, traceID: traceID, message: message, attributes: attributes)
    }

    public func recordExecute(traceID: String, message: String, attributes: TraceAttributes) {
        append(.execute, traceID: traceID, message: message, attributes: attributes)
    }

    public func recordReadback(traceID: String, message: String, attributes: TraceAttributes) {
        append(.readback, traceID: traceID, message: message, attributes: attributes)
    }

    private func append(_ stage: TraceStage, traceID: String, message: String, attributes: TraceAttributes) {
        entries.append(TraceEntry(
            stage: stage,
            traceID: traceID,
            runId: runId,
            parentSpanId: parentSpanId,
            spanKind: spanKind,
            message: message,
            attributes: attributes
        ))
    }
}

// MARK: - C3 internal fallback receipt

/// The only finite reasons accepted by the C1 governance contract (T0).
///
/// This type is intentionally internal: raw finite reasons are retained in C3
/// receipts for diagnostics, but are not part of the runtime-presentation bridge
/// payload contract.
typealias InternalTraceFiniteReason = RuntimeFiniteReason

enum InternalTraceSubactionDisposition: String, Codable, Equatable, Sendable {
    case accepted
    case refused
}

/// A C3 subaction observation before it is persisted as an internal receipt.
/// `stateMutation` is supplied from the observed subaction fact; the writer
/// deliberately does not infer or overwrite it.
struct InternalTraceSubactionFact: Equatable, Sendable {
    let subactionID: String
    let disposition: InternalTraceSubactionDisposition
    let family: String
    let reasonKind: String
    let finiteReason: RuntimeFiniteReason?
    let observedToolCallCount: Int
    let stateMutation: Bool
    let speechText: String
    let readbackKeys: [String]

    init(
        subactionID: String,
        disposition: InternalTraceSubactionDisposition,
        family: String,
        reasonKind: String,
        finiteReason: RuntimeFiniteReason?,
        observedToolCallCount: Int,
        stateMutation: Bool,
        speechText: String,
        readbackKeys: [String]
    ) {
        self.subactionID = subactionID
        self.disposition = disposition
        self.family = family
        self.reasonKind = reasonKind
        self.finiteReason = finiteReason
        self.observedToolCallCount = observedToolCallCount
        self.stateMutation = stateMutation
        self.speechText = speechText
        self.readbackKeys = readbackKeys
    }
}

struct InternalTraceReceiptSubaction: Codable, Equatable, Sendable {
    let subactionID: String
    let disposition: InternalTraceSubactionDisposition
    let family: String
    let reasonKind: String
    let finiteReason: InternalTraceFiniteReason?
    let observedToolCallCount: Int
    let stateMutation: Bool
    let speechText: String
    let readbackKeys: [String]

    private enum CodingKeys: String, CodingKey {
        case subactionID = "subaction_id"
        case disposition
        case family
        case reasonKind = "reason_kind"
        case finiteReason = "finite_reason"
        case observedToolCallCount = "observed_tool_call_count"
        case stateMutation = "state_mutation"
        case speechText = "speech_text"
        case readbackKeys = "readback_keys"
    }
}

struct InternalTraceReceipt: Codable, Equatable, Sendable {
    static let schemaVersion = "c3_internal_trace_receipt.v1"

    let schemaVersion: String
    let traceID: String
    let subactions: [InternalTraceReceiptSubaction]

    init(traceID: String, subactions: [InternalTraceReceiptSubaction]) {
        self.schemaVersion = Self.schemaVersion
        self.traceID = traceID
        self.subactions = subactions
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case traceID = "trace_id"
        case subactions
    }
}

enum InternalTraceReceiptError: Error, Equatable, Sendable {
    case refusedSubactionMissingFiniteReason(subactionID: String)
    case acceptedSubactionHasFiniteReason(subactionID: String, rawValue: String)
    case refusedSubactionHasObservedEffects(
        subactionID: String,
        observedToolCallCount: Int,
        stateMutation: Bool
    )
}

/// Persists C3 fallback and partial facts without widening the public bridge.
final class InternalTraceReceiptWriter {
    private(set) var receipts: [InternalTraceReceipt] = []

    @discardableResult
    func record(
        traceID: String,
        subactions: [InternalTraceSubactionFact]
    ) throws -> InternalTraceReceipt {
        let receipt = try InternalTraceReceipt(
            traceID: traceID,
            subactions: subactions.map(makeReceiptSubaction)
        )
        receipts.append(receipt)
        return receipt
    }

    private func makeReceiptSubaction(
        from fact: InternalTraceSubactionFact
    ) throws -> InternalTraceReceiptSubaction {
        let finiteReason = fact.finiteReason

        switch fact.disposition {
        case .accepted:
            if let finiteReason {
                throw InternalTraceReceiptError.acceptedSubactionHasFiniteReason(
                    subactionID: fact.subactionID,
                    rawValue: finiteReason.rawValue
                )
            }
        case .refused:
            guard finiteReason != nil else {
                throw InternalTraceReceiptError.refusedSubactionMissingFiniteReason(
                    subactionID: fact.subactionID
                )
            }
            if fact.observedToolCallCount != 0 || fact.stateMutation {
                throw InternalTraceReceiptError.refusedSubactionHasObservedEffects(
                    subactionID: fact.subactionID,
                    observedToolCallCount: fact.observedToolCallCount,
                    stateMutation: fact.stateMutation
                )
            }
        }

        return InternalTraceReceiptSubaction(
            subactionID: fact.subactionID,
            disposition: fact.disposition,
            family: fact.family,
            reasonKind: fact.reasonKind,
            finiteReason: finiteReason,
            observedToolCallCount: fact.observedToolCallCount,
            stateMutation: fact.stateMutation,
            speechText: fact.speechText,
            readbackKeys: fact.readbackKeys
        )
    }
}
