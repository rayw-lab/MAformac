# Dispatch: change3 `define-execution-contract` 主体实装 — 纯逻辑契约层（E1b 解耦）· v2 self-audit 回填版

> **v2(2026-06-19)**:经 CC self-audit 对抗审计回填 6 个 catch（见 §0.6）。**以本版为准**。

## 0. 路由元信息
- **TO**:Codex（长跑 TDD）  · **FROM**:Claude（CC0）  · **PRIORITY**:P0（change3 主线）
- **MODE / MODEL**:Codex 本地长跑，TDD（red→green→refactor），持续 commit
- **一句话 DELIVERABLE**:change3 执行链**纯逻辑契约层**实装进 `MAformacCore`（自定义 `JSONValue` + capabilities codegen + content-fallback 候选 + 两层 decode + 错误枚举三态 + DemoGuard R0–R3 schema 门 + mock executor + readback + trace 五段 + 升级 change1），用 **spike 实采 55 条 fixture** 驱动，**`swift test` 全绿**。**不引真 MLX**。

## 0.6 🔴 self-audit 回填的 6 个 catch（实装重点，别再踩）
1. **C1 T7 命名漂移是三处不是一处**:`DemoGuard.swift:16-24` + `DemoActionExecutor.swift:14-22` + `FastPathIntentEngine.swift:17-22` 全有 `vehicle.ac.toggle`/`set_vehicle_control`/`state_key`/`target_state` 旧命名。只修一处 → build 绿但执行链断（guard 新命名放行→executor 旧命名抛 `unsupportedTool`）。
2. **C2 codegen 用手动脚本，不用 SwiftPM plugin**:`Package.swift` 是 `path:"."` 单 target，`contracts/` **在 exclude 列表**且**不动 Package.swift** 是红线 → plugin 路线撞墙。见 0.3。
3. **C3 DemoGuard 是 schema 门，不是语义拒识门**:挡不住 schema 合法的 restraint（N016/N017）/意图越界（N002）。负例 fixture 验的是「不崩+读回真态+trace 如实」，**不是** guard 拦截。见 T3。
4. **C4 T5 数组/标量 fixture 只能合成**:spike 实采 arguments 全是 flat scalar（`{str,int}`，0 数组/0 嵌套）。T5 边界用例**允许合成**（标 coincidental-correctness），与「smoketest 实采」是两类测试。见 §5。
5. **C5 ToolCallFrame 三必填字段无 fixture 来源**:`agentID`/`capabilityID`/`surfacePolicy` 不在 fixture（只有 name+args）→ 由 codegen 反查表补。见 1.2。
6. **C6 最危险负例 N002 别一锅烩**:N002 是真 `.toolCall` 误触发（非裸 JSON），content-fallback 无关，纯靠上游拒识——单列验证。见 §3.5。

