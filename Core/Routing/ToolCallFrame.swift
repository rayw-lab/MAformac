import Foundation

public enum SurfacePolicy: String, Codable, Sendable, CaseIterable {
    case primaryPanel = "primary_panel"
    case overlayCard = "overlay_card"
    case splitPanel = "split_panel"
    case fullscreen
}

public enum AgentAvailability: String, Codable, Sendable {
    case available
    case planned
}

public enum ConnectorKind: String, Codable, Sendable {
    case local
    case mock
    case mcp
}

public enum JSONValue: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.typeMismatch(
                JSONValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public enum ToolCandidateSource: String, Codable, Equatable, Sendable {
    case upstreamToolCall = "upstream_tool_call"
    case contentFallback = "content_fallback"
    case parserRepair = "parser_repair"
    case fastPath = "fast_path"
}

public enum SchemaInvalidReason: Equatable, Sendable {
    case unknownTool(String)
    case missingField(String)
    case typeMismatch(String)
    case outOfRange(String)
    case unknownEnum(String)
    case multipleFrames
}

public enum MalformedReason: Equatable, Sendable {
    case contentFallbackDisabled
    case invalidJSON
    case nonObjectArguments
    case lengthTruncated
}

/// 解码完成时的 stop/finish 元信息。控制路径以此判断候选是否可信。
/// spec tool-execution:16/23-26 — finish_reason=length 表示输出被截断，不得 repair 成动作。
public enum DecodeFinishReason: String, Codable, Equatable, Sendable {
    case stop
    case length
    case toolCalls = "tool_calls"
    case contentFilter = "content_filter"
    case unknown
}

/// decode 的统一输入：原始 content + completion 元信息。
/// 旧 content-only 入口由默认值（finishReason=.stop, toolCallCount=1）保持向后兼容。
public struct ToolCallDecodeInput: Equatable, Sendable {
    public var content: String
    public var finishReason: DecodeFinishReason
    public var stopReason: String?
    public var toolCallCount: Int

    public init(
        content: String,
        finishReason: DecodeFinishReason = .stop,
        stopReason: String? = nil,
        toolCallCount: Int = 1
    ) {
        self.content = content
        self.finishReason = finishReason
        self.stopReason = stopReason
        self.toolCallCount = toolCallCount
    }
}

public enum ToolExecutionError: Error, Equatable, Sendable {
    case noToolCall
    case malformed(MalformedReason)
    case schemaInvalid(SchemaInvalidReason)
    case semanticInvalid(String)
    case staleState(expected: Int, actual: Int)
    case guardDenied(String)
    case readbackMismatch(expected: String, actual: String)
    case thinkLeak
}

public struct AgentDescriptor: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var displayName: String
    public var connector: ConnectorKind
    public var enabled: Bool
    public var availability: AgentAvailability
    public var capabilityIDs: [String]
    public var surfacePolicy: SurfacePolicy

    public init(
        id: String,
        displayName: String,
        connector: ConnectorKind,
        enabled: Bool,
        availability: AgentAvailability,
        capabilityIDs: [String],
        surfacePolicy: SurfacePolicy
    ) {
        self.id = id
        self.displayName = displayName
        self.connector = connector
        self.enabled = enabled
        self.availability = availability
        self.capabilityIDs = capabilityIDs
        self.surfacePolicy = surfacePolicy
    }
}

