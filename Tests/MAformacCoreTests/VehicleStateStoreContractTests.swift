import XCTest
@testable import MAformacCore

final class VehicleStateStoreContractTests: XCTestCase {
    @MainActor
    func testDefaultCellsMatchCapabilityMvpSet() {
        let store = DemoVehicleStateStore()
        let keys = Set(store.cells.map(\.key))

        let legacyMVPKeys: Set<String> = [
            "fan.speed",
            "ac.power",
            "hvac.temperature",
            "lighting.ambient",
            "screen.brightness",
            "seat.driver.heat",
            "seat.driver.ventilation",
            "window.driver"
        ]
        XCTAssertTrue(legacyMVPKeys.isSubset(of: keys))
    }

    @MainActor
    func testPresentationCellsUseScopedC2KeysInsteadOfLegacyDisplayKeys() {
        let store = DemoVehicleStateStore()
        let keys = Set(store.presentationCells.map(\.key))

        XCTAssertTrue(keys.contains("window.position[主驾]"))
        XCTAssertTrue(keys.contains("seat.heat_level[主驾]"))
        XCTAssertTrue(keys.contains("seat.vent_level[主驾]"))
        XCTAssertTrue(keys.contains("ac.fan_speed[主驾]"))
        XCTAssertTrue(keys.contains("screen.brightness[中控屏]"))
        XCTAssertTrue(keys.contains("ambient.brightness[面发光氛围灯]"))

        XCTAssertFalse(keys.contains("window.driver"))
        XCTAssertFalse(keys.contains("seat.driver.heat"))
        XCTAssertFalse(keys.contains("seat.driver.ventilation"))
        XCTAssertFalse(keys.contains("screen.brightness"))
        XCTAssertFalse(keys.contains("lighting.ambient"))
        XCTAssertFalse(keys.contains("fan.speed"))
        XCTAssertFalse(keys.contains("hvac.temperature"))
    }

    @MainActor
    func testSuccessfulMockTransitionUsesSatisfiedVisualState() {
        let store = DemoVehicleStateStore()

        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on"))

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.visualState, .satisfied)
    }

    @MainActor
    func testAlreadyStateMockTransitionReturnsReadbackWithoutBumpingRevision() throws {
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(
                key: "ac.power",
                actualValue: "on",
                desiredValue: "on",
                timestamp: timestamp,
                revision: 7,
                visualState: .satisfied
            )
        ])

        let readback = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on"))
        let cell = try XCTUnwrap(store.cell(for: "ac.power"))

        XCTAssertEqual(readback.actualValue, "on")
        XCTAssertEqual(readback.revision, 7)
        XCTAssertEqual(cell.revision, 7)
        XCTAssertEqual(cell.timestamp, timestamp)
        XCTAssertEqual(cell.visualState, .satisfied)
    }

    @MainActor
    func testDemoActionExecutorOwnsMockStoreWritePath() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_power",
            toolName: "set_vehicle_control",
            arguments: [
                "state_key": "ac.power",
                "target_state": "on",
            ]
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        XCTAssertEqual(readback.key, "ac.power")
        XCTAssertEqual(readback.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, readback.revision)
    }
}
