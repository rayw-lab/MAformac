import SwiftUI

enum PresentationTheme: String, CaseIterable, Identifiable {
    case ivory
    case deepSpace

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ivory: return "米白"
        case .deepSpace: return "深空"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .ivory: return .light
        case .deepSpace: return .dark
        }
    }
}

struct ThemePalette {
    var backgroundBase: Color
    var backgroundHaloA: Color
    var backgroundHaloB: Color
    var surface: Color
    var surfaceElevated: Color
    var assistantBubble: Color
    var inkPrimary: Color
    var inkDim: Color
    var inkDim2: Color
    var hairline: Color
    var softShadow: Color
    var userBubbleStart: Color
    var userBubbleEnd: Color
}

/// 视觉 Design Tokens — Swift 镜像 `docs/design/tokens.md`（视觉 SSOT 单源）。
///
/// 🔴 view 里禁手填 hex，只从 `DesignTokens.*` 取（spec ui-presentation R4）。
/// 语义分类 FROZEN v1.0（2026-06-24 磊哥审签）；hex 值 DRAFT（实渲微调后冻结，tasks 3.7）。
/// 锁 iOS26/macOS26（App target deployment）：API 直接用，无 `#available` 版本守卫。
enum DesignTokens {
    static func palette(for theme: PresentationTheme) -> ThemePalette {
        switch theme {
        case .ivory:
            ThemePalette(
                backgroundBase: Color(hex24: 0xF8F4EF),
                backgroundHaloA: Color(hex24: 0xE4F3FF),
                backgroundHaloB: Color(hex24: 0xF3EAFF),
                surface: Color(hex24: 0xFFFFFF),
                surfaceElevated: Color(hex24: 0xFAF8F5),
                assistantBubble: Color(hex24: 0xFFFFFF),
                inkPrimary: Color(hex24: 0x16181D),
                inkDim: Color(hex24: 0x5D6470),
                inkDim2: Color(hex24: 0x8A909A),
                hairline: Color(hex24: 0x000000).opacity(0.06),
                softShadow: Color(hex24: 0x6B7A90),
                userBubbleStart: Color(hex24: 0xEAF0FF),
                userBubbleEnd: Color(hex24: 0xF0EAFE)
            )
        case .deepSpace:
            ThemePalette(
                backgroundBase: bgBase,
                backgroundHaloA: glowCyan,
                backgroundHaloB: glowViolet,
                surface: Color(hex24: 0x171A24),
                surfaceElevated: Color(hex24: 0x1C2130),
                assistantBubble: Color(hex24: 0xFFFFFF).opacity(0.07),
                inkPrimary: inkPrimary,
                inkDim: inkDim,
                inkDim2: inkDim2,
                hairline: inkDim2.opacity(0.35),
                softShadow: Color(hex24: 0x000000),
                userBubbleStart: glowCyan,
                userBubbleEnd: glowViolet
            )
        }
    }

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
    static let semanticCool = Color(hex24: 0x1AA6FF)
    static let semanticCoolBright = Color(hex24: 0x00E5FF)
    static let semanticCoolIce = Color(hex24: 0x9EEFFF)
    static let semanticCoolDeep = Color(hex24: 0x006BFF)
    static let semanticWarm = Color(hex24: 0xFF4D6D)
    static let semanticWarmBright = Color(hex24: 0xFFB13C)
    static let semanticWarmSoft = Color(hex24: 0xFFD1C2)
    static let semanticWarmDeep = Color(hex24: 0xC91E3A)

    // MARK: 氛围灯色板（tokens.md §1.4，ambient.color 炸场色块；view 经此取，禁手填 hex）
    /// `ambient.color` 枚举色名 → 色块 Color（深空暗底上 vivid 高对比）。
    static func ambientColor(named name: String) -> Color {
        switch name {
        case "白", "白色": return Color(hex24: 0xEDEFF5)
        case "红", "红色": return Color(hex24: 0xFF4D6D)
        case "橙", "橙色": return Color(hex24: 0xFFB13C)
        case "黄", "黄色": return Color(hex24: 0xFFD23C)
        case "绿", "绿色": return Color(hex24: 0x3CE0A0)
        case "青", "青色": return Color(hex24: 0x00E5FF)
        case "蓝", "蓝色": return Color(hex24: 0x1AA6FF)
        case "紫", "紫色": return Color(hex24: 0x7B5CFF)
        case "浅蓝紫", "浅蓝紫色": return Color(hex24: 0x5F75FF)
        case "粉", "粉色": return Color(hex24: 0xFF7AC6)
        default: return Color(hex24: 0x7B5CFF)  // 回落 glow.violet
        }
    }

    static func ambientGradient(named name: String) -> [Color] {
        AmbientBurstColorMapper.burstGradient(for: name).map { ambientColor(named: $0) }
    }

    static func thermalAccent(for tint: ThermalTint) -> Color {
        switch tint {
        case .cooling: return semanticCool
        case .heating: return semanticWarm
        case .neutral: return glowCyan
        }
    }

    static func thermalGradient(for tint: ThermalTint) -> [Color] {
        switch tint {
        case .cooling: return [semanticCoolIce, semanticCoolBright, semanticCool, semanticCoolDeep]
        case .heating: return [semanticWarmSoft, semanticWarm, semanticWarmDeep]
        case .neutral: return [semanticCool, semanticWarm]
        }
    }

    // MARK: 动效时长（tokens.md §4）
    static let ambientBurstDuration: TimeInterval = 5.0
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

    static func of(_ state: DemoVisualState, theme: PresentationTheme) -> CardAppearance {
        let palette = DesignTokens.palette(for: theme)
        switch state {
        case .normal:
            return CardAppearance(background: palette.surfaceElevated.opacity(theme == .ivory ? 0.72 : 0.36),
                                  border: palette.hairline,
                                  icon: nil, breathing: false, pulsing: false)
        case .satisfied:
            return CardAppearance(background: DesignTokens.glowCyan.opacity(theme == .ivory ? 0.12 : 0.14),
                                  border: DesignTokens.glowCyan,
                                  icon: "checkmark.circle.fill", breathing: true, pulsing: false)
        case .changing:
            return CardAppearance(background: DesignTokens.glowCyan.opacity(theme == .ivory ? 0.10 : 0.12),
                                  border: DesignTokens.glowCyan,
                                  icon: "arrow.triangle.2.circlepath", breathing: false, pulsing: true)
        case .blocked_with_alternative:
            return CardAppearance(background: DesignTokens.stateOffline.opacity(theme == .ivory ? 0.12 : 0.14),
                                  border: DesignTokens.stateOffline,
                                  icon: "questionmark.circle.fill", breathing: false, pulsing: false)
        case .blocked_hard:
            return CardAppearance(background: palette.inkDim2.opacity(theme == .ivory ? 0.10 : 0.12),
                                  border: palette.inkDim2.opacity(0.50),
                                  icon: "lock.fill", breathing: false, pulsing: false)
        case .unsafe:
            return CardAppearance(background: DesignTokens.safetyRed.opacity(theme == .ivory ? 0.12 : 0.14),
                                  border: DesignTokens.safetyRed,
                                  icon: "exclamationmark.shield.fill", breathing: false, pulsing: false)
        case .unknown:
            return CardAppearance(background: palette.inkDim.opacity(0.10),
                                  border: palette.inkDim.opacity(0.50),
                                  icon: "exclamationmark.triangle", breathing: false, pulsing: false)
        }
    }
}
