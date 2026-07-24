import XCTest
@testable import MAformacCore

/// G2-P3: customer-entry °F exact templates + sourceUnit end-to-end passthrough.
final class FahrenheitAdmissionTests: XCTestCase {
    private let catalog = DemoSliceAdmissionCatalog()

    func testAdmit_68F_symbol_carriesSourceUnitAndLexeme() throws {
        let admission = try XCTUnwrap(catalog.admission(for: "主驾制热调68°F"))
        XCTAssertEqual(admission.entry.matrixID, 167)
        XCTAssertEqual(admission.entry.contractRowID, "c1_airControl_000167")
        XCTAssertEqual(admission.frame.value.direct, "68")
        XCTAssertEqual(admission.frame.value.sourceUnit, .fahrenheit)
        XCTAssertEqual(admission.frame.slots["adjustment_mode"], "华氏度")
        XCTAssertEqual(admission.frame.slots["direction"], "主驾")
        XCTAssertEqual(admission.frame.slots["mode"], "制热")
    }

    func testAdmit_68_0F_and_ChineseAlias_sameSourceUnit() throws {
        for utterance in ["主驾制热调68.0°F", "主驾制热调68华氏度", "主驾制热调68℉"] {
            let admission = try XCTUnwrap(catalog.admission(for: utterance), utterance)
            XCTAssertEqual(admission.frame.value.sourceUnit, .fahrenheit, utterance)
            XCTAssertEqual(admission.frame.value.direct, utterance.contains("68.0") ? "68.0" : "68", utterance)
        }
    }

    func testAdmit_64_4F_and_89_6F_keepDecimalLexeme() throws {
        let cases: [(String, String)] = [
            ("主驾制热调64.4°F", "64.4"),
            ("主驾制热调89.6°F", "89.6"),
            ("主驾制热调75.2°F", "75.2"),
        ]
        for (utterance, lexeme) in cases {
            let admission = try XCTUnwrap(catalog.admission(for: utterance), utterance)
            XCTAssertEqual(admission.frame.value.direct, lexeme, utterance)
            XCTAssertEqual(admission.frame.value.sourceUnit, .fahrenheit, utterance)
        }
    }

    func testAdmit_celsiusSymbol_stillCelsiusIntegerPath() throws {
        let admission = try XCTUnwrap(catalog.admission(for: "主驾制热调24°C"))
        XCTAssertEqual(admission.frame.value.direct, "24")
        XCTAssertEqual(admission.frame.value.sourceUnit, .celsius)
        XCTAssertEqual(admission.frame.slots["adjustment_mode"], "摄氏度")
    }

    func testRefuse_bareFWithoutDegree_notInCatalog() {
        XCTAssertEqual(catalog.rejection(for: "主驾制热调68F"), .notInCatalog)
        XCTAssertEqual(catalog.rejection(for: "主驾制热调64.4"), .notInCatalog)
    }

    func testRefuse_lexicalInvalidFahrenheit_notInCatalog() {
        XCTAssertEqual(catalog.rejection(for: "主驾制热调68.5.2°F"), .notInCatalog)
        XCTAssertEqual(catalog.rejection(for: "主驾制热调abc°F"), .notInCatalog)
        XCTAssertEqual(catalog.rejection(for: "主驾制热调1e2°F"), .notInCatalog)
    }

    @MainActor
    func testBoundary_64_4_68_89_6_executeToCanonicalCelsius() throws {
        let cases: [(String, String)] = [
            ("主驾制热调64.4°F", "18"),
            ("主驾制热调68°F", "20"),
            ("主驾制热调89.6°F", "32"),
        ]
        for (utterance, expectedC) in cases {
            let admission = try XCTUnwrap(catalog.admission(for: utterance), utterance)
            let store = DemoVehicleStateStore()
            let pipeline = try makePipeline()
            _ = try pipeline.execute(admission.frame, store: store, traceLogger: InMemoryTraceLogger())
            XCTAssertEqual(
                store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue,
                expectedC,
                utterance
            )
        }
    }

    @MainActor
    func testIllegalPrecision_90F_and_68_5F_typedUnsupportedPrecision() throws {
        for utterance in ["主驾制热调90°F", "主驾制热调68.5°F"] {
            let admission = try XCTUnwrap(catalog.admission(for: utterance), utterance)
            XCTAssertEqual(admission.frame.value.sourceUnit, .fahrenheit, utterance)
            let store = DemoVehicleStateStore()
            let beforeTemp = store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue
            let beforeRev = store.currentRevision
            let pipeline = try makePipeline()
            XCTAssertThrowsError(
                try pipeline.execute(admission.frame, store: store, traceLogger: InMemoryTraceLogger()),
                utterance
            ) { error in
                XCTAssertEqual(
                    error as? ToolExecutionError,
                    .semanticInvalid("unsupported_precision"),
                    utterance
                )
            }
            XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, beforeTemp, utterance)
            XCTAssertEqual(store.currentRevision, beforeRev, utterance)
        }
    }

    func testIRBridge_recoversSourceUnitFromRawArguments_whenIRValueOmitsUnit() throws {
        let ir = ToolContractIR(
            sourceToolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: ["direction": "主驾"],
            value: ContractValue(direct: "68", type: "SPOT", sourceUnit: nil)
        )
        let frame = try ToolContractIRFrameBridge.frame(
            from: ir,
            traceID: "trace-f-unit",
            rawCall: C6ToolCall(
                name: "adjust_ac_temperature_to_number",
                arguments: [
                    "temperature": "68",
                    "value.sourceUnit": "fahrenheit",
                ]
            ),
            projectedSlotKeys: ["direction"]
        )
        XCTAssertEqual(frame.value.sourceUnit, .fahrenheit)
        XCTAssertEqual(frame.value.direct, "68")
        XCTAssertEqual(frame.slots["direction"], "主驾")
    }

    func testIRBridge_recoversSourceUnitFromSlot_whenIRValueOmitsUnit() throws {
        let ir = ToolContractIR(
            sourceToolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: ["value.sourceUnit": "fahrenheit"],
            value: ContractValue(direct: "64.4", type: "SPOT")
        )
        let frame = try ToolContractIRFrameBridge.frame(
            from: ir,
            traceID: "trace-f-slot",
            rawCall: C6ToolCall(name: "adjust_ac_temperature_to_number", arguments: [:])
        )
        XCTAssertEqual(frame.value.sourceUnit, .fahrenheit)
        XCTAssertEqual(frame.value.direct, "64.4")
        // Unit lives on ContractValue only — not a silent dual slot.
        XCTAssertNil(frame.slots["value.sourceUnit"])
    }

    func testIRBridge_conflictsOnMismatchedSourceUnit_failClosed() {
        let ir = ToolContractIR(
            sourceToolName: "adjust_ac_temperature_to_number",
            device: "ac_temperature",
            actionPrimitive: "adjust_to_number",
            slots: ["value.sourceUnit": "celsius"],
            value: ContractValue(direct: "68", type: "SPOT", sourceUnit: .fahrenheit)
        )
        XCTAssertThrowsError(
            try ToolContractIRFrameBridge.frame(
                from: ir,
                traceID: "trace-conflict",
                rawCall: C6ToolCall(name: "adjust_ac_temperature_to_number", arguments: [:])
            )
        )
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
