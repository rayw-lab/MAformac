# Lens 1: C1→C2→C3→C5→C6 全链路不对齐盘点(生成式全集 vs D-domain 534工具范式)

# MAformac C1→C5→C6 全链路不对齐盘点

**as-of**: 2026-06-22  
**工作目录**: /Users/wanglei/workspace/MAformac  
**扫描范围**: C1契约→C2执行→C3管道→C5训练→C6基准

---

## 执行摘要

MAformac 核心5层存在**6类系统性不对齐**，根因是**新范式(D-domain 534具名工具+value编码)**与**旧范式(B_frame 671device/141action)**并存未完全切割。单一事实源(SSOT)在三个层级产生漂移：

| 层级 | 口径 | 权威来源 | 状态 |
|---|---|---|---|
| C1语义全集 | 3990行 JSONL | contracts/semantic-function-contract.jsonl | 🟢 锁定 |
| 10族device聚合 | 507 intent (definite only) or 680 intent (definite+disputed) | generated/10-family-device-boundary.md:14 | 🟡 部分对齐(缺definite/disputed分离) |
| 设备-family映射 | 223 device (definite only) | generated/10-family-device-map.json | 🟡 不含disputed |
| D_domain工具(新范式) | 6具名工具 | generated/D_domain.tools.json + ToolContractCompiler.dDomainSurfaceNames | 🟢 锁定 |
| B_frame工具(旧范式) | 671 device / 141 action | generated/B_frame.frame_schema.json | 🔴 未否决，仍在训练/评测 |
| 状态单元 | 5设备完整cell | contracts/state-cells.yaml | 🟡 缺10族其他设备 |

---

## 不对齐点详表

### 1️⃣ SSOT漂移：生成式全集 vs 设备聚合 vs 工具范式

**现状** (file:line):
- `/Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl` (3990行，671个device，1538个intent)
- `/Users/wanglei/workspace/MAformac/generated/10-family-device-boundary.md:4` 记录「3990行 / 671 device / 1538 intent」
- `/Users/wanglei/workspace/MAformac/generated/10-family-device-boundary.md:14` 统计「definite 507 intent / definite+disputed 680 intent」
- `/Users/wanglei/workspace/MAformac/generated/10-family-device-map.json` 映射223个device
- `/Users/wanglei/workspace/MAformac/generated/D_domain.tools.json` 仅6工具：query_cabin_comfort, set_cabin_ac, set_cabin_fan, set_cabin_screen_brightness, set_cabin_ambient_light, set_cabin_window

**新范式要求**:  
SSOT应唯一指向C1语义行集(3990行JSONL)，但按device聚合时必须精确到definite/disputed分离，再映射到10族 → D_domain 6工具。目前三个口径未形成闭合链路。

**改动类型**: 复用(已有数据，需链路穿通) + 文档化(补充SSOT穿通校验)

**根因**: 
- 10族边界分析(10-family-device-boundary.md)已精确到definite/disputed，但未回写C1行标记
- D_domain工具映射未覆盖10族全设备(仅6工具，缺座椅/车门/音量/雨刮/天窗/香氛)
- 生成器未内化「10族 → D_domain」的映射规则

---

### 2️⃣ 训练数据仍生成过期B_frame

**现状** (file:line):
```swift
// Core/Contracts/ToolContractCompiler.swift:23-27
public var frameToolSchema: [[String: JSONValue]] {
    [[
        "type": .string("function"),
        "function": .object([
            "name": .string("tool_call_frame"),  // 🔴 过期frame名
            ...
        ])
    ]]
}

// :48-52 renderedToolsText把B_frame和D_domain并挂
public var renderedToolsText: String {
    ToolContractJSONRenderer.render([
        "tools": .array((frameToolSchema + dDomainToolSchemas).map { .object($0) })
    ])
}

// :71-90 dDomainSurfaceNames硬编码仅6工具
private func dDomainSurfaceNames() -> [String] {
    var names: Set<String> = []
    if devices.contains("ac") || devices.contains("ac_temperature") {
        names.insert("set_cabin_ac")
        names.insert("query_cabin_comfort")
    }
    if devices.contains("ac_windspeed") {
        names.insert("set_cabin_fan")
    }
    // ...仅6工具，之后return names.sorted()
}
```

