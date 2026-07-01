import XCTest
@testable import MAformacCore

/// S2 cut1: model-visible surface 迁 D-domain 具名工具
/// （compiler 消费 generated/D_domain.tools.demo.json catalog，删 6 硬编码 set_cabin_*，frame strangler 保留）。
final class ToolContractCompilerTests: XCTestCase {

    func testLoadDDomainCatalogProduces562Tools() throws {
        let catalog = try ToolContractCompiler.loadDDomainCatalog(repoRoot: repoRoot())
        XCTAssertEqual(catalog.count, 562, "D-domain demo catalog = 562 具名工具(intent-as-name)")
        let names = Set(catalog.map(\.function.name))
        // 真实座舱范式工具名（value 形态编码进名）
        XCTAssertTrue(names.contains("adjust_ac_temperature_to_number"))
        XCTAssertTrue(names.contains("open_ac"))
        // 每工具有完整 parameters schema（非空占位）
        XCTAssertTrue(catalog.allSatisfy { if case .object = $0.function.parameters { return true }; return false })
    }

    func testDDomainSurfaceConsumesCatalogNotHardcoded() throws {
        let catalog = try ToolContractCompiler.loadDDomainCatalog(repoRoot: repoRoot())
        let compiler = ToolContractCompiler(seeds: [], dDomainCatalog: catalog)
        let surfaceNames = toolNames(compiler.dDomainToolSchemas)
        XCTAssertEqual(surfaceNames.count, 562)
        // 旧 6 硬编码 set_cabin_*/query_cabin_comfort 已删，不在新 surface
        XCTAssertFalse(surfaceNames.contains("set_cabin_ac"), "旧 6 硬编码 surface 已删")
        XCTAssertFalse(surfaceNames.contains("query_cabin_comfort"))
        XCTAssertTrue(surfaceNames.contains("adjust_ac_temperature_to_number"))
    }

    func testFamilyAllowlistToolCountMatchesDDomainCatalog() throws {
        let catalog = try ToolContractCompiler.loadDDomainCatalog(repoRoot: repoRoot())
        let allowlistURL = repoRoot().appendingPathComponent("generated/family-device-allowlist.json")
        let allowlist = try JSONDecoder().decode(FamilyDeviceAllowlistMetaFixture.self, from: Data(contentsOf: allowlistURL))

        XCTAssertEqual(allowlist.meta.toolCount, catalog.count, "tool_count must be derived from D-domain catalog count, not demo_intents")
        XCTAssertTrue(allowlist.meta.toolCountDerivation.contains("ToolContractCompiler.loadDDomainCatalog"))
        XCTAssertTrue(allowlist.meta.toolCountDerivation.contains("not demo_intents reuse"))
    }

    func testRenderedToolsTextOnlyDDomainNoGenericFrame() throws {
        let catalog = try ToolContractCompiler.loadDDomainCatalog(repoRoot: repoRoot())
        let compiler = ToolContractCompiler(seeds: [], dDomainCatalog: catalog)
        let rendered = compiler.renderedToolsText
        // model-visible surface 只渲 D-domain，generic frame 显式移除（paradigm §1）
        XCTAssertFalse(rendered.contains("tool_call_frame"), "generic frame 从 model-visible surface 移除")
        XCTAssertTrue(rendered.contains("adjust_ac_temperature_to_number"))
    }

    func testEmptyCatalogProducesEmptySurface() {
        // 默认空 catalog（向后兼容）→ 空 D-domain surface（不再硬编码 6）
        let compiler = ToolContractCompiler(seeds: [])
        XCTAssertTrue(compiler.dDomainToolSchemas.isEmpty)
    }

    func testFrameSchemaKeptForStrangler() {
        // frameToolSchema 物理保留供 C5 训练 surface（strangler，S4 迁后删）
        let compiler = ToolContractCompiler(seeds: [])
        let frame = compiler.frameToolSchema
        XCTAssertEqual(frame.count, 1)
        XCTAssertEqual(toolNames(frame).first, "tool_call_frame")
    }

    // MARK: - cut2 Normalizer 消费 ir_map (562 D-domain 工具名→IR, 旧 surface strangler 保留)

    func testNormalizeDDomainSinglePrimitive() throws {
        let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
        XCTAssertEqual(irMap.count, 562, "ir_map = 562 D-domain 工具名→IR")
        let irs = ToolContractNormalizer.normalize(
            C6ToolCall(name: "adjust_ac_temperature_to_number", arguments: ["value": "24"]), irMap: irMap)
        XCTAssertEqual(irs.count, 1)
        XCTAssertEqual(irs.first?.device, "ac_temperature")
        XCTAssertEqual(irs.first?.actionPrimitive, "adjust_to_number")
        XCTAssertEqual(irs.first?.value.direct, "24")
        XCTAssertEqual(irs.first?.value.type, "SPOT")
    }

