import Foundation

/// 视觉 Design Token 语义值层 —— **token = 视觉地板（floor）SSOT**（D0G-018）。
///
/// 🔴 **token=floor 声明（D0G-018）**：本层每个语义 token 是「视觉质量下限」。
/// view 只能【等于或超过】token 声明的质量（对比度 / 色感 / 降级双通道完整性），
/// **SHALL NOT 低于**——view 禁手填 hex，只从此派生（spec ui-presentation R4）。
///
/// 本层是**纯 Swift（无 SwiftUI）**：故 `swift test` 可直接对语义值做 WCAG 对比度断言
/// （D0G-004），不需模拟器 / Xcode app target。`App/DesignTokens.swift` 把这些值映射成
/// SwiftUI `Color`（Xcode app target 与 Core 同模块，无需 import）。
///
/// **主题 FROZEN（SD11/V6，tokens.md §8）**：`ivory`(light) + `deepSpace`(dark) 两套 token，
/// **强制不跟随系统**（D0G-017），手动切换走 320ms crossfade。「dark」不是独立第三主题，
/// 而是 `deepSpace` 的 colorScheme —— 对比度矩阵遍历 `TokenThemeID.allCases`（新增主题自动覆盖）。
///
/// **四态分色 FROZEN（D0G-001，tokens.md §2）**：clarify 琥珀 ≠ unsupported 灰锁 ≠
/// safety 红 ≠ crash 中性灰 —— 四态绝不互相坍缩；**红只给 unsafe**。

/// sRGB 颜色（分量 0…1）+ WCAG 2.2 相对亮度 / 对比度 / 半透明叠加（纯值，可测）。
struct TokenRGB: Equatable {
    let r: Double
    let g: Double
    let b: Double

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    init(hex24: UInt32) {
        self.r = Double((hex24 >> 16) & 0xFF) / 255
        self.g = Double((hex24 >> 8) & 0xFF) / 255
        self.b = Double(hex24 & 0xFF) / 255
    }

