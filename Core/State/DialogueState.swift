import Foundation

public struct DialogueTurn: Codable, Equatable, Sendable {
    public enum Role: String, Codable, Equatable, Sendable {
        case user
        case assistant
    }

    public var role: Role
    public var text: String

    public init(role: Role, text: String) {
        self.role = role
        self.text = text
    }
}

public struct DialogueState: Codable, Equatable, Sendable {
    public private(set) var turns: [DialogueTurn]
    public private(set) var focusEntity: String?
    public private(set) var lastReadback: DemoActionReadback?
    public var maxTurns: Int

    public init(
        turns: [DialogueTurn] = [],
        focusEntity: String? = nil,
        lastReadback: DemoActionReadback? = nil,
        maxTurns: Int = 3
    ) {
        self.turns = Array(turns.suffix(max(1, maxTurns)))
        self.focusEntity = focusEntity
        self.lastReadback = lastReadback
        self.maxTurns = max(1, maxTurns)
    }

    public mutating func recordUserText(_ text: String) {
        appendTurn(role: .user, text: text)
    }

    public mutating func recordAssistantText(_ text: String) {
        appendTurn(role: .assistant, text: text)
    }

    public mutating func recordReadbacks(_ readbacks: [DemoActionReadback]) {
        guard let latest = readbacks.last else { return }
        lastReadback = latest
        focusEntity = Self.entityName(forStateKey: latest.key)
    }

    public mutating func clearTransientContext() {
        focusEntity = nil
        lastReadback = nil
    }

    private mutating func appendTurn(role: DialogueTurn.Role, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        turns.append(DialogueTurn(role: role, text: trimmed))
        if turns.count > maxTurns {
            turns = Array(turns.suffix(maxTurns))
        }
    }

    private static func entityName(forStateKey key: String) -> String {
        key.split(separator: ".").first.map(String.init) ?? key
    }
}
