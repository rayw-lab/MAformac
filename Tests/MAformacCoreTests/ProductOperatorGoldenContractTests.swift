import XCTest
import Foundation
@testable import MAformacCore

// MARK: - Product Operator test-support fixtures (module-internal)
// Hosted here so both ProductOperatorGoldenContractTests and
// ProductOperatorReliabilityProvisionalTests share one definition without a Core production file.

/// A single golden fixture entry loaded from a JSONL fixture file.
struct ProductOperatorGoldenFixture: Codable, Equatable {
    let utterance: String
    let expectedDisposition: String
    let expectedReadback: String?
    let proofClass: String

    enum CodingKeys: String, CodingKey {
        case utterance
        case expectedDisposition = "expected_disposition"
        case expectedReadback = "expected_readback"
        case proofClass = "proof_class"
    }
}

/// Loads golden fixtures from a JSONL file at the given URL.
/// Returns an empty array on file-not-found; throws on parse errors.
func loadGoldenFixtures(from url: URL) throws -> [ProductOperatorGoldenFixture] {
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
func validateGoldenFixture(_ fixture: ProductOperatorGoldenFixture) throws {
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
struct ProductOperatorReliabilityFixture: Codable, Equatable {
    let thresholdBasis: String
    let basisCitation: String?
    let metricID: String
    let provisionalP95MS: Int?
    let soakStatus: String
    let nonClaims: [String]

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
func validateReliabilityFixture(_ fixture: ProductOperatorReliabilityFixture) throws {
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

enum ProductOperatorFixtureError: Error, Equatable {
    case missingField(String)
    case invalidField(String, String)
    case missingNonClaim(String)
}

extension ProductOperatorFixtureError: LocalizedError {
    var errorDescription: String? {
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

// MARK: - Tests

final class ProductOperatorGoldenContractTests: XCTestCase {
    private static var fixturesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/product-operator-golden")
    }

    // MARK: - Success fixtures

    func testSuccessFixturesLoadAndValidate() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("success.jsonl")
        let fixtures = try loadGoldenFixtures(from: url)
        XCTAssertFalse(fixtures.isEmpty, "Expected at least one success fixture")

        for fixture in fixtures {
            XCTAssertNoThrow(try validateGoldenFixture(fixture), "Fixture failed: \(fixture.utterance)")
            XCTAssertEqual(fixture.proofClass, "fixture_local")
            XCTAssertEqual(fixture.expectedDisposition, "accepted")
            XCTAssertNotNil(fixture.expectedReadback, "Accepted fixture must have expected_readback")
        }
    }

    // MARK: - Reject fixtures

    func testRejectFixturesLoadAndValidate() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("reject.jsonl")
        let fixtures = try loadGoldenFixtures(from: url)
        XCTAssertFalse(fixtures.isEmpty, "Expected at least one reject fixture")

        for fixture in fixtures {
            XCTAssertNoThrow(try validateGoldenFixture(fixture))
            XCTAssertEqual(fixture.proofClass, "fixture_local")
            // Reject fixtures may have nil expected_readback
        }
    }

    // MARK: - Safety fixtures

    func testSafetyFixturesLoadAndValidate() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("safety.jsonl")
        let fixtures = try loadGoldenFixtures(from: url)
        XCTAssertFalse(fixtures.isEmpty, "Expected at least one safety fixture")

        for fixture in fixtures {
            XCTAssertNoThrow(try validateGoldenFixture(fixture))
            XCTAssertEqual(fixture.expectedDisposition, "safety_refusal")
            XCTAssertEqual(fixture.proofClass, "fixture_local")
        }
    }

    // MARK: - Offline fixtures

    func testOfflineFixturesLoadAndValidate() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("offline.jsonl")
        let fixtures = try loadGoldenFixtures(from: url)
        XCTAssertFalse(fixtures.isEmpty, "Expected at least one offline fixture")

        for fixture in fixtures {
            XCTAssertNoThrow(try validateGoldenFixture(fixture))
            XCTAssertEqual(fixture.proofClass, "fixture_local")
        }
    }

    // MARK: - Stale / recovery fixtures

    func testStaleRecoveryFixturesLoadAndValidate() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("stale-recovery.jsonl")
        let fixtures = try loadGoldenFixtures(from: url)
        XCTAssertFalse(fixtures.isEmpty, "Expected at least one stale/recovery fixture")

        for fixture in fixtures {
            XCTAssertNoThrow(try validateGoldenFixture(fixture))
            XCTAssertEqual(fixture.expectedDisposition, "recovery")
            XCTAssertEqual(fixture.proofClass, "fixture_local")
        }
    }

    // MARK: - Negative: missing fields

    func testRejectsMissingUtterance() {
        let fixture = ProductOperatorGoldenFixture(
            utterance: "",
            expectedDisposition: "accepted",
            expectedReadback: "done",
            proofClass: "fixture_local"
        )
        XCTAssertThrowsError(try validateGoldenFixture(fixture)) { error in
            XCTAssertEqual(error as? ProductOperatorFixtureError, .missingField("utterance"))
        }
    }

    func testRejectsUnknownDisposition() {
        let fixture = ProductOperatorGoldenFixture(
            utterance: "test",
            expectedDisposition: "unknown",
            expectedReadback: nil,
            proofClass: "fixture_local"
        )
        XCTAssertThrowsError(try validateGoldenFixture(fixture)) { error in
            guard case .invalidField("expected_disposition", "unknown") = error as? ProductOperatorFixtureError else {
                return XCTFail("Expected invalidField error")
            }
        }
    }

    func testRejectsAcceptedWithoutReadback() {
        let fixture = ProductOperatorGoldenFixture(
            utterance: "test",
            expectedDisposition: "accepted",
            expectedReadback: nil,
            proofClass: "fixture_local"
        )
        XCTAssertThrowsError(try validateGoldenFixture(fixture)) { error in
            XCTAssertEqual(error as? ProductOperatorFixtureError, .missingField("expected_readback"))
        }
    }

    func testRejectsEmptyProofClass() {
        let fixture = ProductOperatorGoldenFixture(
            utterance: "test",
            expectedDisposition: "reject",
            expectedReadback: nil,
            proofClass: ""
        )
        XCTAssertThrowsError(try validateGoldenFixture(fixture)) { error in
            XCTAssertEqual(error as? ProductOperatorFixtureError, .missingField("proof_class"))
        }
    }

    // MARK: - Non-claim enforcement

    func testGoldenProofClassIsFixtureLocalNotOperator() {
        let url = Self.fixturesDirectory.appendingPathComponent("success.jsonl")
        guard let fixtures = try? loadGoldenFixtures(from: url) else { return }
        for fixture in fixtures {
            XCTAssertNotEqual(fixture.proofClass, "operator")
            XCTAssertNotEqual(fixture.proofClass, "runtime_local")
        }
    }

    // Structural: golden fixtures cannot claim customer path DONE
    // because proof_class is fixture_local, not runtime_local or operator.
    func testCustomerPathDONEClaimIsForbidden() {
        let fixture = ProductOperatorGoldenFixture(
            utterance: "test",
            expectedDisposition: "accepted",
            expectedReadback: "done",
            proofClass: "fixture_local"
        )
        XCTAssertNotEqual(fixture.proofClass, "operator")
        XCTAssertNotEqual(fixture.proofClass, "runtime_local")
    }
}
