import Foundation

/// Production-only correlation factory for the App composition root.
///
/// Stateless: each call freezes the identity 4-tuple into a
/// `RuntimeSessionCorrelationProvider` closure. No mutable/global context box.
/// Both `RouteToDialogueCorrelation.schemaVersion` and nested
/// `DialogueRouteAttribution.schemaVersion` are frozen to `DialogueStateSchemaVersion.v1`.
///
/// Exact factory inputs (contract-frozen):
/// - `routeTurnID`
/// - `sessionRef`
/// - `generationRef`
/// - `groupOrdinal`
public enum ProductionRouteCorrelationProvider {
    public enum FactoryError: Error, Equatable, Sendable {
        case emptyRouteTurnID
        case emptySessionRef
        case emptyGenerationRef
    }

    /// Builds a per-turn provider from frozen identity inputs.
    /// Blank / whitespace-only identity strings fail closed at construction.
    public static func make(
        routeTurnID: String,
        sessionRef: String,
        generationRef: String,
        groupOrdinal: UInt32
    ) throws -> RuntimeSessionCorrelationProvider {
        let frozenTurnID = routeTurnID.trimmingCharacters(in: .whitespacesAndNewlines)
        let frozenSessionRef = sessionRef.trimmingCharacters(in: .whitespacesAndNewlines)
        let frozenGenerationRef = generationRef.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !frozenTurnID.isEmpty else { throw FactoryError.emptyRouteTurnID }
        guard !frozenSessionRef.isEmpty else { throw FactoryError.emptySessionRef }
        guard !frozenGenerationRef.isEmpty else { throw FactoryError.emptyGenerationRef }

        return RuntimeSessionCorrelationProvider { frame, traceID in
            let frozenTraceID = traceID.trimmingCharacters(in: .whitespacesAndNewlines)
            // Blank traceID is fail-closed at the provider boundary: return nil so
            // the runner treats this turn as no correlation (no typed-facts success).
            guard !frozenTraceID.isEmpty else { return nil }

            let actionCandidate: String? = {
                let candidate = frame.id.trimmingCharacters(in: .whitespacesAndNewlines)
                return candidate.isEmpty ? nil : candidate
            }()

            return RouteToDialogueCorrelation(
                route: DialogueRouteAttribution(
                    routeTurnID: RouteTurnIdentifier(frozenTurnID),
                    routeTraceID: RouteTraceIdentifier(frozenTraceID),
                    traceDigestRef: nil,
                    actionCandidateRef: actionCandidate,
                    schemaVersion: .v1
                ),
                dialogueGroupRef: DialogueSourceGroupRef(
                    sessionRef: frozenSessionRef,
                    generationRef: frozenGenerationRef,
                    groupOrdinal: groupOrdinal
                ),
                schemaVersion: .v1
            )
        }
    }
}
