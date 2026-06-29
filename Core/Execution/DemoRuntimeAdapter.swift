import Foundation

public enum DemoRuntimeAdapterError: Error, Equatable {
    case unsupportedTool(String)
    case missingArgument(String)
    case missingStateCell(String)
    case idempotencyConflict(commandID: String)
    case readbackReconciliationFailed(commandID: String, key: String, expected: String, actual: String)
    case durableLedgerCorrupt(commandID: String)
    case durableLedgerWriteFailed(commandID: String)
}

public enum DemoRuntimeAdapterProvenance: String, Codable, Equatable, Sendable {
    case firstExecution = "first_execution"
    case retryReplay = "retry_replay"
    case alreadyStateNoop = "already_state_noop"
}

public enum DemoRuntimeAdapterFailureKind: String, Codable, Equatable, Sendable {
    case retryableFailure = "retryable_failure"
    case terminalFailure = "terminal_failure"
    case conflict
    case corruptLedgerEntry = "corrupt_ledger_entry"
}

public struct DemoRuntimeAdapterFailureRecord: Codable, Equatable, Sendable {
    public var commandID: String
    public var requestFingerprint: String?
    public var kind: DemoRuntimeAdapterFailureKind
    public var reason: String

    public init(
        commandID: String,
        requestFingerprint: String?,
        kind: DemoRuntimeAdapterFailureKind,
        reason: String
    ) {
        self.commandID = commandID
        self.requestFingerprint = requestFingerprint
        self.kind = kind
        self.reason = reason
    }
}

public struct DemoRuntimeAdapterResult: Codable, Equatable, Sendable {
    public var commandID: String
    public var requestFingerprint: String
    public var readback: DemoActionReadback
    public var provenance: DemoRuntimeAdapterProvenance

    public init(
        commandID: String,
        requestFingerprint: String,
        readback: DemoActionReadback,
        provenance: DemoRuntimeAdapterProvenance
    ) {
        self.commandID = commandID
        self.requestFingerprint = requestFingerprint
        self.readback = readback
        self.provenance = provenance
    }
}

struct DemoRuntimeAdapterSuccessRecord: Codable, Equatable, Sendable {
    var requestFingerprint: String
    var readback: DemoActionReadback
}

struct DemoRuntimeAdapterLedgerSnapshot: Codable, Equatable, Sendable {
    static let currentSchemaVersion = "r5.d18.local_durable_adapter_ledger.v1"

    var schemaVersion: String
    var successLedger: [String: DemoRuntimeAdapterSuccessRecord]
    var failureLedger: [DemoRuntimeAdapterFailureRecord]

    init(
        schemaVersion: String = DemoRuntimeAdapterLedgerSnapshot.currentSchemaVersion,
        successLedger: [String: DemoRuntimeAdapterSuccessRecord] = [:],
        failureLedger: [DemoRuntimeAdapterFailureRecord] = []
    ) {
        self.schemaVersion = schemaVersion
        self.successLedger = successLedger
        self.failureLedger = failureLedger
    }
}

enum DemoRuntimeAdapterLedgerStoreError: Error, Equatable {
    case unsupportedSchema(String)
    case unknownKey(String)
}

protocol DemoRuntimeAdapterLedgerStore: Sendable {
    func load() throws -> DemoRuntimeAdapterLedgerSnapshot
    func save(_ snapshot: DemoRuntimeAdapterLedgerSnapshot) throws
}

struct FileBackedDemoRuntimeAdapterLedgerStore: DemoRuntimeAdapterLedgerStore {
    let fileURL: URL

    init(directory: URL, fileName: String = "demo-runtime-adapter-ledger.json") {
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    func load() throws -> DemoRuntimeAdapterLedgerSnapshot {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return DemoRuntimeAdapterLedgerSnapshot()
        }
        let data = try Data(contentsOf: fileURL)
        try validateKnownKeys(in: data)
        let snapshot = try JSONDecoder().decode(DemoRuntimeAdapterLedgerSnapshot.self, from: data)
        guard snapshot.schemaVersion == DemoRuntimeAdapterLedgerSnapshot.currentSchemaVersion else {
            throw DemoRuntimeAdapterLedgerStoreError.unsupportedSchema(snapshot.schemaVersion)
        }
        return snapshot
    }

