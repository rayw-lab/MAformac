import Foundation

public struct DemoSliceCatalogEntry: Equatable, Sendable {
    public let matrixID: Int
    public let contractRowID: String
    public let stateBase: String

    public init(matrixID: Int, contractRowID: String, stateBase: String) {
        self.matrixID = matrixID
        self.contractRowID = contractRowID
        self.stateBase = stateBase
    }
}

public struct DemoSliceAdmission: Equatable, Sendable {
    public let entry: DemoSliceCatalogEntry
    public let frame: ToolCallFrame

    public init(entry: DemoSliceCatalogEntry, frame: ToolCallFrame) {
        self.entry = entry
        self.frame = frame
    }
}

public enum DemoSliceAdmissionRejection: Equatable, Sendable {
    case blank
    case notInCatalog
    case valueOutOfRange(actual: Int, allowed: ClosedRange<Int>)
    case clarifyMissingSlot
    case conjunctionOrMultiIntent
}

public struct DemoSliceDesiredTarget: Equatable, Sendable {
    public let key: String
    public let desired: String

    public init(key: String, desired: String) {
        self.key = key
        self.desired = desired
    }
}

public struct StateQuerySpec: Equatable, Sendable {
    public let stateBase: String
    public let scopeHint: String?

    public init(stateBase: String, scopeHint: String? = nil) {
        self.stateBase = stateBase
        self.scopeHint = scopeHint
    }
}

public struct CapabilityQuerySpec: Equatable, Sendable {
    public let stateBase: String
    public let probedTemperature: Int?

    public init(stateBase: String, probedTemperature: Int? = nil) {
        self.stateBase = stateBase
        self.probedTemperature = probedTemperature
    }
}

/// One-shot typed classification for the finite reviewed demo surface.
/// Callers must not re-run admission then rejection.
public enum DemoSliceClassification: Equatable, Sendable {
    case command(DemoSliceAdmission)
    case stateQuery(StateQuerySpec)
    case capabilityQuery(CapabilityQuerySpec)
    case clarification(reason: String)
    case contractRefusal(DemoSliceAdmissionRejection)
    case cancel(target: String?)
}

/// Customer-path admission for the finite, reviewed product surface.
/// Every unmatched utterance remains fail-closed.
public struct DemoSliceAdmissionCatalog: Sendable {
    public let routeMode = "demo_slice"
    public var catalogDigestSHA256: String {
        let canonical = entries
            .map { "\($0.matrixID)|\($0.contractRowID)|\($0.stateBase)" }
            .joined(separator: "\n") + "\n"
        return C6Hash.sha256Hex(Data(canonical.utf8))
    }
    public let entries: [DemoSliceCatalogEntry] = [
        DemoSliceCatalogEntry(
            matrixID: 1,
            contractRowID: "c1_airControl_000006",
            stateBase: "ac.power"
        ),
        DemoSliceCatalogEntry(
            matrixID: 4,
            contractRowID: "c1_airControl_000164",
            stateBase: "ac.temp_setpoint"
        ),
        DemoSliceCatalogEntry(
            matrixID: 31,
            contractRowID: "c1_carControl_000021",
            stateBase: "window.position"
        ),
        DemoSliceCatalogEntry(
            matrixID: 1972,
            contractRowID: "c1_carControl_001972",
            stateBase: "ambient.power"
        ),
        DemoSliceCatalogEntry(
            matrixID: 201,
            contractRowID: "c1_carControl_000201",
            stateBase: "seat.heat_level"
        ),
    ]

    private let temperatureRange = 18 ... 32

    public init() {}

    /// Single classification entry. Prefer this over `admission`/`rejection` dual-pass.
    public func classify(for text: String) -> DemoSliceClassification {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty {
            return .contractRefusal(.blank)
        }
        if hasConjunctionOrMultiIntent(normalized) {
            return .contractRefusal(.conjunctionOrMultiIntent)
        }
        if normalized.hasPrefix("不对，") {
            let rest = String(normalized.dropFirst("不对，".count))
            if rest.isEmpty {
                return .clarification(reason: "incomplete_correction")
            }
            // Correction wrapper is exact `不对，` only; re-classify the remainder
            // without allowing another correction wrapper nest.
            if rest.hasPrefix("不对，") {
                return .clarification(reason: "nested_correction")
            }
            let inner = classifyBody(rest)
            if case .command = inner {
                return inner
            }
            return .clarification(reason: "incomplete_correction")
        }
        return classifyBody(normalized)
    }

    public func admission(for text: String) -> DemoSliceAdmission? {
        if case let .command(admission) = classify(for: text) {
            return admission
        }
        return nil
    }

