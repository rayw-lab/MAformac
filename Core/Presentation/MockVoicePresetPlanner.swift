import Foundation

enum MockVoicePresetID: String, CaseIterable, Equatable, Sendable {
    case acAlreadyOffNoop = "mp01_ac_already_off_noop"
    case acOnTemp24 = "mp02_ac_on_temp_24"
    case windowOpen = "mp03_window_open"
    case windowOpenMore = "mp03_window_open_more"
    case movingDoorSafetyRefusal = "mp04_moving_door_safety_refusal"
    case movingTailgateSafetyRefusal = "mp04_moving_tailgate_safety_refusal"
}

enum MockVoiceUtteranceSource: String, Equatable, Sendable {
    case contractOriginal = "contract_original"
    case extraParaphraseLocal = "extra_paraphrase_local"
}

enum MockVoiceDialogCopySource: String, Equatable, Sendable {
    case demoScenariosYAML = "demo_scenarios_yaml"
    case stateCellsStructuredReadback = "state_cells_structured_readback"
    case localDialogCopy = "local_dialog_copy"
}

enum MockVoicePlanTiming: Equatable, Sendable {
    case eventDriven
    case safetyFixed(milliseconds: Int)
}

struct MockVoicePresetPlan: Equatable, Sendable {
    var presetID: MockVoicePresetID
    var utterance: String
    var utteranceSource: MockVoiceUtteranceSource
    var dialogText: String
    var dialogCopySource: MockVoiceDialogCopySource
    var cells: [DemoVehicleStateCell]
    var readbacks: [DemoActionReadback]
    var activeCells: [FamilyCardID: String]
    var refusedCell: String?
    var scopeOrigins: [String: ScopeOrigin]
    var resultKind: DemoRuntimeResultKind
    var orbState: PresentationOrbState
    var voiceState: PresentationVoiceState
    var proofClass: StagePresentationProofClass
    var timing: MockVoicePlanTiming
}

enum MockVoicePresetScript {
    static let defaultUtterances = [
        "关空调",
        "打开空调把温度调到24度",
        "打开车窗",
        "开大点",
        "打开车门"
    ]

    static func utterance(at index: Int) -> String {
        defaultUtterances[index % defaultUtterances.count]
    }
}

enum MockVoicePresetPlanner {
    static func plan(
        utterance rawUtterance: String,
        cells sourceCells: [DemoVehicleStateCell],
        context: DemoContext,
        priorReadbacks: [DemoActionReadback]
    ) -> MockVoicePresetPlan? {
        let utterance = rawUtterance.trimmingCharacters(in: .whitespacesAndNewlines)
        switch route(for: utterance) {
        case let .some(route):
            return plan(route: route, utterance: utterance, cells: sourceCells, context: context, priorReadbacks: priorReadbacks)
        case .none:
            return nil
        }
    }

    private static func plan(
        route: Route,
        utterance: String,
        cells sourceCells: [DemoVehicleStateCell],
        context: DemoContext,
        priorReadbacks: [DemoActionReadback]
    ) -> MockVoicePresetPlan? {
        switch route.presetID {
        case .acAlreadyOffNoop:
            return acAlreadyOffNoopPlan(route: route, utterance: utterance, cells: sourceCells)
        case .acOnTemp24:
            return acOnTemp24Plan(route: route, utterance: utterance, cells: sourceCells)
        case .windowOpen:
            return windowOpenPlan(route: route, utterance: utterance, cells: sourceCells)
        case .windowOpenMore:
            return windowOpenMorePlan(route: route, utterance: utterance, cells: sourceCells, priorReadbacks: priorReadbacks)
        case .movingDoorSafetyRefusal, .movingTailgateSafetyRefusal:
            guard isMoving(context: context, cells: sourceCells) else { return nil }
            return movingSafetyRefusalPlan(route: route, utterance: utterance, cells: sourceCells)
        }
    }

    private static func acAlreadyOffNoopPlan(
        route: Route,
        utterance: String,
        cells sourceCells: [DemoVehicleStateCell]
    ) -> MockVoicePresetPlan {
        let key = "ac.power"
        let current = cell(for: key, in: sourceCells)?.actualValue ?? "off"
        let revision = cell(for: key, in: sourceCells)?.revision ?? currentRevision(in: sourceCells)
        let dialog = current == "off" ? "空调已经是关闭的了" : "空调已经是关闭的了"
        let readback = DemoActionReadback(key: key, actualValue: current, revision: revision, spokenText: dialog)
        return basePlan(
            route: route,
            utterance: utterance,
            dialogText: dialog,
            dialogCopySource: .demoScenariosYAML,
            cells: sourceCells,
            readbacks: [readback],
            activeCells: [.ac: key],
            resultKind: .alreadyStateNoop,
            scopeOrigins: [key: .explicit],
            timing: .eventDriven
        )
    }

