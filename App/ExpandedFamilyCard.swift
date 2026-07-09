import SwiftUI

/// 展开层族卡（4b 触发聚焦展开，AD-11/AD-13 展开层 + AD-12 §五 ZStack overlay）。
/// device composite：该族每 cell 一行 label + `ValueControlView` 图形控件（座椅 5 cell 行分 3 类）。
/// 🔴 content_glow 卡背（非 `.glassEffect` 内容层，AD-6）；dim/blur 背景层在 ContentView overlay。
struct ExpandedFamilyCard: View {
    let display: ExpandedFamilyDisplay
    let onDismiss: () -> Void
    var forceReduceMotion = false
    var onMockTransition: (String, String) -> Void = { _, _ in }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var effectiveReduceMotion: Bool { reduceMotion || forceReduceMotion }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(display.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DesignTokens.inkPrimary)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(DesignTokens.inkDim)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("收起")
                .accessibilityIdentifier("expanded-\(display.family.rawValue)-close")
            }
            if display.rows.isEmpty {
                Text("待命").font(.headline).foregroundStyle(DesignTokens.inkDim)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(display.rows) { row in
                    ExpandedCellRowView(
                        row: row,
                        forceReduceMotion: effectiveReduceMotion,
                        onMockTransition: onMockTransition
                    )
                    if row.id != display.rows.last?.id {
                        Divider().overlay(DesignTokens.inkDim2.opacity(0.2))
                    }
                }
            }
        }
        .padding(22)
        .frame(maxWidth: 440)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(DesignTokens.bgBase)
                .shadow(color: DesignTokens.glowCyan.opacity(0.25), radius: 24)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(DesignTokens.glowCyan.opacity(0.5), lineWidth: 1)
        )
        .padding(24)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("expanded-\(display.family.rawValue)")
    }
}

/// 单行：device label + 图形控件（穷尽 `ValueControlView`）+ 态图标（双通道）。
struct ExpandedCellRowView: View {
    let row: ExpandedCellRow
    var forceReduceMotion = false
    var onMockTransition: (String, String) -> Void = { _, _ in }
    private var appearance: CardAppearance { CardAppearance.of(row.visualState) }

    var body: some View {
        HStack(spacing: 14) {
            Text(row.label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.inkPrimary)
                .lineLimit(1).minimumScaleFactor(0.7)
            if let icon = appearance.icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(appearance.border)
            }
            Spacer(minLength: 8)
            ValueControlView(
                valueType: row.valueType,
                numericValue: row.numericValue,
                range: row.range,
                stepCount: row.stepCount,
                displayText: row.displayText,
                isOn: row.isOn,
                badgeStyle: row.badgeStyle,
                badgeOptions: badgeOptions,
                primaryActionIdentifier: primaryActionIdentifier,
                forceReduceMotion: forceReduceMotion,
                actions: actions
            )
            .frame(maxWidth: 130, minHeight: 56)
        }
        .padding(.vertical, 2)
    }

    private var actions: ValueControlActions {
        ValueControlActions(
            setNumeric: setNumeric,
            increment: stepped(.increment),
            decrement: stepped(.decrement),
            toggle: toggle,
            cycleBadge: cycleBadge,
            selectBadge: selectBadge
        )
    }

    private var setNumeric: ((Double) -> Void)? {
        switch row.valueType {
        case .dial, .percent, .stepper:
            return { value in
                let base = ScopedStateKey(row.id).base
                onMockTransition(row.id, ValueRangeMapper.valueString(value, forBase: base))
            }
        case .toggle, .badge:
            return nil
        }
    }

    private func stepped(_ direction: ValueRangeMapper.StepDirection) -> (() -> Void)? {
        switch row.valueType {
        case .dial, .percent, .stepper:
            return {
                let base = ScopedStateKey(row.id).base
                let next = ValueRangeMapper.steppedValue(row.numericValue, forBase: base, direction: direction)
                onMockTransition(row.id, next)
            }
        case .toggle, .badge:
            return nil
        }
    }

    private var toggle: (() -> Void)? {
        guard row.valueType == .toggle else { return nil }
        return {
            let base = ScopedStateKey(row.id).base
            onMockTransition(row.id, ValueRangeMapper.toggledValue(current: row.rawValue, forBase: base))
        }
    }

    private var cycleBadge: (() -> Void)? {
        guard row.valueType == .badge, !badgeOptions.isEmpty else { return nil }
        return {
            let next = ValueRangeMapper.nextBadgeValue(current: currentBadgeValue, options: badgeOptions)
            onMockTransition(row.id, next)
        }
    }

    private var selectBadge: ((String) -> Void)? {
        guard row.valueType == .badge, !badgeOptions.isEmpty else { return nil }
        return { value in
            onMockTransition(row.id, value)
        }
    }

    private var currentBadgeValue: String {
        row.rawValue
    }

    private var badgeOptions: [String] {
        BadgeOptionMapper.options(forBase: ScopedStateKey(row.id).base)
    }

    private var primaryActionIdentifier: String {
        "value-control-\(ScopedStateKey(row.id).base.replacingOccurrences(of: ".", with: "-"))-primary"
    }
}
