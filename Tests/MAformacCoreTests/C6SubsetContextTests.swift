import XCTest
@testable import MAformacCore

final class C6SubsetContextTests: XCTestCase {
    func testLegacyBenchCaseDecodeKeepsSubsetFieldsOptional() throws {
        let json = """
        {
          "case_id":"C6-LEGACY-SUBSET-001",
          "source_refs":{"semantic_contract_ids":[],"state_cell_ids":[],"scenario_ids":[],"risk_rule_ids":[]},
          "tags":{"bucket":"action","must_pass":true,"must_not_train":true,"contract_device":"ac","sample_kind":"fixture"},
          "pre_state":{},
          "input_zh":"打开空调",
          "expected_tool_calls":[{"name":"open_ac","arguments":{}}],
          "expect_no_call":false,
          "expected_state_delta":{"ac.power":"on"},
          "readback_assertion":{"contains":["空调"]},
          "clarify_tag":"implicit",
          "failure_class":"none",
          "alternatives":[],
          "behavior_class":"tool_call"
        }
        """

        let decoded = try JSONDecoder().decode(C6SubsetBenchCase.self, from: Data(json.utf8))

        XCTAssertEqual(decoded.base.caseID, "C6-LEGACY-SUBSET-001")
        XCTAssertNil(decoded.subsetContext)
        XCTAssertNil(decoded.expectedUnsupportedClass)
    }

    func testLegacyEvalRunDecodeDefaultsSubsetFailureClassToNone() throws {
        let json = """
        {
          "run_id":"run-1",
          "case_id":"C6-LEGACY-SUBSET-001",
          "model_id":"model",
          "model_artifact_digest":"model-digest",
          "tokenizer_digest":"tokenizer-digest",
          "lora_adapter_id":"",
          "lora_checkpoint_id":"",
          "lora_adapter_digest":"",
          "qwen_tool_call_format_version":"qwen-v1",
          "prompt_hash":"prompt",
          "sampling_seed":"0",
          "tool_output_digest":"tool-output",
          "contract_digest":"contract-digest",
          "contract_bundle_fingerprint":{
            "schema_version":"c6_contract_bundle_v1",
            "bundle_hash":"bundle",
            "component_digests":{"c1.semantic_function_contract":"1111"},
            "component_versions":{"c1.semantic_function_contract":"v1"}
          },
          "gate_result":{
            "tool_call_set_match":true,
            "no_tool_false_positive_count":0,
            "state_delta_match":true,
            "readback_match":true,
            "clarify_match":true,
            "hard_failed":false,
            "failure_classes":[],
            "model_hard_failed":false,
            "readback_hard_failed":false,
            "applied_writes":[],
            "dependency_write_keys":[],
            "unexpected_mutation_keys":[],
            "scope_origin_evidence":{}
          },
          "elapsed_ms":1
        }
        """

        let decoded = try JSONDecoder().decode(C6SubsetEvalRun.self, from: Data(json.utf8))

        XCTAssertEqual(decoded.base.caseID, "C6-LEGACY-SUBSET-001")
        XCTAssertNil(decoded.subsetContext)
        XCTAssertEqual(decoded.subsetFailureClass, .none)
        XCTAssertFalse(decoded.isModelFailure)
    }

    func testSubsetFailureClassSeparatesMissingMountedExpectedFromModelFailure() {
        let accounting = C6SubsetGateClassifier.classify(
            expectedToolCalls: [C6ToolCall(name: "open_ac")],
            actualToolCalls: [],
            mountedToolIDs: ["close_ac"],
            allowedToolIDs: ["close_ac"]
        )

        XCTAssertEqual(accounting.subsetFailureClass, .missingExpectedInMounted)
        XCTAssertFalse(accounting.isModelFailure)
    }

