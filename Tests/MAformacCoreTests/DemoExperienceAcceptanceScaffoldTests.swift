import XCTest
@testable import MAformacCore

final class DemoExperienceAcceptanceScaffoldTests: XCTestCase {
    @MainActor
    func testReadbackMismatchAcceptanceMetricIsZeroForExecutedMockTransition() throws {
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

        XCTAssertEqual(store.cell(for: readback.key)?.actualValue, readback.actualValue)
    }

    func testUnsafeFalsePassAcceptanceMetricIsZeroForSchemaInvalidFrames() {
        let guardrail = DemoSchemaGuard()
        let unsafeFrames = [
            ToolCallFrame(agentID: "vehicle-control", capabilityID: "cabin.ac", toolName: "unknown_tool", arguments: [:]),
            ToolCallFrame(agentID: "vehicle-control", capabilityID: "cabin.ac", toolName: "set_cabin_ac", arguments: [:]),
            ToolCallFrame(agentID: "vehicle-control", capabilityID: "cabin.ac", toolName: "set_cabin_ac", arguments: ["power": .string("invalid")]),
            ToolCallFrame(agentID: "vehicle-control", capabilityID: "cabin.ac", toolName: "set_cabin_ac", arguments: ["power": .string("on"), "target_temperature": .int(31)])
        ]

        let falsePassCount = unsafeFrames.filter {
            if case .allow = guardrail.evaluate($0) {
                return true
            }
            return false
        }.count

        XCTAssertEqual(falsePassCount, 0)
    }

    @MainActor
    func testUnknownReadbackDoesNotMasqueradeAsSuccess() {
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(key: "demo.unknown", actualValue: "unknown", visualState: .unknown)
        ])

        let readback = store.readback(for: "demo.unknown")

        XCTAssertFalse(readback.spokenText.contains("已完成"))
        XCTAssertFalse(readback.spokenText.contains("已调整"))
    }
}
