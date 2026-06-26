import XCTest
@testable import MAformacCore

/// `UIValueTypeMapper.mapping` contract-driven 闭合测试（gptpro 跨厂商审第 2 点）。
/// 🔴 `derivation-layer-discipline` 铁律1：`default` 禁吞错 → 遍历契约全 base 断言每个都显式登记。
final class UIValueTypeMappingTests: XCTestCase {

    func testUIValueTypeRawValuesAreStable() {
        XCTAssertEqual(
            UIValueType.allCases.map(\.rawValue),
            ["dial", "toggle", "stepper", "percent", "badge"]
        )
    }

    // 🔴 gptpro 第2点修复验证：window.lock(enum locked/unlocked 二值锁) 原 default 吞成 badge，实为 toggle
    func testWindowLockIsToggleNotBadge() {
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "window.lock"), .toggle,
                       "window.lock 是二值锁(locked/unlocked)，应 toggle，非被 default 吞成 badge")
    }

    func testUnknownBaseDoesNotSilentlyFallbackToBadge() {
        XCTAssertNil(
            UIValueTypeMapper.mappedUIValueType(forBase: "unknown.future_base"),
            "未知 base 必须 fail-closed；不能静默降级为 badge"
        )
    }

    // 🔴 contract-driven 闭合：state-cells.yaml 全 base 必显式登记（无静默 default 吞错）
    func testEveryContractBaseIsExplicitlyMapped() {
        let bases = StateCellPresentationCatalog.load().knownBases
        XCTAssertGreaterThanOrEqual(bases.count, 30,
                                    "catalog 未加载或 base 不全(\(bases.count))，contract 闭合测试无法执行——查 state-cells.yaml 加载")
        for base in bases {
            XCTAssertTrue(UIValueTypeMapper.isMapped(base),
                          "契约 base 「\(base)」未在 UIValueTypeMapper.mapping 显式登记（会落 default→assertionFailure，4b 控件追查灾难）")
        }
    }

    // 反向防漂移：mapping 不得列契约不存在的幽灵 base（写错 base 名会被静默忽略）
    func testNoOrphanMappingBeyondContract() {
        let bases = StateCellPresentationCatalog.load().knownBases
        guard bases.count >= 30 else { return XCTFail("catalog 未加载，跳过 orphan 检查") }
        for key in UIValueTypeMapper.mapping.keys {
            XCTAssertTrue(bases.contains(key),
                          "mapping 登记了契约不存在的 base 「\(key)」（base 名写错？已被 A2 移除？）")
        }
    }

    func testStateCellUIValueTypeProjectionCoversEveryKnownBase() {
        let catalog = StateCellPresentationCatalog.load()
        let projections = StateCellUIValueTypeProjector.projections(catalog: catalog)

        XCTAssertGreaterThanOrEqual(projections.count, 30)
        XCTAssertEqual(projections.map(\.base), catalog.knownBases.sorted())
        XCTAssertTrue(projections.allSatisfy { !$0.uiValueTypeFieldValue.isEmpty })
    }

    func testStateCellsYAMLDoesNotCarryProducerUIValueTypeField() throws {
        let yaml = try loadStateCellsYAML()

        XCTAssertFalse(
            yaml.contains("ui_value_type"),
            "ui_value_type must remain consumer-side per ui-presentation spec R2 / AD-2"
        )
    }

    // 各控件类型代表 base 映射正确（穷尽分类抽样）
    func testRepresentativeBasesMapCorrectly() {
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "ac.temp_setpoint"), .dial)
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "window.position"), .percent)
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "ac.fan_speed"), .stepper)
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "ac.power"), .toggle)
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "ambient.color"), .badge)
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "seat.massage_mode"), .badge, "6 模式枚举→badge")
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "door.car_door"), .badge, "5 态运动枚举→badge 非 toggle")
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "vehicle.gear"), .badge, "只读仪表→badge")
    }

    // 🔴 codex P2-2 + gptpro 第6点：mapping 与 contract `StateCellDefinition.type/unit/values` 语义对齐（机械化防第二份 SSOT 漂移）。
    // 期望 UIValueType 从 contract 字段推导（int+celsius→dial / int+percent→percent / int+gear→stepper / enum 2值→toggle / enum 多值→badge / int 其它单位→badge 只读）。
    func testMappingSemanticallyAlignedWithContract() throws {
        let lookup = try StateCellContractLookup(yaml: loadStateCellsYAML())
        XCTAssertGreaterThanOrEqual(lookup.cells.count, 30, "contract 未加载，语义对齐测试无法执行")
        for def in lookup.cells {
            guard let expected = expectedUIValueType(for: def) else { continue }
            XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: def.id), expected,
                           "base \(def.id)（type=\(def.type) unit=\(def.unit ?? "-") values=\(def.values.count)）映射应是 \(expected)，与 contract 语义不符=第二份 SSOT 漂移")
        }
    }

    private func expectedUIValueType(for def: StateCellDefinition) -> UIValueType? {
        switch def.type {
        case "int":
            switch def.unit {
            case "celsius": return .dial
            case "percent": return .percent
            case "gear": return .stepper
            default: return .badge   // kmh 等只读仪表
            }
        case "enum":
            return def.values.count == 2 ? .toggle : .badge
        default:
            return nil
        }
    }

    private func loadStateCellsYAML() throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("contracts/state-cells.yaml")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