public struct ToolCallFrame: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var traceID: String
    public var agentID: String
    public var capabilityID: String
    public var toolName: String
    public var device: String
    public var actionPrimitive: String
    public var slots: [String: String]
    public var value: ContractValue
    public var stateRevision: Int
    public var candidateSource: ToolCandidateSource
    public var rawPayload: JSONValue
    public var surfacePolicy: SurfacePolicy

    public var arguments: [String: String] {
        var result = slots
        result["device"] = device
        result["action_primitive"] = actionPrimitive
        result["value.ref"] = value.ref
        result["value.direct"] = value.direct
        result["value.offset"] = value.offset
        result["value.type"] = value.type
        result["state_revision"] = String(stateRevision)
        if candidateSource == .fastPath {
            result["state_key"] = device
            if !value.offset.isEmpty {
                result["target_state"] = value.offset
            }
        }
        return result
    }

    public init(
        id: String = UUID().uuidString,
        traceID: String = UUID().uuidString,
        agentID: String,
        capabilityID: String,
        toolName: String,
        device: String,
        actionPrimitive: String,
        slots: [String: String] = [:],
        value: ContractValue = ContractValue(),
        stateRevision: Int = 0,
        candidateSource: ToolCandidateSource,
        rawPayload: JSONValue = .object([:]),
        surfacePolicy: SurfacePolicy = .primaryPanel
    ) {
        self.id = id
        self.traceID = traceID
        self.agentID = agentID
        self.capabilityID = capabilityID
        self.toolName = toolName
        self.device = device
        self.actionPrimitive = actionPrimitive
        self.slots = slots
        self.value = value
        self.stateRevision = stateRevision
        self.candidateSource = candidateSource
        self.rawPayload = rawPayload
        self.surfacePolicy = surfacePolicy
    }

    public init(
        id: String = UUID().uuidString,
        traceID: String = UUID().uuidString,
        agentID: String,
        capabilityID: String,
        toolName: String,
        arguments: [String: String],
        surfacePolicy: SurfacePolicy = .primaryPanel
    ) {
        self.init(
            id: id,
            traceID: traceID,
            agentID: agentID,
            capabilityID: capabilityID,
            toolName: toolName,
            device: arguments["device"] ?? arguments["state_key"] ?? capabilityID,
            actionPrimitive: arguments["action_primitive"] ?? "power_on",
            slots: arguments.filter { key, _ in !["device", "action_primitive", "state_key", "target_state"].contains(key) },
            value: ContractValue(offset: arguments["target_state"] ?? ""),
            stateRevision: Int(arguments["state_revision"] ?? "") ?? 0,
            candidateSource: .fastPath,
            rawPayload: .object(arguments.mapValues { .string($0) }),
            surfacePolicy: surfacePolicy
        )
    }
}

public struct NoActionFrame: Equatable, Codable, Sendable {
    public var reason: String

    public init(reason: String) {
        self.reason = reason
    }
}

public struct ClarifyFrame: Equatable, Codable, Sendable {
    public var question: String

    public init(question: String) {
        self.question = question
    }
}

public enum RuntimeFrame: Equatable, Sendable {
    case tool(ToolCallFrame)
    case noAction(NoActionFrame)
    case clarify(ClarifyFrame)

    public static func requireExactlyOne(_ frames: [RuntimeFrame]) throws -> RuntimeFrame {
        guard !frames.isEmpty else {
            throw ToolExecutionError.noToolCall
        }
        guard frames.count == 1, let frame = frames.first else {
            throw ToolExecutionError.schemaInvalid(.multipleFrames)
        }
        return frame
    }
}

public struct ToolCallCandidateDecoder: Sendable {
    public var contentFallbackEnabled: Bool
    public var allowedActionPrimitives: Set<String>
    public var allowedValueTypes: Set<String>

    public init(
        contentFallbackEnabled: Bool = false,
        allowedActionPrimitives: Set<String> = Self.defaultAllowedActionPrimitives,
        allowedValueTypes: Set<String> = Self.defaultAllowedValueTypes
    ) {
        self.contentFallbackEnabled = contentFallbackEnabled
        self.allowedActionPrimitives = allowedActionPrimitives
        self.allowedValueTypes = allowedValueTypes
    }

    /// 元信息感知的解码入口。先用 completion 元信息做 fail-closed gate,再走 content fallback。
    /// spec tool-execution:16「finish reason length / 多 tool call → reject,不 repair-to-action」。
    public func decode(_ input: ToolCallDecodeInput) throws -> ToolCallFrame {
        // length 截断:即使 JSON 碰巧可解析,也是被截断的不可信输出,标 decode failed,不进 repair。
        guard input.finishReason != .length else {
            throw ToolExecutionError.malformed(.lengthTruncated)
        }
        // 单发约束:tool_call_count > 1 在 decode 边界就拒,不选其一执行(spec:16/18-21)。
        guard input.toolCallCount <= 1 else {
            throw ToolExecutionError.schemaInvalid(.multipleFrames)
        }
        return try decodeContentFallback(input.content)
    }

