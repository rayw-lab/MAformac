import XCTest
@testable import MAformacCore

final class AmbientEdgeBurstBudgetConsumptionTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(at path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    func testAmbientEdgeBurstConsumesEffectiveBudgetForLargeBlurAndShadow() throws {
        let source = try source(at: "App/AmbientEdgeBurst.swift")

        XCTAssertTrue(source.contains("allowLargeBlurAndShadow: effectiveBudget.allowLargeBlurAndShadow"))
        XCTAssertTrue(source.contains("let allowLargeBlurAndShadow = effectiveBudget.allowLargeBlurAndShadow"))
        XCTAssertTrue(source.contains("let primaryShadowRadius = allowLargeBlurAndShadow ? phase.shadowRadius : 0"))
        XCTAssertTrue(source.contains("let secondaryShadowRadius = allowLargeBlurAndShadow ? phase.shadowRadius * 1.55 : 0"))
        XCTAssertTrue(source.contains("let accentBlurRadius = allowLargeBlurAndShadow ? 1.2 : 0"))
        XCTAssertTrue(source.contains("let primaryShadowRadius: CGFloat = allowLargeBlurAndShadow ? 34 : 0"))
        XCTAssertTrue(source.contains("let secondaryShadowRadius: CGFloat = allowLargeBlurAndShadow ? 64 : 0"))
        XCTAssertTrue(source.contains("let accentBlurRadius: CGFloat = allowLargeBlurAndShadow ? 1.8 : 0"))
    }
}
