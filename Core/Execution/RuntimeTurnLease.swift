import Foundation

/// Stable `(sessionID, sequence, turnID)` link token for pre/post-commit cancel receipts.
/// Does not carry `isCurrent` capability — that lives on `RuntimeTurnLease`.
public struct RuntimeTurnIdentity: Hashable, Sendable {
    public let sessionID: UUID
    public let sequence: UInt64
    public let turnID: UUID

    public init(sessionID: UUID, sequence: UInt64, turnID: UUID) {
        self.sessionID = sessionID
        self.sequence = sequence
        self.turnID = turnID
    }

    public init(_ lease: RuntimeTurnLease) {
        self.sessionID = lease.sessionID
        self.sequence = lease.sequence
        self.turnID = lease.turnID
    }

    /// Wire token for eventID / receipt linking (lowercase UUID, no truncation).
    public var linkToken: String {
        "\(sessionID.uuidString.lowercased()):\(sequence):\(turnID.uuidString.lowercased())"
    }
}

/// Immutable turn-lease identity for last-intent-wins / cancel fencing.
///
/// Core-only type: no App imports. `isCurrent` is a MainActor capability closure so
/// composition can invalidate stale turns without runner inventing a second epoch.
public struct RuntimeTurnLease: Sendable {
    public let sessionID: UUID
    public let sequence: UInt64
    public let turnID: UUID
    private let isCurrentProvider: @MainActor @Sendable () -> Bool

    public init(
        sessionID: UUID,
        sequence: UInt64,
        turnID: UUID,
        isCurrent: @escaping @MainActor @Sendable () -> Bool
    ) {
        self.sessionID = sessionID
        self.sequence = sequence
        self.turnID = turnID
        self.isCurrentProvider = isCurrent
    }

    public var identity: RuntimeTurnIdentity {
        RuntimeTurnIdentity(self)
    }

    @MainActor
    public var isCurrent: Bool {
        isCurrentProvider()
    }
}
