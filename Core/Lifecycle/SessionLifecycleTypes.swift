import Foundation

// MARK: - K1 schema-core identity & closed classification types
//
// CREATE-only surface for session lifecycle schema-core (OpenSpec implement-t09).
// Value types only: no owner mutation, no state machine, no concurrency runtime.
// Observable states include recoveryReady; executable entry is not defined here
// (Coordinator enforces ready→active / active→terminal only).

// MARK: Identity

/// Opaque owner authority token. Equality is value equality on the raw token.
public struct SessionOwnerAuthority: Equatable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Parent session identity (value type; not a process handle).
public struct SessionID: Equatable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Monotonic generation identity for a parent session.
/// K1 does not allocate new generations; unknown generation fails closed at apply.
public struct SessionGeneration: Equatable, Hashable, Sendable {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }
}

// MARK: Observable lifecycle states

/// Observable parent-session lifecycle states.
/// K1 executable subset is only ready→active and active→terminal (enforced by Coordinator).
/// `recoveryReady` is named for schema alignment with base capability but is not K1-executable.
public enum SessionLifecycleState: String, Equatable, Hashable, Sendable {
    case ready
    case active
    case terminal
    case recoveryReady
}

// MARK: Terminal disposition & cause (once-write at first successful terminal)

/// Closed terminal disposition set for parent session settlement.
public enum SessionTerminalDisposition: String, Equatable, Hashable, Sendable {
    case completed
    case cancelled
    case refused
    case failed
}

/// Closed first-cause set written once on first successful entry into terminal.
public enum SessionTerminalCause: String, Equatable, Hashable, Sendable {
    case completedNormally
    case operatorCancel
    case policyRefused
    case unsupportedRequest
    case deadlineTimeout
    case internalFailure
}

// MARK: Apply rejection reasons (fail-closed; never implies mutation)

/// Why an apply was rejected or treated as non-applied.
/// Reasons are classification only; Coordinator maps events to these without partial mutation.
public enum SessionLifecycleRejectionReason: String, Equatable, Hashable, Sendable {
    case wrongAuthority
    case illegalTransition
    case batchInvalid
    case recoveryNotExecutable
    case newGenerationNotExecutable
    case crossSession
    case unknownIdentity
    case unknownGeneration
    /// Terminal disposition/cause/outcomeClass tuple is inconsistent (e.g. failure-class + accepted).
    /// Fail-closed: must not upgrade error-class terminal into success/accepted fact.
    case inconsistentTerminalOutcome
}
