import XCTest
@testable import MAformacCore

final class DemoActionExecutorTests: XCTestCase {
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
}