    public func rejection(for text: String) -> DemoSliceAdmissionRejection? {
        switch classify(for: text) {
        case .command:
            return nil
        case .clarification:
            return .clarifyMissingSlot
        case let .contractRefusal(reason):
            return reason
        case .stateQuery, .capabilityQuery, .cancel:
            // Query/cancel are not rejections; route handles them.
            return nil
        }
    }

    private func classifyBody(_ normalized: String) -> DemoSliceClassification {
        if normalized == "打开空调" {
            return .command(powerOnAdmission(entry: entries[0], device: "ac", capabilityID: "vehicle.ac.toggle", toolName: "set_vehicle_control"))
        }
        if normalized == "把主驾车窗再开50%" {
            let entry = entries[2]
            return .command(
                DemoSliceAdmission(
                    entry: entry,
                    frame: ToolCallFrame(
                        agentID: "vehicle-control",
                        capabilityID: "vehicle.window.position",
                        toolName: "open_window_by_number",
                        device: "window",
                        actionPrimitive: "by_percent",
                        slots: ["position": "主驾"],
                        value: ContractValue(
                            ref: "CUR",
                            direct: "+",
                            offset: "50",
                            type: "PERCENT"
                        ),
                        candidateSource: .fastPath,
                        rawPayload: evidencePayload(entry: entry, inputValue: 50),
                        surfacePolicy: .primaryPanel
                    )
                )
            )
        }
        if normalized == "打开氛围灯" {
            return .command(
                powerOnAdmission(
                    entry: entries[3],
                    device: "atmosphere_lamp",
                    capabilityID: "vehicle.ambient_light.power",
                    toolName: "open_atmosphere_lamp"
                )
            )
        }
        if normalized == "打开副驾座椅加热" {
            let entry = entries[4]
            return .command(
                DemoSliceAdmission(
                    entry: entry,
                    frame: ToolCallFrame(
                        agentID: "vehicle-control",
                        capabilityID: "vehicle.seat_heating.power",
                        toolName: "open_seat_heat",
                        device: "seat_heat",
                        actionPrimitive: "power_on",
                        slots: ["position": "副驾"],
                        value: ContractValue(offset: "on", type: "STATE"),
                        candidateSource: .fastPath,
                        rawPayload: evidencePayload(entry: entry, inputValue: nil),
                        surfacePolicy: .primaryPanel
                    )
                )
            )
        }

        if normalized == "现在空调多少度" {
            return .stateQuery(StateQuerySpec(stateBase: "ac.temp_setpoint", scopeHint: "主驾"))
        }
        if normalized == "空调支持多少度" {
            return .capabilityQuery(CapabilityQuerySpec(stateBase: "ac.temp_setpoint"))
        }
        if normalized == "空调" {
            return .clarification(reason: "missing_slot")
        }
        if normalized == "改成24度" || normalized.hasPrefix("改成") {
            return .clarification(reason: "incomplete_correction")
        }

        if let capability = matchCapabilityTemperature(normalized) {
            return capability
        }
        if let commandOrRefusal = matchCommandTemperature(normalized) {
            return commandOrRefusal
        }
        return .contractRefusal(.notInCatalog)
    }

    private func matchCapabilityTemperature(_ text: String) -> DemoSliceClassification? {
        // Capability templates are disjoint from polite command `能调到{N}度吗`.
        let templates: [(prefix: String, allowsQuestionSuffix: Bool)] = [
            ("空调能调到", true),
            ("你能调到", true),
            ("能不能调到", true),
            ("可以调到", true),
        ]
        for template in templates {
            guard let temperature = parseExactTemperature(
                text,
                prefix: template.prefix,
                allowsQuestionSuffix: template.allowsQuestionSuffix
            ) else { continue }
            if !temperatureRange.contains(temperature) {
                return .contractRefusal(.valueOutOfRange(actual: temperature, allowed: temperatureRange))
            }
            return .capabilityQuery(
                CapabilityQuerySpec(stateBase: "ac.temp_setpoint", probedTemperature: temperature)
            )
        }
        return nil
    }