**生成的工具集**:
- `generated/D_domain.tools.json` = 6 functions
- `generated/B_frame.frame_schema.json` = 671 device + 141 action primitives
- C5训练仍消费B_frame：见下一点

**新范式要求**:  
canonical IR应保持device×action，但**exposed surface必须只是D_domain 6工具**(demo scope)。B_frame仅作内部状态转换IR，不应进入训练和评测。

**改动类型**: 重写(ToolContractCompiler需分离canonical IR和exposed surface)

**根因**:  
- generic frame(tool_call_frame) surface否决但canonical IR仍device×action，代码混淆了「canonical」和「exposed」两个层级
- dDomainSurfaceNames硬编码只能映射6工具，无法扩展到10族全设备

---

### 3️⃣ C5训练样本硬写tool_call_frame + 非自然中文协议合成

**现状** (file:line):
```swift
// Core/Training/C5LoRATraining.swift:2360-2365
private func makePositiveSample(...) -> C5TrainingSample {
    let valueAugmentation = C5TrainingRenderer.augmentValue(seed: seed, variant: variant)
    let slotAssignments = C5TrainingRenderer.slotAssignments(seed: seed, variant: variant, value: valueAugmentation.value)
    let call = C5TrainingToolCall(
        name: "tool_call_frame",  // 🔴 硬写过期B_frame工具名
        arguments: C5TrainingRenderer.toolCallArguments(seed: seed, value: valueAugmentation.value, slotAssignments: slotAssignments)
    )
    let renderedToolCall = C5TrainingRenderer.renderToolCall(call)
    let assistant = "\n\n" + renderedToolCall
    let localUtterance = C5TrainingRenderer.renderUserUtterance(seed: seed, variant: variant, valueText: valueAugmentation.utteranceValueText, slotAssignments: slotAssignments)
    // :2408
    tools: toolCallFrameSchema + distractors.schemas,  // 🔴 仍混B_frame+D_domain
    expectedToolCalls: [call],  // 期望仍是tool_call_frame
    ...
}

// :1755-1770 用户文本合成协议风格，非自然中文
private static func renderUserUtterance(seed: C5SemanticSeed, variant: Int, valueText: String, slotAssignments: [String: String]) -> String {
    // ...
    let suffix = suffixes[variant % suffixes.count]
    if valueText.isEmpty {
        return "device=\(seed.device); primitive=\(seed.actionPrimitive); slots=\(slotText); \(suffix)"
    }
    return "device=\(seed.device); primitive=\(seed.actionPrimitive); value=\(valueText); slots=\(slotText); \(suffix)"
    // 🔴 user角色文本是"device=ac_temperature; primitive=increase_by_exp; value=...; slots=..."
    // 不是自然中文"有点热/凉飕飕"这样的semantic语义
}
```

**问题后果**:
- 模型学的是 generic frame协议，不是D_domain具名工具
- 用户文本是机械协议风格(device=...;primitive=...)，不能验证「自然说法 → value四件套」的逆规整
- 评测期望tool_call_frame，但线上应该期望set_cabin_ac等D_domain工具 → θ-α 0/23根因之一

**新范式要求**:
- positive样本tool name应从semantic.device+primitive映射到D_domain具名工具(e.g., ac + power_on → set_cabin_ac with power=on)
- user文本应是真实自然中文变体(从生成服务或数据库采样)，或至少非协议风格
- tools列表应只包含D_domain 6工具+安全拒识工具，无B_frame

**改动类型**: 重写(C5LoRATraining.makePositiveSample + C5TrainingRenderer.renderUserUtterance + renderToolCall)

**根因**:  
θ-α早期设计用B_frame做canonical IR，评测也期望tool_call_frame，后来设计改为D_domain但代码未跟新。训练数据成为θ-α 0/23失败的直接根因。

---

### 4️⃣ C5 CLI无--scope D_domain导出，全量用词混杂

