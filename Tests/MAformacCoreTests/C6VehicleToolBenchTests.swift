import XCTest
@testable import MAformacCore

final class C6VehicleToolBenchTests: XCTestCase {
    func testDatasetGenerationCarriesSchemaRefsNegativeRatioAndMustNotTrain() throws {
        let generator = try makeGenerator()
        let cases = try generator.generate()
        let validation = generator.validate(cases)

        XCTAssertGreaterThanOrEqual(cases.count, 38)
        XCTAssertEqual(validation.unresolvedSourceRefCount, 0)
        XCTAssertGreaterThanOrEqual(validation.negativeRatio, 0.2)
        XCTAssertGreaterThanOrEqual(validation.mustPassCount, 30)
        XCTAssertEqual(validation.mustPassWithoutMustNotTrainCount, 0)

        let action = try XCTUnwrap(cases.first { $0.tags.bucket == .action })
        XCTAssertFalse(action.inputZh.isEmpty)
        XCTAssertFalse(action.preState.isEmpty)
        XCTAssertFalse(action.expectedToolCalls.isEmpty)
        XCTAssertFalse(action.expectedStateDelta.isEmpty)
        XCTAssertFalse(action.readbackAssertion.contains.isEmpty)

        let noCall = try XCTUnwrap(cases.first { $0.expectNoCall })
        XCTAssertTrue(noCall.expectedToolCalls.isEmpty)
    }

    func testToolCallSetGateRejectsMissingExtraWrongArgumentsAndDuplicates() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        let pass = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开"))
        XCTAssertFalse(pass.gateResult.hardFailed)
        XCTAssertTrue(pass.gateResult.toolCallSetMatch)

