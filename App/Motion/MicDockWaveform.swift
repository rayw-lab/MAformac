import SwiftUI

/// 基础 · MicDock 拾起波形（teardown §5.5）—— Mac mouseDown/up + Option+Space。
///
/// 三柱波形（phase 0/80/160ms），振幅随输入电平、cap 24px。**Canvas 实现（非重复 SwiftUI stack）**。
/// RM 降级 = 静态电平表（无相位动画）。
struct MicDockWaveform: View {
    /// 输入电平 0…1。
    let level: Double
    let reduceMotion: Bool
    var barColor: Color = DesignTokens.glowCyan

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
            Canvas { context, size in
                let bars = MotionTimings.MicDock.waveBarCount
                let cap = MotionTimings.MicDock.waveAmplitudeCapPT
                let spacing: CGFloat = 6
                let barWidth: CGFloat = 4
                let totalW = CGFloat(bars) * barWidth + CGFloat(bars - 1) * spacing
                let startX = (size.width - totalW) / 2
                let midY = size.height / 2
                let now = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<bars {
                    let phase = MotionTimings.MicDock.wavePhaseOffsetsMS[i] / 1000.0
                    // RM：静态电平（无相位调制）；否则相位调制
                    let osc = reduceMotion ? 1.0 : (0.55 + 0.45 * sin((now + phase) * 6.0))
                    let amp = min(CGFloat(level) * CGFloat(cap) * osc, CGFloat(cap))
                    let h = max(amp, 3)
                    let x = startX + CGFloat(i) * (barWidth + spacing)
                    let rect = CGRect(x: x, y: midY - h / 2, width: barWidth, height: h)
                    let bar = Path(roundedRect: rect, cornerRadius: barWidth / 2)
                    context.fill(bar, with: .color(barColor.opacity(0.85)))
                }
            }
        }
        .frame(height: MotionTimings.MicDock.waveAmplitudeCapPT + 4)
        .allowsHitTesting(false)
    }
}
