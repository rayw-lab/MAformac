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

    func testDatasetCodecDefaultsMissingAlternativesToEmptyArray() throws {
        let jsonl = """
        {"case_id":"C6-OLD-001","source_refs":{"semantic_contract_ids":["c1_fixture"],"state_cell_ids":["ac.power"],"scenario_ids":["scene1"],"risk_rule_ids":[]},"tags":{"bucket":"action","must_pass":true,"must_not_train":true,"contract_device":"fixture","scenario_id":"scene1","sample_kind":"fixture"},"pre_state":{"ac.power":"off"},"input_zh":"打开空调","expected_tool_calls":[{"name":"set_cabin_ac","arguments":{"power":"on"}}],"expect_no_call":false,"expected_state_delta":{"ac.power":"on"},"readback_assertion":{"contains":["空调"]},"clarify_tag":"implicit","failure_class":"none"}
        """

        let cases = try C6DatasetCodec().decodeJSONL(jsonl)

        XCTAssertEqual(cases.count, 1)
        XCTAssertEqual(cases[0].alternatives, [])
    }

    func testDatasetCodecDecodesAcceptableAlternative() throws {
        let jsonl = """
        {"case_id":"C6-ALT-001","source_refs":{"semantic_contract_ids":["c1_fixture"],"state_cell_ids":["ac.power"],"scenario_ids":["scene1"],"risk_rule_ids":[]},"tags":{"bucket":"action","must_pass":true,"must_not_train":true,"contract_device":"fixture","scenario_id":"scene1","sample_kind":"fixture"},"pre_state":{"ac.power":"off","window.position[主驾]":"0"},"input_zh":"有点闷","expected_tool_calls":[{"name":"set_cabin_ac","arguments":{"power":"on"}}],"expect_no_call":false,"expected_state_delta":{"ac.power":"on"},"readback_assertion":{"contains":["空调"]},"clarify_tag":"implicit","failure_class":"none","alternatives":[{"id":"open_driver_window","expected_tool_calls":[{"name":"set_cabin_window","arguments":{"position":"driver","percent":"20"}}],"expect_no_call":false,"expected_state_delta":{"window.position[主驾]":"20"},"readback_assertion":{"contains":["主驾","20"]},"clarify_tag":"implicit","failure_class":"none","quality":"acceptable","reason":"通风是闷热表达的可接受车控解"}]}
        """

        let item = try XCTUnwrap(try C6DatasetCodec().decodeJSONL(jsonl).first)

        XCTAssertEqual(item.alternatives.count, 1)
        XCTAssertEqual(item.alternatives[0].id, "open_driver_window")
        XCTAssertEqual(item.alternatives[0].quality, "acceptable")
    }

    func testTrackedDatasetDecodesValidatesTrapCasesAndAlternatives() throws {
        let generator = try makeGenerator()
        let cases = try C6DatasetCodec().decodeJSONL(readRepoFile("contracts/c6-bench-cases.jsonl"))
        let validation = generator.validate(cases)
        let trapCases = cases.filter { $0.caseID.hasPrefix("C6-TRAP-") }
        let trapKinds = Dictionary(grouping: trapCases, by: \.tags.sampleKind)
        let alternativesCount = trapCases.map(\.alternatives.count).reduce(0, +)

        XCTAssertEqual(validation.unresolvedSourceRefCount, 0)
        XCTAssertEqual(validation.mustPassWithoutMustNotTrainCount, 0)
        XCTAssertEqual(trapCases.count, 12)
        XCTAssertEqual(trapKinds["trap-negation"]?.count, 2)
        XCTAssertEqual(trapKinds["trap-numeric-lure"]?.count, 2)
        XCTAssertEqual(trapKinds["trap-correction"]?.count, 2)
        XCTAssertEqual(trapKinds["trap-ambiguous"]?.count, 2)
        XCTAssertEqual(trapKinds["trap-safety-inheritance"]?.count, 2)
        XCTAssertEqual(trapKinds["trap-low-confidence-asr"]?.count, 2)
        XCTAssertEqual(alternativesCount, 2)
        XCTAssertTrue(trapCases.allSatisfy { $0.tags.mustPass && $0.tags.mustNotTrain })
        XCTAssertTrue(trapCases.filter { $0.tags.sampleKind == "trap-low-confidence-asr" }.allSatisfy { !$0.readbackAssertion.contains.isEmpty })
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

    func testAcceptableAlternativeCanSatisfyHardGatesWhenPrimaryFails() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"],
            preState: ["ac.power": "off", "window.position[主驾]": "0"],
            alternatives: [
                C6GoldAlternative(
                    id: "open_driver_window",
                    expectedToolCalls: [C6ToolCall(name: "set_cabin_window", arguments: ["position": "driver", "percent": "20"])],
                    expectNoCall: false,
                    expectedStateDelta: ["window.position[主驾]": "20"],
                    readbackAssertion: C6ReadbackAssertion(contains: ["主驾", "20"]),
                    clarifyTag: .implicit,
                    failureClass: .none,
                    quality: "acceptable",
                    reason: "通风是可接受替代解"
                )
            ]
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_window", arguments: ["position": "driver", "percent": "20"])
        ], text: "主驾车窗已打开到20%"))

        XCTAssertFalse(result.gateResult.hardFailed)
        XCTAssertTrue(result.gateResult.toolCallSetMatch)
        XCTAssertTrue(result.gateResult.stateDeltaMatch)
        XCTAssertTrue(result.gateResult.readbackMatch)
    }

    func testDegradedAndUnknownAlternativesDoNotSatisfyHardGates() throws {
        let runner = try makeRunner()
        let alternatives = ["degraded", "unknown"].map { quality in
            C6GoldAlternative(
                id: "alt-\(quality)",
                expectedToolCalls: [C6ToolCall(name: "set_cabin_window", arguments: ["position": "driver", "percent": "20"])],
                expectNoCall: false,
                expectedStateDelta: ["window.position[主驾]": "20"],
                readbackAssertion: C6ReadbackAssertion(contains: ["主驾", "20"]),
                clarifyTag: .implicit,
                failureClass: .none,
                quality: quality,
                reason: "not acceptable"
            )
        }
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"],
            preState: ["ac.power": "off", "window.position[主驾]": "0"],
            alternatives: alternatives
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_window", arguments: ["position": "driver", "percent": "20"])
        ], text: "主驾车窗已打开到20%"))

        XCTAssertTrue(result.gateResult.hardFailed)
        XCTAssertTrue(result.gateResult.failureClasses.contains(.toolCall))
    }

    func testGoldVerifierHappyPathReplaysPrimaryGold() throws {
        let stateCells = try makeStateCells()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        let report = C6GoldVerifier().report(cases: [caseItem], stateCells: stateCells, validation: goldValidation(caseCount: 1))

        XCTAssertEqual(report.status, "pass")
        XCTAssertEqual(report.goldReplayPassCount, 1)
        XCTAssertEqual(report.goldReplayFailCount, 0)
        XCTAssertEqual(report.results[0].candidateID, "primary")
        XCTAssertTrue(report.results[0].toolCallPass)
        XCTAssertTrue(report.results[0].stateDeltaPass)
        XCTAssertTrue(report.results[0].readbackPass)
    }

    func testGoldVerifierFailsStateChangingGoldWithoutC2ReadbackTemplate() throws {
        let stateCells = try missingReadbackStateCells()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        let report = C6GoldVerifier().report(cases: [caseItem], stateCells: stateCells, validation: goldValidation(caseCount: 1))

        XCTAssertEqual(report.status, "fail")
        XCTAssertEqual(report.goldReplayFailCount, 1)
        XCTAssertFalse(report.results[0].readbackPass)
        XCTAssertTrue(report.results[0].failureClasses.contains(.readback))
    }

    func testGoldVerifierFailsWhenToolCallsDoNotReachExpectedStateDelta() throws {
        let stateCells = try makeStateCells()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "off"],
            readbackContains: ["空调"]
        )

        let report = C6GoldVerifier().report(cases: [caseItem], stateCells: stateCells, validation: goldValidation(caseCount: 1))

        XCTAssertEqual(report.status, "fail")
        XCTAssertFalse(report.results[0].stateDeltaPass)
        XCTAssertTrue(report.results[0].failureClasses.contains(.stateDelta))
    }

    func testGoldVerifierFailsMutatingToolWithoutExpectedStateDelta() throws {
        let stateCells = try makeStateCells()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: [:],
            readbackContains: ["空调"]
        )

        let report = C6GoldVerifier().report(cases: [caseItem], stateCells: stateCells, validation: goldValidation(caseCount: 1))

        XCTAssertEqual(report.status, "fail")
        XCTAssertFalse(report.results[0].stateDeltaPass)
        XCTAssertTrue(report.results[0].failureClasses.contains(.stateDelta))
    }

    func testGoldVerifierTreatsAcceptableAlternativeAsCaseValid() throws {
        let stateCells = try makeStateCells()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "off"],
            readbackContains: ["空调"],
            preState: ["ac.power": "off", "window.position[主驾]": "0"],
            alternatives: [
                C6GoldAlternative(
                    id: "open_driver_window",
                    expectedToolCalls: [C6ToolCall(name: "set_cabin_window", arguments: ["position": "driver", "percent": "20"])],
                    expectNoCall: false,
                    expectedStateDelta: ["window.position[主驾]": "20"],
                    readbackAssertion: C6ReadbackAssertion(contains: ["主驾", "20"]),
                    clarifyTag: .implicit,
                    failureClass: .none,
                    quality: "acceptable",
                    reason: "可接受替代解"
                )
            ]
        )

        let report = C6GoldVerifier().report(cases: [caseItem], stateCells: stateCells, validation: goldValidation(caseCount: 1))

        XCTAssertEqual(report.status, "pass")
        XCTAssertEqual(report.candidateCount, 2)
        XCTAssertEqual(report.goldReplayPassCount, 1)
        XCTAssertEqual(report.goldReplayFailCount, 0)
        XCTAssertTrue(report.results.contains { $0.candidateID == "open_driver_window" && $0.goldReplayPass })
        XCTAssertTrue(report.results.contains { $0.candidateID == "primary" && !$0.goldReplayPass })
    }

    func testGoldVerifierMarksNoCallReadbackNonApplicableInsteadOfPass() throws {
        let stateCells = try makeStateCells()
        let caseItem = C6BenchCase.fixture(
            bucket: .refusal,
            expectedToolCalls: [],
            expectNoCall: true,
            expectedStateDelta: ["vehicle.speed": "30"],
            readbackContains: ["行驶中"],
            clarifyTag: .rejected,
            preState: ["vehicle.speed": "30", "vehicle.gear": "D"]
        )

        let report = C6GoldVerifier().report(cases: [caseItem], stateCells: stateCells, validation: goldValidation(caseCount: 1))
        let result = try XCTUnwrap(report.results.first)

        XCTAssertEqual(report.status, "pass")
        XCTAssertFalse(result.readbackApplicable)
        XCTAssertFalse(result.readbackPass)
        XCTAssertFalse(result.failureClasses.contains(.readback))
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
        let runner = try makeRunner(stateCells: missingReadbackStateCells())
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开"))

        XCTAssertTrue(result.gateResult.stateDeltaMatch)
        XCTAssertFalse(result.gateResult.readbackMatch)
        XCTAssertTrue(result.gateResult.failureClasses.contains(.readback))
    }

    func testRefusalGateRequiresTextEvidenceWhenAssertionIsProvided() throws {
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

        let emptyText = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [], text: ""))
        XCTAssertTrue(emptyText.gateResult.hardFailed)
        XCTAssertTrue(emptyText.gateResult.failureClasses.contains(.refusal))
        XCTAssertFalse(emptyText.gateResult.failureClasses.contains(.readback))

        let refusalText = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [], text: "行驶中不能开门"))
        XCTAssertFalse(refusalText.gateResult.hardFailed)
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

    func testReplayFingerprintRecordsArtifactDigestsAsRequiredFields() throws {
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
        XCTAssertEqual(run.modelArtifactDigest, "model-digest")
        XCTAssertEqual(run.tokenizerDigest, "tokenizer-digest")
        XCTAssertEqual(run.loraAdapterDigest, "")
        XCTAssertEqual(run.qwenToolCallFormatVersion, "format-hash")
        XCTAssertEqual(run.contractDigest, "contract-digest")
    }

    func testLoRAIdentifierRequiresAdapterDigest() throws {
        let runner = try makeRunner(
            loraAdapterID: "adapter-a",
            loraCheckpointID: "ckpt-1",
            loraAdapterDigest: ""
        )
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        XCTAssertThrowsError(try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开"))) { error in
            XCTAssertEqual(error as? C6InfraError, .missingEvalRunField("C6-FIXTURE-001"))
        }
    }

    func testMissingModelArtifactDigestFailsFingerprintGate() throws {
        let runner = try makeRunner(modelArtifactDigest: "")
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        XCTAssertThrowsError(try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开"))) { error in
            XCTAssertEqual(error as? C6InfraError, .missingEvalRunField("C6-FIXTURE-001"))
        }
    }

    func testMissingTokenizerDigestFailsFingerprintGate() throws {
        let runner = try makeRunner(tokenizerDigest: "")
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )

        XCTAssertThrowsError(try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开"))) { error in
            XCTAssertEqual(error as? C6InfraError, .missingEvalRunField("C6-FIXTURE-001"))
        }
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

    func testSummaryRecordsArtifactDigestsAtTopLevelAndEachEvalRun() throws {
        let runner = try makeRunner()
        let caseItem = C6BenchCase.fixture(
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectedStateDelta: ["ac.power": "on"],
            readbackContains: ["空调"]
        )
        let run = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
            C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
        ], text: "空调已打开"))

        let summary = runner.summarize(cases: [caseItem], runs: [run], validation: C6DatasetValidation(
            caseCount: 1,
            negativeRatio: 0,
            unresolvedSourceRefCount: 0,
            mustPassCount: 1,
            mustPassWithoutMustNotTrainCount: 0,
            representedDevices: 1,
            totalContractDevices: 1
        ))

        XCTAssertEqual(summary.modelArtifactDigest, "model-digest")
        XCTAssertEqual(summary.tokenizerDigest, "tokenizer-digest")
        XCTAssertEqual(summary.loraAdapterDigest, "")
        XCTAssertEqual(Set(summary.evalRuns.map(\.modelArtifactDigest)), ["model-digest"])
        XCTAssertEqual(Set(summary.evalRuns.map(\.tokenizerDigest)), ["tokenizer-digest"])
        XCTAssertEqual(Set(summary.evalRuns.map(\.loraAdapterDigest)), [""])
    }

    private func goldValidation(caseCount: Int) -> C6DatasetValidation {
        C6DatasetValidation(
            caseCount: caseCount,
            negativeRatio: 0,
            unresolvedSourceRefCount: 0,
            mustPassCount: caseCount,
            mustPassWithoutMustNotTrainCount: 0,
            representedDevices: 1,
            totalContractDevices: 1
        )
    }

    private func makeStateCells() throws -> StateCellContractLookup {
        try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
    }

    func testFormatDigestChangesWhenFormatFileContentChanges() throws {
        let first = C6Hash.sha256Hex(Data("runtime_parser: json\n".utf8))
        let second = C6Hash.sha256Hex(Data("runtime_parser: xml\n".utf8))

        XCTAssertNotEqual(first, second)
    }

    func testFileHashChangesWhenFileContentChanges() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("c6-hash-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let firstURL = directory.appendingPathComponent("first.bin")
        let secondURL = directory.appendingPathComponent("second.bin")
        try Data("model-a".utf8).write(to: firstURL)
        try Data("model-b".utf8).write(to: secondURL)

        XCTAssertNotEqual(try C6Hash.fileHash(url: firstURL), try C6Hash.fileHash(url: secondURL))
    }

    private func makeGenerator() throws -> C6DatasetGenerator {
        C6DatasetGenerator(
            semantic: try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl")),
            stateCells: try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml")),
            demoScenariosYAML: try readRepoFile("contracts/demo-scenarios.yaml"),
            riskPolicyYAML: try readRepoFile("contracts/risk-policy.yaml")
        )
    }

    private func makeRunner(
        modelArtifactDigest: String = "model-digest",
        tokenizerDigest: String = "tokenizer-digest",
        loraAdapterID: String = "",
        loraCheckpointID: String = "",
        loraAdapterDigest: String = "",
        stateCells: StateCellContractLookup? = nil
    ) throws -> C6BenchRunner {
        C6BenchRunner(
            qwenToolCallFormatVersion: "format-hash",
            contractDigest: "contract-digest",
            modelID: "base",
            modelArtifactDigest: modelArtifactDigest,
            tokenizerDigest: tokenizerDigest,
            loraAdapterDigest: loraAdapterDigest,
            loraAdapterID: loraAdapterID,
            loraCheckpointID: loraCheckpointID,
            stateCells: try stateCells ?? StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
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

    private func missingReadbackStateCells() throws -> StateCellContractLookup {
        try StateCellContractLookup(yaml: """
        device_cells:
          ac:
            state_cells:
              - id: ac.power
                type: enum
                values: [on, off]
        """)
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
        ],
        alternatives: [C6GoldAlternative] = []
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
            failureClass: .none,
            alternatives: alternatives
        )
    }
}
