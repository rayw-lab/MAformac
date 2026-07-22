import Foundation

/// Typed fail-closed errors for the single customer-facing production composition root.
enum FrontstageRuntimeCompositionError: Error, Equatable {
    case currentTurnMismatch(expected: String?, actual: String)
    case invalidTurnSequence(Int)
    case emptyTurnIdentity(field: String)
}

/// App-owned frontstage composition. Production routing remains deny-first; the
/// only positive binding is the separately reviewed finite demo slice.
///
/// **S0 freeze:** This type is the sole customer-facing production composition root.
/// It owns one cached `DemoSliceRoute` and one lifecycle/state/store path. Do not
/// create a second root, coordinator, or ContentView-local production runner.
@MainActor
final class FrontstageRuntimeComposition {
    let session: FrontstageVoiceSession
    let customerIngress: FrontstageCustomerIngress
    private(set) var currentTurnID: String?
    private var demoSliceRoute: DemoSliceRoute?
    private var sessionLifecycleGate: SessionLifecycleCompositionGate?

    init(session: FrontstageVoiceSession = FrontstageVoiceSession()) {
        self.session = session
        self.customerIngress = FrontstageCustomerIngress(session: session)
    }

    func markCurrent(_ turn: FrontstageVoiceTurn) {
        currentTurnID = turn.turnID
    }

    func isCurrentTurn(_ turn: FrontstageVoiceTurn) -> Bool {
        currentTurnID == turn.turnID
    }

    func routeDemoSlice(
        _ turn: FrontstageVoiceTurn,
        store: DemoVehicleStateStore,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine
    ) async throws -> DemoSliceRouteResult {
        guard isCurrentTurn(turn) else {
            throw FrontstageRuntimeCompositionError.currentTurnMismatch(
                expected: currentTurnID,
                actual: turn.turnID
            )
        }
        if sessionLifecycleGate == nil {
            sessionLifecycleGate = SessionLifecycleCompositionGate(
                sessionID: SessionID(rawValue: session.sessionID),
                generation: SessionGeneration(value: 0)
            )
        }
        let lifecycleSnapshot = try sessionLifecycleGate!.ensureActive(
            expectedSessionID: SessionID(rawValue: turn.sessionID)
        )
        guard lifecycleSnapshot.state == .active,
              lifecycleSnapshot.sessionID.rawValue == turn.sessionID
        else {
            throw SessionLifecycleCompositionGateError.unexpectedState(lifecycleSnapshot.state)
        }

        // Fail-closed identity assembly before any catalog/runner success path.
        let trimmedTurnID = turn.turnID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSessionID = turn.sessionID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTurnID.isEmpty else {
            throw FrontstageRuntimeCompositionError.emptyTurnIdentity(field: "turnID")
        }
        guard !trimmedSessionID.isEmpty else {
            throw FrontstageRuntimeCompositionError.emptyTurnIdentity(field: "sessionID")
        }
        // Positive sequence required; also rejects values outside UInt32 domain.
        guard turn.sequence > 0, let groupOrdinal = UInt32(exactly: turn.sequence) else {
            throw FrontstageRuntimeCompositionError.invalidTurnSequence(turn.sequence)
        }

        let correlationProvider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: trimmedTurnID,
            sessionRef: trimmedSessionID,
            generationRef: String(lifecycleSnapshot.generation.value),
            groupOrdinal: groupOrdinal
        )

        if demoSliceRoute == nil {
            demoSliceRoute = try DemoSliceRoute(
                store: store,
                traceLogger: traceLogger,
                speech: speech
            )
        }
        return try await demoSliceRoute!.route(
            text: turn.utterance,
            correlationProvider: correlationProvider
        )
    }
}
