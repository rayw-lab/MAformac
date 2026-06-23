import Foundation

public struct ToolContractCompiler: Sendable {
    public var devices: [String]
    public var actionPrimitives: [String]
    public var valueTypes: [String]
    public var slotKeys: [String]
    // D-domain 具名工具目录(S1 codegen generated/D_domain.tools.demo.json 注入); 默认空保持向后兼容。
    public var dDomainCatalog: [DDomainToolEntry]

    public init(rows: [SemanticContractRow], dDomainCatalog: [DDomainToolEntry] = []) {
        self.devices = Self.unique(rows.map(\.device))
        self.actionPrimitives = Self.unique(rows.map(\.actionPrimitive))
        self.valueTypes = Self.unique(rows.map { $0.value.type })
        self.slotKeys = Self.unique(rows.flatMap(\.slotKeys))
        self.dDomainCatalog = dDomainCatalog
    }

    public init(seeds: [C5SemanticSeed], dDomainCatalog: [DDomainToolEntry] = []) {
        self.devices = Self.unique(seeds.map(\.device))
        self.actionPrimitives = Self.unique(seeds.map(\.actionPrimitive))
        self.valueTypes = Self.unique(seeds.map { $0.value.type })
        self.slotKeys = Self.unique(seeds.flatMap(\.slotKeys))
        self.dDomainCatalog = dDomainCatalog
    }

    // D-domain 具名工具目录加载(generated/ 被 Package.swift exclude, 走 repoRoot 文件加载, 仿 C6 :1381)。
    public static func loadDDomainCatalog(repoRoot: URL) throws -> [DDomainToolEntry] {
        let url = repoRoot.appendingPathComponent("generated/D_domain.tools.demo.json")
        return try JSONDecoder().decode([DDomainToolEntry].self, from: Data(contentsOf: url))
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
        dDomainCatalog.map { entry in
            [
                "type": .string(entry.type),
                "function": .object([
                    "name": .string(entry.function.name),
                    "description": .string(entry.function.description),
                    "parameters": entry.function.parameters
                ])
            ]
        }
    }

