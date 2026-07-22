import Darwin
import Foundation

public enum FrontstageRouteReceiptConfigurationError: Error, Equatable {
    case invalidEmitValue
    case legacyAliasPresent(String)
    case foreignKeyWithoutEmit(String)
    case missingForeignKey(String)
    case invalidRunID
    case invalidRunNonce
    case invalidRunDirectory
    case invalidSourceHeadSHA
}

public enum FrontstageRouteReceiptWriteError: Error, Equatable {
    case appExecutableUnavailable
    case failedToCreateDirectory
    case failedToCreateTemporaryFile
    case failedToReplaceReceipt
    /// B10: durable persist failed. App must not relabel committed mutation as cancelled/rolled back.
    case durableWriteFailed(underlying: String)
}

public struct FrontstageRouteReceiptConfiguration: Equatable {
    public let foreignEmit: Bool
    public let runID: String
    public let runNonce: String
    public let runDirectory: URL
    public let sourceHeadSHA: String?

    public var receiptURL: URL {
        runDirectory
            .appendingPathComponent("receipts", isDirectory: true)
            .appendingPathComponent("c1", isDirectory: true)
            .appendingPathComponent("frontstage-route-receipt.v2.json", isDirectory: false)
    }

    public static func environment(
        _ values: [String: String],
        currentDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    ) throws -> FrontstageRouteReceiptConfiguration {
        let legacyAliases = [
            "FRONTSTAGE_RUN_ID",
            "FRONTSTAGE_RUN_NONCE",
            "FRONTSTAGE_RECEIPT_PATH",
            "C1_FRONTSTAGE_RECEIPT_PATH"
        ]
        if let alias = legacyAliases.first(where: { values[$0] != nil }) {
            throw FrontstageRouteReceiptConfigurationError.legacyAliasPresent(alias)
        }

        let foreignKeys = [
            "C1_FRONTSTAGE_RUN_ID",
            "C1_FRONTSTAGE_RUN_NONCE",
            "C1_RUN_DIR",
            "C1_FRONTSTAGE_SOURCE_HEAD_SHA"
        ]
        guard let emit = values["C1_FRONTSTAGE_RECEIPT_EMIT"] else {
            if let key = foreignKeys.first(where: { values[$0] != nil }) {
                throw FrontstageRouteReceiptConfigurationError.foreignKeyWithoutEmit(key)
            }
            let runID = "local-\(UUID().uuidString.lowercased())"
            let runNonce = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
            let runDirectory = currentDirectory
                .appendingPathComponent(".build", isDirectory: true)
                .appendingPathComponent("c1-run", isDirectory: true)
                .appendingPathComponent(runID, isDirectory: true)
            try ensureWritableDirectory(runDirectory)
            return FrontstageRouteReceiptConfiguration(
                foreignEmit: false,
                runID: runID,
                runNonce: runNonce,
                runDirectory: runDirectory,
                sourceHeadSHA: nil
            )
        }

        guard emit == "1" else {
            throw FrontstageRouteReceiptConfigurationError.invalidEmitValue
        }
        guard let runID = values["C1_FRONTSTAGE_RUN_ID"] else {
            throw FrontstageRouteReceiptConfigurationError.missingForeignKey("C1_FRONTSTAGE_RUN_ID")
        }
        guard let runNonce = values["C1_FRONTSTAGE_RUN_NONCE"] else {
            throw FrontstageRouteReceiptConfigurationError.missingForeignKey("C1_FRONTSTAGE_RUN_NONCE")
        }
        guard let runDirectoryPath = values["C1_RUN_DIR"] else {
            throw FrontstageRouteReceiptConfigurationError.missingForeignKey("C1_RUN_DIR")
        }
        guard let sourceHeadSHA = values["C1_FRONTSTAGE_SOURCE_HEAD_SHA"] else {
            throw FrontstageRouteReceiptConfigurationError.missingForeignKey("C1_FRONTSTAGE_SOURCE_HEAD_SHA")
        }
        guard !runID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw FrontstageRouteReceiptConfigurationError.invalidRunID
        }
        guard isLowerHex(runNonce, length: 32) else {
            throw FrontstageRouteReceiptConfigurationError.invalidRunNonce
        }
        guard runDirectoryPath.hasPrefix("/") else {
            throw FrontstageRouteReceiptConfigurationError.invalidRunDirectory
        }
        guard isLowerHex(sourceHeadSHA, length: 40) else {
            throw FrontstageRouteReceiptConfigurationError.invalidSourceHeadSHA
        }
        let runDirectory = URL(fileURLWithPath: runDirectoryPath, isDirectory: true)
        try ensureWritableDirectory(runDirectory)
        return FrontstageRouteReceiptConfiguration(
            foreignEmit: true,
            runID: runID,
            runNonce: runNonce,
            runDirectory: runDirectory,
            sourceHeadSHA: sourceHeadSHA
        )
    }

    private static func ensureWritableDirectory(_ directory: URL) throws {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw FrontstageRouteReceiptConfigurationError.invalidRunDirectory
        }
        guard FileManager.default.isWritableFile(atPath: directory.path) else {
            throw FrontstageRouteReceiptConfigurationError.invalidRunDirectory
        }
    }

    private static func isLowerHex(_ value: String, length: Int) -> Bool {
        value.range(of: "^[0-9a-f]{\(length)}$", options: .regularExpression) != nil
    }
}

