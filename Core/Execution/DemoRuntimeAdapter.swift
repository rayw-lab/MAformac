import Foundation

public enum DemoRuntimeAdapterError: Error, Equatable {
    case unsupportedTool(String)
    case missingArgument(String)
    case missingStateCell(String)
    case idempotencyConflict(commandID: String)
}

public enum DemoRuntimeAdapterProvenance: String, Codable, Equatable, Sendable {
    case firstExecution = "first_execution"
    case retryReplay = "retry_replay"
    case alreadyStateNoop = "already_state_noop"
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

    public init() {}

    public func execute(
        commandID: String,
        frame: ToolCallFrame,
        store: DemoVehicleStateStore
    ) throws -> DemoRuntimeAdapterResult {
        let transition = try transition(from: frame)
        let fingerprint = requestFingerprint(toolName: frame.toolName, transition: transition)

        if let existing = ledger[commandID] {
            guard existing.requestFingerprint == fingerprint else {
                throw DemoRuntimeAdapterError.idempotencyConflict(commandID: commandID)
            }
            return DemoRuntimeAdapterResult(
                commandID: commandID,
                requestFingerprint: fingerprint,
                readback: existing.readback,
                provenance: .retryReplay
            )
        }

        guard let current = store.cell(for: transition.key) else {
            throw DemoRuntimeAdapterError.missingStateCell(transition.key)
        }

        let provenance: DemoRuntimeAdapterProvenance = current.actualValue == transition.desiredValue
            ? .alreadyStateNoop
            : .firstExecution
        let readback = store.applyMockTransition(transition)
        ledger[commandID] = LedgerEntry(requestFingerprint: fingerprint, readback: readback)

        return DemoRuntimeAdapterResult(
            commandID: commandID,
            requestFingerprint: fingerprint,
            readback: readback,
            provenance: provenance
        )
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
}
