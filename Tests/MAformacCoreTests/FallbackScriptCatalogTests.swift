import XCTest
@testable import MAformacCore

final class FallbackScriptCatalogTests: XCTestCase {
    func testGeneratedCatalogCoversExactTenByFourPairs() {
        XCTAssertEqual(FallbackScriptCatalog.entries.count, 40)
        XCTAssertEqual(Set(FallbackScriptCatalog.entries.map(\.family)).count, 10)
        let keys = FallbackScriptCatalog.entries.compactMap { entry in
            FallbackScriptCatalog.governanceReason(for: entry)
                .map { "\(entry.family.rawValue)|\($0.rawValue)" }
        }
        XCTAssertEqual(Set(keys).count, 40)
        XCTAssertEqual(keys.count, 40)
    }

    func testFamilyAliasesNormalizeThroughGeneratedCatalog() {
        XCTAssertEqual(FallbackScriptCatalog.normalizeFamily("air_conditioner"), .ac)
        XCTAssertEqual(FallbackScriptCatalog.normalizeFamily("ambient_light"), .ambient)
        XCTAssertEqual(FallbackScriptCatalog.normalizeFamily("sunroof_shade"), .sunroofShade)
        XCTAssertNil(FallbackScriptCatalog.normalizeFamily("unknown_family"))
    }

    func testCoreLookupKeepsGovernanceReasonInternalToSafeEntry() throws {
        let entry = FallbackScriptCatalog.entry(
            for: .ac,
            governanceReason: .unmountedNameRejected
        )
        XCTAssertEqual(entry?.safeReasonKind, .capabilityNotMounted)
        XCTAssertFalse((entry?.cellID ?? "").contains("unmounted_name_rejected"))
        XCTAssertEqual(FallbackScriptCatalog.governanceReason(for: try XCTUnwrap(entry)), .unmountedNameRejected)
    }

    func testEncodedCatalogContainsOnlySafeReasonProjection() throws {
        let data = try JSONEncoder().encode(FallbackScriptCatalog.entries)
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(text.contains("safeReasonKind"))
        XCTAssertFalse(text.contains("reasonKind"))
        XCTAssertFalse(text.contains("safety_or_clarify_reject"))
        XCTAssertFalse(text.contains("unmounted_name_rejected"))
        XCTAssertFalse(text.contains("fast_path_no_match_fallback"))
        XCTAssertFalse(text.contains("unknown_no_representative_entry"))
        XCTAssertFalse(text.contains("finiteReason"))
        XCTAssertFalse(text.contains("rawFiniteReason"))
        XCTAssertFalse(text.contains("internalReason"))
    }
}
