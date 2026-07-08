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
    /// 重放代号（TXB 修②）：开场/reset 时 ContentView **递增**此值 → onChange 真触发重入场。
    /// 旧「isActive:false + stable .id」不会重放（id 稳定=view 不重建，onAppear 不再触发）——已修。
    let replayToken: Int
    let reduceMotion: Bool

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .scaleEffect(reduceMotion || appeared ? 1 : MotionTimings.Waterfall.cardStartScale)
            .offset(y: reduceMotion || appeared ? 0 : MotionTimings.Waterfall.cardStartTranslateY)
            .onAppear { animateIn() }
            .onChange(of: replayToken) { old, new in
                if MotionTimings.Waterfall.shouldReplay(previous: old, current: new) {
                    appeared = false
                    animateIn()
                }
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

/// 招牌② 卡内 icon/value 独立入场（TX7 修②；teardown §5.2「icon/value 在卡 70% opacity 时 80ms 入场」）。
///
/// 内容入场延迟 = 卡延迟 `min(i*18,120)` + 卡 spring 的 70% 处（`contentAtOpacityFraction*cardSpringMS`），
/// 淡入 `contentFadeMS=80ms`。RM 降级 = 随卡单次 fade（无独立延迟）。
struct CardContentEntrance: ViewModifier {
    let index: Int
    let replayToken: Int
    let reduceMotion: Bool

    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion || visible ? 1 : 0)
            .onAppear { animateIn() }
            .onChange(of: replayToken) { old, new in
                if MotionTimings.Waterfall.shouldReplay(previous: old, current: new) {
                    visible = false
                    animateIn()
                }
            }
    }

    private func animateIn() {
        if reduceMotion {
            withAnimation(.easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.Waterfall.reduceMotionFadeMS))) {
                visible = true
            }
            return
        }
        let cardDelay = MotionTimings.Waterfall.cardDelayMS(index: index)
        let contentDelay = cardDelay + MotionTimings.Waterfall.contentAtOpacityFraction * MotionTimings.Waterfall.cardSpringMS
        withAnimation(.easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.Waterfall.contentFadeMS))
            .delay(MotionAnimationFactory.seconds(contentDelay))) {
            visible = true
        }
    }
}

extension View {
    /// 招牌② 瀑布入场（便捷挂载）。`replayToken` 递增触发重入场（reset/开场）。
    func cardWaterfallEntrance(index: Int, replayToken: Int, reduceMotion: Bool) -> some View {
        modifier(CardWaterfallEntrance(index: index, replayToken: replayToken, reduceMotion: reduceMotion))
    }
    /// 招牌② 卡内 icon/value 独立入场（70% opacity 时 80ms）。
    func cardContentEntrance(index: Int, replayToken: Int, reduceMotion: Bool) -> some View {
        modifier(CardContentEntrance(index: index, replayToken: replayToken, reduceMotion: reduceMotion))
    }
}
