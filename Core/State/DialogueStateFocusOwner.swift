import Foundation

// MARK: - Focus expiry

public enum DialogueFocusExpiryReason: String, Codable, Equatable, Sendable {
    case ownerWindowEvicted = "owner_window_evicted"
    case terminalClear = "terminal_clear"
    case sessionClear = "session_clear"
    case identityFence = "identity_fence"
    case unauthorisedInjection = "unauthorised_injection"
}

// MARK: - Activation bound

/// focus 何时被视为失效。
///
/// - `.untilOwnerWindowEvicted`：R5 owner-window eviction 触发 invalid。
/// - `.untilTerminalClear` / `.untilSessionClear` / `.untilIdentityFence`：R6 effect matrix 层触发。
/// - `.revoked(reason:)`：显式 revocation（e.g. unauthorised injection）。
public enum DialogueFocusActivationBound: Codable, Equatable, Sendable {
    case untilOwnerWindowEvicted
    case untilTerminalClear
    case untilSessionClear
    case untilIdentityFence
    case revoked(reason: DialogueFocusExpiryReason)
    case unknown(rawValue: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        switch kind {
        case "until_owner_window_evicted": self = .untilOwnerWindowEvicted
        case "until_terminal_clear": self = .untilTerminalClear
        case "until_session_clear": self = .untilSessionClear
        case "until_identity_fence": self = .untilIdentityFence
        case "revoked":
            let reason = try container.decode(DialogueFocusExpiryReason.self, forKey: .reason)
            self = .revoked(reason: reason)
        default:
            self = .unknown(rawValue: kind)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .untilOwnerWindowEvicted:
            try container.encode("until_owner_window_evicted", forKey: .kind)
        case .untilTerminalClear:
            try container.encode("until_terminal_clear", forKey: .kind)
        case .untilSessionClear:
            try container.encode("until_session_clear", forKey: .kind)
        case .untilIdentityFence:
            try container.encode("until_identity_fence", forKey: .kind)
        case .revoked(let reason):
            try container.encode("revoked", forKey: .kind)
            try container.encode(reason, forKey: .reason)
        case .unknown(let raw):
            try container.encode(raw, forKey: .kind)
        }
    }

    public var isKnown: Bool {
        if case .unknown = self { return false }
        return true
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case reason
    }
}

// MARK: - Focus owner window

public struct DialogueFocusOwnerWindow: Codable, Equatable, Sendable {
    public let ownerWindowRef: DialogueSourceGroupRef
    public let focusValidityReason: DialogueFieldValidityReason
    public let activeUntil: DialogueFocusActivationBound
    public let schemaVersion: DialogueStateSchemaVersion

    public init(
        ownerWindowRef: DialogueSourceGroupRef,
        focusValidityReason: DialogueFieldValidityReason,
        activeUntil: DialogueFocusActivationBound,
        schemaVersion: DialogueStateSchemaVersion
    ) {
        self.ownerWindowRef = ownerWindowRef
        self.focusValidityReason = focusValidityReason
        self.activeUntil = activeUntil
        self.schemaVersion = schemaVersion
    }

    /// 纯函数：给定当前仍 active 的 owner window ref 集合，判定 focus 是否仍有效。
    ///
    /// - unpaired supersession 组不能作为 owner（R5 "Unpaired groups SHALL NOT renew focus"）。
    /// - `activeUntil == .revoked(...)` 一律失效。
    /// - schema version unsupported → 失效（fail-closed）。
    public func isValid(givenActiveWindows activeOwnerRefs: Set<DialogueSourceGroupRef>) -> Bool {
        guard schemaVersion.isSupported else { return false }
        guard activeUntil.isKnown else { return false }
        if case .revoked = activeUntil { return false }
        if !focusValidityReason.isKnown { return false }
        // focus injection 必须在 disabled=true 状态（未授权 → 静态 invalid）
        if focusValidityReason.isFocusInjectionAllowed { return false }
        return activeOwnerRefs.contains(ownerWindowRef)
    }
}

// MARK: - Focus injection authority (statically closed)

/// R5 spec 条款：focus injection SHALL remain disabled until a separate authority and
/// proof contract is ratified. 因此本枚举只暴露 `.notYetRatified` 一 case，
/// 类型系统直接拒绝任何 "已授权" 的呈现。
public enum DialogueFocusInjectionAuthority: Codable, Equatable, Sendable {
    case notYetRatified

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard raw == "not_yet_ratified" else {
            throw DialogueFocusOwnerError.unauthorisedInjectionAttempted(rawValue: raw)
        }
        self = .notYetRatified
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("not_yet_ratified")
    }
}

// MARK: - Force visual state probe (uninhabited marker)

/// R5 spec 条款：Force visual state SHALL NOT create focus.
///
/// 通过一个 uninhabited 类型（enum 无 case）表达：force visual state 无法构造出
/// focus source 类型的值——这是类型系统层的静态证据。
public enum DialogueForceVisualStateProbe: Sendable {
    // no cases — cannot be constructed
}

/// 未授权 injection 尝试的 error 通道。
public enum DialogueFocusOwnerError: Error, Equatable, Sendable {
    case unauthorisedInjectionAttempted(rawValue: String)
    case unsupportedSchemaVersion(rawValue: String)
    case unknownActivationBound(rawValue: String)
}

// MARK: - Injection request guard

/// 显式 injection 请求 gate。schema 层永远返回 `.failure(.unauthorisedInjectionAttempted)`
/// 除非同时提供 `.notYetRatified`（即证明尚未授权）。这里刻意让 API 永远静态失败，
/// 用作类型层拒收面。
public enum DialogueFocusInjectionGuard {
    public static func evaluate(
        authority: DialogueFocusInjectionAuthority
    ) -> Result<Never, DialogueFocusOwnerError> {
        switch authority {
        case .notYetRatified:
            return .failure(.unauthorisedInjectionAttempted(rawValue: "not_yet_ratified"))
        }
    }
}
