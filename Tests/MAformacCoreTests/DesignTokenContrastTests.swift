import XCTest
@testable import MAformacCore

/// D1a T1 —— Design Token 语义值层单测（D0G-001/002/003/004/017/018）。
///
/// token 语义值放 Core（纯值，无 SwiftUI），故 `swift test` 可直接做 WCAG 对比度断言，
/// 不需模拟器 / Xcode app target。App/DesignTokens.swift 映射成 SwiftUI Color（同 Xcode 模块）。
///
/// **主题矩阵口径（回溯 SSOT）**：dispatch 措辞「ivory/dark/deepSpace 三主题」，但冻结 SSOT
/// （SD11/V6，tokens.md §8）= ivory(light) + deepSpace(dark) **两套 token**；「dark」是 deepSpace
/// 的 colorScheme 非独立第三主题。本矩阵遍历 `TokenThemeID.allCases`（新增主题自动覆盖）。
final class DesignTokenContrastTests: XCTestCase {

    private let allStates = DemoVisualState.allCases
    private let allThemes = TokenThemeID.allCases

    // MARK: D0G-001 —— 七态穷尽 + 三通道（color / icon / 文案）

    func testAllSevenStatesResolveAcrossThemes() {
        XCTAssertEqual(allStates.count, 7, "七态必须恰好 7 个")
        for theme in allThemes {
            for state in allStates {
                _ = DesignTokenValues.token(for: state, theme: theme)  // 穷尽 switch，不 crash
            }
        }
    }

    func testDualChannelForActiveStates() {
        // D0G-004：非 normal 态语义不靠色彩单通道 —— icon（图形）+ reason（文案）双通道齐备。
        for theme in allThemes {
            for state in allStates where state != .normal {
                let t = DesignTokenValues.token(for: state, theme: theme)
                XCTAssertNotNil(t.iconSymbol, "\(state) 须有 icon 通道")
                XCTAssertFalse(t.reason.isEmpty, "\(state) 须有文案通道")
            }
            // normal 无 icon（baseline，靠 fill/shadow 区分）
            XCTAssertNil(DesignTokenValues.token(for: .normal, theme: theme).iconSymbol)
        }
    }

    // MARK: D0G-004 —— L2 contrast 断言（正文 4.5:1）

    func testBodyTextContrastMeetsWCAGAcrossMatrix() {
        // 卡片主文本 / 主数值（inkPrimary）叠加在有效卡背上须 ≥ 4.5:1（七态 × 主题矩阵）。
        for theme in allThemes {
            let ink = theme.inkPrimary
            for state in allStates {
                let t = DesignTokenValues.token(for: state, theme: theme)
                let bg = t.effectiveBackground(on: theme)
                let ratio = ink.contrastRatio(against: bg)
                XCTAssertGreaterThanOrEqual(
                    ratio, DesignTokenValues.bodyTextMinContrast,
                    "正文对比度不足: state=\(state) theme=\(theme) ratio=\(String(format: "%.2f", ratio))"
                )
            }
        }
    }

    func testWCAGContrastMathKnownValues() {
        // 黑白极值 = 21:1（WCAG 上限），锚定对比度公式正确性。
        let black = TokenRGB(0, 0, 0)
        let white = TokenRGB(1, 1, 1)
        XCTAssertEqual(black.contrastRatio(against: white), 21.0, accuracy: 0.01)
        // 同色 = 1:1
        XCTAssertEqual(white.contrastRatio(against: white), 1.0, accuracy: 0.001)
    }

    // MARK: D0G-001 —— 红只给 unsafe + 四态分色

