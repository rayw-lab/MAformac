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

/// value.type 5 类异构控件 spike（4b Task11，验 Gauge `.accessoryCircular` iOS 真渲染 + Grid 内不冲突）。
/// launch arg `-spikeControls`；simctl 截图过目验环形仪表/容量环渲染（非 watchOS-only 编译错 + 真出环）。
struct ValueControlsSpikeScreen: View {
    var body: some View {
        ZStack {
            DeepSpaceBackground()
            VStack(alignment: .leading, spacing: 20) {
                Text("value.type 5 类控件 spike（4b）")
                    .font(.headline).foregroundStyle(DesignTokens.inkPrimary)
                Grid(alignment: .center, horizontalSpacing: 20, verticalSpacing: 22) {
                    GridRow {
                        spikeCell("dial 空调温度") {
                            ValueControlView(valueType: .dial, numericValue: 24, range: 18...32,
                                             stepCount: 0, displayText: "24℃", isOn: false, badgeStyle: .plain)
                        }
                        spikeCell("percent 车窗") {
                            ValueControlView(valueType: .percent, numericValue: 60, range: 0...100,
                                             stepCount: 0, displayText: "60%", isOn: false, badgeStyle: .plain)
                        }
                        spikeCell("stepper 座椅加热") {
                            ValueControlView(valueType: .stepper, numericValue: 2, range: 0...3,
                                             stepCount: 3, displayText: "2挡", isOn: false, badgeStyle: .plain)
                        }
                    }
                    GridRow {
                        spikeCell("toggle 雨刮") {
                            ValueControlView(valueType: .toggle, numericValue: 0, range: 0...1,
                                             stepCount: 0, displayText: "开", isOn: true, badgeStyle: .plain)
                        }
                        spikeCell("badge 氛围灯") {
                            ValueControlView(valueType: .badge, numericValue: 0, range: 0...1,
                                             stepCount: 0, displayText: "红色", isOn: false, badgeStyle: .colorSwatch("红色"))
                        }
                        spikeCell("badge 按摩模式") {
                            ValueControlView(valueType: .badge, numericValue: 0, range: 0...1,
                                             stepCount: 0, displayText: "波浪模式", isOn: false, badgeStyle: .mode("波浪模式"))
                        }
                    }
                }
            }
            .padding(28)
        }
        .frame(minWidth: 720, minHeight: 460)
    }

    // 泛型 @ViewBuilder（非 AnyView，守 spec R2）：控件 + 标签包一格
    private func spikeCell<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 8) {
            content().frame(width: 88, height: 88)
            Text(label).font(.caption2).foregroundStyle(DesignTokens.inkDim).lineLimit(1)
        }
        .padding(12)
        .background(DesignTokens.inkDim2.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// 座椅 composite 展开卡 spike（4b Task13/12，验触发聚焦展开 device composite + 座椅 5 cell 行分3类 + dim 背景）。
/// launch arg `-spikeExpanded`；simctl 截图过目验展开卡渲染（环形/分段/色块/模式齐 + ultraThinMaterial dim）。
struct ExpandedFamilyCardSpikeScreen: View {
    var body: some View {
        ZStack {
            DeepSpaceBackground()
            // 模拟 grid 底层（虚化）
            VehicleCardsGrid(displays: VehicleCardDisplay.familyDisplays(
                from: [DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "2", revision: 1, visualState: .satisfied)]
            ))
            .padding(20)
            // dim/blur 层 + 展开卡（同 ContentView.expandedOverlay 形态）
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            ExpandedFamilyCard(
                display: ExpandedFamilyDisplay.make(for: .seat, from: [
                    DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "2", revision: 1, visualState: .satisfied),
                    DemoVehicleStateCell(key: "seat.vent_level[主驾]", actualValue: "1", revision: 1, visualState: .satisfied),
                    DemoVehicleStateCell(key: "seat.massage_force", actualValue: "1", revision: 1, visualState: .changing),
                    DemoVehicleStateCell(key: "seat.massage_mode", actualValue: "波浪模式", revision: 1, visualState: .satisfied),
                    DemoVehicleStateCell(key: "seat.backrest_angle[主驾]", actualValue: "50", revision: 1, visualState: .satisfied),
                ]),
                onDismiss: {}
            )
        }
        .frame(minWidth: 720, minHeight: 520)
    }
}

/// 多意图错峰浮现 spike（4c Task14，验 220ms stagger 单点串行错峰）。
/// `-spikeSequencer`；启动后 sequencer 依次浮现 5 族，截图中间态（前几族亮、后面待命 = 错峰进行中非同时炸）。
struct MultiCallSequencerSpikeScreen: View {
    @State private var sequencer = MultiCallSequencer()
    private let order: [FamilyCardID] = [.seat, .ambient, .ac, .screen, .volume]
    private let cellByFamily: [FamilyCardID: DemoVehicleStateCell] = [
        .seat: DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "2", revision: 1, visualState: .satisfied),
        .ambient: DemoVehicleStateCell(key: "ambient.color", actualValue: "红色", revision: 1, visualState: .satisfied),
        .ac: DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1, visualState: .satisfied),
        .screen: DemoVehicleStateCell(key: "screen.brightness[中控屏]", actualValue: "80", revision: 1, visualState: .satisfied),
        .volume: DemoVehicleStateCell(key: "volume.level", actualValue: "30", revision: 1, visualState: .satisfied),
    ]
    private var cells: [DemoVehicleStateCell] {
        sequencer.surfacedFamilies.compactMap { cellByFamily[$0] }
    }
    var body: some View {
        ZStack {
            DeepSpaceBackground()
            VStack(alignment: .leading, spacing: 12) {
                Text("多意图错峰浮现 spike（4c · 220ms stagger 单点串行非同时炸）")
                    .font(.headline).foregroundStyle(DesignTokens.inkPrimary)
                VehicleCardsGrid(displays: VehicleCardDisplay.familyDisplays(from: cells))
            }
            .padding(20)
        }
        .task { await sequencer.surface(order) }
    }
}

#Preview("7 态 gallery") { DemoVisualStateGallery() }
#Preview("force unsafe") { ForcedStateScreen(state: .unsafe) }
#Preview("value 控件 spike") { ValueControlsSpikeScreen() }
#Preview("座椅展开 spike") { ExpandedFamilyCardSpikeScreen() }
#Preview("错峰浮现 spike") { MultiCallSequencerSpikeScreen() }
#endif