**现状** (file:line):
```swift
// Tools/C5TrainingCLI/main.swift:31-72
private struct Options {
    var command: String
    var repoRoot: URL
    var outputDir: String
    var targetPositiveRows: Int
    var devSelectionRows: Int
    var maskingStage: C5MaskingStage
    var baseModelDir: URL
    var generatedUtterancesURL: URL?
    var expectedOffsetArtifactSHA256: String?
    var allowRegeneratedOffsetArtifact: Bool
    var requireCandidateDataQualityGate: Bool
    var requireGeneratedUtteranceRecords: Bool
    var thetaAlphaPositiveOnly: Bool
    // 🔴 无scope、surface、d_domain_only等参数
    
    init(arguments: [String]) throws {
        let usage = "usage: C5TrainingCLI prepare [--repo-root PATH] [--output-dir PATH] ... [--theta-alpha-positive-only]"
        // 无--scope demo10 / --surface D_domain
    }
}
```

**问题后果**:
- C5 CLI只有全量生成模式，无法导出「仅demo范围(6工具)」专属训练集
- 无法验证demo范围的完整性(是否覆盖6工具的全intent)
- 无法与后续「demo vs全量」的分流分离

**新范式要求**:
- `--scope demo10` / `--surface D_domain` 参数控制导出
- D_domain专属导出时，只从10族 × definite device中采样，并映射到6工具
- 独立输出报告验证D_domain覆盖完整性

**改动类型**: 新建(CLI参数+D_domain导出逻辑)

**根因**:  
早期未预见demo和全量数据分离需求，CLI一直是全量生成。

---

### 5️⃣ C6基准30个MP用例期望旧工具名，缺D_domain覆盖验证

**现状** (file:line):
```swift
// Core/Bench/C6VehicleToolBench.swift:342-388 mustPassCases
private func mustPassCases() throws -> [C6BenchCase] {
    let specs: [CaseSpec] = [
        // 所有case都写死D_domain工具名：set_cabin_ac, set_cabin_window, set_cabin_fan等
        CaseSpec("C6-MP-001", "scene1", "ac_temperature", "query", "关空调", [], true, ["ac.power": "off"], [], .implicit, .noCall, ["ac.power"], "state-aware-no-repeat"),
        // ...
        CaseSpec("C6-MP-030", "scene1", "ac", "power_on", "别让车里这么闷", [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])], false, ["ac.power": "on"], ["空调"], .implicit, .action, ["ac.power"], "free-ac-on")
    ]
    return try specs.map { try makeCase($0, defaultState: defaultState, mustPass: true) }
}

// :419-420 覆盖采样仅7个device
private func coverageCases(existingIDs: Set<String>) throws -> [C6BenchCase] {
    let devices = ["ac_temperature", "window", "screen_brightness", "atmosphere_lamp_color", "atmosphere_lamp_brightness", "ac_windspeed", "car_door"]
    // 🔴 仅覆盖7个，未覆盖其他671 - 6 = 665个旧设备
}
```

**对应期望**:
- 30个MP用例逐case写死D_domain工具名(set_cabin_ac/window/fan/screen_brightness/ambient_light/query_cabin_comfort)  
- 但无法验证D_domain 6工具的全intent覆盖(缺intent × 工具维度的必过用例)
- 覆盖采样仅7个device，无法验证是否覆盖了10族的所有definite device

**新范式要求**:
- 为每个D_domain工具维护独立的intent覆盖集合(e.g., set_cabin_ac应覆盖power_on/power_off/adjust_to_number等所有primitive)
- MP用例应明确标记「这个用例验证D_domain工具X的primitive Y」
- Coverage用例应按10族 × definite device展开

**改动类型**: 复用(现有用例继续用)+ 补充(coverage用例扩展+工具维度分类)

**根因**:  
MP用例硬编成D_domain工具是对的(surface选型已定), 但没有配套的验证策略确保D_domain覆盖完整。

---

### 6️⃣ C6评测readback failure分类与脚本实现解耦

