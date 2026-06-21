import XCTest
@testable import MAformacCore

final class C5DataGateTests: XCTestCase {
    func testCleanReceiptIsDataGateReady() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-OK-001","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-OK-001","parent_semantic_id":"parent:c5.ok.train","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"masking":{"function_name":true,"argument_name":true,"argument_value":true,"train_on_turn":true}}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.rowCount, 1)
        XCTAssertEqual(receipt.mustNotTrainViolations, 0)
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 0)
        XCTAssertEqual(receipt.toolCallFormatPass, 1)
        XCTAssertEqual(receipt.proposedFix.autoApply, false)
        XCTAssertEqual(receipt.redactionStatus, "pass")
        XCTAssertTrue(receipt.maskingCoverage.functionName)
    }

    func testC6MustPassInTrainFails() throws {
        let c6Case = protectedC6Case(caseID: "C6-MP-FIXTURE", semanticID: "c1_fixture_protected")
        let receipt = try makeReceipt(c6Cases: [c6Case], jsonl: """
        {"sample_id":"C5-BAD-MP","split":"train","bucket":"tool_call_wrapper_format","case_id":"C6-MP-FIXTURE","parent_semantic_id":"parent:c5.bad","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.mustNotTrainViolations, 1)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "must_not_train_candidate_in_train" })
    }

    func testParentSemanticOverlapInTrainFails() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-001","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-001","parent_semantic_id":"parent:shared","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-001","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-001","parent_semantic_id":"parent:shared","must_not_train":true,"input_zh":"空调打开"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.detectedParentSemanticOverlapCount, 1)
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 1)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "train_parent_semantic_overlap" })
    }

    func testBareJSONTrainActionFailsFormatGate() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-BAD-FORMAT","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-BAD-FORMAT","parent_semantic_id":"parent:bad.format","must_not_train":false,"input_zh":"打开空调","expected_tool_calls":[{"name":"set_cabin_ac","arguments":{"power":"on"}}],"messages":[{"role":"assistant","content":"{\\"name\\":\\"set_cabin_ac\\",\\"arguments\\":{\\"power\\":\\"on\\"}}"}]}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.toolCallFormatFailures.count, 1)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "tool_call_format_mismatch" })
    }

    func testLegacyRawCandidateSchemaDecodes() throws {
        let receipt = try makeReceipt(jsonl: """
        {"case_id":"mfc-004","dataset_bucket":"train_candidate","scenario_family_id":"ac_free_say_temperature","must_not_train":false,"query_template":"表达自己有点冷","expected":{"frames":[{"arguments":{"delta":"warmer"},"tool_name":"set_cabin_ac","type":"tool_call"}]},"messages":[{"role":"assistant","content":"<tool_call>{\\"name\\":\\"set_cabin_ac\\",\\"arguments\\":{\\"delta\\":\\"warmer\\"}}</tool_call>"}]}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.bucketCounts["train"], 1)
        XCTAssertEqual(receipt.toolCallFormatPass, 1)
    }

    func testDevSelectionIsWhitelistedAndDoesNotProtectParentOverlap() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-001","split":"train","bucket":"semantic_protocol_augmented","case_id":"C5-TRAIN-001","parent_semantic_id":"parent:shared","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"tool_call_frame","arguments":{"device":"ac","action_primitive":"power_on"}}}
        {"sample_id":"C5-DEV-001","split":"dev_selection","bucket":"dev_selection","case_id":"C5-DEV-001","parent_semantic_id":"parent:shared","must_not_train":true,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"tool_call_frame","arguments":{"device":"ac","action_primitive":"power_on"}}}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.bucketCounts["dev_selection"], 1)
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 0)
        XCTAssertTrue(receipt.splitWhitelist.contains("dev_selection"))
    }

    private func makeReceipt(
        c6Cases: [C6BenchCase] = [],
        jsonl: String
    ) throws -> C5DataGateReceipt {
        let decoder = JSONDecoder()
        let candidates = try jsonl.split(whereSeparator: \.isNewline).map {
            try decoder.decode(C5DataGateCandidate.self, from: Data(String($0).utf8))
        }
        let context = C5DataGateRunContext(
            sourceSnapshotDigest: "source-digest",
            sourceAuthorizationStatus: "authorized_fixture",
            formatContractVersion: "format-digest",
            generatedAt: "2026-06-20T00:00:00Z"
        )
        return C5DataGateValidator().receipt(candidates: candidates, c6Cases: c6Cases, context: context)
    }

    private func protectedC6Case(caseID: String, semanticID: String) -> C6BenchCase {
        C6BenchCase(
            caseID: caseID,
            sourceRefs: C6SourceRefs(semanticContractIDs: [semanticID], stateCellIDs: ["ac.power"], scenarioIDs: ["scene1"]),
            tags: C6CaseTags(bucket: .action, mustPass: true, mustNotTrain: true, contractDevice: "ac", scenarioID: "scene1", sampleKind: "fixture"),
            preState: ["ac.power": "off"],
            inputZh: "打开空调",
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectNoCall: false,
            expectedStateDelta: ["ac.power": "on"],
            readbackAssertion: C6ReadbackAssertion(contains: ["空调"]),
            clarifyTag: .implicit,
            failureClass: .none
        )
    }
}
