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

    /// 纯值主题标识（桥接 Core `DesignTokenValues`，取语义 token / 对比度 / 降级 SSOT）。
    var tokenID: TokenThemeID {
        switch self {
        case .ivory: return .ivory
        case .deepSpace: return .deepSpace
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
/// 🔴 **token = 视觉地板（floor）声明（D0G-018）**：view 只能【等于或超过】token 声明的
/// 视觉质量（对比度 / 色感 / 降级双通道），SHALL NOT 低于——view 禁手填 hex，只从
/// `DesignTokens.*` 取（spec ui-presentation R4）。
/// 语义分类 FROZEN v1.0（2026-06-24 磊哥审签）；hex 值 DRAFT（实渲微调后冻结，tasks 3.7）。
/// 锁 iOS26/macOS26（App target deployment）：API 直接用，无 `#available` 版本守卫。
///
/// **语义值 SSOT 在 Core `DesignTokenValues`**（纯值，无 SwiftUI）：七态 × 主题的
/// 对比度门（D0G-004，`swift test` 可测）、文案通道、RM/RT 降级变体、colorset 桥皆在其中；
/// 本 App 层把纯值映射成 SwiftUI `Color` 渲染（App/Core 同 Xcode 模块，无需 import）。
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

    static func reduceTransparencyBackdropFill(for theme: PresentationTheme) -> Color {
        let palette = palette(for: theme)
        return palette.surface.opacity(theme == .ivory ? 0.96 : 0.94)
    }

    static func reduceTransparencyChromeFill(for theme: PresentationTheme) -> Color {
        let palette = palette(for: theme)
        return palette.surfaceElevated.opacity(theme == .ivory ? 0.98 : 0.96)
    }

    static func reduceTransparencyCardFill(for theme: PresentationTheme) -> Color {
        let palette = palette(for: theme)
        return palette.surfaceElevated
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
    static let semanticWarmGoldGray = Color(hex24: 0xC8B184)
    static let semanticWarmGoldGrayDim = Color(hex24: 0x7D7364)

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

    /// ContextCapsule 的 reduceTransparency 实心 chrome fallback。
    /// token 层只给颜色语义；是否替换 `.glassEffect` 由渲染层结合系统开关决定。
    static func contextCapsuleChromeFill(theme: PresentationTheme, reduceTransparency: Bool) -> Color {
        guard reduceTransparency else { return .clear }
        switch theme {
        case .ivory:
            return palette(for: theme).surfaceElevated.opacity(0.92)
        case .deepSpace:
            return bgDeepest.opacity(0.86)
        }
    }

    static func contextCapsuleChromeStroke(theme: PresentationTheme, reduceTransparency: Bool) -> Color {
        guard reduceTransparency else {
            return Color.white.opacity(theme == .ivory ? 0.16 : 0.12)
        }
        switch theme {
        case .ivory:
            return glowCyan.opacity(0.26)
        case .deepSpace:
            return glowCyan.opacity(0.34)
        }
    }

    // MARK: 动效时长（tokens.md §4）
    static let ambientBurstDuration: TimeInterval = 5.0

    /// 主题切换 crossfade 时长 —— **320ms**（D0G-017：ivory 默认强制不跟系统 + 手动切换 crossfade）。
    /// 单源自 Core `DesignTokenValues`（swift test 锁值）。
    static let themeCrossfadeDuration: TimeInterval = DesignTokenValues.themeCrossfadeDuration

    // MARK: Asset Catalog colorset 桥（HA2 P1-1：token enum ↔ Assets.xcassets colorset 双向）

    /// 态 → Asset Catalog colorset 名（`Assets.xcassets/<name>.colorset`，含 light/dark appearance）。
    /// 单源自 Core `DesignTokenValues.colorsetName`。
    static func stateColorsetName(for state: DemoVisualState) -> String {
        DesignTokenValues.colorsetName(for: state)
    }

    /// 态 → 语义强调 `Color`，**按 `theme` 参数确定性解析**（TX1 修复，T1 对抗审 P1）。
    ///
    /// 🔴 **不走 `Color(name:bundle:)` 解析 Asset colorset**——那依赖【环境 colorScheme】，
    /// 与 D0G-017「ivory 强制不跟系统」冲突：系统处于 dark 时，即便 theme=ivory，环境 colorScheme
    /// 仍可能是 dark → colorset 会渗入 deepSpace(dark) appearance。故本访问器直接从 Core
    /// `DesignTokenValues.token(for:theme:).border`（纯值，按 theme 参数 keyed）取色，**env 无关**。
    /// Asset Catalog colorset 仍作 HA2 P1-1 设计侧产物（名映射见 `stateColorsetName`），运行时不靠它解析。
    static func stateColor(for state: DemoVisualState, theme: PresentationTheme) -> Color {
        Color(token: DesignTokenValues.token(for: state, theme: theme.tokenID).border)
    }
}

extension Color {
    /// `0xRRGGBB` → `Color`（DesignTokens 内部用；view 别直接调，走 `DesignTokens.X`）。
    init(hex24: UInt32, opacity: Double = 1.0) {
        let r = Double((hex24 >> 16) & 0xFF) / 255
        let g = Double((hex24 >> 8) & 0xFF) / 255
        let b = Double(hex24 & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    /// Core `TokenRGB`（纯值 SSOT）→ SwiftUI `Color`（env 无关，sRGB 确定性）。
    init(token: TokenRGB, opacity: Double = 1.0) {
        self.init(.sRGB, red: token.r, green: token.g, blue: token.b, opacity: opacity)
    }
}

/// `DemoVisualState` 7 态视觉外观（spec ui-presentation R1：穷尽 switch + 四态分开）。
///
/// 色彩语义分类 FROZEN（tokens.md §2）：
/// clarify 琥珀 ≠ unsupported 灰锁 ≠ safety 红 ≠ crash 中性灰 —— 四态绝不互相坍缩。
struct CardAppearance: Equatable {
    let background: Color
    let border: Color
    let icon: String?     // SF Symbol（图形通道）；nil = 无图标（仅 normal）
    let breathing: Bool   // 呼吸动效（satisfied 稳定已完成）
    let pulsing: Bool     // 脉冲动效（changing 执行中）
    /// 文案通道（三通道之一，D0G-001）—— 态默认语义标签；runtime `reason` 可覆盖，token 是 floor。
    /// 默认值保持既有 memberwise init 兼容（工厂内 hex 表达式零改，渲染不回退）。
    var reason: String = ""

    /// RM / RT 降级变体（D0G-002 停循环动效保双通道 / D0G-003 内容实心化）。
    /// 关呼吸/脉冲循环，**保 icon + 文案双通道**（态语义不塌，色盲/低对比可辨）。
    /// 背景实心化（去半透明）由渲染层结合 `reduceTransparency` 应用；本层承诺「无循环 + 双通道」。
    func reducedVariant() -> CardAppearance {
        CardAppearance(background: background, border: border, icon: icon,
                       breathing: false, pulsing: false, reason: reason)
    }

    /// 7 态穷尽映射 —— **无 `default` 分支**（spec R1：SHALL NOT default 吞态）。
    /// 新增 `DemoVisualState` case 时编译器强制此处补分支（穷尽性即保护）。
    /// 文案通道单源自 Core `DesignTokenValues`（态默认文案）。
    static func of(_ state: DemoVisualState) -> CardAppearance {
        var appearance = base(state)
        appearance.reason = DesignTokenValues.token(for: state, theme: .deepSpace).reason
        return appearance
    }

    private static func base(_ state: DemoVisualState) -> CardAppearance {
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
        var appearance = base(state, theme: theme)
        appearance.reason = DesignTokenValues.token(for: state, theme: theme.tokenID).reason
        return appearance
    }

    private static func base(_ state: DemoVisualState, theme: PresentationTheme) -> CardAppearance {
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
