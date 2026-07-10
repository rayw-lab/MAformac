import XCTest
@testable import MAformacCore

final class DemoRuntimeSessionRunnerFallbackTests: XCTestCase {
    func testSafetyFallbackUsesDoorCatalogAndTypedOutcomeSummary() throws {
        let context = FallbackContext.resolve(
            family: .door,
            reasonKind: .safetyOrClarifyReject
        )

        XCTAssertEqual(context.family, .door)
        XCTAssertEqual(context.reasonKind, .safetyOrClarifyReject)
        XCTAssertEqual(context.outcome.resultKind, .refusalSafetyOrPolicy)
        XCTAssertEqual(context.outcome.safeReasonKind, .safetyPolicy)
        XCTAssertEqual(context.runtimeResult, .refusalSafetyOrPolicy)
        XCTAssertEqual(context.dialogText, "行驶中为了安全不能开门；停稳后请再说一次，我先保持车门不变。")
        XCTAssertEqual(context.ttsText, context.dialogText)
        XCTAssertEqual(context.badgeLabel, "安全拦截")
        let encoded = String(decoding: try JSONEncoder().encode(context), as: UTF8.self)
        XCTAssertFalse(encoded.contains("finiteReason"))
        XCTAssertFalse(encoded.contains("model"))
        XCTAssertFalse(encoded.contains("ledger"))
    }

    func testNoRepresentativeFallbackRemainsTypedWithoutInventingFamily() throws {
        let context = FallbackContext.resolve(
            family: nil,
            reasonKind: .unknownNoRepresentativeEntry
        )

        XCTAssertNil(context.family)
        XCTAssertEqual(context.reasonKind, .unknownNoRepresentativeEntry)
        XCTAssertEqual(context.outcome.resultKind, .refusalNoAvailableTool)
        XCTAssertEqual(context.outcome.safeReasonKind, .notAvailableInDemo)
        XCTAssertEqual(context.runtimeResult, .refusalNoAvailableTool)
        XCTAssertEqual(context.dialogText, "这项能力不在本轮演示范围，我先保持原样。")
        XCTAssertEqual(context.ttsText, context.dialogText)
        XCTAssertEqual(context.badgeLabel, "不在范围")
        let encoded = String(decoding: try JSONEncoder().encode(context), as: UTF8.self)
        XCTAssertFalse(encoded.contains("finiteReason"))
        XCTAssertFalse(encoded.contains("raw"))
    }
}
