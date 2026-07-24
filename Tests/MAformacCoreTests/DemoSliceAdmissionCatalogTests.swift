import XCTest
@testable import MAformacCore

final class DemoSliceAdmissionCatalogTests: XCTestCase {
    func testCatalogIsTheExactReviewedEntrySet() {
        let catalog = DemoSliceAdmissionCatalog()

        XCTAssertEqual(catalog.entries.map(\.matrixID), [1, 4, 31, 1972, 201, 167])
        XCTAssertEqual(
            catalog.entries.map(\.contractRowID),
            [
                "c1_airControl_000006",
                "c1_airControl_000164",
                "c1_carControl_000021",
                "c1_carControl_001972",
                "c1_carControl_000201",
                "c1_airControl_000167",
            ]
        )
        XCTAssertEqual(
            catalog.entries.map(\.stateBase),
            [
                "ac.power",
                "ac.temp_setpoint",
                "window.position",
                "ambient.power",
                "seat.heat_level",
                "ac.temp_setpoint",
            ]
        )
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
        let twentyTwo = try XCTUnwrap(catalog.admission(for: "空调调到22度"))
        let twentySix = try XCTUnwrap(catalog.admission(for: "空调调到26度"))

        XCTAssertEqual(twentyTwo.entry.matrixID, 4)
        XCTAssertEqual(twentyTwo.frame.value.direct, "22")
        XCTAssertEqual(twentySix.frame.value.direct, "26")
        XCTAssertEqual(catalog.rejection(for: "空调调到17度"), .valueOutOfRange(actual: 17, allowed: 18 ... 32))
        XCTAssertEqual(catalog.rejection(for: "空调调到33度"), .valueOutOfRange(actual: 33, allowed: 18 ... 32))
    }

    func testPhaseTwoAmbientAndPassengerSeatLiteralsAreExact() throws {
        let catalog = DemoSliceAdmissionCatalog()
        let ambient = try XCTUnwrap(catalog.admission(for: "打开氛围灯"))
        let seat = try XCTUnwrap(catalog.admission(for: "打开副驾座椅加热"))

        XCTAssertEqual(ambient.entry.matrixID, 1972)
        XCTAssertEqual(ambient.frame.toolName, "open_atmosphere_lamp")
        XCTAssertEqual(ambient.frame.device, "atmosphere_lamp")
        XCTAssertEqual(ambient.frame.actionPrimitive, "power_on")
        XCTAssertEqual(seat.entry.matrixID, 201)
        XCTAssertEqual(seat.frame.toolName, "open_seat_heat")
        XCTAssertEqual(seat.frame.device, "seat_heat")
        XCTAssertEqual(seat.frame.actionPrimitive, "power_on")
        XCTAssertEqual(seat.frame.slots["position"], "副驾")
    }

    func testDefaultDenyAndClarifyDoNotProduceFrames() {
        let catalog = DemoSliceAdmissionCatalog()

        XCTAssertNil(catalog.admission(for: "打开车窗"))
        XCTAssertEqual(catalog.rejection(for: "打开车窗"), .notInCatalog)
        XCTAssertNil(catalog.admission(for: "空调"))
        XCTAssertEqual(catalog.rejection(for: "空调"), .clarifyMissingSlot)
        XCTAssertNil(catalog.admission(for: "   \n"))
        XCTAssertEqual(catalog.rejection(for: "   \n"), .blank)
        XCTAssertEqual(catalog.rejection(for: "打开空调并调到26度"), .conjunctionOrMultiIntent)
    }

    func testClassify_capabilityVsPoliteCommandDisjoint() {
        let catalog = DemoSliceAdmissionCatalog()
        XCTAssertNotNil(catalog.admission(for: "能调到26度吗"))
        XCTAssertNil(catalog.admission(for: "空调能调到26度吗"))
        guard case .capabilityQuery = catalog.classify(for: "空调能调到26度吗") else {
            return XCTFail("expected capabilityQuery")
        }
    }

    func testRow167_driverHeatTune_isAdmitted() throws {
        let catalog = DemoSliceAdmissionCatalog()
        let admission = try XCTUnwrap(catalog.admission(for: "主驾制热调24度"))

        XCTAssertEqual(admission.entry.matrixID, 167)
        XCTAssertEqual(admission.entry.contractRowID, "c1_airControl_000167")
        XCTAssertEqual(admission.frame.slots["direction"], "主驾")
        XCTAssertEqual(admission.frame.slots["mode"], "制热")
        XCTAssertEqual(admission.frame.slots["adjustment_mode"], "摄氏度")
        XCTAssertEqual(admission.frame.value.direct, "24")
        XCTAssertEqual(admission.frame.value.sourceUnit, .celsius)
    }

    func testS10_matrix4_exactUtterance_directCommand_admitted() throws {
        let catalog = DemoSliceAdmissionCatalog()
        let admission = try XCTUnwrap(catalog.admission(for: "空调调到26度"))

        XCTAssertEqual(admission.entry.matrixID, 4)
        XCTAssertEqual(admission.entry.contractRowID, "c1_airControl_000164")
        XCTAssertEqual(admission.frame.value.direct, "26")
    }

    func testS10_matrix4_exactUtterance_politeQuestion_admitted() throws {
        let catalog = DemoSliceAdmissionCatalog()
        let admission = try XCTUnwrap(catalog.admission(for: "能调到26度吗"))

        XCTAssertEqual(admission.entry.matrixID, 4)
        XCTAssertEqual(admission.entry.contractRowID, "c1_airControl_000164")
        XCTAssertEqual(admission.frame.value.direct, "26")
    }

    func testS10_matrix4_failClosedVariants_rejected() {
        let catalog = DemoSliceAdmissionCatalog()
        let variants = [
            "把空调调到26度",
            "打开空调到26度",
            "请帮我调到26度",
            "调到26度",
        ]
        for variant in variants {
            XCTAssertNil(catalog.admission(for: variant), "Expected '\(variant)' to yield nil admission (fail-closed)")
        }
    }

    func testS10_matrix4_noGlobalQuestionSuffixStrip() {
        let catalog = DemoSliceAdmissionCatalog()
        // Template ("空调调到", false) does not allow question suffix strip.
        // No global suffix strip per DemoSliceAdmissionCatalog.swift:364-365.
        XCTAssertNil(catalog.admission(for: "把空调调到26度吗"))
        XCTAssertNil(catalog.admission(for: "空调调到26度吗"))
    }
    func testCloseACExactSecondaryAdmissionIsTypedAndUnproven() throws {
        let catalog = DemoSliceAdmissionCatalog()
        let admission = try XCTUnwrap(catalog.admission(for: "关闭空调"))
        XCTAssertEqual(admission.entry.subject, .secondaryTool("close_ac"))
        XCTAssertNil(admission.entry.matrixID)
        XCTAssertEqual(admission.frame.toolName, "set_vehicle_control")
        XCTAssertEqual(admission.frame.actionPrimitive, "power_off")
        XCTAssertEqual(admission.frame.value.offset, "off")
        guard case let .object(payload) = admission.frame.rawPayload else {
            return XCTFail("expected structured admission evidence payload")
        }
        XCTAssertEqual(payload["subject_type"], .string("secondary_tool"))
        XCTAssertEqual(payload["subject_id"], .string("close_ac"))
        XCTAssertNil(payload["matrix_id"])
        XCTAssertFalse(payload.keys.contains { $0.contains("subjectType") || $0.contains("subjectID") })
        XCTAssertNil(catalog.admission(for: "请关闭空调"))
        XCTAssertNil(catalog.admission(for: "关闭空调然后打开空调"))
    }

}
