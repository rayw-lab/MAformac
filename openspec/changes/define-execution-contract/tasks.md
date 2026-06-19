> 范围:7-change 第 3 个。升级 change1 walking skeleton（DemoGuard 协议位→完整门;arguments `[String:String]`→**自定义** `[String:JSONValue]`）为完整执行链 + 错误枚举。**adopt `mlx-swift-lm` 上游 parser(E1)思想,但本 change 不引真 MLX**——**E1b 解耦(2026-06-19 磊哥拍):本 change = 纯逻辑契约层,用 spike 实采 55 条 fixture 驱动;MLX runtime 接入(锁 format + 消费实时事件)拆出独立 change**。依赖 change2 `capabilities.yaml`/`agents.yaml`（demo_guard 规则 / 范围枚举 / 字段反查源）。pre-mortem 全料见 `docs/execution-pre-mortem-2026-06-18.md` + 主体实装 catch 见 design Risks **T6/T7/T8/T9** + E1a/E1b。**2026-06-19 self-audit 回填 6 catch(C1-C6)见 dispatch §0.6**。

## 0. 前置（spike done + 契约层底座）

- [x] 0.1 spike E3 go/no-go(base Qwen3-1.7B function call)。**✅ done(2026-06-18/19)**:`dev/spike-e3/` 隔离包,55 样本,**GO**(raw trigger 31/40=77.5%,审计调整工具意图 35/40=87.5%)。产出 `dev/spike-e3/Reports/spike-e3-results.json` = **本 change fixture 源**。
- [x] 0.2 **自定义 `JSONValue` enum**(E1b):7-case(null/bool/int/double/string/array/object),Codable+Hashable+Sendable,**不 import MLXLMCommon**。验收:数组/标量/嵌套对象 round-trip 测试过;契约层 grep 无 `import MLXLMCommon`。
- [x] 0.3 **capabilities → Swift codegen(C2:手动脚本,不用 SwiftPM plugin)**:独立脚本(`scripts/gen_capabilities.*`,手动跑)读 `contracts/{capabilities,agents}.yaml` → 生成 Swift 到 `Core/Generated/`(commit 进仓,标 `// GENERATED`),含 demo_guard 规则(risk_level/confirm_policy/writable/range/enum/preconditions)+ tool_schema + execution.state_cell + **三张反查表**(toolName→capabilityID→agentID/surfacePolicy)。**不动 Package.swift**(`contracts/` 在 exclude + plugin 撞红线);**禁运行时 Yams**。验收:与 8 capability/4 agent 逐字段一致;幂等二次跑 0 diff。

## 1. ToolCallFrame 薄层（契约层,E1b/E2/T5/T7）

- [x] 1.1 **[拆出 → MLX runtime 接入 change]** load 后锁 `.json` format(不靠 infer)+ 消费实时 `.toolCall` 事件。**本 change 不做**(避 T8 未验 iOS 集成坑);接入前先最小 iOS 真机冒烟。本 change 仅留 `ToolCallCandidate` 入口契约。
- [x] 1.2 **本 change**:`ToolCallCandidate` → `ToolCallFrame`(薄层 + 二次校验)。候选源 = **spike fixture**。`arguments` 升级**自定义** `[String:JSONValue]` 全类型归一。**C5 字段映射**(fixture 只有 name+args,frame 三必填字段由 codegen 反查表补):`capabilityID`=toolName→capabilities.id;`agentID`=capabilityID→agents.capability_ids 反查;`surfacePolicy`=agents.surface_policy。验收:实采样本 frame 字段齐全;**T5 数组/字符串化JSON/标量归一用合成边界用例**(C4:spike 实采全 flat scalar,标 coincidental-correctness)不被丢弃。
- [x] 1.3 **content-fallback 候选层**(E1a,**C3 可配置开关**):裸单个 `{"name":...,"arguments":...}` → `ToolCallCandidate(source:contentFallback)`,**抄上游 `ToolCallProcessor.processInlineChunk:108-135` brace-count 思路**,不另发明算法、不吞混排文本、不重建 parser。候选**不得直接执行**。**C3 修正**:N016/N017 裸 JSON schema 合法,开启 fallback 时**会过 schema 门执行**(已知 G3 代价 1/15→3/15,非 DemoGuard 挡);验收:9 条正例裸 JSON 可恢复为候选;trace 三口径区分;默认开关 + 净 G3 影响留 change6。
- [x] 1.4 两层 decode 边界:严格 enum/required/类型/范围校验门挂**第②层(`execute()` 前 `decode(Input.self)`)**。验收:enum 校验在第②层触发(非宽松第①层候选解析)。

