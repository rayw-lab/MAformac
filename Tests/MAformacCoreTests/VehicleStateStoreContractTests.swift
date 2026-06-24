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
}