/// Per-action evidence inside unique RuntimeTurnReceipt v2 (B08; no proofClass).
public struct RuntimeTurnActionEvidence: Codable, Equatable, Sendable {
    public let actionIndex: Int
    public let frameIdentity: String?
    public let contractIdentity: String?
    public let toolName: String?
    public let deviceName: String?
    public let actionName: String?
    public let slotsIdentity: String?
    public let disposition: String
    public let failureReason: String?
    public let policyDecision: String?
    public let beforeRevision: Int?
    public let afterRevision: Int?
    public let readback: DemoActionReadback?
    public let replayRef: String?
    /// True when readback key is presentation-virtual (e.g. `presentation.cancel`), not a business cell.
    public let isVirtualReadback: Bool

    enum CodingKeys: String, CodingKey {
        case actionIndex = "action_index"
        case frameIdentity = "frame_identity"
        case contractIdentity = "contract_identity"
        case toolName = "tool_name"
        case deviceName = "device_name"
        case actionName = "action_name"
        case slotsIdentity = "slots_identity"
        case disposition
        case failureReason = "failure_reason"
        case policyDecision = "policy_decision"
        case beforeRevision = "before_revision"
        case afterRevision = "after_revision"
        case readback
        case replayRef = "replay_ref"
        case isVirtualReadback = "is_virtual_readback"
    }

    public init(
        actionIndex: Int,
        frameIdentity: String? = nil,
        contractIdentity: String? = nil,
        toolName: String? = nil,
        deviceName: String? = nil,
        actionName: String? = nil,
        slotsIdentity: String? = nil,
        disposition: String,
        failureReason: String? = nil,
        policyDecision: String? = nil,
        beforeRevision: Int? = nil,
        afterRevision: Int? = nil,
        readback: DemoActionReadback? = nil,
        replayRef: String? = nil,
        isVirtualReadback: Bool = false
    ) {
        self.actionIndex = actionIndex
        self.frameIdentity = frameIdentity
        self.contractIdentity = contractIdentity
        self.toolName = toolName
        self.deviceName = deviceName
        self.actionName = actionName
        self.slotsIdentity = slotsIdentity
        self.disposition = disposition
        self.failureReason = failureReason
        self.policyDecision = policyDecision
        self.beforeRevision = beforeRevision
        self.afterRevision = afterRevision
        self.readback = readback
        self.replayRef = replayRef
        self.isVirtualReadback = isVirtualReadback
    }
}

/// Unique Frontstage RuntimeTurnReceipt v2 (B08 clean-cutover; zero v1 shim; no proofClass).
public struct RuntimeTurnReceipt: Codable, Equatable, Sendable {
    public static let schemaVersionValue = "frontstage_route_receipt.v2"