**现状** (file:line):
```swift
// Core/Bench/C6VehicleToolBench.swift:1025-1054
var failures: [C6FailureClass] = []
if output.parserFailure {
    failures.append(.parser)
}
if !candidate.expectNoCall, !toolMatch {
    failures.append(.toolCall)
}
if noToolFalsePositiveCount > 0 {
    failures.append(.noCall)
}
if !stateMatch {
    failures.append(.stateDelta)
}
if readbackApplicable && !readbackMatch {
    failures.append(.readback)  // 🔴 readback作为hardFailed因子之一
}
if !clarifyMatch {
    failures.append(candidate.clarifyTag == .rejected ? .refusal : .clarify)
}

return C6GateResult(
    // ...
    hardFailed: !failures.isEmpty,  // readback failure导致hardFailed=True
    failureClasses: failures,
    // ...
)
```

**脚本说法** (file:line):
```python
# scripts/_c6_axis_lib.py:1-20
"""共享：C6 axis schema-field 拆分 + action hard_pass 复算。
...
- schema 三分类（顺序敏感，refusal 先排，防 noop 双计）：
    refusal  = expect_no_call==True
    noop     = (非 refusal) AND expected_state_delta 非空 AND delta 各 key 在 pre 已是该值
    positive = 非 refusal AND 非 noop
- action hard_pass（不含 readback）= gate_result.tool_call_set_match AND state_delta_match
"""
```

**问题后果**:
- Swift代码：readback failure是hardFailed的一部分
- 脚本定义：action hard_pass"不含readback"
- 评测结果被反复解释，无单一事实源

**新范式要求**:
- 明确readback是否是「must-pass」判定的一部分
- 若是：修改脚本定义，action hard_pass应含readback
- 若否：修改Swift代码，readback failure单独记录，不并入hardFailed

**改动类型**: 复用(已有基础设施)+文档化(SSOT澄清readback地位)

**根因**:  
readback验证难度较高(模糊匹配)，早期设计时不确定是否纳入必过判定，导致代码和脚本各说各话。根据demo演示目标，建议readback作为"高质量"判定但不是"必过"判定的一部分。

---

### 7️⃣ 状态单元混新旧device命名，缺10族其他设备

**现状** (file:line):
```yaml
# contracts/state-cells.yaml:29-177
devices:
  air_conditioner:
    state_cells:
      - id: ac.power          # 🟢 新范式device名(对应semantic contract中ac)
      - id: ac.temp_setpoint  # 🟢
      - id: ac.fan_speed      # 🟢
  window:
    state_cells:
      - id: window.position   # 🟢
  screen:
    state_cells:
      - id: screen.brightness # 🟢
  ambient_light:
    state_cells:
      - id: ambient.color     # 🟢
      - id: ambient.brightness # 🟢
# 🔴 缺：seat/door/volume/wiper/sunroof/fragrance等10族其他设备的cell
```

```swift
// Core/State/DemoVehicleStateStore.swift:134-158
public static func defaultCells() -> [DemoVehicleStateCell] {
    [
        DemoVehicleStateCell(key: "ac.power", actualValue: "off"),           // 🟢 新范式
        DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24"),  // 🟢
        // ...
        DemoVehicleStateCell(key: "hvac.ac", actualValue: "off"),            // 🔴 旧范式(不在state-cells.yaml)
        DemoVehicleStateCell(key: "hvac.temperature", actualValue: "24"),    // 🔴 旧范式
        DemoVehicleStateCell(key: "seat.driver.heat", actualValue: "off"),   // 不在state-cells.yaml
        DemoVehicleStateCell(key: "window.driver", actualValue: "closed"),   // 不在state-cells.yaml(命名也不同：state-cells用position)
        // ...
        DemoVehicleStateCell(key: "fan.speed", actualValue: "0"),            // 不在state-cells.yaml
    ]
}

// Core/Intent/FastPathIntentEngine.swift:16-25
public func decode(_ text: String) throws -> ToolCallFrame {
    guard normalized == "打开空调" else {
        throw FastPathIntentError.noMatch(text)
    }
    return ToolCallFrame(
        // ...
        arguments: [
            "state_key": "hvac.ac",      // 🔴 使用旧device名(应该用ac.power)
            "target_state": "on"
        ],
        // ...
    )
}
```

**问题后果**:
- state-cells.yaml只覆盖5设备，不足以支撑10族演示
- defaultCells()混合新旧命名，导致state read/write不一致
- FastPathIntentEngine使用hvac.*命名，与ac.*命名冲突

