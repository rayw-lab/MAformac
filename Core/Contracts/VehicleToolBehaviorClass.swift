import Foundation

public enum VehicleToolBehaviorClass: String, Codable, CaseIterable, Equatable, Sendable {
    case toolCall = "tool_call"
    case clarifyMissingSlot = "clarify_missing_slot"
    case refusalNoAvailableTool = "refusal_no_available_tool"
    case refusalSafetyOrPolicy = "refusal_safety_or_policy"
    case alreadyStateNoop = "already_state_noop"
}
