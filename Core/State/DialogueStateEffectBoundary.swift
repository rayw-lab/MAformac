import Foundation

// MARK: - W8 fact kind (opaque)

/// W7 消费 W8 typed lifecycle facts 的 opaque identity。
///
/// 本 P1/P2 change 不 import W8 Swift types（W8 typed producer 尚不存在，见 intel Q6），
/// 用 opaque enum 承载 identity，为将来 bridging 保留 versioned 边界。
public enum DialogueW8FactKind: Codable, Equatable, Hashable, Sendable {
    case sessionStarted
    case sessionCleared
    case generationFenced
    case turnCancelled
    case terminalClear
    case checkpointSaved
    case checkpointRestoreAttempted
    case unknown(rawValue: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "session_started": self = .sessionStarted
        case "session_cleared": self = .sessionCleared
        case "generation_fenced": self = .generationFenced
        case "turn_cancelled": self = .turnCancelled
        case "terminal_clear": self = .terminalClear
        case "checkpoint_saved": self = .checkpointSaved
        case "checkpoint_restore_attempted": self = .checkpointRestoreAttempted
        default: self = .unknown(rawValue: raw)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .sessionStarted: return "session_started"
        case .sessionCleared: return "session_cleared"
        case .generationFenced: return "generation_fenced"
        case .turnCancelled: return "turn_cancelled"
        case .terminalClear: return "terminal_clear"
        case .checkpointSaved: return "checkpoint_saved"
        case .checkpointRestoreAttempted: return "checkpoint_restore_attempted"
        case .unknown(let raw): return raw
        }
    }

    public var isKnown: Bool {
        if case .unknown = self { return false }
        return true
    }
}

// MARK: - Field effects (finite)

public enum DialogueFieldEffect: String, Codable, Equatable, Sendable {
    case clear
    case retain
}

/// terminal audit 与 active field 分离的效果枚举：终端 audit 独有 `.retainAsAuditOnly`。
public enum DialogueTerminalAuditEffect: String, Codable, Equatable, Sendable {
    case retainAsAuditOnly = "retain_as_audit_only"
    case retain
    case clear
}

// MARK: - Effect matrix version

public enum DialogueEffectMatrixVersion: Codable, Equatable, Sendable {
    case v1
    case unsupported(rawValue: String)

    static let v1RawValue = "w7.effect-matrix/v1"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case Self.v1RawValue: self = .v1
        default: self = .unsupported(rawValue: raw)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .v1: return Self.v1RawValue
        case .unsupported(let raw): return raw
        }
    }

    public var isSupported: Bool {
        if case .v1 = self { return true }
        return false
    }
}

// MARK: - W7 effect (aggregate across 5 fields)

public struct DialogueW7Effect: Codable, Equatable, Sendable {
    public let focusEffect: DialogueFieldEffect
    public let lastReadbackEffect: DialogueFieldEffect
    public let activeWindowEffect: DialogueFieldEffect
    public let unpairedGroupEffect: DialogueFieldEffect
    public let terminalAuditEffect: DialogueTerminalAuditEffect

    public init(
        focusEffect: DialogueFieldEffect,
        lastReadbackEffect: DialogueFieldEffect,
        activeWindowEffect: DialogueFieldEffect,
        unpairedGroupEffect: DialogueFieldEffect,
        terminalAuditEffect: DialogueTerminalAuditEffect
    ) {
        self.focusEffect = focusEffect
        self.lastReadbackEffect = lastReadbackEffect
        self.activeWindowEffect = activeWindowEffect
        self.unpairedGroupEffect = unpairedGroupEffect
        self.terminalAuditEffect = terminalAuditEffect
    }
}

// MARK: - Errors

public enum DialogueEffectMatrixError: Error, Equatable, Sendable {
    case effectVersionMismatch(matrixRawValue: String)
    case unknownFact(rawValue: String)
    case unrecognizedEffect(factRawValue: String)
}

// MARK: - Effect matrix

/// R6 typed schema-only 效果矩阵。
///
/// P1/P2 只提供 typed lookup；本 change 不 wire consumer；「同 fact 不被消费两次」由
/// 未来 wire 层承担，见 `DialogueW7EffectConsumptionRegisterMarker`。
public struct DialogueW7EffectMatrix: Codable, Equatable, Sendable {
    public let version: DialogueEffectMatrixVersion
    public let entries: [DialogueW7EffectMatrixEntry]

    public init(version: DialogueEffectMatrixVersion, entries: [DialogueW7EffectMatrixEntry]) {
        self.version = version
        self.entries = entries
    }

    public func apply(_ fact: DialogueW8FactKind) -> Result<DialogueW7Effect, DialogueEffectMatrixError> {
        guard version.isSupported else {
            return .failure(.effectVersionMismatch(matrixRawValue: version.rawValue))
        }
        if case .unknown(let raw) = fact {
            return .failure(.unknownFact(rawValue: raw))
        }
        for entry in entries where entry.fact == fact {
            return .success(entry.effect)
        }
        return .failure(.unrecognizedEffect(factRawValue: fact.rawValue))
    }
}

public struct DialogueW7EffectMatrixEntry: Codable, Equatable, Sendable {
    public let fact: DialogueW8FactKind
    public let effect: DialogueW7Effect

    public init(fact: DialogueW8FactKind, effect: DialogueW7Effect) {
        self.fact = fact
        self.effect = effect
    }
}

// MARK: - Idempotency marker (typed schema layer only)

/// R1 spec 条款：the same fact is not consumed twice.
///
/// 本 change 仅提供 marker（uninhabited type），说明 idempotency register 的责任
/// 归属未来的 wire 层。schema 层不提供 register 存储，避免蔓延成 consumer。
public enum DialogueW7EffectConsumptionRegisterMarker: Sendable {
    // no cases — implementation deferred to production wire (P3, GATED).
}
