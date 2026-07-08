import XCTest
@testable import MAformacCore

/// D1a T7c —— 招牌① 能量线 runtime 事件缝单测（B①：stub 事件注入点，T5 未 merge 留缝）。
final class RuntimeReadbackSignalTests: XCTestCase {

    func testFiresOnlyWithTarget() {
        // 有目标卡 → 触发能量线
        let withTarget = RuntimeReadbackSignal.stub(readbackID: "rb-1", target: "ac")
        XCTAssertTrue(RuntimeReadbackSignalRouter.shouldFireEnergyLine(withTarget))
        XCTAssertEqual(RuntimeReadbackSignalRouter.targetFamily(withTarget), "ac")
    }

    func testNoFireWhenNilOrEmptyTarget() {
        XCTAssertFalse(RuntimeReadbackSignalRouter.shouldFireEnergyLine(nil))
        XCTAssertNil(RuntimeReadbackSignalRouter.targetFamily(nil))
        let noTarget = RuntimeReadbackSignal.stub(readbackID: "rb-2", target: "")
        XCTAssertFalse(RuntimeReadbackSignalRouter.shouldFireEnergyLine(noTarget), "无目标不触发能量线")
        XCTAssertNil(RuntimeReadbackSignalRouter.targetFamily(noTarget))
    }

    func testStubCarriesReadbackID() {
        let s = RuntimeReadbackSignal.stub(readbackID: "rb-42", target: "seat")
        XCTAssertEqual(s.readbackID, "rb-42")   // 对齐 T5 readbackID 语义
        XCTAssertEqual(s.targetFamilyID, "seat")
    }
}
