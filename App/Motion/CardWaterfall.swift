import SwiftUI

/// 招牌② —— 10 卡入场瀑布（D-126 拍②；teardown §5.2）。
///
/// 开场/reset 时，卡 i 延迟 `min(i*18ms, 120ms)` 后以 spring(response .28, damping .9) 180ms 入场
/// （opacity 0→1, translateY 8→0, scale .985→1）。**premeasured frame，只动 transform/opacity**。
/// RM 降级 = 单次 100ms fade（无位移/缩放）。
///
/// 用法：卡片 `.modifier(CardWaterfallEntrance(index: i, isActive: waterfallPlaying, reduceMotion: rm))`。
struct CardWaterfallEntrance: ViewModifier {
    let index: Int
    /// 入场序号触发信号（开场/reset 时置真触发一次）。
    let isActive: Bool
    let reduceMotion: Bool

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .scaleEffect(reduceMotion || appeared ? 1 : MotionTimings.Waterfall.cardStartScale)
            .offset(y: reduceMotion || appeared ? 0 : MotionTimings.Waterfall.cardStartTranslateY)
            .onAppear { animateIn() }
            .onChange(of: isActive) { _, active in
                if active { appeared = false; animateIn() }
            }
    }

    private func animateIn() {
        if reduceMotion {
            // RM 降级：单次 100ms fade，无位移
            withAnimation(.easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.Waterfall.reduceMotionFadeMS))) {
                appeared = true
            }
            return
        }
        let delay = MotionAnimationFactory.seconds(MotionTimings.Waterfall.cardDelayMS(index: index))
        let spring = MotionTimings.Waterfall.cardSpring.swiftUIAnimation  // spring(.28,.9)
        withAnimation(spring.delay(delay)) {
            appeared = true
        }
    }
}

extension View {
    /// 招牌② 瀑布入场（便捷挂载）。
    func cardWaterfallEntrance(index: Int, isActive: Bool, reduceMotion: Bool) -> some View {
        modifier(CardWaterfallEntrance(index: index, isActive: isActive, reduceMotion: reduceMotion))
    }
}
