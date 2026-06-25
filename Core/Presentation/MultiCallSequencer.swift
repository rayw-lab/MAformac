import Foundation
import Observation

/// 多意图错峰浮现时间表（4c，AD-4/AD-8.5/AD-12 §四 纯逻辑，可测）。
/// 跨族多意图（如「打开空调和座椅加热」）→ 多族卡【依次】高亮浮现（220ms stagger），
/// 序列化非并发（`MAX_CONCURRENT_HIGHLIGHTS=1`），不同时炸（撞「稳>炸」北极星 + D8.5）。
enum StaggerSchedule {
    static let delayMs = 220
    static let maxConcurrentHighlights = 1

    /// 错峰浮现时间表：第 i 族 delay = i × 220ms（单点串行，序列化非并发）。
    static func schedule(_ families: [FamilyCardID]) -> [(family: FamilyCardID, delayMs: Int)] {
        families.enumerated().map { ($0.element, $0.offset * delayMs) }
    }

    /// 总浮现时长（末族 delay；编排完成判定）。
    static func totalDurationMs(_ count: Int) -> Int {
        count > 1 ? (count - 1) * delayMs : 0
    }
}

/// 多意图错峰浮现编排器（4c runtime，AD-4 单点聚焦同源）。
/// 跨族多意图依次 append 到 `surfacedFamilies`（220ms stagger），view 据此渐次点亮高亮。
@Observable
@MainActor
final class MultiCallSequencer {
    /// 已错峰浮现的族（按 stagger 依次 append；view 用于渐次高亮，单点串行非同时炸）。
    private(set) var surfacedFamilies: [FamilyCardID] = []

    /// 多族错峰浮现（220ms stagger 依次 append，序列化非并发）。
    /// 单点串行 schedule（AD-12 §四）：一族浮现 → 等 220ms → 下一族，不并发。
    func surface(_ families: [FamilyCardID]) async {
        surfacedFamilies = []
        for (index, family) in families.enumerated() {
            if index > 0 {
                try? await Task.sleep(for: .milliseconds(StaggerSchedule.delayMs))
            }
            surfacedFamilies.append(family)
        }
    }

    func reset() {
        surfacedFamilies = []
    }
}
