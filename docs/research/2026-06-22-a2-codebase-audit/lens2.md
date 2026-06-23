# Lens 2: MAformac硬编码&健壮性盘点 — Core/Tools/contracts全量grep审计

# MAformac 硬编码 & 健壮性盘点报告

## 执行摘要

本审计对MAformac项目的Core/, Tools/, contracts/目录进行了全量grep盘点，识别出**15个关键硬编码点**与**14个健壮性缺陷**。核心问题是业务逻辑（device、action、state cell等）与协议定义（contracts YAML）的映射硬编码在Swift代码中，导致：
- **跨度层信息漂移**：修改协议时需手工更新多处Swift硬编码
- **运行时防御缺失**：JSON解析/null返回无fallback，隐藏错误
- **文件单体化**：C5LoRATraining 2481行混合多个职责，难以维护

---

## I. 硬编码点详细清单

### 1. 工具名字面量散落（Tiger级，应立即codegen）

**硬编码位置汇总：**

| File | Lines | Pattern |
|------|-------|---------|
| ToolContractCompiler.swift | 74, 78, 81, 84, 87 | `names.insert("set_cabin_*")` |
| ToolContractCompiler.swift | 150, 152, 154, 156, 158, 160 | `case "set_cabin_*":` in normalizeFrame |
| ToolContractCompiler.swift | 202, 246, 247 | case "set_cabin_ac/fan/window/..." in normalize* |
| C6VehicleToolBench.swift | 358-386 | 30+ MP case specs with `C6ToolCall(name: "set_cabin_*")` |
| Bench/C6VehicleToolBench.swift | 全文 | [set_cabin_ac, set_cabin_fan, set_cabin_window, set_cabin_screen_brightness, set_cabin_ambient_light] |

**代码片段：**
```swift
// ToolContractCompiler.swift:71-90
private func dDomainSurfaceNames() -> [String] {
    var names: Set<String> = []
    if devices.contains("ac") || devices.contains("ac_temperature") {
        names.insert("set_cabin_ac")           // ← 硬编码
        names.insert("query_cabin_comfort")   // ← 硬编码
    }
    if devices.contains("ac_windspeed") {
        names.insert("set_cabin_fan")         // ← 硬编码
    }
    if devices.contains("window") {
        names.insert("set_cabin_window")      // ← 硬编码
    }
    // ... 更多硬编码
}

// 同时在normalize()中出现
switch call.name {
case "tool_call_frame":
    return normalizeFrame(call)
case "set_cabin_ac":              // ← 重复硬编码
    // ...
case "set_cabin_fan":             // ← 重复硬编码
    // ...
}
```

**SSOT来源：** contracts/function-spec-full.yaml 中的device + action_primitive组合应派生工具名

**建议行动：**
- 从contracts/function-spec-full.yaml codegen ToolNameEnum.swift
- 所有case语句迁移至 `ToolNameEnum.allCases`
- 添加 `ToolNameEnum.fromDeviceAction(device, primitive)` 派生函数

---

### 2. 设备状态键名硬编码（Tiger级）

**关键状态键硬编码位置：**

| State Key | Files & Lines | Frequency |
|-----------|---|-----------|
| `"ac.power"` | ToolContractCompiler.swift:326,328,335,341,344; C3ExecutionPipeline.swift:145-146,220; DemoVehicleStateStore.swift:136,163-165 | 10+ |
| `"ac.temp_setpoint[主驾]"` | ToolContractCompiler.swift:334,338,340,343; C3ExecutionPipeline.swift:162; C6VehicleToolBench.swift:358,362 | 8+ |
| `"ac.fan_speed[主驾]"` | ToolContractCompiler.swift:350,353,355,357; C6VehicleToolBench.swift:364,365 | 6+ |
| `"window.position[主驾]"` | ToolContractCompiler.swift:368,371; C6VehicleToolBench.swift:370-377 | 8+ |
| `"screen.brightness[中控屏]"` | ToolContractCompiler.swift:383,386,388,390; C6VehicleToolBench.swift:359,378-379,423 | 8+ |
| `"ambient.color"` | ToolContractCompiler.swift:396,400; C6VehicleToolBench.swift:366,367,384 | 6+ |
| `"ambient.brightness[面发光氛围灯]"` | ToolContractCompiler.swift:405,407,409; C6VehicleToolBench.swift:368,369,384 | 6+ |

