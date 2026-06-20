import Foundation

public enum TraceStage: String, Codable, Equatable, Sendable {
    case decode
    case plan
    case `guard`
    case execute
    case readback
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

    public init(
        candidateSource: ToolCandidateSource? = nil,
        toolCallCount: Int? = nil,
        stopReason: String? = nil,
        repairUsed: Bool? = nil,
        guardReason: String? = nil,
        readbackResult: TraceReadbackResult? = nil
    ) {
        self.candidateSource = candidateSource
        self.toolCallCount = toolCallCount
        self.stopReason = stopReason
        self.repairUsed = repairUsed
        self.guardReason = guardReason
        self.readbackResult = readbackResult
    }
}

public struct TraceEntry: Codable, Equatable, Sendable {
    public var stage: TraceStage
    public var traceID: String
    public var message: String
    public var attributes: TraceAttributes
    public var timestamp: Date

    public init(
        stage: TraceStage,
        traceID: String,
        message: String,
        attributes: TraceAttributes = TraceAttributes(),
        timestamp: Date = Date()
    ) {
        self.stage = stage
        self.traceID = traceID
        self.message = message
        self.attributes = attributes
        self.timestamp = timestamp
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

    public init() {}

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
        entries.append(TraceEntry(stage: stage, traceID: traceID, message: message, attributes: attributes))
    }
}