**新范式要求**:
- state-cells.yaml应补完10族所有L1设备的完整cell定义(至少座椅/车门/音量的core cell)
- defaultCells()应严格对应state-cells.yaml的key定义
- FastPathIntentEngine应使用state-cells.yaml权威key

**改动类型**: 重写(state-cells.yaml补完10族) + 复用(defaultCells和FastPathIntentEngine改指向权威)

**根因**:  
state-cells.yaml在CC设计时只聚焦5设备demo路径，后续演示扩展但cell定义未跟新。defaultCells和FastPathIntentEngine是legacy代码遗留。

---

### 8️⃣ Risk-policy设计正确，缺θ-β safety_refusal数据

**现状** (file:line):
```yaml
# contracts/risk-policy.yaml:1-5
# ⚠️ 本文件是独立 demo 风险策略。C1 行的 `risk` 字段【仍全空】
# 把 risk 写进 C1 行需同刀改 gen_c1 + verify_refs(T2 耦合), 本 change 不做。
# 本文件只定义"风险级→demo 行为"映射, 由 verify_risk_policy 校验内部一致
```

```swift
// Core/Execution/C3ExecutionPipeline.swift:94-103
switch riskPolicy.evaluate(device: frame.device, stateValues: store.stateValues) {
case .allow:
    break
case .confirm(let reason):
    traceLogger.recordGuard(traceID: frame.traceID, message: reason, ...)
    throw ToolExecutionError.guardDenied(reason)
case .refuse(let reason):
    traceLogger.recordGuard(traceID: frame.traceID, message: reason, ...)
    throw ToolExecutionError.guardDenied(reason)
}
```

**现状**:
- risk-policy.yaml明确「独立，不写入C1行」→ 设计正确(T2耦合留后续change)
- C1行risk字段全空 → verify_refs.verify_contract_invariants检查强制
- C3管道走code safety gate评估risk → 实现正确

**缺陷**:
- θ-β没有safety_refusal专属训练数据(model该学会「某些情景下拒识」)
- risk_level→demo_action的映射定义了但没有训练数据支撑

**新范式要求**:
- C5训练应为safety_refusal场景生成专属样本(noCall+拒识理由)
- risk_level应从policy映射到训练数据的label
- C6基准应包含L4安全拒识的完整测试用例

**改动类型**: 新建(θ-β safety_refusal数据采样+生成)

**根因**:  
risk-policy设计已经正确且独立，但数据生成流程未配套实现。是θ-α 0/23的间接根因。

---

## 复用、重写、新建总清单

| 文件 | 行号 | 现状 | 新范式要求 | 改动类型 |
|---|---|---|---|---|
| ToolContractCompiler.swift | 23-27 | frameToolSchema硬写tool_call_frame | canonical IR与exposed surface分离 | 重写 |
| ToolContractCompiler.swift | 48-52 | renderedToolsText混B_frame+D_domain | canonical IR用device×action，exposed仅D_domain | 重写 |
| ToolContractCompiler.swift | 71-90 | dDomainSurfaceNames硬编6工具 | 从10族device映射到D_domain工具 | 复用+扩展 |
| C5LoRATraining.swift | 2362 | tool_call_frame硬写 | 从semantic映射到D_domain工具名 | 重写 |
| C5LoRATraining.swift | 2408 | tools混B_frame+D_domain | tools仅包D_domain 6工具 | 重写 |
| C5LoRATraining.swift | 1767-1769 | 协议风格user文本 | 自然中文或生成文本 | 重写 |
| C5TrainingCLI/main.swift | 31-72 | 无scope/surface参数 | 新增--scope demo10 / --surface D_domain | 新建 |
| C6VehicleToolBench.swift | 342-388 | MP用例硬编D_domain工具(可) | 补充工具维度覆盖标记 | 复用+补充 |
| C6VehicleToolBench.swift | 419-420 | 覆盖采样7 device | 覆盖10族全definite device | 复用+扩展 |
| C6VehicleToolBench.swift | 1038-1039 | readback作为failure | 澄清readback必过地位 | 复用+文档化 |
| state-cells.yaml | 29-177 | 仅5设备cell | 补完10族L1设备cell | 新建 |
| DemoVehicleStateStore.swift | 134-158 | 混新旧device命名 | 严格对应state-cells.yaml | 复用 |
| FastPathIntentEngine.swift | 16-25 | hvac.*旧名 | 用ac.power新名 | 复用 |
| C3ExecutionPipeline.swift | 94-103 | code safety gate(可) | θ-β训练数据支撑 | 新建(数据) |
| (无具体文件) | (SSOT穿通) | 3990行→671device→223family→6tool | 补充映射校验脚本+文档 | 新建(工具) |

