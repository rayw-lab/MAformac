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

private struct PlannedTransition: Equatable {
    var transition: DemoMockTransition
    var scopeOrigin: ScopeOrigin?
}

private struct SettledPlan {
    var parentRequestFingerprint: String
    var transitions: [PlannedTransition]
}

private final class RuntimeAdapterBox: @unchecked Sendable {
    @MainActor
    private var adapter: DemoRuntimeAdapter?
    @MainActor
    private var settledPlans: [String: SettledPlan] = [:]

    @MainActor
    func resolve() -> DemoRuntimeAdapter {
        if let adapter {
            return adapter
        }
        let adapter = DemoRuntimeAdapter()
        self.adapter = adapter
        return adapter
    }

    @MainActor
    func recordSettledPlanIfAbsent(parentID: String, parentRequestFingerprint: String, transitions: [PlannedTransition]) {
        guard settledPlans[parentID] == nil else {
            return
        }
        settledPlans[parentID] = SettledPlan(
            parentRequestFingerprint: parentRequestFingerprint,
            transitions: transitions
        )
    }

    @MainActor
    func settledPlan(parentID: String) -> SettledPlan? {
        settledPlans[parentID]
    }
}

public struct C3ExecutionPipeline: Sendable {
    public var semantic: SemanticContractLookup
    public var stateCells: StateCellContractLookup
    public var riskPolicy: RiskPolicyLookup
    public var allowlist: L1DemoAllowlistLookup
    private let runtimeAdapterBox: RuntimeAdapterBox
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
        self.runtimeAdapterBox = RuntimeAdapterBox()
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

        if frame.stateRevision < store.currentRevision,
           let replay = try replaySettledStaleRequestIfAvailable(frame, store: store, traceLogger: traceLogger) {
            return replay
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
        traceLogger.recordPlan(
            traceID: frame.traceID,
            message: transitions.map { "\($0.transition.key)=\($0.transition.desiredValue)" }.joined(separator: ",")
        )
        traceLogger.recordGuard(traceID: frame.traceID, message: "allow", attributes: TraceAttributes(guardReason: "allow"))

        var readbacks: [DemoActionReadback] = []
        for planned in transitions {
            let transition = planned.transition
            let commandID = adapterCommandID(parent: frame, transition: transition)
            let adapterResult = try runtimeAdapterBox.resolve().execute(
                commandID: commandID,
                frame: adapterFrame(parent: frame, transition: transition, commandID: commandID),
                store: store
            )
            traceLogger.recordExecute(
                traceID: frame.traceID,
                message: "\(adapterResult.readback.key)=\(adapterResult.readback.actualValue):\(adapterResult.provenance.rawValue)"
            )
            var verified = try C2ReadbackVerifier.verify(store: store, key: transition.key, expectedValue: transition.desiredValue)
            verified.scopeOrigin = planned.scopeOrigin
            // gap#5:播报优先消费 C2 readback_zh 模板,而非 store 硬编码兜底。
            if let rendered = stateCells.renderReadback(
                stateKey: transition.key,
                scope: scope(forKey: transition.key),
                value: verified.actualValue,
                scopeOrigin: planned.scopeOrigin
            ) {
                verified.spokenText = rendered
            }
            traceLogger.recordReadback(
                traceID: frame.traceID,
                message: verified.spokenText,
                attributes: TraceAttributes(readbackResult: .verified)
            )
            readbacks.append(verified)
        }
        runtimeAdapterBox.recordSettledPlanIfAbsent(
            parentID: frame.id,
            parentRequestFingerprint: parentRequestFingerprint(for: frame),
            transitions: transitions
        )

        return C3ExecutionResult(traceID: frame.traceID, readbacks: readbacks)
    }

