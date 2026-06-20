import Foundation

public struct ContractValue: Codable, Equatable, Sendable {
    public var ref: String
    public var direct: String
    public var offset: String
    public var type: String

    public init(ref: String = "", direct: String = "", offset: String = "", type: String = "") {
        self.ref = ref
        self.direct = direct
        self.offset = offset
        self.type = type
    }
}

public struct SemanticContractRow: Codable, Equatable, Sendable {
    public var contractRowID: String
    public var device: String
    public var actionPrimitive: String
    public var slot: String
    public var slotKeys: [String]
    public var clarifyTag: String
    public var risk: String
    public var execTier: String
    public var executionRangeRef: String
    public var value: ContractValue

    enum CodingKeys: String, CodingKey {
        case contractRowID = "contract_row_id"
        case device
        case actionPrimitive = "action_primitive"
        case slot
        case slotKeys = "slot_keys"
        case clarifyTag = "clarify_tag"
        case risk
        case execTier = "exec_tier"
        case executionRangeRef = "execution_range_ref"
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contractRowID = try container.decode(String.self, forKey: .contractRowID)
        self.device = try container.decode(String.self, forKey: .device)
        self.actionPrimitive = try container.decode(String.self, forKey: .actionPrimitive)
        self.slot = try container.decode(String.self, forKey: .slot)
        self.slotKeys = try container.decodeIfPresent([String].self, forKey: .slotKeys) ?? []
        self.clarifyTag = try container.decodeIfPresent(String.self, forKey: .clarifyTag) ?? ""
        self.risk = try container.decodeIfPresent(String.self, forKey: .risk) ?? ""
        self.execTier = try container.decodeIfPresent(String.self, forKey: .execTier) ?? ""
        self.executionRangeRef = try container.decodeIfPresent(String.self, forKey: .executionRangeRef) ?? ""
        self.value = try container.decodeIfPresent(ContractValue.self, forKey: .value) ?? ContractValue()
    }
}

public struct SemanticContractLookup: Sendable {
    public var rows: [SemanticContractRow]

    public init(jsonl: String) throws {
        let decoder = JSONDecoder()
        self.rows = try jsonl
            .split(whereSeparator: \.isNewline)
            .map { line in
                try decoder.decode(SemanticContractRow.self, from: Data(String(line).utf8))
            }
    }

    public var riskValues: [String] {
        Array(Set(rows.map(\.risk))).sorted()
    }

    public func first(device: String, actionPrimitive: String) -> SemanticContractRow? {
        rows.first {
            $0.device == device && $0.actionPrimitive == actionPrimitive
        }
    }

    public func contains(device: String, actionPrimitive: String, slotKeys: Set<String>? = nil) -> Bool {
        rows.contains { row in
            guard row.device == device, row.actionPrimitive == actionPrimitive else {
                return false
            }
            guard let slotKeys else {
                return true
            }
            return Set(row.slotKeys) == slotKeys
        }
    }
}

public struct ExecutionRange: Equatable, Sendable {
    public var min: Int
    public var max: Int
    public var step: Int

    public init(min: Int, max: Int, step: Int) {
        self.min = min
        self.max = max
        self.step = step
    }

    public func contains(_ value: Int) -> Bool {
        value >= min && value <= max && ((value - min) % step == 0)
    }
}

public struct StateCellDefinition: Equatable, Sendable {
    public var id: String
    public var type: String
    public var unit: String?
    public var values: [String]
    public var scope: [String]
    public var executionRange: ExecutionRange?
    public var expStepLittle: Int?
    public var gearMap: [String: Int]
    public var extremeMap: [String: Int]
    public var readbackTemplate: String?

    public init(
        id: String,
        type: String = "",
        unit: String? = nil,
        values: [String] = [],
        scope: [String] = [],
        executionRange: ExecutionRange? = nil,
        expStepLittle: Int? = nil,
        gearMap: [String: Int] = [:],
        extremeMap: [String: Int] = [:],
        readbackTemplate: String? = nil
    ) {
        self.id = id
        self.type = type
        self.unit = unit
        self.values = values
        self.scope = scope
        self.executionRange = executionRange
        self.expStepLittle = expStepLittle
        self.gearMap = gearMap
        self.extremeMap = extremeMap
        self.readbackTemplate = readbackTemplate
    }
}