    private static func acOnTemp24Plan(
        route: Route,
        utterance: String,
        cells sourceCells: [DemoVehicleStateCell]
    ) -> MockVoicePresetPlan {
        var cells = sourceCells
        let powerReadback = apply(key: "ac.power", value: "on", visualState: .satisfied, in: &cells, spokenText: "空调已打开")
        let tempReadback = apply(key: "ac.temp_setpoint[主驾]", value: "24", visualState: .changing, in: &cells, spokenText: "空调已打开, 温度24度")
        let tempKey = "ac.temp_setpoint[主驾]"
        return basePlan(
            route: route,
            utterance: utterance,
            dialogText: "空调已打开, 温度24度",
            dialogCopySource: .demoScenariosYAML,
            cells: cells,
            readbacks: [powerReadback, tempReadback],
            activeCells: [.ac: tempKey],
            resultKind: .acceptedToolCall,
            scopeOrigins: ["ac.power": .explicit, tempKey: .explicit],
            timing: .eventDriven
        )
    }

    private static func windowOpenPlan(
        route: Route,
        utterance: String,
        cells sourceCells: [DemoVehicleStateCell]
    ) -> MockVoicePresetPlan {
        var cells = sourceCells
        let key = "window.position[主驾]"
        let readback = apply(key: key, value: "25", visualState: .changing, in: &cells, spokenText: "主驾车窗开度25%")
        return basePlan(
            route: route,
            utterance: utterance,
            dialogText: "主驾车窗开度25%",
            dialogCopySource: .stateCellsStructuredReadback,
            cells: cells,
            readbacks: [readback],
            activeCells: [.window: key],
            resultKind: .acceptedToolCall,
            scopeOrigins: [key: .defaulted],
            timing: .eventDriven
        )
    }

    private static func windowOpenMorePlan(
        route: Route,
        utterance: String,
        cells sourceCells: [DemoVehicleStateCell],
        priorReadbacks: [DemoActionReadback]
    ) -> MockVoicePresetPlan {
        var cells = sourceCells
        let focusedKey = windowFocusKey(from: priorReadbacks) ?? "window.position[主驾]"
        let current = Int(cell(for: focusedKey, in: cells)?.actualValue ?? "") ?? 25
        let target = min(100, current + 20)
        let readback = apply(key: focusedKey, value: "\(target)", visualState: .changing, in: &cells, spokenText: "车窗已开大")
        return basePlan(
            route: route,
            utterance: utterance,
            dialogText: "车窗已开大",
            dialogCopySource: .demoScenariosYAML,
            cells: cells,
            readbacks: [readback],
            activeCells: [.window: focusedKey],
            resultKind: .acceptedToolCall,
            scopeOrigins: [focusedKey: .defaulted],
            timing: .eventDriven
        )
    }

    private static func movingSafetyRefusalPlan(
        route: Route,
        utterance: String,
        cells sourceCells: [DemoVehicleStateCell]
    ) -> MockVoicePresetPlan {
        var cells = sourceCells
        let key = route.presetID == .movingTailgateSafetyRefusal ? "door.tailgate_height" : "door.car_door"
        ensureCell(key: key, in: &cells)
        markCell(key: key, visualState: DemoRuntimeResultPresentationMatrix.errorEntry(for: .safety).visualState, in: &cells)
        let current = cell(for: key, in: cells)?.actualValue ?? defaultValue(for: key)
        let revision = cell(for: key, in: cells)?.revision ?? currentRevision(in: cells)
        let dialog = "行驶中为了安全暂时不能开门, 停稳后我再帮您"
        let readback = DemoActionReadback(key: key, actualValue: current, revision: revision, spokenText: dialog)
        return basePlan(
            route: route,
            utterance: utterance,
            dialogText: dialog,
            dialogCopySource: .demoScenariosYAML,
            cells: cells,
            readbacks: [readback],
            activeCells: [.door: key],
            refusedCell: key,
            resultKind: .refusalSafetyOrPolicy,
            scopeOrigins: [key: .explicit],
            timing: .safetyFixed(milliseconds: 1000)
        )
    }

    private static func basePlan(
        route: Route,
        utterance: String,
        dialogText: String,
        dialogCopySource: MockVoiceDialogCopySource,
        cells: [DemoVehicleStateCell],
        readbacks: [DemoActionReadback],
        activeCells: [FamilyCardID: String],
        refusedCell: String? = nil,
        resultKind: DemoRuntimeResultKind,
        scopeOrigins: [String: ScopeOrigin],
        timing: MockVoicePlanTiming
    ) -> MockVoicePresetPlan {
        MockVoicePresetPlan(
            presetID: route.presetID,
            utterance: utterance,
            utteranceSource: route.source,
            dialogText: dialogText,
            dialogCopySource: dialogCopySource,
            cells: cells,
            readbacks: readbacks,
            activeCells: activeCells,
            refusedCell: refusedCell,
            scopeOrigins: scopeOrigins,
            resultKind: resultKind,
            orbState: .speak,
            voiceState: .idle,
            proofClass: .simulatorMock,
            timing: timing
        )
    }