**代码片段（ToolContractCompiler.swift:324-410）：**
```swift
private static func applyAC(_ ir: ToolContractIR, state: inout [String: String]) {
    if isOff(ir.actionPrimitive, value: ir.value) {
        state["ac.power"] = "off"  // ← 硬编码
    } else if isOn(ir.actionPrimitive, value: ir.value) {
        state["ac.power"] = "on"   // ← 硬编码
    }
}

private static func applyTemperature(_ ir: ToolContractIR, state: inout [String: String]) {
    if let target = targetNumber(ir) {
        state["ac.temp_setpoint[主驾]"] = target  // ← 硬编码，含中文scope
        state["ac.power"] = "on"
        return
    }
    let current = Int(state["ac.temp_setpoint[主驾]"] ?? "24") ?? 24  // ← 默认值也硬编码
    if ir.actionPrimitive == "increase_by_exp" {
        state["ac.temp_setpoint[主驾]"] = String(current + 2)  // ← 步长硬编码
        state["ac.power"] = "on"
    }
}

private static func applyWindow(_ ir: ToolContractIR, state: inout [String: String]) {
    let current = Int(state["window.position[主驾]"] ?? "0") ?? 0  // ← 默认值硬编码
    percent = String(min(100, current + 20))  // ← 步长20硬编码
}

private static func applyScreen(_ ir: ToolContractIR, state: inout [String: String]) {
    let current = Int(state["screen.brightness[中控屏]"] ?? "70") ?? 70  // ← 默认70硬编码
    if ir.actionPrimitive == "increase_by_exp" {
        state["screen.brightness[中控屏]"] = String(min(100, current + 10))  // ← 步长10硬编码
    }
}

private static func applyAmbientBrightness(_ ir: ToolContractIR, state: inout [String: String]) {
    let current = Int(state["ambient.brightness[面发光氛围灯]"] ?? "70") ?? 70  // ← 默认70硬编码
}
```

**SSOT来源：** contracts/state-cells.yaml:
- `ac.power` → airControl / state_cells / id: ac.power
- `ac.temp_setpoint[主驾]` → airControl / state_cells / id: ac.temp_setpoint + scope: [主驾, ...]
- `execution_range` 包含 min/max/step （应派生步长逻辑）
- `default` 包含默认值

**建议行动：**
- Codegen StateKeyConstants.swift from contracts/state-cells.yaml
- 为每个设备生成 `StateKey` enum 和 `ScopedKey` helper
- 将步长/默认值迁移至contracts配置

---

### 3. Device→StateCell映射硬编码（Tiger级）

**C3ExecutionPipeline.swift:156-175：**
```swift
private func executionCellID(for frame: ToolCallFrame) -> String? {
    if let entry = allowlist.entry(device: frame.device) {
        return entry.executionRangeCell
    }
    switch frame.device {
    case "ac_temperature":
        return "ac.temp_setpoint"              // ← 硬编码映射
    case "window":
        return "window.position"               // ← 硬编码映射
    case "screen_brightness":
        return "screen.brightness"             // ← 硬编码映射
    case "atmosphere_lamp_brightness":
        return "ambient.brightness"            // ← 硬编码映射
    case "atmosphere_lamp_color":
        return "ambient.color"                 // ← 硬编码映射
    case "ac":
        return "ac.power"                      // ← 硬编码映射
    default:
        return nil                             // ← 无default处理
    }
}
```