        let missing = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: []))
        XCTAssertTrue(missing.gateResult.hardFailed)
        XCTAssertTrue(missing.gateResult.failureClasses.contains(.toolCall))

        let extra = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"]),
            C6ToolCall(name: "set_cabin_window", arguments: ["position": "driver", "percent": "50"])
        ]))
        XCTAssertTrue(extra.gateResult.failureClasses.contains(.toolCall))

        let wrongArgument = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "off"])
        ]))
        XCTAssertTrue(wrongArgument.gateResult.failureClasses.contains(.toolCall))

        let duplicate = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"]),
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ]))
        XCTAssertTrue(duplicate.gateResult.failureClasses.contains(.toolCall))
    }

    func testReadbackGateRejectsMachineStringAndAcceptsC2RenderedChinese() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on", "delta": "warmer"])],
            expectedStateDelta: ["ac.temp_setpoint[主驾]": "26"],
            readbackContains: ["主驾", "26"]
        )

        let machineString = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on", "delta": "warmer"])
        ], text: "ac.temp_setpoint[主驾]=26"))
        XCTAssertFalse(machineString.gateResult.readbackMatch)
        XCTAssertTrue(machineString.gateResult.failureClasses.contains(.readback))

        let chineseReadback = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on", "delta": "warmer"])
        ], text: "主驾空调已设为26度"))
        XCTAssertTrue(chineseReadback.gateResult.readbackMatch)
        XCTAssertFalse(chineseReadback.gateResult.hardFailed)
    }

    func testReadbackGateUsesEnumBranchFromStateCellTemplate() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        let wrongBranch = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已关闭"))
        XCTAssertFalse(wrongBranch.gateResult.readbackMatch)
        XCTAssertTrue(wrongBranch.gateResult.failureClasses.contains(.readback))

        let rightBranch = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开"))
        XCTAssertTrue(rightBranch.gateResult.readbackMatch)
        XCTAssertFalse(rightBranch.gateResult.hardFailed)
    }

    func testReadbackGateRejectsAssertionOnlyMatchWhenC2TemplateIsMissing() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ambient_light", arguments: ["power": "on", "color": "red"])],
            expectedStateDelta: ["ambient.color": "红"],
            readbackContains: ["氛围灯", "红"]
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ambient_light", arguments: ["power": "on", "color": "red"])
        ], text: "氛围灯红色已打开"))

        XCTAssertTrue(result.gateResult.stateDeltaMatch)
        XCTAssertFalse(result.gateResult.readbackMatch)
        XCTAssertTrue(result.gateResult.failureClasses.contains(.readback))
    }

    func testReadbackGateRejectsNegatedTokenMatch() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on", "delta": "warmer"])],
            expectedStateDelta: ["ac.temp_setpoint[主驾]": "26"],
            readbackContains: ["主驾", "26"]
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on", "delta": "warmer"])
        ], text: "主驾空调不是26度"))

        XCTAssertFalse(result.gateResult.readbackMatch)
        XCTAssertTrue(result.gateResult.failureClasses.contains(.readback))
    }

    func testNoCallCaseDoesNotReportFakeReadbackPass() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            bucket: .noCall,
            expectedToolCalls: [],
            expectNoCall: true,
            expectedStateDelta: [:],
            readbackContains: [],
            clarifyTag: .rejected
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [], text: "这个我不能执行"))

        XCTAssertFalse(result.gateResult.readbackMatch)
        XCTAssertFalse(result.gateResult.hardFailed)
    }

    func testNoCallPreconditionStateDoesNotInvokeReadbackGate() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            bucket: .refusal,
            expectedToolCalls: [],
            expectNoCall: true,
            expectedStateDelta: ["vehicle.speed": "30"],
            readbackContains: ["行驶中"],
            clarifyTag: .rejected,
            preState: ["vehicle.speed": "30", "vehicle.gear": "D"]
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [], text: "行驶中不能开门"))

        XCTAssertTrue(result.gateResult.stateDeltaMatch)
        XCTAssertFalse(result.gateResult.readbackMatch)
        XCTAssertFalse(result.gateResult.failureClasses.contains(.readback))
        XCTAssertFalse(result.gateResult.hardFailed)
    }

    func testExpectNoCallGateCountsFalsePositive() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            bucket: .noCall,
            expectedToolCalls: [],
            expectNoCall: true,
            expectedStateDelta: [:],
            readbackContains: []
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ]))

        XCTAssertEqual(result.gateResult.noToolFalsePositiveCount, 1)
        XCTAssertTrue(result.gateResult.failureClasses.contains(.noCall))
    }

    func testStateDeltaAndReadbackAreSeparateHardGates() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_screen_brightness", arguments: ["percent": "40"])],
            expectedStateDelta: ["screen.brightness[中控屏]": "40"],
            readbackContains: ["屏幕", "40"]
        )

        let pass = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_screen_brightness", arguments: ["percent": "40"])
        ], text: "中控屏幕亮度已调到40%"))
        XCTAssertTrue(pass.gateResult.stateDeltaMatch)
        XCTAssertTrue(pass.gateResult.readbackMatch)

        let badState = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_screen_brightness", arguments: ["percent": "60"])
        ]))
        XCTAssertFalse(badState.gateResult.stateDeltaMatch)
        XCTAssertTrue(badState.gateResult.failureClasses.contains(.stateDelta))
    }

    func testClarifyAndRefusalCorrectnessBlocksWrongAction() throws {
        let runner = try makeRunner()
        let refusal = C6BenchCase.fixture(
            bucket: .refusal,
            expectedToolCalls: [],
            expectNoCall: true,
            expectedStateDelta: [:],
            readbackContains: [],
            clarifyTag: .rejected
        )

        let bad = try runner.evaluate(case: refusal, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "已打开"))
        XCTAssertFalse(bad.gateResult.clarifyMatch)
        XCTAssertTrue(bad.gateResult.failureClasses.contains(.noCall))

        let good = try runner.evaluate(case: refusal, output: C6RuntimeOutput(toolCalls: [], text: "这个我不能执行"))
        XCTAssertFalse(good.gateResult.hardFailed)
        XCTAssertNotNil(good.gateResult.judge)
    }

    func testJudgeSchemaOnlyRunsAfterHardGatesPassAndHasNoHardGateFields() throws {
        let runner = try makeRunner()
        let refusal = C6BenchCase.fixture(
            bucket: .refusal,
            expectedToolCalls: [],
            expectNoCall: true,
            expectedStateDelta: [:],
            readbackContains: [],
            clarifyTag: .rejected
        )

        let hardFailed = try runner.evaluate(case: refusal, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_window", arguments: ["position": "driver", "percent": "100"])
        ]))
        XCTAssertNil(hardFailed.gateResult.judge)

        let passed = try runner.evaluate(case: refusal, output: C6RuntimeOutput(toolCalls: [], text: "行驶中不能开门"))
        let judge = try XCTUnwrap(passed.gateResult.judge)
        let data = try JSONEncoder().encode(judge)
        let json = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(json.contains("refusal_text_score"))
        XCTAssertFalse(json.contains("tool"))
        XCTAssertFalse(json.contains("state"))
        XCTAssertFalse(json.contains("readback"))
        XCTAssertFalse(json.contains("tts"))
    }

    func testReplayFingerprintRecordsTenRequiredFields() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )
        let run = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开", samplingSeed: "3"), runIndex: 3)

        XCTAssertTrue(run.hasRequiredFingerprintFields)
        XCTAssertEqual(run.runID, "c6-C6-FIXTURE-001-3")
        XCTAssertEqual(run.modelID, "base")
        XCTAssertEqual(run.loraAdapterID, "")
        XCTAssertEqual(run.loraCheckpointID, "")
        XCTAssertEqual(run.qwenToolCallFormatVersion, "format-hash")
        XCTAssertEqual(run.contractDigest, "contract-digest")
    }

    func testSummaryKeepsCoverageAndScenarioAxesSeparateAndSupportsBaseLoRADiffIndex() throws {
        let runner = try makeRunner()
        let generator = try makeGenerator()
        let cases = Array(try generator.generate().prefix(5))
        let validation = generator.validate(cases)
        let runs = try cases.enumerated().map { index, item in
            try runner.evaluate(case: item, output: C6RuntimeOutput(toolCalls: item.expectedToolCalls, text: "ok", samplingSeed: "\(index)"), runIndex: index)
        }

        let summary = runner.summarize(cases: cases, runs: runs, validation: validation)

        XCTAssertGreaterThanOrEqual(summary.contractCoverageScore, 0)
        XCTAssertGreaterThanOrEqual(summary.scenarioScore, 0)
        XCTAssertEqual(summary.evalRuns.map(\.caseID).count, runs.count)
        XCTAssertFalse(summary.perCaseStats.isEmpty)
        XCTAssertEqual(Set(summary.evalRuns.map(\.loraCheckpointID)), [""])
    }

    func testFormatDigestChangesWhenFormatFileContentChanges() throws {
        let first = C6Hash.sha256Hex(Data("runtime_parser: json\n".utf8))
        let second = C6Hash.sha256Hex(Data("runtime_parser: xml\n".utf8))

        XCTAssertNotEqual(first, second)
    }

    private func makeGenerator() throws -> C6DatasetGenerator {
        C6DatasetGenerator(
            semantic: try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl")),
            stateCells: try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml")),
            demoScenariosYAML: try readRepoFile("contracts/demo-scenarios.yaml"),
            riskPolicyYAML: try readRepoFile("contracts/risk-policy.yaml")
        )
    }

    private func makeRunner() throws -> C6BenchRunner {
        C6BenchRunner(
            qwenToolCallFormatVersion: "format-hash",
            contractDigest: "contract-digest",
            modelID: "base",
            stateCells: try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        )
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}

private extension C6BenchCase {
    static func fixture(
        bucket: C6Bucket = .action,
        expectedToolCalls: [C6ToolCall],
        expectNoCall: Bool = false,
        expectedStateDelta: [String: String],
        readbackContains: [String],
        clarifyTag: C6ClarifyTag = .implicit,
        preState: [String: String] = [
            "ac.power": "off",
            "screen.brightness[中控屏]": "70"
        ]
    ) -> C6BenchCase {
        C6BenchCase(
            caseID: "C6-FIXTURE-001",
            sourceRefs: C6SourceRefs(semanticContractIDs: ["c1_fixture"], stateCellIDs: ["ac.power"], scenarioIDs: ["scene1"]),
            tags: C6CaseTags(bucket: bucket, mustPass: true, mustNotTrain: true, contractDevice: "fixture", scenarioID: "scene1", sampleKind: "fixture"),
            preState: preState,
            inputZh: "fixture",
            expectedToolCalls: expectedToolCalls,
            expectNoCall: expectNoCall,
            expectedStateDelta: expectedStateDelta,
            readbackAssertion: C6ReadbackAssertion(contains: readbackContains),
            clarifyTag: clarifyTag,
            failureClass: .none
        )
    }
}
