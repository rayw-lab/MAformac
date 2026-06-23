import Foundation

public struct ToolContractCompiler: Sendable {
    public var devices: [String]
    public var actionPrimitives: [String]
    public var valueTypes: [String]
    public var slotKeys: [String]

    public init(rows: [SemanticContractRow]) {
        self.devices = Self.unique(rows.map(\.device))
        self.actionPrimitives = Self.unique(rows.map(\.actionPrimitive))
        self.valueTypes = Self.unique(rows.map { $0.value.type })
        self.slotKeys = Self.unique(rows.flatMap(\.slotKeys))
    }

    public init(seeds: [C5SemanticSeed]) {
        self.devices = Self.unique(seeds.map(\.device))
        self.actionPrimitives = Self.unique(seeds.map(\.actionPrimitive))
        self.valueTypes = Self.unique(seeds.map { $0.value.type })
        self.slotKeys = Self.unique(seeds.flatMap(\.slotKeys))
    }

    public var frameToolSchema: [[String: JSONValue]] {
        [[
            "type": .string("function"),
            "function": .object([
                "name": .string("tool_call_frame"),
                "description": .string("Emit exactly one MAformac single-hop ToolCallFrame for offline mock vehicle control."),
                "parameters": .object([
                    "type": .string("object"),
                    "additionalProperties": .bool(true),
                    "required": .array([.string("device"), .string("action_primitive")]),
                    "properties": .object(frameProperties)
                ])
            ])
        ]]
    }

    public var dDomainToolSchemas: [[String: JSONValue]] {
        dDomainSurfaceNames().map { name in
            functionSchema(
                name: name,
                description: "D-domain vehicle-control surface derived from the semantic contract."
            )
        }
    }

    public var renderedToolsText: String {
        ToolContractJSONRenderer.render([
            "tools": .array((frameToolSchema + dDomainToolSchemas).map { .object($0) })
        ])
    }

    private var frameProperties: [String: JSONValue] {
        var properties: [String: JSONValue] = [
            "device": enumStringSchema(values: devices),
            "action_primitive": enumStringSchema(values: actionPrimitives),
            "value.ref": .object(["type": .string("string")]),
            "value.direct": .object(["type": .string("string")]),
            "value.offset": .object(["type": .string("string")]),
            "value.type": enumStringSchema(values: valueTypes)
        ]
        for key in slotKeys {
            if properties[key] == nil {
                properties[key] = .object(["type": .string("string")])
            }
        }
        return properties
    }

    private func dDomainSurfaceNames() -> [String] {
        var names: Set<String> = []
        if devices.contains("ac") || devices.contains("ac_temperature") {
            names.insert("set_cabin_ac")
            names.insert("query_cabin_comfort")
        }
        if devices.contains("ac_windspeed") {
            names.insert("set_cabin_fan")
        }
        if devices.contains("window") {
            names.insert("set_cabin_window")
        }
        if devices.contains("screen_brightness") {
            names.insert("set_cabin_screen_brightness")
        }
        if devices.contains("atmosphere_lamp_color") || devices.contains("atmosphere_lamp_brightness") {
            names.insert("set_cabin_ambient_light")
        }
        return names.sorted()
    }

    private func functionSchema(name: String, description: String) -> [String: JSONValue] {
        [
            "type": .string("function"),
            "function": .object([
                "name": .string(name),
                "description": .string(description),
                "parameters": .object([
                    "type": .string("object"),
                    "additionalProperties": .bool(true),
                    "properties": .object([:])
                ])
            ])
        ]
    }

    private func enumStringSchema(values: [String]) -> JSONValue {
        var object: [String: JSONValue] = ["type": .string("string")]
        if !values.isEmpty {
            object["enum"] = .array(values.map { .string($0) })
        }
        return .object(object)
    }

    private static func unique(_ values: [String]) -> [String] {
        Array(Set(values.filter { !$0.isEmpty })).sorted()
    }
}

public struct ToolContractIR: Equatable, Sendable {
    public var sourceToolName: String
    public var device: String
    public var actionPrimitive: String
    public var slots: [String: String]
    public var value: ContractValue
    public var rawArguments: [String: String]

    public init(
        sourceToolName: String,
        device: String,
        actionPrimitive: String,
        slots: [String: String] = [:],
        value: ContractValue = ContractValue(),
        rawArguments: [String: String] = [:]
    ) {
        self.sourceToolName = sourceToolName
        self.device = device
        self.actionPrimitive = actionPrimitive
        self.slots = slots
        self.value = value
        self.rawArguments = rawArguments
    }
}