    @MainActor
    private func replaySettledStaleRequestIfAvailable(
        _ frame: ToolCallFrame,
        store: DemoVehicleStateStore,
        traceLogger: any TraceLogger
    ) throws -> C3ExecutionResult? {
        guard let settledPlan = runtimeAdapterBox.settledPlan(parentID: frame.id),
              settledPlan.parentRequestFingerprint == parentRequestFingerprint(for: frame) else {
            return nil
        }
        let adapter = runtimeAdapterBox.resolve()
        var replayed: [(PlannedTransition, DemoRuntimeAdapterResult)] = []
        for planned in settledPlan.transitions {
            let transition = planned.transition
            let commandID = adapterCommandID(parent: frame, transition: transition)
            guard let adapterResult = try adapter.replayIfSettled(
                commandID: commandID,
                frame: adapterFrame(parent: frame, transition: transition, commandID: commandID),
                store: store
            ) else {
                return nil
            }
            replayed.append((planned, adapterResult))
        }

        traceLogger.recordGuard(traceID: frame.traceID, message: "stale_retry_replay", attributes: TraceAttributes(guardReason: "stale_retry_replay"))
        var readbacks: [DemoActionReadback] = []
        for (planned, adapterResult) in replayed {
            let transition = planned.transition
            traceLogger.recordExecute(
                traceID: frame.traceID,
                message: "\(adapterResult.readback.key)=\(adapterResult.readback.actualValue):\(adapterResult.provenance.rawValue)"
            )
            var verified = try C2ReadbackVerifier.verify(
                store: store,
                key: transition.key,
                expectedValue: adapterResult.readback.actualValue
            )
            verified.scopeOrigin = planned.scopeOrigin
            if let rendered = stateCells.renderReadback(
                stateKey: transition.key,
                scope: scope(forKey: transition.key),
                value: verified.actualValue,
                scopeOrigin: planned.scopeOrigin
            ) {
                verified.spokenText = rendered
            }
            traceLogger.recordReadback(
                traceID: frame.traceID,
                message: verified.spokenText,
                attributes: TraceAttributes(readbackResult: .verified)
            )
            readbacks.append(verified)
        }
        return C3ExecutionResult(traceID: frame.traceID, readbacks: readbacks)
    }

    private func adapterCommandID(parent frame: ToolCallFrame, transition: DemoMockTransition) -> String {
        "\(frame.id)#\(transition.key)"
    }

    private func parentRequestFingerprint(for frame: ToolCallFrame) -> String {
        let slots = frame.slots
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "\u{1E}")
        return [
            "tool=\(frame.toolName)",
            "device=\(frame.device)",
            "primitive=\(frame.actionPrimitive)",
            "slots=\(slots)",
            "value.ref=\(frame.value.ref)",
            "value.direct=\(frame.value.direct)",
            "value.offset=\(frame.value.offset)",
            "value.type=\(frame.value.type)",
            "state_revision=\(frame.stateRevision)",
            "source=\(frame.candidateSource.rawValue)"
        ].joined(separator: "\u{1F}")
    }

    private func adapterFrame(parent frame: ToolCallFrame, transition: DemoMockTransition, commandID: String) -> ToolCallFrame {
        ToolCallFrame(
            id: commandID,
            traceID: frame.traceID,
            agentID: frame.agentID,
            capabilityID: frame.capabilityID,
            toolName: "set_vehicle_control",
            arguments: [
                "state_key": transition.key,
                "target_state": transition.desiredValue
            ],
            surfacePolicy: frame.surfacePolicy
        )
    }

    @MainActor
    private func planTransitions(for frame: ToolCallFrame, store: DemoVehicleStateStore) throws -> [PlannedTransition] {
        guard let cellID = executionCellID(for: frame) else {
            throw ToolExecutionError.semanticInvalid("no_execution_cell")
        }
        guard let cell = stateCells.cell(id: cellID) else {
            throw ToolExecutionError.semanticInvalid("missing_c2_cell:\(cellID)")
        }

        var transitions: [PlannedTransition] = []
        if frame.device == "ac_temperature",
           frame.actionPrimitive != "query",
           store.cell(for: "ac.power")?.actualValue != "on" {
            transitions.append(PlannedTransition(
                transition: DemoMockTransition(key: "ac.power", desiredValue: "on"),
                scopeOrigin: nil
            ))
        }

        let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)
        for key in resolution.keys {
            let desiredValue = try normalizeValue(frame: frame, cell: cell, key: key, store: store)
            transitions.append(PlannedTransition(
                transition: DemoMockTransition(key: key, desiredValue: desiredValue),
                scopeOrigin: resolution.origin
            ))
        }
        return transitions
    }

    private func executionCellID(for frame: ToolCallFrame) -> String? {
        if let entry = allowlist.entry(device: frame.device) {
            return entry.executionRangeCell
        }
        // 复用 ToolContractStateApplier.deviceCellMap 单一 SSOT(消除 C3 switch / S2 deviceCellMap / allowlist
        // 三处 device→cell 平行硬编码分叉, claim-vs-reality 铁律1; 并 fix C3 旧 switch 缺 ac_windspeed)。
        return ToolContractStateApplier.deviceCellMap[frame.device]
    }

    /// 从 scoped mock key(如 `ac.temp_setpoint[主驾]`)提取 scope 段;无 scope 返回 nil。
    private func scope(forKey key: String) -> String? {
        guard let open = key.firstIndex(of: "["), let close = key.firstIndex(of: "]"), open < close else {
            return nil
        }
        return String(key[key.index(after: open)..<close])
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
