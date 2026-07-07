import Foundation

public struct ExternalToolSchema: Codable, Equatable, Sendable {
    public var toolName: String
    public var argumentsSchema: [String: JSONValue]
    public var proofClass: PresentationProofClass

    public init(
        toolName: String,
        argumentsSchema: [String: JSONValue] = [:],
        proofClass: PresentationProofClass
    ) {
        self.toolName = toolName
        self.argumentsSchema = argumentsSchema
        self.proofClass = proofClass
    }
}

public enum ExternalToolStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case plannedUnavailable = "planned_connector_disabled"
    case blocked
    case mockNotExecuted = "mock_not_executed"
}

public struct ExternalToolInvocation: Codable, Equatable, Sendable {
    public var domainID: DomainID
    public var toolName: String
    public var arguments: [String: JSONValue]
    public var connector: ConnectorKind
    public var proofClass: PresentationProofClass
    public var status: ExternalToolStatus

    public init(
        domainID: DomainID,
        toolName: String,
        arguments: [String: JSONValue],
        connector: ConnectorKind,
        proofClass: PresentationProofClass,
        status: ExternalToolStatus
    ) {
        self.domainID = domainID
        self.toolName = toolName
        self.arguments = arguments
        self.connector = connector
        self.proofClass = proofClass
        self.status = status
    }
}

public struct ExternalToolResult: Codable, Equatable, Sendable {
    public var domainID: DomainID
    public var toolName: String
    public var status: ExternalToolStatus
    public var proofClass: PresentationProofClass
    public var reasonCode: String
    public var payload: [String: JSONValue]

    public init(
        domainID: DomainID,
        toolName: String,
        status: ExternalToolStatus,
        proofClass: PresentationProofClass,
        reasonCode: String,
        payload: [String: JSONValue] = [:]
    ) {
        self.domainID = domainID
        self.toolName = toolName
        self.status = status
        self.proofClass = proofClass
        self.reasonCode = reasonCode
        self.payload = payload
    }
}

public struct ToolProviderDescriptor: Codable, Equatable, Sendable {
    public var domainID: DomainID
    public var connector: ConnectorKind
    public var enabled: Bool
    public var availability: AgentAvailability
    public var proofCap: PresentationProofClass

    public init(
        domainID: DomainID,
        connector: ConnectorKind,
        enabled: Bool,
        availability: AgentAvailability,
        proofCap: PresentationProofClass
    ) {
        self.domainID = domainID
        self.connector = connector
        self.enabled = enabled
        self.availability = availability
        self.proofCap = proofCap
    }
}

public protocol ToolProvider: Sendable {
    var descriptor: ToolProviderDescriptor { get }
    func listTools() async throws -> [ExternalToolSchema]
    func invoke(_ invocation: ExternalToolInvocation) async throws -> ExternalToolResult
}

public struct DisabledMcpToolProvider: ToolProvider {
    public let descriptor: ToolProviderDescriptor

    public init(domainID: DomainID, proofCap: PresentationProofClass = .localUnit) {
        self.descriptor = ToolProviderDescriptor(
            domainID: domainID,
            connector: .mcp,
            enabled: false,
            availability: .planned,
            proofCap: proofCap
        )
    }

    public func listTools() async throws -> [ExternalToolSchema] {
        []
    }

    public func invoke(_ invocation: ExternalToolInvocation) async throws -> ExternalToolResult {
        ExternalToolResult(
            domainID: invocation.domainID,
            toolName: invocation.toolName,
            status: .plannedUnavailable,
            proofClass: invocation.proofClass,
            reasonCode: "planned_connector_disabled"
        )
    }
}

public enum DomainProviderGuardError: Error, Equatable, Sendable {
    case domainNotRegistered(DomainID)
    case domainMismatch(invocation: DomainID, provider: DomainID)
    case providerDisabled
    case availabilityNotPlanned(AgentAvailability)
    case unsupportedConnector(ConnectorKind)
    case proofClassNotAllowed(PresentationProofClass)
}

public struct DomainProviderGuard: Sendable {
    public static let allowedFirstSliceProofClasses: Set<PresentationProofClass> = [
        .docsLocal,
        .openspecContract,
        .localStaticContract,
        .localUnit,
        .simulatorMock
    ]

    public var registry: DomainRegistry

    public init(registry: DomainRegistry = .default) {
        self.registry = registry
    }

    public func validate(
        _ invocation: ExternalToolInvocation,
        providerDescriptor: ToolProviderDescriptor
    ) throws {
        guard registry.contains(invocation.domainID) else {
            throw DomainProviderGuardError.domainNotRegistered(invocation.domainID)
        }
        guard registry.contains(providerDescriptor.domainID) else {
            throw DomainProviderGuardError.domainNotRegistered(providerDescriptor.domainID)
        }
        guard invocation.domainID == providerDescriptor.domainID else {
            throw DomainProviderGuardError.domainMismatch(
                invocation: invocation.domainID,
                provider: providerDescriptor.domainID
            )
        }
        guard providerDescriptor.enabled else {
            throw DomainProviderGuardError.providerDisabled
        }
        guard providerDescriptor.availability == .planned else {
            throw DomainProviderGuardError.availabilityNotPlanned(providerDescriptor.availability)
        }
        guard providerDescriptor.connector == .mcp else {
            throw DomainProviderGuardError.unsupportedConnector(providerDescriptor.connector)
        }
        guard invocation.connector == .mcp else {
            throw DomainProviderGuardError.unsupportedConnector(invocation.connector)
        }
        guard Self.allowedFirstSliceProofClasses.contains(providerDescriptor.proofCap) else {
            throw DomainProviderGuardError.proofClassNotAllowed(providerDescriptor.proofCap)
        }
        guard Self.allowedFirstSliceProofClasses.contains(invocation.proofClass) else {
            throw DomainProviderGuardError.proofClassNotAllowed(invocation.proofClass)
        }
    }
}
