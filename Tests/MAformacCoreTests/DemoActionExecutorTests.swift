import XCTest
@testable import MAformacCore

final class DemoActionExecutorTests: XCTestCase {

    // MARK: - Single-cell capabilities

    @MainActor
    func testExecutorUsesGeneratedStateCellForWritableCapabilities() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.fan",
            toolName: "set_cabin_fan",
            arguments: ["level": .int(2)],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        XCTAssertEqual(readback.key, "fan.speed")
        XCTAssertEqual(readback.actualValue, "2")
        XCTAssertEqual(store.cell(for: "fan.speed")?.actualValue, "2")
    }

    @MainActor
    func testExecutorReadsStateWithoutWritingForQueryCapabilities() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.comfort_query",
            toolName: "query_cabin_comfort",
            arguments: ["topic": .string("temperature")],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        XCTAssertEqual(readback.key, "hvac.temperature")
        XCTAssertEqual(readback.actualValue, "24")
        XCTAssertEqual(readback.revision, 0)
        XCTAssertEqual(store.cell(for: "hvac.temperature")?.revision, 0)
    }

    // MARK: - F2: Multi-cell transform tests (AC temperature)

    /// set_cabin_ac(power:on, target_temperature:25) must write BOTH hvac.ac and hvac.temperature.
    @MainActor
    func testACWithTemperatureWritesBothCells() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ac",
            toolName: "set_cabin_ac",
            arguments: ["power": .string("on"), "target_temperature": .int(25)],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        // Primary cell readback
        XCTAssertEqual(readback.key, "hvac.ac")
        XCTAssertEqual(readback.actualValue, "on")

        // Secondary cell must also be written (F2 core bug fix)
        XCTAssertEqual(store.cell(for: "hvac.ac")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "hvac.temperature")?.actualValue, "25",
                       "hvac.temperature must be updated when target_temperature is provided")
    }

    /// set_cabin_ac(power:on) without temperature — hvac.temperature should remain unchanged.
    @MainActor
    func testACPowerOnlyDoesNotModifyTemperatureCell() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ac",
            toolName: "set_cabin_ac",
            arguments: ["power": .string("on")],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        XCTAssertEqual(readback.actualValue, "on")
        // Temperature cell remains at default
        XCTAssertEqual(store.cell(for: "hvac.temperature")?.revision, 0,
                       "hvac.temperature must not be written when target_temperature is absent")
    }

    /// set_cabin_ac(power:unchanged, target_temperature:22) — power:unchanged skips hvac.ac,
    /// but target_temperature still updates hvac.temperature.
    @MainActor
    func testACPowerUnchangedSkipsPrimaryCell() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ac",
            toolName: "set_cabin_ac",
            arguments: ["power": .string("unchanged"), "target_temperature": .int(22)],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        // Primary cell: power:unchanged → skipped → readback returns current value
        XCTAssertEqual(readback.key, "hvac.ac")
        XCTAssertEqual(store.cell(for: "hvac.ac")?.revision, 0,
                       "hvac.ac must NOT be written when power=unchanged")
        // Secondary cell: temperature should be updated
        XCTAssertEqual(store.cell(for: "hvac.temperature")?.actualValue, "22")
    }

    // MARK: - F2 + F3: Ambient light composite semantic

    /// set_cabin_ambient_light(power:on, color:blue) → lighting.ambient = "blue" (∈ allowed_values).
    /// Bug: old executor wrote "on" (∉ allowed_values for lighting.ambient).
    @MainActor
    func testAmbientLightPowerOnWithColorWritesColorValue() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ambient_light",
            toolName: "set_cabin_ambient_light",
            arguments: ["power": .string("on"), "color": .string("blue")],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        XCTAssertEqual(readback.key, "lighting.ambient")
        XCTAssertEqual(readback.actualValue, "blue",
                       "ambient light power:on with color:blue must write 'blue', not 'on'")
        XCTAssertEqual(store.cell(for: "lighting.ambient")?.actualValue, "blue")
    }

    /// set_cabin_ambient_light(power:off) → lighting.ambient = "off" (∈ allowed_values).
    @MainActor
    func testAmbientLightPowerOffWritesOff() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ambient_light",
            toolName: "set_cabin_ambient_light",
            arguments: ["power": .string("off")],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        XCTAssertEqual(readback.actualValue, "off")
        XCTAssertEqual(store.cell(for: "lighting.ambient")?.actualValue, "off")
    }

    /// set_cabin_ambient_light(power:unchanged) → lighting.ambient must NOT be written.
    @MainActor
    func testAmbientLightPowerUnchangedDoesNotWriteCell() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ambient_light",
            toolName: "set_cabin_ambient_light",
            arguments: ["power": .string("unchanged")],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        // No write should occur → revision stays 0, readback returns current state
        XCTAssertEqual(readback.key, "lighting.ambient")
        XCTAssertEqual(store.cell(for: "lighting.ambient")?.revision, 0,
                       "lighting.ambient must NOT be written when power=unchanged")
    }

    // MARK: - Seat heating: position+level multi-required-field

    /// set_cabin_seat_heating(position:driver, level:2) → seat.driver.heat = "2".
    @MainActor
    func testSeatHeatingWritesLevelToStateCell() throws {
        let store = DemoVehicleStateStore()
        let executor = DemoActionExecutor()
        let frame = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.seat_heating",
            toolName: "set_cabin_seat_heating",
            arguments: ["position": .string("driver"), "level": .int(2)],
            surfacePolicy: .primaryPanel
        )

        let readback = try executor.applyMockTransition(frame, store: store)

        XCTAssertEqual(readback.key, "seat.driver.heat")
        XCTAssertEqual(readback.actualValue, "2")
        XCTAssertEqual(store.cell(for: "seat.driver.heat")?.actualValue, "2")
    }
}
