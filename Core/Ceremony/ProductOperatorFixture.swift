import Foundation

// MARK: - Product Operator Golden Fixture

/// A single golden fixture entry loaded from a JSONL fixture file.
public struct ProductOperatorGoldenFixture: Codable, Equatable {
    public let utterance: String
    public let expectedDisposition: String
    public let expectedReadback: String?
    public let proofClass: String

    enum CodingKeys: String, CodingKey {
        case utterance
        case expectedDisposition = "expected_disposition"
        case expectedReadback = "expected_readback"
        case proofClass = "proof_class"
    }
}

/// Loads golden fixtures from a JSONL file at the given URL.
/// Returns an empty array on file-not-found; throws on parse errors.
public func loadGoldenFixtures(from url: URL) throws -> [ProductOperatorGoldenFixture] {
    guard FileManager.default.fileExists(atPath: url.path) else { return [] }
    let data = try Data(contentsOf: url)
    let text = String(data: data, encoding: .utf8) ?? ""
    return try text
        .components(separatedBy: .newlines)
        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        .map { line in
            try JSONDecoder().decode(ProductOperatorGoldenFixture.self, from: Data(line.utf8))
        }
}

/// Validates that a golden fixture has all required fields.
/// - `utterance` must be non-empty.
/// - `expectedDisposition` must be a known disposition value.
/// - `proofClass` must be non-empty.
/// - If `expectedDisposition` is `"accepted"`, `expectedReadback` must be present.
public func validateGoldenFixture(_ fixture: ProductOperatorGoldenFixture) throws {
    guard !fixture.utterance.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw ProductOperatorFixtureError.missingField("utterance")
    }
    let knownDispositions = ["accepted", "reject", "clarify", "safety_refusal", "recovery"]
    guard knownDispositions.contains(fixture.expectedDisposition) else {
        throw ProductOperatorFixtureError.invalidField("expected_disposition", fixture.expectedDisposition)
    }
    guard !fixture.proofClass.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw ProductOperatorFixtureError.missingField("proof_class")
    }
    if fixture.expectedDisposition == "accepted" {
        guard let readback = fixture.expectedReadback, !readback.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ProductOperatorFixtureError.missingField("expected_readback")
        }
    }
}

// MARK: - Product Operator Reliability Fixture

/// A provisional reliability receipt fixture.
public struct ProductOperatorReliabilityFixture: Codable, Equatable {
    public let thresholdBasis: String
    public let basisCitation: String?
    public let metricID: String
    public let provisionalP95MS: Int?
    public let soakStatus: String
    public let nonClaims: [String]

    enum CodingKeys: String, CodingKey {
        case thresholdBasis = "threshold_basis"
        case basisCitation = "basis_citation"
        case metricID = "metric_id"
        case provisionalP95MS = "provisional_p95_ms"
        case soakStatus = "soak_status"
        case nonClaims = "non_claims"
    }
}

/// Validates a reliability fixture.
/// - `thresholdBasis` must be `"provisional_package_local"`.
/// - `basisCitation` must be present and non-nil.
/// - `metricID` must be non-empty.
/// - `soakStatus` must be a known value.
/// - `nonClaims` must contain `"not_w4_done"` and `"not_v1_ratified"`.
public func validateReliabilityFixture(_ fixture: ProductOperatorReliabilityFixture) throws {
    guard fixture.thresholdBasis == "provisional_package_local" else {
        throw ProductOperatorFixtureError.invalidField("threshold_basis", fixture.thresholdBasis)
    }
    guard let citation = fixture.basisCitation, !citation.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw ProductOperatorFixtureError.missingField("basis_citation")
    }
    guard !fixture.metricID.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw ProductOperatorFixtureError.missingField("metric_id")
    }
    let knownSoakStatuses = ["resource_deferred", "not_run", "local_pass"]
    guard knownSoakStatuses.contains(fixture.soakStatus) else {
        throw ProductOperatorFixtureError.invalidField("soak_status", fixture.soakStatus)
    }
    guard fixture.nonClaims.contains("not_w4_done") else {
        throw ProductOperatorFixtureError.missingNonClaim("not_w4_done")
    }
    guard fixture.nonClaims.contains("not_v1_ratified") else {
        throw ProductOperatorFixtureError.missingNonClaim("not_v1_ratified")
    }
}

// MARK: - Errors

public enum ProductOperatorFixtureError: Error, Equatable {
    case missingField(String)
    case invalidField(String, String)
    case missingNonClaim(String)
}

extension ProductOperatorFixtureError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingField(let name):
            return "Missing required field: \(name)"
        case .invalidField(let name, let value):
            return "Invalid value for field '\(name)': \(value)"
        case .missingNonClaim(let claim):
            return "Missing required non-claim: \(claim)"
        }
    }
}
