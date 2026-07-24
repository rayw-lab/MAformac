import Foundation

public enum DomainID: String, Codable, CaseIterable, Equatable, Sendable {
    case vehicle = "vehicle-control"
    case navigation
    case music
    case foodDelivery = "food-delivery"
}

public struct DomainDescriptor: Codable, Equatable, Sendable, Identifiable {
    public var id: String { domainID.rawValue }
    public var domainID: DomainID
    public var displayName: String
    public var enabled: Bool
    public var availability: AgentAvailability
    public var connectorKind: ConnectorKind
    public var proofCap: PresentationProofClass

    public init(
        domainID: DomainID,
        displayName: String,
        enabled: Bool,
        availability: AgentAvailability,
        connectorKind: ConnectorKind,
        proofCap: PresentationProofClass
    ) {
        self.domainID = domainID
        self.displayName = displayName
        self.enabled = enabled
        self.availability = availability
        self.connectorKind = connectorKind
        self.proofCap = proofCap
    }
}
