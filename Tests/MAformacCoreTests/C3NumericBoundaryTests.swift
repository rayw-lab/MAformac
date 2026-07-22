import XCTest
@testable import MAformacCore

final class C3NumericBoundaryTests: XCTestCase {
    @MainActor
    func testConvert_68F_and_68_0F_to_20C() throws {
        for lexeme in ["68", "68.0"] {
            let store = DemoVehicleStateStore()
            let pipeline = try makePipeline()
            let frame = ToolCallFrame.numericFixture(
                value: ContractValue(direct: lexeme, type: "SPOT", sourceUnit: .fahrenheit)
            )
            _ = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
            XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "20", lexeme)
            XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on", lexeme)
        }
    }

    @MainActor
    func testConvert_64_4F_to_18C_and_89_6F_to_32C() throws {
        let cases: [(String, String)] = [("64.4", "18"), ("89.6", "32")]
        for (lexeme, expected) in cases {
            let store = DemoVehicleStateStore()
            let pipeline = try makePipeline()
            let frame = ToolCallFrame.numericFixture(
                value: ContractValue(direct: lexeme, type: "SPOT", sourceUnit: .fahrenheit)
            )
            _ = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
            XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, expected, lexeme)
        }
    }

    @MainActor
    func testConvert_90F_and_68_5F_and_20_5C_unsupportedPrecision_mutationZero() throws {
        let cases: [ContractValue] = [
            ContractValue(direct: "90", type: "SPOT", sourceUnit: .fahrenheit),
            ContractValue(direct: "68.5", type: "SPOT", sourceUnit: .fahrenheit),
            ContractValue(direct: "20.5", type: "SPOT", sourceUnit: .celsius)
        ]
        for value in cases {
            let store = DemoVehicleStateStore()
            let beforeTemp = store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue
            let beforeRev = store.currentRevision
            let pipeline = try makePipeline()
            let frame = ToolCallFrame.numericFixture(value: value)
            XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
                XCTAssertEqual(error as? ToolExecutionError, .semanticInvalid("unsupported_precision"))
            }
            XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, beforeTemp)
            XCTAssertEqual(store.currentRevision, beforeRev)
        }
    }

    @MainActor
    func testDirect_IntMax_rangeRefusalOrOverflow_noCrash() throws {
        let store = DemoVehicleStateStore()
        let pipeline = try makePipeline()
        let frame = ToolCallFrame.numericFixture(
            value: ContractValue(direct: String(Int.max), type: "SPOT")
        )
        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            let toolError = error as? ToolExecutionError
            let ok = toolError == .schemaInvalid(.outOfRange("ac.temp_setpoint"))
                || toolError == .semanticInvalid("numeric_overflow")
                || toolError == .semanticInvalid("arithmetic_overflow")
            XCTAssertTrue(ok, "unexpected error: \(String(describing: error))")
        }
    }

    @MainActor
    func testCUR_current20_plusIntMax_checkedOverflow_mutationZero() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        let before = store.cell(for: "window.position[主驾]")?.actualValue
        let beforeRev = store.currentRevision
        let pipeline = try makePipeline()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.window",
            toolName: "vehicle_control",
            device: "window",
            actionPrimitive: "increase_by_number",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: String(Int.max), type: "SPOT"),
            stateRevision: store.currentRevision,
            candidateSource: .upstreamToolCall
        )
        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            XCTAssertEqual(error as? ToolExecutionError, .semanticInvalid("arithmetic_overflow"))
        }
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, before)
        XCTAssertEqual(store.currentRevision, beforeRev)
    }

    @MainActor
    func testCUR_subtractIntMin_checked_noSignMultiplyTrap() throws {
        let store = DemoVehicleStateStore()
        _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
        let before = store.cell(for: "window.position[主驾]")?.actualValue
        let beforeRev = store.currentRevision
        let pipeline = try makePipeline()
        // Old trap: sign(-1) * Int.min. Offset carries String(Int.min); must typed-refuse, never trap.
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.window",
            toolName: "vehicle_control",
            device: "window",
            actionPrimitive: "increase_by_number",
            slots: ["position": "主驾"],
            value: ContractValue(ref: "CUR", direct: "-", offset: String(Int.min), type: "SPOT"),
            stateRevision: store.currentRevision,
            candidateSource: .upstreamToolCall
        )
        XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
            let toolError = error as? ToolExecutionError
            let ok = toolError == .semanticInvalid("numeric_overflow")
                || toolError == .semanticInvalid("arithmetic_overflow")
                || toolError == .semanticInvalid("lexical_invalid")
            XCTAssertTrue(ok, "unexpected error: \(String(describing: error))")
        }
        XCTAssertEqual(store.cell(for: "window.position[主驾]")?.actualValue, before)
        XCTAssertEqual(store.currentRevision, beforeRev)
    }

    @MainActor
    func testCurrent_missing_or_abc_malformedCurrent_mutationZero() throws {
        for raw in ["", "abc"] {
            let store = DemoVehicleStateStore()
            _ = store.applyMockTransition(DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: raw))
            let beforeRev = store.currentRevision
            let pipeline = try makePipeline()
            let frame = ToolCallFrame(
                agentID: "vehicle-control",
                capabilityID: "cabin.ac_temperature",
                toolName: "vehicle_control",
                device: "ac_temperature",
                actionPrimitive: "increase_by_exp",
                slots: ["direction": "主驾"],
                value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
                stateRevision: store.currentRevision,
                candidateSource: .upstreamToolCall
            )
            XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
                XCTAssertEqual(error as? ToolExecutionError, .semanticInvalid("malformed_current"))
            }
            // Empty/abc must not silently become range.min (18) via fail-open.
            XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, raw)
            XCTAssertEqual(store.currentRevision, beforeRev)
        }
    }

    @MainActor
    func testFahrenheitRelative_CUR_or_EXP_unsupportedUnitReference() throws {
        let pipeline = try makePipeline()
        let cases: [ContractValue] = [
            ContractValue(ref: "CUR", direct: "+", offset: "2", type: "SPOT", sourceUnit: .fahrenheit),
            ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP", sourceUnit: .fahrenheit)
        ]
        for value in cases {
            let store = DemoVehicleStateStore()
            let before = store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue
            let beforeRev = store.currentRevision
            let primitive = value.type == "EXP" ? "increase_by_exp" : "increase_by_number"
            // SPOT CUR on ac hits allowlist deny for increase_by_number — use window for CUR SPOT.
            if value.type == "SPOT" {
                _ = store.applyMockTransition(DemoMockTransition(key: "window.position[主驾]", desiredValue: "20"))
                let frame = ToolCallFrame(
                    agentID: "vehicle-control",
                    capabilityID: "cabin.window",
                    toolName: "vehicle_control",
                    device: "window",
                    actionPrimitive: "increase_by_number",
                    slots: ["position": "主驾"],
                    value: value,
                    stateRevision: store.currentRevision,
                    candidateSource: .upstreamToolCall
                )
                XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
                    XCTAssertEqual(error as? ToolExecutionError, .semanticInvalid("unsupported_unit_reference"))
                }
            } else {
                let frame = ToolCallFrame.numericFixture(actionPrimitive: primitive, value: value)
                XCTAssertThrowsError(try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())) { error in
                    XCTAssertEqual(error as? ToolExecutionError, .semanticInvalid("unsupported_unit_reference"))
                }
                XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, before)
                XCTAssertEqual(store.currentRevision, beforeRev)
            }
        }
    }

    @MainActor
    func testIRBridge_passthrough_sourceUnit() throws {
        let ir = ToolContractIR(
            sourceToolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: [:],
            value: ContractValue(direct: "68", type: "SPOT", sourceUnit: .fahrenheit)
        )
        let frame = try ToolContractIRFrameBridge.frame(
            from: ir,
            traceID: "trace-unit",
            rawCall: C6ToolCall(name: "adjust_ac_temperature_to_number", arguments: ["temperature": "68"])
        )
        XCTAssertEqual(frame.value.sourceUnit, .fahrenheit)
        XCTAssertEqual(frame.value.direct, "68")
    }

    private func makePipeline() throws -> C3ExecutionPipeline {
        let semantic = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))
        let allowlist = try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        return C3ExecutionPipeline(
            semantic: semantic,
            stateCells: stateCells,
            riskPolicy: risk,
            allowlist: allowlist,
            intentConfirmed: { true }
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

private extension ToolCallFrame {
    static func numericFixture(
        actionPrimitive: String = "adjust_to_number",
        value: ContractValue
    ) -> ToolCallFrame {
        ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_temperature",
            toolName: "vehicle_control",
            device: "ac_temperature",
            actionPrimitive: actionPrimitive,
            slots: ["direction": "主驾"],
            value: value,
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )
    }
}