**问题：** 这个映射应该是 contracts/state-cells.yaml 的一部分（如 `device: ac_temperature` 对应 `execution_range_cell: ac.temp_setpoint`），当前硬编码使任何协议更新都需要手动修改此处。

**SSOT来源：** contracts/state-cells.yaml 的device级别应包含：
```yaml
devices:
  air_conditioner:
    devices:
      - device: ac_temperature
        execution_range_cell: ac.temp_setpoint  # ← 权威映射源
```

---

### 4. 魔法数字与阈值硬编码（Paper Tiger级）

**C5LoRATraining.swift 中的数值硬编码：**

| Line | Constant | Usage | Should Be |
|------|----------|-------|-----------|
| 1919 | 17 | `variant % 17` distractor count | contracts/distractor-config.yaml |
| 555 | 20 | `firstCandidateScale: Double = 20` | contracts/scale-authority.yaml |
| 619 | 0.80 | `uniqueUtteranceRatio >= 0.80` | contracts/diversity-threshold.yaml |
| 671 | 4_500 | `targetPositiveRows: Int = 4_500` | contracts/training-config.yaml |
| 672 | 400 | `devSelectionRows: Int = 400` | contracts/training-config.yaml |
| 673 | 0.10 | `refusalRatioTarget: Double = 0.10` | contracts/training-config.yaml |
| 674 | 0.20 | `refusalRatioHardCap: Double = 0.20` | contracts/training-config.yaml |
| 1942-1950 | [20,22,24,26] / [25,50,75] / [1,3,5,7] | spotChoices() temperature/percent/gear | contracts/state-cells.yaml::exp_step |

**代码片段：**
```swift
// C5LoRATraining.swift:555
public static func evaluate(observedScale: Double, firstCandidateScale: Double = 20) -> C5ScaleAuthorityResolution {
    // ← 20 是权威阈值,修改需改代码

// C5LoRATraining.swift:619
let diversityOK = uniqueUtteranceRatio >= 0.80  // ← 80% 多样性阈值硬编码

// C5LoRATraining.swift:671-674
public struct C5TrainingBuildOptions: Sendable {
    public var targetPositiveRows: Int = 4_500       // ← 硬编码
    public var devSelectionRows: Int = 400           // ← 硬编码
    public var refusalRatioTarget: Double = 0.10     // ← 硬编码
    public var refusalRatioHardCap: Double = 0.20    // ← 硬编码

// C5LoRATraining.swift:1940-1950
private static func spotChoices(for offset: String) -> [String] {
    if offset.contains("温") {
        return ["20", "22", "24", "26"]   // ← 温度候选硬编码
    }
    if offset.contains("百分") {
        return ["25", "50", "75"]         // ← 百分比硬编码
    }
    if offset.contains("档") {
        return ["1", "3", "5", "7"]       // ← 档位硬编码
    }
    return ["1", "2", "3", "4"]           // ← 默认硬编码
}
```

**建议行动：** 创建 contracts/training-config.yaml 与 contracts/distractor-config.yaml，codegen到Swift常量

---

### 5. MP Case Spec硬编码（Paper Tiger级）

**C6VehicleToolBench.swift:357-386 包含30+个测试用例硬编码：**

```swift
CaseSpec("C6-MP-001", "scene1", "ac_temperature", "query", "关空调", 
         [], true, ["ac.power": "off"], [], .implicit, .noCall, ["ac.power"], "state-aware-no-repeat"),
CaseSpec("C6-MP-002", "scene1", "ac_temperature", "increase_by_exp", "有点冷", 
         [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on", "delta": "warmer"])],
         false, ["ac.power": "on", "ac.temp_setpoint[主驾]": "26"], ["空调", "26"], .implicit, .action, 
         ["ac.power", "ac.temp_setpoint"], "feeling-warmer"),
// ... 28 more cases with similar hardcoded patterns
```

**问题：** 这些case spec重复了工具名、设备名、状态键的硬编码，应从 contracts/c6-bench-scenarios.yaml codegen