    private static func apply(
        key: String,
        value: String,
        visualState: DemoVisualState,
        in cells: inout [DemoVehicleStateCell],
        spokenText: String
    ) -> DemoActionReadback {
        ensureCell(key: key, in: &cells)
        guard let index = cells.firstIndex(where: { $0.key == key }) else {
            return DemoActionReadback(key: key, actualValue: "missing", revision: currentRevision(in: cells), spokenText: "状态未定义")
        }
        cells[index].desiredValue = value
        cells[index].actualValue = value
        cells[index].source = .mock
        cells[index].revision += 1
        cells[index].timestamp = Date()
        cells[index].visualState = visualState
        return DemoActionReadback(key: key, actualValue: value, revision: cells[index].revision, spokenText: spokenText)
    }

    private static func ensureCell(key: String, in cells: inout [DemoVehicleStateCell]) {
        guard !cells.contains(where: { $0.key == key }) else { return }
        cells.append(DemoVehicleStateCell(
            key: key,
            actualValue: defaultValue(for: key),
            source: .mock,
            revision: currentRevision(in: cells),
            visualState: .normal
        ))
    }

    private static func markCell(key: String, visualState: DemoVisualState, in cells: inout [DemoVehicleStateCell]) {
        guard let index = cells.firstIndex(where: { $0.key == key }) else { return }
        cells[index].source = .mock
        cells[index].timestamp = Date()
        cells[index].visualState = visualState
    }

    private static func defaultValue(for key: String) -> String {
        let base = scopedBase(for: key)
        if let value = StateCellPresentationCatalog.shared.defaultValue(for: base) {
            return value
        }
        switch base {
        case "ac.power": return "off"
        case "ac.temp_setpoint": return "24"
        case "window.position": return "0"
        case "door.car_door": return "closed"
        case "door.tailgate_height": return "0"
        case "vehicle.speed": return "0"
        case "vehicle.gear": return "P"
        default: return ""
        }
    }

    private static func cell(for key: String, in cells: [DemoVehicleStateCell]) -> DemoVehicleStateCell? {
        cells.first { $0.key == key }
    }

    private static func currentRevision(in cells: [DemoVehicleStateCell]) -> Int {
        cells.map(\.revision).max() ?? 0
    }

    private static func scopedBase(for key: String) -> String {
        key.split(separator: "[").first.map(String.init) ?? key
    }

    private static func windowFocusKey(from priorReadbacks: [DemoActionReadback]) -> String? {
        guard let key = priorReadbacks.last?.key, scopedBase(for: key) == "window.position" else { return nil }
        return key
    }

    private static func isMoving(context: DemoContext, cells: [DemoVehicleStateCell]) -> Bool {
        let speed = Int(cell(for: "vehicle.speed", in: cells)?.actualValue ?? "") ?? context.vehicle.speed
        let gear = cell(for: "vehicle.gear", in: cells)?.actualValue ?? context.vehicle.gear
        return speed > 0 && gear != "P"
    }

    private static func route(for utterance: String) -> Route? {
        if mp01ContractOriginals.contains(utterance) {
            return Route(presetID: .acAlreadyOffNoop, source: .contractOriginal)
        }
        if utterance == "空调关一下" {
            return Route(presetID: .acAlreadyOffNoop, source: .extraParaphraseLocal)
        }
        if mp02ContractOriginals.contains(utterance) {
            return Route(presetID: .acOnTemp24, source: .contractOriginal)
        }
        if mp03Turn1ContractOriginals.contains(utterance) {
            return Route(presetID: .windowOpen, source: .contractOriginal)
        }
        if mp03Turn2ContractOriginals.contains(utterance) {
            return Route(presetID: .windowOpenMore, source: .contractOriginal)
        }
        if utterance == "开个后备箱" {
            return Route(presetID: .movingTailgateSafetyRefusal, source: .contractOriginal)
        }
        if mp04DoorContractOriginals.contains(utterance) {
            return Route(presetID: .movingDoorSafetyRefusal, source: .contractOriginal)
        }
        return nil
    }

    private struct Route: Equatable, Sendable {
        var presetID: MockVoicePresetID
        var source: MockVoiceUtteranceSource
    }

    private static let mp01ContractOriginals: Set<String> = ["关空调", "把空调关了", "空调关掉", "不用空调了"]
    private static let mp02ContractOriginals: Set<String> = ["打开空调把温度调到24度", "开空调调到24度", "空调打开设成24", "把空调开了温度24"]
    private static let mp03Turn1ContractOriginals: Set<String> = ["打开车窗", "把车窗开开", "开一下窗户"]
    private static let mp03Turn2ContractOriginals: Set<String> = ["开大点", "再开大些", "拉大一点", "再大点"]
    private static let mp04DoorContractOriginals: Set<String> = ["打开车门", "把车门打开", "开一下门", "车门开开"]
}
