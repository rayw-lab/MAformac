import Foundation

// MARK: - RouteExecTier
//
// Five-layer intent model — `docs/srd-three-layer-intent-routing.md:40-49` §1.2.
// jsonl `exec_tier` field (live distribution: L1=76, L2=3914; L3-L5 reserved
// for downstream routing decisions, not present in row-level SSOT).
public enum RouteExecTier: String, Codable, CaseIterable, Equatable, Sendable {
    case L1
    case L2
    case L3
    case L4
    case L5
}

// MARK: - RouteOutcome
//
// Routing verdict axis. Orthogonal to exec_tier and clarify_tag.
public enum RouteOutcome: String, Codable, CaseIterable, Equatable, Sendable {
    case candidate
    case clarify
    case reject
    case fallback
}

// MARK: - RouteClarifyTag
//
// STRICT 2-value alphabet mirroring `contracts/semantic-function-contract.jsonl`
// row-level `clarify_tag` (live grep: "explicit" 2561 rows, "implicit" 1429 rows).
// Runtime routing states `ambiguous`, `rejected`, `passthrough` from
// `docs/srd-three-layer-intent-routing.md` §1.3 are expressed via the independent
// `RouteOutcome` axis or via `RouteError` — NOT by widening this alphabet.
public enum RouteClarifyTag: String, Codable, CaseIterable, Equatable, Sendable {
    case explicit
    case implicit
}

// MARK: - RouteService
//
// D-domain service catalog. Verified from live jsonl service distribution
// (airControl 178, carControl 2656, cmd 1156 rows — matches
// `docs/baseline-semantic-protocol-2026-06-19.md:16`).
public enum RouteService: String, Codable, CaseIterable, Equatable, Sendable {
    case airControl
    case carControl
    case cmd
}

// MARK: - RouteSchemaVersion
//
// Const per SHALL: "schema_version (const `typed_route_contract.v1`)".
public enum RouteSchemaVersion {
    public static let current = "typed_route_contract.v1"
}

// MARK: - RouteSourceIdentity
//
// Field shape aligned with `Core/Contracts/DemoAuthorityIdentity.swift:3-11`
// (matrixSourceSHA256 + runtimeContractBundleDigest). We use snake_case wire
// keys matching the jsonl/JSON conventions elsewhere in contracts/.
public struct RouteSourceIdentity: Codable, Equatable, Sendable {
    public let matrixSourceSHA256: String
    public let runtimeContractBundleDigest: String

    public init(matrixSourceSHA256: String, runtimeContractBundleDigest: String) {
        self.matrixSourceSHA256 = matrixSourceSHA256
        self.runtimeContractBundleDigest = runtimeContractBundleDigest
    }

    enum CodingKeys: String, CodingKey {
        case matrixSourceSHA256 = "matrix_source_sha256"
        case runtimeContractBundleDigest = "runtime_contract_bundle_digest"
    }
}

// MARK: - RouteSubject
//
// Identity slice per SHALL "RouteSubject SHALL carry only ...".
// Never carries session_id / event_id / sequence (belong to T04a / W5a
// pending-correlation record; joined outside this contract).
public struct RouteSubject: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let routeSchema: String
    public let turnID: String
    public let traceID: String
    public let sourceIdentity: RouteSourceIdentity
    public let sourceRevision: String?
    public let staleMarker: String?
    public let contractDigest: String

    public init(
        schemaVersion: String = RouteSchemaVersion.current,
        routeSchema: String,
        turnID: String,
        traceID: String,
        sourceIdentity: RouteSourceIdentity,
        sourceRevision: String?,
        staleMarker: String?,
        contractDigest: String
    ) {
        self.schemaVersion = schemaVersion
        self.routeSchema = routeSchema
        self.turnID = turnID
        self.traceID = traceID
        self.sourceIdentity = sourceIdentity
        self.sourceRevision = sourceRevision
        self.staleMarker = staleMarker
        self.contractDigest = contractDigest
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case routeSchema = "route_schema"
        case turnID = "turn_id"
        case traceID = "trace_id"
        case sourceIdentity = "source_identity"
        case sourceRevision = "source_revision"
        case staleMarker = "stale_marker"
        case contractDigest = "contract_digest"
    }
}

// MARK: - RouteCanonicalJSON
//
// Deterministic canonical JSON encoding used for digest computation.
// Sorted keys, no whitespace, ISO-8601 dates. The bytes → hex hash step
// delegates to `C6Hash.sha256Hex(_ data: Data)` at
// `Core/Support/C6Hash.swift:5` so there is no parallel SHA-256 hex
// implementation in the repo (SHALL "Contract SHALL NOT introduce a second
// D-domain tool registry, service catalog, or fc_flags→exec_tier map" —
// its intent, no-second-SSOT, applies to hash helpers too).
public enum RouteCanonicalJSON {
    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }

    /// Delegate to the existing C6Hash helper — no second sha256Hex impl.
    public static func sha256Hex<T: Encodable>(_ value: T) throws -> String {
        let data = try encode(value)
        return C6Hash.sha256Hex(data)
    }
}
