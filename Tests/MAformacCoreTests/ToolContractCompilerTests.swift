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

    // MARK: - helpers

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
