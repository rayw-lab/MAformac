import Foundation

public enum ToolCallCandidateSource: String, Codable, Equatable, Sendable {
    case rawToolCall = "raw_tool_call"
    case contentFallback = "content_fallback"
    case fastPath = "fast_path"
}

public enum ToolCallStopReason: Codable, Equatable, Sendable {
    case stop
    case length
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "stop":
            self = .stop
        case "length":
            self = .length
        default:
            self = .unknown(rawValue)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .stop:
            return "stop"
        case .length:
            return "length"
        case .unknown(let value):
            return value
        }
    }
}

public struct ToolCallCandidate: Codable, Equatable, Sendable {
    public let toolName: String
    public let arguments: [String: JSONValue]
    public let source: ToolCallCandidateSource
    public let rawContent: String?
    public let stopReason: ToolCallStopReason?

    public init(
        toolName: String,
        arguments: [String: JSONValue],
        source: ToolCallCandidateSource,
        rawContent: String? = nil,
        stopReason: String? = nil
    ) {
        self.toolName = toolName
        self.arguments = arguments
        self.source = source
        self.rawContent = rawContent
        self.stopReason = stopReason.map(ToolCallStopReason.init(rawValue:))
    }

    public init(
        toolName: String,
        argumentsValue: JSONValue,
        source: ToolCallCandidateSource,
        rawContent: String? = nil,
        stopReason: String? = nil
    ) throws {
        self.init(
            toolName: toolName,
            arguments: try Self.normalize(argumentsValue),
            source: source,
            rawContent: rawContent,
            stopReason: stopReason
        )
    }

    private static func normalize(_ value: JSONValue) throws -> [String: JSONValue] {
        switch value {
        case .object(let object):
            return object
        case .string(let rawString):
            return try normalizeString(rawString)
        case .null, .bool, .int, .double, .array:
            return ["_value": value]
        }
    }

    private static func normalizeString(_ rawString: String) throws -> [String: JSONValue] {
        let trimmed = rawString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first,
              ["{", "[", "\"", "t", "f", "n", "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(first)
        else {
            return ["_value": .string(rawString)]
        }

        let decoded: JSONValue
        do {
            decoded = try JSONDecoder().decode(JSONValue.self, from: Data(trimmed.utf8))
        } catch {
            throw ToolCallDecodeError.malformed("arguments_json")
        }

        switch decoded {
        case .object(let object):
            return object
        case .null, .bool, .int, .double, .string, .array:
            return ["_value": decoded]
        }
    }
}

public enum ToolCallDecodeFailureKind: String, Codable, Equatable, Sendable {
    case no_tool_call
    case malformed
    case unknown_tool
    case missing_field
    case type_mismatch
    case out_of_range

    public static let acceptanceTable: [ToolCallDecodeFailureKind] = [
        .no_tool_call,
        .malformed,
        .unknown_tool,
        .missing_field,
        .type_mismatch,
        .out_of_range
    ]
}

public enum ToolCallSchemaInvalidReason: Error, Equatable, Sendable {
    case unknown_tool(String)
    case missing_field(toolName: String, field: String)
    case type_mismatch(toolName: String, field: String, expected: String, actual: String)
    case out_of_range(toolName: String, field: String, minimum: Int, maximum: Int, actual: Int)
}

public enum ToolCallDecodeError: Error, Equatable, Sendable {
    case no_tool_call
    case malformed(String)
    case schema_invalid(ToolCallSchemaInvalidReason)
}

public enum ToolCallDecodeRecoveryDecision: Equatable, Sendable {
    case retry
    case clarify
}

public struct ToolCallDecodeRetryPolicy: Sendable {
    public let maxMalformedRetries: Int

    public init(maxMalformedRetries: Int = 1) {
        self.maxMalformedRetries = maxMalformedRetries
    }

    public func decision(
        for error: ToolCallDecodeError,
        priorMalformedRetries: Int
    ) -> ToolCallDecodeRecoveryDecision {
        switch error {
        case .malformed where priorMalformedRetries < maxMalformedRetries:
            return .retry
        case .no_tool_call, .malformed, .schema_invalid:
            return .clarify
        }
    }
}

public struct ToolCallDecoder: Sendable {
    private let contentFallbackEnabled: Bool

    public init(contentFallbackEnabled: Bool = true) {
        self.contentFallbackEnabled = contentFallbackEnabled
    }

    public func decode(_ candidate: ToolCallCandidate, traceID: String = UUID().uuidString) throws -> ToolCallFrame {
        guard let capability = GeneratedCapabilityCatalog.capability(toolName: candidate.toolName) else {
            throw ToolCallDecodeError.schema_invalid(.unknown_tool(candidate.toolName))
        }

        try validate(candidate.arguments, for: capability)

        guard let agentID = GeneratedCapabilityCatalog.capabilityIDToAgentID[capability.id],
              let surfacePolicy = GeneratedCapabilityCatalog.capabilityIDToSurfacePolicy[capability.id]
        else {
            throw ToolCallDecodeError.schema_invalid(.unknown_tool(candidate.toolName))
        }

        return ToolCallFrame(
            traceID: traceID,
            agentID: agentID,
            capabilityID: capability.id,
            toolName: candidate.toolName,
            arguments: candidate.arguments,
            surfacePolicy: surfacePolicy
        )
    }

    public func decodeFirst(_ candidates: [ToolCallCandidate], traceID: String = UUID().uuidString) throws -> ToolCallFrame {
        guard let candidate = candidates.first else {
            throw ToolCallDecodeError.no_tool_call
        }
        return try decode(candidate, traceID: traceID)
    }

