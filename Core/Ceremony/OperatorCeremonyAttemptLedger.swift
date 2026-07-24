import Foundation

// MARK: - T07a Attempt Ledger

/// A single attempt in the operator-ceremony attempt ledger.
public struct OperatorCeremonyAttempt: Codable, Equatable {
    public let attemptID: String
    public let launchMode: OperatorCeremonyLaunchMode
    public let artifact: OperatorCeremonyArtifactIdentity
    public let environment: OperatorCeremonyEnvironmentIdentity
    public let timestamp: Date
    public let disposition: String
    public let reason: String?
}

/// Finite launch-mode vocabulary for operator-ceremony attempts.
public enum OperatorCeremonyLaunchMode: String, Codable, CaseIterable {
    case xcodeRun = "xcode_run"
    case signedApp = "signed_app"
    case archive
}

/// Artifact identity for a ceremony attempt.
public struct OperatorCeremonyArtifactIdentity: Codable, Equatable {
    public let repoSHA: String
    public let dirtyVerdict: Bool
    public let buildScheme: String
    public let bundleVersion: String
    public let bundleHash: String
}

/// Environment identity for a ceremony attempt.
public struct OperatorCeremonyEnvironmentIdentity: Codable, Equatable {
    public let machine: String
    public let osVersion: String
    public let target: String
    public let scenarioVersion: String
    public let contractVersion: String
}

/// A ceremony subject identity.
public struct OperatorCeremonySubjectIdentity: Codable, Equatable {
    public let repoSHA: String
    public let dirtyVerdict: Bool
}

/// A ceremony envelope containing all six sections.
public struct OperatorCeremonyEnvelope: Codable, Equatable {
    public let schemaVersion: String
    public let subject: OperatorCeremonySubjectIdentity
    public let environment: OperatorCeremonyEnvironmentIdentity
    public let attempt: OperatorCeremonyAttempt
    public let axes: OperatorCeremonyAxes
    public let expiry: OperatorCeremonyExpiry
    public let evidence: OperatorCeremonyEvidence
}

/// Per-axis ceremony predicates.
public struct OperatorCeremonyAxes: Codable, Equatable {
    public let decision: OperatorCeremonyAxis
    public let execution: OperatorCeremonyAxis
    public let proof: OperatorCeremonyAxis
}

/// A single axis predicate.
public struct OperatorCeremonyAxis: Codable, Equatable {
    public let predicateVersion: String
    public let isCurrent: Bool
    public let pass: Bool
    public let reason: String?
    public let claimCap: String
}

/// Expiry and retest semantics.
public struct OperatorCeremonyExpiry: Codable, Equatable {
    public let isExpired: Bool
    public let expiredReason: String?
    public let retestRequired: Bool
}

/// Evidence reference.
public struct OperatorCeremonyEvidence: Codable, Equatable {
    public let evidenceIDs: [String]
    public let proofClass: String
}

/// The immutable append-only attempt ledger.
public final class OperatorCeremonyAttemptLedger {
    public private(set) var attempts: [OperatorCeremonyAttempt] = []

    public init() {}

    /// Appends a new attempt. Does not overwrite prior attempts.
    public func append(_ attempt: OperatorCeremonyAttempt) {
        attempts.append(attempt)
    }

    /// Returns the latest attempt, if any.
    public var latestAttempt: OperatorCeremonyAttempt? {
        attempts.last
    }

    /// Returns the number of attempts.
    public var count: Int { attempts.count }
}

// MARK: - Envelope Validation

/// Validates a ceremony envelope against the six-section schema.
/// Returns `.success` if all sections are present and valid, or a specific failure.
public func validateCeremonyEnvelope(_ envelope: OperatorCeremonyEnvelope) -> CeremonyEnvelopeValidation {
    guard !envelope.schemaVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing schema version")
    }
    // subject
    guard !envelope.subject.repoSHA.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing subject.repoSHA")
    }
    // environment
    guard !envelope.environment.machine.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing environment.machine")
    }
    guard !envelope.environment.osVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing environment.osVersion")
    }
    guard !envelope.environment.target.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing environment.target")
    }
    guard !envelope.environment.scenarioVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing environment.scenarioVersion")
    }
    guard !envelope.environment.contractVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing environment.contractVersion")
    }
    // attempt
    guard !envelope.attempt.attemptID.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing attempt.attemptID")
    }
    guard !envelope.attempt.artifact.repoSHA.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing attempt.artifact.repoSHA")
    }
    // axes
    guard !envelope.axes.decision.predicateVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing axes.decision.predicateVersion")
    }
    guard !envelope.axes.execution.predicateVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing axes.execution.predicateVersion")
    }
    guard !envelope.axes.proof.predicateVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing axes.proof.predicateVersion")
    }
    // expiry
    // evidence
    guard !envelope.evidence.proofClass.trimmingCharacters(in: .whitespaces).isEmpty else {
        return .failure("Missing evidence.proofClass")
    }
    return .success
}

/// Result of envelope validation.
public enum CeremonyEnvelopeValidation: Equatable {
    case success
    case failure(String)
}

// MARK: - Synthetic Fixture Validation

/// Validates that a synthetic fixture carries the required three fields.
public func validateSyntheticFixture(synthetic: Bool, proofClass: String, satisfiesT07bPrerequisite: Bool) throws {
    guard synthetic == true else {
        throw SyntheticFixtureError.missingOrContradictory("synthetic must be true")
    }
    guard proofClass == "local" else {
        throw SyntheticFixtureError.missingOrContradictory("proof_class must be 'local'")
    }
    guard satisfiesT07bPrerequisite == false else {
        throw SyntheticFixtureError.missingOrContradictory("satisfies_t07b_prerequisite must be false")
    }
}

public enum SyntheticFixtureError: Error, Equatable {
    case missingOrContradictory(String)
}

extension SyntheticFixtureError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingOrContradictory(let detail):
            return "Synthetic fixture validation failed: \(detail)"
        }
    }
}

// MARK: - Identity Join

/// Result of a ceremony identity join.
public enum CeremonyIdentityJoinResult: Equatable {
    case localSchemaJoinOnly
    case mismatch(String)
}

/// Performs an exact identity join between two ceremony envelopes.
/// Returns `.localSchemaJoinOnly` when all identity fields match exactly.
/// Returns `.mismatch` with a description when any field differs.
public func joinCeremonyIdentities(_ lhs: OperatorCeremonyEnvelope, _ rhs: OperatorCeremonyEnvelope) -> CeremonyIdentityJoinResult {
    // subject
    guard lhs.subject == rhs.subject else {
        return .mismatch("subject mismatch")
    }
    // environment
    guard lhs.environment == rhs.environment else {
        return .mismatch("environment mismatch")
    }
    // attempt artifact
    guard lhs.attempt.artifact == rhs.attempt.artifact else {
        return .mismatch("artifact mismatch")
    }
    // scenario version and contract version
    guard lhs.environment.scenarioVersion == rhs.environment.scenarioVersion else {
        return .mismatch("scenario version mismatch")
    }
    guard lhs.environment.contractVersion == rhs.environment.contractVersion else {
        return .mismatch("contract version mismatch")
    }
    return .localSchemaJoinOnly
}