public enum ToolContractNormalizer {
    public static func normalize(_ call: C6ToolCall) -> [ToolContractIR] {
        switch call.name {
        case "tool_call_frame":
            return normalizeFrame(call)
        case "set_cabin_ac":
            return normalizeAC(call)
        case "set_cabin_window":
            return normalizeWindow(call)
        case "set_cabin_screen_brightness":
            return normalizeScreen(call)
        case "set_cabin_ambient_light":
            return normalizeAmbient(call)
        case "set_cabin_fan":
            return normalizeFan(call)
        case "query_cabin_comfort":
            return [
                ToolContractIR(
                    sourceToolName: call.name,
                    device: "ac_temperature",
                    actionPrimitive: "query",
                    slots: call.arguments,
                    rawArguments: call.arguments
                )
            ]
        default:
            return []
        }
    }

    private static func normalizeFrame(_ call: C6ToolCall) -> [ToolContractIR] {
        guard let device = call.arguments["device"],
              let actionPrimitive = call.arguments["action_primitive"] else {
            return []
        }
        let reserved = Set(["device", "action_primitive", "value.ref", "value.direct", "value.offset", "value.type"])
        let slots = call.arguments.filter { !reserved.contains($0.key) }
        return [
            ToolContractIR(
                sourceToolName: call.name,
                device: device,
                actionPrimitive: actionPrimitive,
                slots: slots,
                value: ContractValue(
                    ref: call.arguments["value.ref"] ?? "",
                    direct: call.arguments["value.direct"] ?? "",
                    offset: call.arguments["value.offset"] ?? "",
                    type: call.arguments["value.type"] ?? ""
                ),
                rawArguments: call.arguments
            )
        ]
    }

    private static func normalizeAC(_ call: C6ToolCall) -> [ToolContractIR] {
        var result: [ToolContractIR] = []
        if let power = call.arguments["power"], power != "unchanged" {
            result.append(ir(call, device: "ac", action: power == "off" ? "power_off" : "power_on", value: ContractValue(offset: power, type: "STATE")))
        }
        if let temp = call.arguments["target_temperature"] {
            result.append(ir(call, device: "ac_temperature", action: "adjust_to_number", value: ContractValue(direct: temp, type: "SPOT")))
        }
        if let delta = call.arguments["delta"], delta != "none" {
            let action = delta == "warmer" ? "increase_by_exp" : "decrease_by_exp"
            result.append(ir(call, device: "ac_temperature", action: action, value: ContractValue(offset: delta, type: "EXP")))
        }
        return result
    }

    private static func normalizeWindow(_ call: C6ToolCall) -> [ToolContractIR] {
        var slots = call.arguments
        if slots["position"] == nil {
            slots["position"] = "all"
        }
        if let percent = call.arguments["percent"] {
            let action = percent == "0" ? "power_off" : (percent == "100" ? "power_on" : "by_percent")
            return [ir(call, device: "window", action: action, slots: slots, value: ContractValue(direct: percent, type: "PERCENT"))]
        }
        if call.arguments["delta"] == "more_open" {
            return [ir(call, device: "window", action: "increase_by_exp", slots: slots, value: ContractValue(offset: "more_open", type: "EXP"))]
        }
        return [ir(call, device: "window", action: "power_on", slots: slots, value: ContractValue(direct: "100", type: "PERCENT"))]
    }

    private static func normalizeScreen(_ call: C6ToolCall) -> [ToolContractIR] {
        if let percent = call.arguments["percent"] {
            return [ir(call, device: "screen_brightness", action: "by_percent", value: ContractValue(direct: percent, type: "PERCENT"))]
        }
        if call.arguments["delta"] == "brighter" {
            return [ir(call, device: "screen_brightness", action: "increase_by_exp", value: ContractValue(offset: "brighter", type: "EXP"))]
        }
        if call.arguments["delta"] == "dimmer" {
            return [ir(call, device: "screen_brightness", action: "decrease_by_exp", value: ContractValue(offset: "dimmer", type: "EXP"))]
        }
        return []
    }

    private static func normalizeAmbient(_ call: C6ToolCall) -> [ToolContractIR] {
        var result: [ToolContractIR] = []
        if let color = call.arguments["color"] {
            result.append(ir(call, device: "atmosphere_lamp_color", action: "set_mode", value: ContractValue(direct: color, type: "ENUM")))
        } else if call.arguments["power"] == "off" {
            result.append(ir(call, device: "atmosphere_lamp_color", action: "power_off", value: ContractValue(offset: "off", type: "STATE")))
        }
        if call.arguments["brightness_delta"] == "brighter" {
            result.append(ir(call, device: "atmosphere_lamp_brightness", action: "increase_by_exp", value: ContractValue(offset: "brighter", type: "EXP")))
        } else if call.arguments["brightness_delta"] == "dimmer" {
            result.append(ir(call, device: "atmosphere_lamp_brightness", action: "decrease_by_exp", value: ContractValue(offset: "dimmer", type: "EXP")))
        }
        return result
    }