---

## 背景：新范式 vs 旧范式对比

| 维度 | 旧范式(B_frame) | 新范式(D_domain) | 现状 |
|---|---|---|---|
| **IR形态** | device × action_primitive(671 × 141) | value编码进名：set_cabin_ac(power/delta/target_temperature/delta) | IR用旧，exposed新 |
| **训练目标** | tool_call_frame(通用) | D_domain具名工具(6个) | 训练仍用tool_call_frame |
| **用户文本** | device=...;primitive=...协议 | 自然中文变体 | 仍用协议风格 |
| **覆盖单位** | 展开语义行(3990行) | 10族×definite device×primitive组合 | 混用，未明确边界 |
| **设备范围** | 全671(生成式全集) | 10族×definite 161 device | 无明确切割 |
| **状态承载** | B_frame内部IR | state-cells.yaml(C2权威) | 混新旧state名 |
| **安全层级** | risk字段(旧设计) | risk-policy.yaml(R0-R2分级)+ code safety gate | policy设计对，数据缺 |

---

## Codex言论验证(codex_claim_checks)

### Codex Claim 1: 数字口径混乱

**Claim**: generated/10-family-device-boundary.md:4 vs GLM计数 534 intent

| Codex言论 | 实际file:line | 数值对照 | 真值判定 |
|---|---|---|---|
| "3990行/671device" | 10-family-device-boundary.md:4 | ✅ 确认3990行、671device | confirmed |
| "definite 507intent / definite+disputed 680intent" | 10-family-device-boundary.md:14 | ✅ 表格行14确认 | confirmed |
| "generated/10-family-device-map.json=223device" | 10-family-device-map.json | ✅ 223个映射条目 | confirmed |
| "GLM坐实534intent" | (无对应文件记录) | ❌ 本机未找到534的一手来源 | unverifiable |
| "与§14 GLM口径冲突" | (间接推导) | ⚠️ 因果：507/680 ≠ 534，但534来源未确认 | partial |

**结论**: 数字本身对(507/680/223/671都查证)，但534的来源需追溯到最初的GLM对话记录或邮件，不在本机代码树中。

---

### Codex Claim 2: B_frame仍在训练

**Claim**: ToolContractCompiler.swift:23/48/71 生成tool_call_frame + B_frame

| Codex言论 | file:line | 代码验证 | 判定 |
|---|---|---|---|
| ":23仍生成tool_call_frame" | ToolContractCompiler.swift:23-27 | ✅ 第26行`"name": .string("tool_call_frame")` | confirmed |
| ":48 renderedToolsText把B_frame+D_domain一起挂" | ToolContractCompiler.swift:48-52 | ✅ 第50行`frameToolSchema + dDomainToolSchemas` | confirmed |
| ":71 dDomainSurfaceNames仅硬编码6工具" | ToolContractCompiler.swift:71-90 | ✅ 循环内仅insert 6个工具名 | confirmed |
| "generated/D_domain.tools.json=6" | generated/D_domain.tools.json | ✅ JSON数组长度=6 | confirmed |
| "B_frame仍有671device/141action" | generated/B_frame.frame_schema.json | ✅ device enum长度=671, action_primitive长度=141 | confirmed |

**结论**: B_frame并未否决，canonical IR仍在生成，只是D_domain作为exposed surface硬编6工具。这是设计，但与「generic frame surface否决」的目标产生gap。

---

### Codex Claim 3: C5训练用旧frame

**Claim**: C5LoRATraining.swift:2362/2408 + renderUserUtterance:1767