    func testRedOnlyForUnsafeAndFourStateDistinction() {
        let red = TokenRGB(hex24: 0xFF5C6C)
        for theme in allThemes {
            let unsafe = DesignTokenValues.token(for: .unsafe, theme: theme).border
            let clarify = DesignTokenValues.token(for: .blocked_with_alternative, theme: theme).border
            let unsupported = DesignTokenValues.token(for: .blocked_hard, theme: theme).border
            let crash = DesignTokenValues.token(for: .unknown, theme: theme).border
            // 红只给 unsafe
            XCTAssertEqual(unsafe, red, "unsafe 须用 safety 红")
            XCTAssertNotEqual(clarify, red, "clarify 琥珀 ≠ 红")
            XCTAssertNotEqual(unsupported, red, "unsupported 灰 ≠ 红")
            XCTAssertNotEqual(crash, red, "crash 灰 ≠ 红")
            // 四态两两分明（clarify 琥珀 / unsupported 灰 / unsafe 红 / crash 灰 不坍缩）
            XCTAssertNotEqual(clarify, unsupported, "clarify ≠ unsupported")
            XCTAssertNotEqual(clarify, unsafe, "clarify ≠ unsafe")
            // unsupported 与 crash 都用灰但取不同灰阶（inkDim2 vs inkDim），避免同灰坍缩
            XCTAssertNotEqual(unsupported, crash, "unsupported 灰 ≠ crash 灰（不同灰阶）")
        }
    }

    // MARK: D0G-002/003 —— RM/RT 降级变体

    func testReducedVariantSolidifiesStopsLoopKeepsDualChannel() {
        for theme in allThemes {
            for state in allStates where state != .normal {
                let base = DesignTokenValues.token(for: state, theme: theme)
                let reduced = base.reducedVariant(on: theme)
                // D0G-003 实心化：alpha=1（去半透明）
                XCTAssertEqual(reduced.backgroundAlpha, 1.0, "\(state) RT 须实心化")
                // 实心化保持有效外观（对比度不变）：烘焙色 == 原有效背景
                XCTAssertEqual(reduced.effectiveBackground(on: theme), base.effectiveBackground(on: theme),
                               "\(state) 实心化不得改变有效背景色")
                // D0G-002 停循环动效
                XCTAssertFalse(reduced.isLoopAnimation, "\(state) RM 须停循环动效")
                // 双通道保留（不塌）
                XCTAssertEqual(reduced.iconSymbol, base.iconSymbol)
                XCTAssertEqual(reduced.reason, base.reason)
                // 实心化后正文对比度仍达标
                let ratio = theme.inkPrimary.contrastRatio(against: reduced.effectiveBackground(on: theme))
                XCTAssertGreaterThanOrEqual(ratio, DesignTokenValues.bodyTextMinContrast,
                    "\(state) 实心化后正文对比度不足: \(String(format: "%.2f", ratio))")
            }
        }
    }

    func testLoopAnimationOnlyForSatisfiedAndChanging() {
        for theme in allThemes {
            for state in allStates {
                let loop = DesignTokenValues.token(for: state, theme: theme).isLoopAnimation
                let expected = (state == .satisfied || state == .changing)
                XCTAssertEqual(loop, expected, "\(state) 循环动效位不符（仅 satisfied 呼吸 / changing 脉冲）")
            }
        }
    }

    // MARK: D0G-017 —— 主题切换 320ms crossfade

    func testThemeCrossfadeDurationIs320ms() {
        XCTAssertEqual(DesignTokenValues.themeCrossfadeDuration, 0.320, accuracy: 0.0001)
    }

    // MARK: HA2 P1-1 —— colorset 双向映射

    func testColorsetBidirectionalMapping() {
        var names = Set<String>()
        for state in allStates {
            let name = DesignTokenValues.colorsetName(for: state)
            XCTAssertFalse(name.isEmpty)
            names.insert(name)
            // 反查回原态
            XCTAssertEqual(DesignTokenValues.state(forColorsetName: name), state,
                           "colorset 反查须回原态: \(name)")
        }
        XCTAssertEqual(names.count, 7, "7 态须 7 个不撞的 colorset 名")
        XCTAssertNil(DesignTokenValues.state(forColorsetName: "NonExistentColorset"))
    }
}