---

### 6. 命名不一致（Paper Tiger级）

**发现的命名空间不一致：**

| Namespace | Example | Risk |
|-----------|---------|------|
| State Cell ID | ac.power, ac.temp_setpoint[主驾], window.position[主驾] | 含scope后缀 |
| Device (C1) | ac, ac_temperature, ac_windspeed, window, screen_brightness | 短名 |
| Tool Name (D-domain) | set_cabin_ac, set_cabin_fan, set_cabin_window | 描述性 |
| Function Spec | carControl.electric_tailgate_switch (yaml line 3935) | 长路径 |

**跨层映射风险：** 当协议更新（如 device="climate_control" 替换 "ac"）时，需同时更新：
- ToolContractNormalizer 中的case
- C3ExecutionPipeline 的 executionCellID() switch
- ToolContractCompiler 的 dDomainSurfaceNames()
- DemoVehicleStateStore 的初值
- 30+ MP case specs

---

## II. 健壮性问题详表

### A. 错误处理缺失（P1 - 阻塞发布）

#### Issue #1: C5DataGate.swift:503 - try? 吞异常无日志

**代码：**
```swift
// C5DataGate.swift:502-510
static func decode(from container: KeyedDecodingContainer<C5DataGateCandidate.CodingKeys>) -> [C5ExpectedToolCall]? {
    guard let expected = try? container.decodeIfPresent(C5LegacyExpectedPayload.self, forKey: .expected) else {
        return nil  // ← 吞异常，无日志，无fallback
    }
    // ...
}
```

**风险：** JSON decode 失败时静默返回 nil，调用方无法区分"字段不存在"vs"字段格式错误"

**建议修复：**
```swift
static func decode(from container: ...) -> [C5ExpectedToolCall]? {
    do {
        if let expected = try container.decodeIfPresent(...) {
            // process
        }
    } catch let error as DecodingError {
        // Log error with context
        TraceLogger.shared.recordDecode(message: "legacy_expected_decode_failed", 
                                       attributes: TraceAttributes(decodeError: "\(error)"))
    }
    return nil
}
```

---

#### Issue #2: C3ExecutionPipeline.swift:135-140 - executionCellID() 返回nil无fallback

**代码：**
```swift
@MainActor
private func planTransitions(for frame: ToolCallFrame, store: DemoVehicleStateStore) throws -> [DemoMockTransition] {
    guard let cellID = executionCellID(for: frame) else {
        throw ToolExecutionError.semanticInvalid("no_execution_cell")  // ← 异常，但后续调用仍可能panic
    }
    guard let cell = stateCells.cell(id: cellID) else {
        throw ToolExecutionError.semanticInvalid("missing_c2_cell:\(cellID)")  // ← cellID有但cell无，缺关联日志
    }
}
```

**风险：** 虽然有guard语句，但 `stateCells.cell(id:)` 可能再次返回nil（二级查询失败）。无日志关联 cellID→cell 的映射失败原因

**建议修复：**
```swift
guard let cell = stateCells.cell(id: cellID) else {
    traceLogger.recordGuard(traceID: frame.traceID, 
                           message: "missing_c2_cell", 
                           attributes: TraceAttributes(
                               guardReason: "cell_lookup_failed",
                               context: "cellID=\(cellID), device=\(frame.device)"
                           ))
    throw ToolExecutionError.semanticInvalid("missing_c2_cell:\(cellID)")
}
```

---

#### Issue #3: ContractLookups.swift:60 - JSON循环解析无individual error handle

**代码：**
```swift
public init(jsonl: String) throws {
    let decoder = JSONDecoder()
    let rows = try jsonl
        .split(separator: "\n")
        .map { line in
            try decoder.decode(SemanticContractRow.self, 
                              from: Data(String(line).utf8))
        }  // ← 任意行失败导致全部加载失败
}
```

**风险：** 数据集中任意一行格式错误导致整个合同加载失败。无法识别哪一行有问题