| Codex言论 | file:line | 代码验证 | 判定 |
|---|---|---|---|
| ":2362正样本工具名写死tool_call_frame" | C5LoRATraining.swift:2362 | ✅ `name: "tool_call_frame"` | confirmed |
| ":2408 tools=toolCallFrameSchema+distractors" | C5LoRATraining.swift:2408 | ✅ 第2408行`tools: toolCallFrameSchema + distractors.schemas` | confirmed |
| ":1743用户文本device=...;primitive=..." | C5LoRATraining.swift:1767,1769 | ✅ 字符串模板`"device=\(seed.device); primitive=..."` | confirmed |
| "非自然中文协议风格" | C5LoRATraining.swift:1755-1770 | ✅ suffix是描述性语义，但主体是protocol格式 | confirmed |
| "C5TrainingCLI main.swift:31仅读全量C1无--scope/--surface" | Tools/C5TrainingCLI/main.swift:9-72 | ✅ Options无scope字段 | confirmed |

**结论**: 全部confirmed。C5数据生成仍用旧B_frame+协议文本。

---

### Codex Claim 4: C6基准旧用例+readback分类不一致

**Claim**: C6VehicleToolBench.swift:342/419/1038

| Codex言论 | file:line | 代码验证 | 判定 |
|---|---|---|---|
| ":342 30 MP case期望set_cabin_*" | C6VehicleToolBench.swift:356-387 | ✅ CaseSpec逐行写死D_domain工具名 | confirmed |
| ":419覆盖仅7device" | C6VehicleToolBench.swift:420 | ✅ `let devices = [7个名字]` | confirmed |
| ":1038 readback failure放hardFailed" | C6VehicleToolBench.swift:1038-1039 | ✅ `failures.append(.readback); ...hardFailed: !failures.isEmpty` | confirmed |
| "scripts/_c6_axis_lib.py:11已排除readback" | scripts/_c6_axis_lib.py:1-20 | ✅ 注释明确"action hard_pass（不含readback）" | confirmed |

**结论**: 代码和脚本定义不一致，是readback分类地位不明造成的。

---

### Codex Claim 5: State单元混新旧

**Claim**: state-cells.yaml:29 仅5设备 vs DemoVehicleStateStore.swift:134混ac.power+hvac.ac

| Codex言论 | file:line | 代码验证 | 判定 |
|---|---|---|---|
| "state-cells.yaml仅5设备" | contracts/state-cells.yaml:30-152 | ✅ air_conditioner/window/screen/ambient_light/safety_cells 5个device组 | confirmed |
| "缺座椅/车门/音量/雨刮/天窗/香氛" | contracts/state-cells.yaml | ✅ 全文搜无seat/door/volume/wiper/sunroof/fragrance | confirmed |
| "defaultCells混ac.power+hvac.ac" | Core/State/DemoVehicleStateStore.swift:136,150 | ✅ 第136行`ac.power`，第150行`hvac.ac`共存 | confirmed |
| "FastPathIntentEngine:16用hvac.ac" | Core/Intent/FastPathIntentEngine.swift:21 | ✅ `"state_key": "hvac.ac"` | confirmed |

**结论**: 全部confirmed。状态单元确实混新旧。

---

### Codex Claim 6: Risk-policy设计对，缺数据

**Claim**: risk-policy.yaml:1 "独立不写入C1行" vs C3ExecutionPipeline:94 code safety gate

| Codex言论 | file:line | 代码验证 | 判定 |
|---|---|---|---|
| "risk-policy.yaml:1明确独立" | contracts/risk-policy.yaml:1-5 | ✅ 注释明确"不写入C1行" | confirmed |
| "C1 risk空是当前设计" | (推导自verify_refs约束) | ✅ 设计选择正确 | confirmed |
| "C3ExecutionPipeline:94走code safety gate" | Core/Execution/C3ExecutionPipeline.swift:94-103 | ✅ `riskPolicy.evaluate(device:...)` | confirmed |
| "缺θ-β safety_refusal数据" | (全库搜索无专属safety样本生成) | ✅ 无对应代码 | confirmed |

**结论**: 设计和实现一致，缺的是C5数据层的support。这不是bug而是incomplete feature。

---

## 改动优先级矩阵