    func testNormalizeDDomainMultiPrimitiveDisambiguation() throws {
        let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
        // adjust_atmosphere_lamp_brightness_to_number: primitives [adjust_to_number, by_percent]
        let spot = ToolContractNormalizer.normalize(
            C6ToolCall(name: "adjust_atmosphere_lamp_brightness_to_number", arguments: ["value": "50"]), irMap: irMap)
        XCTAssertEqual(spot.first?.actionPrimitive, "adjust_to_number", "纯数字→SPOT/adjust_to_number")
        XCTAssertEqual(spot.first?.value.type, "SPOT")
        let pct = ToolContractNormalizer.normalize(
            C6ToolCall(name: "adjust_atmosphere_lamp_brightness_to_number", arguments: ["value": "50%"]), irMap: irMap)
        XCTAssertEqual(pct.first?.actionPrimitive, "by_percent", "含%→PERCENT/by_percent")
        XCTAssertEqual(pct.first?.value.type, "PERCENT")
    }

    func testNormalizeOldSurfaceStranglerKept() {
        // 旧 set_cabin_ac normalize 仍工作(strangler, 无 irMap 走 switch case)
        let irs = ToolContractNormalizer.normalize(C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"]))
        XCTAssertFalse(irs.isEmpty)
        XCTAssertEqual(irs.first?.device, "ac")
    }

    func testNormalizeUnknownToolReturnsEmpty() {
        // 未知工具名 default 返 [] (+ stderr logUnclassified, 不静默吞 claim-vs-reality 铁律1)
        let irs = ToolContractNormalizer.normalize(C6ToolCall(name: "nonexistent_tool_xyz"))
        XCTAssertTrue(irs.isEmpty)
    }

    // MARK: - cut3 StateApplier data-driven (cell-driven applyGeneric, parity 等价旧硬编码)

    func testStateApplierDataDrivenEndToEndDDomainTool() throws {
        let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        // 端到端 cut1→cut2→cut3: D-domain 工具名→normalize(irMap)→IR→data-driven apply→state delta
        let state = try ToolContractStateApplier.apply(
            toolCalls: [C6ToolCall(name: "adjust_ac_temperature_to_number", arguments: ["value": "24"])],
            to: [:], stateCells: stateCells, irMap: irMap)
        XCTAssertEqual(state["ac.temp_setpoint[主驾]"], "24")
        XCTAssertEqual(state["ac.power"], "on", "depends_on 联动(cell-driven): 调温度自动开空调")
    }

    func testStateApplierExpStepFromCellMetadata() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        // increase_by_exp 用 cell.exp_step.little(screen 10) + clamp executionRange, 非硬编码
        let state = try ToolContractStateApplier.apply(
            toolCalls: [C6ToolCall(name: "set_cabin_screen_brightness", arguments: ["delta": "brighter"])],
            to: ["screen.brightness[中控屏]": "70"], stateCells: stateCells)
        XCTAssertEqual(state["screen.brightness[中控屏]"], "80", "cell-driven expStep 10: 70+10")
    }

