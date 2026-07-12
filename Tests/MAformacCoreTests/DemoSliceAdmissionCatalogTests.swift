import XCTest
@testable import MAformacCore

final class DemoSliceAdmissionCatalogTests: XCTestCase {
    func testCatalogIsTheExactTwoEntryRatifiedSet() {
        let catalog = DemoSliceAdmissionCatalog()

        XCTAssertEqual(catalog.entries.map(\.matrixID), [1, 4])
        XCTAssertEqual(
            catalog.entries.map(\.contractRowID),
            ["c1_airControl_000006", "c1_airControl_000164"]
        )
        XCTAssertEqual(catalog.entries.map(\.stateBase), ["ac.power", "ac.temp_setpoint"])
        XCTAssertEqual(catalog.routeMode, "demo_slice")
        XCTAssertFalse(catalog.catalogDigestSHA256.isEmpty)
    }

    func testOpenACIsAdmittedAsMatrixOne() throws {
        let admission = try XCTUnwrap(DemoSliceAdmissionCatalog().admission(for: "打开空调"))

        XCTAssertEqual(admission.entry.matrixID, 1)
        XCTAssertEqual(admission.entry.contractRowID, "c1_airControl_000006")
        XCTAssertEqual(admission.frame.device, "ac")
        XCTAssertEqual(admission.frame.actionPrimitive, "power_on")
        XCTAssertEqual(admission.frame.value.offset, "on")
    }

    func testTemperatureValueIsParsedFromInputAndBoundedByStateCellRange() throws {
        let catalog = DemoSliceAdmissionCatalog()
        let twentyTwo = try XCTUnwrap(catalog.admission(for: "把空调调到22度"))
        let twentySix = try XCTUnwrap(catalog.admission(for: "空调调到26度"))

        XCTAssertEqual(twentyTwo.entry.matrixID, 4)
        XCTAssertEqual(twentyTwo.frame.value.direct, "22")
        XCTAssertEqual(twentySix.frame.value.direct, "26")
        XCTAssertEqual(catalog.rejection(for: "空调调到17度"), .valueOutOfRange(actual: 17, allowed: 18 ... 32))
        XCTAssertEqual(catalog.rejection(for: "空调调到33度"), .valueOutOfRange(actual: 33, allowed: 18 ... 32))
    }

    func testDefaultDenyAndClarifyDoNotProduceFrames() {
        let catalog = DemoSliceAdmissionCatalog()

        XCTAssertNil(catalog.admission(for: "打开车窗"))
        XCTAssertEqual(catalog.rejection(for: "打开车窗"), .notInCatalog)
        XCTAssertNil(catalog.admission(for: "空调"))
        XCTAssertEqual(catalog.rejection(for: "空调"), .clarifyMissingSlot)
        XCTAssertNil(catalog.admission(for: "   \n"))
        XCTAssertEqual(catalog.rejection(for: "   \n"), .blank)
    }
}
