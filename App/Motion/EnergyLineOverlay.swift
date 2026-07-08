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
    /// 触发信号（识别完成置真）。
    let isFiring: Bool
    let reduceMotion: Bool
    var themeCyan: Color = DesignTokens.glowCyan
    var themeViolet: Color = DesignTokens.glowViolet

    /// 0…1 线 trim 进度。
    @State private var trim: CGFloat = 0

    var body: some View {
        Canvas { context, _ in
            guard trim > 0 else { return }
            var path = Path()
            path.move(to: from)
            // 单条二次贝塞尔（青紫渐变能量线），控制点上抬形成弧线
            let control = CGPoint(x: (from.x + to.x) / 2,
                                  y: min(from.y, to.y) - abs(to.x - from.x) * 0.12)
            path.addQuadCurve(to: to, control: control)
            let trimmed = path.trimmedPath(from: 0, to: trim)
            let gradient = GraphicsContext.Shading.linearGradient(
                Gradient(colors: [themeViolet.opacity(0.0), themeViolet, themeCyan]),
                startPoint: from, endPoint: to)
            context.stroke(trimmed, with: gradient, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            // 命中头部光点
            if trim > 0.85 {
                let dot = Path(ellipseIn: CGRect(x: to.x - 5, y: to.y - 5, width: 10, height: 10))
                context.fill(dot, with: .color(themeCyan.opacity(Double((trim - 0.85) / 0.15))))
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isFiring) { _, firing in
            guard firing else { trim = 0; return }
            fire()
        }
    }

    private func fire() {
        trim = 0
        if reduceMotion {
            // RM：直接点亮头部（无流动），瞬时呈现
            withAnimation(.easeOut(duration: MotionAnimationFactory.seconds(MotionTimings.EnergyLine.cardPulseDurationMS))) {
                trim = 1
            }
            return
        }
        // 70-260ms line trim，cubic(.16,1,.3,1)
        let dur = MotionTimings.EnergyLine.lineTrimEndMS - MotionTimings.EnergyLine.lineTrimStartMS
        let delay = MotionAnimationFactory.seconds(MotionTimings.EnergyLine.lineTrimStartMS)
        withAnimation(MotionTimings.EnergyLine.lineCurve.cubicAnimation(durationMS: dur).delay(delay)) {
            trim = 1
        }
    }
}