| 优先级 | 不对齐点 | 阻断范围 | 建议处理 |
|---|---|---|---|
| **P0** | B_frame仍在训练(点2/3/4) | θ-α 0/23致命 | 立刻重写C5和ToolContractCompiler |
| **P0** | 用户文本协议风格(点3) | 模型无法学自然语义 | 同上 |
| **P1** | SSOT漂移(点1) | 覆盖率报告虚假 | 建立映射校验脚本 + CONTEXT文档 |
| **P1** | 状态混新旧命名(点7) | 运行时state不一致 | state-cells补完+defaultCells改指向 |
| **P2** | C5 CLI无demo导出(点4) | demo和全量数据混杂 | 新增CLI参数 |
| **P2** | C6基准readback分类(点6) | 评测SSOT混乱 | 文档化澄清readback地位 |
| **P3** | Safety数据缺失(点8) | 后续feature incomplete | C5层支撑数据生成 |

---

## 可复用资源总结

| 模块 | 文件 | 可复用部分 | 建议重用方式 |
|---|---|---|---|
| **C5训练框架** | Core/Training/C5LoRATraining.swift | :1175 rank16 recipe / :1734 name-first renderer | 迁移到新的semanticIR→D_domainTool流程 |
| | | :2370-2412 C5TrainingSample完整结构 | 保留结构，仅改tool name和user文本 |
| **Validation层** | Core/Training/C5LoRATraining.swift | :mask/offset/lineage/data gate逻辑 | 复用gate检查，补充D_domain覆盖校验 |
| **Axis库** | scripts/_c6_axis_lib.py | :11-20 case分类逻辑(refusal/noop/positive) | 复用分类，补充readback判定澄清 |
| **Risk框架** | contracts/risk-policy.yaml | R0-R2分级映射 | 保留结构，补充训练数据生成逻辑 |
| **State基础** | contracts/state-cells.yaml | ac/window/screen/ambient_light cell范式 | 用现有模板扩展到10族 |

---

## 结论与建议

### 现状
- **意图正确**: D_domain 6工具设计已定、state-cells.yaml范式已清、risk-policy逻辑已定
- **实现滞后**: B_frame和D_domain并存、训练数据仍用旧format、状态单元混名

### 根本原因
1. **新旧范式过渡未完成**: θ-α早期用B_frame做canonical IR，后改为D_domain但代码未跟新
2. **SSOT未穿通**: 3990行→671device→223family的映射链路未闭合
3. **数据生成与运行时脱离**: C5训练没有跟上C2/C3运行时的device命名和工具选型

### 建议行动
1. **即刻P0**: 重写C5LoRATraining + ToolContractCompiler，tool_call_frame改为D_domain具名工具映射
2. **即刻P0**: 清理用户文本合成，改为自然中文或从生成服务采样
3. **本周P1**: 建立SSOT穿通校验脚本(3990行→D_domain完整性检查)
4. **本周P1**: state-cells.yaml补完10族、defaultCells同步改指向
5. **周末P2**: C5 CLI增加--scope demo10 / --surface D_domain参数
6. **后续P3**: C5层补充θ-β safety_refusal训练数据

---

## 精确行号总索引

```
不对齐点1: 
  - generated/10-family-device-boundary.md:4,14
  - generated/10-family-device-map.json
  - generated/D_domain.tools.json
  - generated/B_frame.frame_schema.json

不对齐点2:
  - Core/Contracts/ToolContractCompiler.swift:23-27,48-52,71-90

不对齐点3:
  - Core/Training/C5LoRATraining.swift:2362,2408,1767-1769
  - Tools/C5TrainingCLI/main.swift:31-72

不对齐点4:
  - Core/Bench/C6VehicleToolBench.swift:342-388,419-420

不对齐点5:
  - Core/Bench/C6VehicleToolBench.swift:1038-1039
  - scripts/_c6_axis_lib.py:11-20

不对齐点6:
  - contracts/state-cells.yaml:29-177
  - Core/State/DemoVehicleStateStore.swift:134-158
  - Core/Intent/FastPathIntentEngine.swift:16-25

不对齐点7:
  - contracts/risk-policy.yaml:1-5
  - Core/Execution/C3ExecutionPipeline.swift:94-103
```
