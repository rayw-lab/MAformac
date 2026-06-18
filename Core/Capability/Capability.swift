import Foundation

public struct ToolSchema: Codable, Equatable, Sendable {
    public var name: String
    public var description: String
    public var parameters: [String: String]

    public init(name: String, description: String, parameters: [String: String] = [:]) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

public struct CapabilityMatch: Equatable, Sendable {
    public var confidence: Double
    public var reason: String

    public init(confidence: Double, reason: String) {
        self.confidence = confidence
        self.reason = reason
    }
}

public struct CapabilityResult: Equatable, Sendable {
    public var readback: DemoActionReadback
    public var traceID: String

    public init(readback: DemoActionReadback, traceID: String) {
        self.readback = readback
        self.traceID = traceID
    }
}

public protocol Capability: Sendable {
    var id: String { get }
    var schema: ToolSchema { get }

    func match(text: String) -> CapabilityMatch
    @MainActor func handle(_ frame: ToolCallFrame, store: DemoVehicleStateStore) async throws -> CapabilityResult
}

public final class CapabilityRegistry: @unchecked Sendable {
    private var capabilitiesByID: [String: any Capability]

    public init(capabilities: [any Capability] = []) {
        self.capabilitiesByID = Dictionary(uniqueKeysWithValues: capabilities.map { ($0.id, $0) })
    }

    public func register(_ capability: any Capability) {
        capabilitiesByID[capability.id] = capability
    }

    public func capability(id: String) -> (any Capability)? {
        capabilitiesByID[id]
    }
}

