import Foundation

public enum DemoActionError: Error, Equatable {
    case unsupportedTool(String)
    case missingArgument(String)
    case guardDenied(String)
}

public struct DemoActionExecutor: Sendable {
    public init() {}

    @MainActor
    public func applyMockTransition(_ frame: ToolCallFrame, store: DemoVehicleStateStore) throws -> DemoActionReadback {
        guard let capability = GeneratedCapabilityCatalog.capability(toolName: frame.toolName) else {
            throw DemoActionError.unsupportedTool(frame.toolName)
        }

        switch capability.execution.mockBehavior {
        case "update_mock_state":
            let desiredValue = try desiredMockValue(from: frame, capability: capability)
            return store.applyMockTransition(
                DemoMockTransition(key: capability.execution.stateCell, desiredValue: desiredValue)
            )
        case "read_mock_state":
            return store.readback(for: capability.execution.stateCell)
        default:
            throw DemoActionError.unsupportedTool(frame.toolName)
        }
    }

    private func desiredMockValue(
        from frame: ToolCallFrame,
        capability: GeneratedCapabilityContract
    ) throws -> String {
        for key in ["power", "level", "percent", "color", "topic", "target_temperature", "delta", "mode"] {
            if let value = frame.arguments[key]?.scalarString {
                return value
            }
        }

        for key in capability.toolSchema.required {
            if let value = frame.arguments[key]?.scalarString {
                return value
            }
        }

        throw DemoActionError.missingArgument(capability.toolSchema.required.first ?? "value")
    }
}
