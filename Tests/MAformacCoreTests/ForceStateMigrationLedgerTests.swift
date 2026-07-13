import XCTest
@testable import MAformacCore

final class ForceStateMigrationLedgerTests: XCTestCase {
    private func makeRow(
        source: String = "src.a",
        target: String = "tgt.b",
        direction: ForceStateMigrationDirection = .forward,
        reason: String = "canonical-migration",
        evidence: String = "docs/commander-log/decisions.md:1384"
    ) -> ForceStateMigrationRow {
        ForceStateMigrationRow(
            sourceStableIdentity: source,
            targetStableIdentity: target,
            direction: direction,
            reason: reason,
            evidence: evidence
        )
    }

    func testHappyPathResolvesExactlyOneRow() throws {
        let row = makeRow(source: "src.a", target: "tgt.b", direction: .forward)
        let ledger = try ForceStateMigrationLedger.load(rows: [row])
        let resolved = try ledger.resolve(source: "src.a", direction: .forward)
        XCTAssertEqual(resolved, row)
    }

    // MARK: - Forbidden 4↔5 mapping

    func testForbidden4to5MappingIsRejectedForward() {
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [makeRow(source: "4", target: "5", direction: .forward)])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .forbidden4to5Mapping(source: "4", target: "5", direction: .forward)
            )
        }
    }

    func testForbidden5to4MappingIsRejectedReverse() {
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [makeRow(source: "5", target: "4", direction: .reverse)])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .forbidden4to5Mapping(source: "5", target: "4", direction: .reverse)
            )
        }
    }

    func testForbidden4to5IsRejectedEvenReverseDirection() {
        // Direction alone does not lift the ban; a `4` → `5` payload in the
        // reverse channel is still forbidden.
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [makeRow(source: "4", target: "5", direction: .reverse)])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .forbidden4to5Mapping(source: "4", target: "5", direction: .reverse)
            )
        }
    }

    // MARK: - Structural rejection

    func testDuplicateRowIsRejected() {
        let row = makeRow(source: "src.a", target: "tgt.b", direction: .forward)
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [row, row])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .duplicateRow(sourceStableIdentity: "src.a", targetStableIdentity: "tgt.b", direction: .forward)
            )
        }
    }

    func testAmbiguousMappingIsRejected() {
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [
                makeRow(source: "src.a", target: "tgt.b", direction: .forward),
                makeRow(source: "src.a", target: "tgt.c", direction: .forward)
            ])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .ambiguousMapping(
                    sourceStableIdentity: "src.a",
                    direction: .forward,
                    existingTarget: "tgt.b",
                    newTarget: "tgt.c"
                )
            )
        }
    }

    func testEmptyEvidenceFailsClosed() {
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [makeRow(source: "src.a", target: "tgt.b", evidence: "   ")])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .emptyEvidence(sourceStableIdentity: "src.a", targetStableIdentity: "tgt.b")
            )
        }
    }

    func testEmptyStableIdentityFailsClosed() {
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [makeRow(source: "  ", target: "tgt.b")])
        ) { error in
            XCTAssertEqual(error as? ForceStateMigrationError, .emptyStableIdentity)
        }
    }

    func testEmptyReasonFailsClosed() {
        XCTAssertThrowsError(
            try ForceStateMigrationLedger.load(rows: [makeRow(source: "src.a", target: "tgt.b", reason: "")])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .emptyReason(sourceStableIdentity: "src.a", targetStableIdentity: "tgt.b")
            )
        }
    }

    // MARK: - Missing row query

    func testMissingRowQueryFailsClosed() throws {
        let ledger = try ForceStateMigrationLedger.load(rows: [makeRow(source: "src.a", target: "tgt.b", direction: .forward)])
        XCTAssertThrowsError(try ledger.resolve(source: "src.a", direction: .reverse)) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .missingRow(sourceStableIdentity: "src.a", direction: .reverse)
            )
        }
        XCTAssertThrowsError(try ledger.resolve(source: "src.unknown", direction: .forward)) { error in
            XCTAssertEqual(
                error as? ForceStateMigrationError,
                .missingRow(sourceStableIdentity: "src.unknown", direction: .forward)
            )
        }
    }

    func testDirectionSeparatesRowsCleanly() throws {
        // Two rows with identical source but different direction should coexist
        // without ambiguity; the ambiguous check is scoped to (source, direction).
        let forward = makeRow(source: "src.a", target: "tgt.b", direction: .forward)
        let reverse = makeRow(source: "src.a", target: "tgt.z", direction: .reverse)
        let ledger = try ForceStateMigrationLedger.load(rows: [forward, reverse])
        XCTAssertEqual(try ledger.resolve(source: "src.a", direction: .forward), forward)
        XCTAssertEqual(try ledger.resolve(source: "src.a", direction: .reverse), reverse)
    }
}
