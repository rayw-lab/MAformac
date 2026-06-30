import Foundation

public enum StateWriteKind: String, Codable, Equatable, Sendable {
    case direct
    case dependency
}

public struct StateWrite: Codable, Equatable, Sendable {
    public var stateKey: String
    public var beforeValue: String?
    public var afterValue: String
    public var scopeOrigin: ScopeOrigin?
    public var writeKind: StateWriteKind

    public init(
        stateKey: String,
        beforeValue: String?,
        afterValue: String,
        scopeOrigin: ScopeOrigin? = nil,
        writeKind: StateWriteKind
    ) {
        self.stateKey = stateKey
        self.beforeValue = beforeValue
        self.afterValue = afterValue
        self.scopeOrigin = scopeOrigin
        self.writeKind = writeKind
    }
}
