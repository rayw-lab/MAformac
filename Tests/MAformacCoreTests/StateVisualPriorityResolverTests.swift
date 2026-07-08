import XCTest
@testable import MAformacCore

/// D1a T2 —— 状态视觉优先级 resolver 单测（D0G-005）。
final class StateVisualPriorityResolverTests: XCTestCase {

    /// D0G-005 commander 终序：safety > crash > clarify > changing > selected/hover > unsupported > satisfied > normal。
    func testAuthoritativeChainOrdering() {
        let R = StateVisualPriorityResolver.self
        XCTAssertTrue(R.dominates(.unsafe, over: .unknown), "safety > crash")
        XCTAssertTrue(R.dominates(.unknown, over: .blocked_with_alternative), "crash > clarify")
        XCTAssertTrue(R.dominates(.blocked_with_alternative, over: .changing), "clarify > changing（停留等人响应）")
        XCTAssertTrue(R.dominates(.changing, over: .blocked_hard), "changing > unsupported")
        XCTAssertTrue(R.dominates(.blocked_hard, over: .satisfied), "unsupported > satisfied")
        XCTAssertTrue(R.dominates(.satisfied, over: .normal), "satisfied > normal")
        // safety 永远最高，不被 changing 覆盖（DGA-075）
        XCTAssertTrue(R.dominates(.unsafe, over: .changing))
        XCTAssertTrue(R.dominates(.unsafe, over: .satisfied))
    }

    func testClarifyAboveChangingUnsupportedBelowHover() {
        let R = StateVisualPriorityResolver.self
        // clarify 停留等人响应 → 排 changing 上
        XCTAssertTrue(R.dominates(.blocked_with_alternative, over: .changing))
        // unsupported 静默终态 → 排 selected/hover 下、satisfied 上
        XCTAssertGreaterThan(R.priority(.blocked_hard), R.interactionSelectedHoverPriority)
        XCTAssertLessThan(R.priority(.blocked_hard), R.priority(.satisfied))
    }

    func testSelectedHoverBetweenChangingAndUnsupported() {
        // 交互层介于 changing(3) 与 unsupported(5)
        XCTAssertGreaterThan(StateVisualPriorityResolver.interactionSelectedHoverPriority,
                             StateVisualPriorityResolver.priority(.changing))
        XCTAssertLessThan(StateVisualPriorityResolver.interactionSelectedHoverPriority,
                          StateVisualPriorityResolver.priority(.blocked_hard))
    }

    func testDominantAmong() {
        XCTAssertEqual(StateVisualPriorityResolver.dominant(among: [.normal, .satisfied, .unsafe, .changing]), .unsafe)
        XCTAssertEqual(StateVisualPriorityResolver.dominant(among: [.normal, .satisfied]), .satisfied)
        XCTAssertNil(StateVisualPriorityResolver.dominant(among: []))
    }

    /// 清偿二值压缩债：featured 选主导态而非「第一个非 normal」。
    func testFeaturedIndexPicksDominantNotFirstNonNormal() {
        // 卡序：[satisfied, unsafe, changing] —— binary「首个非normal」会选 satisfied(idx0)；
        // 优先级 resolver 应选 unsafe(idx1)。
        let idx = StateVisualPriorityResolver.featuredIndex(states: [.satisfied, .unsafe, .changing])
        XCTAssertEqual(idx, 1, "featured 须选主导 unsafe，非首个非 normal")
    }

    func testFeaturedIndexSelectedHoverLifts() {
        // [satisfied, normal]，第 1 张(normal) 被 hover → 交互层(5) 优于 normal(7) 但不及 satisfied(6)?
        // satisfied(6) vs hover-lifted normal(min(7,5)=5) → hover 卡(idx1)优先级5 < satisfied 6 → 选 idx1
        let idx = StateVisualPriorityResolver.featuredIndex(states: [.satisfied, .normal],
                                                            selectedFlags: [false, true])
        XCTAssertEqual(idx, 1, "hover 卡抬到交互层，优于 satisfied")
        // 但 hover 不得覆盖 safety
        let idx2 = StateVisualPriorityResolver.featuredIndex(states: [.unsafe, .normal],
                                                             selectedFlags: [false, true])
        XCTAssertEqual(idx2, 0, "hover 不得覆盖 safety")
    }

    func testAllStatesDistinctPriority() {
        let all = DemoVisualState.allCases.map { StateVisualPriorityResolver.priority($0) }
        XCTAssertEqual(Set(all).count, all.count, "7 态优先级两两不同")
    }
}
