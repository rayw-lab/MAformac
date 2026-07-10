import XCTest
@testable import MAformacCore

final class FallbackScriptCatalogTests: XCTestCase {
    func testGeneratedCatalogCoversExactTenByFourPairs() {
        XCTAssertEqual(FallbackScriptCatalog.entries.count, 40)
        XCTAssertEqual(Set(FallbackScriptCatalog.entries.map(\.family)).count, 10)
        XCTAssertEqual(Set(FallbackScriptCatalog.entries.map(\.reasonKind)).count, 4)
        XCTAssertEqual(Set(FallbackScriptCatalog.entries.map { "\($0.family.rawValue)|\($0.reasonKind.rawValue)" }).count, 40)
    }

    func testFamilyAliasesNormalizeThroughGeneratedCatalog() {
        XCTAssertEqual(FallbackScriptCatalog.normalizeFamily("air_conditioner"), .ac)
        XCTAssertEqual(FallbackScriptCatalog.normalizeFamily("ambient_light"), .ambient)
        XCTAssertEqual(FallbackScriptCatalog.normalizeFamily("sunroof_shade"), .sunroofShade)
        XCTAssertNil(FallbackScriptCatalog.normalizeFamily("unknown_family"))
    }

    func testEncodedCatalogContainsOnlySafeReasonProjection() throws {
        let data = try JSONEncoder().encode(FallbackScriptCatalog.entries)
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(text.contains("safeReasonKind"))
        XCTAssertFalse(text.contains("finiteReason"))
        XCTAssertFalse(text.contains("rawFiniteReason"))
        XCTAssertFalse(text.contains("internalReason"))
    }
}
