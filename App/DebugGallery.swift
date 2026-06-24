#if DEBUG
import SwiftUI

/// DEBUG 截图脚手架（spec ui-presentation §2.5；仅 DEBUG 编译，不进 release）。
///
/// 两层（磊哥拍 ①，false dichotomy 修正后分层）：
/// - **gallery 一屏 7 态**：Phase 3 D7 内循环快速核（色映射颠倒/clarify 渲成红等），`simctl` 截 2 张/端。**不上 5-gate**（缩略失真）。
/// - **force-state 单态满屏**：5-gate 验收用（真实视觉重量/字号/留白）。launch argument 驱动
///   `-forceVisualState <态名>`（如 `xcrun simctl launch <udid> lab.rayw.MAformac.ios -forceVisualState unsafe`）。
///   ⚠️ refinement：原议 URL scheme（`maformac://...`）需 CFBundleURLTypes，`GENERATE_INFOPLIST_FILE=YES` 下难设；launch arg 同目的更简。
enum DebugVisualState {
    /// 从 launch argument 读 force-state；nil = 不强制（走正常 ContentView）。
    static var forced: DemoVisualState? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-forceVisualState"), i + 1 < args.count else { return nil }
        return DemoVisualState(rawValue: args[i + 1])
    }

    /// 7 态样例数据（gallery + force-state 共用）：值 + blocked 态原因文案。
    static let samples: [(state: DemoVisualState, value: String, reason: String?)] = [
        (.normal, "26℃", nil),
        (.satisfied, "26℃", nil),
        (.changing, "调节中…", nil),
        (.blocked_with_alternative, "18℃", "最低18℃，已为您调到18"),   // D8.2 clarify 少用态：值超范围+替代（卡片级非区域；非"主驾还是全车"区域澄清——区域默认主驾不打断）
        (.blocked_hard, "不支持", "后排无独立温控"),                      // unsupported
        (.unsafe, "已拦截", "行驶中禁止开启车门"),                        // safety
        (.unknown, "—", "状态读取失败"),                                 // crash
    ]

    static func sample(for state: DemoVisualState) -> (value: String, reason: String?) {
        let s = samples.first { $0.state == state }
        return (s?.value ?? "—", s?.reason)
    }
}

/// 单态满屏卡（5-gate 用）。
struct ForcedStateScreen: View {
    let state: DemoVisualState
    var body: some View {
        let s = DebugVisualState.sample(for: state)
        ZStack {
            DesignTokens.bgBase.ignoresSafeArea()
            VehicleStateCard(
                cell: DemoVehicleStateCell(key: "ac.temp_setpoint", actualValue: s.value, visualState: state),
                reason: s.reason
            )
            .frame(maxWidth: 360)
            .padding(40)
        }
    }
}

/// 7 态 gallery（内循环，非 5-gate）。
struct DemoVisualStateGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("DemoVisualState 7 态 gallery（DEBUG 内循环，非 5-gate）")
                    .font(.headline)
                    .foregroundStyle(DesignTokens.inkPrimary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], spacing: 12) {
                    ForEach(Array(DebugVisualState.samples.enumerated()), id: \.offset) { _, s in
                        VehicleStateCard(
                            cell: DemoVehicleStateCell(key: "ac.temp_setpoint", actualValue: s.value, visualState: s.state),
                            reason: s.reason
                        )
                    }
                }
            }
            .padding(24)
        }
        .frame(minWidth: 760, minHeight: 560)
        .background(DesignTokens.bgBase)
    }
}

#Preview("7 态 gallery") { DemoVisualStateGallery() }
#Preview("force unsafe") { ForcedStateScreen(state: .unsafe) }
#endif
