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

    public func admission(for text: String) -> DemoSliceAdmission? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized == "打开空调" {
            let entry = entries[0]
            return DemoSliceAdmission(
                entry: entry,
                frame: ToolCallFrame(
                    agentID: "vehicle-control",
                    capabilityID: "vehicle.ac.toggle",
                    toolName: "set_vehicle_control",
                    device: "ac",
                    actionPrimitive: "power_on",
                    value: ContractValue(offset: "on", type: "STATE"),
                    candidateSource: .fastPath,
                    rawPayload: evidencePayload(entry: entry, inputValue: nil),
                    surfacePolicy: .primaryPanel
                )
            )
        }

        if normalized == "把主驾车窗再开50%" {
            let entry = entries[2]
            return DemoSliceAdmission(
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
        }

        if normalized == "打开氛围灯" {
            let entry = entries[3]
            return DemoSliceAdmission(
                entry: entry,
                frame: ToolCallFrame(
                    agentID: "vehicle-control",
                    capabilityID: "vehicle.ambient_light.power",
                    toolName: "open_atmosphere_lamp",
                    device: "atmosphere_lamp",
                    actionPrimitive: "power_on",
                    value: ContractValue(offset: "on", type: "STATE"),
                    candidateSource: .fastPath,
                    rawPayload: evidencePayload(entry: entry, inputValue: nil),
                    surfacePolicy: .primaryPanel
                )
            )
        }

        if normalized == "打开副驾座椅加热" {
            let entry = entries[4]
            return DemoSliceAdmission(
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
        }

        guard let temperature = parsedTemperature(normalized), temperatureRange.contains(temperature) else {
            return nil
        }
        let entry = entries[1]
        return DemoSliceAdmission(
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
    }

    public func rejection(for text: String) -> DemoSliceAdmissionRejection? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty {
            return .blank
        }
        if admission(for: normalized) != nil {
            return nil
        }
        if normalized == "空调" {
            return .clarifyMissingSlot
        }
        if let temperature = parsedTemperature(normalized), !temperatureRange.contains(temperature) {
            return .valueOutOfRange(actual: temperature, allowed: temperatureRange)
        }
        return .notInCatalog
    }

    private func parsedTemperature(_ text: String) -> Int? {
        let prefixes = ["把空调调到", "空调调到", "打开空调到", "请把空调调到", "能把空调调到", "能调到"]
        guard let prefix = prefixes.first(where: text.hasPrefix) else { return nil }
        var suffix = text.dropFirst(prefix.count)
        if suffix.hasSuffix("吗") || suffix.hasSuffix("呢") {
            suffix = suffix.dropLast()
        }
        guard suffix.hasSuffix("度") else { return nil }
        let number = suffix.dropLast()
        guard !number.isEmpty else { return nil }
        return Int(number)
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
    /// No side effects and no store access.
    public static func targetProjection(
        for admission: DemoSliceAdmission,
        stateCells: StateCellContractLookup
    ) throws -> (targetKeys: [String], desiredValue: String) {
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
        return (targetKeys, desiredValue)
    }

}
