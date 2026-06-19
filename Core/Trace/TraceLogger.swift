import Foundation

public enum TraceStage: String, Codable, Equatable, Sendable {
    case decode
    case plan
    case `guard`
    case execute
    case readback
}

public struct TraceEntry: Codable, Equatable, Sendable {
    public var stage: TraceStage
    public var traceID: String
    public var message: String
    public var metadata: [String: String]
    public var timestamp: Date

    public init(
        stage: TraceStage,
        traceID: String,
        message: String,
        metadata: [String: String] = [:],
        timestamp: Date = Date()
    ) {
        self.stage = stage
        self.traceID = traceID
        self.message = message
        self.metadata = metadata
        self.timestamp = timestamp
    }
}

public protocol TraceLogger: Sendable {
    func recordDecode(traceID: String, message: String, metadata: [String: String])
    func recordPlan(traceID: String, message: String, metadata: [String: String])
    func recordGuard(traceID: String, message: String, metadata: [String: String])
    func recordExecute(traceID: String, message: String, metadata: [String: String])
    func recordReadback(traceID: String, message: String, metadata: [String: String])
}

public extension TraceLogger {
    func recordDecode(traceID: String, message: String) {
        recordDecode(traceID: traceID, message: message, metadata: [:])
    }

    func recordPlan(traceID: String, message: String) {
        recordPlan(traceID: traceID, message: message, metadata: [:])
    }

    func recordGuard(traceID: String, message: String) {
        recordGuard(traceID: traceID, message: message, metadata: [:])
    }

    func recordExecute(traceID: String, message: String) {
        recordExecute(traceID: traceID, message: message, metadata: [:])
    }

    func recordReadback(traceID: String, message: String) {
        recordReadback(traceID: traceID, message: message, metadata: [:])
    }
}

public final class InMemoryTraceLogger: TraceLogger, @unchecked Sendable {
    public private(set) var entries: [TraceEntry] = []

    public init() {}

    public func recordDecode(traceID: String, message: String, metadata: [String: String]) {
        append(.decode, traceID: traceID, message: message, metadata: metadata)
    }

    public func recordPlan(traceID: String, message: String, metadata: [String: String]) {
        append(.plan, traceID: traceID, message: message, metadata: metadata)
    }

    public func recordGuard(traceID: String, message: String, metadata: [String: String]) {
        append(.guard, traceID: traceID, message: message, metadata: metadata)
    }

    public func recordExecute(traceID: String, message: String, metadata: [String: String]) {
        append(.execute, traceID: traceID, message: message, metadata: metadata)
    }

    public func recordReadback(traceID: String, message: String, metadata: [String: String]) {
        append(.readback, traceID: traceID, message: message, metadata: metadata)
    }

    private func append(_ stage: TraceStage, traceID: String, message: String, metadata: [String: String]) {
        entries.append(TraceEntry(stage: stage, traceID: traceID, message: message, metadata: metadata))
    }
}
