import Foundation

// MARK: - Schema version

/// W7 P1 typed schema version.
///
/// P1/P2 只承认 `.v1`。decode 时未识别的 raw 值承载为 `.unsupported(rawValue:)`，
/// 用于审计而不冒充 supported。validate 阶段一律 fail-closed。
public enum DialogueStateSchemaVersion: Codable, Equatable, Sendable {
    case v1
    case unsupported(rawValue: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case Self.v1RawValue:
            self = .v1
        default:
            self = .unsupported(rawValue: raw)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .v1:
            return Self.v1RawValue
        case .unsupported(let raw):
            return raw
        }
    }

    public var isSupported: Bool {
        if case .v1 = self { return true }
        return false
    }

    static let v1RawValue = "w7.dialogue-state/v1"
}

// MARK: - Carrier-frozen identity

/// carrier-frozen identity 字段（sessionRef / generationRef 均为 opaque String，
/// 绑 W8 owner；本 P1/P2 change 不定义其构造/校验算法）。
public struct DialogueGroupIdentity: Codable, Equatable, Sendable {
    public let sessionRef: String
    public let generationRef: String
    public let groupOrdinal: UInt32

    public init(sessionRef: String, generationRef: String, groupOrdinal: UInt32) {
        self.sessionRef = sessionRef
        self.generationRef = generationRef
        self.groupOrdinal = groupOrdinal
    }

    /// 缺 identity → `.missingIdentity`
    fileprivate func validate() throws {
        if sessionRef.isEmpty {
            throw DialogueStateEnvelopeError.missingIdentity(field: "sessionRef")
        }
        if generationRef.isEmpty {
            throw DialogueStateEnvelopeError.missingIdentity(field: "generationRef")
        }
    }
}

// MARK: - Group disposition (finite)

public enum DialogueGroupDisposition: Codable, Equatable, Sendable {
    case paired
    case unpairedUserOnly
    case unpairedAssistantCancelled
    case unpairedConsecutiveUserSupersession
    case legacyUnpairedAmbiguous
    case contextInvalid
    case terminalAuditOnly
    case unknown(rawValue: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = Self.map(rawValue: raw)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .paired: return "paired"
        case .unpairedUserOnly: return "unpaired_user_only"
        case .unpairedAssistantCancelled: return "unpaired_assistant_cancelled"
        case .unpairedConsecutiveUserSupersession: return "unpaired_consecutive_user_supersession"
        case .legacyUnpairedAmbiguous: return "legacy_unpaired_ambiguous"
        case .contextInvalid: return "context_invalid"
        case .terminalAuditOnly: return "terminal_audit_only"
        case .unknown(let raw): return raw
        }
    }

    public var isKnown: Bool {
        if case .unknown = self { return false }
        return true
    }

    private static func map(rawValue raw: String) -> DialogueGroupDisposition {
        switch raw {
        case "paired": return .paired
        case "unpaired_user_only": return .unpairedUserOnly
        case "unpaired_assistant_cancelled": return .unpairedAssistantCancelled
        case "unpaired_consecutive_user_supersession": return .unpairedConsecutiveUserSupersession
        case "legacy_unpaired_ambiguous": return .legacyUnpairedAmbiguous
        case "context_invalid": return .contextInvalid
        case "terminal_audit_only": return .terminalAuditOnly
        default: return .unknown(rawValue: raw)
        }
    }
}

// MARK: - Window bound (carrier-frozen)

public struct DialogueWindowBound: Codable, Equatable, Sendable {
    public let maxActiveGroups: UInt

    public init(maxActiveGroups: UInt) {
        self.maxActiveGroups = maxActiveGroups
    }
}

// MARK: - Envelope

/// P1/P2 typed schema-only window envelope。
///
/// - `activeGroups`：paired / user-only 等仍在 active window 的组。
/// - `auditGroups`：terminal audit-only 组（与 active 完全分离，SHALL NOT 作为 resolver context）。
/// - `focusValidity` / `readbackValidity`：独立字段级 validity record（R3）。
/// - `sourceReferences`：显式引用列表（避免隐式索引推断）。
public struct DialogueStateWindowEnvelope: Codable, Equatable, Sendable {
    public let schemaVersion: DialogueStateSchemaVersion
    public let identity: DialogueGroupIdentity
    public let bound: DialogueWindowBound
    public let activeGroups: [DialogueGroupRecord]
    public let auditGroups: [DialogueGroupRecord]
    public let focusValidity: DialogueFieldValidityRecord?
    public let readbackValidity: DialogueFieldValidityRecord?
    public let sourceReferences: [DialogueSourceReference]