    func testStateApplierDefaultFromCellMetadata() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        // 无 pre-state, increase 用 cell.default 初值(fan default 1), 非硬编码 1
        let state = try ToolContractStateApplier.apply(
            toolCalls: [C6ToolCall(name: "set_cabin_fan", arguments: ["delta": "stronger"])],
            to: [:], stateCells: stateCells)
        XCTAssertEqual(state["ac.fan_speed[主驾]"], "2", "cell-driven default 1: 1+1")
    }

    func testStateApplierUsesC2DefaultScopeForOmittedWindow() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
        let preState: [String: String] = [
            "window.position[主驾]": "0",
            "window.position[副驾]": "0",
            "window.position[左后]": "0",
            "window.position[右后]": "0"
        ]

        let state = try ToolContractStateApplier.apply(
            toolCalls: [C6ToolCall(name: "open_window", arguments: [:])],
            to: preState,
            stateCells: stateCells,
            irMap: irMap
        )

        XCTAssertEqual(state["window.position[主驾]"], "100")
        XCTAssertEqual(state["window.position[副驾]"], "0")
        XCTAssertEqual(state["window.position[左后]"], "0")
        XCTAssertEqual(state["window.position[右后]"], "0")
    }

    func testStateApplierEvidenceIncludesDirectAndDependencyWrites() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        let result = try ToolContractStateApplier.applyWithEvidence(
            toolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["target_temperature": "24"])],
            to: ["ac.power": "off", "ac.temp_setpoint[主驾]": "22"],
            stateCells: stateCells
        )

        XCTAssertTrue(result.appliedWrites.contains {
            $0.stateKey == "ac.temp_setpoint[主驾]" &&
                $0.beforeValue == "22" &&
                $0.afterValue == "24" &&
                $0.writeKind == .direct
        })
        XCTAssertTrue(result.appliedWrites.contains {
            $0.stateKey == "ac.power" &&
                $0.beforeValue == "off" &&
                $0.afterValue == "on" &&
                $0.writeKind == .dependency
        })
    }

    func testStateApplierEvidenceIncludesEnumDirectWrites() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        let result = try ToolContractStateApplier.applyWithEvidence(
            toolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            to: ["ac.power": "off"],
            stateCells: stateCells
        )

        XCTAssertEqual(result.appliedWrites, [
            StateWrite(stateKey: "ac.power", beforeValue: "off", afterValue: "on", scopeOrigin: nil, writeKind: .direct)
        ])
    }

    func testStateApplierFansOutOnlyForExplicitCollectionAlias() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
        let preState: [String: String] = [
            "window.position[主驾]": "0",
            "window.position[副驾]": "0",
            "window.position[左后]": "0",
            "window.position[右后]": "0"
        ]

        let state = try ToolContractStateApplier.apply(
            toolCalls: [C6ToolCall(name: "open_window", arguments: ["position": "全车"])],
            to: preState,
            stateCells: stateCells,
            irMap: irMap
        )

        XCTAssertEqual(state["window.position[主驾]"], "100")
        XCTAssertEqual(state["window.position[副驾]"], "100")
        XCTAssertEqual(state["window.position[左后]"], "100")
        XCTAssertEqual(state["window.position[右后]"], "100")
    }

    func testStateApplierRejectsOutOfScopeWindowWithoutBaseCellFallback() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
        let preState: [String: String] = [
            "window.position[主驾]": "0",
            "window.position[副驾]": "0"
        ]

        XCTAssertThrowsError(
            try ToolContractStateApplier.apply(
                toolCalls: [C6ToolCall(name: "open_window", arguments: ["position": "后排"])],
                to: preState,
                stateCells: stateCells,
                irMap: irMap
            )
        ) { error in
            guard case ToolContractStateApplyError.scopeResolutionFailed(let cellID, _) = error else {
                return XCTFail("expected scopeResolutionFailed, got \(error)")
            }
            XCTAssertEqual(cellID, "window.position")
        }
    }

    func testStateApplierUnmappedDeviceNoWrite() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        XCTAssertThrowsError(
            try ToolContractStateApplier.apply(
                toolCalls: [C6ToolCall(name: "tool_call_frame", arguments: ["device": "seat_heat", "action_primitive": "power_on"])],
                to: ["x": "y"],
                stateCells: stateCells
            )
        ) { error in
            XCTAssertEqual(error as? ToolContractStateApplyError, .unmappedDevice("seat_heat"))
        }
    }

    // MARK: - S3 deviceCellMap 扩 6 族 (每 value cellID 在 state-cells 存在 + 6 族不落 unmapped)

    func testDeviceCellMapAllValuesExistInStateCells() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        for (device, cellID) in ToolContractStateApplier.deviceCellMap {
            XCTAssertNotNil(stateCells.cell(id: cellID), "deviceCellMap[\(device)]=\(cellID) 不在 state-cells(会 logUnmapped 不写 state)")
        }
        XCTAssertEqual(ToolContractStateApplier.deviceCellMap.count, 24, "S2 7 族 + S3 17 = 24 device→cell 单源映射")
    }

    func testS3FamilyDeviceWritesStateNotUnmapped() throws {
        let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
        // seat_heat_temperature adjust_to_number → seat.heat_level[主驾] (S3 族 cell-driven 写 state, 非 unmapped)
        let state = try ToolContractStateApplier.apply(
            toolCalls: [C6ToolCall(name: "tool_call_frame", arguments: ["device": "seat_heat_temperature", "action_primitive": "adjust_to_number", "value.direct": "2"])],
            to: [:], stateCells: stateCells)
        XCTAssertEqual(state["seat.heat_level[主驾]"], "2", "seat 族 deviceCellMap+cell-driven 写 state")
    }

    func testC3ExecutionCellReusesDeviceCellMapSingleSource() throws {
        // C3 executionCellID 复用 deviceCellMap 单源, fix 旧 switch 缺 ac_windspeed
        XCTAssertEqual(ToolContractStateApplier.deviceCellMap["ac_windspeed"], "ac.fan_speed")
        XCTAssertEqual(ToolContractStateApplier.deviceCellMap["seat_heat_temperature"], "seat.heat_level")
    }

    // MARK: - helpers

    private func stateCellsYAML() throws -> String {
        try String(contentsOf: repoRoot().appendingPathComponent("contracts/state-cells.yaml"), encoding: .utf8)
    }

    private func toolNames(_ schemas: [[String: JSONValue]]) -> [String] {
        schemas.compactMap { schema in
            guard case let .object(function)? = schema["function"],
                  case let .string(name)? = function["name"] else { return nil }
            return name
        }
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

private struct FamilyDeviceAllowlistMetaFixture: Decodable {
    var meta: Meta

    struct Meta: Decodable {
        var toolCount: Int
        var toolCountDerivation: String

        enum CodingKeys: String, CodingKey {
            case toolCount = "tool_count"
            case toolCountDerivation = "tool_count_derivation"
        }
    }
}
