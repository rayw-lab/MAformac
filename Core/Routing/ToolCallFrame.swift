import Foundation

public enum SurfacePolicy: String, Codable, Sendable, CaseIterable {
    case primaryPanel = "primary_panel"
    case overlayCard = "overlay_card"
    case splitPanel = "split_panel"
    case fullscreen
}

public enum AgentAvailability: String, Codable, Sendable {
    case available
    case planned
}

public enum ConnectorKind: String, Codable, Sendable {
    case local
    case mock
    case mcp
}

public struct AgentDescriptor: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var displayName: String
    public var connector: ConnectorKind
    public var enabled: Bool
    public var availability: AgentAvailability
    public var capabilityIDs: [String]
    public var surfacePolicy: SurfacePolicy

    public init(
        id: String,
        displayName: String,
        connector: ConnectorKind,
        enabled: Bool,
        availability: AgentAvailability,
        capabilityIDs: [String],
        surfacePolicy: SurfacePolicy
    ) {
        self.id = id
        self.displayName = displayName
        self.connector = connector
        self.enabled = enabled
        self.availability = availability
        self.capabilityIDs = capabilityIDs
        self.surfacePolicy = surfacePolicy
    }
}

public struct ToolCallFrame: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var traceID: String
    public var agentID: String
    public var capabilityID: String
    public var toolName: String
    public var arguments: [String: JSONValue]
    public var surfacePolicy: SurfacePolicy

    public init(
        id: String = UUID().uuidString,
        traceID: String = UUID().uuidString,
        agentID: String,
        capabilityID: String,
        toolName: String,
        arguments: [String: JSONValue],
        surfacePolicy: SurfacePolicy = .primaryPanel
    ) {
        self.id = id
        self.traceID = traceID
        self.agentID = agentID
        self.capabilityID = capabilityID
        self.toolName = toolName
        self.arguments = arguments
        self.surfacePolicy = surfacePolicy
    }

    public init(
        id: String = UUID().uuidString,
        traceID: String = UUID().uuidString,
        agentID: String,
        capabilityID: String,
        toolName: String,
        stringArguments: [String: String],
        surfacePolicy: SurfacePolicy = .primaryPanel
    ) {
        self.init(
            id: id,
            traceID: traceID,
            agentID: agentID,
            capabilityID: capabilityID,
            toolName: toolName,
            arguments: stringArguments.mapValues { .string($0) },
            surfacePolicy: surfacePolicy
        )
    }
}