## 1. 冷启动背景（零上下文也能懂）
- **项目**:MAformac = 纯端侧 iOS/macOS 离线车控**方案演示助手**（非量产/非真车控）。**起手必读** `CLAUDE.md` → `docs/README.md` → `docs/handoffs/2026-06-19-spike-intent-routing.md` → 本 dispatch。
- **本任务处于**:OpenSpec apply；7-change 第 **3** 个 `define-execution-contract`。
- **🔴 范围决策 E1b（2026-06-19 磊哥拍）**:本 change = **纯逻辑契约层，不引真 MLX runtime**。原因:MLX 进 iOS App target 撞未验集成坑（metallib 打包 / **MLX 在 iOS Simulator 必崩** [mlx#2605] / jetsam OOM 需 entitlement），且契约层单测无法在 Simulator 跑。MLX runtime 接入（锁 format + 消费实时 `.toolCall` 流）**拆出独立 change**，接入前先最小 iOS 真机冒烟——**不在本 dispatch**。本 change 用 spike 实采输出做 fixture，`swift test` 即可跑。

## 2. 任务（TASK）
事实源 = `openspec/changes/define-execution-contract/{design,tasks,proposal}.md` + `specs/tool-execution/spec.md`（绝对路径见 §6）。**以 `tasks.md` 勾选项为准**，逐项 TDD。

**T0 契约层底座**
- **0.2 自定义 `JSONValue` enum**:7-case（null/bool/int/double/string/array/object），`Codable+Hashable+Sendable`，**不 `import MLXLMCommon`**。形态镜像上游 `Value.swift`（只读参考，不依赖）。放 `Core/` 合适模块。
- **0.3 capabilities → Swift codegen（C2:手动脚本，不用 plugin）**:写独立脚本（`scripts/gen_capabilities.*`，手动 `swift`/`python3` 跑），读 `contracts/capabilities.yaml` + `contracts/agents.yaml` → 生成 Swift 源文件到 **`Core/Generated/`**（在 `sources:["Core"]` 内，test target 可见），含:① 每 capability 的 `tool_schema`(name+参数 schema) + `demo_guard`(risk_level/confirm_policy/writable/range/enum/preconditions) + `execution`(state_cell/exclusive_bus/mock_behavior) + `reference_binding.writable`;② **三张反查表**(见 1.2)。生成物 commit 进仓，标 `// GENERATED from contracts/*.yaml — do not edit`。**不改 `Package.swift`、不用 SwiftPM build plugin**（`contracts/` 在 exclude，plugin 读不到 + 改 Package 撞红线）。**禁运行时 Yams 解析**。

**T1 ToolCallFrame 薄层（契约层）**
- **1.2 `ToolCallCandidate` → `ToolCallFrame`**:候选源 = spike fixture。`arguments` 从 change1 占位 `[String:String]` 升级**自定义** `[String:JSONValue]` 全类型归一（对象/字符串化 JSON/数组/标量不丢，T5）。**修 change1 `Core/Routing/ToolCallFrame.swift`**。**C5 字段映射**(fixture 只有 name+args，frame 三必填字段由 0.3 codegen 反查表补):
  - `capabilityID` = `toolName` → `capabilities.yaml.tool_schema.name` 反查 `.id`（`set_cabin_ac`→`cabin.ac`）
  - `agentID` = `capabilityID` → `agents.yaml.capability_ids` 反查 `.id`（`cabin.ac`→`vehicle-control`）
  - `surfacePolicy` = `agents.yaml.surface_policy`（`vehicle-control`→`primary_panel`）
- **1.3 content-fallback 候选层**（E1a，**C3:可配置开关**）:裸单个 `{"name":...,"arguments":...}` → `ToolCallCandidate(source:contentFallback)`，**抄上游 `ToolCallProcessor.processInlineChunk`(源码 line 108-135) brace-count 思路**，不另发明算法、不吞混排文本、不重建 `<tool_call>` parser。候选**不得直接执行**。**设 feature flag**（默认行为 + restraint 净影响留 change6 实测，见 T3/C3）。
- **1.4 两层 decode 边界**:严格 enum/required/类型/范围校验门挂**第②层**（`execute()` 前 `decode(Input.self)`），非宽松第①层候选解析。

**T2 错误枚举**
- **2.1** 自写 `throws` decoder → 三态:`no_tool_call`/`malformed`/`schema_invalid`(细分 `unknown_tool`/`missing_field`/`type_mismatch`/`out_of_range`)。
- **2.2** 面向模型输出的 enum **手写 `init(from:)`**（未知值落 `unknown`/转 decode_failed）；**全链路禁 `try!`/`try?`**（do/catch）。**C8 豁免**:`JSONValue.init(from:)` 自身的**类型试探**（顺序尝试 bool/int/double/string/array/object）是合法构造，可用 `if let x = try? container.decode(T.self)` 或 do/catch，**不算违禁**（禁令针对**业务 decode 路径吞 DecodingError**，非 JSONValue 类型嗅探）。
- **2.3** retry≤1（仅 `malformed`）+ `decode_failed` → 澄清，无无限重试。

**T3 DemoGuard schema 门（C1 命名三处 + C3 边界）**
- **3.1** R0–R3 代码门:unknown tool/schema/范围枚举/writable/风险等级/确认策略/互斥 bus/前置条件（规则源 = 0.3 codegen 产物）。
  - **🔴 C1 修 T7 三处**:删 `DemoGuard.swift:16-24` + `DemoActionExecutor.swift:14-22` + `FastPathIntentEngine.swift:17-22` 的 `vehicle.ac.toggle`/`set_vehicle_control`/`state_key`/`target_state`，全切 capabilities.yaml 命名（`cabin.*`/`set_cabin_*`/`power|level|percent|color|topic`）。executor 升级:`frame.toolName`+`arguments` → 查 `capabilities.execution.state_cell` → `DemoMockTransition(key:state_cell, desiredValue:按 schema 提主参数)`。
  - **🔴 C3 DemoGuard 是 schema 门，不是语义拒识门**:它防 unknown tool/越界/缺字段/非法 enum/不可写/风险确认，**挡不住** schema 合法的 restraint（N016 `set_cabin_ac{power:off}`、N017 `query_cabin_comfort{topic}`）和意图越界（N002 `set_cabin_fan{level:2}`）——这些 schema 全合法，DemoGuard **会放行**。**别为「DemoGuard 拦截 restraint」建测试**（capabilities.yaml demo_guard 无 restraint 字段，做不到）。这类负例的真防线 = intent-routing 拒识 + LoRA 负样本（**非本 change**）。
  - R0/R1 完整（实际数据覆盖:R0=空调/座椅/氛围灯/屏幕/风量/查询，R1=车窗）；**R2/R3 门逻辑实装 + 合成 fixture 验**（无实际数据，标 coincidental-correctness）。
  - 验收:`Unsafe false pass=0`(unknown/越界/缺字段/非法 enum 均拒)；cross-check 断言 `frame.toolName ∈ tool_schema.name 集`。
- **3.2** `think_leak`:fixture `chunkText` 含 `<think>` → trace 记 + 该轮失败/降级澄清（spike thinkLeak=0，用合成 fixture 验门逻辑）。

**T4 trace + 升级 change1**
- **4.1** TraceLogger 五段（decode/plan/guard/execute/readback）+ 显式记 `toolCalls.count`/`stopReason`（fixture `completion.stopReason`）+ **分开记 raw `.toolCall` / fallback candidate / guard 后实际执行**（E1a 三口径，供 change6 量化 content-fallback 净 G3 影响）。
- **4.2** 升级 change1 `DemoWalkingSkeleton`（`Features/VehicleControl/`）:单条放行占位 → 接完整契约层（decoder+完整 DemoGuard+executor+readback），**fixture 驱动，不接真 MLX**。**C1**:`FastPathIntentEngine` 现有硬编码「打开空调」那条**切新命名**（→ `set_cabin_ac{power:on}`），保证 text→frame→guard→executor 全链路新命名**自洽不断**；其**完整规则 NLU 扩展**归 intent-routing change（本 change 只切现有一条命名）。change1 闭环测试仍绿。

## 3. Prerequisite Check（起手必跑）
```bash
cd /Users/wanglei/workspace/MAformac
git status --short ; git log --oneline -1
ls Core/Execution/ Core/Routing/ Core/Intent/ Features/VehicleControl/   # change1 现状(DemoGuard/DemoActionExecutor/ToolCallFrame/FastPathIntentEngine/DemoWalkingSkeleton)
test -f dev/spike-e3/Reports/spike-e3-results.json && echo "fixture 源在" || echo "BLOCKED: 缺 fixture"
grep -rn "set_vehicle_control\|vehicle.ac.toggle\|state_key\|target_state" Core/ Features/   # T7 旧命名三处现状(应见 3 文件)
swift test 2>&1 | tail -5                                                  # change1/2 基线(应绿)
```
hard-code 数字标 `(snapshot 2026-06-19，以上方 Check 为准)`。

## 3.5 Fixture 提取（真实数据源，C6 负例分类）
`dev/spike-e3/Reports/spike-e3-results.json` = spike 实采 55 条（`enable_thinking=false`）。每条 `CaseResult`:`id`/`expectedTool`/`isNegative`/`toolCalls[{name,arguments}]`/`chunkText`/`completion.stopReason`。解析成本 change 自定义 `JSONValue` fixture（**禁手搓 keyword、禁 LLM 自造**，codex §23）:
- **正例（40 条全用）**:`toolCalls` 非空 → 驱动 1.2/1.4/3.1（decode+guard+readback）。
- **content-fallback fixture（9 条裸 JSON）**:P002/P008/P013/P018/P022/P027/P028/P029/P030（`toolCalls` 空 + `chunkText` 裸 JSON）→ 驱动 1.3。
- **restraint 负例（C6）**:N016（`{"name":"set_cabin_ac","arguments":{"power":"off"}}`）/ N017（`query_cabin_comfort{topic}`）→ 裸 JSON，验证「content-fallback 开启时 → 候选过 schema 门**会执行**（已知 G3 代价）；trace 三口径如实记；不崩」。**不是验 DemoGuard 拦截**。
- **🔴 N002 单列（C6）**:`toolCalls=[set_cabin_fan{level:2}]` 真 `.toolCall` 误触发（写诗→车控），`contentLooksLikeToolCall=false`。content-fallback **无关**，schema 合法 DemoGuard 放行 → 验证「change3 不崩 + 读回真态 + trace 如实记 raw `.toolCall` 误执行」；拒识它是 intent-routing/LoRA 的事。
- **OOD 负例 N001/N003-N015**:无 toolCall → 验 `no_tool_call`。

## 4. 边界（CONSTRAINTS）
- **🔴 红线**（`CLAUDE.md §6`）:真实客户名「某车厂」；密钥/PII/车型代号绝不入仓；RAW/下载只读不进仓；**不降级**。
- **🔴 不引 MLX**:契约层 grep **无 `import MLXLMCommon`/`import MLXLLM`**；**不动 `Package.swift`**（不加依赖、不加 plugin target）；不碰 `dev/spike-e3/`（只读 fixture）。
- **禁区**:`contracts/*.yaml`（事实源，只读消费/codegen，不改）；`specs/`（行为契约不改）；已 archive 的 change1/2。
- **OUT_OF_SCOPE**（撞到→返回说明+建议归属，不硬扛）:锁 `.json` format/消费实时 `.toolCall` 流/真机加载模型/metallib/entitlement → 「MLX runtime 接入 change」；FastPathIntentEngine **完整规则 NLU** → intent-routing change（本 change 只切现有一条命名）。

## 5. 验收门（codex §23 三硬约束 + tasks 验收 + Pre-Mortem）
- **每条 task 带证据**（不写「完成/OK」，带等级/数据）:
  - `swift test` **全绿**（契约层纯逻辑，**不需 metallib/Simulator**）。
  - **(a) unexpected error → failure receipt**（risk_state 枚举 + 实际异常，别静默吞）。
  - **(b) smoketest 实采 ≥55**（spike **40 正例全覆盖 + 15 负例全覆盖**，含 N002/N016/N017；非 mock/非自造）。**C4 例外**:T5「数组/字符串化 JSON/标量归一」spike 无实采形态，**允许合成边界用例**（标 coincidental-correctness），属契约单元测试，与 smoketest 分开。
  - **(c) 错误 risk_state mapping table-driven test ≥5 源错误类型**:`no_tool_call`/`malformed`/`unknown_tool`/`missing_field`/`type_mismatch`/`out_of_range`（≥6）。
  - `Unsafe false pass=0`；`readback mismatch=0`；`pending/failed/unknown` 不播「已完成」。
  - **C1 T7 cross-check**:`grep -rn "set_vehicle_control\|vehicle.ac.toggle\|state_key\|target_state" Core/ Features/` **零命中**；断言 `frame.toolName ∈ tool_schema.name 集`。
  - 全链路 grep **无 `try!`/`try?`**（C8:JSONValue 类型试探豁免，需注释标明）；契约层 grep **无 `import MLXLMCommon`**；**codegen 幂等**（二次跑 0 diff）；**不动 `Package.swift`**（git diff Package.swift 为空）。
- **必过门**:`openspec validate define-execution-contract`（strict）通过；`swift test` 全绿；change1 闭环测试不破。
- **叠加 Superpowers**:TDD（每 task red→green）+ verification-before-completion（收尾自验）。
- **Pre-Mortem Risks 已落 `design.md` Risks 段 T1–T9 + E1a/E1b**;实装新踩坑**当场回流** dispatch + `docs/lessons-learned.md`。

## 6. 相关文件（优先读，≤5，绝对路径）
1. `/Users/wanglei/workspace/MAformac/openspec/changes/define-execution-contract/design.md`（**E1b 解耦 + E1a content-fallback + T9 DemoGuard 边界 + 决策表 + Risks T1-T9**）
2. `/Users/wanglei/workspace/MAformac/openspec/changes/define-execution-contract/tasks.md` + `specs/tool-execution/spec.md`
3. `/Users/wanglei/workspace/MAformac/contracts/capabilities.yaml` + `contracts/agents.yaml`（8 capability + 4 agent 事实源:tool_schema/demo_guard/execution/反查源）
4. `/Users/wanglei/workspace/MAformac/dev/spike-e3/Reports/spike-e3-results.json`（fixture 源 55 条）+ `Core/{Execution/DemoGuard.swift,Execution/DemoActionExecutor.swift,Routing/ToolCallFrame.swift,Intent/FastPathIntentEngine.swift}`（T7 三处 + change1 现状）
5. 上游源码**只读参考**（镜像/抄思路，不依赖）:`/Users/wanglei/workspace/MAformac/dev/spike-e3/.build/checkouts/mlx-swift-lm/Libraries/MLXLMCommon/Tool/{Value.swift,ToolCall.swift,ToolCallProcessor.swift:108-135}`

## 7. 完成回报（带 status field）
- **status**:`done` / `blocked` / `partial`
- **产出清单**:文件 + 每项 task 验收结果（带证据:`swift test` 通过数 / table-driven error 行数 / T7 grep 零命中 / codegen diff / Package.swift 未动）。
- **BLOCKED**:`BLOCKED: <缺什么> FROM: <需谁/资源>`。
- **关键发现/偏差**:分清 `introduced`（本次引入）vs `exposed`（旧债暴露:T7 命名漂移三处 = change1 旧债被本 change 暴露）。
- **下一步建议**:具体动作（MLX runtime 接入 change 粒度 / R2/R3 实际数据缺口 / content-fallback 默认开关 + 净 G3 影响在 change6 的验证点 / FastPathIntentEngine 完整 NLU 归 intent-routing）。