    public init(
        schemaVersion: DialogueStateSchemaVersion,
        identity: DialogueGroupIdentity,
        bound: DialogueWindowBound,
        activeGroups: [DialogueGroupRecord] = [],
        auditGroups: [DialogueGroupRecord] = [],
        focusValidity: DialogueFieldValidityRecord? = nil,
        readbackValidity: DialogueFieldValidityRecord? = nil,
        sourceReferences: [DialogueSourceReference] = []
    ) {
        self.schemaVersion = schemaVersion
        self.identity = identity
        self.bound = bound
        self.activeGroups = activeGroups
        self.auditGroups = auditGroups
        self.focusValidity = focusValidity
        self.readbackValidity = readbackValidity
        self.sourceReferences = sourceReferences
    }

    /// fail-closed validate：不 mutate，只在合法时返回 `self` 拷贝。
    public func validate() throws -> DialogueStateWindowEnvelope {
        guard schemaVersion.isSupported else {
            throw DialogueStateEnvelopeError.unsupportedSchemaVersion(rawValue: schemaVersion.rawValue)
        }
        try identity.validate()
        for group in activeGroups {
            guard group.completeness.disposition.isKnown else {
                throw DialogueStateEnvelopeError.unknownDisposition(rawValue: group.completeness.disposition.rawValue)
            }
            if case .terminalAuditOnly = group.completeness.disposition {
                throw DialogueStateEnvelopeError.terminalAuditInActiveWindow
            }
        }
        for group in auditGroups {
            guard group.completeness.disposition.isKnown else {
                throw DialogueStateEnvelopeError.unknownDisposition(rawValue: group.completeness.disposition.rawValue)
            }
            guard case .terminalAuditOnly = group.completeness.disposition else {
                throw DialogueStateEnvelopeError.nonTerminalGroupInAuditWindow(rawValue: group.completeness.disposition.rawValue)
            }
        }
        if UInt(activeGroups.count) > bound.maxActiveGroups {
            throw DialogueStateEnvelopeError.retentionExceeded(current: UInt(activeGroups.count), bound: bound.maxActiveGroups)
        }
        // nested validity records fail-closed（P2#1）：unknown reason / unsupported schema
        // / injection enabled → 明确拒收，防 declare-vs-enforce（铁律 1）。
        try Self.validateNested(focusValidity, label: "focusValidity")
        try Self.validateNested(readbackValidity, label: "readbackValidity")
        return self
    }

    private static func validateNested(_ record: DialogueFieldValidityRecord?, label: String) throws {
        guard let record else { return }
        guard record.schemaVersion.isSupported else {
            throw DialogueStateEnvelopeError.unsupportedSchemaVersion(rawValue: record.schemaVersion.rawValue)
        }
        guard record.reason.isKnown else {
            throw DialogueStateEnvelopeError.unknownValidityReason(label: label)
        }
        if record.reason.isFocusInjectionAllowed {
            throw DialogueStateEnvelopeError.focusInjectionMustRemainDisabled(label: label)
        }
    }

    /// 显式驱逐最老一条 active 组，返回新 envelope（不进 auditGroups，
    /// 对齐 R2 "eviction does not create cross-session or long-lived context"）。
    public func evictingOldestActive() -> DialogueStateWindowEnvelope {
        guard !activeGroups.isEmpty else { return self }
        return DialogueStateWindowEnvelope(
            schemaVersion: schemaVersion,
            identity: identity,
            bound: bound,
            activeGroups: Array(activeGroups.dropFirst()),
            auditGroups: auditGroups,
            focusValidity: focusValidity,
            readbackValidity: readbackValidity,
            sourceReferences: sourceReferences
        )
    }
}

// MARK: - Errors

public enum DialogueStateEnvelopeError: Error, Equatable, Sendable {
    case missingIdentity(field: String)
    case unsupportedSchemaVersion(rawValue: String)
    case unknownDisposition(rawValue: String)
    case terminalAuditInActiveWindow
    case nonTerminalGroupInAuditWindow(rawValue: String)
    case retentionExceeded(current: UInt, bound: UInt)
    case unknownValidityReason(label: String)
    case focusInjectionMustRemainDisabled(label: String)
}

// MARK: - Canonical encoding helper

public enum DialogueStateSchemaCanonicalCoder {
    public static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    public static func decoder() -> JSONDecoder {
        return JSONDecoder()
    }
}
