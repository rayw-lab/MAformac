import Foundation

struct FrontstagePresentationUpdate: Equatable {
    let snapshot: StagePresentationSnapshot
    let dialogueTurns: [DialogueTurn]
    let proofClass: PresentationProofClass
}

enum FrontstageRuntimePresentationAdapter {
    static func containmentUpdate(
        _ turn: FrontstageVoiceTurn,
        preserving previous: StagePresentationSnapshot
    ) -> FrontstagePresentationUpdate {
        precondition(turn.outcome.result == .refusalNoAvailableTool)
        precondition(!turn.stateMutation)
        precondition(turn.readbacks.isEmpty)

        let dialogText = "这个功能当前演示环境暂不支持"
        let snapshot = StagePresentationSnapshot(
            traceId: previous.traceId,
            storeCells: previous.storeCells,
            activeCells: previous.activeCells,
            refusedCell: previous.refusedCell,
            scopeOrigins: previous.scopeOrigins,
            context: previous.context,
            orbState: .think,
            voiceState: .idle,
            dialogText: dialogText,
            readbacks: previous.readbacks,
            resultKind: .refusalNoAvailableTool,
            proofClass: previous.proofClass
        )
        return FrontstagePresentationUpdate(
            snapshot: snapshot,
            dialogueTurns: [
                DialogueTurn(role: .user, text: turn.utterance),
                DialogueTurn(role: .assistant, text: dialogText)
            ],
            proofClass: turn.proofClass
        )
    }

    static func fixtureSnapshot(
        traceID: String,
        storeCells: [DemoVehicleStateCell],
        activeCells: [FamilyCardID: String],
        refusedCell: String?,
        scopeOrigins: [String: ScopeOrigin],
        orbState: PresentationOrbState,
        voiceState: PresentationVoiceState,
        dialogText: String,
        readbacks: [DemoActionReadback],
        resultKind: DemoRuntimeResultKind,
        proofClass: StagePresentationProofClass
    ) -> StagePresentationSnapshot {
        StagePresentationSnapshot(
            traceId: traceID,
            storeCells: storeCells,
            activeCells: activeCells,
            refusedCell: refusedCell,
            scopeOrigins: scopeOrigins,
            orbState: orbState,
            voiceState: voiceState,
            dialogText: dialogText,
            readbacks: readbacks,
            resultKind: resultKind,
            proofClass: proofClass
        )
    }
}