public struct StateCellContractLookup: Sendable {
    private var cellsByID: [String: StateCellDefinition]

    public init(yaml: String) throws {
        self.cellsByID = Self.parseCells(yaml: yaml)
    }

    public func cell(id: String) -> StateCellDefinition? {
        cellsByID[id]
    }

    public var cells: [StateCellDefinition] {
        cellsByID.values.sorted { $0.id < $1.id }
    }

    /// 用 C2 `readback_zh` 模板渲染播报文本(gap#5)。
    /// mock state key 形如 `ac.temp_setpoint[主驾]` → 取 base cell id 查模板,把 scope/value 填入占位符。
    /// 模板占位符按 C2 现状有 `{温区}/{位置}/{屏幕}/{氛围灯}`(均代表 scope)与 `{值}`;
    /// enum 形如 `空调{已打开|已关闭}` 由调用方传 enum 渲染。无模板时返回 nil,交回调用方走兜底。
    public func renderReadback(stateKey: String, scope: String?, value: String) -> String? {
        let baseID = stateKey.contains("[") ? String(stateKey.prefix(while: { $0 != "[" })) : stateKey
        guard let cell = cellsByID[baseID], let template = cell.readbackTemplate else {
            return nil
        }
        var result = template
        for placeholder in ["{温区}", "{位置}", "{屏幕}", "{氛围灯}", "{区域}", "{位}"] {
            result = result.replacingOccurrences(of: placeholder, with: scope ?? "")
        }
        result = result.replacingOccurrences(of: "{值}", with: value)
        // enum-branch 形式 `空调{已打开|已关闭}`:按 value 在 cell.values 中的位置选分支。
        result = Self.resolveEnumBranch(result, value: value, values: cell.values)
        return result
    }

    /// 把模板里的 `{分支A|分支B|...}` 按 value 在 enum values 列表中的索引展开。
    /// 无法匹配索引时取第一分支兜底,保证不把原始 `{...|...}` 漏给 TTS。
    private static func resolveEnumBranch(_ template: String, value: String, values: [String]) -> String {
        guard let open = template.firstIndex(of: "{"),
              let close = template.firstIndex(of: "}"),
              open < close else {
            return template
        }
        let inner = String(template[template.index(after: open)..<close])
        guard inner.contains("|") else {
            return template
        }
        let branches = inner.components(separatedBy: "|")
        let index = values.firstIndex(of: value) ?? 0
        let chosen = index < branches.count ? branches[index] : (branches.first ?? "")
        return template.replacingCharacters(in: open...close, with: chosen)
    }

    private static func parseCells(yaml: String) -> [String: StateCellDefinition] {
        var cells: [String: StateCellDefinition] = [:]
        var current: StateCellDefinition?
        var inExpStep = false

        func finishCurrent() {
            if let current {
                cells[current.id] = current
            }
            current = nil
            inExpStep = false
        }

        for rawLine in yaml.split(whereSeparator: \.isNewline).map(String.init) {
            let line = stripComment(rawLine)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                continue
            }

            if trimmed.hasPrefix("- id: ") {
                finishCurrent()
                current = StateCellDefinition(id: cleanValue(String(trimmed.dropFirst("- id: ".count))))
                continue
            }

            guard current != nil else {
                continue
            }

            if trimmed.hasPrefix("exp_step:") {
                inExpStep = true
                if let inline = inlineMap(after: "exp_step:", in: trimmed), let little = inline["little"] {
                    current?.expStepLittle = Int(little)
                }
                continue
            }

            if !trimmed.hasPrefix("little:"),
               !trimmed.hasPrefix("gear:"),
               !trimmed.hasPrefix("extreme:") {
                inExpStep = false
            }

            if trimmed.hasPrefix("type: ") {
                current?.type = cleanValue(String(trimmed.dropFirst("type: ".count)))
            } else if trimmed.hasPrefix("unit: ") {
                current?.unit = cleanValue(String(trimmed.dropFirst("unit: ".count)))
            } else if trimmed.hasPrefix("values: ") {
                current?.values = parseArray(after: "values:", in: trimmed)
            } else if trimmed.hasPrefix("scope: ") {
                current?.scope = parseArray(after: "scope:", in: trimmed)
            } else if trimmed.hasPrefix("execution_range: ") {
                if let map = inlineMap(after: "execution_range:", in: trimmed),
                   let min = Int(map["min"] ?? ""),
                   let max = Int(map["max"] ?? ""),
                   let step = Int(map["step"] ?? "") {
                    current?.executionRange = ExecutionRange(min: min, max: max, step: step)
                }
            } else if inExpStep, trimmed.hasPrefix("little: ") {
                current?.expStepLittle = Int(cleanValue(String(trimmed.dropFirst("little: ".count))))
            } else if inExpStep, trimmed.hasPrefix("gear: ") {
                current?.gearMap = parseIntMap(after: "gear:", in: trimmed)
            } else if inExpStep, trimmed.hasPrefix("extreme: ") {
                current?.extremeMap = parseIntMap(after: "extreme:", in: trimmed)
            } else if trimmed.hasPrefix("gear_map: ") {
                current?.gearMap = parseIntMap(after: "gear_map:", in: trimmed)
            } else if trimmed.hasPrefix("readback_zh: ") {
                current?.readbackTemplate = cleanValue(String(trimmed.dropFirst("readback_zh: ".count)))
            }
        }
        finishCurrent()
        return cells
    }
}

