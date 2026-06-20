import Foundation

public struct C3ExecutionResult: Equatable, Sendable {
    public var traceID: String
    public var readbacks: [DemoActionReadback]

    public init(traceID: String, readbacks: [DemoActionReadback]) {
        self.traceID = traceID
        self.readbacks = readbacks
    }
}

public struct C2ReadbackVerifier: Sendable {
    @MainActor
    public static func verify(store: DemoVehicleStateStore, key: String, expectedValue: String) throws -> DemoActionReadback {
        guard let cell = store.cell(for: key) else {
            throw ToolExecutionError.readbackMismatch(expected: expectedValue, actual: "missing")
        }
        guard cell.actualValue == expectedValue else {
            throw ToolExecutionError.readbackMismatch(expected: expectedValue, actual: cell.actualValue)
        }
        return DemoActionReadback(
            key: cell.key,
            actualValue: cell.actualValue,
            revision: cell.revision,
            spokenText: DemoVehicleStateStore.spokenText(for: cell)
        )
    }
}

public struct C3ExecutionPipeline: Sendable {
    public var semantic: SemanticContractLookup
    public var stateCells: StateCellContractLookup
    public var riskPolicy: RiskPolicyLookup
    public var allowlist: L1DemoAllowlistLookup
    private let intentConfirmedProvider: @Sendable () -> Bool

    public init(
        semantic: SemanticContractLookup,
        stateCells: StateCellContractLookup,
        riskPolicy: RiskPolicyLookup,
        allowlist: L1DemoAllowlistLookup,
        intentConfirmed: @escaping @Sendable () -> Bool = { true }
    ) {
        self.semantic = semantic
        self.stateCells = stateCells
        self.riskPolicy = riskPolicy
        self.allowlist = allowlist
        self.intentConfirmedProvider = intentConfirmed
    }

    @MainActor
    public func execute(
        _ frame: ToolCallFrame,
        store: DemoVehicleStateStore,
        traceLogger: any TraceLogger
    ) throws -> C3ExecutionResult {
        let decodeAttributes = TraceAttributes(
            candidateSource: frame.candidateSource,
            toolCallCount: 1,
            repairUsed: frame.candidateSource == .parserRepair
        )
        traceLogger.recordDecode(
            traceID: frame.traceID,
            message: "\(frame.candidateSource.rawValue):\(frame.device).\(frame.actionPrimitive)",
            attributes: decodeAttributes
        )

        guard let semanticRow = semantic.first(device: frame.device, actionPrimitive: frame.actionPrimitive) else {
            traceLogger.recordGuard(traceID: frame.traceID, message: "semantic_invalid", attributes: TraceAttributes(guardReason: "semantic_invalid"))
            throw ToolExecutionError.semanticInvalid("unknown_device_or_primitive")
        }

        // L1 primitive gate (gap#3 / design E7):device 在 L1 allowlist 内时,只有 reviewed primitives
        // 才能走 L1 精做执行。合法 C1 但非 reviewed 的 primitive(如 ac_temperature.increase_by_number)
        // 不得被当 L1 静默执行,deny 让其在全系统中改走 L2。
        if let entry = allowlist.entry(device: frame.device),
           !entry.primitives.isEmpty,
           !entry.primitives.contains(frame.actionPrimitive) {
            traceLogger.recordGuard(traceID: frame.traceID, message: "primitive_not_in_l1_allowlist", attributes: TraceAttributes(guardReason: "primitive_not_in_l1_allowlist"))
            throw ToolExecutionError.guardDenied("primitive_not_in_l1_allowlist")
        }

        if semanticRow.clarifyTag == "implicit", !intentConfirmedProvider() {
            traceLogger.recordGuard(traceID: frame.traceID, message: "intent_not_confirmed", attributes: TraceAttributes(guardReason: "intent_not_confirmed"))
            throw ToolExecutionError.guardDenied("intent_not_confirmed")
        }

        guard frame.stateRevision >= store.currentRevision else {
            traceLogger.recordGuard(traceID: frame.traceID, message: "stale_state", attributes: TraceAttributes(guardReason: "stale_state"))
            throw ToolExecutionError.staleState(expected: store.currentRevision, actual: frame.stateRevision)
        }

        switch riskPolicy.evaluate(device: frame.device, stateValues: store.stateValues) {
        case .allow:
            break
        case .confirm(let reason):
            traceLogger.recordGuard(traceID: frame.traceID, message: reason, attributes: TraceAttributes(guardReason: reason))
            throw ToolExecutionError.guardDenied(reason)
        case .refuse(let reason):
            traceLogger.recordGuard(traceID: frame.traceID, message: reason, attributes: TraceAttributes(guardReason: reason))
            throw ToolExecutionError.guardDenied(reason)
        }

        let transitions = try planTransitions(for: frame, store: store)
        traceLogger.recordPlan(traceID: frame.traceID, message: transitions.map { "\($0.key)=\($0.desiredValue)" }.joined(separator: ","))
        traceLogger.recordGuard(traceID: frame.traceID, message: "allow", attributes: TraceAttributes(guardReason: "allow"))

        var readbacks: [DemoActionReadback] = []
        for transition in transitions {
            let applied = store.applyMockTransition(transition)
            traceLogger.recordExecute(traceID: frame.traceID, message: "\(applied.key)=\(applied.actualValue)")
            let verified = try C2ReadbackVerifier.verify(store: store, key: transition.key, expectedValue: transition.desiredValue)
            traceLogger.recordReadback(
                traceID: frame.traceID,
                message: verified.spokenText,
                attributes: TraceAttributes(readbackResult: .verified)
            )
            readbacks.append(verified)
        }

        return C3ExecutionResult(traceID: frame.traceID, readbacks: readbacks)
    }

