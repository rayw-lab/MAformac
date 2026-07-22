import Foundation

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

    @MainActor
    public var isCurrent: Bool {
        isCurrentProvider()
    }
}