public enum RiskPolicyDecision: Equatable, Sendable {
    case allow
    case confirm(reason: String)
    case refuse(reason: String)
}

public struct RiskPolicyLookup: Sendable {
    public struct ForbiddenRule: Equatable, Sendable {
        public var ruleID: String
        public var triggerCell: String
        public var threshold: Int
        public var devices: [String]
        public var refuseReadback: String
    }

    public var forbiddenRules: [ForbiddenRule]

    public init(yaml: String) throws {
        self.forbiddenRules = Self.parseForbiddenRules(yaml: yaml)
    }

    public func evaluate(device: String, stateValues: [String: String]) -> RiskPolicyDecision {
        for rule in forbiddenRules where rule.devices.contains(device) {
            let current = Int(stateValues[rule.triggerCell] ?? "") ?? 0
            if current > rule.threshold {
                return .refuse(reason: rule.refuseReadback)
            }
        }
        return .allow
    }

    private static func parseForbiddenRules(yaml: String) -> [ForbiddenRule] {
        var rules: [ForbiddenRule] = []
        var current: ForbiddenRule?
        var inForbidden = false

        func finishCurrent() {
            if let current {
                rules.append(current)
            }
            current = nil
        }

        for rawLine in yaml.split(whereSeparator: \.isNewline).map(String.init) {
            let line = stripComment(rawLine)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                continue
            }
            if trimmed == "forbidden:" {
                inForbidden = true
                continue
            }
            guard inForbidden else {
                continue
            }
            if trimmed.hasPrefix("- rule_id: ") {
                finishCurrent()
                current = ForbiddenRule(
                    ruleID: cleanValue(String(trimmed.dropFirst("- rule_id: ".count))),
                    triggerCell: "",
                    threshold: 0,
                    devices: [],
                    refuseReadback: ""
                )
            } else if trimmed.hasPrefix("trigger: ") {
                let trigger = cleanValue(String(trimmed.dropFirst("trigger: ".count)))
                let parts = trigger.components(separatedBy: ">").map { $0.trimmingCharacters(in: .whitespaces) }
                current?.triggerCell = parts.first ?? ""
                current?.threshold = Int(parts.dropFirst().first ?? "") ?? 0
            } else if trimmed.hasPrefix("devices: ") {
                current?.devices = parseArray(after: "devices:", in: trimmed)
            } else if trimmed.hasPrefix("refuse_readback_zh: ") {
                current?.refuseReadback = cleanValue(String(trimmed.dropFirst("refuse_readback_zh: ".count)))
            } else if !trimmed.hasPrefix("display_zh:"),
                      !trimmed.hasPrefix("risk_level:") {
                continue
            }
        }
        finishCurrent()
        return rules
    }
}

public struct L1DemoAllowlistEntry: Equatable, Sendable {
    public var device: String
    public var primitives: [String]
    public var executionRangeCell: String
}

