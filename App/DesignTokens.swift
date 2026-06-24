import SwiftUI

/// 视觉 Design Tokens — Swift 镜像 `docs/design/tokens.md`（视觉 SSOT 单源）。
///
/// 🔴 view 里禁手填 hex，只从 `DesignTokens.*` 取（spec ui-presentation R4）。
/// 语义分类 FROZEN v1.0（2026-06-24 磊哥审签）；hex 值 DRAFT（实渲微调后冻结，tasks 3.7）。
/// 锁 iOS26/macOS26（App target deployment）：API 直接用，无 `#available` 版本守卫。
enum DesignTokens {
    // MARK: 底色 / 中性（tokens.md §1.1 深空层次）
    static let bgBase = Color(hex24: 0x121212)        // U11 + D2#2 软黑
    static let bgDeepest = Color(hex24: 0x05060C)
    static let inkPrimary = Color(hex24: 0xEAF0FF)
    static let inkDim = Color(hex24: 0x7C87A8)
    static let inkDim2 = Color(hex24: 0x5F6A8C)

    // MARK: 辉光主色（tokens.md §1.2 深空青紫）
    static let glowCyan = Color(hex24: 0x00E5FF)
    static let glowViolet = Color(hex24: 0x7B5CFF)

    // MARK: 功能 / 语义态色（tokens.md §1.3 + §2）
    static let stateOffline = Color(hex24: 0xFFB13C)  // 琥珀 = clarify（非红）
    static let safetyRed = Color(hex24: 0xFF5C6C)     // safety（唯一红）
}

extension Color {
    /// `0xRRGGBB` → `Color`（DesignTokens 内部用；view 别直接调，走 `DesignTokens.X`）。
    init(hex24: UInt32, opacity: Double = 1.0) {
        let r = Double((hex24 >> 16) & 0xFF) / 255
        let g = Double((hex24 >> 8) & 0xFF) / 255
        let b = Double(hex24 & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

/// `DemoVisualState` 7 态视觉外观（spec ui-presentation R1：穷尽 switch + 四态分开）。
///
/// 色彩语义分类 FROZEN（tokens.md §2）：
/// clarify 琥珀 ≠ unsupported 灰锁 ≠ safety 红 ≠ crash 中性灰 —— 四态绝不互相坍缩。
struct CardAppearance: Equatable {
    let background: Color
    let border: Color
    let icon: String?     // SF Symbol；nil = 无图标
    let breathing: Bool   // 呼吸动效（satisfied 稳定已完成）
    let pulsing: Bool     // 脉冲动效（changing 执行中）

    /// 7 态穷尽映射 —— **无 `default` 分支**（spec R1：SHALL NOT default 吞态）。
    /// 新增 `DemoVisualState` case 时编译器强制此处补分支（穷尽性即保护）。
    static func of(_ state: DemoVisualState) -> CardAppearance {
        switch state {
        case .normal:                       // 默认未激活 → 灰蓝静默
            CardAppearance(background: DesignTokens.inkDim2.opacity(0.10),
                           border: DesignTokens.inkDim2.opacity(0.35),
                           icon: nil, breathing: false, pulsing: false)
        case .satisfied:                    // 已满足 → 青辉光呼吸
            CardAppearance(background: DesignTokens.glowCyan.opacity(0.14),
                           border: DesignTokens.glowCyan,
                           icon: "checkmark.circle.fill", breathing: true, pulsing: false)
        case .changing:                     // 执行中 → cyan 脉冲（区别于 satisfied 稳定呼吸）
            CardAppearance(background: DesignTokens.glowCyan.opacity(0.10),
                           border: DesignTokens.glowCyan,
                           icon: "arrow.triangle.2.circlepath", breathing: false, pulsing: true)
        case .blocked_with_alternative:     // clarify 澄清（卖点）→ 琥珀，绝非红
            CardAppearance(background: DesignTokens.stateOffline.opacity(0.14),
                           border: DesignTokens.stateOffline,
                           icon: "questionmark.circle.fill", breathing: false, pulsing: false)
        case .blocked_hard:                 // unsupported 拒识 → 灰锁，绝非红
            CardAppearance(background: DesignTokens.inkDim2.opacity(0.10),
                           border: DesignTokens.inkDim2.opacity(0.50),
                           icon: "lock.fill", breathing: false, pulsing: false)
        case .unsafe:                       // safety 安全门 → 警示红（唯一该用红的态）
            CardAppearance(background: DesignTokens.safetyRed.opacity(0.14),
                           border: DesignTokens.safetyRed,
                           icon: "exclamationmark.shield.fill", breathing: false, pulsing: false)
        case .unknown:                      // crash 真错误 → 中性灰，区别于 unsafe 安全红
            CardAppearance(background: DesignTokens.inkDim.opacity(0.10),
                           border: DesignTokens.inkDim.opacity(0.50),
                           icon: "exclamationmark.triangle", breathing: false, pulsing: false)
        }
    }
}