    func save(_ snapshot: DemoRuntimeAdapterLedgerSnapshot) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(snapshot)
        try data.write(to: fileURL, options: [.atomic])
    }

    private func validateKnownKeys(in data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data)
        guard let root = json as? [String: Any] else {
            throw DemoRuntimeAdapterLedgerStoreError.unknownKey("root")
        }
        try validate(keys: root.keys, allowed: ["schemaVersion", "successLedger", "failureLedger"], context: "root")

        if let successLedger = root["successLedger"] as? [String: Any] {
            for (commandID, value) in successLedger {
                guard let entry = value as? [String: Any] else {
                    throw DemoRuntimeAdapterLedgerStoreError.unknownKey("successLedger.\(commandID)")
                }
                try validate(keys: entry.keys, allowed: ["requestFingerprint", "readback"], context: "successLedger.\(commandID)")
                guard let readback = entry["readback"] as? [String: Any] else {
                    throw DemoRuntimeAdapterLedgerStoreError.unknownKey("successLedger.\(commandID).readback")
                }
                try validate(
                    keys: readback.keys,
                    allowed: ["key", "actualValue", "revision", "spokenText", "scopeOrigin"],
                    context: "successLedger.\(commandID).readback"
                )
            }
        }

        if let failureLedger = root["failureLedger"] as? [[String: Any]] {
            for (index, failure) in failureLedger.enumerated() {
                try validate(
                    keys: failure.keys,
                    allowed: ["commandID", "requestFingerprint", "kind", "reason"],
                    context: "failureLedger[\(index)]"
                )
            }
        }
    }

    private func validate(keys: Dictionary<String, Any>.Keys, allowed: Set<String>, context: String) throws {
        for key in keys where !allowed.contains(key) {
            throw DemoRuntimeAdapterLedgerStoreError.unknownKey("\(context).\(key)")
        }
    }
}

@MainActor
public final class DemoRuntimeAdapter {
    private let ledgerStore: DemoRuntimeAdapterLedgerStore?
    private var ledgerLoadError: Error?
    private var ledger: [String: DemoRuntimeAdapterSuccessRecord] = [:]
    private(set) var failureLedger: [DemoRuntimeAdapterFailureRecord] = []

    public init() {
        self.ledgerStore = nil
    }

    init(ledgerStore: DemoRuntimeAdapterLedgerStore) {
        self.ledgerStore = ledgerStore
        do {
            let snapshot = try ledgerStore.load()
            self.ledger = snapshot.successLedger
            self.failureLedger = snapshot.failureLedger
        } catch {
            self.ledgerLoadError = error
        }
    }

    public func execute(
        commandID: String,
        frame: ToolCallFrame,
        store: DemoVehicleStateStore
    ) throws -> DemoRuntimeAdapterResult {
        if ledgerLoadError != nil {
            recordFailure(
                commandID: commandID,
                fingerprint: nil,
                kind: .corruptLedgerEntry,
                reason: "durable_ledger_corrupt"
            )
            throw DemoRuntimeAdapterError.durableLedgerCorrupt(commandID: commandID)
        }

        let plannedTransition: DemoMockTransition
        do {
            plannedTransition = try transition(from: frame)
        } catch let error as DemoRuntimeAdapterError {
            recordFailure(commandID: commandID, fingerprint: nil, kind: .terminalFailure, reason: "\(error)")
            throw error
        }
        let fingerprint = requestFingerprint(toolName: frame.toolName, transition: plannedTransition)

        if let existing = ledger[commandID] {
            guard existing.requestFingerprint == fingerprint else {
                recordFailure(
                    commandID: commandID,
                    fingerprint: fingerprint,
                    kind: .conflict,
                    reason: "idempotency_conflict"
                )
                throw DemoRuntimeAdapterError.idempotencyConflict(commandID: commandID)
            }
            return try replayExisting(commandID: commandID, fingerprint: fingerprint, existing: existing, store: store)
        }

        guard let current = store.cell(for: plannedTransition.key) else {
            recordFailure(
                commandID: commandID,
                fingerprint: fingerprint,
                kind: .retryableFailure,
                reason: "missing_state_cell:\(plannedTransition.key)"
            )
            throw DemoRuntimeAdapterError.missingStateCell(plannedTransition.key)
        }

        let provenance: DemoRuntimeAdapterProvenance = current.actualValue == plannedTransition.desiredValue
            ? .alreadyStateNoop
            : .firstExecution
        let readback = store.applyMockTransition(plannedTransition)
        guard let verified = store.cell(for: plannedTransition.key), verified.actualValue == plannedTransition.desiredValue else {
            let actual = store.cell(for: plannedTransition.key)?.actualValue ?? "missing"
            recordFailure(
                commandID: commandID,
                fingerprint: fingerprint,
                kind: .retryableFailure,
                reason: "readback_reconciliation_failed:\(plannedTransition.key)"
            )
            throw DemoRuntimeAdapterError.readbackReconciliationFailed(
                commandID: commandID,
                key: plannedTransition.key,
                expected: plannedTransition.desiredValue,
                actual: actual
            )
        }
        ledger[commandID] = DemoRuntimeAdapterSuccessRecord(requestFingerprint: fingerprint, readback: readback)
        do {
            try persistSnapshot()
        } catch {
            recordFailure(
                commandID: commandID,
                fingerprint: fingerprint,
                kind: .retryableFailure,
                reason: "durable_ledger_write_failed"
            )
            throw DemoRuntimeAdapterError.durableLedgerWriteFailed(commandID: commandID)
        }

        return DemoRuntimeAdapterResult(
            commandID: commandID,
            requestFingerprint: fingerprint,
            readback: readback,
            provenance: provenance
        )
    }

