import XCTest
@testable import MAformacCore

final class T7DVisualSwapFeatureTests: XCTestCase {
    func testVisualSwapDefaultsOff() {
        XCTAssertFalse(T7DVisualSwapFeature.isEnabled(arguments: ["app"], environment: [:]))
    }

    func testVisualSwapCanBeEnabledByEnvironmentOrArgument() {
        XCTAssertTrue(T7DVisualSwapFeature.isEnabled(arguments: ["app"], environment: ["UIUE_VISUAL_SWAP": "1"]))
        XCTAssertTrue(T7DVisualSwapFeature.isEnabled(arguments: ["app", "-visualSwap", "true"], environment: [:]))
        XCTAssertTrue(T7DVisualSwapFeature.isEnabled(arguments: ["app", "-enableVisualSwap"], environment: [:]))
    }

    func testVisualSwapExplicitFalseStaysOff() {
        XCTAssertFalse(T7DVisualSwapFeature.isEnabled(arguments: ["app", "-visualSwap", "0"], environment: [:]))
        XCTAssertFalse(T7DVisualSwapFeature.isEnabled(arguments: ["app"], environment: ["UIUE_VISUAL_SWAP": "false"]))
    }
}
