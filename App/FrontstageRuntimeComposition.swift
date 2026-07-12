import Foundation

/// App-owned frontstage composition. Production routing remains deny-first; the
/// only positive binding is the separately admitted two-entry demo slice.
@MainActor
final class FrontstageRuntimeComposition {
    let session: FrontstageVoiceSession
    let customerIngress: FrontstageCustomerIngress
    private(set) var currentTurnID: String?
    private var demoSliceRoute: DemoSliceRoute?

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
        precondition(isCurrentTurn(turn))
        if demoSliceRoute == nil {
            demoSliceRoute = try DemoSliceRoute(
                store: store,
                traceLogger: traceLogger,
                speech: speech
            )
        }
        return try await demoSliceRoute!.route(text: turn.utterance)
    }
}
