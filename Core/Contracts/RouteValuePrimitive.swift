import Foundation

// MARK: - RouteValueRef
//
// Field naming — verbatim from contracts/semantic-function-contract.jsonl
// row-level `value.ref` and MASTER anchor `docs/baseline-semantic-protocol-2026-06-19.md`
// §2② (line 53-57): ref ∈ {"", "CUR", "ZERO", "MAX"}.
//
// Pattern follows Core/Contracts/VehicleToolBehaviorClass.swift:3-13
// (public enum String, Codable, CaseIterable, Equatable, Sendable + computed accessor).
public enum RouteValueRef: String, Codable, CaseIterable, Equatable, Sendable {
    case empty = ""
    case CUR
    case ZERO
    case MAX

    /// True when this ref describes a delta-from-current pattern.
    public var isRelative: Bool { self == .CUR }
}

// MARK: - RouteValueDirect
//
// `direct` field — jsonl empty string / "+" / "-" (MASTER §2② line 55).
public enum RouteValueDirect: String, Codable, CaseIterable, Equatable, Sendable {
    case empty = ""
    case plus = "+"
    case minus = "-"
}

// MARK: - RouteValueType
//
// `type` field — jsonl SPOT/PERCENT/EXP or empty (MASTER §2② line 57).
public enum RouteValueType: String, Codable, CaseIterable, Equatable, Sendable {
    case empty = ""
    case SPOT
    case PERCENT
    case EXP
}

// MARK: - RouteValueExperiential
//
// Experiential enum for EXP-typed offsets — MASTER §2② line 56
// (LITTLE / MORE / MAX / MIN / HIGH / HIGHER / MIDDLE / LOW / LOWER).
public enum RouteValueExperiential: String, Codable, CaseIterable, Equatable, Sendable {
    case LITTLE
    case MORE
    case MAX
    case MIN
    case HIGH
    case HIGHER
    case MIDDLE
    case LOW
    case LOWER
}

// MARK: - RouteValueOffset
//
// Closed sum type — MASTER §2② line 56:
//   • literal(String) : numeric or explicit non-experiential offset (e.g. "26", "50%")
//   • experiential(RouteValueExperiential) : EXP-typed offsets
//   • empty : jsonl row-level absence
//
// Codable represents this as a String (transparent to jsonl / fixture wire form):
//   • RouteValueExperiential raw ⇒ .experiential(...)
//   • empty string ⇒ .empty
//   • otherwise ⇒ .literal(<verbatim>)
public enum RouteValueOffset: Codable, Equatable, Sendable {
    case empty
    case literal(String)
    case experiential(RouteValueExperiential)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if raw.isEmpty {
            self = .empty
            return
        }
        if let exp = RouteValueExperiential(rawValue: raw) {
            self = .experiential(exp)
            return
        }
        self = .literal(raw)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawString)
    }

    /// Canonical wire representation. Deterministic for digest computation.
    public var rawString: String {
        switch self {
        case .empty:
            return ""
        case .literal(let value):
            return value
        case .experiential(let exp):
            return exp.rawValue
        }
    }
}

// MARK: - RouteValueFourTuple
//
// Typed carrier of the jsonl `value{ref,direct,offset,type}` four-tuple.
// Field names are verbatim jsonl keys (`ref`, `direct`, `offset`, `type`) — no
// near-synonyms per SHALL "value four-tuple SHALL use jsonl field names verbatim".
public struct RouteValueFourTuple: Codable, Equatable, Sendable {
    public var ref: RouteValueRef
    public var direct: RouteValueDirect
    public var offset: RouteValueOffset
    public var type: RouteValueType

    public init(
        ref: RouteValueRef = .empty,
        direct: RouteValueDirect = .empty,
        offset: RouteValueOffset = .empty,
        type: RouteValueType = .empty
    ) {
        self.ref = ref
        self.direct = direct
        self.offset = offset
        self.type = type
    }

    /// True when every axis is empty — matches jsonl rows that carry
    /// `value={ref:"",direct:"",offset:"",type:""}` (live head-2 sample confirms
    /// this shape for `power_on`-family rows without explicit numeric args).
    public var isEmpty: Bool {
        ref == .empty && direct == .empty && offset == .empty && type == .empty
    }
}