    private static func normalizeFan(_ call: C6ToolCall) -> [ToolContractIR] {
        if let level = call.arguments["level"] {
            return [ir(call, device: "ac_windspeed", action: "adjust_to_number", value: ContractValue(direct: level, type: "SPOT"))]
        }
        if call.arguments["delta"] == "stronger" {
            return [ir(call, device: "ac_windspeed", action: "increase_by_exp", value: ContractValue(offset: "stronger", type: "EXP"))]
        }
        if call.arguments["delta"] == "weaker" {
            return [ir(call, device: "ac_windspeed", action: "decrease_by_exp", value: ContractValue(offset: "weaker", type: "EXP"))]
        }
        return []
    }

    private static func ir(
        _ call: C6ToolCall,
        device: String,
        action: String,
        slots: [String: String]? = nil,
        value: ContractValue
    ) -> ToolContractIR {
        ToolContractIR(
            sourceToolName: call.name,
            device: device,
            actionPrimitive: action,
            slots: slots ?? call.arguments,
            value: value,
            rawArguments: call.arguments
        )
    }
}

public enum ToolContractStateApplier {
    public static func apply(
        toolCalls: [C6ToolCall],
        to preState: [String: String],
        stateCells: StateCellContractLookup
    ) -> [String: String] {
        var state = preState
        for call in toolCalls {
            for ir in ToolContractNormalizer.normalize(call) {
                apply(ir, state: &state, stateCells: stateCells)
            }
        }
        return state
    }

    private static func apply(_ ir: ToolContractIR, state: inout [String: String], stateCells: StateCellContractLookup) {
        switch ir.device {
        case "ac":
            applyAC(ir, state: &state)
        case "ac_temperature":
            applyTemperature(ir, state: &state)
        case "ac_windspeed":
            applyFan(ir, state: &state)
        case "window":
            applyWindow(ir, state: &state)
        case "screen_brightness":
            applyScreen(ir, state: &state)
        case "atmosphere_lamp_color":
            applyAmbientColor(ir, state: &state, stateCells: stateCells)
        case "atmosphere_lamp_brightness":
            applyAmbientBrightness(ir, state: &state)
        default:
            return
        }
    }

    private static func applyAC(_ ir: ToolContractIR, state: inout [String: String]) {
        if isOff(ir.actionPrimitive, value: ir.value) {
            state["ac.power"] = "off"
        } else if isOn(ir.actionPrimitive, value: ir.value) {
            state["ac.power"] = "on"
        }
    }

    private static func applyTemperature(_ ir: ToolContractIR, state: inout [String: String]) {
        if let target = targetNumber(ir) {
            state["ac.temp_setpoint[主驾]"] = target
            state["ac.power"] = "on"
            return
        }
        let current = Int(state["ac.temp_setpoint[主驾]"] ?? "24") ?? 24
        if ir.actionPrimitive == "increase_by_exp" {
            state["ac.temp_setpoint[主驾]"] = String(current + 2)
            state["ac.power"] = "on"
        } else if ir.actionPrimitive == "decrease_by_exp" {
            state["ac.temp_setpoint[主驾]"] = String(current - 2)
            state["ac.power"] = "on"
        }
    }

    private static func applyFan(_ ir: ToolContractIR, state: inout [String: String]) {
        if let target = targetNumber(ir) {
            state["ac.fan_speed[主驾]"] = target
            return
        }
        let current = Int(state["ac.fan_speed[主驾]"] ?? "1") ?? 1
        if ir.actionPrimitive == "increase_by_exp" {
            state["ac.fan_speed[主驾]"] = String(min(10, current + 1))
        } else if ir.actionPrimitive == "decrease_by_exp" {
            state["ac.fan_speed[主驾]"] = String(max(1, current - 1))
        }
    }

