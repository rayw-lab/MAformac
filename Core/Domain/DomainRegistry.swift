import Foundation

public struct DomainRegistry: Equatable, Sendable {
    public static let `default` = DomainRegistry(descriptors: [
        DomainDescriptor(
            domainID: .navigation,
            displayName: "导航",
            enabled: false,
            availability: .planned,
            connectorKind: .mcp,
            proofCap: .openspecContract
        ),
        DomainDescriptor(
            domainID: .music,
            displayName: "音乐",
            enabled: false,
            availability: .planned,
            connectorKind: .mcp,
            proofCap: .openspecContract
        ),
        DomainDescriptor(
            domainID: .foodDelivery,
            displayName: "外卖",
            enabled: false,
            availability: .planned,
            connectorKind: .mcp,
            proofCap: .openspecContract
        )
    ])

    private let descriptorsByDomainID: [DomainID: DomainDescriptor]
    private let domainOrder: [DomainID]

    public init(descriptors: [DomainDescriptor]) {
        self.domainOrder = descriptors.map(\.domainID)
        self.descriptorsByDomainID = Dictionary(uniqueKeysWithValues: descriptors.map { ($0.domainID, $0) })
    }

    public var allDescriptors: [DomainDescriptor] {
        domainOrder.compactMap { descriptorsByDomainID[$0] }
    }

    public func descriptor(for domainID: DomainID) -> DomainDescriptor? {
        descriptorsByDomainID[domainID]
    }

    public func contains(_ domainID: DomainID) -> Bool {
        descriptor(for: domainID) != nil
    }
}
