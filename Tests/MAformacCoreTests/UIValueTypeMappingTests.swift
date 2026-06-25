import XCTest
@testable import MAformacCore

/// `UIValueTypeMapper.mapping` contract-driven 闭合测试（gptpro 跨厂商审第 2 点）。
/// 🔴 `derivation-layer-discipline` 铁律1：`default` 禁吞错 → 遍历契约全 base 断言每个都显式登记。
final class UIValueTypeMappingTests: XCTestCase {

    // 🔴 gptpro 第2点修复验证：window.lock(enum locked/unlocked 二值锁) 原 default 吞成 badge，实为 toggle
    func testWindowLockIsToggleNotBadge() {
        XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: "window.lock"), .toggle,
                       "window.lock 是二值锁(locked/unlocked)，应 toggle，非被 default 吞成 badge")
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
}