    private static func applyWindow(_ ir: ToolContractIR, state: inout [String: String]) {
        let percent: String
        if let target = targetNumber(ir) {
            percent = target
        } else if isOff(ir.actionPrimitive, value: ir.value) {
            percent = "0"
        } else if ir.actionPrimitive == "increase_by_exp" {
            let current = Int(state["window.position[主驾]"] ?? "0") ?? 0
            percent = String(min(100, current + 20))
        } else if ir.actionPrimitive == "decrease_by_exp" {
            let current = Int(state["window.position[主驾]"] ?? "0") ?? 0
            percent = String(max(0, current - 20))
        } else {
            percent = "100"
        }
        for key in windowKeys(for: ir.slots["position"] ?? "all") {
            state[key] = percent
        }
    }

    private static func applyScreen(_ ir: ToolContractIR, state: inout [String: String]) {
        if let target = targetNumber(ir) {
            state["screen.brightness[中控屏]"] = target
            return
        }
        let current = Int(state["screen.brightness[中控屏]"] ?? "70") ?? 70
        if ir.actionPrimitive == "increase_by_exp" {
            state["screen.brightness[中控屏]"] = String(min(100, current + 10))
        } else if ir.actionPrimitive == "decrease_by_exp" {
            state["screen.brightness[中控屏]"] = String(max(0, current - 10))
        }
    }

    private static func applyAmbientColor(_ ir: ToolContractIR, state: inout [String: String], stateCells: StateCellContractLookup) {
        if isOff(ir.actionPrimitive, value: ir.value) {
            state["ambient.color"] = "off"
            return
        }
        if let color = firstNonEmpty(ir.value.direct, ir.value.offset, ir.slots["color"]) {
            state["ambient.color"] = c2ColorValue(for: color, stateCells: stateCells)
        }
    }

    private static func applyAmbientBrightness(_ ir: ToolContractIR, state: inout [String: String]) {
        let current = Int(state["ambient.brightness[面发光氛围灯]"] ?? "70") ?? 70
        if ir.actionPrimitive == "increase_by_exp" {
            state["ambient.brightness[面发光氛围灯]"] = String(min(100, current + 10))
        } else if ir.actionPrimitive == "decrease_by_exp" {
            state["ambient.brightness[面发光氛围灯]"] = String(max(0, current - 10))
        }
    }

    private static func targetNumber(_ ir: ToolContractIR) -> String? {
        firstNumberLike(ir.value.direct, ir.value.offset, ir.slots["percent"], ir.slots["target_temperature"], ir.slots["level"])
    }

    private static func isOn(_ action: String, value: ContractValue) -> Bool {
        action == "power_on" || value.offset == "on" || value.direct == "on"
    }

    private static func isOff(_ action: String, value: ContractValue) -> Bool {
        action == "power_off" || value.offset == "off" || value.direct == "off"
    }

    private static func firstNumberLike(_ values: String?...) -> String? {
        for value in values {
            guard let value, !value.isEmpty else {
                continue
            }
            if Int(value) != nil {
                return value
            }
        }
        return nil
    }

    private static func firstNonEmpty(_ values: String?...) -> String? {
        for value in values {
            guard let value, !value.isEmpty else {
                continue
            }
            return value
        }
        return nil
    }

    private static func windowKeys(for position: String) -> [String] {
        switch position {
        case "driver":
            return ["window.position[主驾]"]
        case "passenger":
            return ["window.position[副驾]"]
        case "rear_left":
            return ["window.position[左后]"]
        case "rear_right":
            return ["window.position[右后]"]
        default:
            return ["window.position[主驾]", "window.position[副驾]", "window.position[左后]", "window.position[右后]"]
        }
    }

    private static func c2ColorValue(for value: String, stateCells: StateCellContractLookup) -> String {
        let aliases = [
            "red": "红",
            "blue": "蓝",
            "cool": "蓝",
            "warm": "橙",
            "amber": "橙",
            "white": "白",
        ]
        let candidate = aliases[value] ?? value
        let allowed = stateCells.cell(id: "ambient.color")?.values ?? []
        return allowed.contains(candidate) ? candidate : value
    }
}

private enum ToolContractJSONRenderer {
    static func render(_ object: [String: JSONValue]) -> String {
        let body = object.keys.sorted().map { key in
            "\"\(escape(key))\":\(renderValue(object[key] ?? .null))"
        }.joined(separator: ",")
        return "{\(body)}"
    }

    private static func renderValue(_ value: JSONValue) -> String {
        switch value {
        case .string(let text):
            return "\"\(escape(text))\""
        case .number(let number):
            if number.rounded() == number {
                return String(Int(number))
            }
            return String(number)
        case .bool(let bool):
            return bool ? "true" : "false"
        case .object(let object):
            return render(object)
        case .array(let values):
            return "[\(values.map(renderValue).joined(separator: ","))]"
        case .null:
            return "null"
        }
    }

    private static func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
