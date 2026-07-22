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
///
/// **G4 刀3:** Owns the customer-path ingress `Task` handle and turn-lease
/// issuance. ContentView must not spawn anonymous route Tasks.
@MainActor
final class FrontstageRuntimeComposition {
    let session: FrontstageVoiceSession
    let customerIngress: FrontstageCustomerIngress
    private(set) var currentTurnID: String?
    private var demoSliceRoute: DemoSliceRoute?
    private var sessionLifecycleGate: SessionLifecycleCompositionGate?
    /// Sole customer-path route Task. New ingress cancels the previous handle.
    private var ingressRouteTask: Task<Void, Never>?

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

    /// Schedule demo-slice routing under the composition-owned Task handle.
    ///
    /// Preempt order (Gemini 刀1/刀2 risk):
    /// 1. `cancel()` previous ingress Task
    /// 2. switch current identity (`markCurrent`) so lease capability flips
    /// 3. `cancelPendingSpeech()` for the *old* turn (after identity switch — never
    ///    kill speech belonging to the turn that just became current)
    /// 4. start a new Task that issues lease and routes
    func scheduleIngressRoute(
        _ turn: FrontstageVoiceTurn,
        store: DemoVehicleStateStore,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine,
        onResult: @escaping @MainActor (Result<DemoSliceRouteResult, Error>) -> Void
    ) {
        ingressRouteTask?.cancel()
        ingressRouteTask = nil

        markCurrent(turn)
        speech.cancelPendingSpeech()

        let scheduledTurn = turn
        ingressRouteTask = Task { @MainActor in
            // Gemini: clear handle on completion; never wipe a successor
            // scheduled after preempt (preempt already cancelled us).
            defer {
                if !Task.isCancelled {
                    self.ingressRouteTask = nil
                }
            }
            do {
                let routeResult = try await self.routeDemoSlice(
                    scheduledTurn,
                    store: store,
                    traceLogger: traceLogger,
                    speech: speech
                )
                guard !Task.isCancelled else { return }
                guard self.isCurrentTurn(scheduledTurn) else { return }
                onResult(.success(routeResult))
            } catch {
                guard !Task.isCancelled else { return }
                guard self.isCurrentTurn(scheduledTurn) else { return }
                onResult(.failure(error))
            }
        }
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
        guard let sessionUUID = UUID(uuidString: trimmedSessionID),
              let turnUUID = UUID(uuidString: trimmedTurnID),
              let leaseSequence = UInt64(exactly: turn.sequence)
        else {
            throw FrontstageRuntimeCompositionError.emptyTurnIdentity(field: "leaseIdentity")
        }

        let correlationProvider = try ProductionRouteCorrelationProvider.make(
            routeTurnID: trimmedTurnID,
            sessionRef: trimmedSessionID,
            generationRef: String(lifecycleSnapshot.generation.value),
            groupOrdinal: groupOrdinal
        )

        // Issue lease before any await so Door-1/Door-2 can fence this turn.
        let lease = RuntimeTurnLease(
            sessionID: sessionUUID,
            sequence: leaseSequence,
            turnID: turnUUID,
            isCurrent: { [weak self] in
                self?.currentTurnID == trimmedTurnID
            }
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
            correlationProvider: correlationProvider,
            lease: lease
        )
    }
}