    public func failureKind(for error: ToolCallDecodeError) -> ToolCallDecodeFailureKind {
        switch error {
        case .no_tool_call:
            return .no_tool_call
        case .malformed:
            return .malformed
        case .schema_invalid(let violation):
            switch violation {
            case .unknown_tool:
                return .unknown_tool
            case .missing_field:
                return .missing_field
            case .type_mismatch:
                return .type_mismatch
            case .out_of_range:
                return .out_of_range
            }
        }
    }

    public func contentFallbackCandidate(from content: String, stopReason: String? = nil) throws -> ToolCallCandidate? {
        guard contentFallbackEnabled else {
            return nil
        }
        guard !content.contains("<think>") else {
            throw ToolCallDecodeError.malformed("think_leak")
        }
        guard let jsonText = singleBareJSONObject(in: content) else {
            return nil
        }

        let data = Data(jsonText.utf8)
        let envelope: ContentFallbackEnvelope
        do {
            envelope = try JSONDecoder().decode(ContentFallbackEnvelope.self, from: data)
        } catch {
            throw ToolCallDecodeError.malformed("bad_json")
        }

        guard let arguments = envelope.arguments.objectValue else {
            throw ToolCallDecodeError.malformed("arguments_not_object")
        }

        return ToolCallCandidate(
            toolName: envelope.name,
            arguments: arguments,
            source: .contentFallback,
            rawContent: jsonText,
            stopReason: stopReason
        )
    }

    private func validate(_ arguments: [String: JSONValue], for capability: GeneratedCapabilityContract) throws {
        let toolName = capability.toolSchema.name
        let properties = capability.toolSchema.properties

        for required in capability.toolSchema.required where arguments[required] == nil {
            throw ToolCallDecodeError.schema_invalid(.missing_field(toolName: toolName, field: required))
        }

        for (field, value) in arguments {
            guard let property = properties[field] else {
                throw ToolCallDecodeError.schema_invalid(.type_mismatch(toolName: toolName, field: field, expected: "declared_field", actual: field))
            }
            try validateType(value, property: property, toolName: toolName, field: field)
            try validateEnum(value, property: property, toolName: toolName, field: field)
            try validateRange(value, capability: capability, toolName: toolName, field: field)
        }
    }

    private func validateType(
        _ value: JSONValue,
        property: GeneratedToolProperty,
        toolName: String,
        field: String
    ) throws {
        let actual = value.typeName
        switch property.type {
        case "string":
            guard case .string = value else {
                throw ToolCallDecodeError.schema_invalid(.type_mismatch(toolName: toolName, field: field, expected: "string", actual: actual))
            }
        case "integer":
            guard case .int = value else {
                throw ToolCallDecodeError.schema_invalid(.type_mismatch(toolName: toolName, field: field, expected: "integer", actual: actual))
            }
        case "number":
            switch value {
            case .int, .double:
                return
            default:
                throw ToolCallDecodeError.schema_invalid(.type_mismatch(toolName: toolName, field: field, expected: "number", actual: actual))
            }
        case "boolean":
            guard case .bool = value else {
                throw ToolCallDecodeError.schema_invalid(.type_mismatch(toolName: toolName, field: field, expected: "boolean", actual: actual))
            }
        default:
            return
        }
    }

    private func validateEnum(
        _ value: JSONValue,
        property: GeneratedToolProperty,
        toolName: String,
        field: String
    ) throws {
        guard !property.enumValues.isEmpty else {
            return
        }
        guard case .string(let actual) = value else {
            return
        }
        guard property.enumValues.contains(actual) else {
            throw ToolCallDecodeError.schema_invalid(.type_mismatch(
                toolName: toolName,
                field: field,
                expected: "enum:\(property.enumValues.joined(separator: "|"))",
                actual: actual
            ))
        }
    }

    private func validateRange(
        _ value: JSONValue,
        capability: GeneratedCapabilityContract,
        toolName: String,
        field: String
    ) throws {
        guard let range = capability.demoGuard.ranges[field],
              case .int(let actual) = value
        else {
            return
        }
        guard actual >= range.minimum, actual <= range.maximum else {
            throw ToolCallDecodeError.schema_invalid(
                .out_of_range(toolName: toolName, field: field, minimum: range.minimum, maximum: range.maximum, actual: actual)
            )
        }
    }

    private func singleBareJSONObject(in content: String) -> String? {
        guard let firstBrace = content.firstIndex(of: "{") else {
            return nil
        }
        let leading = content[..<firstBrace].trimmingCharacters(in: .whitespacesAndNewlines)
        guard leading.isEmpty else {
            return nil
        }

        var depth = 0
        var closingBrace: String.Index?
        var index = firstBrace
        while index < content.endIndex {
            let character = content[index]
            if character == "{" {
                depth += 1
            } else if character == "}" {
                depth -= 1
                if depth == 0 {
                    closingBrace = index
                    break
                }
            }
            index = content.index(after: index)
        }

        guard let closingBrace, depth == 0 else {
            return nil
        }

        let afterClosingBrace = content.index(after: closingBrace)
        let trailing = content[afterClosingBrace...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard trailing.isEmpty else {
            return nil
        }

        return String(content[firstBrace...closingBrace])
    }
}

private struct ContentFallbackEnvelope: Decodable {
    let name: String
    let arguments: JSONValue
}

extension JSONValue {
    fileprivate var typeName: String {
        switch self {
        case .null:
            return "null"
        case .bool:
            return "bool"
        case .int:
            return "int"
        case .double:
            return "double"
        case .string:
            return "string"
        case .array:
            return "array"
        case .object:
            return "object"
        }
    }
}
