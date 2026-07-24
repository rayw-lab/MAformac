import SwiftUI

/// 基础 · 数值滚动确认（teardown §5.3）—— 温度/音量/亮度 readback 更新。
///
/// old y 0→-8 opacity 1→0（90ms）/ new y 8→0 opacity 0→1（120ms，起 40ms）；单位标签静止。
/// 值跳变 >10 单位走 3 步滚（220ms 封顶），否则单跳。**数字在固定宽度层，禁卡片 relayout**。
struct RollingNumberText: View {
    let value: Int
    let unit: String
    var font: Font = .system(size: 34, weight: .bold, design: .rounded)
    var color: Color = DesignTokens.inkPrimary
    let reduceMotion: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(value)")
                .font(font)
                .foregroundStyle(color)
                .contentTransition(.numericText(value: Double(value)))
                .animation(reduceMotion ? nil : rollAnimation, value: value)
                .monospacedDigit()   // 固定宽度层，防 relayout 抖动
            Text(unit)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(color.opacity(0.7))
        }
    }

    /// 常规 120ms；无法从此处感知 delta（value 已更新），滚动步进由 numericText 承担，
    /// 大跳的 3 步封顶语义在 `MotionTimings.ValueScroll` SSOT（消费方按 delta 决定是否分步）。
    private var rollAnimation: Animation {
        .timingCurve(0.2, 0, 0, 1, duration: MotionAnimationFactory.seconds(MotionTimings.ValueScroll.newInMS))
    }
}
