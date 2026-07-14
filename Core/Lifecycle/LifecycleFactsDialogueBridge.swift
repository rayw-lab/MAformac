import Foundation

// MARK: - S2 Product Operator Boundary Gate
// Bridge maps live SessionLifecycleEvent to DialogueW8FactKind and applies a caller-provided
// DialogueW7EffectMatrix. Owns no coordinator / DialogueState / store / register.
// Unknown / version mismatch / missing matrix entry fails closed.

/// Errors emitted by the lifecycle-to-dialogue bridge.
public enum LifecycleBridgeError: Error, Equatable, Sendable {
    /// The effect matrix version is unsupported (not `.v1`).
    case effectVersionMismatch(matrixRawValue: String)
    /// The mapped fact kind is unknown (`.unknown` variant from decode).
    case unknownFact(rawValue: String)
    /// The matrix has no entry for the mapped fact kind.
    case unrecognizedEffect(factRawValue: String)
}

/// Public bridge that translates a live `SessionLifecycleEvent` into a `DialogueW8FactKind`
/// and consumes it through a caller-provided `DialogueW7EffectMatrix`.
///
/// - Owns NO coordinator, NO DialogueState, NO store, NO register.
/// - Only maps + delegates to `DialogueW7EffectMatrix.apply(_:)`.
/// - Fail-closed on unknown fact, unsupported matrix version, or missing entry.
public struct LifecycleFactsDialogueBridge: Sendable {
    public init() {}

    /// Maps a `SessionLifecycleEvent` to its corresponding `DialogueW8FactKind`.
    ///
    /// Mapping table (closed, per spec AD-4.1):
    /// - `.start` → `.sessionStarted`
    /// - `.terminal` with `outcomeClass == .cancelled` → `.turnCancelled`
    /// - `.terminal` with any other settled outcome class → `.terminalClear`
    /// - `.newGeneration` → `.generationFenced`
    /// - `.recoveryReady` → `.checkpointRestoreAttempted`
    public func map(event: SessionLifecycleEvent) -> DialogueW8FactKind {
        switch event {
        case .start:
            return .sessionStarted
        case .terminal(_, _, _, _, let outcomeClass):
            switch outcomeClass {
            case .cancelled:
                return .turnCancelled
            case .accepted, .refused, .unsupported, .timeout, .failure:
                return .terminalClear
            }
        case .newGeneration:
            return .generationFenced
        case .recoveryReady:
            return .checkpointRestoreAttempted
        }
    }

    /// Maps the event and immediately applies the effect through the provided matrix.
    ///
    /// - Parameters:
    ///   - event: The live lifecycle event to translate and consume.
    ///   - matrix: Caller-provided effect matrix (versioned, fail-closed).
    /// - Returns: `.success(DialogueW7Effect)` on valid mapping + matrix entry; `.failure(LifecycleBridgeError)` otherwise.
    /// - Note: No DialogueState mutation occurs here; the bridge only returns the effect for the caller to apply.
    public func mapAndApply(
        event: SessionLifecycleEvent,
        matrix: DialogueW7EffectMatrix
    ) -> Result<DialogueW7Effect, LifecycleBridgeError> {
        let factKind = map(event: event)

        // Fail-closed on unknown fact (should not happen for known mappings, but defensive).
        if case .unknown(let raw) = factKind {
            return .failure(.unknownFact(rawValue: raw))
        }

        // Delegate to matrix apply (handles version mismatch + missing entry).
        let matrixResult = matrix.apply(factKind)

        switch matrixResult {
        case .success(let effect):
            return .success(effect)
        case .failure(let error):
            switch error {
            case .effectVersionMismatch(let raw):
                return .failure(.effectVersionMismatch(matrixRawValue: raw))
            case .unknownFact(let raw):
                return .failure(.unknownFact(rawValue: raw))
            case .unrecognizedEffect(let raw):
                return .failure(.unrecognizedEffect(factRawValue: raw))
            }
        }
    }

    /// Maps the event to a fact kind without applying the matrix.
    /// Useful for callers that want to inspect the fact before deciding to apply.
    public func mapToFactKind(event: SessionLifecycleEvent) -> DialogueW8FactKind {
        map(event: event)
    }
}