    public let schemaVersion: String
    public let runID: String
    public let runNonce: String
    public let sourceHeadSHA: String?
    public let testedCheckoutSHA: String?
    public let sessionID: String
    public let turnID: String
    public let eventID: String
    public let sequence: Int
    public let matrixID: Int?
    public let matrixSourceSHA256: String
    public let runtimeContractBundleDigest: String
    public let appExecutableSHA256: String
    public let finalOutcome: DemoRuntimeResult
    public let stateMutation: Bool
    public let readbackCount: Int
    public let mountReceiptBodySHA256: String
    public let codeHeadDigest: String
    public let mountedCatalogDigest: String
    public let touchedCellCanonicalSnapshotDigest: String
    public let linkedPreviousTurnID: String?
    public let actions: [RuntimeTurnActionEvidence]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case runID = "run_id"
        case runNonce = "run_nonce"
        case sourceHeadSHA = "source_head_sha"
        case testedCheckoutSHA = "tested_checkout_sha"
        case sessionID = "session_id"
        case turnID = "turn_id"
        case eventID = "event_id"
        case sequence
        case matrixID = "matrix_id"
        case matrixSourceSHA256 = "matrix_source_sha256"
        case runtimeContractBundleDigest = "runtime_contract_bundle_digest"
        case appExecutableSHA256 = "app_executable_sha256"
        case finalOutcome = "final_outcome"
        case stateMutation = "state_mutation"
        case readbackCount = "readback_count"
        case mountReceiptBodySHA256 = "mount_receipt_body_sha256"
        case codeHeadDigest = "code_head_digest"
        case mountedCatalogDigest = "mounted_catalog_digest"
        case touchedCellCanonicalSnapshotDigest = "touched_cell_canonical_snapshot_digest"
        case linkedPreviousTurnID = "linked_previous_turn_id"
        case actions
    }

    public init(
        schemaVersion: String = RuntimeTurnReceipt.schemaVersionValue,
        runID: String,
        runNonce: String,
        sourceHeadSHA: String?,
        testedCheckoutSHA: String?,
        sessionID: String,
        turnID: String,
        eventID: String,
        sequence: Int,
        matrixID: Int?,
        matrixSourceSHA256: String,
        runtimeContractBundleDigest: String,
        appExecutableSHA256: String,
        finalOutcome: DemoRuntimeResult,
        stateMutation: Bool,
        readbackCount: Int,
        mountReceiptBodySHA256: String,
        codeHeadDigest: String,
        mountedCatalogDigest: String,
        touchedCellCanonicalSnapshotDigest: String,
        linkedPreviousTurnID: String? = nil,
        actions: [RuntimeTurnActionEvidence]
    ) {
        self.schemaVersion = schemaVersion
        self.runID = runID
        self.runNonce = runNonce
        self.sourceHeadSHA = sourceHeadSHA
        self.testedCheckoutSHA = testedCheckoutSHA
        self.sessionID = sessionID
        self.turnID = turnID
        self.eventID = eventID
        self.sequence = sequence
        self.matrixID = matrixID
        self.matrixSourceSHA256 = matrixSourceSHA256
        self.runtimeContractBundleDigest = runtimeContractBundleDigest
        self.appExecutableSHA256 = appExecutableSHA256
        self.finalOutcome = finalOutcome
        self.stateMutation = stateMutation
        self.readbackCount = readbackCount
        self.mountReceiptBodySHA256 = mountReceiptBodySHA256
        self.codeHeadDigest = codeHeadDigest
        self.mountedCatalogDigest = mountedCatalogDigest
        self.touchedCellCanonicalSnapshotDigest = touchedCellCanonicalSnapshotDigest
        self.linkedPreviousTurnID = linkedPreviousTurnID
        self.actions = actions
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(runID, forKey: .runID)
        try container.encode(runNonce, forKey: .runNonce)
        try container.encode(sourceHeadSHA, forKey: .sourceHeadSHA)
        try container.encode(testedCheckoutSHA, forKey: .testedCheckoutSHA)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(turnID, forKey: .turnID)
        try container.encode(eventID, forKey: .eventID)
        try container.encode(sequence, forKey: .sequence)
        try container.encode(matrixID, forKey: .matrixID)
        try container.encode(matrixSourceSHA256, forKey: .matrixSourceSHA256)
        try container.encode(runtimeContractBundleDigest, forKey: .runtimeContractBundleDigest)
        try container.encode(appExecutableSHA256, forKey: .appExecutableSHA256)
        try container.encode(finalOutcome, forKey: .finalOutcome)
        try container.encode(stateMutation, forKey: .stateMutation)
        try container.encode(readbackCount, forKey: .readbackCount)
        try container.encode(mountReceiptBodySHA256, forKey: .mountReceiptBodySHA256)
        try container.encode(codeHeadDigest, forKey: .codeHeadDigest)
        try container.encode(mountedCatalogDigest, forKey: .mountedCatalogDigest)
        try container.encode(touchedCellCanonicalSnapshotDigest, forKey: .touchedCellCanonicalSnapshotDigest)
        try container.encode(linkedPreviousTurnID, forKey: .linkedPreviousTurnID)
        try container.encode(actions, forKey: .actions)
    }

    public static func decode(from url: URL) throws -> RuntimeTurnReceipt {
        try JSONDecoder().decode(RuntimeTurnReceipt.self, from: Data(contentsOf: url))
    }

    static func executableSHA256() throws -> String {
        guard let executableURL = Bundle.main.executableURL else {
            throw FrontstageRouteReceiptWriteError.appExecutableUnavailable
        }
        return C6Hash.sha256Hex(try Data(contentsOf: executableURL))
    }
}

public enum FrontstageRouteReceiptWriter {
    @discardableResult
    public static func writeCurrent(
        _ receipt: RuntimeTurnReceipt,
        configuration: FrontstageRouteReceiptConfiguration,
        isCurrent: () -> Bool
    ) throws -> URL? {
        guard isCurrent() else { return nil }
        let destination = configuration.receiptURL
        let directory = destination.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw FrontstageRouteReceiptWriteError.durableWriteFailed(underlying: "failedToCreateDirectory")
        }

        let temporary = directory.appendingPathComponent(".frontstage-route-receipt-\(UUID().uuidString.lowercased()).tmp")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(receipt)
        guard FileManager.default.createFile(atPath: temporary.path, contents: data) else {
            throw FrontstageRouteReceiptWriteError.durableWriteFailed(underlying: "failedToCreateTemporaryFile")
        }
        do {
            let handle = try FileHandle(forWritingTo: temporary)
            try handle.synchronize()
            try handle.close()
        } catch {
            try? FileManager.default.removeItem(at: temporary)
            throw FrontstageRouteReceiptWriteError.durableWriteFailed(underlying: "failedToSynchronizeTemporaryFile")
        }

        guard isCurrent() else {
            try? FileManager.default.removeItem(at: temporary)
            return nil
        }
        guard Darwin.rename(temporary.path, destination.path) == 0 else {
            try? FileManager.default.removeItem(at: temporary)
            throw FrontstageRouteReceiptWriteError.durableWriteFailed(underlying: "failedToReplaceReceipt")
        }
        return destination
    }
}
