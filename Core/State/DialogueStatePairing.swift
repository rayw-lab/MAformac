import Foundation

// MARK: - Source references

/// 显式引用一组 source group（避免隐式索引推断 group 完整性）。
public struct DialogueSourceGroupRef: Codable, Equatable, Hashable, Sendable {
    public let sessionRef: String
    public let generationRef: String
    public let groupOrdinal: UInt32

    public init(sessionRef: String, generationRef: String, groupOrdinal: UInt32) {
        self.sessionRef = sessionRef
        self.generationRef = generationRef
        self.groupOrdinal = groupOrdinal
    }

    public init(identity: DialogueGroupIdentity) {
        self.sessionRef = identity.sessionRef
        self.generationRef = identity.generationRef
        self.groupOrdinal = identity.groupOrdinal
    }
}

/// envelope 内 sourceReferences 元素：既承载 group ref，也承载 source kind。
public struct DialogueSourceReference: Codable, Equatable, Sendable {
    public let groupRef: DialogueSourceGroupRef
    public let sourceKind: DialogueSourceKind

    public init(groupRef: DialogueSourceGroupRef, sourceKind: DialogueSourceKind) {
        self.groupRef = groupRef
        self.sourceKind = sourceKind
    }
}

public enum DialogueSourceKind: Codable, Equatable, Sendable {
    case userText
    case assistantText
    case readback
    case checkpointRestore
    case unknown(rawValue: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "user_text": self = .userText
        case "assistant_text": self = .assistantText
        case "readback": self = .readback
        case "checkpoint_restore": self = .checkpointRestore
        default: self = .unknown(rawValue: raw)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .userText: return "user_text"
        case .assistantText: return "assistant_text"
        case .readback: return "readback"
        case .checkpointRestore: return "checkpoint_restore"
        case .unknown(let raw): return raw
        }
    }
}

// MARK: - Field validity

public enum DialogueFieldValidityReason: Codable, Equatable, Sendable {
    case derivedFromReadback
    /// 唯一 case（`disabled: true`）——对齐 W7 spec R5「focus injection SHALL remain disabled
    /// until a separate authority and proof contract is ratified」。本 change 类型层禁止 enabled=true。
    case derivedFromExplicitFocusInjection(disabled: Bool)
    case invalidated(dueTo: DialogueFieldValidityInvalidationCause)
    case unknown(rawValue: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        switch kind {
        case "derived_from_readback":
            self = .derivedFromReadback
        case "derived_from_explicit_focus_injection":
            let disabled = try container.decodeIfPresent(Bool.self, forKey: .disabled) ?? true
            // typed schema 层强制 disabled = true（未授权 injection 不可 enable）
            self = .derivedFromExplicitFocusInjection(disabled: disabled)
        case "invalidated":
            let cause = try container.decode(DialogueFieldValidityInvalidationCause.self, forKey: .cause)
            self = .invalidated(dueTo: cause)
        default:
            self = .unknown(rawValue: kind)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .derivedFromReadback:
            try container.encode("derived_from_readback", forKey: .kind)
        case .derivedFromExplicitFocusInjection(let disabled):
            try container.encode("derived_from_explicit_focus_injection", forKey: .kind)
            try container.encode(disabled, forKey: .disabled)
        case .invalidated(let cause):
            try container.encode("invalidated", forKey: .kind)
            try container.encode(cause, forKey: .cause)
        case .unknown(let raw):
            try container.encode(raw, forKey: .kind)
        }
    }

    public var isKnown: Bool {
        if case .unknown = self { return false }
        return true
    }

    /// 未授权 injection：typed schema 层要求 disabled=true；enabled=true 即 fail-closed 信号。
    public var isFocusInjectionAllowed: Bool {
        if case .derivedFromExplicitFocusInjection(let disabled) = self {
            return !disabled
        }
        return false
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case disabled
        case cause
    }
}

public enum DialogueFieldValidityInvalidationCause: String, Codable, Equatable, Sendable {
    case ownerWindowEvicted = "owner_window_evicted"
    case terminalClear = "terminal_clear"
    case sessionClear = "session_clear"
    case identityFence = "identity_fence"
    case unauthorisedInjection = "unauthorised_injection"
}

public struct DialogueFieldValidityRecord: Codable, Equatable, Sendable {
    public let reason: DialogueFieldValidityReason
    public let sourceGroupRef: DialogueSourceGroupRef
    public let schemaVersion: DialogueStateSchemaVersion

    public init(
        reason: DialogueFieldValidityReason,
        sourceGroupRef: DialogueSourceGroupRef,
        schemaVersion: DialogueStateSchemaVersion
    ) {
        self.reason = reason
        self.sourceGroupRef = sourceGroupRef
        self.schemaVersion = schemaVersion
    }
}

// MARK: - Group completeness (finite paired/unpaired)

public enum DialogueGroupCompletenessReason: String, Codable, Equatable, Sendable {
    case pairedComplete = "paired_complete"
    case userOnlyPending = "user_only_pending"
    case assistantCancelled = "assistant_cancelled"
    case consecutiveUserSupersession = "consecutive_user_supersession"
    case legacyAmbiguous = "legacy_ambiguous"
    case contextInvalid = "context_invalid"
    case terminalAuditOnly = "terminal_audit_only"
}

public struct DialogueGroupCompleteness: Codable, Equatable, Sendable {
    public let disposition: DialogueGroupDisposition
    public let reason: DialogueGroupCompletenessReason

    public init(disposition: DialogueGroupDisposition, reason: DialogueGroupCompletenessReason) {
        self.disposition = disposition
        self.reason = reason
    }
}

// MARK: - Group record

/// P1/P2 typed group record。array length **不**推断 paired；
/// completeness/disposition 独立表达。
public struct DialogueGroupRecord: Codable, Equatable, Sendable {
    public let identity: DialogueGroupIdentity
    public let completeness: DialogueGroupCompleteness
    public let userText: String?
    public let assistantText: String?

    public init(
        identity: DialogueGroupIdentity,
        completeness: DialogueGroupCompleteness,
        userText: String? = nil,
        assistantText: String? = nil
    ) {
        self.identity = identity
        self.completeness = completeness
        self.userText = userText
        self.assistantText = assistantText
    }
}

// MARK: - Pairing analyzer (helpers, non-mutating)

public enum DialogueStatePairingAnalyzer {
    /// consecutive user messages 语义：给一串按 groupOrdinal 单调递增的 record，
    /// 相邻两条都是 userOnlyPending 时，前一条应被标记为 supersession。
    public static func superseding(_ records: [DialogueGroupRecord]) -> [DialogueGroupRecord] {
        guard records.count >= 2 else { return records }
        var result = records
        for i in 0 ..< result.count - 1 {
            let current = result[i]
            let next = result[i + 1]
            guard current.completeness.reason == .userOnlyPending,
                  next.completeness.reason == .userOnlyPending else { continue }
            let promoted = DialogueGroupCompleteness(
                disposition: .unpairedConsecutiveUserSupersession,
                reason: .consecutiveUserSupersession
            )
            result[i] = DialogueGroupRecord(
                identity: current.identity,
                completeness: promoted,
                userText: current.userText,
                assistantText: current.assistantText
            )
        }
        return result
    }
}
