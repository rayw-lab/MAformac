import XCTest
@testable import MAformacCore

final class C3ContractLookupTests: XCTestCase {
    func testSemanticContractLookupFindsC1RowsAndClarifyTags() throws {
        let lookup = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))

        let ac = try XCTUnwrap(lookup.first(device: "ac_temperature", actionPrimitive: "increase_by_exp"))
        XCTAssertEqual(ac.clarifyTag, "implicit")
        XCTAssertEqual(ac.executionRangeRef, "ac.temp_setpoint")

        let window = try XCTUnwrap(lookup.first(device: "window", actionPrimitive: "by_percent"))
        XCTAssertEqual(window.executionRangeRef, "window.position")

        XCTAssertNotNil(lookup.first(device: "screen_brightness", actionPrimitive: "increase_by_exp"))
        XCTAssertNotNil(lookup.first(device: "atmosphere_lamp_brightness", actionPrimitive: "increase_by_exp"))
    }

    func testSemanticContractLookupKeepsC1RiskOutOfDemoGuard() throws {
        let lookup = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))

        XCTAssertEqual(lookup.riskValues, [""])
    }

    func testStateCellLookupReadsExecutionRangeExpStepScopeAndReadback() throws {
        let lookup = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))

        let acTemp = try XCTUnwrap(lookup.cell(id: "ac.temp_setpoint"))
        XCTAssertEqual(acTemp.executionRange, ExecutionRange(min: 18, max: 32, step: 1))
        XCTAssertEqual(acTemp.expStepLittle, 2)
        XCTAssertTrue(acTemp.scope.contains("主驾"))
        XCTAssertEqual(acTemp.readbackTemplate, "{温区}空调温度{值}度")

        let window = try XCTUnwrap(lookup.cell(id: "window.position"))
        XCTAssertEqual(window.executionRange, ExecutionRange(min: 0, max: 100, step: 1))
        XCTAssertEqual(window.expStepLittle, 20)
        XCTAssertTrue(window.scope.contains("全车"))

        XCTAssertEqual(try XCTUnwrap(lookup.cell(id: "screen.brightness")).expStepLittle, 10)
        XCTAssertEqual(try XCTUnwrap(lookup.cell(id: "ambient.brightness")).expStepLittle, 10)
    }

    func testRiskPolicyLookupUsesIndependentForbiddenRuleWhenC1RiskIsEmpty() throws {
        let semantic = try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl"))
        let risk = try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml"))

        XCTAssertEqual(semantic.riskValues, [""])
        let decision = risk.evaluate(device: "car_door", stateValues: ["vehicle.speed": "12"])
        XCTAssertEqual(decision, .refuse(reason: "行驶中为了安全暂时不能开门, 停稳后我再帮您"))
    }

    func testL1AllowlistLookupClosesReviewedDevicesToC2Cells() throws {
        let allowlist = try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))

        let ac = try XCTUnwrap(allowlist.entry(device: "ac_temperature"))
        XCTAssertTrue(ac.primitives.contains("increase_by_exp"))
        XCTAssertEqual(ac.executionRangeCell, "ac.temp_setpoint")
        XCTAssertNotNil(stateCells.cell(id: ac.executionRangeCell))

        let window = try XCTUnwrap(allowlist.entry(device: "window"))
        XCTAssertTrue(window.primitives.contains("power_on"))
        XCTAssertEqual(window.executionRangeCell, "window.position")
        XCTAssertNotNil(stateCells.cell(id: window.executionRangeCell))
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