    @MainActor
    private func planTransitions(for frame: ToolCallFrame, store: DemoVehicleStateStore) throws -> [DemoMockTransition] {
        guard let cellID = executionCellID(for: frame) else {
            throw ToolExecutionError.semanticInvalid("no_execution_cell")
        }
        guard let cell = stateCells.cell(id: cellID) else {
            throw ToolExecutionError.semanticInvalid("missing_c2_cell:\(cellID)")
        }

        var transitions: [DemoMockTransition] = []
        if frame.device == "ac_temperature",
           frame.actionPrimitive != "query",
           store.cell(for: "ac.power")?.actualValue != "on" {
            transitions.append(DemoMockTransition(key: "ac.power", desiredValue: "on"))
        }

        for key in try targetKeys(for: frame, cell: cell) {
            let desiredValue = try normalizeValue(frame: frame, cell: cell, key: key, store: store)
            transitions.append(DemoMockTransition(key: key, desiredValue: desiredValue))
        }
        return transitions
    }

    private func executionCellID(for frame: ToolCallFrame) -> String? {
        if let entry = allowlist.entry(device: frame.device) {
            return entry.executionRangeCell
        }
        switch frame.device {
        case "ac_temperature":
            return "ac.temp_setpoint"
        case "window":
            return "window.position"
        case "screen_brightness":
            return "screen.brightness"
        case "atmosphere_lamp_brightness":
            return "ambient.brightness"
        case "atmosphere_lamp_color":
            return "ambient.color"
        case "ac":
            return "ac.power"
        default:
            return nil
        }
    }

    private func targetKeys(for frame: ToolCallFrame, cell: StateCellDefinition) throws -> [String] {
        guard !cell.scope.isEmpty else {
            return [cell.id]
        }

        let requested = frame.slots["direction"]
            ?? frame.slots["position"]
            ?? frame.slots["screen_type"]
            ?? frame.slots["name"]
            ?? "全车"

        if requested == "全车" {
            return cell.scope
                .filter { $0 != "全车" && !$0.hasSuffix("屏") && !$0.hasSuffix("氛围灯") }
                .map { scopedKey(cell.id, scope: $0) }
        }
        guard cell.scope.contains(requested) else {
            throw ToolExecutionError.semanticInvalid("slot_out_of_scope")
        }
        return [scopedKey(cell.id, scope: requested)]
    }

    private func scopedKey(_ cellID: String, scope: String) -> String {
        "\(cellID)[\(scope)]"
    }

    @MainActor
    private func normalizeValue(
        frame: ToolCallFrame,
        cell: StateCellDefinition,
        key: String,
        store: DemoVehicleStateStore
    ) throws -> String {
        if cell.type == "enum" {
            if cell.id == "ac.power" {
                return frame.actionPrimitive == "power_off" ? "off" : "on"
            }
            if cell.id == "ambient.color" {
                guard cell.values.contains(frame.value.offset) else {
                    throw ToolExecutionError.schemaInvalid(.unknownEnum("ambient.color"))
                }
                return frame.value.offset
            }
        }

        guard let range = cell.executionRange else {
            throw ToolExecutionError.semanticInvalid("missing_execution_range")
        }

        let current = Int(store.cell(for: key)?.actualValue ?? "") ?? range.min
        let desired: Int
        switch frame.actionPrimitive {
        case "power_on":
            desired = range.max
        case "power_off":
            desired = range.min
        case "adjust_to_max":
            desired = cell.extremeMap["MAX"] ?? range.max
        case "adjust_to_min":
            desired = cell.extremeMap["MIN"] ?? range.min
        default:
            desired = try normalizeNumericValue(frame: frame, cell: cell, current: current, range: range)
        }

        guard range.contains(desired) else {
            throw ToolExecutionError.schemaInvalid(.outOfRange(cell.id))
        }
        return String(desired)
    }

    private func normalizeNumericValue(
        frame: ToolCallFrame,
        cell: StateCellDefinition,
        current: Int,
        range: ExecutionRange
    ) throws -> Int {
        switch frame.value.type {
        case "EXP":
            let step = cell.expStepLittle ?? range.step
            let sign = frame.value.direct == "-" || frame.actionPrimitive.hasPrefix("decrease") ? -1 : 1
            return current + sign * step
        case "SPOT", "PERCENT":
            if let numeric = Int(frame.value.offset) {
                if frame.value.ref == "CUR" {
                    let sign = frame.value.direct == "-" ? -1 : 1
                    return current + sign * numeric
                }
                return numeric
            }
            if let gear = cell.gearMap[frame.value.offset] {
                return gear
            }
            throw ToolExecutionError.schemaInvalid(.typeMismatch("value.offset"))
        case "":
            if frame.actionPrimitive == "query" {
                return current
            }
            throw ToolExecutionError.schemaInvalid(.missingField("value.type"))
        default:
            throw ToolExecutionError.schemaInvalid(.unknownEnum("value.type"))
        }
    }
}