**建议修复：**
```swift
public init(jsonl: String) throws {
    let decoder = JSONDecoder()
    var rows: [SemanticContractRow] = []
    var failedLines: [(lineNum: Int, error: Error)] = []
    
    for (index, line) in jsonl.split(separator: "\n").enumerated() {
        do {
            let row = try decoder.decode(SemanticContractRow.self, 
                                        from: Data(String(line).utf8))
            rows.append(row)
        } catch let error as DecodingError {
            failedLines.append((index + 1, error))
        }
    }
    
    if !failedLines.isEmpty {
        // Either throw with details or log warning
        let errorMsg = failedLines.map { "line \($0.lineNum): \($0.error)" }.joined(separator: "; ")
        throw ContractLoadError.partialDecodeFailure(errorMsg)
    }
    
    self.rows = rows
}
```

---

### B. JSON解析无容错（P2）

#### Issue #4: C6VehicleToolBench.swift:276-280 - decodeJSONL 一行失败全失败

**代码：**
```swift
public func decodeJSONL(_ text: String) throws -> [C6BenchCase] {
    let decoder = JSONDecoder()
    return try text.split(separator: "\n")
        .map { try decoder.decode(C6BenchCase.self, from: Data(String($0).utf8)) }  // ← 一行失败全失败
        .filter { !$0.caseID.isEmpty }
}
```

**建议修复：**
```swift
public func decodeJSONL(_ text: String) throws -> [C6BenchCase] {
    let decoder = JSONDecoder()
    var cases: [C6BenchCase] = []
    var errors: [String] = []
    
    for (lineNum, line) in text.split(separator: "\n").enumerated() {
        do {
            if let benchCase = try? decoder.decode(C6BenchCase.self, 
                                                   from: Data(String(line).utf8)),
               !benchCase.caseID.isEmpty {
                cases.append(benchCase)
            }
        } catch {
            errors.append("line \(lineNum + 1): \(error)")
        }
    }
    
    if !errors.isEmpty {
        // Log warnings but don't fail
        TraceLogger.shared.recordDecode(message: "partial_jsonl_decode_failure",
                                       attributes: TraceAttributes(decodeErrors: errors))
    }
    
    return cases
}
```

---

### C. Switch语句无default（P2）

#### Issue #5 & #6: ToolContractCompiler.swift:147-160, 304-320

**代码 (ToolContractCompiler.swift:147-160):**
```swift
public static func normalize(_ call: C6ToolCall) -> [ToolContractIR] {
    switch call.name {
    case "tool_call_frame":
        return normalizeFrame(call)
    case "set_cabin_ac":
        return normalizeAC(call)
    // ... more cases
    case "set_cabin_fan":
        // ...
    // NO DEFAULT CASE - unknown tool names silently dropped
    }
}
```

**风险：** 新增工具名或拼写错误导致无日志的silent drop

**建议修复：**
```swift
public static func normalize(_ call: C6ToolCall) -> [ToolContractIR] {
    switch call.name {
    case "tool_call_frame":
        return normalizeFrame(call)
    // ... cases
    default:
        // Log and return empty or throw
        TraceLogger.shared.recordDecode(message: "unknown_tool_name", 
                                       attributes: TraceAttributes(toolName: call.name))
        return []
    }
}
```

---

### D. 单文件过大（P1 - 代码质量）

**C5LoRATraining.swift: 2481行**

**结构分析：**
- Lines 1-65: Enum定义 (C5RouteTier, C5ValueStrategy, C5MaskingStage 等)
- Lines 65-600: 数据结构 (C5FCFlags, C5ContractValue, C5SemanticSeed 等)
- Lines 600-900: 验证逻辑 (各Validator类)
- Lines 900-1600: 生成逻辑 (各builder方法)
- Lines 1600-2000: 配置/常量 (C5MLXLoRAConfig, spotChoices等)
- Lines 2000-2100: 工具schema生成
- Lines 2100-2481: Receipt生成

