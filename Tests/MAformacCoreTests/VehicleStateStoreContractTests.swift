import XCTest
@testable import MAformacCore

final class VehicleStateStoreContractTests: XCTestCase {
    @MainActor
    func testDefaultCellsMatchCapabilityMvpSet() {
        let store = DemoVehicleStateStore()
        let keys = Set(store.cells.map(\.key))

        XCTAssertEqual(keys, [
            "fan.speed",
            "hvac.ac",
            "hvac.temperature",
            "lighting.ambient",
            "screen.brightness",
            "seat.driver.heat",
            "seat.driver.ventilation",
            "window.driver"
        ])
    }

    @MainActor
    func testSuccessfulMockTransitionUsesSatisfiedVisualState() {
        let store = DemoVehicleStateStore()

        _ = store.applyMockTransition(DemoMockTransition(key: "hvac.ac", desiredValue: "on"))

        XCTAssertEqual(store.cell(for: "hvac.ac")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "hvac.ac")?.visualState, .satisfied)
    }
}
