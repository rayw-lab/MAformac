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
    case nonContainmentTurn
    case appExecutableUnavailable
    case failedToCreateDirectory
    case failedToCreateTemporaryFile
    case failedToReplaceReceipt
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
            .appendingPathComponent("frontstage-route-receipt.v1.json", isDirectory: false)
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

public struct FrontstageRouteReceipt: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let runID: String
    public let runNonce: String
    public let sourceHeadSHA: String?
    public let sessionID: String
    public let turnID: String
    public let eventID: String
    public let sequence: Int
    public let matrixID: Int?
    public let runtimeContractBundleDigest: String
    public let appExecutableSHA256: String
    public let proofClass: String
    public let result: DemoRuntimeResult
    public let stateMutation: Bool
    public let readbackCount: Int

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case runID = "run_id"
        case runNonce = "run_nonce"
        case sourceHeadSHA = "source_head_sha"
        case sessionID = "session_id"
        case turnID = "turn_id"
        case eventID = "event_id"
        case sequence
        case matrixID = "matrix_id"
        case runtimeContractBundleDigest = "runtime_contract_bundle_digest"
        case appExecutableSHA256 = "app_executable_sha256"
        case proofClass = "proof_class"
        case result
        case stateMutation = "state_mutation"
        case readbackCount = "readback_count"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(runID, forKey: .runID)
        try container.encode(runNonce, forKey: .runNonce)
        try container.encode(sourceHeadSHA, forKey: .sourceHeadSHA)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(turnID, forKey: .turnID)
        try container.encode(eventID, forKey: .eventID)
        try container.encode(sequence, forKey: .sequence)
        try container.encode(matrixID, forKey: .matrixID)
        try container.encode(runtimeContractBundleDigest, forKey: .runtimeContractBundleDigest)
        try container.encode(appExecutableSHA256, forKey: .appExecutableSHA256)
        try container.encode(proofClass, forKey: .proofClass)
        try container.encode(result, forKey: .result)
        try container.encode(stateMutation, forKey: .stateMutation)
        try container.encode(readbackCount, forKey: .readbackCount)
    }

    static func containment(_ turn: FrontstageVoiceTurn, configuration: FrontstageRouteReceiptConfiguration) throws -> FrontstageRouteReceipt {
        guard turn.outcome.result == .refusalNoAvailableTool, !turn.stateMutation, turn.readbacks.isEmpty else {
            throw FrontstageRouteReceiptWriteError.nonContainmentTurn
        }
        return FrontstageRouteReceipt(
            schemaVersion: "frontstage_route_receipt.v1",
            runID: configuration.runID,
            runNonce: configuration.runNonce,
            sourceHeadSHA: configuration.sourceHeadSHA,
            sessionID: turn.sessionID,
            turnID: turn.turnID,
            eventID: turn.eventID,
            sequence: turn.sequence,
            matrixID: nil,
            runtimeContractBundleDigest: DemoRuntimeContractBundleCatalog.runtimeContractBundleDigest,
            appExecutableSHA256: try executableSHA256(),
            proofClass: "frontstage_route_local_integration",
            result: turn.outcome.result,
            stateMutation: turn.stateMutation,
            readbackCount: turn.readbacks.count
        )
    }

    public static func decode(from url: URL) throws -> FrontstageRouteReceipt {
        try JSONDecoder().decode(FrontstageRouteReceipt.self, from: Data(contentsOf: url))
    }

    private static func executableSHA256() throws -> String {
        guard let executableURL = Bundle.main.executableURL else {
            throw FrontstageRouteReceiptWriteError.appExecutableUnavailable
        }
        return C6Hash.sha256Hex(try Data(contentsOf: executableURL))
    }
}

public enum FrontstageRouteReceiptWriter {
    @discardableResult
    public static func writeCurrent(
        _ turn: FrontstageVoiceTurn,
        configuration: FrontstageRouteReceiptConfiguration,
        isCurrent: () -> Bool
    ) throws -> URL? {
        guard isCurrent() else { return nil }
        let receipt = try FrontstageRouteReceipt.containment(turn, configuration: configuration)
        let destination = configuration.receiptURL
        let directory = destination.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw FrontstageRouteReceiptWriteError.failedToCreateDirectory
        }

        let temporary = directory.appendingPathComponent(".frontstage-route-receipt-\(UUID().uuidString.lowercased()).tmp")
        let data = try JSONEncoder().encode(receipt)
        guard FileManager.default.createFile(atPath: temporary.path, contents: data) else {
            throw FrontstageRouteReceiptWriteError.failedToCreateTemporaryFile
        }
        let handle = try FileHandle(forWritingTo: temporary)
        try handle.synchronize()
        try handle.close()

        guard isCurrent() else {
            try? FileManager.default.removeItem(at: temporary)
            return nil
        }
        guard Darwin.rename(temporary.path, destination.path) == 0 else {
            try? FileManager.default.removeItem(at: temporary)
            throw FrontstageRouteReceiptWriteError.failedToReplaceReceipt
        }
        return destination
    }
}
