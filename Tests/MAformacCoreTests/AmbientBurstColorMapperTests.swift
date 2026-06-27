import XCTest
@testable import MAformacCore

final class AmbientBurstColorMapperTests: XCTestCase {
    func testEightAmbientColorsHaveBurstGradientMixes() {
        let expected: [String: [String]] = [
            "紫色": ["紫色", "黄色"],
            "红色": ["红色", "橙色"],
            "青色": ["青色", "紫色"],
            "绿色": ["绿色", "青色"],
            "蓝色": ["蓝色", "青色"],
            "白色": ["白色", "黄色"],
            "橙色": ["橙色", "黄色"],
            "黄色": ["黄色", "橙色"]
        ]

        for (color, gradient) in expected {
            XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: color), gradient)
        }
    }

    func testCanonicalAmbientPickerOptionsStayOnEightContractColors() {
        XCTAssertEqual(AmbientBurstColorMapper.canonicalColorOptions, ["白", "红", "橙", "黄", "绿", "青", "蓝", "紫"])

        for color in AmbientBurstColorMapper.canonicalColorOptions {
            XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: color).count, 2)
        }
    }

    func testAmbientColorAliasesNormalizeToTokenNames() {
        XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: "紫"), ["紫色", "黄色"])
        XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: "白"), ["白色", "黄色"])
        XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: "冰蓝"), ["青色", "紫色"])
        XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: "暖白"), ["紫色", "黄色"])
    }

    func testAmbientColorDeltaTriggersBurstOnlyForAmbientColor() {
        XCTAssertEqual(
            AmbientBurstTriggerPolicy.triggerColor(key: "ambient.color", previousValue: "白色", nextValue: "紫色"),
            "紫色"
        )
        XCTAssertEqual(
            AmbientBurstTriggerPolicy.triggerColor(key: "ambient.color[面发光氛围灯]", previousValue: nil, nextValue: "蓝色"),
            "蓝色"
        )
        XCTAssertNil(
            AmbientBurstTriggerPolicy.triggerColor(key: "ambient.brightness[面发光氛围灯]", previousValue: "40", nextValue: "70")
        )
    }

    func testAmbientColorAliasesDoNotFalseTriggerWhenNormalizedValueIsSame() {
        XCTAssertNil(
            AmbientBurstTriggerPolicy.triggerColor(key: "ambient.color", previousValue: "紫", nextValue: "紫色")
        )
        XCTAssertNil(
            AmbientBurstTriggerPolicy.triggerColor(key: "ambient.color", previousValue: "浅蓝紫", nextValue: "浅蓝紫色")
        )
    }
}