    func testSubsetFailureClassSeparatesActualOutsideAllowed() {
        let accounting = C6SubsetGateClassifier.classify(
            expectedToolCalls: [C6ToolCall(name: "open_ac")],
            actualToolCalls: [C6ToolCall(name: "open_window")],
            mountedToolIDs: ["open_ac"],
            allowedToolIDs: ["open_ac"]
        )

        XCTAssertEqual(accounting.subsetFailureClass, .actualNotInAllowed)
        XCTAssertTrue(accounting.isModelFailure)
    }

    func testExpectedUnsupportedClassMismatchIsClassified() {
        let accounting = C6SubsetGateClassifier.classify(
            expectedToolCalls: [C6ToolCall(name: "open_ac")],
            actualToolCalls: [C6ToolCall(name: "open_ac")],
            mountedToolIDs: ["open_ac"],
            allowedToolIDs: ["open_ac"],
            expectedUnsupportedClass: .groupOutOfMount,
            behaviorClass: .toolCall
        )

        XCTAssertEqual(accounting.subsetFailureClass, .unsupportedClassMismatch)
        XCTAssertFalse(accounting.isModelFailure)
    }

    func testThreeUnsupportedExpectedClassesDecode() throws {
        XCTAssertEqual(
            try JSONDecoder().decode(C6ExpectedUnsupportedClass.self, from: Data(#""group_out_of_mount""#.utf8)),
            .groupOutOfMount
        )
        XCTAssertEqual(
            try JSONDecoder().decode(C6ExpectedUnsupportedClass.self, from: Data(#""mvp_unsupported""#.utf8)),
            .mvpUnsupported
        )
        XCTAssertEqual(
            try JSONDecoder().decode(C6ExpectedUnsupportedClass.self, from: Data(#""global_unsupported""#.utf8)),
            .globalUnsupported
        )
    }

    func testSubsetFailureStatsDecodeDefaultsUnsupportedClassMismatchCount() throws {
        let json = """
        {
          "missing_expected_in_mounted_count":1,
          "actual_not_in_allowed_count":2
        }
        """

        let stats = try JSONDecoder().decode(C6SubsetFailureStats.self, from: Data(json.utf8))

        XCTAssertEqual(stats.missingExpectedInMountedCount, 1)
        XCTAssertEqual(stats.actualNotInAllowedCount, 2)
        XCTAssertEqual(stats.unsupportedClassMismatchCount, 0)
    }

    func testSixAxisDigestReceiptBlocksOnAnyMismatch() throws {
        let input = C6SubsetDigestReceiptInput(
            targetToolIDs: ["open_ac"],
            promptToolIDs: ["open_ac"],
            expectedToolIDs: ["open_ac"],
            mountedToolIDs: ["open_ac"],
            actualToolIDs: ["open_window"],
            allowedToolIDs: ["open_ac"],
            grammarToolIDs: ["open_ac"],
            subsetContext: C6SubsetContext(
                subsetPolicyID: "policy-1",
                subsetGroupID: "group-ac",
                mountMode: "subset",
                mountedToolIDsDigest: "mounted-digest",
                grammarToolsDigest: "grammar-digest"
            )
        )

        let receipt = try C6SubsetDigestReceiptWriter.write(input)

        XCTAssertEqual(receipt.verdict, .blocked)
        XCTAssertTrue(receipt.axes.targetInPrompt)
        XCTAssertTrue(receipt.axes.expectedInMounted)
        XCTAssertFalse(receipt.axes.actualInAllowed)
        XCTAssertEqual(receipt.mismatchReasons, ["actual_not_in_allowed"])
        XCTAssertFalse(receipt.axes.promptToolsDigest.isEmpty)
        XCTAssertFalse(receipt.axes.grammarToolsDigest.isEmpty)
        XCTAssertFalse(receipt.axes.subsetPolicyDigest.isEmpty)
    }

    func testSixAxisDigestReceiptBlocksOnDigestMismatch() throws {
        let input = C6SubsetDigestReceiptInput(
            targetToolIDs: ["open_ac"],
            promptToolIDs: ["open_ac"],
            expectedToolIDs: ["open_ac"],
            mountedToolIDs: ["open_ac"],
            actualToolIDs: ["open_ac"],
            allowedToolIDs: ["open_ac"],
            grammarToolIDs: ["open_ac"],
            subsetContext: C6SubsetContext(subsetPolicyID: "policy-1"),
            expectedGrammarToolsDigest: "wrong-digest"
        )

        let receipt = try C6SubsetDigestReceiptWriter.write(input)

        XCTAssertEqual(receipt.verdict, .blocked)
        XCTAssertEqual(receipt.mismatchReasons, ["grammar_tools_digest_mismatch"])
    }

    func testRunnerSubsetEvaluationConsumesMountedSetAndEmitsSubsetFailureClass() throws {
        let subsetCase = C6SubsetBenchCase(
            base: Self.fixtureCase(),
            subsetContext: C6SubsetContext(
                subsetPolicyID: "policy-ac",
                subsetGroupID: "group-ac",
                mountMode: "subset",
                mountedToolIDsDigest: "mounted-close-only",
                grammarToolsDigest: "grammar-close-only"
            )
        )
        let runner = try Self.fixtureRunner()

        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(toolCalls: [], text: ""),
            mountedToolIDs: ["close_ac"],
            allowedToolIDs: ["close_ac"]
        )

        XCTAssertEqual(run.subsetContext?.subsetPolicyID, "policy-ac")
        XCTAssertEqual(run.subsetFailureClass, .missingExpectedInMounted)
        XCTAssertFalse(run.isModelFailure, "missing_expected_in_mounted is a mount accounting failure, not a model failure")
        XCTAssertTrue(run.base.gateResult.modelHardFailed, "base C6 gate still records the runner-visible hard failure")
    }

    func testRunnerConsumesExpectedUnsupportedClassMismatch() throws {
        let subsetCase = C6SubsetBenchCase(
            base: Self.fixtureCase(),
            subsetContext: C6SubsetContext(
                subsetPolicyID: "policy-ac",
                subsetGroupID: "group-ac",
                mountMode: "subset",
                mountedToolIDsDigest: "mounted-open-ac",
                grammarToolsDigest: "grammar-open-ac"
            ),
            expectedUnsupportedClass: .groupOutOfMount
        )
        let runner = try Self.fixtureRunner()

        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(
                toolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
                text: "空调已打开"
            ),
            mountedToolIDs: ["set_cabin_ac"],
            allowedToolIDs: ["set_cabin_ac"]
        )

        XCTAssertFalse(run.base.gateResult.modelHardFailed)
        XCTAssertEqual(run.subsetFailureClass, .unsupportedClassMismatch)
        XCTAssertFalse(run.isModelFailure)
    }

    func testRunnerAllowsGroupOutOfMountUnsupportedClassWhenExpectedToolIsNotMounted() throws {
        let subsetCase = C6SubsetBenchCase(
            base: Self.fixtureCase(),
            expectedUnsupportedClass: .groupOutOfMount
        )
        let runner = try Self.fixtureRunner()

        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(toolCalls: [], text: "当前分组没有这个控制项"),
            mountedToolIDs: ["close_ac"],
            allowedToolIDs: ["close_ac"]
        )

        XCTAssertTrue(run.base.gateResult.modelHardFailed)
        XCTAssertEqual(run.subsetFailureClass, .none)
    }

    func testRunnerAllowsMVPUnsupportedClassWhenNoToolReasonMatches() throws {
        let subsetCase = C6SubsetBenchCase(
            base: Self.unsupportedFixtureCase(caseID: "C6-SUBSET-MVP-UNSUPPORTED-001"),
            expectedUnsupportedClass: .mvpUnsupported
        )
        let runner = try Self.fixtureRunner()

        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(toolCalls: [], text: "这个车控功能暂不支持，不能执行"),
            mountedToolIDs: ["set_cabin_ac"],
            allowedToolIDs: ["set_cabin_ac"],
            actualUnsupportedClass: .mvpUnsupported
        )

        XCTAssertFalse(run.base.gateResult.modelHardFailed)
        XCTAssertEqual(run.subsetFailureClass, .none)
        XCTAssertFalse(run.isModelFailure)
    }

    func testRunnerAllowsGlobalUnsupportedClassWhenNoToolReasonMatches() throws {
        let subsetCase = C6SubsetBenchCase(
            base: Self.unsupportedFixtureCase(caseID: "C6-SUBSET-GLOBAL-UNSUPPORTED-001"),
            expectedUnsupportedClass: .globalUnsupported
        )
        let runner = try Self.fixtureRunner()

        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(toolCalls: [], text: "这不是车控功能，我不能执行"),
            mountedToolIDs: ["set_cabin_ac"],
            allowedToolIDs: ["set_cabin_ac"],
            actualUnsupportedClass: .globalUnsupported
        )

        XCTAssertFalse(run.base.gateResult.modelHardFailed)
        XCTAssertEqual(run.subsetFailureClass, .none)
        XCTAssertFalse(run.isModelFailure)
    }

    func testRunnerRejectsMVPGlobalUnsupportedClassMismatch() throws {
        let subsetCase = C6SubsetBenchCase(
            base: Self.unsupportedFixtureCase(caseID: "C6-SUBSET-UNSUPPORTED-MISMATCH-001"),
            expectedUnsupportedClass: .mvpUnsupported
        )
        let runner = try Self.fixtureRunner()

        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(toolCalls: [], text: "这不是车控功能，我不能执行"),
            mountedToolIDs: ["set_cabin_ac"],
            allowedToolIDs: ["set_cabin_ac"],
            actualUnsupportedClass: .globalUnsupported
        )

        XCTAssertFalse(run.base.gateResult.modelHardFailed)
        XCTAssertEqual(run.subsetFailureClass, .unsupportedClassMismatch)
        XCTAssertFalse(run.isModelFailure)
    }

