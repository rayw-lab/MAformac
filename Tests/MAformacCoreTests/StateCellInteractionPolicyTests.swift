import XCTest
@testable import MAformacCore

@MainActor
final class StateCellInteractionPolicyTests: XCTestCase {
    private let catalog = StateCellPresentationCatalog.load()

    func testProjectionDerivesFamilyPrimaryTypeRangeOptionsAndReadbackFromExistingSources() {
        let cell = DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24")

        let policy = StateCellInteractionPolicyProjector.policy(
            for: cell,
            catalog: catalog,
            proofClass: .simulatorMock
        )

        XCTAssertEqual(policy.stateKey, "ac.temp_setpoint[主驾]")
        XCTAssertEqual(policy.base, "ac.temp_setpoint")
        XCTAssertEqual(policy.scope, "主驾")
        XCTAssertEqual(policy.family, FamilyCardIDMapper.familyCardID(forBase: "ac.temp_setpoint"))
        XCTAssertEqual(policy.primaryCellBase, FamilyPrimaryCellMapper.primaryCellBase(for: .ac))
        XCTAssertTrue(policy.isPrimaryCell)
        XCTAssertEqual(policy.uiValueType, UIValueTypeMapper.mappedUIValueType(forBase: "ac.temp_setpoint"))
        XCTAssertEqual(policy.executionRange, ValueRangeMapper.executionRange(forBase: "ac.temp_setpoint", catalog: catalog))
        XCTAssertEqual(policy.enumOptions, [])
        XCTAssertEqual(policy.gesture, .ring)
        XCTAssertEqual(policy.writebackPath, .expandedFamilyCardToMockStore)
        XCTAssertEqual(policy.proofClass, .simulatorMock)
        XCTAssertEqual(policy.catalogReadback, catalog.renderReadback(stateKey: cell.key, scope: "主驾", value: "24"))
    }

    func testReadOnlyAndProcessCellsDoNotExposeFakeAffordance() {
        for cell in [
            DemoVehicleStateCell(key: "vehicle.gear", actualValue: "D"),
            DemoVehicleStateCell(key: "door.car_door", actualValue: "opening"),
            DemoVehicleStateCell(key: "window.motion", actualValue: "opening")
        ] {
            let policy = StateCellInteractionPolicyProjector.policy(for: cell, catalog: catalog)

            XCTAssertFalse(policy.canWriteBack, "\(cell.key) must remain read-only/process-only")
            XCTAssertEqual(policy.enumOptions, [], "\(cell.key) must not expose fake selectable options")
            XCTAssertEqual(policy.gesture, .none)
            XCTAssertEqual(policy.writebackPath, .none)
        }
    }

    func testRepresentativeControlsWriteThroughMockStoreAndRefreshFamilyReadback() {
        assertWriteback(
            key: "ac.temp_setpoint[主驾]",
            value: "27",
            expectedFamily: .ac,
            expectedGesture: .ring,
            expectedSummaryValue: "27℃"
        )
        assertWriteback(
            key: "window.position[主驾]",
            value: "61",
            expectedFamily: .window,
            expectedGesture: .ring,
            expectedSummaryValue: "61%"
        )
        assertWriteback(
            key: "seat.heat_level[主驾]",
            value: "3",
            expectedFamily: .seat,
            expectedGesture: .stepper,
            expectedSummaryValue: "3挡"
        )
        assertWriteback(
            key: "ac.power",
            value: "on",
            expectedFamily: .ac,
            expectedGesture: .toggle,
            expectedSummaryValue: "开"
        )
        assertWriteback(
            key: "ambient.color",
            value: "冰蓝",
            expectedFamily: .ambient,
            expectedGesture: .badgeOptions,
            expectedSummaryValue: "冰蓝"
        )
    }

    func testAmbientAndWiperActiveCellsAreExplicitlySeparatedFromBaselinePrimary() {
        let ambient = StateCellInteractionPolicyProjector.policy(
            for: DemoVehicleStateCell(key: "ambient.brightness[面发光氛围灯]", actualValue: "63"),
            catalog: catalog
        )
        XCTAssertEqual(ambient.family, .ambient)
        XCTAssertEqual(ambient.primaryCellBase, "ambient.color")
        XCTAssertFalse(ambient.isPrimaryCell)
        XCTAssertTrue(ambient.canWriteBack)

        let wiper = StateCellInteractionPolicyProjector.policy(
            for: DemoVehicleStateCell(key: "wiper.speed", actualValue: "2"),
            catalog: catalog
        )
        XCTAssertEqual(wiper.family, .wiper)
        XCTAssertEqual(wiper.primaryCellBase, "wiper.power")
        XCTAssertFalse(wiper.isPrimaryCell)
        XCTAssertTrue(wiper.canWriteBack)
    }

    func testRingBoundaryDeltaAcrossZeroIsExplicitlyCovered() {
        XCTAssertGreaterThan(
            CircularControlGestureMapper.signedProgressDelta(from: 0.95, to: 0.05),
            0
        )
        XCTAssertLessThan(
            CircularControlGestureMapper.signedProgressDelta(from: 0.05, to: 0.95),
            0
        )
    }

    private func assertWriteback(
        key: String,
        value: String,
        expectedFamily: FamilyCardID,
        expectedGesture: StateCellInteractionGesture,
        expectedSummaryValue: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let store = DemoVehicleStateStore(cells: DemoVehicleStateStore.defaultCells())
        let cell = XCTUnwrapOrFail(store.cell(for: key), file: file, line: line)
        let policy = StateCellInteractionPolicyProjector.policy(
            for: cell,
            catalog: catalog,
            proofClass: .simulatorMock
        )
        XCTAssertEqual(policy.family, expectedFamily, file: file, line: line)
        XCTAssertEqual(policy.gesture, expectedGesture, file: file, line: line)
        XCTAssertTrue(policy.canWriteBack, file: file, line: line)
        XCTAssertEqual(policy.writebackPath, .expandedFamilyCardToMockStore, file: file, line: line)

        let readback = store.applyMockTransition(DemoMockTransition(key: key, desiredValue: value, source: .user))
        XCTAssertEqual(readback.actualValue, value, file: file, line: line)
        XCTAssertFalse(readback.spokenText.isEmpty, file: file, line: line)

        let summary = VehicleCardDisplay.familyDisplays(
            from: store.presentationCells,
            activeCells: [expectedFamily: key],
            catalog: catalog
        )
        let display = XCTUnwrapOrFail(summary.first { $0.familyCardID == expectedFamily }, file: file, line: line)
        XCTAssertEqual(display.valueText, expectedSummaryValue, file: file, line: line)
    }
}

private func XCTUnwrapOrFail<T>(
    _ value: T?,
    file: StaticString = #filePath,
    line: UInt = #line
) -> T {
    switch value {
    case .some(let unwrapped):
        return unwrapped
    case .none:
        XCTFail("expected non-nil value", file: file, line: line)
        fatalError("expected non-nil value")
    }
}
