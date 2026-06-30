import XCTest
@testable import MAformacCore

/// `MultiCallSequencer` / `StaggerSchedule` — 多意图错峰浮现（4c，AD-4 220ms + MAX=1 + D8.5 不同时炸）。
final class MultiCallSequencerTests: XCTestCase {
    // 220ms stagger schedule：第 i 族 delay = i×220（单点串行）
    func testStaggerScheduleDelays() {
        let sched = StaggerSchedule.schedule([.ac, .seat, .window])
        XCTAssertEqual(sched.map(\.delayMs), [0, 220, 440], "220ms stagger 单点串行")
        XCTAssertEqual(sched.map(\.family), [.ac, .seat, .window], "顺序保持")
    }

    func testTotalDuration() {
        XCTAssertEqual(StaggerSchedule.totalDurationMs(4), 660)  // (4-1)*220
        XCTAssertEqual(StaggerSchedule.totalDurationMs(1), 0)
        XCTAssertEqual(StaggerSchedule.totalDurationMs(0), 0)
    }

    // 🔴 D8.5 序列化非并发：MAX_CONCURRENT_HIGHLIGHTS=1（不同时炸，撞「稳>炸」北极星）
    func testMaxConcurrentHighlightsIsOne() {
        XCTAssertEqual(StaggerSchedule.maxConcurrentHighlights, 1)
    }

    // sequencer 错峰浮现后全部依次 surface（顺序保持）
    @MainActor
    func testSequencerSurfacesAllInOrder() async {
        let seq = MultiCallSequencer()
        await seq.surface([.ac, .seat, .window])
        XCTAssertEqual(seq.surfacedFamilies, [.ac, .seat, .window])
    }

    @MainActor
    func testSequencerResetClears() async {
        let seq = MultiCallSequencer()
        await seq.surface([.ac])
        seq.reset()
        XCTAssertTrue(seq.surfacedFamilies.isEmpty)
    }
}
