import Foundation

public struct DDomainParsedToolCall: Equatable, Sendable {
    public let name: String
    public let arguments: [String: String]
}

public enum DDomainToolCallParser {
    public static func parse(_ completion: String) throws -> DDomainParsedToolCall {
        let body = try extractToolCallBody(from: completion)
        guard let data = body.data(using: .utf8),
              let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DDomainToolPlanFailure.parseFailed
        }
        guard let name = object["name"] as? String, !name.isEmpty else {
            throw DDomainToolPlanFailure.parseFailed
        }
        guard let rawArguments = object["arguments"] as? [String: Any] else {
            throw DDomainToolPlanFailure.parseFailed
        }
        return DDomainParsedToolCall(name: name, arguments: stringify(rawArguments))
    }

    private static func extractToolCallBody(from completion: String) throws -> String {
        let trimmed = completion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let start = trimmed.range(of: "<tool_call>"),
              let end = trimmed.range(of: "</tool_call>", range: start.upperBound..<trimmed.endIndex) else {
            throw DDomainToolPlanFailure.parseFailed
        }
        return String(trimmed[start.upperBound..<end.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
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
