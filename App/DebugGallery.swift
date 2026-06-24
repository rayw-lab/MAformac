#if DEBUG
import SwiftUI

/// DEBUG 截图脚手架（spec ui-presentation §2.5；仅 DEBUG 编译，不进 release）。
///
/// 两层（磊哥拍 ①）：
/// - **gallery 一屏 7 态**：Phase 3 D7 内循环快速核（色映射颠倒/clarify 渲成红等），`simctl` 截 2 张/端。**不上 5-gate**（缩略失真）。
/// - **force-state 满屏 10 族 grid**：5-gate 验收用（真实视觉重量/字号/留白 + 10 族常驻骨架 + scope 角标 + ambient 色块）。
///   launch argument `-forceVisualState <态>`（如 `xcrun simctl launch <udid> lab.rayw.MAformac.ios -forceVisualState unsafe`）。
enum DebugVisualState {
    /// 从 launch argument 读 force-state；nil = 不强制（走正常 ContentView）。
    static var forced: DemoVisualState? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-forceVisualState"), i + 1 < args.count else { return nil }
        return DemoVisualState(rawValue: args[i + 1])
    }

    /// 7 态样例（ac 主 cell 数值 + blocked 态 reason；值保持数值，态色+图标+reason 表达结果，不把状态词塞进数值避免「不支持℃」）。
    static let samples: [(state: DemoVisualState, value: String, reason: String?)] = [
        (.normal, "26", nil),
        (.satisfied, "26", nil),
        (.changing, "27", nil),
        (.blocked_with_alternative, "18", "最低18℃，已为您调到18"),
        (.blocked_hard, "26", "后排无独立温控"),
        (.unsafe, "26", "行驶中禁止开启"),
        (.unknown, "26", "状态读取失败"),
    ]

    static func sample(for state: DemoVisualState) -> (value: String, reason: String?) {
        let s = samples.first { $0.state == state }
        return (s?.value ?? "26", s?.reason)
    }

    /// force-state 场景 = 10 族全景常驻 Grid：ac 受 forced 态（展示态色 + reason），多族活跃（scope 角标 + ambient 色块 + numericText），
    /// door/wiper/sunroofShade/fragrance 缺 cell → normal 占位（验收 10 族常驻骨架 + 炸场视觉）。
    static func forcedScenarioCells(_ state: DemoVisualState) -> [DemoVehicleStateCell] {
        let s = sample(for: state)
        return [
            // 受 forced 态的 ac（主 cell temp_setpoint + power，态色/icon/reason 展示）
            DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: s.value, revision: 2, visualState: state),
            DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 2, visualState: state),
            // 多族活跃：座椅(默认主驾 dim 角标) / 车窗(非默认副驾显式) / 氛围灯(红色色块炸场) / 屏幕 / 音量
            DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "2", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "60", revision: 1, visualState: .changing),
            DemoVehicleStateCell(key: "ambient.color", actualValue: "红色", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "screen.brightness[中控屏]", actualValue: "80", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "volume.level", actualValue: "30", revision: 1, visualState: .satisfied),
        ]
    }

    static func forcedReason(forKey key: String, state: DemoVisualState) -> String? {
        ScopedStateKey(key).base == "ac.temp_setpoint" ? sample(for: state).reason : nil
    }
}

/// force-state 满屏 10 族 grid（5-gate 验收主屏）。
struct ForcedStateScreen: View {
    let state: DemoVisualState
    var body: some View {
        ZStack {
            DeepSpaceBackground()
            VStack(alignment: .leading, spacing: 12) {
                Text("force-state · \(state.rawValue)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DesignTokens.inkDim)
                VehicleCardsGrid(displays: VehicleCardDisplay.familyDisplays(
                    from: DebugVisualState.forcedScenarioCells(state),
                    reasons: { DebugVisualState.forcedReason(forKey: $0, state: state) }
                ))
            }
            .padding(20)
        }
    }
}

/// 7 态 gallery（内循环快速核，非 5-gate）：每态单卡，display-ready 值。
struct DemoVisualStateGallery: View {
    private var displays: [VehicleCardDisplay] {
        let displayValue: [DemoVisualState: String] = [
            .normal: "26℃", .satisfied: "26℃", .changing: "调节中…",
            .blocked_with_alternative: "18℃", .blocked_hard: "26℃",
            .unsafe: "26℃", .unknown: "—",
        ]
        return DebugVisualState.samples.map { s in
            VehicleCardDisplay(
                id: "gallery.\(s.state.rawValue)",
                title: "空调",
                valueText: displayValue[s.state] ?? "—",
                scopeBadge: ScopeBadge(text: "主驾", style: .dim),
                visualState: s.state,
                revision: 1,
                accessibilityKey: "gallery.\(s.state.rawValue)",
                reason: s.reason,
                familyCardID: .ac,
                badgeStyle: .plain
            )
        }
    }

    var body: some View {
        ZStack {
            DeepSpaceBackground()
            // P2-2（Task5 审计）：VehicleCardsGrid 已自带 ScrollView，外层不再套 ScrollView（防嵌套滚动冲突）
            VStack(alignment: .leading, spacing: 14) {
                Text("DemoVisualState 7 态 gallery（DEBUG 内循环，非 5-gate）")
                    .font(.headline)
                    .foregroundStyle(DesignTokens.inkPrimary)
                VehicleCardsGrid(displays: displays)
            }
            .padding(24)
        }
        .frame(minWidth: 760, minHeight: 560)
    }
}

#Preview("7 态 gallery") { DemoVisualStateGallery() }
#Preview("force unsafe") { ForcedStateScreen(state: .unsafe) }
#endif
