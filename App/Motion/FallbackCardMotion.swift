import SwiftUI

/// 基础 · fallback 不丢脸卡入场（teardown §5.4）—— 拒识/未挂载/clarify 的 amber/grey/safety result。
///
/// tint 0-80ms 淡入 → reason badge 40-160ms 滑入(x -4→0) → 建议 chip 120-240ms 出现（**无执行按钮**）。
/// safety 变体：红只在相关卡，无全局红洗（`MotionTimings.Fallback.safetyRedScopedToCardOnly` + D0G-001）。
/// 总 240ms（正好 ≤ 重复上限）。RM = 单次 fade，无位移。
struct FallbackCardStagger: ViewModifier {
    /// 三段进度阶段（消费方按 elapsed 推进；此 modifier 只做 badge/chip 的进入过渡）。
    let phase: FallbackPhase
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
    }
}

/// fallback 三段入场阶段。
enum FallbackPhase: Equatable {
    case tint
    case badge
    case chip
}

/// reason badge 滑入过渡（40-160ms）。
struct FallbackBadgeTransition: ViewModifier {
    let visible: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(x: reduceMotion || visible ? 0 : MotionTimings.Fallback.badgeStartTranslateX)
            .animation(
                reduceMotion
                    ? .easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.Fallback.tintFadeEndMS))
                    : .easeOut(duration: MotionAnimationFactory.seconds(
                        MotionTimings.Fallback.badgeSlideEndMS - MotionTimings.Fallback.badgeSlideStartMS))
                        .delay(MotionAnimationFactory.seconds(MotionTimings.Fallback.badgeSlideStartMS)),
                value: visible)
    }
}

/// 建议 chip 出现过渡（120-240ms，无执行按钮）。
struct FallbackChipTransition: ViewModifier {
    let visible: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .animation(
                reduceMotion
                    ? .easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.Fallback.tintFadeEndMS))
                    : .easeOut(duration: MotionAnimationFactory.seconds(
                        MotionTimings.Fallback.chipEndMS - MotionTimings.Fallback.chipStartMS))
                        .delay(MotionAnimationFactory.seconds(MotionTimings.Fallback.chipStartMS)),
                value: visible)
    }
}

extension View {
    /// fallback reason badge 滑入。
    func fallbackBadgeTransition(visible: Bool, reduceMotion: Bool) -> some View {
        modifier(FallbackBadgeTransition(visible: visible, reduceMotion: reduceMotion))
    }
    /// fallback 建议 chip 出现。
    func fallbackChipTransition(visible: Bool, reduceMotion: Bool) -> some View {
        modifier(FallbackChipTransition(visible: visible, reduceMotion: reduceMotion))
    }
}