## 2. 错误枚举 + decode_failed（T3/T4）

- [x] 2.1 自写 `throws` decoder,三态:`no_tool_call` / `malformed` / `schema_invalid`(细分 `unknown_tool`/`missing_field`/`type_mismatch`/`out_of_range`)。验收:三态各有测试,`decode_failed` 可达。
- [x] 2.2 面向模型输出的 enum **手写 `init(from:)`**(未知值落 `unknown`/转 decode_failed);**全链路禁 `try!`/`try?`**(do/catch)。**C8 豁免**:`JSONValue.init(from:)` 自身**类型试探**(顺序尝试各 case)是合法构造,需注释标明,不算违禁(禁令针对业务 decode 路径吞 DecodingError)。验收:未知 enum 值不抛 `dataCorrupted`、不崩。**叠加 code review checklist**。
- [x] 2.3 retry≤1(仅 `malformed`)+ `decode_failed` → 澄清。验收:malformed 重试 1 次后转澄清,无无限重试。

## 3. DemoGuard schema 门（升级 change1,C1 T7 三处 + C3 边界）

- [x] 3.1 实现 R0–R3 **schema 门**(unknown tool/schema/范围枚举/writable/风险等级/确认策略/互斥 bus/前置条件;规则源 = codegen 产物)。**🔴 C1 修 T7 三处**:`Core/Execution/DemoGuard.swift:16-24` + `Core/Execution/DemoActionExecutor.swift:14-22` + `Core/Intent/FastPathIntentEngine.swift:17-22` 全删旧命名(`vehicle.ac.toggle`/`set_vehicle_control`/`state_key`/`target_state`)切 capabilities.yaml 命名;executor 用 `execution.state_cell` 映射。**🔴 C3 DemoGuard 是 schema 门非语义拒识门**:挡不住 schema 合法的 restraint(N016/N017)/意图越界(N002),**别为「guard 拦截 restraint」建测试**(demo_guard 无 restraint 字段)。验收:`Unsafe false pass=0`;unknown/越界/缺字段/非法 enum 均拒;`grep set_vehicle_control|state_key|target_state Core/ Features/` 零命中;断言 `frame.toolName ∈ tool_schema.name 集`。**R0/R1 完整(实际数据);R2/R3 门逻辑 + 合成 fixture 验**(coincidental-correctness)。
- [x] 3.2 `think_leak`:fixture `chunkText` 含 `<think>` → trace 记 + 该轮失败/降级澄清。验收:think 泄漏被捕获不进执行(spike thinkLeak=0,合成 fixture 验门逻辑)。

## 4. trace + 升级 change1 接入

- [x] 4.1 TraceLogger 五段(decode/plan/guard/execute/readback)+ 显式记 `toolCalls.count`/`stopReason` + **分开记 raw `.toolCall` / fallback candidate / guard 后实际执行**(E1a 三口径,供 change6 量化 content-fallback 净 G3)。验收:trace 含五段 + 指标 + 三口径。
- [x] 4.2 升级 change1 `DemoWalkingSkeleton`:单条放行占位 → 接完整契约层(decoder + 完整 DemoGuard + executor + readback),**fixture 驱动,不接真 MLX**。**C1**:`FastPathIntentEngine` 现有硬编码「打开空调」那条**切新命名**(→`set_cabin_ac{power:on}`)保证全链路自洽;完整规则 NLU 扩展归 intent-routing change。验收:change1 闭环测试仍绿 + 新错误枚举/fallback 路径覆盖。

## 5. 验收门

- [x] 5.1 错误枚举三态 + arguments 全类型 + content-fallback fixture 测试(**smoketest 用 spike 实采 ≥55:40 正例全 + 15 负例全含 N002/N016/N017;T5 数组/标量边界用合成豁免**)。**叠加 Superpowers: TDD**。
- [x] 5.2 填实 change1 占位测试(`Unsafe false pass=0` / `readback mismatch=0` / pending 不冒充);全绿。
- [x] 5.3 `openspec validate define-execution-contract` 通过;全链路 grep 无 `try!`/`try?`(JSONValue 类型试探豁免须注释);契约层 grep 无 `import MLXLMCommon`;codegen 幂等无 diff;`git diff Package.swift` 为空。
