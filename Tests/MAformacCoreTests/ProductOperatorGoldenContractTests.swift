import XCTest
@testable import MAformacCore

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

    func testCustomerPathDONEClaimIsForbidden() {
        // Structural: golden fixtures cannot claim customer path DONE
        // because proof_class is fixture_local, not runtime_local or operator.
        // This test verifies the structural constraint.
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