    /// WCAG 2.2 相对亮度（sRGB → 线性 → 加权）。
    var relativeLuminance: Double {
        func lin(_ c: Double) -> Double {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }

    /// WCAG 对比度 `(L_lighter + 0.05) / (L_darker + 0.05)`，范围 1…21。
    func contrastRatio(against other: TokenRGB) -> Double {
        let l1 = relativeLuminance
        let l2 = other.relativeLuminance
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// self 以 `alpha` 叠加在 `background` 之上的有效色（半透明背景对比度真值用）。
    func composited(over background: TokenRGB, alpha: Double) -> TokenRGB {
        let a = min(max(alpha, 0), 1)
        return TokenRGB(
            r * a + background.r * (1 - a),
            g * a + background.g * (1 - a),
            b * a + background.b * (1 - a)
        )
    }
}

/// 主题标识（纯值镜像 `App/PresentationTheme`；不含 SwiftUI `ColorScheme`）。
enum TokenThemeID: String, CaseIterable {
    case ivory
    case deepSpace

    var isDark: Bool { self == .deepSpace }

    /// 卡片背景所叠加的基底 surface（半透明 tint 的有效对比度基准）。
    /// 值对齐 `App/DesignTokens.palette(for:).surface`（ivory 0xFFFFFF / deepSpace 0x171A24）。
    var surface: TokenRGB {
        switch self {
        case .ivory: return TokenRGB(hex24: 0xFFFFFF)
        case .deepSpace: return TokenRGB(hex24: 0x171A24)
        }
    }

    /// 卡片主文本 / 主要数值墨色（对齐 `palette.inkPrimary`）。
    var inkPrimary: TokenRGB {
        switch self {
        case .ivory: return TokenRGB(hex24: 0x16181D)
        case .deepSpace: return TokenRGB(hex24: 0xEAF0FF)
        }
    }

    /// 次级墨色（文案 / 副标题；对齐 `palette.inkDim`）。
    var inkDim: TokenRGB {
        switch self {
        case .ivory: return TokenRGB(hex24: 0x5D6470)
        case .deepSpace: return TokenRGB(hex24: 0x7C87A8)
        }
    }
}

/// 七态语义 token —— **三通道（color / icon / 文案）+ 降级变体**（D0G-001/002/003）。
///
/// 双通道保护（D0G-004）：状态语义**不靠色彩单通道**——每个非 `normal` 态同时有
/// `iconSymbol`（图形通道）+ `reason`（文案通道），故色盲 / 低对比 / RM 下仍可辨。
struct SemanticStateToken: Equatable {
    /// tint 原色（未叠加）。
    let backgroundTint: TokenRGB
    /// tint 叠加在 surface 上的 alpha（半透明卡背）。
    let backgroundAlpha: Double
    /// 边框 / 强调原色。
    let border: TokenRGB
    /// 边框 alpha。
    let borderAlpha: Double
    /// SF Symbol 名；`nil` = 无图标（仅 `normal`）。
    let iconSymbol: String?
    /// 文案通道 —— 态默认语义标签（runtime `reason` 可覆盖，但 token 是 floor）。
    let reason: String
    /// 循环动效（呼吸 satisfied / 脉冲 changing）—— RM 时关（D0G-002）。
    let isLoopAnimation: Bool

    /// 有效背景色（tint 以 alpha 叠加在 surface 上）—— WCAG 对比度真值用。
    func effectiveBackground(on theme: TokenThemeID) -> TokenRGB {
        backgroundTint.composited(over: theme.surface, alpha: backgroundAlpha)
    }

    /// 有效边框色（border 以 alpha 叠加在有效背景上）。
    func effectiveBorder(on theme: TokenThemeID) -> TokenRGB {
        border.composited(over: effectiveBackground(on: theme), alpha: borderAlpha)
    }

    /// RM / RT 降级变体（D0G-002 停循环动效保双通道 / D0G-003 内容实心化）。
    ///
    /// **实心化 = 把当前叠加后的有效色烘焙成不透明**（保持外观 / 对比度不变，仅去除对
    /// 半透明合成的依赖，满足 reduce-transparency）；**非**把原 tint 拉到 alpha=1（那会
    /// 在 deepSpace 上让强调色盖过文本，破坏对比度）。同时**关循环动效**、**保 icon+文案双通道**。
    func reducedVariant(on theme: TokenThemeID) -> SemanticStateToken {
        SemanticStateToken(
            backgroundTint: effectiveBackground(on: theme),  // 烘焙有效色
            backgroundAlpha: 1.0,                              // 实心（去半透明）
            border: effectiveBorder(on: theme),
            borderAlpha: 1.0,
            iconSymbol: iconSymbol,                            // 双通道保留
            reason: reason,                                    // 双通道保留
            isLoopAnimation: false                             // 停循环（D0G-002）
        )
    }
}

/// Design Token 语义值 SSOT（七态 × 主题 + WCAG 门限 + 动效常量 + colorset 桥）。
enum DesignTokenValues {
    // MARK: 动效常量（tokens.md §4）

    /// 主题切换 crossfade 时长 —— **320ms**（D0G-017：ivory 默认强制不跟系统 + 手动切换 crossfade）。
    static let themeCrossfadeDuration: TimeInterval = 0.320

    // MARK: WCAG 2.2 对比度门限（D0G-004）

    /// 正文文本最小对比度 4.5:1。
    static let bodyTextMinContrast: Double = 4.5
    /// 大字 / 图形对象最小对比度 3:1。
    static let largeTextMinContrast: Double = 3.0

    // MARK: 七态 × 主题 → 语义 token（穷尽 switch，无 default）

    /// **无 `default` 分支**（spec R1：SHALL NOT default 吞态）——新增 `DemoVisualState`
    /// case 时编译器强制此处补分支（穷尽性即保护）。
    static func token(for state: DemoVisualState, theme: TokenThemeID) -> SemanticStateToken {
        let ivory = (theme == .ivory)
        switch state {
        case .normal:
            // 默认未激活 → surfaceElevated 静默，边框 hairline（装饰性，无强调色）
            return SemanticStateToken(
                backgroundTint: ivory ? TokenRGB(hex24: 0xFAF8F5) : TokenRGB(hex24: 0x1C2130),
                backgroundAlpha: ivory ? 0.72 : 0.36,
                border: ivory ? TokenRGB(hex24: 0x000000) : TokenRGB(hex24: 0x5F6A8C),
                borderAlpha: ivory ? 0.06 : 0.35,
                iconSymbol: nil,
                reason: "",
                isLoopAnimation: false
            )
        case .satisfied:
            // 已满足 → 青辉光呼吸（cyan）
            return SemanticStateToken(
                backgroundTint: TokenRGB(hex24: 0x00E5FF),
                backgroundAlpha: ivory ? 0.12 : 0.14,
                border: TokenRGB(hex24: 0x00E5FF),
                borderAlpha: 1.0,
                iconSymbol: "checkmark.circle.fill",
                reason: "已完成",
                isLoopAnimation: true
            )
        case .changing:
            // 执行中 → cyan 脉冲（区别于 satisfied 稳定呼吸）
            return SemanticStateToken(
                backgroundTint: TokenRGB(hex24: 0x00E5FF),
                backgroundAlpha: ivory ? 0.10 : 0.12,
                border: TokenRGB(hex24: 0x00E5FF),
                borderAlpha: 1.0,
                iconSymbol: "arrow.triangle.2.circlepath",
                reason: "调整中",
                isLoopAnimation: true
            )
        case .blocked_with_alternative:
            // clarify 澄清（卖点）→ 琥珀，**绝非红**（四态分色）
            return SemanticStateToken(
                backgroundTint: TokenRGB(hex24: 0xFFB13C),
                backgroundAlpha: ivory ? 0.12 : 0.14,
                border: TokenRGB(hex24: 0xFFB13C),
                borderAlpha: 1.0,
                iconSymbol: "questionmark.circle.fill",
                reason: "需要确认",
                isLoopAnimation: false
            )
        case .blocked_hard:
            // unsupported 拒识 → 灰锁，**绝非红**（四态分色）
            return SemanticStateToken(
                backgroundTint: ivory ? TokenRGB(hex24: 0x8A909A) : TokenRGB(hex24: 0x5F6A8C),
                backgroundAlpha: ivory ? 0.10 : 0.12,
                border: ivory ? TokenRGB(hex24: 0x8A909A) : TokenRGB(hex24: 0x5F6A8C),
                borderAlpha: 0.50,
                iconSymbol: "lock.fill",
                reason: "暂不支持",
                isLoopAnimation: false
            )
        case .unsafe:
            // safety 安全门 → 警示红（**唯一该用红的态**，D0G-001）
            return SemanticStateToken(
                backgroundTint: TokenRGB(hex24: 0xFF5C6C),
                backgroundAlpha: ivory ? 0.12 : 0.14,
                border: TokenRGB(hex24: 0xFF5C6C),
                borderAlpha: 1.0,
                iconSymbol: "exclamationmark.shield.fill",
                reason: "安全限制",
                isLoopAnimation: false
            )
        case .unknown:
            // crash 真错误 → 中性灰，区别于 unsafe 安全红（四态分色）
            return SemanticStateToken(
                backgroundTint: ivory ? TokenRGB(hex24: 0x5D6470) : TokenRGB(hex24: 0x7C87A8),
                backgroundAlpha: 0.10,
                border: ivory ? TokenRGB(hex24: 0x5D6470) : TokenRGB(hex24: 0x7C87A8),
                borderAlpha: 0.50,
                iconSymbol: "exclamationmark.triangle",
                reason: "出错了",
                isLoopAnimation: false
            )
        }
    }

    // MARK: token enum ↔ Asset Catalog colorset（HA2 P1-1 双向）

    /// 态 → Asset Catalog colorset 名（`App/Assets.xcassets/<name>.colorset`）。
    static func colorsetName(for state: DemoVisualState) -> String {
        switch state {
        case .normal: return "StateNormal"
        case .satisfied: return "StateSatisfied"
        case .changing: return "StateChanging"
        case .blocked_with_alternative: return "StateClarify"
        case .blocked_hard: return "StateUnsupported"
        case .unsafe: return "StateUnsafe"
        case .unknown: return "StateCrash"
        }
    }

    /// colorset 名 → 态（反查；`nil` = 非 token colorset）。
    static func state(forColorsetName name: String) -> DemoVisualState? {
        DemoVisualState.allCases.first { colorsetName(for: $0) == name }
    }
}

extension DemoVisualState: CaseIterable {
    public static var allCases: [DemoVisualState] {
        [.normal, .satisfied, .changing, .blocked_with_alternative, .blocked_hard, .unsafe, .unknown]
    }
}
