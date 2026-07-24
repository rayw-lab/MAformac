import XCTest
@testable import MAformacCore

final class R5ProofGovernanceStaticChecksTests: XCTestCase {
    func testReceiptSchemaRequiresGovernanceFields() throws {
        let schema = try read("docs/project/phase0/r5-proof-governance-receipt-schema-2026-06-28.md")
        let requiredFields = [
            "command",
            "surface_or_device",
            "proof_class",
            "touched_paths",
            "dirty_split",
            "residual_risks",
            "live_HEAD",
            "non_claims_checkbox",
            "unresolved_P0_P1_carry_forward"
        ]

        for field in requiredFields {
            XCTAssertTrue(schema.contains(field), field)
        }
    }

    func testDispatch3ReceiptCarriesRecordedUIUEBranchHead() throws {
        let receipt = try read("docs/project/phase0/r5-shared-proof-governance-dispatch-3-2026-06-28.md")
        let recordedHead = try XCTUnwrap(recordedHead(in: receipt, for: "UIUE"))

        XCTAssertNotNil(recordedHead.range(of: #"^[0-9a-f]{40}$"#, options: .regularExpression), recordedHead)
        XCTAssertTrue(receipt.contains("uiue/phase4-default-scope-presentation"))
    }

    func testRowsInScopeHaveDispositions() throws {
        let receipt = try read("docs/project/phase0/r5-shared-proof-governance-dispatch-3-2026-06-28.md")
        let rows = [
            "C106",
            "C001", "C008", "C025", "C036", "C050", "C189",
            "C046", "C047", "C048", "C049", "C107", "C108",
            "C110", "C111", "C179", "C193", "C195", "C196"
        ]

        for row in rows {
            XCTAssertTrue(receipt.contains("`\(row)`"), row)
        }

        XCTAssertTrue(receipt.contains("covered_by_governance_checker"))
        XCTAssertTrue(receipt.contains("guarded_no_regression"))
        XCTAssertTrue(receipt.contains("rewritten_as_falsifiable_rule"))
    }

    func testProofPromotionChecksAreRecorded() throws {
        let receipt = try read("docs/project/phase0/r5-shared-proof-governance-dispatch-3-2026-06-28.md")
        let checks = [
            "screenshot_no_promotion",
            "forbidden_claim_grep",
            "proof_enum_translation",
            "receipt_schema_required_fields",
            "validation_gate_by_touched_paths",
            "dual_repo_dirty_split",
            "live_head_required"
        ]

        for check in checks {
            XCTAssertTrue(receipt.contains(check), check)
        }
    }

    func testValidationGateByTouchedPathsIsFalsifiable() throws {
        let schema = try read("docs/project/phase0/r5-proof-governance-receipt-schema-2026-06-28.md")
        let requiredTokens = [
            "docs_only",
            "swift_uiue_code",
            "mainline_read_only_reference",
            "openspec_touched",
            "simulator_or_screenshot_touched",
            "runtime_or_device_touched",
            "openspec validate ui-presentation --strict",
            "swift test --filter",
            "openspec validate define-runtime-presentation-bridge --strict"
        ]

        for token in requiredTokens {
            XCTAssertTrue(schema.contains(token), token)
        }
    }

    func testK1M3H1RemainNonImplementationLanes() throws {
        let receipt = try read("docs/project/phase0/r5-shared-proof-governance-dispatch-3-2026-06-28.md")

        XCTAssertTrue(receipt.contains("K1"))
        XCTAssertTrue(receipt.contains("spike_before_implementation"))
        XCTAssertTrue(receipt.contains("M3"))
        XCTAssertTrue(receipt.contains("merge_only_not_implemented"))
        XCTAssertTrue(receipt.contains("H1"))
        XCTAssertTrue(receipt.contains("human_review_only"))
    }

    @MainActor
    func testReviewedProductRouteMutatesStateAndReturnsObservedReadback() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )

        let result = try await route.route(text: "打开空调")
        let execution = try XCTUnwrap(result.execution)

        XCTAssertNil(result.rejection)
        XCTAssertEqual(execution.runnerCallCount, 1)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertTrue(
            execution.payload.readbacks.contains {
                $0.key == "ac.power" && $0.actualValue == "on"
            }
        )
        XCTAssertEqual(speech.spokenTexts.count, 1)
    }

    @MainActor
    func testOutOfCatalogProductRouteRefusesWithoutMutationOrSpeech() async throws {
        let store = DemoVehicleStateStore()
        let speech = RecordingSpeechSynthesisEngine()
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: speech
        )

        let initialRevision = store.currentRevision
        let result = try await route.route(text: "打开所有车窗")

        XCTAssertNil(result.execution)
        XCTAssertNotNil(result.rejection)
        XCTAssertEqual(store.currentRevision, initialRevision)
        XCTAssertTrue(speech.spokenTexts.isEmpty)
    }


    private func read(_ relativePath: String) throws -> String {
        try String(contentsOf: repoRoot().appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func recordedHead(in receipt: String, for repoName: String) -> String? {
        for line in receipt.components(separatedBy: .newlines) {
            let cells = line.split(separator: "|").map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            guard cells.count >= 3, cells[0] == repoName else {
                continue
            }
            return cells[2].trimmingCharacters(in: CharacterSet(charactersIn: "`"))
        }
        return nil
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

}
