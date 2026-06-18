import Foundation

public enum FastPathIntentError: Error, Equatable {
    case noMatch(String)
}

public struct FastPathIntentEngine: Sendable {
    public init() {}

    public func decode(_ text: String) throws -> ToolCallFrame {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized == "打开空调" else {
            throw FastPathIntentError.noMatch(text)
        }

        return ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.toggle",
            toolName: "set_vehicle_control",
            arguments: [
                "state_key": "hvac.ac",
                "target_state": "on"
            ],
            surfacePolicy: .primaryPanel
        )
    }
}

