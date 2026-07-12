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

/// Phase-A customer-path admission. The positive surface is intentionally frozen
/// to two semantic contract rows; every other utterance remains fail-closed.
public struct DemoSliceAdmissionCatalog: Sendable {
    public let routeMode = "demo_slice"
    public let catalogDigestSHA256 = "36fba1b5ed14275504964a69236c0084456541a80be052c5de8f74a1a5317f9a"
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
        let prefixes = ["把空调调到", "空调调到"]
        guard let prefix = prefixes.first(where: text.hasPrefix), text.hasSuffix("度") else {
            return nil
        }
        let start = text.index(text.startIndex, offsetBy: prefix.count)
        let end = text.index(before: text.endIndex)
        guard start < end else { return nil }
        return Int(text[start..<end])
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
}
