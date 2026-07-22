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
        XCTAssertTrue(keys.contains("ac.mode"))
        XCTAssertTrue(keys.contains("seat.massage_mode"))
        XCTAssertTrue(keys.contains("volume.mode"))
        XCTAssertTrue(keys.contains("wiper.mode"))
        XCTAssertTrue(keys.contains("fragrance.mode"))
        XCTAssertTrue(keys.contains("screen.brightness[中控屏]"))
        XCTAssertTrue(keys.contains("ambient.brightness[面发光氛围灯]"))

        XCTAssertFalse(keys.contains("window.driver"))
        XCTAssertFalse(keys.contains("seat.driver.heat"))
        XCTAssertFalse(keys.contains("seat.driver.ventilation"))
        XCTAssertFalse(keys.contains("screen.brightness"))
        XCTAssertFalse(keys.contains("lighting.ambient"))
        XCTAssertFalse(keys.contains("fan.speed"))
    }

    @MainActor
    func testDefaultCellsDoNotCarryActiveHvacLegacyKeys() {
        let store = DemoVehicleStateStore()
        let keys = store.cells.map(\.key)
        let legacyHVACPrefix = ["hvac", ""].joined(separator: ".")

        XCTAssertFalse(keys.contains { $0.hasPrefix(legacyHVACPrefix) })
    }

    @MainActor
    func testArchivedCapabilityAliasDoesNotReintroduceActiveLegacyState() {
        let store = DemoVehicleStateStore()
        let archivedComfortQueryKey = ["hvac", "temperature"].joined(separator: ".")

        XCTAssertNotNil(store.cell(for: archivedComfortQueryKey))
        XCTAssertFalse(store.cells.contains { $0.key == archivedComfortQueryKey })
        XCTAssertFalse(store.presentationCells.contains { $0.key == archivedComfortQueryKey })
    }

    @MainActor
    func testSuccessfulMockTransitionUsesSatisfiedVisualState() {
        let store = DemoVehicleStateStore()

        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "on"))

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.visualState, .satisfied)
    }

    @MainActor
    func testValueChangeProducesNonNormalVisualState() {
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24")
        ])

        _ = store.applyMockTransition(DemoMockTransition(key: "ac.temp_setpoint[主驾]", desiredValue: "26", source: .user))

        XCTAssertEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.actualValue, "26")
        XCTAssertNotEqual(store.cell(for: "ac.temp_setpoint[主驾]")?.visualState, .normal)
    }

    @MainActor
    func testToggleOffKeepsNormalVisualState() {
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(key: "ac.power", actualValue: "on", visualState: .satisfied)
        ])

        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "off", source: .user))

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertEqual(store.cell(for: "ac.power")?.visualState, .normal)
    }

    @MainActor
    func testContractToggleValuesDriveVisualState() {
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(key: "window.lock", actualValue: "locked", visualState: .normal),
            DemoVehicleStateCell(key: "volume.mute", actualValue: "muted", visualState: .normal)
        ])

        _ = store.applyMockTransition(DemoMockTransition(key: "window.lock", desiredValue: "unlocked", source: .user))
        _ = store.applyMockTransition(DemoMockTransition(key: "volume.mute", desiredValue: "unmuted", source: .user))

        XCTAssertEqual(store.cell(for: "window.lock")?.visualState, .satisfied)
        XCTAssertEqual(store.cell(for: "volume.mute")?.visualState, .satisfied)
    }

    @MainActor
    func testDirectUITransitionReadbackUsesContractOrDisplayText() {
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(key: "ambient.color", actualValue: "白"),
            DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷")
        ])

        let ambient = store.applyMockTransition(DemoMockTransition(key: "ambient.color", desiredValue: "红", source: .user))
        let mode = store.applyMockTransition(DemoMockTransition(key: "ac.mode", desiredValue: "制热", source: .user))

        XCTAssertEqual(ambient.spokenText, "氛围灯颜色红")
        XCTAssertEqual(mode.spokenText, "空调模式制热")
    }

    @MainActor
    func testReplaceCellsSeedsMockPresentationStore() {
        let store = DemoVehicleStateStore()

        store.replaceCells([
            DemoVehicleStateCell(key: "ac.temp_setpoint", actualValue: "26"),
            DemoVehicleStateCell(key: "volume.level", actualValue: "38")
        ])

        XCTAssertEqual(store.presentationCells.map(\.key), ["ac.temp_setpoint", "volume.level"])
        XCTAssertNil(store.cell(for: "ac.power"))
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
        // GOVERNANCE: bypasses NLU by design (not product behavior)
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
