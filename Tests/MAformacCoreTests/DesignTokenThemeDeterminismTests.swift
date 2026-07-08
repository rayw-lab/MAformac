import XCTest
@testable import MAformacCore

/// TX1 —— stateColor 主题确定性回归（T1 对抗审 P1：Asset colorset 依赖环境 colorScheme，
/// 与 D0G-017「ivory 强制不跟系统」冲突）。
///
/// App `DesignTokens.stateColor(for:theme:)` 已改为从 `DesignTokenValues.token(for:theme:).border`
/// 取色（纯值，按 theme 参数 keyed，env 无关），不再走 `Color(name:bundle:)` 的环境解析。
/// App 层不在 swift test，故此处锁其**派生源**的主题确定性：ivory 下不得渗入 deepSpace 值。
final class DesignTokenThemeDeterminismTests: XCTestCase {

    /// 主题相关态（灰阶随主题变）：ivory 与 deepSpace 的强调色必须不同 —— 证明 theme 参数真正驱动取色。
    func testThemeVaryingStatesResolveDistinctColorsPerTheme() {
        for state in [DemoVisualState.normal, .blocked_hard, .unknown] {
            let ivory = DesignTokenValues.token(for: state, theme: .ivory).border
            let deep = DesignTokenValues.token(for: state, theme: .deepSpace).border
            XCTAssertNotEqual(ivory, deep, "\(state) 强调色须随 theme 变（证明按 theme 参数解析）")
        }
    }

    /// 🔴 核心回归：theme=ivory 时，取到的必须是 ivory-keyed 值，**deepSpace colorset/色不得渗入**。
    func testIvoryThemeDoesNotBleedDeepSpaceColor() {
        // unsupported 灰：ivory=inkDim2 0x8A909A / deepSpace=0x5F6A8C
        let unsupportedIvory = DesignTokenValues.token(for: .blocked_hard, theme: .ivory).border
        XCTAssertEqual(unsupportedIvory, TokenRGB(hex24: 0x8A909A), "ivory 下须取 ivory 灰")
        XCTAssertNotEqual(unsupportedIvory, TokenRGB(hex24: 0x5F6A8C), "ivory 下不得渗入 deepSpace 灰")
        // crash 灰：ivory=inkDim 0x5D6470 / deepSpace=0x7C87A8
        let crashIvory = DesignTokenValues.token(for: .unknown, theme: .ivory).border
        XCTAssertEqual(crashIvory, TokenRGB(hex24: 0x5D6470))
        XCTAssertNotEqual(crashIvory, TokenRGB(hex24: 0x7C87A8), "ivory 下不得渗入 deepSpace crash 灰")
    }

    /// 主题无关的语义色（红/琥珀/青）两主题一致 —— 确保修复不误伤共享强调色。
    func testChromaticStatesThemeInvariant() {
        for state in [DemoVisualState.satisfied, .changing, .blocked_with_alternative, .unsafe] {
            let ivory = DesignTokenValues.token(for: state, theme: .ivory).border
            let deep = DesignTokenValues.token(for: state, theme: .deepSpace).border
            XCTAssertEqual(ivory, deep, "\(state) 语义强调色两主题一致（红/琥珀/青不随主题变）")
        }
    }

    /// 纯函数确定性：同 (state,theme) 多次调用结果一致（无 env / 无隐藏状态）。
    func testResolutionIsPureAndDeterministic() {
        for theme in TokenThemeID.allCases {
            for state in DemoVisualState.allCases {
                let a = DesignTokenValues.token(for: state, theme: theme).border
                let b = DesignTokenValues.token(for: state, theme: theme).border
                XCTAssertEqual(a, b, "\(state)/\(theme) 取色须确定性（env 无关）")
            }
        }
    }
}
