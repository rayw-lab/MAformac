import XCTest
@testable import MAformacCore

/// `ValueRangeMapper` — 控件值域从 contract `execution_range` 读（真 SSOT，4b dial/percent/stepper 用）。
/// 🔴 derivation 铁律2：值域无第二份硬编码，A2 改 yaml execution_range → range 自动跟随。
final class ValueRangeMapperTests: XCTestCase {
    private let catalog = StateCellPresentationCatalog.load()

    // range 从 contract execution_range 读（一手值：温度 18-32 / 风量 1-10 / 座椅 0-3 / 开度 0-100 / 雨刮 1-4）
    func testRangeFromContractExecutionRange() {
        XCTAssertEqual(ValueRangeMapper.range(forBase: "ac.temp_setpoint", catalog: catalog), 18.0...32.0)
        XCTAssertEqual(ValueRangeMapper.range(forBase: "ac.fan_speed", catalog: catalog), 1.0...10.0)
        XCTAssertEqual(ValueRangeMapper.range(forBase: "seat.heat_level", catalog: catalog), 0.0...3.0)
        XCTAssertEqual(ValueRangeMapper.range(forBase: "window.position", catalog: catalog), 0.0...100.0)
        XCTAssertEqual(ValueRangeMapper.range(forBase: "sunroof.position", catalog: catalog), 0.0...100.0)
        XCTAssertEqual(ValueRangeMapper.range(forBase: "wiper.speed", catalog: catalog), 1.0...4.0)
    }

    // enum/只读 base 无 execution_range → nil（toggle/badge 不需范围）
    func testNoRangeForEnumBases() {
        XCTAssertNil(ValueRangeMapper.range(forBase: "ac.power", catalog: catalog))
        XCTAssertNil(ValueRangeMapper.range(forBase: "ambient.color", catalog: catalog))
        XCTAssertNil(ValueRangeMapper.range(forBase: "seat.massage_mode", catalog: catalog))
    }

    // stepCount = 段数 = 上界 max（🔴 codex P1-2 修：非零起始 range 不少格；fan 1-10→10 段 / seat 0-3→3 段 / wiper 1-4→4 段）
    func testStepCountFromContract() {
        XCTAssertEqual(ValueRangeMapper.stepCount(forBase: "seat.heat_level", catalog: catalog), 3)   // 0-3 → 3 段
        XCTAssertEqual(ValueRangeMapper.stepCount(forBase: "ac.fan_speed", catalog: catalog), 10)      // 1-10 → 10 段（原误算 9，「1挡」亮0格）
        XCTAssertEqual(ValueRangeMapper.stepCount(forBase: "wiper.speed", catalog: catalog), 4)        // 1-4 → 4 段（非零起始验证）
    }

    // clamp 越界钳制（防 Gauge value 越界异常渲染）
    func testClampIntoRange() {
        XCTAssertEqual(ValueRangeMapper.clamp(40, forBase: "ac.temp_setpoint", catalog: catalog), 32.0)
        XCTAssertEqual(ValueRangeMapper.clamp(10, forBase: "ac.temp_setpoint", catalog: catalog), 18.0)
        XCTAssertEqual(ValueRangeMapper.clamp(24, forBase: "ac.temp_setpoint", catalog: catalog), 24.0)
        XCTAssertEqual(ValueRangeMapper.clamp(5, forBase: "ac.power", catalog: catalog), 5.0, "无 range 的 base 原样返回")
    }

    func testNextSteppedValueClampsToExecutionRange() {
        XCTAssertEqual(ValueRangeMapper.steppedValue(32, forBase: "ac.temp_setpoint", direction: .increment, catalog: catalog), "32")
        XCTAssertEqual(ValueRangeMapper.steppedValue(18, forBase: "ac.temp_setpoint", direction: .decrement, catalog: catalog), "18")
        XCTAssertEqual(ValueRangeMapper.steppedValue(24, forBase: "ac.temp_setpoint", direction: .increment, catalog: catalog), "25")
        XCTAssertEqual(ValueRangeMapper.steppedValue(2, forBase: "seat.heat_level", direction: .decrement, catalog: catalog), "1")
    }

    func testValueStringSnapsToContractStepBeforeFormatting() {
        XCTAssertEqual(ValueRangeMapper.valueString(76.6, forBase: "window.position", catalog: catalog), "77")
        XCTAssertEqual(ValueRangeMapper.valueString(32.4, forBase: "ac.temp_setpoint", catalog: catalog), "32")
    }

    func testCircularGestureProgressMatchesClockwiseRingSemantics() {
        let current = 0.76
        let redZone = CircularControlGestureMapper.progress(x: 20, y: 20, size: 56)
        let yellowZone = CircularControlGestureMapper.progress(x: 28, y: 44, size: 56)
        XCTAssertNotNil(redZone)
        XCTAssertNotNil(yellowZone)
        XCTAssertGreaterThan(redZone!, current, "当前 76% 时，左上环区应被判为顺时针增大方向")
        XCTAssertLessThan(yellowZone!, current, "当前 76% 时，下方环区应被判为逆时针减小方向")
    }

    func testNextToggleAndBadgeValuesCycleWithoutViewRangeLogic() {
        XCTAssertEqual(ValueRangeMapper.toggledValue(isOn: true), "off")
        XCTAssertEqual(ValueRangeMapper.toggledValue(isOn: false), "on")
        XCTAssertEqual(ValueRangeMapper.nextBadgeValue(current: "白", options: ["白", "浅蓝紫", "冰蓝"]), "浅蓝紫")
        XCTAssertEqual(ValueRangeMapper.nextBadgeValue(current: "冰蓝", options: ["白", "浅蓝紫", "冰蓝"]), "白")
        XCTAssertEqual(ValueRangeMapper.nextBadgeValue(current: "未知", options: ["白", "浅蓝紫"]), "白")
    }

    func testToggleValueUsesContractEnumValues() {
        XCTAssertEqual(ValueRangeMapper.toggledValue(current: "on", forBase: "ac.power", catalog: catalog), "off")
        XCTAssertEqual(ValueRangeMapper.toggledValue(current: "off", forBase: "ac.power", catalog: catalog), "on")
        XCTAssertEqual(ValueRangeMapper.toggledValue(current: "locked", forBase: "window.lock", catalog: catalog), "unlocked")
        XCTAssertEqual(ValueRangeMapper.toggledValue(current: "unlocked", forBase: "door.child_lock", catalog: catalog), "locked")
        XCTAssertEqual(ValueRangeMapper.toggledValue(current: "muted", forBase: "volume.mute", catalog: catalog), "unmuted")
        XCTAssertEqual(ValueRangeMapper.toggledValue(current: "unmuted", forBase: "volume.mute", catalog: catalog), "muted")
    }

    // 🔴 契约 SSOT 加载守卫：catalog 必加载成功（否则 range 全 nil 假绿）
    func testCatalogLoadedWithExecutionRanges() {
        XCTAssertNotNil(ValueRangeMapper.range(forBase: "ac.temp_setpoint", catalog: catalog),
                        "catalog 未加载 execution_range——查 state-cells.yaml 解析")
    }
}
