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
struct ValueControlActions {
    var increment: (() -> Void)?
    var decrement: (() -> Void)?
    var toggle: (() -> Void)?
    var cycleBadge: (() -> Void)?
    var selectBadge: ((String) -> Void)?
}

struct ValueControlView: View {
    let valueType: UIValueType
    let numericValue: Double       // dial/percent/stepper 的数值
    let range: ClosedRange<Double> // 控件值域（ValueRangeMapper 派生自 contract execution_range）
    let stepCount: Int             // stepper 档位数（range 内整数档，如座椅 0-3 → 3）
    let displayText: String        // 格式化文本（24℃/80%/2挡/开…）
    let isOn: Bool                 // toggle 开关态
    let badgeStyle: BadgeRenderStyle
    var badgeOptions: [String] = []
    var tint: Color = DesignTokens.glowCyan
    var actions = ValueControlActions()

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
        StepperLikeShell(
            onDecrement: actions.decrement,
            onIncrement: actions.increment
        ) {
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
    }

    // percent = 容量环（.accessoryCircularCapacity，填充比例直观）
    private var percentGauge: some View {
        StepperLikeShell(
            onDecrement: actions.decrement,
            onIncrement: actions.increment
        ) {
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
        .overlay(alignment: .leading) {
            hitButton(label: "减少", systemName: "minus", action: actions.decrement)
                .offset(x: -26)
        }
        .overlay(alignment: .trailing) {
            hitButton(label: "增加", systemName: "plus", action: actions.increment)
                .offset(x: 26)
        }
    }
    private var activeSteps: Int {
        // 🔴 codex P1-2 修：亮段 = 当前档位值(clamp+round)；段数=max → fan「1挡」亮1格 / seat「2挡」亮2格 / 「0挡」亮0格
        max(0, min(stepCount, Int(numericValue.clamped(to: range).rounded())))
    }

    // toggle = 开关视觉（开/关 + 图标 + 色）
    private var toggleVisual: some View {
        Button {
            actions.toggle?()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isOn ? "power.circle.fill" : "power.circle")
                    .font(.title3)
                    .foregroundStyle(isOn ? tint : DesignTokens.inkDim)
                Text(displayText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isOn ? DesignTokens.inkPrimary : DesignTokens.inkDim)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("切换")
    }

    @ViewBuilder private var badgeVisual: some View {
        if hasBadgeAction, badgeOptions.isEmpty {
            Button {
                actions.cycleBadge?()
            } label: {
                badgeBody
            }
            .buttonStyle(.plain)
            .accessibilityLabel("切换选项")
        } else {
            badgeBody
        }
    }

    private var hasBadgeAction: Bool {
        actions.cycleBadge != nil || actions.selectBadge != nil
    }

    @ViewBuilder private var badgeBody: some View {
        switch badgeStyle {
        case .colorSwatch(let name):
            VStack(alignment: .trailing, spacing: 5) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(LinearGradient(colors: DesignTokens.ambientGradient(named: name), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 18, height: 18)
                        .overlay(Circle().strokeBorder(.white.opacity(0.48), lineWidth: 0.6))
                        .shadow(color: DesignTokens.ambientColor(named: name).opacity(0.7), radius: 6)
                    Text(displayText).font(.caption.weight(.semibold)).foregroundStyle(DesignTokens.inkPrimary)
                }
                if !badgeOptions.isEmpty {
                    AmbientColorPalette(
                        options: badgeOptions,
                        selectedName: name,
                        onSelect: { option in
                            if let selectBadge = actions.selectBadge {
                                selectBadge(option)
                            } else {
                                actions.cycleBadge?()
                            }
                        }
                    )
                }
            }
        case .mode(let mode):
            VStack(alignment: .trailing, spacing: 5) {
                Text(mode)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 9).padding(.vertical, 3)
                    .background(modeTint(for: mode).opacity(0.20), in: Capsule())
                    .foregroundStyle(DesignTokens.inkPrimary)
                    .overlay(
                        Capsule().strokeBorder(modeTint(for: mode).opacity(0.52), lineWidth: 0.7)
                    )
                if !badgeOptions.isEmpty {
                    ModeOptionPalette(
                        options: badgeOptions,
                        selectedMode: mode,
                        onSelect: { option in
                            if let selectBadge = actions.selectBadge {
                                selectBadge(option)
                            } else {
                                actions.cycleBadge?()
                            }
                        }
                    )
                }
            }
        case .plain:
            Text(displayText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.inkPrimary)
        }
    }

    private func hitButton(label: String, systemName: String, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            Image(systemName: systemName)
                .font(.caption.weight(.bold))
                .foregroundStyle(DesignTokens.inkDim)
                .frame(width: 26, height: 34)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func modeTint(for mode: String) -> Color {
        switch mode {
        case "制热": return DesignTokens.semanticWarm
        case "制冷": return DesignTokens.semanticCoolBright
        case "自动", "auto": return DesignTokens.glowViolet
        default: return DesignTokens.glowViolet
        }
    }
}