    public func replayIfSettled(
        commandID: String,
        frame: ToolCallFrame,
        store: DemoVehicleStateStore
    ) throws -> DemoRuntimeAdapterResult? {
        if ledgerLoadError != nil {
            recordFailure(
                commandID: commandID,
                fingerprint: nil,
                kind: .corruptLedgerEntry,
                reason: "durable_ledger_corrupt"
            )
            throw DemoRuntimeAdapterError.durableLedgerCorrupt(commandID: commandID)
        }

        let transition = try transition(from: frame)
        let fingerprint = requestFingerprint(toolName: frame.toolName, transition: transition)
        guard let existing = ledger[commandID], existing.requestFingerprint == fingerprint else {
            return nil
        }
        return try replayExisting(commandID: commandID, fingerprint: fingerprint, existing: existing, store: store)
    }

    private func transition(from frame: ToolCallFrame) throws -> DemoMockTransition {
        guard frame.toolName == "set_vehicle_control" else {
            throw DemoRuntimeAdapterError.unsupportedTool(frame.toolName)
        }
        guard let key = frame.arguments["state_key"] else {
            throw DemoRuntimeAdapterError.missingArgument("state_key")
        }
        guard let desiredValue = frame.arguments["target_state"] else {
            throw DemoRuntimeAdapterError.missingArgument("target_state")
        }
        return DemoMockTransition(key: key, desiredValue: desiredValue)
    }

    private func requestFingerprint(toolName: String, transition: DemoMockTransition) -> String {
        [
            "tool=\(toolName)",
            "state_key=\(transition.key)",
            "target_state=\(transition.desiredValue)",
            "source=\(transition.source.rawValue)"
        ].joined(separator: "\u{1F}")
    }

    private func replayExisting(
        commandID: String,
        fingerprint: String,
        existing: DemoRuntimeAdapterSuccessRecord,
        store: DemoVehicleStateStore
    ) throws -> DemoRuntimeAdapterResult {
        guard let current = store.cell(for: existing.readback.key) else {
            recordFailure(
                commandID: commandID,
                fingerprint: fingerprint,
                kind: .retryableFailure,
                reason: "replay_readback_missing:\(existing.readback.key)"
            )
            throw DemoRuntimeAdapterError.readbackReconciliationFailed(
                commandID: commandID,
                key: existing.readback.key,
                expected: existing.readback.actualValue,
                actual: "missing"
            )
        }
        guard current.actualValue == existing.readback.actualValue else {
            recordFailure(
                commandID: commandID,
                fingerprint: fingerprint,
                kind: .retryableFailure,
                reason: "replay_readback_drift:\(existing.readback.key)"
            )
            throw DemoRuntimeAdapterError.readbackReconciliationFailed(
                commandID: commandID,
                key: existing.readback.key,
                expected: existing.readback.actualValue,
                actual: current.actualValue
            )
        }
        return DemoRuntimeAdapterResult(
            commandID: commandID,
            requestFingerprint: fingerprint,
            readback: DemoActionReadback(
                key: current.key,
                actualValue: current.actualValue,
                revision: current.revision,
                spokenText: DemoVehicleStateStore.spokenText(for: current)
            ),
            provenance: .retryReplay
        )
    }

    private func recordFailure(
        commandID: String,
        fingerprint: String?,
        kind: DemoRuntimeAdapterFailureKind,
        reason: String
    ) {
        failureLedger.append(DemoRuntimeAdapterFailureRecord(
            commandID: commandID,
            requestFingerprint: fingerprint,
            kind: kind,
            reason: reason
        ))
        guard ledgerLoadError == nil else {
            return
        }
        try? persistSnapshot()
    }

    private func persistSnapshot() throws {
        guard let ledgerStore else {
            return
        }
        try ledgerStore.save(DemoRuntimeAdapterLedgerSnapshot(
            successLedger: ledger,
            failureLedger: failureLedger
        ))
    }
}