public struct L1DemoAllowlistLookup: Sendable {
    private var entriesByDevice: [String: L1DemoAllowlistEntry]

    public init(yaml: String) throws {
        self.entriesByDevice = Self.parseEntries(yaml: yaml)
    }

    public func entry(device: String) -> L1DemoAllowlistEntry? {
        entriesByDevice[device]
    }

    private static func parseEntries(yaml: String) -> [String: L1DemoAllowlistEntry] {
        var entries: [String: L1DemoAllowlistEntry] = [:]
        var currentDevice: String?
        var currentPrimitives: [String] = []
        var currentExecutionRangeCell = ""
        var readingPrimitives = false
        var inAllowlist = false
        var inPending = false

        func finishCurrent() {
            if let currentDevice, !currentExecutionRangeCell.isEmpty {
                entries[currentDevice] = L1DemoAllowlistEntry(
                    device: currentDevice,
                    primitives: currentPrimitives,
                    executionRangeCell: currentExecutionRangeCell
                )
            }
            currentDevice = nil
            currentPrimitives = []
            currentExecutionRangeCell = ""
            readingPrimitives = false
        }

        for rawLine in yaml.split(whereSeparator: \.isNewline).map(String.init) {
            let line = stripComment(rawLine)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                continue
            }
            if trimmed == "allowlist:" {
                inAllowlist = true
                inPending = false
                continue
            }
            if trimmed == "allowlist_pending_c2:" {
                finishCurrent()
                inPending = true
                inAllowlist = false
                continue
            }
            guard inAllowlist, !inPending else {
                continue
            }
            if trimmed.hasPrefix("- device: ") {
                finishCurrent()
                currentDevice = cleanValue(String(trimmed.dropFirst("- device: ".count)))
            } else if trimmed.hasPrefix("primitives:") {
                readingPrimitives = true
                let inline = parseArray(after: "primitives:", in: trimmed)
                if !inline.isEmpty {
                    currentPrimitives = inline
                    readingPrimitives = false
                }
            } else if readingPrimitives, trimmed.hasPrefix("- ") {
                currentPrimitives.append(cleanValue(String(trimmed.dropFirst(2))))
            } else if trimmed.hasPrefix("execution_range_cell: ") {
                currentExecutionRangeCell = cleanValue(String(trimmed.dropFirst("execution_range_cell: ".count)))
                readingPrimitives = false
            } else if !trimmed.hasPrefix("- ") {
                readingPrimitives = false
            }
        }
        finishCurrent()
        return entries
    }
}

private func stripComment(_ line: String) -> String {
    var quote: Character?
    var result = ""
    for character in line {
        if character == "\"" || character == "'" {
            if quote == character {
                quote = nil
            } else if quote == nil {
                quote = character
            }
        }
        if character == "#", quote == nil {
            break
        }
        result.append(character)
    }
    return result
}

private func cleanValue(_ raw: String) -> String {
    raw
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
}

private func parseArray(after prefix: String, in line: String) -> [String] {
    guard let range = line.range(of: prefix) else {
        return []
    }
    let rest = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
    guard rest.hasPrefix("["), let end = rest.firstIndex(of: "]") else {
        return []
    }
    return rest[rest.index(after: rest.startIndex)..<end]
        .split(separator: ",")
        .map { cleanValue(String($0)) }
        .filter { !$0.isEmpty }
}

private func inlineMap(after prefix: String, in line: String) -> [String: String]? {
    guard let range = line.range(of: prefix) else {
        return nil
    }
    let rest = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
    guard rest.hasPrefix("{"), let end = rest.firstIndex(of: "}") else {
        return nil
    }
    let body = rest[rest.index(after: rest.startIndex)..<end]
    var result: [String: String] = [:]
    for pair in body.split(separator: ",") {
        let pieces = pair.split(separator: ":", maxSplits: 1).map { cleanValue(String($0)) }
        if pieces.count == 2 {
            result[pieces[0]] = pieces[1]
        }
    }
    return result
}

private func parseIntMap(after prefix: String, in line: String) -> [String: Int] {
    (inlineMap(after: prefix, in: line) ?? [:]).reduce(into: [:]) { result, item in
        if let value = Int(item.value) {
            result[item.key] = value
        }
    }
}