private struct ModeOptionPalette: View {
    let options: [String]
    let selectedMode: String
    let onSelect: (String) -> Void

    private var rows: [[String]] {
        stride(from: 0, to: options.count, by: 3).map { start in
            Array(options[start..<min(start + 3, options.count)])
        }
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 5) {
                    ForEach(row, id: \.self) { option in
                        let label = displayLabel(for: option)
                        Button {
                            onSelect(option)
                        } label: {
                            Text(label)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .foregroundStyle(isSelected(option) ? Color.white : DesignTokens.inkPrimary)
                                .background(
                                    Capsule().fill(optionTint(for: option).opacity(isSelected(option) ? 0.88 : 0.18))
                                )
                                .overlay(
                                    Capsule().strokeBorder(optionTint(for: option).opacity(isSelected(option) ? 0.95 : 0.38), lineWidth: 0.7)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("模式\(label)")
                    }
                }
            }
        }
    }

    private func displayLabel(for option: String) -> String {
        option == "auto" ? "自动" : option
    }

    private func isSelected(_ option: String) -> Bool {
        displayLabel(for: option) == selectedMode
    }

    private func optionTint(for option: String) -> Color {
        switch option {
        case "制热": return DesignTokens.semanticWarm
        case "制冷": return DesignTokens.semanticCoolBright
        case "auto": return DesignTokens.glowViolet
        default: return DesignTokens.glowViolet
        }
    }
}

private struct AmbientColorPalette: View {
    let options: [String]
    let selectedName: String
    let onSelect: (String) -> Void

    private var rows: [[String]] {
        stride(from: 0, to: options.count, by: 4).map { start in
            Array(options[start..<min(start + 4, options.count)])
        }
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { option in
                        Button {
                            onSelect(option)
                        } label: {
                            Circle()
                                .fill(LinearGradient(colors: DesignTokens.ambientGradient(named: option),
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing))
                                .frame(width: 17, height: 17)
                                .overlay(
                                    Circle().strokeBorder(
                                        isSelected(option) ? Color.white.opacity(0.96) : Color.white.opacity(0.32),
                                        lineWidth: isSelected(option) ? 1.6 : 0.55
                                    )
                                )
                                .shadow(color: DesignTokens.ambientColor(named: option).opacity(isSelected(option) ? 0.78 : 0.38),
                                        radius: isSelected(option) ? 6 : 3)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("氛围灯\(option)")
                    }
                }
            }
        }
    }

    private func isSelected(_ option: String) -> Bool {
        AmbientBurstColorMapper.normalizedColorName(for: option) == AmbientBurstColorMapper.normalizedColorName(for: selectedName)
    }
}

private struct StepperLikeShell<Content: View>: View {
    var onDecrement: (() -> Void)?
    var onIncrement: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 6) {
            Button {
                onDecrement?()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DesignTokens.inkDim)
                    .frame(width: 24, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("减少")

            content()
                .frame(width: 56, height: 56)

            Button {
                onIncrement?()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DesignTokens.inkDim)
                    .frame(width: 24, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("增加")
        }
    }
}
