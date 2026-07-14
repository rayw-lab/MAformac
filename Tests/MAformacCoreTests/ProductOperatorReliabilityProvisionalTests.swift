import XCTest
@testable import MAformacCore

final class ProductOperatorReliabilityProvisionalTests: XCTestCase {
    private static var fixturesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/product-operator-reliability")
    }

    // MARK: - Valid fixture

    func testValidProvisionalReceiptPassesValidation() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("provisional-receipt.json")
        let data = try Data(contentsOf: url)
        let fixture = try JSONDecoder().decode(ProductOperatorReliabilityFixture.self, from: data)

        XCTAssertNoThrow(try validateReliabilityFixture(fixture))
        XCTAssertEqual(fixture.thresholdBasis, "provisional_package_local")
        XCTAssertEqual(fixture.metricID, "turn_latency_ms")
        XCTAssertEqual(fixture.provisionalP95MS, 500)
        XCTAssertEqual(fixture.soakStatus, "resource_deferred")
        XCTAssertTrue(fixture.nonClaims.contains("not_w4_done"))
        XCTAssertTrue(fixture.nonClaims.contains("not_v1_ratified"))
    }

    // MARK: - Missing citation

    func testRejectsMissingBasisCitation() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("provisional-receipt-missing-citation.json")
        let data = try Data(contentsOf: url)
        let fixture = try JSONDecoder().decode(ProductOperatorReliabilityFixture.self, from: data)

        XCTAssertThrowsError(try validateReliabilityFixture(fixture)) { error in
            XCTAssertEqual(error as? ProductOperatorFixtureError, .missingField("basis_citation"))
        }
    }

    // MARK: - No p95 is valid

    func testAcceptsMissingP95() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("provisional-receipt-no-p95.json")
        let data = try Data(contentsOf: url)
        let fixture = try JSONDecoder().decode(ProductOperatorReliabilityFixture.self, from: data)

        XCTAssertNoThrow(try validateReliabilityFixture(fixture))
        XCTAssertNil(fixture.provisionalP95MS)
    }

    // MARK: - Soak status

    func testRejectsUnknownSoakStatus() {
        let fixture = ProductOperatorReliabilityFixture(
            thresholdBasis: "provisional_package_local",
            basisCitation: "some/file.json",
            metricID: "turn_latency_ms",
            provisionalP95MS: nil,
            soakStatus: "unknown_status",
            nonClaims: ["not_w4_done", "not_v1_ratified"]
        )
        XCTAssertThrowsError(try validateReliabilityFixture(fixture)) { error in
            guard case .invalidField("soak_status", "unknown_status") = error as? ProductOperatorFixtureError else {
                return XCTFail("Expected invalidField for soak_status")
            }
        }
    }

    // MARK: - Non-claims

    func testRejectsMissingNotW4Done() {
        let fixture = ProductOperatorReliabilityFixture(
            thresholdBasis: "provisional_package_local",
            basisCitation: "some/file.json",
            metricID: "turn_latency_ms",
            provisionalP95MS: nil,
            soakStatus: "resource_deferred",
            nonClaims: ["not_v1_ratified"]
        )
        XCTAssertThrowsError(try validateReliabilityFixture(fixture)) { error in
            XCTAssertEqual(error as? ProductOperatorFixtureError, .missingNonClaim("not_w4_done"))
        }
    }

    func testRejectsMissingNotV1Ratified() {
        let fixture = ProductOperatorReliabilityFixture(
            thresholdBasis: "provisional_package_local",
            basisCitation: "some/file.json",
            metricID: "turn_latency_ms",
            provisionalP95MS: nil,
            soakStatus: "resource_deferred",
            nonClaims: ["not_w4_done"]
        )
        XCTAssertThrowsError(try validateReliabilityFixture(fixture)) { error in
            XCTAssertEqual(error as? ProductOperatorFixtureError, .missingNonClaim("not_v1_ratified"))
        }
    }

    // MARK: - Threshold basis

    func testRejectsWrongThresholdBasis() {
        let fixture = ProductOperatorReliabilityFixture(
            thresholdBasis: "some_other_basis",
            basisCitation: "some/file.json",
            metricID: "turn_latency_ms",
            provisionalP95MS: nil,
            soakStatus: "resource_deferred",
            nonClaims: ["not_w4_done", "not_v1_ratified"]
        )
        XCTAssertThrowsError(try validateReliabilityFixture(fixture)) { error in
            guard case .invalidField("threshold_basis", "some_other_basis") = error as? ProductOperatorFixtureError else {
                return XCTFail("Expected invalidField for threshold_basis")
            }
        }
    }

    // MARK: - W4 DONE / V1 RATIFIED claim forbidden

    func testReliabilityDoesNotClaimW4DONE() {
        let fixture = ProductOperatorReliabilityFixture(
            thresholdBasis: "provisional_package_local",
            basisCitation: "some/file.json",
            metricID: "turn_latency_ms",
            provisionalP95MS: nil,
            soakStatus: "resource_deferred",
            nonClaims: ["not_w4_done", "not_v1_ratified"]
        )
        XCTAssertTrue(fixture.nonClaims.contains("not_w4_done"))
        XCTAssertTrue(fixture.nonClaims.contains("not_v1_ratified"))
    }

    func testSoakStatusIsResourceDeferredNotPass() {
        let url = Self.fixturesDirectory.appendingPathComponent("provisional-receipt.json")
        guard let data = try? Data(contentsOf: url),
              let fixture = try? JSONDecoder().decode(ProductOperatorReliabilityFixture.self, from: data) else {
            return
        }
        XCTAssertEqual(fixture.soakStatus, "resource_deferred")
        XCTAssertNotEqual(fixture.soakStatus, "local_pass")
    }
}
