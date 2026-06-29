import Foundation

public enum DemoRuntimeAdapterError: Error, Equatable {
    case unsupportedTool(String)
    case missingArgument(String)
    case missingStateCell(String)
    case idempotencyConflict(commandID: String)
    case readbackReconciliationFailed(commandID: String, key: String, expected: String, actual: String)
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

@MainActor
public final class DemoRuntimeAdapter {
    private struct LedgerEntry {
        var requestFingerprint: String
        var readback: DemoActionReadback
    }

    private var ledger: [String: LedgerEntry] = [:]
    public private(set) var failureLedger: [DemoRuntimeAdapterFailureRecord] = []

    public init() {}

    public func execute(
        commandID: String,
        frame: ToolCallFrame,
        store: DemoVehicleStateStore
    ) throws -> DemoRuntimeAdapterResult {
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
        ledger[commandID] = LedgerEntry(requestFingerprint: fingerprint, readback: readback)

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
        existing: LedgerEntry,
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
    }
}
