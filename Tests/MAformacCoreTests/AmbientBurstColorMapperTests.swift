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

    func testAmbientColorAliasesNormalizeToTokenNames() {
        XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: "紫"), ["紫色", "黄色"])
        XCTAssertEqual(AmbientBurstColorMapper.burstGradient(for: "白"), ["白色", "黄色"])
    }
}
