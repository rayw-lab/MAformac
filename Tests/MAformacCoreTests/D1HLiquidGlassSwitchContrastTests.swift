import XCTest
@testable import MAformacCore

final class D1HLiquidGlassSwitchContrastTests: XCTestCase {
    private let badSampleEnvKey = "D1H_L2_CONTRAST_FORCE_BAD_SAMPLE"

    func testL2ContrastStaysGreenAcrossThreeSwitchCombinations() {
        let forceBadSample = ProcessInfo.processInfo.environment[badSampleEnvKey] == "1"

        for combination in D1HAccessibilitySwitchCombination.allCases {
            for theme in TokenThemeID.allCases {
                for state in DemoVisualState.allCases {
                    let base = DesignTokenValues.token(for: state, theme: theme)
                    let token = combination.requiresReducedVariant ? base.reducedVariant(on: theme) : base
                    let background = token.effectiveBackground(on: theme)
                    let ink = forceBadSample && combination == .allOn && state == .unsafe
                        ? background
                        : theme.inkPrimary
                    let ratio = ink.contrastRatio(against: background)

                    XCTAssertGreaterThanOrEqual(
                        ratio,
                        DesignTokenValues.bodyTextMinContrast,
                        "L2 contrast failed: combination=\(combination.id) theme=\(theme.rawValue) state=\(state.rawValue) ratio=\(String(format: "%.2f", ratio))"
                    )

                    if combination.reduceMotion {
                        XCTAssertFalse(token.isLoopAnimation, "reduceMotion combination must stop loop animation: \(combination.id)/\(state.rawValue)")
                    }
                    if combination.reduceTransparency {
                        XCTAssertEqual(token.backgroundAlpha, 1.0, "reduceTransparency combination must solidify background: \(combination.id)/\(state.rawValue)")
                    }
                    if combination.increaseContrast {
                        let borderRatio = theme.inkPrimary.contrastRatio(against: token.effectiveBorder(on: theme))
                        XCTAssertGreaterThanOrEqual(
                            max(ratio, borderRatio),
                            DesignTokenValues.bodyTextMinContrast,
                            "increaseContrast combination must keep at least one strong foreground/background edge"
                        )
                    }
                }
            }
        }
    }

    func testL2ContrastGateRejectsInjectedBadCombination() {
        let failures = D1HAccessibilitySwitchCombination.failuresWithInjectedBadSample()

        XCTAssertTrue(
            failures.contains { $0.contains("combination=reduceTransparency+increaseContrast+reduceMotion") && $0.contains("state=unsafe") },
            "Injected bad L2 contrast sample must be caught"
        )
    }
}

private struct D1HAccessibilitySwitchCombination: Equatable {
    let reduceTransparency: Bool
    let increaseContrast: Bool
    let reduceMotion: Bool

    var requiresReducedVariant: Bool {
        reduceTransparency || reduceMotion
    }

    var id: String {
        var parts: [String] = []
        if reduceTransparency { parts.append("reduceTransparency") }
        if increaseContrast { parts.append("increaseContrast") }
        if reduceMotion { parts.append("reduceMotion") }
        return parts.isEmpty ? "default" : parts.joined(separator: "+")
    }

    static let allCases: [D1HAccessibilitySwitchCombination] = [
        D1HAccessibilitySwitchCombination(reduceTransparency: false, increaseContrast: false, reduceMotion: false),
        D1HAccessibilitySwitchCombination(reduceTransparency: true, increaseContrast: false, reduceMotion: false),
        D1HAccessibilitySwitchCombination(reduceTransparency: false, increaseContrast: true, reduceMotion: false),
        D1HAccessibilitySwitchCombination(reduceTransparency: false, increaseContrast: false, reduceMotion: true),
        D1HAccessibilitySwitchCombination(reduceTransparency: true, increaseContrast: true, reduceMotion: false),
        D1HAccessibilitySwitchCombination(reduceTransparency: true, increaseContrast: false, reduceMotion: true),
        D1HAccessibilitySwitchCombination(reduceTransparency: false, increaseContrast: true, reduceMotion: true),
        allOn
    ]

    static let allOn = D1HAccessibilitySwitchCombination(
        reduceTransparency: true,
        increaseContrast: true,
        reduceMotion: true
    )

    static func failuresWithInjectedBadSample() -> [String] {
        var failures: [String] = []
        for combination in allCases {
            for theme in TokenThemeID.allCases {
                for state in DemoVisualState.allCases {
                    let base = DesignTokenValues.token(for: state, theme: theme)
                    let token = combination.requiresReducedVariant ? base.reducedVariant(on: theme) : base
                    let background = token.effectiveBackground(on: theme)
                    let ink = combination == .allOn && state == .unsafe ? background : theme.inkPrimary
                    let ratio = ink.contrastRatio(against: background)
                    if ratio < DesignTokenValues.bodyTextMinContrast {
                        failures.append("combination=\(combination.id) theme=\(theme.rawValue) state=\(state.rawValue) ratio=\(String(format: "%.2f", ratio))")
                    }
                }
            }
        }
        return failures
    }
}
