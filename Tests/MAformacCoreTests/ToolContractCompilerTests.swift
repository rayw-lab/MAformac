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