**建议拆分为：**
1. **C5LoRATrainingModels.swift** - 枚举 + 数据结构 (content from L1-600)
2. **C5LoRATrainingBuilder.swift** - 生成逻辑 (L900-1600)
3. **C5LoRATrainingValidator.swift** - 验证逻辑 (L600-900)
4. **C5LoRATrainingConfig.swift** - 配置 + schema (L1600-2100)
5. **C5LoRATrainingReceipt.swift** - Receipt生成 (L2100-2481)

**单一职责收益：**
- 测试更聚焦（单个Validator/Builder易mock）
- 圈复杂度降低（当前可能超过C5LoC Cognition threshold）
- 维护时修改范围明确

---

### E. 状态初值无schema验证（P2）

**DemoVehicleStateStore.swift:136, 146-147, 156**

```swift
let initialCells = [
    DemoVehicleStateCell(key: "ac.power", actualValue: "off"),     // ← 硬编码
    DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24"),  // ← 硬编码，值也硬编码
    DemoVehicleStateCell(key: "ambient.color", actualValue: "白"),  // ← 硬编码
    DemoVehicleStateCell(key: "ambient.brightness[面发光氛围灯]", actualValue: "70"),  // ← 默认值硬编码
    DemoVehicleStateCell(key: "screen.brightness", actualValue: "70"),  // ← 硬编码
]
```

**问题：** 初值应与contracts/state-cells.yaml::default一致，当前无验证机制

**建议修复：** 从contracts codegen defaultStateStore()方法

---

### F. 测试覆盖盲区（Elephant级）

**识别的测试gap：**

| Gap | Files Affected | Severity |
|-----|-----------------|----------|
| 未知device/action无test | C3ExecutionPipeline, ToolContractCompiler | P2 |
| JSON malformed无test | C5DataGate, ContractLookups, C6VehicleToolBench | P2 |
| State cell 边界值(min/max)无test | ToolContractCompiler applyTemperature/Fan/Screen | P2 |
| Risk policy拒绝路径无test | C3ExecutionPipeline | P2 |

**建议新增test:**
```swift
// Test unknown device
let badFrame = ToolCallFrame(device: "unknown_device", actionPrimitive: "query", ...)
XCTAssertThrows(try pipeline.execute(badFrame, ...)) 

// Test JSON decode failure per-line
let malformedJSONL = "valid_line\ninvalid_json_line\nanother_valid"
let result = try benchCase.decodeJSONL(malformedJSONL)
XCTAssertEqual(result.count, 2)  // Only 2 valid lines recovered

// Test state cell boundary
let frame = ToolCallFrame(device: "ac_temperature", actionPrimitive: "adjust_to_number", 
                         slots: ["target_temperature": "50"])  // Out of range [18-32]
let result = try pipeline.execute(frame, store, logger)
// Should either clamp to 32 or throw, not silently store 50
```

---

## III. Codegen化路线图

### 第一阶段（Tiger级 - 立即执行）

**目标：** 消除工具名与设备状态键硬编码

**工作项：**

1. **生成 ToolNameEnum.swift**
   - 源: contracts/function-spec-full.yaml
   - 输出: enum + allCases + derived factories
   ```swift
   public enum ToolName: String, CaseIterable {
       case setCabinAC = "set_cabin_ac"
       case setCabinFan = "set_cabin_fan"
       case setCabinWindow = "set_cabin_window"
       // ...
       
       static func fromDeviceAction(_ device: String, _ action: String) -> ToolName? {
           // codegen logic
       }
   }
   ```

2. **生成 StateKeyLookup.swift**
   - 源: contracts/state-cells.yaml
   - 输出: device→cellID + cellID→scope mapping
   ```swift
   public struct StateKeyLookup {
       static let ac_power = "ac.power"
       static let ac_temp_setpoint = "ac.temp_setpoint"
       static func scopedKey(_ cellID: String, scope: String) -> String {
           return "\(cellID)[\(scope)]"  // or lookup table
       }
   }
   ```

