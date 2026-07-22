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
    func testNewAdapterSessionDoesNotPersistLedger() throws {
        let store = DemoVehicleStateStore()
        let firstSession = DemoRuntimeAdapter()

        _ = try firstSession.execute(commandID: "cmd-session-boundary", frame: frame(key: "ac.power", target: "on"), store: store)

        let secondSession = DemoRuntimeAdapter()
        let result = try secondSession.execute(commandID: "cmd-session-boundary", frame: frame(key: "ac.power", target: "off"), store: store)

        XCTAssertEqual(result.provenance, .firstExecution)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
    }

    @MainActor
    func testDurableLedgerReplaysAcrossNewAdapterWithoutSecondWrite() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        let store = DemoVehicleStateStore()
        let firstAdapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)

        let first = try firstAdapter.execute(
            commandID: "cmd-durable-ac-on",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )
        let cellAfterFirst = try XCTUnwrap(store.cell(for: "ac.power"))

        let reconstructedAdapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)
        let replay = try reconstructedAdapter.execute(
            commandID: "cmd-durable-ac-on",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )
        let cellAfterReplay = try XCTUnwrap(store.cell(for: "ac.power"))

        XCTAssertEqual(first.provenance, .firstExecution)
        XCTAssertEqual(replay.provenance, .retryReplay)
        XCTAssertEqual(replay.readback, first.readback)
        XCTAssertEqual(cellAfterReplay.revision, cellAfterFirst.revision)
        XCTAssertEqual(cellAfterReplay.timestamp, cellAfterFirst.timestamp)
    }

    @MainActor
    func testDurableLedgerFingerprintMismatchFailsClosedAcrossAdapter() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        let store = DemoVehicleStateStore()

        _ = try DemoRuntimeAdapter(ledgerStore: ledgerStore).execute(
            commandID: "cmd-durable-conflict",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )

        let reconstructedAdapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)
        XCTAssertThrowsError(try reconstructedAdapter.execute(
            commandID: "cmd-durable-conflict",
            frame: frame(key: "ac.power", target: "off"),
            store: store
        )) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .idempotencyConflict(commandID: "cmd-durable-conflict"))
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(reconstructedAdapter.failureLedger.last?.kind, .conflict)
    }

    @MainActor
    func testCorruptDurableLedgerFailsClosedWithoutMutation() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("{\"successLedger\":".utf8).write(to: ledgerStore.fileURL)
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)

        XCTAssertThrowsError(try adapter.execute(
            commandID: "cmd-corrupt-ledger",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .durableLedgerCorrupt(commandID: "cmd-corrupt-ledger"))
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertEqual(adapter.failureLedger.last?.kind, .corruptLedgerEntry)
    }

    @MainActor
    func testUnknownDurableLedgerSchemaFailsClosedWithoutMutation() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        let unsupported = DemoRuntimeAdapterLedgerSnapshot(schemaVersion: "unexpected.schema")
        try ledgerStore.save(unsupported)
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)

        XCTAssertThrowsError(try adapter.execute(
            commandID: "cmd-unknown-ledger-schema",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .durableLedgerCorrupt(commandID: "cmd-unknown-ledger-schema"))
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertEqual(adapter.failureLedger.last?.kind, .corruptLedgerEntry)
    }

    @MainActor
    func testUnknownDurableSuccessEntryFieldFailsClosedWithoutMutation() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        let store = DemoVehicleStateStore()

        _ = try DemoRuntimeAdapter(ledgerStore: ledgerStore).execute(
            commandID: "cmd-unknown-success-field",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )
        let cellAfterFirst = try XCTUnwrap(store.cell(for: "ac.power"))
        try mutateLedgerJSON(at: ledgerStore.fileURL) { root in
            var successLedger = root["successLedger"] as? [String: Any] ?? [:]
            var entry = successLedger["cmd-unknown-success-field"] as? [String: Any] ?? [:]
            entry["unknownDurableField"] = "future"
            successLedger["cmd-unknown-success-field"] = entry
            root["successLedger"] = successLedger
        }

        let reconstructedAdapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)
        XCTAssertThrowsError(try reconstructedAdapter.execute(
            commandID: "cmd-unknown-success-field",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .durableLedgerCorrupt(commandID: "cmd-unknown-success-field"))
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, cellAfterFirst.revision)
        XCTAssertEqual(store.cell(for: "ac.power")?.timestamp, cellAfterFirst.timestamp)
        XCTAssertEqual(reconstructedAdapter.failureLedger.last?.kind, .corruptLedgerEntry)
    }

    @MainActor
    func testUnknownDurableReadbackFieldFailsClosedWithoutMutation() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        let store = DemoVehicleStateStore()

        _ = try DemoRuntimeAdapter(ledgerStore: ledgerStore).execute(
            commandID: "cmd-unknown-readback-field",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )
        let cellAfterFirst = try XCTUnwrap(store.cell(for: "ac.power"))
        try mutateLedgerJSON(at: ledgerStore.fileURL) { root in
            var successLedger = root["successLedger"] as? [String: Any] ?? [:]
            var entry = successLedger["cmd-unknown-readback-field"] as? [String: Any] ?? [:]
            var readback = entry["readback"] as? [String: Any] ?? [:]
            readback["unknownReadbackField"] = "future"
            entry["readback"] = readback
            successLedger["cmd-unknown-readback-field"] = entry
            root["successLedger"] = successLedger
        }

        let reconstructedAdapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)
        XCTAssertThrowsError(try reconstructedAdapter.execute(
            commandID: "cmd-unknown-readback-field",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .durableLedgerCorrupt(commandID: "cmd-unknown-readback-field"))
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, cellAfterFirst.revision)
        XCTAssertEqual(store.cell(for: "ac.power")?.timestamp, cellAfterFirst.timestamp)
        XCTAssertEqual(reconstructedAdapter.failureLedger.last?.kind, .corruptLedgerEntry)
    }

    @MainActor
    func testDurableFailureRecordDoesNotCreateSuccessfulReplay() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        let store = DemoVehicleStateStore()
        // GOVERNANCE: bypasses NLU by design (not product behavior)
        let invalid = ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.runtime_adapter",
            toolName: "unsupported_tool",
            arguments: [
                "state_key": "ac.power",
                "target_state": "on"
            ]
        )

        XCTAssertThrowsError(try DemoRuntimeAdapter(ledgerStore: ledgerStore).execute(
            commandID: "cmd-durable-failure",
            frame: invalid,
            store: store
        )) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .unsupportedTool("unsupported_tool"))
        }

        let reconstructedAdapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)
        let result = try reconstructedAdapter.execute(
            commandID: "cmd-durable-failure",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )
        XCTAssertEqual(result.provenance, .firstExecution)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }

    @MainActor
    func testDurableReplayReconcilesCurrentStoreReadback() throws {
        let directory = try temporaryLedgerDirectory()
        let ledgerStore = FileBackedDemoRuntimeAdapterLedgerStore(directory: directory)
        let store = DemoVehicleStateStore()

        _ = try DemoRuntimeAdapter(ledgerStore: ledgerStore).execute(
            commandID: "cmd-durable-readback-drift",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "off"))

        let reconstructedAdapter = DemoRuntimeAdapter(ledgerStore: ledgerStore)
        XCTAssertThrowsError(try reconstructedAdapter.execute(
            commandID: "cmd-durable-readback-drift",
            frame: frame(key: "ac.power", target: "on"),
            store: store
        )) { error in
            XCTAssertEqual(
                error as? DemoRuntimeAdapterError,
                .readbackReconciliationFailed(
                    commandID: "cmd-durable-readback-drift",
                    key: "ac.power",
                    expected: "on",
                    actual: "off"
                )
            )
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertEqual(reconstructedAdapter.failureLedger.last?.kind, .retryableFailure)
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
        XCTAssertEqual(adapter.failureLedger.last?.kind, .conflict)
    }

    @MainActor
    func testFailedCommandDoesNotCreateSuccessfulLedgerEntry() throws {
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter()
        // GOVERNANCE: bypasses NLU by design (not product behavior)
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
        XCTAssertEqual(adapter.failureLedger.last?.kind, .terminalFailure)

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
        XCTAssertEqual(adapter.failureLedger.last?.kind, .retryableFailure)

        let result = try adapter.execute(commandID: "cmd-missing-cell", frame: frame(key: "ac.power", target: "on"), store: store)
        XCTAssertEqual(result.provenance, .firstExecution)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
    }

    @MainActor
    func testRetryReplayReconcilesCurrentStoreReadback() throws {
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter()

        _ = try adapter.execute(commandID: "cmd-readback-drift", frame: frame(key: "ac.power", target: "on"), store: store)
        _ = store.applyMockTransition(DemoMockTransition(key: "ac.power", desiredValue: "off"))

        XCTAssertThrowsError(try adapter.execute(commandID: "cmd-readback-drift", frame: frame(key: "ac.power", target: "on"), store: store)) { error in
            XCTAssertEqual(
                error as? DemoRuntimeAdapterError,
                .readbackReconciliationFailed(commandID: "cmd-readback-drift", key: "ac.power", expected: "on", actual: "off")
            )
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertEqual(adapter.failureLedger.last?.kind, .retryableFailure)
    }

    @MainActor
    func testFailureLedgerRecordsPersistenceFailureInMemory() throws {
        let store = DemoVehicleStateStore()
        let adapter = DemoRuntimeAdapter(ledgerStore: FailingDemoRuntimeAdapterLedgerStore())

        XCTAssertThrowsError(try adapter.execute(commandID: "cmd-ledger-save-fails", frame: frame(key: "ac.power", target: "on"), store: store)) { error in
            XCTAssertEqual(error as? DemoRuntimeAdapterError, .durableLedgerWriteFailed(commandID: "cmd-ledger-save-fails"))
        }

        XCTAssertTrue(adapter.failureLedger.contains { $0.reason == "durable_ledger_write_failed" })
        XCTAssertTrue(adapter.failureLedger.contains { $0.reason == "failure_ledger_write_failed:durable_ledger_write_failed" })
    }

    private func frame(key: String, target: String) -> ToolCallFrame {
        // GOVERNANCE: bypasses NLU by design (not product behavior)
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

    private func temporaryLedgerDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("MAformac-DemoRuntimeAdapterTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func mutateLedgerJSON(at fileURL: URL, mutate: (inout [String: Any]) throws -> Void) throws {
        let data = try Data(contentsOf: fileURL)
        var root = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        try mutate(&root)
        let mutated = try JSONSerialization.data(withJSONObject: root, options: [.sortedKeys])
        try mutated.write(to: fileURL, options: [.atomic])
    }
}

private struct FailingDemoRuntimeAdapterLedgerStore: DemoRuntimeAdapterLedgerStore {
    func load() throws -> DemoRuntimeAdapterLedgerSnapshot {
        DemoRuntimeAdapterLedgerSnapshot()
    }

    func save(_ snapshot: DemoRuntimeAdapterLedgerSnapshot) throws {
        throw DemoRuntimeAdapterLedgerStoreError.unknownKey("forced_save_failure")
    }
}
