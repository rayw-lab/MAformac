import Foundation

/// 状态视觉优先级 resolver（D0G-005，RATIFIED_BY_LEIGE_20260708）。
///
/// 权威链：**safety/unsafe > crash/unknown > changing > selected/hover > satisfied/normal**。
/// 多状态冲突时决定「哪个态主导卡片外观 / 哪张卡被 featured」，避免状态机不确定。
///
/// 🔴 口径填充（D0G-005 未显式排 clarify/unsupported）：`blocked_with_alternative`(clarify) 与
/// `blocked_hard`(unsupported) 是 runtime 结果态，置于 `changing` 之下、`selected/hover` 之上的
/// **attention 层**（runtime 结果应比纯交互 hover 更显）。此填充为 D0G-005 链的合理延伸，
/// 不改动链中已排 5 态的相对次序。selected/hover 是**交互叠加层**（非 `DemoVisualState`），
/// 位于 changing 与 satisfied 之间（链原文），由 `interactionSelectedHoverPriority` 承载。
enum StateVisualPriorityResolver {

    /// 状态优先级（**数值越小优先级越高**）。穷尽 switch，无 default。
    static func priority(_ state: DemoVisualState) -> Int {
        switch state {
        case .unsafe: return 0                  // safety —— 永远最高，不被 changing 覆盖（DGA-075）
        case .unknown: return 1                 // crash（真错误）
        case .changing: return 2                // 执行中
        case .blocked_with_alternative: return 3 // clarify（attention：需确认）
        case .blocked_hard: return 4            // unsupported（attention：拒识）
        // 5 = selected/hover 交互叠加层（见 interactionSelectedHoverPriority）
        case .satisfied: return 6
        case .normal: return 7
        }
    }

    /// selected/hover 交互叠加层优先级（介于 changing 与 satisfied 之间，D0G-005 链原文）。
    static let interactionSelectedHoverPriority: Int = 5

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
