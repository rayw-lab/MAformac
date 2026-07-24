import SwiftUI

/// 招牌① —— orb → 卡片能量流动线（D-126 拍①；teardown §5.1）。
///
/// 识别完成 → 青紫能量线从 orb 射向目标卡 → 命中点亮。
/// **单 Canvas 层实现，禁 per-pixel SwiftUI layout**（dispatch 硬规则 + `MotionTimings.EnergyLine.rendersInSingleCanvasLayer`）。
/// 时序（`MotionTimings.EnergyLine`）：0-90 orb glow / 70-260 line trim(cubic .16,1,.3,1) / 210-340 card pulse。
/// RM 降级：无流动线，目标卡直接 100ms fade 点亮（保语义）。
struct EnergyLineOverlay: View {
    /// orb 中心（视图坐标）。
    let from: CGPoint
    /// 目标卡中心（视图坐标）。
    let to: CGPoint
    /// 触发信号（识别完成/readback 事件递增）。
    let triggerToken: Int
    let reduceMotion: Bool
    /// 三档预算：`allowLargeBlurAndShadow=false`(L1/L2) 时关 glow/blow 底层软描边，静态档关 pulse（TX7 修①）。
    var budget: PresentationMotionBudget = .preset(.fullShowcase)
    var themeCyan: Color = DesignTokens.glowCyan
    var themeViolet: Color = DesignTokens.glowViolet
    var onCompletion: () -> Void = {}

    /// 0…1 线 trim 进度。
    @State private var trim: CGFloat = 0
    /// 0…1 orb glow 进度（0-90ms，scale 1→1.08 + opacity +0.18）。
    @State private var orbGlow: CGFloat = 0
    /// 0…1 目标卡 ring pulse 进度（210-340ms，opacity 0→.22→0）。
    @State private var cardPulse: CGFloat = 0
    /// 0…1 completion gate；只用于 SwiftUI animation completion 推进队列。
    @State private var completionProgress: CGFloat = 0

    /// 是否允许 glow/blur 软层（budget + RM 双门）。
    private var allowsGlow: Bool { !reduceMotion && budget.allowLargeBlurAndShadow }

    var body: some View {
        Canvas { context, _ in
            _ = completionProgress
            var path = Path()
            path.move(to: from)
            // 单条二次贝塞尔（青紫渐变能量线），控制点上抬形成弧线
            let control = CGPoint(x: (from.x + to.x) / 2,
                                  y: min(from.y, to.y) - abs(to.x - from.x) * 0.12)
            path.addQuadCurve(to: to, control: control)
            let gradient = GraphicsContext.Shading.linearGradient(
                Gradient(colors: [themeViolet.opacity(0.0), themeViolet, themeCyan]),
                startPoint: from, endPoint: to)

            if orbGlow > 0 {
                let scale = 1 + (MotionTimings.EnergyLine.orbGlowScale - 1) * orbGlow
                let radius = 21 * CGFloat(scale)
                let opacity = Double(0.18 * (1 - orbGlow * 0.2))
                let glow = Path(ellipseIn: CGRect(x: from.x - radius,
                                                  y: from.y - radius,
                                                  width: radius * 2,
                                                  height: radius * 2))
                context.fill(glow, with: .color(themeViolet.opacity(opacity)))
                context.stroke(glow, with: .color(themeCyan.opacity(opacity * 0.85)),
                               style: StrokeStyle(lineWidth: 1.5))
            }

            if trim > 0 {
                let trimmed = path.trimmedPath(from: 0, to: trim)
                // 底层软描边（blur/glow 代偿，budget 关时不画）—— line blur 10→2 的 Canvas 近似
                if allowsGlow {
                    context.stroke(trimmed, with: gradient,
                                   style: StrokeStyle(lineWidth: 9, lineCap: .round))
                }
                context.stroke(trimmed, with: gradient,
                               style: StrokeStyle(lineWidth: 3, lineCap: .round))
                // 命中头部光点
                if trim > 0.85 {
                    let dot = Path(ellipseIn: CGRect(x: to.x - 5, y: to.y - 5, width: 10, height: 10))
                    context.fill(dot, with: .color(themeCyan.opacity(Double((trim - 0.85) / 0.15))))
                }
            }

            // 目标卡 ring pulse（命中点亮，210-340ms）：opacity 0→.22→0，半径随 pulse 扩张
            if cardPulse > 0 {
                let opacity = Double(0.22 * (cardPulse < 0.5 ? cardPulse * 2 : (1 - cardPulse) * 2))
                let r = 18 + cardPulse * 14
                let ring = Path(ellipseIn: CGRect(x: to.x - r, y: to.y - r, width: r * 2, height: r * 2))
                context.stroke(ring, with: .color(themeCyan.opacity(opacity)),
                               style: StrokeStyle(lineWidth: 2.5))
            }
        }
        .allowsHitTesting(false)
        .onChange(of: triggerToken) { _, token in
            guard token > 0 else { reset() ; return }
            fire()
        }
        .onAppear {
            if triggerToken > 0 {
                fire()
            }
        }
    }

    private func fire() {
        reset()
        runCompletionGate(
            durationMS: reduceMotion
                ? MotionTimings.EnergyLine.cardPulseDurationMS
                : Double(MotionTimings.EnergyLine.totalMS)
        )
        if reduceMotion {
            // RM：直接点亮头部（无流动、无 pulse），瞬时呈现
            withAnimation(.easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.EnergyLine.cardPulseDurationMS))) {
                trim = 1
            }
            return
        }
        // 0-90ms orb glow，scale 1→1.08 +0.18 opacity
        withAnimation(.easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.EnergyLine.orbGlowMS))) {
            orbGlow = 1
        }
        // 70-260ms line trim，cubic(.16,1,.3,1)
        let dur = MotionTimings.EnergyLine.lineTrimEndMS - MotionTimings.EnergyLine.lineTrimStartMS
        let delay = MotionAnimationFactory.seconds(MotionTimings.EnergyLine.lineTrimStartMS)
        withAnimation(MotionTimings.EnergyLine.lineCurve.cubicAnimation(durationMS: dur).delay(delay)) {
            trim = 1
        }
        // 210-340ms 目标卡 ring pulse 100ms（静态档不 pulse）
        guard budget.level != .trainSafeStatic else { return }
        let pulseDelay = MotionAnimationFactory.seconds(MotionTimings.EnergyLine.cardPulseStartMS)
        withAnimation(.easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.EnergyLine.cardPulseDurationMS)).delay(pulseDelay)) {
            cardPulse = 1
        }
    }

    private func runCompletionGate(durationMS: Double) {
        completionProgress = 0
        withAnimation(
            .linear(duration: MotionAnimationFactory.seconds(durationMS)),
            completionCriteria: .logicallyComplete
        ) {
            completionProgress = 1
        } completion: {
            onCompletion()
        }
    }

    private func reset() {
        trim = 0
        orbGlow = 0
        cardPulse = 0
        completionProgress = 0
    }
}