    func testRunnerMarksModelFailureWhenMountedTargetProducesWrongOutput() throws {
        let subsetCase = C6SubsetBenchCase(base: Self.fixtureCase())
        let runner = try Self.fixtureRunner()

        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(toolCalls: [], text: ""),
            mountedToolIDs: ["set_cabin_ac"],
            allowedToolIDs: ["set_cabin_ac"]
        )

        XCTAssertEqual(run.subsetFailureClass, .none)
        XCTAssertTrue(run.base.gateResult.modelHardFailed)
        XCTAssertTrue(run.isModelFailure)
    }

    func testRunnerSubsetSummaryDerivesBlockedStatusFromSubsetFailureClass() throws {
        let subsetCase = C6SubsetBenchCase(base: Self.fixtureCase())
        let runner = try Self.fixtureRunner()
        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(toolCalls: [], text: ""),
            mountedToolIDs: ["close_ac"],
            allowedToolIDs: ["close_ac"]
        )

        let summary = runner.summarize(
            subsetCases: [subsetCase],
            subsetRuns: [run],
            validation: C6DatasetValidation(
                caseCount: 1,
                negativeRatio: 0,
                unresolvedSourceRefCount: 0,
                mustPassCount: 1,
                mustPassWithoutMustNotTrainCount: 0,
                representedDevices: 1,
                totalContractDevices: 1
            )
        )

        XCTAssertEqual(summary.status, "construction_subset_blocked")
        XCTAssertEqual(summary.subsetFailureStats.missingExpectedInMountedCount, 1)
        XCTAssertEqual(summary.subsetFailureStats.actualNotInAllowedCount, 0)
        XCTAssertEqual(summary.baseSummary.totalRuns, 1)
    }

    func testRunnerSubsetSummaryBlocksOnUnsupportedClassMismatch() throws {
        let subsetCase = C6SubsetBenchCase(base: Self.fixtureCase(), expectedUnsupportedClass: .groupOutOfMount)
        let runner = try Self.fixtureRunner()
        let run = try runner.evaluate(
            subsetCase: subsetCase,
            output: C6RuntimeOutput(
                toolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
                text: "空调已打开"
            ),
            mountedToolIDs: ["set_cabin_ac"],
            allowedToolIDs: ["set_cabin_ac"]
        )

        let summary = runner.summarize(
            subsetCases: [subsetCase],
            subsetRuns: [run],
            validation: C6DatasetValidation(
                caseCount: 1,
                negativeRatio: 0,
                unresolvedSourceRefCount: 0,
                mustPassCount: 1,
                mustPassWithoutMustNotTrainCount: 0,
                representedDevices: 1,
                totalContractDevices: 1
            )
        )

        XCTAssertEqual(summary.status, "construction_subset_blocked")
        XCTAssertEqual(summary.subsetFailureStats.missingExpectedInMountedCount, 0)
        XCTAssertEqual(summary.subsetFailureStats.actualNotInAllowedCount, 0)
        XCTAssertEqual(summary.subsetFailureStats.unsupportedClassMismatchCount, 1)
    }

    private static func fixtureCase() -> C6BenchCase {
        C6BenchCase(
            caseID: "C6-SUBSET-CONSUME-001",
            sourceRefs: C6SourceRefs(),
            tags: C6CaseTags(
                bucket: .action,
                mustPass: true,
                mustNotTrain: true,
                contractDevice: "ac",
                sampleKind: "subset-fixture"
            ),
            preState: [:],
            inputZh: "打开空调",
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectNoCall: false,
            expectedStateDelta: ["ac.power": "on"],
            readbackAssertion: C6ReadbackAssertion(contains: ["空调"]),
            clarifyTag: .implicit,
            failureClass: .none,
            behaviorClass: .toolCall
        )
    }

    private static func unsupportedFixtureCase(caseID: String) -> C6BenchCase {
        C6BenchCase(
            caseID: caseID,
            sourceRefs: C6SourceRefs(),
            tags: C6CaseTags(
                bucket: .refusal,
                mustPass: true,
                mustNotTrain: true,
                contractDevice: "unsupported",
                sampleKind: "subset-fixture"
            ),
            preState: [:],
            inputZh: "帮我订一杯咖啡",
            expectedToolCalls: [],
            expectNoCall: true,
            expectedStateDelta: [:],
            readbackAssertion: C6ReadbackAssertion(contains: ["不能"]),
            clarifyTag: .rejected,
            failureClass: .none,
            behaviorClass: .refusalNoAvailableTool
        )
    }

    private static func fixtureRunner() throws -> C6BenchRunner {
        let bundle = try C6ContractBundleFingerprint.receipt(components: [
            C6ContractBundleComponent(componentID: "c1.semantic_function_contract", version: "v1", contentDigest: "1111"),
            C6ContractBundleComponent(componentID: "c2.state_cells_renderer", version: "v1", contentDigest: "2222"),
            C6ContractBundleComponent(componentID: "c6.bench_cases", version: "v1", contentDigest: "3333"),
            C6ContractBundleComponent(componentID: "qwen.tool_call_format", version: "v1", contentDigest: "4444"),
            C6ContractBundleComponent(componentID: "d_domain.ir_map", version: "v1", contentDigest: "5555"),
            C6ContractBundleComponent(componentID: "d_domain.demo_tool_catalog", version: "v1", contentDigest: "6666"),
        ])
        return C6BenchRunner(
            qwenToolCallFormatVersion: "format-v1",
            contractDigest: "contract-digest",
            modelID: "model",
            modelArtifactDigest: "model-digest",
            tokenizerDigest: "tokenizer-digest",
            contractBundleFingerprint: bundle,
            stateCells: try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        )
    }

    private static func readRepoFile(_ relativePath: String) throws -> String {
        try String(contentsOf: repoRootURL().appendingPathComponent(relativePath), encoding: .utf8)
    }

    private static func repoRootURL() -> URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
