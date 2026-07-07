import XCTest
@testable import MAformacCore

final class DDomainMountedToolCatalogTests: XCTestCase {
    func testIRMapFingerprintRepresentsFull562RecognitionSurface() {
        XCTAssertEqual(DDomainMountedToolCatalog.irMapFingerprint, DDomainIRMap.irMapCompiledFingerprint)
        XCTAssertEqual(DDomainIRMap.irMapCompiled.count, 562)
        XCTAssertGreaterThan(DDomainIRMap.irMapCompiled.count, DDomainMountedToolCatalog.mountedToolNames.count)
    }

    func testMountedDemoCatalogIsMinimalClaimedRuntimeSurface() {
        XCTAssertEqual(DDomainMountedToolCatalog.mountedToolNames, ["adjust_ac_temperature_to_number"])
        XCTAssertEqual(DDomainMountedToolCatalog.mountedCatalogKind, "mounted_demo_catalog_sha")
    }

    func testMountedCatalogAllNamesResolveToExecutionCell() {
        for name in DDomainMountedToolCatalog.mountedToolNames {
            let irs = ToolContractNormalizer.normalize(
                C6ToolCall(name: name, arguments: ["value": "26"]),
                irMap: DDomainIRMap.irMapCompiled
            )
            XCTAssertFalse(irs.isEmpty, name)
            for ir in irs {
                XCTAssertNotNil(ToolContractStateApplier.deviceCellMap[ir.device], "\(name) resolved to non-executable device \(ir.device)")
            }
        }
    }

    func testMountedCatalogExcludesPersonaAvoidList() {
        XCTAssertTrue(DDomainMountedToolCatalog.mountedToolNames.isDisjoint(with: DDomainMountedToolCatalog.personaAvoidListToolNames))
        XCTAssertTrue(DDomainMountedToolCatalog.personaAvoidListToolNames.contains("raise_ac_temperature_by_exp"))
        XCTAssertTrue(DDomainMountedToolCatalog.personaAvoidListToolNames.contains("lower_ac_temperature_by_exp"))
        XCTAssertTrue(DDomainMountedToolCatalog.personaAvoidListToolNames.contains("lock_ac"))
    }

    func testReceiptArtifactNamesKeepIRMapAndMountedCatalogSeparate() {
        let artifacts = DDomainMountedToolCatalog.receiptArtifacts
        XCTAssertEqual(artifacts.irMapName, "ir_map_fingerprint")
        XCTAssertEqual(artifacts.mountedCatalogName, "mounted_demo_catalog_sha")
        XCTAssertNotEqual(artifacts.irMapFingerprint, artifacts.mountedDemoCatalogSha)
    }
}
