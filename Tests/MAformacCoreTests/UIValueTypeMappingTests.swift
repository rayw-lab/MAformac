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
        XCTAssertEqual(UIValueTypeMapper.mapping["window.lock"], .toggle, "window.lock 二值锁应显式映射 toggle")
    }

    func testAmbientPowerIsToggle() {
        XCTAssertEqual(UIValueTypeMapper.mapping["ambient.power"], .toggle, "ambient.power 二值开关应显式映射 toggle")
    }

    func testAmbientPowerDisplayTitle() {
        let catalog = StateCellPresentationCatalog.load()
        XCTAssertEqual(catalog.displayTitle(for: "ambient.power"), "氛围灯开关")
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

        XCTAssertFalse(yaml.contains("ui_value_type"),
        "ui_value_type must remain consumer-side per ui-presentation spec R2 / AD-2")
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

    func testInteractiveBadgeOptionsDeriveFromContractValues() throws {
        let yaml = try loadStateCellsYAML()
        let lookup = try StateCellContractLookup(yaml: yaml)
        let catalog = StateCellPresentationCatalog.load()

        for base in BadgeOptionMapper.interactiveModeBases.sorted() {
            XCTAssertEqual(
                BadgeOptionMapper.options(forBase: base, catalog: catalog),
                lookup.cell(id: base)?.values ?? [],
                "\(base) 的展开选项必须从 state-cells.yaml values 派生，不能手写第二份列表"
            )
        }

        XCTAssertEqual(
            BadgeOptionMapper.options(forBase: "ambient.color", catalog: catalog),
            AmbientBurstColorMapper.canonicalColorOptions
        )
        XCTAssertEqual(
            BadgeOptionMapper.options(forBase: "seat.massage_mode", catalog: catalog),
            ["波浪模式", "蛇形模式", "蝶形模式", "舒缓模式", "松弛模式", "全身伸展模式"]
        )
        XCTAssertFalse(BadgeOptionMapper.options(forBase: "seat.massage_mode", catalog: catalog).contains("活力模式"))
        XCTAssertFalse(BadgeOptionMapper.options(forBase: "seat.massage_mode", catalog: catalog).contains("关闭"))
    }

    func testReadOnlyAndMotionBadgesDoNotExposeFakeOptions() {
        let catalog = StateCellPresentationCatalog.load()
        for base in ["door.car_door", "window.motion", "sunroof.motion", "vehicle.speed", "vehicle.gear"] {
            XCTAssertTrue(
                BadgeOptionMapper.options(forBase: base, catalog: catalog).isEmpty,
                "\(base) 是过程态或只读态，不能渲染成可点但无真实语义的选择器"
            )
        }
    }

    func testInteractiveModeBadgesRenderWithModeStyle() {
        XCTAssertEqual(VehicleCardDisplay.badgeRenderStyle(forBase: "volume.mode", value: "现代"), .mode("现代"))
        XCTAssertEqual(VehicleCardDisplay.badgeRenderStyle(forBase: "wiper.mode", value: "自动模式"), .mode("自动模式"))
        XCTAssertEqual(VehicleCardDisplay.badgeRenderStyle(forBase: "fragrance.mode", value: "白茶模式"), .mode("白茶模式"))
        XCTAssertEqual(VehicleCardDisplay.badgeRenderStyle(forBase: "door.car_door", value: "opening"), .plain)
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
