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
            capabilityID: "cabin.ac",
            toolName: "set_cabin_ac",
            stringArguments: [
                "power": "on"
            ],
            surfacePolicy: .primaryPanel
        )
    }
}
