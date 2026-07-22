import Foundation

enum DemoRuntimeResultKind: String, CaseIterable, Codable, Equatable, Sendable {
    case acceptedToolCall = "accepted_tool_call"
    case noAction = "no_action"
    case clarifyMissingSlot = "clarify_missing_slot"
    case refusalNoAvailableTool = "refusal_no_available_tool"
    case refusalSafetyOrPolicy = "refusal_safety_or_policy"
    case alreadyStateNoop = "already_state_noop"
    case runtimeError = "runtime_error"
    case cancelled
    case partialAcceptPartialRefuse = "partial_accept_partial_refuse"
}

enum StagePresentationProofClass: String, Codable, Equatable, Sendable {
    case localMock = "local_mock"
    case staticPreview = "static_preview"
    case simulatorMock = "simulator_mock"
    case operatorReview = "operator_review"
}

enum PresentationOrbState: String, CaseIterable, Codable, Equatable, Sendable {
    case idle
    case listen
    case think
    case speak
}

enum PresentationVoiceState: String, Codable, Equatable, Sendable {
    case idle
    case listening
    case transcribing
    case speaking
}

struct DemoVehicleContext: Codable, Equatable, Sendable {
    var speed: Int
    var gear: String
}

struct DemoEnvironmentContext: Codable, Equatable, Sendable {
    var weather: String
    var timePeriod: String
}

struct DemoContext: Codable, Equatable, Sendable {
    var vehicle: DemoVehicleContext
    var environment: DemoEnvironmentContext

    static let idle = DemoContext(
        vehicle: DemoVehicleContext(speed: 0, gear: "P"),
        environment: DemoEnvironmentContext(weather: "晴", timePeriod: "日间")
    )
}

/// A-2 mock-frontstage vocabulary container.
///
/// This carries presentation-safe state for UIUE without requiring the front stage
/// to read runtime traces, NLU output, voice state machines, or training receipts.
struct StagePresentationSnapshot: Equatable {
    var traceId: String
    var storeCells: [DemoVehicleStateCell]
    var activeCells: [FamilyCardID: String]
    var refusedCell: String?
    var scopeOrigins: [String: ScopeOrigin]
    var context: DemoContext
    var orbState: PresentationOrbState
    var voiceState: PresentationVoiceState
    var dialogText: String
    var readbacks: [DemoActionReadback]
    var resultKind: DemoRuntimeResultKind?
    var proofClass: StagePresentationProofClass

    init(
        traceId: String = UUID().uuidString,
        storeCells: [DemoVehicleStateCell],
        activeCells: [FamilyCardID: String] = [:],
        refusedCell: String? = nil,
        scopeOrigins: [String: ScopeOrigin] = [:],
        context: DemoContext = .idle,
        orbState: PresentationOrbState = .idle,
        voiceState: PresentationVoiceState = .idle,
        dialogText: String = "",
        readbacks: [DemoActionReadback] = [],
        resultKind: DemoRuntimeResultKind? = nil,
        proofClass: StagePresentationProofClass = .localMock
    ) {
        self.traceId = traceId
        self.storeCells = storeCells
        self.activeCells = activeCells
        self.refusedCell = refusedCell
        self.scopeOrigins = scopeOrigins
        self.context = context
        self.orbState = orbState
        self.voiceState = voiceState
        self.dialogText = dialogText
        self.readbacks = readbacks
        self.resultKind = resultKind
        self.proofClass = proofClass
    }
}

enum MockPresentationSnapshotProvider {
    static func coldStart() -> StagePresentationSnapshot {
        StagePresentationSnapshot(storeCells: [])
    }

    static func acStarted() -> StagePresentationSnapshot {
        StagePresentationSnapshot(
            storeCells: [
                DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied),
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1, visualState: .normal)
            ],
            activeCells: [.ac: "ac.power"],
            scopeOrigins: ["ac.power": .explicit],
            dialogText: "已为您打开空调",
            resultKind: .acceptedToolCall
        )
    }

    static func coolingMode() -> StagePresentationSnapshot {
        StagePresentationSnapshot(
            storeCells: [
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "26", revision: 2, visualState: .changing),
                DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷", revision: 2, visualState: .satisfied)
            ],
            activeCells: [.ac: "ac.temp_setpoint[主驾]"],
            scopeOrigins: ["ac.temp_setpoint[主驾]": .defaulted],
            dialogText: "我感觉有点冷了，帮您升高一点",
            resultKind: .acceptedToolCall
        )
    }

    static func safetyRefusal() -> StagePresentationSnapshot {
        StagePresentationSnapshot(
            storeCells: [
                DemoVehicleStateCell(key: "door.tailgate_height[尾门]", actualValue: "0", revision: 1, visualState: .unsafe)
            ],
            activeCells: [.door: "door.tailgate_height[尾门]"],
            refusedCell: "door.tailgate_height[尾门]",
            scopeOrigins: ["door.tailgate_height[尾门]": .explicit],
            context: DemoContext(
                vehicle: DemoVehicleContext(speed: 30, gear: "D"),
                environment: DemoEnvironmentContext(weather: "晴", timePeriod: "日间")
            ),
            orbState: .think,
            dialogText: "行驶中为了安全暂时不能开尾门，停稳后我再帮您",
            resultKind: .refusalSafetyOrPolicy
        )
    }
}

extension StagePresentationSnapshot {
    @MainActor
    static func from(
        store: DemoVehicleStateStore,
        activeCells: [FamilyCardID: String] = [:],
        context: DemoContext = .idle,
        resultKind: DemoRuntimeResultKind? = nil,
        traceId: String = UUID().uuidString,
        refusedCell: String? = nil,
        scopeOrigins: [String: ScopeOrigin] = [:],
        orbState: PresentationOrbState = .idle,
        voiceState: PresentationVoiceState = .idle,
        dialogText: String = "",
        readbacks: [DemoActionReadback] = [],
        proofClass: StagePresentationProofClass = .localMock
    ) -> StagePresentationSnapshot {
        StagePresentationSnapshot(
            traceId: traceId,
            storeCells: store.presentationCells,
            activeCells: activeCells,
            refusedCell: refusedCell,
            scopeOrigins: scopeOrigins,
            context: context,
            orbState: orbState,
            voiceState: voiceState,
            dialogText: dialogText,
            readbacks: readbacks,
            resultKind: resultKind,
            proofClass: proofClass
        )
    }
}
