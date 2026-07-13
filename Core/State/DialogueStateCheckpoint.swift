import Foundation

// MARK: - Restore disposition

/// authoritative checkpoint 的 restore disposition。
///
/// `.authoritative` 之外的 case 均为「不可 rebind」信号，validator 会返回 failure。
public enum DialogueStateRestoreDisposition: Codable, Equatable, Sendable {
    case authoritative
    case legacyMigrationAmbiguous
    case identityMismatch(currentIdentityRef: String, checkpointIdentityRef: String)
    case displayTextOnlyNoContext
    case unknown(rawValue: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        switch kind {
        case "authoritative":
            self = .authoritative
        case "legacy_migration_ambiguous":
            self = .legacyMigrationAmbiguous
        case "identity_mismatch":
            let current = try container.decode(String.self, forKey: .currentIdentityRef)
            let checkpoint = try container.decode(String.self, forKey: .checkpointIdentityRef)
            self = .identityMismatch(currentIdentityRef: current, checkpointIdentityRef: checkpoint)
        case "display_text_only_no_context":
            self = .displayTextOnlyNoContext
        default:
            self = .unknown(rawValue: kind)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .authoritative:
            try container.encode("authoritative", forKey: .kind)
        case .legacyMigrationAmbiguous:
            try container.encode("legacy_migration_ambiguous", forKey: .kind)
        case .identityMismatch(let current, let checkpoint):
            try container.encode("identity_mismatch", forKey: .kind)
            try container.encode(current, forKey: .currentIdentityRef)
            try container.encode(checkpoint, forKey: .checkpointIdentityRef)
        case .displayTextOnlyNoContext:
            try container.encode("display_text_only_no_context", forKey: .kind)
        case .unknown(let raw):
            try container.encode(raw, forKey: .kind)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case currentIdentityRef = "current_identity_ref"
        case checkpointIdentityRef = "checkpoint_identity_ref"
    }
}

// MARK: - Checkpoint value type

/// authoritative checkpoint schema。所有字段皆为 schema 层承载（不实现算法）。
///
/// - `digest`：hex-encoded；本 change 不定义 hash 算法。
/// - `sessionOwnerRef` / `generationOwnerRef`：opaque String，绑 W8 owner。
/// - `capturedAt`：Unix epoch seconds。
public struct DialogueStateCheckpoint: Codable, Equatable, Sendable {
    public let schemaVersion: DialogueStateSchemaVersion
    public let sessionOwnerRef: String
    public let generationOwnerRef: String
    public let digest: String
    public let restoreDisposition: DialogueStateRestoreDisposition
    public let capturedAt: TimeInterval

    public init(
        schemaVersion: DialogueStateSchemaVersion,
        sessionOwnerRef: String,
        generationOwnerRef: String,
        digest: String,
        restoreDisposition: DialogueStateRestoreDisposition,
        capturedAt: TimeInterval
    ) {
        self.schemaVersion = schemaVersion
        self.sessionOwnerRef = sessionOwnerRef
        self.generationOwnerRef = generationOwnerRef
        self.digest = digest
        self.restoreDisposition = restoreDisposition
        self.capturedAt = capturedAt
    }
}

// MARK: - Errors

public enum DialogueStateCheckpointError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(rawValue: String)
    case missingIdentity(field: String)
    case emptyDigest
    case unknownRestoreDisposition(rawValue: String)
    case notAuthoritative(disposition: DialogueStateRestoreDisposition)
    case identityMismatch(currentIdentityRef: String, checkpointIdentityRef: String)
    case displayTextOnlyNoContext
    case legacyMigrationAmbiguous
}

// MARK: - Validator

/// checkpoint validator。fail-closed：identity mismatch / legacy ambiguous /
/// display-text-only / unknown disposition / unsupported version 全部 `.failure`，
/// caller SHALL NOT rebind checkpoint 到 current session。
public enum DialogueStateCheckpointValidator {
    public static func validate(
        _ checkpoint: DialogueStateCheckpoint,
        againstCurrentIdentity current: DialogueStateCheckpointCurrentIdentity
    ) -> Result<DialogueStateCheckpoint, DialogueStateCheckpointError> {
        guard checkpoint.schemaVersion.isSupported else {
            return .failure(.unsupportedSchemaVersion(rawValue: checkpoint.schemaVersion.rawValue))
        }
        if checkpoint.sessionOwnerRef.isEmpty {
            return .failure(.missingIdentity(field: "sessionOwnerRef"))
        }
        if checkpoint.generationOwnerRef.isEmpty {
            return .failure(.missingIdentity(field: "generationOwnerRef"))
        }
        if checkpoint.digest.isEmpty {
            return .failure(.emptyDigest)
        }
        switch checkpoint.restoreDisposition {
        case .authoritative:
            break
        case .legacyMigrationAmbiguous:
            return .failure(.legacyMigrationAmbiguous)
        case .identityMismatch(let currentRef, let checkpointRef):
            return .failure(.identityMismatch(
                currentIdentityRef: currentRef,
                checkpointIdentityRef: checkpointRef
            ))
        case .displayTextOnlyNoContext:
            return .failure(.displayTextOnlyNoContext)
        case .unknown(let raw):
            return .failure(.unknownRestoreDisposition(rawValue: raw))
        }
        // 即使 disposition 声称 authoritative，也要用 current identity 兜底核对
        if checkpoint.sessionOwnerRef != current.sessionOwnerRef {
            return .failure(.identityMismatch(
                currentIdentityRef: current.sessionOwnerRef,
                checkpointIdentityRef: checkpoint.sessionOwnerRef
            ))
        }
        if checkpoint.generationOwnerRef != current.generationOwnerRef {
            return .failure(.identityMismatch(
                currentIdentityRef: current.generationOwnerRef,
                checkpointIdentityRef: checkpoint.generationOwnerRef
            ))
        }
        return .success(checkpoint)
    }
}

public struct DialogueStateCheckpointCurrentIdentity: Equatable, Sendable {
    public let sessionOwnerRef: String
    public let generationOwnerRef: String

    public init(sessionOwnerRef: String, generationOwnerRef: String) {
        self.sessionOwnerRef = sessionOwnerRef
        self.generationOwnerRef = generationOwnerRef
    }
}