    public func decodeContentFallback(_ content: String) throws -> ToolCallFrame {
        if content.contains("<think>") || content.contains("</think>") {
            throw ToolExecutionError.thinkLeak
        }
        guard contentFallbackEnabled else {
            throw ToolExecutionError.malformed(.contentFallbackDisabled)
        }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8),
              let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ToolExecutionError.malformed(.invalidJSON)
        }

        guard let device = object["device"] as? String, !device.isEmpty else {
            throw ToolExecutionError.schemaInvalid(.missingField("device"))
        }
        guard let actionPrimitive = object["action_primitive"] as? String, !actionPrimitive.isEmpty else {
            throw ToolExecutionError.schemaInvalid(.missingField("action_primitive"))
        }
        guard allowedActionPrimitives.contains(actionPrimitive) else {
            throw ToolExecutionError.schemaInvalid(.unknownEnum("action_primitive"))
        }

        let slots = try decodeStringMap(object["slot"], field: "slot") ?? [:]
        let value = try decodeValue(object["value"])
        if !value.type.isEmpty, !allowedValueTypes.contains(value.type) {
            throw ToolExecutionError.schemaInvalid(.unknownEnum("value.type"))
        }
        let stateRevision = object["state_revision"] as? Int ?? 0

        return ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.\(device)",
            toolName: "vehicle_control",
            device: device,
            actionPrimitive: actionPrimitive,
            slots: slots,
            value: value,
            stateRevision: stateRevision,
            candidateSource: .contentFallback,
            rawPayload: try JSONDecoder().decode(JSONValue.self, from: data)
        )
    }

    public func decodeNonStreamingCompletion(_ completion: String) throws -> ToolCallFrame {
        let stripped = stripThinking(from: completion)
        let candidate = extractFencedJSON(from: stripped) ?? stripped.trimmingCharacters(in: .whitespacesAndNewlines)
        var frame = try decodeContentFallback(candidate)
        frame.candidateSource = .parserRepair
        return frame
    }

    private func stripThinking(from content: String) -> String {
        var result = content
        while let start = result.range(of: "<think>"),
              let end = result.range(of: "</think>", range: start.upperBound..<result.endIndex) {
            result.removeSubrange(start.lowerBound..<end.upperBound)
        }
        return result
    }

    private func extractFencedJSON(from content: String) -> String? {
        guard let fenceStart = content.range(of: "```json") ?? content.range(of: "```") else {
            return nil
        }
        let bodyStart = fenceStart.upperBound
        guard let fenceEnd = content.range(of: "```", range: bodyStart..<content.endIndex) else {
            return nil
        }
        return String(content[bodyStart..<fenceEnd.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func decodeStringMap(_ raw: Any?, field: String) throws -> [String: String]? {
        guard let raw else {
            return nil
        }
        guard let map = raw as? [String: Any] else {
            throw ToolExecutionError.schemaInvalid(.typeMismatch(field))
        }
        var result: [String: String] = [:]
        for (key, value) in map {
            guard let stringValue = value as? String else {
                throw ToolExecutionError.schemaInvalid(.typeMismatch(field))
            }
            result[key] = stringValue
        }
        return result
    }

    private func decodeValue(_ raw: Any?) throws -> ContractValue {
        guard let raw else {
            return ContractValue()
        }
        guard let map = raw as? [String: Any] else {
            throw ToolExecutionError.schemaInvalid(.typeMismatch("value"))
        }
        func string(_ key: String) throws -> String {
            guard let value = map[key] else {
                return ""
            }
            if let stringValue = value as? String {
                return stringValue
            }
            if let intValue = value as? Int {
                return String(intValue)
            }
            if let doubleValue = value as? Double {
                return String(doubleValue)
            }
            throw ToolExecutionError.schemaInvalid(.typeMismatch("value.\(key)"))
        }
        return ContractValue(
            ref: try string("ref"),
            direct: try string("direct"),
            offset: try string("offset"),
            type: try string("type")
        )
    }

    public static let defaultAllowedActionPrimitives: Set<String> = [
        "power_on",
        "power_off",
        "query",
        "adjust_to_number",
        "by_percent",
        "increase_by_number",
        "decrease_by_number",
        "increase_by_exp",
        "decrease_by_exp",
        "adjust_to_gear",
        "adjust_to_max",
        "adjust_to_min",
        "set_mode",
        "pause_function",
        "pause_action",
        "pause_opening",
        "pause_position_function",
        "pause_position_opening"
    ]

    public static let defaultAllowedValueTypes: Set<String> = ["", "SPOT", "EXP", "PERCENT", "MAX", "MIN"]
}
