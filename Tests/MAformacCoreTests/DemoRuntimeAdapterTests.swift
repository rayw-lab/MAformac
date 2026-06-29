import XCTest
@testable import MAformacCore

final class DemoRuntimeAdapterTests: XCTestCase {
    @MainActor
    func testFirstExecutionWritesThroughAdapterOwnedMockPath() throws {
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter()

        let result = try adapter.execute(
            commandID: "cmd-ac-on",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )

        XCTAssertEqual(result.provenance, .firstExecution)
        XCTAssertEqual(result.readback.key, "ac.power")
        XCTAssertEqual(result.readback.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, result.readback.revision)
    }

    @MainActor
    func testRetryReplayReturnsReadbackWithoutSecondWrite() throws {
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(key: "ac.power", actualValue: "off", timestamp: timestamp)
        ])
        let adapter = DemoRuntimeAdapter()

        let first = try adapter.execute(commandID: "cmd-ac-on", frame: frame(key: "ac.power", target: "on"), store: store)
        let cellAfterFirst = try XCTUnwrap(store.cell(for: "ac.power"))
        let replay = try adapter.execute(commandID: "cmd-ac-on", frame: frame(key: "ac.power", target: "on"), store: store)
        let cellAfterReplay = try XCTUnwrap(store.cell(for: "ac.power"))

        XCTAssertEqual(first.provenance, .firstExecution)
        XCTAssertEqual(replay.provenance, .retryReplay)
        XCTAssertEqual(replay.readback, first.readback)
        XCTAssertEqual(cellAfterReplay.revision, cellAfterFirst.revision)
        XCTAssertEqual(cellAfterReplay.timestamp, cellAfterFirst.timestamp)
    }

    @MainActor
    func testAlreadyStateReturnsNoopProvenanceWithoutMutation() throws {
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let store = DemoVehicleStateStore(cells: [
            DemoVehicleStateCell(key: "ac.power", actualValue: "on", timestamp: timestamp, revision: 7, visualState: .satisfied)
        ])
        let adapter = DemoRuntimeAdapter()

        let result = try adapter.execute(commandID: "cmd-ac-on", frame: frame(key: "ac.power", target: "on"), store: store)
        let cell = try XCTUnwrap(store.cell(for: "ac.power"))

        XCTAssertEqual(result.provenance, .alreadyStateNoop)
        XCTAssertEqual(result.readback.revision, 7)
        XCTAssertEqual(cell.revision, 7)
        XCTAssertEqual(cell.timestamp, timestamp)
    }

    @MainActor
    func testSameCommandIDWithDifferentRequestFailsClosed() throws {
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter()

        _ = try adapter.execute(commandID: "cmd-ac", frame: frame(key: "ac.power", target: "on"), store: store)

        XCTAssertThrowsError(try adapter.execute(commandID: "cmd-ac", frame: frame(key: "ac.power", target: "off"), store: store)) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .idempotencyConflict(commandID: "cmd-ac"))
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }

    @MainActor
    func testFailedCommandDoesNotCreateSuccessfulLedgerEntry() throws {
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter()
        let invalid = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_power",
            toolName: "unsupported_tool",
            arguments: [
                "state_key": "ac.power",
                "target_state": "on"
            ]
        )

        XCTAssertThrowsError(try adapter.execute(commandID: "cmd-retry-after-fail", frame: invalid, store: store)) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .unsupportedTool("unsupported_tool"))
        }

        let result = try adapter.execute(
            commandID: "cmd-retry-after-fail",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )
        XCTAssertEqual(result.provenance, .firstExecution)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }

    @MainActor
    func testMissingStateCellDoesNotCreateSuccessfulLedgerEntry() throws {
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter()

        XCTAssertThrowsError(try adapter.execute(commandID: "cmd-missing-cell", frame: frame(key: "missing.cell", target: "on"), store: store)) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .missingStateCell("missing.cell"))
        }

        let result = try adapter.execute(commandID: "cmd-missing-cell", frame: frame(key: "ac.power", target: "on"), store: store)
        XCTAssertEqual(result.provenance, .firstExecution)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }

    private func frame(key: String, target: String) -> ToolCallFrame {
        ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.runtime_adapter",
            toolName: "set_vehicle_control",
            arguments: [
                "state_key": key,
                "target_state": target
            ]
        )
    }
}
