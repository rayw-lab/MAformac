import Foundation

public enum DemoGuardDecision: Equatable, Sendable {
    case allow(reason: String)
    case deny(reason: String)
}

public protocol DemoGuard: Sendable {
    func evaluate(_ frame: ToolCallFrame) -> DemoGuardDecision
}

public struct DemoFastPathGuard: DemoGuard {
    public init() {}

    public func evaluate(_ frame: ToolCallFrame) -> DemoGuardDecision {
        guard frame.agentID == "vehicle-control" else {
            return .deny(reason: "agent_not_allowed")
        }
        guard frame.capabilityID == "vehicle.ac.toggle" else {
            return .deny(reason: "capability_not_allowed")
        }
        guard frame.arguments["target_state"] == "on" else {
            return .deny(reason: "target_state_not_allowed")
        }
        return .allow(reason: "single_fast_path_allow")
    }
}

