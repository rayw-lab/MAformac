import Foundation

// MARK: - RouteError
//
// Closed enum covering the SHALL "Route error enum SHALL be closed and cover
// risk-policy R0-R3" — anchored to `CLAUDE.md:109` (D37 amend risk-policy
// R0-R3 + clarifyTag) and live `contracts/risk-policy.yaml`.
//
// Rejection precedence (see `RouteError.rank` below) matches the SHALL
// "The rejection precedence SHALL be, in strict order" — one reason emitted
// per RouteResult; validators use `rank` to pick.
public enum RouteError: Error, Equatable, Sendable {
    // R0 — driving-forbidden / ASIL hard reject.
    case riskR0Forbidden(String)
    // Wire-shape / axis correctness — comes before catalog checks so shape
    // errors don't get masked by catalog errors.
    case illegalCombination(String)
    // D-domain named tool surface violation — tool name not in
    // Core/Contracts/DDomainMountedToolCatalog.swift:12-14 mountedToolNames.
    case unmountedName(String)
    // Service outside the canonical catalog {airControl, carControl, cmd}
    // (verified via jsonl service distribution + docs/baseline-semantic-protocol-2026-06-19.md:16).
    case outOfCatalog(String)
    // Session-generation mismatch (W8 lifecycle downstream).
    case oldGeneration(String)
    // Source revision / stale-marker.
    case staleSource(String)
    // Trace digest mismatch between RouteResult and RouteTrace.
    case digestMismatch(expected: String, actual: String)
    // schema_version const drift.
    case schemaVersionMismatch(expected: String, actual: String)
    // Structural / wire payload invalid (bad JSON shape, forbidden field, etc.).
    case payloadInvalid(String)
    // Required slot missing.
    case slotMissing(String)
    // Value four-tuple out of range.
    case valueOutOfRange(String)
    // Any closed-enum decode with an out-of-alphabet value (fail-closed).
    case unknownEnum(String)
    // R1 — end-state precondition unmet.
    case riskR1PreconditionUnmet(String)
    // R2 — clarify request (linked to clarify_tag=implicit).
    case clarifyRequired(RouteClarifyTag)

    /// Total ordering used by the validator to select a single reject reason.
    /// Lower = higher precedence. Matches the SHALL enumeration order.
    public var rank: Int {
        switch self {
        case .riskR0Forbidden: return 0
        case .illegalCombination: return 1
        case .unmountedName: return 2
        case .outOfCatalog: return 3
        case .oldGeneration: return 4
        case .staleSource: return 5
        case .digestMismatch: return 6
        case .schemaVersionMismatch: return 7
        case .payloadInvalid: return 8
        case .slotMissing: return 9
        case .valueOutOfRange: return 10
        case .unknownEnum: return 11
        case .riskR1PreconditionUnmet: return 12
        case .clarifyRequired: return 13
        }
    }

    /// Stable machine-readable identifier for the error case.
    public var code: String {
        switch self {
        case .riskR0Forbidden: return "risk_r0_forbidden"
        case .illegalCombination: return "illegal_combination"
        case .unmountedName: return "unmounted_name"
        case .outOfCatalog: return "out_of_catalog"
        case .oldGeneration: return "old_generation"
        case .staleSource: return "stale_source"
        case .digestMismatch: return "digest_mismatch"
        case .schemaVersionMismatch: return "schema_version_mismatch"
        case .payloadInvalid: return "payload_invalid"
        case .slotMissing: return "slot_missing"
        case .valueOutOfRange: return "value_out_of_range"
        case .unknownEnum: return "unknown_enum"
        case .riskR1PreconditionUnmet: return "risk_r1_precondition_unmet"
        case .clarifyRequired: return "clarify_required"
        }
    }
}

// MARK: - Codable wire representation
//
// RouteError is serialised as an object with `code` + `detail` (String) or
// `expected`/`actual` (for digestMismatch and schemaVersionMismatch) or
// `clarify_tag` for clarifyRequired. Deterministic canonical form for digest.
extension RouteError: Codable {
    private enum CodingKeys: String, CodingKey {
        case code
        case detail
        case expected
        case actual
        case clarify_tag
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let code = try c.decode(String.self, forKey: .code)
        switch code {
        case "risk_r0_forbidden":
            self = .riskR0Forbidden(try c.decode(String.self, forKey: .detail))
        case "illegal_combination":
            self = .illegalCombination(try c.decode(String.self, forKey: .detail))
        case "unmounted_name":
            self = .unmountedName(try c.decode(String.self, forKey: .detail))
        case "out_of_catalog":
            self = .outOfCatalog(try c.decode(String.self, forKey: .detail))
        case "old_generation":
            self = .oldGeneration(try c.decode(String.self, forKey: .detail))
        case "stale_source":
            self = .staleSource(try c.decode(String.self, forKey: .detail))
        case "digest_mismatch":
            self = .digestMismatch(
                expected: try c.decode(String.self, forKey: .expected),
                actual: try c.decode(String.self, forKey: .actual)
            )
        case "schema_version_mismatch":
            self = .schemaVersionMismatch(
                expected: try c.decode(String.self, forKey: .expected),
                actual: try c.decode(String.self, forKey: .actual)
            )
        case "payload_invalid":
            self = .payloadInvalid(try c.decode(String.self, forKey: .detail))
        case "slot_missing":
            self = .slotMissing(try c.decode(String.self, forKey: .detail))
        case "value_out_of_range":
            self = .valueOutOfRange(try c.decode(String.self, forKey: .detail))
        case "unknown_enum":
            self = .unknownEnum(try c.decode(String.self, forKey: .detail))
        case "risk_r1_precondition_unmet":
            self = .riskR1PreconditionUnmet(try c.decode(String.self, forKey: .detail))
        case "clarify_required":
            self = .clarifyRequired(try c.decode(RouteClarifyTag.self, forKey: .clarify_tag))
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: c.codingPath,
                debugDescription: "Unknown RouteError code: \(code)"
            ))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(code, forKey: .code)
        switch self {
        case .riskR0Forbidden(let d),
             .illegalCombination(let d),
             .unmountedName(let d),
             .outOfCatalog(let d),
             .oldGeneration(let d),
             .staleSource(let d),
             .payloadInvalid(let d),
             .slotMissing(let d),
             .valueOutOfRange(let d),
             .unknownEnum(let d),
             .riskR1PreconditionUnmet(let d):
            try c.encode(d, forKey: .detail)
        case .digestMismatch(let expected, let actual),
             .schemaVersionMismatch(let expected, let actual):
            try c.encode(expected, forKey: .expected)
            try c.encode(actual, forKey: .actual)
        case .clarifyRequired(let tag):
            try c.encode(tag, forKey: .clarify_tag)
        }
    }
}