    // model-visible surface = 只渲 D-domain 具名工具(562); generic frame 已从 surface 显式移除(paradigm §1)。
    // frameToolSchema 物理保留供 C5 训练 surface(strangler, S4 迁后删)。
    public var renderedToolsText: String {
        ToolContractJSONRenderer.render([
            "tools": .array(dDomainToolSchemas.map { .object($0) })
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

// D-domain 具名工具目录条目(解码 generated/D_domain.tools.demo.json; _domain=family/_sg=device 供 S4 同族 distractor)。
public struct DDomainToolEntry: Codable, Equatable, Sendable {
    public let type: String
    public let function: DDomainFunction
    public let domain: String?   // _domain (family, S4 同族 distractor 回退)
    public let sg: String?       // _sg (device, S4 同设备 distractor 优先)

    enum CodingKeys: String, CodingKey {
        case type
        case function
        case domain = "_domain"
        case sg = "_sg"
    }
}

public struct DDomainFunction: Codable, Equatable, Sendable {
    public let name: String
    public let description: String
    public let parameters: JSONValue
}

// D-domain 工具名→IR 映射条目(解码 generated/d_domain_ir_map.json; S1 codegen 产, Normalizer 消费支持 562 具名工具)。
public struct DDomainIRMapEntry: Codable, Sendable {
    public let device: String
    public let irPrimitives: [String]
    public let valueTypes: [String]
    enum CodingKeys: String, CodingKey {
        case device
        case irPrimitives = "ir_primitives"
        case valueTypes = "value_types"
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
    // D-domain 工具名→IR 映射加载(generated/ 被 Package.swift exclude, 走 repoRoot 文件加载)。
    public static func loadIRMap(repoRoot: URL) throws -> [String: DDomainIRMapEntry] {
        let url = repoRoot.appendingPathComponent("generated/d_domain_ir_map.json")
        return try JSONDecoder().decode([String: DDomainIRMapEntry].self, from: Data(contentsOf: url))
    }

    public static func normalize(_ call: C6ToolCall, irMap: [String: DDomainIRMapEntry] = [:]) -> [ToolContractIR] {
        // 优先 D-domain 具名工具名查表(562); 旧 surface(frame + 6 set_cabin_*) strangler 保留, S4/S5 迁后删。
        if let entry = irMap[call.name] {
            return normalizeDDomain(call, entry: entry)
        }
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
            // 未知工具名不静默吞(claim-vs-reality 铁律1: 防 D-domain 工具名拼错/ir_map 漏条目被悄悄吞=假绿)。
            logUnclassified(call.name)
            return []
        }
    }

    // D-domain 具名工具名→canonical IR(device×action×value); ir_map(S1 codegen)提供 device + 候选 primitive + value_types。
    private static func normalizeDDomain(_ call: C6ToolCall, entry: DDomainIRMapEntry) -> [ToolContractIR] {
        let primitive = resolvePrimitive(entry, arguments: call.arguments)
        let value = buildValue(entry, arguments: call.arguments)
        let reserved: Set<String> = ["name", "value", "value.type"]
        let slots = call.arguments.filter { !reserved.contains($0.key) }
        return [
            ToolContractIR(
                sourceToolName: call.name,
                device: entry.device,
                actionPrimitive: primitive,
                slots: slots,
                value: value,
                rawArguments: call.arguments
            )
        ]
    }

    // multi-primitive(134/562)用 value 参数格式消歧; 单值直取。
    private static func resolvePrimitive(_ entry: DDomainIRMapEntry, arguments: [String: String]) -> String {
        guard entry.irPrimitives.count > 1 else {
            return entry.irPrimitives.first ?? ""
        }
        let valueArg = arguments["value"] ?? arguments.values.first { Int($0) != nil || $0.contains("%") } ?? ""
        if valueArg.contains("%") {
            return entry.irPrimitives.first { $0.contains("percent") } ?? entry.irPrimitives[0]
        }
        if Int(valueArg) != nil {
            return entry.irPrimitives.first { $0.contains("to_number") } ?? entry.irPrimitives[0]
        }
        return entry.irPrimitives.first { $0.contains("exp") || $0.contains("gear") } ?? entry.irPrimitives[0]
    }

    // value_types 单值定 type; 多值/空按 value 参数派生(SPOT/PERCENT→direct, EXP→offset, 空→STATE)。
    private static func buildValue(_ entry: DDomainIRMapEntry, arguments: [String: String]) -> ContractValue {
        let valueArg = arguments["value"] ?? ""
        let vtype: String
        if entry.valueTypes.count == 1, !entry.valueTypes[0].isEmpty {
            vtype = entry.valueTypes[0]
        } else if valueArg.contains("%") {
            vtype = "PERCENT"
        } else if Int(valueArg) != nil {
            vtype = "SPOT"
        } else if entry.valueTypes.contains("EXP") {
            vtype = "EXP"
        } else {
            vtype = "STATE"
        }
        switch vtype {
        case "SPOT", "PERCENT":
            return ContractValue(direct: valueArg, type: vtype)
        case "EXP":
            return ContractValue(offset: valueArg, type: vtype)
        default:
            return ContractValue(type: vtype)
        }
    }

    private static func logUnclassified(_ name: String) {
        let message = "[ToolContractNormalizer] unclassified tool name: \(name)\n"
        FileHandle.standardError.write(message.data(using: .utf8) ?? Data())
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
        stateCells: StateCellContractLookup,
        irMap: [String: DDomainIRMapEntry] = [:]
    ) -> [String: String] {
        var state = preState
        for call in toolCalls {
            for ir in ToolContractNormalizer.normalize(call, irMap: irMap) {
                apply(ir, state: &state, stateCells: stateCells)
            }
        }
        return state
    }

    // device → C2 cell id 单一 SSOT 映射(S2 5 族 + S3 6 族 = 10 族 demo-positive); C3ExecutionPipeline 复用此单源
    // 消除三处 device→cell 平行硬编码分叉(claim-vs-reality 铁律1)。191 全量 + codegen 派生 = DEFERRED(随 retrain-c5/rebuild-c6)。
    public static let deviceCellMap: [String: String] = [
        // S2 5 族(空调/车窗/屏幕/氛围灯)
        "ac": "ac.power",
        "ac_temperature": "ac.temp_setpoint",
        "ac_windspeed": "ac.fan_speed",
        "window": "window.position",
        "screen_brightness": "screen.brightness",
        "atmosphere_lamp_color": "ambient.color",
        "atmosphere_lamp_brightness": "ambient.brightness",
        // S3 座椅
        "seat_heat_temperature": "seat.heat_level",
        "seat_ventilation_windspeed": "seat.vent_level",
        "seat_massage_force": "seat.massage_force",
        "seat_backrest": "seat.backrest_angle",
        // S3 车门
        "car_door": "door.car_door",
        "central_lock": "door.central_lock",
        "child_lock": "door.child_lock",
        "tailgate_height": "door.tailgate_height",
        // S3 音量
        "volume": "volume.level",
        "volume_mute": "volume.mute",
        // S3 雨刮
        "wiper": "wiper.power",
        "wiper_speed": "wiper.speed",
        // S3 天窗遮阳
        "sunroof": "sunroof.position",
        "sunroof_slide": "sunroof.motion",
        "sunshade": "sunshade.position",
        // S3 香氛
        "fragrance": "fragrance.power",
        "fragrance_intensity": "fragrance.intensity",
    ]

    // data-driven: device→cell, 从 cell 元数据(execution_range/exp_step/default/scope/depends_on)派生 state 写入,
    // 替旧 8 个硬编码 applyXxx(cell SSOT enforce, claim-vs-reality 铁律1: 边界/步长/初值不在代码重复一份)。
    private static func apply(_ ir: ToolContractIR, state: inout [String: String], stateCells: StateCellContractLookup) {
        guard let cellID = deviceCellMap[ir.device] else {
            logUnmapped(ir.device)  // 未映射 device 不静默吞(S3 扩 191 逐族纳入)
            return
        }
        guard let cell = stateCells.cell(id: cellID) else {
            logUnmapped(cellID)
            return
        }
        if cell.type == "enum" {
            applyEnumCell(ir, cellID: cellID, cell: cell, state: &state, stateCells: stateCells)
        } else {
            applyNumericCell(ir, cellID: cellID, cell: cell, state: &state)
        }
    }

    // enum cell(ac.power power_on/off; ambient.color set_mode 别名/off)。
    private static func applyEnumCell(
        _ ir: ToolContractIR, cellID: String, cell: StateCellDefinition,
        state: inout [String: String], stateCells: StateCellContractLookup
    ) {
        if isOff(ir.actionPrimitive, value: ir.value) {
            state[cellID] = "off"
        } else if isOn(ir.actionPrimitive, value: ir.value) {
            state[cellID] = "on"
        } else if let raw = firstNonEmpty(ir.value.direct, ir.value.offset, ir.slots["color"]) {
            state[cellID] = c2ColorValue(for: raw, stateCells: stateCells)
        }
    }

    // numeric cell: target 直写 / exp ±expStepLittle clamp executionRange / scope 区位(window 多区位) / depends_on 联动。
    private static func applyNumericCell(
        _ ir: ToolContractIR, cellID: String, cell: StateCellDefinition, state: inout [String: String]
    ) {
        let baseScope = cell.scope.first ?? ""
        let currentKey = baseScope.isEmpty ? cellID : "\(cellID)[\(baseScope)]"
        let writeKeys = ir.device == "window"
            ? windowKeys(for: ir.slots["position"] ?? "all")
            : [currentKey]
        let initial = Int(cell.defaultValue ?? "") ?? 0
        let newValue: String?
        if let target = targetNumber(ir) {
            newValue = target                                       // 绝对 target 直写(复现旧, 不 clamp)
        } else if isOff(ir.actionPrimitive, value: ir.value) {
            newValue = String(cell.executionRange?.min ?? 0)        // power_off → 下界(window 0)
        } else if ir.actionPrimitive == "increase_by_exp" {
            let current = Int(state[currentKey] ?? "") ?? initial
            newValue = String(clampUpper(current + (cell.expStepLittle ?? 0), cell.executionRange))
        } else if ir.actionPrimitive == "decrease_by_exp" {
            let current = Int(state[currentKey] ?? "") ?? initial
            newValue = String(clampLower(current - (cell.expStepLittle ?? 0), cell.executionRange))
        } else if ir.device == "window" {
            newValue = String(cell.executionRange?.max ?? 100)      // window power_on 无 target → 全开(复现旧)
        } else {
            newValue = nil
        }
        guard let value = newValue else { return }
        for key in writeKeys {
            state[key] = value
        }
        for dependency in cell.dependsOn {                          // 写 cell 激活依赖(ac.temp_setpoint→ac.power=on)
            state[dependency] = "on"
        }
    }

    private static func clampUpper(_ value: Int, _ range: ExecutionRange?) -> Int {
        guard let range else { return value }
        return min(range.max, value)
    }

    private static func clampLower(_ value: Int, _ range: ExecutionRange?) -> Int {
        guard let range else { return value }
        return max(range.min, value)
    }

    private static func logUnmapped(_ name: String) {
        let message = "[ToolContractStateApplier] unmapped device/cell: \(name)\n"
        FileHandle.standardError.write(message.data(using: .utf8) ?? Data())
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
