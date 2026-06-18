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
    public var timestamp: Date

    public init(stage: TraceStage, traceID: String, message: String, timestamp: Date = Date()) {
        self.stage = stage
        self.traceID = traceID
        self.message = message
        self.timestamp = timestamp
    }
}

public protocol TraceLogger: Sendable {
    func recordDecode(traceID: String, message: String)
    func recordPlan(traceID: String, message: String)
    func recordGuard(traceID: String, message: String)
    func recordExecute(traceID: String, message: String)
    func recordReadback(traceID: String, message: String)
}

public final class InMemoryTraceLogger: TraceLogger, @unchecked Sendable {
    public private(set) var entries: [TraceEntry] = []

    public init() {}

    public func recordDecode(traceID: String, message: String) {
        append(.decode, traceID: traceID, message: message)
    }

    public func recordPlan(traceID: String, message: String) {
        append(.plan, traceID: traceID, message: message)
    }

    public func recordGuard(traceID: String, message: String) {
        append(.guard, traceID: traceID, message: message)
    }

    public func recordExecute(traceID: String, message: String) {
        append(.execute, traceID: traceID, message: message)
    }

    public func recordReadback(traceID: String, message: String) {
        append(.readback, traceID: traceID, message: message)
    }

    private func append(_ stage: TraceStage, traceID: String, message: String) {
        entries.append(TraceEntry(stage: stage, traceID: traceID, message: message))
    }
}

