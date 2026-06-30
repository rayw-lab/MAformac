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
        guard frame.toolName == "set_vehicle_control" else {
            throw DemoActionError.unsupportedTool(frame.toolName)
        }
        if frame.device == "ac", frame.actionPrimitive == "power_on" {
            return store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on"))
        }
        if frame.device == "ac", frame.actionPrimitive == "power_off" {
            return store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "off"))
        }
        guard let key = frame.arguments["state_key"] else {
            throw DemoActionError.missingArgument("state_key")
        }
        guard let desiredValue = frame.arguments["target_state"] else {
            throw DemoActionError.missingArgument("target_state")
        }
        return store.applyMockTransition(DemoMockTransition(key: key, desiredValue: desiredValue))
    }
}