    private func matchCommandTemperature(_ text: String) -> DemoSliceClassification? {
        // Only templates that declare optional question-tail may strip 吗/呢.
        // No global suffix strip.
        let templates: [(prefix: String, allowsQuestionSuffix: Bool)] = [
            ("把空调调到", false),
            ("空调调到", false),
            ("打开空调到", false),
            ("请把空调调到", false),
            ("能把空调调到", true),
            ("能调到", true),
        ]
        for template in templates {
            guard let temperature = parseExactTemperature(
                text,
                prefix: template.prefix,
                allowsQuestionSuffix: template.allowsQuestionSuffix
            ) else { continue }
            if !temperatureRange.contains(temperature) {
                return .contractRefusal(.valueOutOfRange(actual: temperature, allowed: temperatureRange))
            }
            let entry = entries[1]
            return .command(
                DemoSliceAdmission(
                    entry: entry,
                    frame: ToolCallFrame(
                        agentID: "vehicle-control",
                        capabilityID: "vehicle.ac.temperature",
                        toolName: "adjust_ac_temperature_to_number",
                        device: "ac_temperature",
                        actionPrimitive: "adjust_to_number",
                        value: ContractValue(direct: String(temperature), type: "SPOT"),
                        candidateSource: .fastPath,
                        rawPayload: evidencePayload(entry: entry, inputValue: temperature),
                        surfacePolicy: .primaryPanel
                    )
                )
            )
        }
        return nil
    }

    private func parseExactTemperature(
        _ text: String,
        prefix: String,
        allowsQuestionSuffix: Bool
    ) -> Int? {
        guard text.hasPrefix(prefix) else { return nil }
        var suffix = text.dropFirst(prefix.count)
        if allowsQuestionSuffix {
            if suffix.hasSuffix("吗") || suffix.hasSuffix("呢") {
                suffix = suffix.dropLast()
            }
        }
        guard suffix.hasSuffix("度") else { return nil }
        let number = suffix.dropLast()
        guard !number.isEmpty, number.allSatisfy(\.isNumber) else { return nil }
        // Exact template: nothing after optional question suffix beyond `{N}度`.
        return Int(number)
    }

    private func hasConjunctionOrMultiIntent(_ text: String) -> Bool {
        if text.contains("\n") || text.contains("\r") { return true }
        if text.contains(";") || text.contains("；") { return true }
        if text.contains("{") || text.contains("}") { return true }
        if text.contains("\"tool\"") || text.contains("tool_call") { return true }
        if text.contains("并") || text.contains("然后") { return true }
        if text.contains("，再") || text.contains(",再") { return true }
        if text.contains("，不对，") || text.contains(",不对,") { return true }
        return false
    }

    private func powerOnAdmission(
        entry: DemoSliceCatalogEntry,
        device: String,
        capabilityID: String,
        toolName: String
    ) -> DemoSliceAdmission {
        DemoSliceAdmission(
            entry: entry,
            frame: ToolCallFrame(
                agentID: "vehicle-control",
                capabilityID: capabilityID,
                toolName: toolName,
                device: device,
                actionPrimitive: "power_on",
                value: ContractValue(offset: "on", type: "STATE"),
                candidateSource: .fastPath,
                rawPayload: evidencePayload(entry: entry, inputValue: nil),
                surfacePolicy: .primaryPanel
            )
        )
    }

    private func evidencePayload(entry: DemoSliceCatalogEntry, inputValue: Int?) -> JSONValue {
        var payload: [String: JSONValue] = [
            "route_mode": .string(routeMode),
            "catalog_digest_sha256": .string(catalogDigestSHA256),
            "matrix_id": .number(Double(entry.matrixID)),
            "contract_row_id": .string(entry.contractRowID),
            "state_base": .string(entry.stateBase),
        ]
        if let inputValue {
            payload["input_value"] = .number(Double(inputValue))
        }
        return .object(payload)
    }

    /// Pure projection through the same state-cell scope resolver used by C3.
    /// Per-key desired targets are shared by route pre-run gate and C3 plan.
    public static func targetProjection(
        for admission: DemoSliceAdmission,
        stateCells: StateCellContractLookup
    ) throws -> [DemoSliceDesiredTarget] {
        let entry = admission.entry
        let frame = admission.frame
        guard let definition = stateCells.cell(id: entry.stateBase) else {
            throw ToolExecutionError.semanticInvalid("state_cell_not_found")
        }
        let targetKeys = try C2ScopeResolver.resolve(frame: frame, cell: definition).keys
        let desiredValue: String
        if frame.actionPrimitive == "power_on", let powerOnValue = definition.powerOnValue {
            desiredValue = powerOnValue
        } else if !frame.value.direct.isEmpty {
            desiredValue = frame.value.direct
        } else if !frame.value.offset.isEmpty {
            desiredValue = frame.value.offset
        } else {
            desiredValue = frame.value.ref
        }
        return targetKeys.map { DemoSliceDesiredTarget(key: $0, desired: desiredValue) }
    }
}
