import SwiftUI

/// value.type 异构控件视图（spec ui-presentation R2：5 类**穷尽 switch + 禁 AnyView**）。
///
/// 用于触发聚焦展开后的 device composite 卡（**4b 展开层**）；摘要层走文本格式化（4a，`VehicleStateCard.valueText`，phase matrix AD-13）。
/// 5 类形态（AD-2 + P4-D1 4b 段，控件选型）：
///   - `dial`    = `Gauge(.accessoryCircular)`         环形仪表（温度；🔴 **非 watchOS `.circular`**，iOS16+/macOS13+ ≤ deployment 26）
///   - `percent` = `Gauge(.accessoryCircularCapacity)` 容量环（开度类，填充比例直观）
///   - `stepper` = 分段档位条                          当前档高亮（座椅档/风量，离散 N 档）
///   - `toggle`  = 开关视觉                            开/关 + 图标 + 色
///   - `badge`   = 二级 `BadgeRenderStyle` 穷尽 switch  色块 / 模式 / 纯文本（无 if 链无 AnyView，守 spec.md:83）
///
/// 🔴 双通道（AD-7）：值由「数值环 + 文本 + 色」共同承载，非只靠 Gauge 图形；ReduceMotion/低对比仍可读。
struct ValueControlView: View {
    let valueType: UIValueType
    let numericValue: Double       // dial/percent/stepper 的数值
    let range: ClosedRange<Double> // 控件值域（ValueRangeMapper 派生自 contract execution_range）
    let stepCount: Int             // stepper 档位数（range 内整数档，如座椅 0-3 → 3）
    let displayText: String        // 格式化文本（24℃/80%/2挡/开…）
    let isOn: Bool                 // toggle 开关态
    let badgeStyle: BadgeRenderStyle
    var tint: Color = DesignTokens.glowCyan

    var body: some View {
        // 🔴 spec R2：穷尽 switch（无 default），每类 dedicated 分支，禁 AnyView（保静态类型 diff 高效，C11/C12）
        switch valueType {
        case .dial:    dialGauge
        case .percent: percentGauge
        case .stepper: stepperBar
        case .toggle:  toggleVisual
        case .badge:   badgeVisual
        }
    }

    // dial = 环形仪表（🔴 .accessoryCircular 非 watchOS .circular）
    private var dialGauge: some View {
        Gauge(value: numericValue.clamped(to: range), in: range) {
            EmptyView()
        } currentValueLabel: {
            Text(displayText)
                .font(.caption.weight(.bold))
                .foregroundStyle(DesignTokens.inkPrimary)
                .minimumScaleFactor(0.6)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(tint)
    }

    // percent = 容量环（.accessoryCircularCapacity，填充比例直观）
    private var percentGauge: some View {
        Gauge(value: numericValue.clamped(to: range), in: range) {
            EmptyView()
        } currentValueLabel: {
            Text(displayText)
                .font(.caption.weight(.bold))
                .foregroundStyle(DesignTokens.inkPrimary)
                .minimumScaleFactor(0.6)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(tint)
    }

    // stepper = 分段档位条（当前档高亮，离散 N 档；双通道：档数 + 文本）
    private var stepperBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 3) {
                ForEach(0 ..< max(1, stepCount), id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(i < activeSteps ? tint : DesignTokens.inkDim2.opacity(0.3))
                        .frame(height: 10)
                }
            }
            Text(displayText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DesignTokens.inkPrimary)
        }
    }
    private var activeSteps: Int {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        let ratio = (numericValue.clamped(to: range) - range.lowerBound) / span
        return max(0, min(stepCount, Int((ratio * Double(stepCount)).rounded())))
    }

    // toggle = 开关视觉（开/关 + 图标 + 色）
    private var toggleVisual: some View {
        HStack(spacing: 6) {
            Image(systemName: isOn ? "power.circle.fill" : "power.circle")
                .font(.title3)
                .foregroundStyle(isOn ? tint : DesignTokens.inkDim)
            Text(displayText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isOn ? DesignTokens.inkPrimary : DesignTokens.inkDim)
        }
    }

    // badge = 二级 BadgeRenderStyle 穷尽 switch（无 default；色块/模式/纯文本）
    @ViewBuilder private var badgeVisual: some View {
        switch badgeStyle {
        case .colorSwatch(let name):
            HStack(spacing: 6) {
                Circle()
                    .fill(DesignTokens.ambientColor(named: name))
                    .frame(width: 18, height: 18)
                    .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 0.5))
                    .shadow(color: DesignTokens.ambientColor(named: name).opacity(0.6), radius: 5)
                Text(displayText).font(.subheadline).foregroundStyle(DesignTokens.inkPrimary)
            }
        case .mode(let mode):
            Text(mode)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 9).padding(.vertical, 3)
                .background(DesignTokens.glowViolet.opacity(0.18), in: Capsule())
                .foregroundStyle(DesignTokens.inkPrimary)
        case .plain:
            Text(displayText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.inkPrimary)
        }
    }
}