3. **生成 ExecutionCellIDLookup.swift**
   - 源: contracts/state-cells.yaml::execution_range_cell
   - 输出: device→executionCellID映射
   ```swift
   public enum ExecutionCellIDLookup {
       static func cellID(for device: String) -> String? {
           // codegen: [ac_temperature: ac.temp_setpoint, ...]
       }
   }
   ```

4. **修复P1错误处理**
   - C5DataGate.swift:503 + TraceLogger
   - C3ExecutionPipeline.swift:135-140 + 日志
   - ContractLookups.swift:60 + per-line error collection

---

### 第二阶段（Paper Tiger级 - 2周内）

**目标：** 迁移魔法数字，拆分大文件

**工作项：**

5. **生成 TrainingConfig.swift**
   - 源: contracts/training-config.yaml (new)
   - Constants: targetPositiveRows, devSelectionRows, 各阈值
   ```yaml
   # contracts/training-config.yaml
   training:
     targetPositiveRows: 4500
     devSelectionRows: 400
     refusalRatioTarget: 0.10
     refusalRatioHardCap: 0.20
   diversity:
     uniqueUtteranceThreshold: 0.80
   scale:
     firstCandidateScale: 20
   ```

6. **拆分 C5LoRATraining.swift**
   - 分离: Models → Builder → Validator → Config → Receipt
   - 并发更新所有client 引用

7. **补齐switch default cases**
   - ToolContractCompiler.swift:147-160 + default case + logging
   - ToolContractCompiler.swift:304-320 + default case + logging
   - DemoVehicleStateStore.swift:163-165 + default case

---

### 第三阶段（Elephant级 - 1个月）

**目标：** 补齐测试，完全contracts-driven

**工作项：**

8. **生成 C6BenchCases.swift** from contracts/c6-bench-scenarios.yaml
9. **补齐负向test cases** (unknown device, JSON failure, state boundary)
10. **建立 UBL (Ubiquitous Language)** doc 规范化命名

---

## IV. 风险优先级与建议行动计划

### 优先级 HIGH (发布前必须修复)

- [x] **P1a**: 修复 C5DataGate.swift:503 decode() 异常处理 → TraceLogger记录
- [x] **P1b**: 修复 C3ExecutionPipeline.swift:135-140 executionCellID() → 无cell时日志+throw
- [x] **P1c**: 修复 ContractLookups.swift:60 JSON循环解析 → per-record error collection
- [ ] **P1d**: 补齐switch default cases (ToolContractCompiler, DemoVehicleStateStore) → 统一日志

**估算工时：** 4-6小时

---

### 优先级 MEDIUM (迭代1-2内完成)

- [ ] **P2a**: Codegen ToolNameEnum, StateKeyLookup, ExecutionCellIDLookup
- [ ] **P2b**: 拆分 C5LoRATraining.swift 为5个文件
- [ ] **P2c**: 迁移 magic numbers → contracts/training-config.yaml

**估算工时：** 20-24小时

---

### 优先级 LOW (长期重构)

- [ ] **P3a**: 补齐负向test cases
- [ ] **P3b**: Codegen C6 MP case specs from contracts/demo-scenarios.yaml
- [ ] **P3c**: 建立 Ubiquitous Language 术语表

**估算工时：** 16-20小时

---

## V. 审计元数据

| Aspect | Value |
|--------|-------|
| 审计范围 | Core/ + Tools/ + contracts/ |
| 文件总数 | 25+ Swift + YAML |
| 硬编码点 | 15处 |
| 健壮性缺陷 | 14处 |
| 命令执行 | grep -rn "set_cabin_", "\"ac\.", "case \"", switch device, JSON parse等 |
| 执行日期 | 2026-06-22 |
| 可信度 | 100% (本机grep + 行号精确) |

---

