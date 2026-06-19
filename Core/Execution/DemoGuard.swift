import Foundation

public enum DemoGuardDecision: Equatable, Sendable {
    case allow(reason: String)
    case deny(reason: String)
}

public protocol DemoGuard: Sendable {
    func evaluate(_ frame: ToolCallFrame) -> DemoGuardDecision
}

public struct DemoGuardContext: Equatable, Sendable {
    public var confirmedCapabilityIDs: Set<String>
    public var satisfiedPreconditions: Set<String>
    public var occupiedExclusiveBuses: Set<String>

    public init(
        confirmedCapabilityIDs: Set<String> = [],
        satisfiedPreconditions: Set<String> = [],
        occupiedExclusiveBuses: Set<String> = []
    ) {
        self.confirmedCapabilityIDs = confirmedCapabilityIDs
        self.satisfiedPreconditions = satisfiedPreconditions
        self.occupiedExclusiveBuses = occupiedExclusiveBuses
    }
}

public struct DemoSchemaGuard: DemoGuard {
    private let capabilities: [GeneratedCapabilityContract]
    private let capabilityIDToAgentID: [String: String]
    private let capabilityIDToSurfacePolicy: [String: SurfacePolicy]

    public init(
        capabilities: [GeneratedCapabilityContract] = GeneratedCapabilityCatalog.capabilities,
        capabilityIDToAgentID: [String: String] = GeneratedCapabilityCatalog.capabilityIDToAgentID,
        capabilityIDToSurfacePolicy: [String: SurfacePolicy] = GeneratedCapabilityCatalog.capabilityIDToSurfacePolicy
    ) {
        self.capabilities = capabilities
        self.capabilityIDToAgentID = capabilityIDToAgentID
        self.capabilityIDToSurfacePolicy = capabilityIDToSurfacePolicy
    }

    public func evaluate(_ frame: ToolCallFrame) -> DemoGuardDecision {
        evaluate(frame, context: DemoGuardContext())
    }

    public func evaluate(_ frame: ToolCallFrame, context: DemoGuardContext) -> DemoGuardDecision {
        guard let capability = capabilities.first(where: { $0.toolSchema.name == frame.toolName }) else {
            return .deny(reason: "unknown_tool")
        }

        guard capability.id == frame.capabilityID else {
            return .deny(reason: "capability_tool_mismatch")
        }

        guard capabilityIDToAgentID[capability.id] == frame.agentID else {
            return .deny(reason: "agent_not_allowed")
        }

        guard capabilityIDToSurfacePolicy[capability.id] == frame.surfacePolicy else {
            return .deny(reason: "surface_policy_mismatch")
        }

        if let schemaReason = schemaInvalidReason(for: frame.arguments, capability: capability) {
            return .deny(reason: schemaReason)
        }

        if capability.execution.mockBehavior == "update_mock_state",
           (!capability.referenceBinding.writable || !capability.demoGuard.writable) {
            return .deny(reason: "not_writable")
        }

        if requiresConfirmation(capability),
           !context.confirmedCapabilityIDs.contains(capability.id) {
            return .deny(reason: "confirmation_required")
        }

        for precondition in capability.demoGuard.preconditions where !context.satisfiedPreconditions.contains(precondition) {
            return .deny(reason: "precondition_missing:\(precondition)")
        }

        if capability.execution.exclusiveBus != "none",
           context.occupiedExclusiveBuses.contains(capability.execution.exclusiveBus) {
            return .deny(reason: "exclusive_bus_conflict:\(capability.execution.exclusiveBus)")
        }

        return .allow(reason: "schema_valid")
    }

    private func schemaInvalidReason(
        for arguments: [String: JSONValue],
        capability: GeneratedCapabilityContract
    ) -> String? {
        let properties = capability.toolSchema.properties

        for required in capability.toolSchema.required where arguments[required] == nil {
            return "missing_field"
        }

        for (field, value) in arguments {
            guard let property = properties[field] else {
                return "unknown_field"
            }
            if let typeReason = typeInvalidReason(value, property: property) {
                return typeReason
            }
            if let enumReason = enumInvalidReason(value, property: property) {
                return enumReason
            }
            if let range = capability.demoGuard.ranges[field],
               case .int(let actual) = value,
               actual < range.minimum || actual > range.maximum {
                return "out_of_range"
            }
        }

        return nil
    }

    private func typeInvalidReason(_ value: JSONValue, property: GeneratedToolProperty) -> String? {
        switch property.type {
        case "string":
            if case .string = value { return nil }
            return "type_mismatch"
        case "integer":
            if case .int = value { return nil }
            return "type_mismatch"
        case "number":
            switch value {
            case .int, .double:
                return nil
            default:
                return "type_mismatch"
            }
        case "boolean":
            if case .bool = value { return nil }
            return "type_mismatch"
        default:
            return nil
        }
    }

    private func enumInvalidReason(_ value: JSONValue, property: GeneratedToolProperty) -> String? {
        guard !property.enumValues.isEmpty else {
            return nil
        }
        guard case .string(let actual) = value else {
            return nil
        }
        return property.enumValues.contains(actual) ? nil : "invalid_enum"
    }

    private func requiresConfirmation(_ capability: GeneratedCapabilityContract) -> Bool {
        capability.demoGuard.confirmPolicy != "none"
            || capability.demoGuard.riskLevel == "R2"
            || capability.demoGuard.riskLevel == "R3"
    }
}

public struct DemoFastPathGuard: DemoGuard {
    private let schemaGuard: DemoSchemaGuard

    public init(schemaGuard: DemoSchemaGuard = DemoSchemaGuard()) {
        self.schemaGuard = schemaGuard
    }

    public func evaluate(_ frame: ToolCallFrame) -> DemoGuardDecision {
        schemaGuard.evaluate(frame)
    }
}
