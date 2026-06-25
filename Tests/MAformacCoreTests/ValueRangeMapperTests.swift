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

    // 🔴 契约 SSOT 加载守卫：catalog 必加载成功（否则 range 全 nil 假绿）
    func testCatalogLoadedWithExecutionRanges() {
        XCTAssertNotNil(ValueRangeMapper.range(forBase: "ac.temp_setpoint", catalog: catalog),
                        "catalog 未加载 execution_range——查 state-cells.yaml 解析")
    }
}
