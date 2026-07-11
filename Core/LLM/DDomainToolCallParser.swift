import Foundation

public struct DDomainParsedToolCall: Equatable, Sendable {
    public let name: String
    public let arguments: [String: String]
}

public enum DDomainToolCallParser {
    public static func parse(
        _ envelope: DDomainCompletionEnvelope,
        policy: ToolPlanCardinalityPolicy
    ) throws -> [DDomainParsedToolCall] {
        try validateMetadata(envelope)
        let bodies = try extractToolCallBodies(from: envelope.content)
        guard bodies.count == envelope.toolCallCount else {
            throw DDomainCompletionRejection.toolCallCountMismatch(
                declared: envelope.toolCallCount,
                parsed: bodies.count
            )
        }
        guard policy.accepts(bodies.count) else {
            throw DDomainCompletionRejection.cardinalityRejected(policy: policy, actual: bodies.count)
        }
        return try bodies.enumerated().map { index, body in
            try parseBody(body, index: index)
        }
    }

    private static func validateMetadata(_ envelope: DDomainCompletionEnvelope) throws {
        guard !envelope.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DDomainCompletionRejection.missingSource
        }
        guard envelope.finishReason == "tool_calls" else {
            throw DDomainCompletionRejection.unsupportedFinishReason(envelope.finishReason)
        }
        guard !envelope.stopReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DDomainCompletionRejection.missingStopReason
        }
        guard envelope.toolCallCount >= 0 else {
            throw DDomainCompletionRejection.invalidDeclaredToolCallCount(envelope.toolCallCount)
        }
        guard envelope.content.lengthOfBytes(using: .utf8) <= DDomainCompletionEnvelope.maximumContentBytes else {
            throw DDomainCompletionRejection.contentTooLarge
        }
    }

    private static func parseBody(_ body: String, index: Int) throws -> DDomainParsedToolCall {
        guard let data = body.data(using: .utf8) else {
            throw DDomainCompletionRejection.invalidToolCallJSON(index: index)
        }
        let object: [String: Any]
        do {
            guard let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw DDomainCompletionRejection.invalidToolCallJSON(index: index)
            }
            object = decoded
        } catch is DDomainCompletionRejection {
            throw DDomainCompletionRejection.invalidToolCallJSON(index: index)
        } catch {
            throw DDomainCompletionRejection.invalidToolCallJSON(index: index)
        }
        guard let name = object["name"] as? String, !name.isEmpty else {
            throw DDomainCompletionRejection.invalidToolCallJSON(index: index)
        }
        guard let rawArguments = object["arguments"] as? [String: Any] else {
            throw DDomainCompletionRejection.invalidToolCallJSON(index: index)
        }
        return DDomainParsedToolCall(name: name, arguments: stringify(rawArguments))
    }

    private static func extractToolCallBodies(from completion: String) throws -> [String] {
        let trimmed = completion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let open = "<tool_call>"
        let close = "</tool_call>"
        var cursor = trimmed.startIndex
        var bodies: [String] = []
        while cursor < trimmed.endIndex {
            guard trimmed[cursor...].hasPrefix(open) else {
                throw DDomainCompletionRejection.invalidContentShape
            }
            let bodyStart = trimmed.index(cursor, offsetBy: open.count)
            guard let closeRange = trimmed.range(of: close, range: bodyStart..<trimmed.endIndex) else {
                throw DDomainCompletionRejection.invalidContentShape
            }
            bodies.append(String(trimmed[bodyStart..<closeRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines))
            cursor = closeRange.upperBound
            while cursor < trimmed.endIndex, trimmed[cursor].isWhitespace {
                cursor = trimmed.index(after: cursor)
            }
        }
        return bodies
    }

    private static func stringify(_ arguments: [String: Any]) -> [String: String] {
        arguments.compactMapValues { value in
            switch value {
            case let string as String:
                return string
            case let number as NSNumber:
                return number.stringValue
            default:
                return nil
            }
        }
    }
}
