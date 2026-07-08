import Foundation

/// 状态视觉优先级 resolver（D0G-005，commander 裁定终序 2026-07-08，记 receipt）。
///
/// **终序（RATIFIED）**：
/// `safety/unsafe > crash/unknown > clarify > changing > selected/hover > unsupported > satisfied/normal`。
/// 多状态冲突时决定「哪个态主导卡片外观 / 哪张卡被 featured」，避免状态机不确定。
///
/// 🔴 commander 裁定要点（覆盖初版把 clarify/unsupported 并列 attention 层的口径）：
/// - `blocked_with_alternative`(clarify)：**停留等人响应**，排 `changing` **之上**（需人介入 > 自动执行中）。
/// - `blocked_hard`(unsupported)：**静默终态**，排 `selected/hover` **之下**、`satisfied` 之上。
/// selected/hover 是**交互叠加层**（非 `DemoVisualState`），介于 changing 与 unsupported 之间，
/// 由 `interactionSelectedHoverPriority` 承载。
enum StateVisualPriorityResolver {

    /// 状态优先级（**数值越小优先级越高**）。穷尽 switch，无 default。
    static func priority(_ state: DemoVisualState) -> Int {
        switch state {
        case .unsafe: return 0                  // safety —— 永远最高，不被 changing 覆盖（DGA-075）
        case .unknown: return 1                 // crash（真错误）
        case .blocked_with_alternative: return 2 // clarify（停留等人响应，排 changing 上）
        case .changing: return 3                // 执行中
        // 4 = selected/hover 交互叠加层（见 interactionSelectedHoverPriority）
        case .blocked_hard: return 5            // unsupported（静默终态，排 hover 下）
        case .satisfied: return 6
        case .normal: return 7
        }
    }

    /// selected/hover 交互叠加层优先级（介于 changing 与 unsupported 之间，commander 终序）。
    static let interactionSelectedHoverPriority: Int = 4

    /// a 是否优先于 b（严格支配）。
    static func dominates(_ a: DemoVisualState, over b: DemoVisualState) -> Bool {
        priority(a) < priority(b)
    }

    /// 一组态里的主导态（空 → nil）。
    static func dominant(among states: [DemoVisualState]) -> DemoVisualState? {
        states.min { priority($0) < priority($1) }
    }

    /// 一组卡片里被 featured 的（主导态 + 稳定 key 次序）——供 activeFamily / hero 选择消费，
    /// 清偿「二值压缩债」（`visualState != .normal` 的 binary 判定，D7）。
    /// selected/hover 通过 `selectedKeys` 注入：被选中/悬停的卡获得交互层优先级（介于 changing 与 satisfied）。
    static func featuredIndex(states: [DemoVisualState],
                              selectedFlags: [Bool]? = nil) -> Int? {
        guard !states.isEmpty else { return nil }
        var best: (idx: Int, pri: Int)? = nil
        for (i, state) in states.enumerated() {
            let statePri = priority(state)
            let selected = selectedFlags?.indices.contains(i) == true && selectedFlags![i]
            // 交互层：selected/hover 抬升到 interaction 层（若其状态优先级低于交互层）
            let effectivePri = selected ? min(statePri, interactionSelectedHoverPriority) : statePri
            if best == nil || effectivePri < best!.pri {
                best = (i, effectivePri)
            }
        }
        return best?.idx
    }
}
