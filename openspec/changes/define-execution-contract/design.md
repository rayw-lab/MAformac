## Context

`define-execution-contract` 升级 change1 walking skeleton(`DemoGuard` 协议位占位 → 完整门;`ToolCallFrame.arguments` `[String:String]` → `[String:JSONValue]`)。pre-mortem(`docs/execution-pre-mortem-2026-06-18.md`,oracle **直读 `mlx-swift-lm` 源码**)定了根架构:**adopt 上游 parser**。依赖 change2 `capabilities.yaml`(tool schema / demo_guard 规则 / 范围枚举的事实源)。

**范围(2026-06-19 主体实装 pre-mortem 后磊哥拍,见 Decisions E1b)**:本 change = **纯逻辑契约层**,**不在本 change 引入真 MLX runtime**;用 spike 实采 55 条真实模型输出做 fixture。MLX runtime 接入(锁 format + 消费实时 `.toolCall` 流)**拆出独立 change**。

## Goals / Non-Goals

**Goals:** 执行链行为契约 + 错误枚举三态 + adopt 薄层 + DemoGuard 完整 R0–R3 + enable_thinking=false。
**Non-Goals:** 不自建 `<tool_call>` parser;不实现 LLM 推理(LLMBackend 具体 backend 留 runtime);**不在本 change 接真 MLX runtime / 不消费实时 `.toolCall` 流事件(E1b 拆出,本 change 用 spike fixture 驱动)**;不降级;不做 ReAct stopword 模板。

## Decisions

### 根架构决策 E1:ToolCallFrame = 薄校验层(adopt,非自建)
`mlx-swift-lm` 已有 `ToolCallProcessor` / `JSONToolCallParser` / `ToolCall`(arguments 已是 `[String:JSONValue]`,streaming 出 `.chunk`/`.toolCall`/`.info` 三态事件)。`ToolCallFrame` **站其上**:消费 `.toolCall` 事件 → enum/validator 二次校验 → 内部 frame。**不自建 XML/JSON parser**(自建 = 重造更差的轮子 + 与上游打架)。源码锚点(2026-06-19 scout 实测 pin 3.31.3 修正,见 T6):`JSONToolCallParser` 并入 `Libraries/MLXLMCommon/Tool/ToolCallFormat.swift`;`ToolCallProcessor`/`ToolCall`/`Value.swift(JSONValue)` 同目录独立文件。

### 审计回流决策 E1a:裸 JSON content-fallback = 候选修复,非 parser fork
spike E3 cross-vendor 审计把 G2 拆开:raw `.toolCall` 触发率是 31/40=77.5%,但 9 条 content 伪工具 100% 是裸 JSON(无 `<tool_call>` 标签),其中 7/9 工具名与参数语义可恢复;base 工具意图正确率应按 `28 raw expected hits + 7 recoverable bare JSON = 35/40 = 87.5%` 看。上游 `.json` parser 是 **tagged** 格式(`ToolCallFormat.swift:108` `JSONToolCallParser(startTag:"<tool_call>")`),stream processor 对 tagged format 走 `processTaggedChunk`——裸 JSON 不含 `<` 直接漏成 `.chunk`(`ToolCallProcessor.swift:180`);上游 bare-JSON brace-count(`processInlineChunk:108-135`)**仅在 inline format(startTag==nil)激活**,本路径没走它,故 E1a 与上游不重叠(见 paper-tiger)。所以这是**格式通道问题 > 意图问题**。

落法:只加**窄 content-fallback 候选层**,**抄上游 `ToolCallProcessor.processInlineChunk:108-135` 的 brace-count 思路**(不另发明算法,防 coincidental correctness)。当 `.chunk`/fixture 文本是单个裸 `{"name": "...", "arguments": {...}}` 形态时,正则/JSON decode 只产 `ToolCallCandidate(source: contentFallback, rawContent: ...)`;它**不得直接执行**,也不得重建 `<tool_call>` parser 或吞其它混排文本。候选必须进入同一第②层 `decode(Input.self)` 严格校验,再进 DemoGuard(R0–R3,含 restraint allowlist/deny rule),全部通过后才变成可执行 `ToolCallFrame`。

为什么不能裸接:spike 负例里也出现 2 条裸 JSON(N016 `不要开空调`→`set_cabin_ac{power:off}`;N017 `已经26度了,不要再调`→`query_cabin_comfort{topic}`)。裸接直接执行必误执行。

**🔴 边界澄清(2026-06-19 self-audit catch,修正原 G3 论证)**:DemoGuard 是 **schema/range/risk/writable/互斥/前置条件 安全门**,**不是语义拒识门**。N016/N017 的裸 JSON 是 **schema 合法**的(`power:off`∈enum、`topic` 合法),DemoGuard 会**放行**——schema 门挡不住「合法调用但用户否定意图(restraint)」。同理 N002(写诗→真 `.toolCall` `set_cabin_fan{level:2}`)是意图越界、schema 合法、DemoGuard 放行。故**原「候选过 DemoGuard 则 negative 被挡、G3 不恶化」的论证不成立**:content-fallback 把 N016/N017 从 raw 未触发变成候选→过 schema 门→执行,G3 会从 1/15 升到最多 3/15(spike report 早已预警,且 capabilities.yaml `demo_guard` 无 restraint allowlist 字段,change3 无规则源做语义拒识)。

**真防线分层**:restraint / 意图越界拒识 = **intent-routing 拒识层(规则 NLU + 慢思考)+ LoRA 负样本 + base 模型**(spike G3 测的就是 base 拒识),**不是 change3 DemoGuard**。change3 对这类的诚实契约:**不崩 + 读回真 mock 态(不冒充成功)+ trace 三口径如实记(raw `.toolCall` / fallback candidate / guard 后实际执行)**,让误执行**可观测**,供 change6 benchmark 量化净影响 + intent-routing 改进。**content-fallback 实装为可配置开关**,默认行为 + 净 G3 影响留 change6 实测拍。

指标口径必须分开:
- **raw trigger**:只统计上游 `.toolCall` 事件,本次 31/40=77.5%。
- **fallback candidate trigger**:`.toolCall` + 裸 JSON candidate,positive 可接近 40/40,但仍只是候选。
- **expected tool intent hit**:工具名语义正确率,本次 35/40=87.5%。
- **G3 false execution**:只统计 guard 后实际会执行的误调;fallback 必须在 DemoGuard 前置下不恶化。

生死线裁决:GO。base 1.7B 意图够用,缺的是稳定 `<tool_call>` 包裹;change3 继续做 guard-first 的薄 fallback,change5 再用 LoRA 修格式稳定性。

### 范围解耦决策 E1b(2026-06-19 主体实装 pre-mortem 后磊哥拍):契约层 ⊥ MLX runtime 接入
主体实装 pre-mortem catch:原 tasks 1.1/1.2(load 后锁 format + 消费实时 `.toolCall` 事件)会把 MLX 拽进 iOS App target,撞整套**未验** iOS 集成坑——metallib 在 iOS App 必须 Xcode bundle([jan#8046](https://github.com/janhq/jan/issues/8046))、**MLX 在 iOS Simulator 必崩**(Metal 不支持现代 GPUFamily,[mlx#2605](https://github.com/ml-explore/mlx/issues/2605))、jetsam OOM 需 `Increased Memory Limit` entitlement([#770868](https://developer.apple.com/forums/thread/770868))——且契约层单测无法在 Simulator 跑。

**拆分**:
- **本 change(纯逻辑契约层)**:content-fallback 候选 → 两层 decode → 错误枚举三态 → DemoGuard → mock executor → readback → trace。**不引入真 MLX**;用 **spike 实采 55 条真实模型输出**(`dev/spike-e3/Reports/spike-e3-results.json` 的 `chunkText`/`toolCalls`)做 fixture(符合「smoketest 实采真实数据,非 mock / 非 LLM 自造」)。
- **拆出(独立 change / runtime 接入)**:MLX runtime 接入(锁 `.json` format + 消费实时 `.toolCall` 流式事件)。接入前先跑**最小 iOS 真机冒烟**(空壳 App + MLXLLM 真机加载 1.7B 跑一次 + 读回,一次性证伪 metallib/entitlement/签名)。

**arguments 用自定义 `JSONValue`(改 E5 原 typealias 决策)**:契约层定义自己的 7-case `JSONValue` enum(null/bool/int/double/string/array/object,Codable+Hashable+Sendable),**不 `import MLXLMCommon`** → Core 不绑 Metal 栈、不被 Simulator 崩传染、不 pin 死上游内部类型(解 honnibal #10 version-coupled)。代价:未来 MLX runtime 接入 change 加一层 `上游 ToolCall([String:JSONValue上游]) → ToolCallFrame([String:JSONValue本地])` 映射(~一个 switch 7-case,机械;上游 `ToolCall.swift:19` 已有 `arguments:[String:any Sendable]` 便利 init,映射成本低)。

### 两层 decode 边界 E2(validator 门挂对层)
- **第①层(宽松,候选解析)**:fixture/裸 JSON content-fallback 解成 `[String:JSONValue]`,只校验 name + 结构。
- **第②层(`execute()` 前 `decode(Input.self)`,严格)**:enum / required / 类型 / 范围校验 = **`decode_failed` 错误枚举的产出处**。validator 门**必须挂第②层**(挂第①层 enum 校验根本不触发)。

### 升级后执行链(强制明确)
```
ToolCall 候选(本 change:来自 spike 实采 fixture;runtime 接入 change:来自 mlx-swift-lm `.toolCall` 事件,锁 format=.json,不靠 infer())
  or 裸 JSON content-fallback → ToolCallCandidate(source=contentFallback;抄上游 ToolCallProcessor.processInlineChunk:108-135 brace-count 思路)
 → ToolCallFrame(薄层:第②层 decode(Input.self) 严格校验;fallback 只是候选)
 → 错误枚举三态:ok / no_tool_call / malformed / schema_invalid(unknown_tool|missing_field|type_mismatch|out_of_range)
 → retry≤1(仅 malformed)/ decode_failed → 澄清
 → DemoGuard 完整门 R0–R3(规则源 = capabilities.yaml.demo_guard)
 → DemoActionExecutor.applyMockTransition(唯一写入口)
 → DemoVehicleStateStore → readback(读回 actualValue 才算成功)
 → TraceLogger 五段 + 显式记 toolCalls.count / stopReason(T2 指纹)
```
**安全铁律**:DemoGuard 是代码门;模型只产候选;`pending/failed/unknown` 不播「已完成」。

### 关键决策表
| 决策 | 选 | 不选(原因) |
|---|---|---|
| parser | **adopt mlx-swift-lm 上游**(runtime 接入 change) | 自建(重造更差 + 打架) |
| content fallback | 裸 JSON 只产候选,过第②层 decode + DemoGuard(**schema 门**)才执行;**可配置开关**,restraint 净影响留 change6(T9) | 裸接 JSON / 重建 `<tool_call>` parser(放大误执行 + 违 adopt 薄层) |
| format | 显式锁 `.json`(runtime 接入 change) | `infer()`(model_type 失配 → tool call 静默漏进文本) |
| 错误 | `throws` decoder 三态枚举 | `parse()->nil`(无区分信号,decode_failed 不可达) |
| enum | 手写 `init(from:)` + `unknown` | 默认合成(未知值抛 `dataCorrupted`) |
| try | `do/catch` + 错误枚举 | `try!`(崩,违「不崩」)/ `try?`(吞 DecodingError) |
| arguments | **自定义** `[String:JSONValue]` 全类型归一(E1b,不 import 上游) | typealias 上游 Value.swift(绑 Metal 栈 / 被 Simulator 崩传染)/ `[String:String]`/`[String:Any]`(丢数组/标量) |
| thinking | `enable_thinking=false`(MUST;本 change fixture 已是 enable_thinking=false 采集) | 开(破坏 tool parser) |
| validator 门 | 第②层 `execute()` 前 | 第①层 parser(enum 校验不触发) |
| 驱动源(本 change) | **spike 实采 55 条 fixture** | mock / LLM 自造 keyword(违 codex §23 smoketest) |

## Risks / Trade-offs(pre-mortem 实证,带来源)

- [T1 上游 parser 与自建职责重叠] → adopt 薄层(本 design AD)。源:`mlx-swift-lm` `ToolCallProcessor.swift` 源码。
- [T2 `infer()` 精确匹配 model_type → tool call 静默漏进 `.chunk` 文本、`stopReason=.stop`] → 显式锁 `.json` + smoketest 断言收 `.toolCall` 事件(runtime 接入 change)。源:[mlx-swift-lm #259](https://github.com/ml-explore/mlx-swift-lm/issues/259) / [mlx-lm #984](https://github.com/ml-explore/mlx-lm/issues/984) / [#1293](https://github.com/ml-explore/mlx-lm/issues/1293)。
- [T3 `parse()` 全失败归一 `nil`,无区分信号] → 自写 `throws` decoder 三态枚举。源:`ToolCallFormat.swift`(JSONToolCallParser `parse()` 内 `try?` 吞 DecodingError)。
- [T4 enum 加 `unknown` 不够,合成 decoder 仍抛 `dataCorrupted`] → 手写 `init(from:)` + 全链路禁 `try!`/`try?`。源:[sarunw decode enums](https://sarunw.com/posts/how-to-decode-enums-ignoring-case-in-swift-codable/) / [Vapor #1736](https://github.com/vapor/vapor/issues/1736)。
- [T5 arguments string-vs-object,上游只救 `[String:Any]`,数组/标量静默丢] → 自己全类型归一。源:[llama.cpp #20198](https://github.com/ggml-org/llama.cpp/issues/20198) / [qwen-code #379](https://github.com/QwenLM/qwen-code/issues/379)/[#783](https://github.com/QwenLM/qwen-code/issues/783)。
- [E3 审计回流:裸 JSON fallback 会同时恢复 positive 和放大 negative] → fallback 只产候选,必须过第②层 decode + DemoGuard/restraint 才执行;trace 分开记 raw `.toolCall`、fallback candidate、guard 后实际执行。源:`dev/spike-e3/Reports/spike-e3-results.json` cross-vendor 审计。
- **[T6 源码锚点失效(2026-06-19 scout 实测 pin 3.31.3)]** → execution-pre-mortem + 旧 design 引的 `JSONToolCallParser.swift` **文件不存在**。**实测锚点**:`JSONToolCallParser` 并入 `Tool/ToolCallFormat.swift`(`.json` = `JSONToolCallParser(startTag:"<tool_call>",endTag:"</tool_call>")`,**tagged**);`JSONValue` 在 `Tool/Value.swift`;`ToolCall.arguments:[String:JSONValue]` 在 `Tool/ToolCall.swift:12`(便利 init `[String:any Sendable]` 在 `:19`);bare-JSON brace-count 在 `Tool/ToolCallProcessor.swift:108-135`(**仅 inline format 激活**)。
- **[T7 命名漂移 stringly-typed 断裂(HIGH)]** → change1 `DemoFastPathGuard` 硬编码 `agentID=="vehicle-control"`/`capabilityID=="vehicle.ac.toggle"`/`arguments["target_state"]`(`Core/Execution/DemoGuard.swift:16-24`),与 change2 `capabilities.yaml`(`cabin.ac`/`set_cabin_ac`/`power:on|off|unchanged`)**完全对不上**。本 change DemoGuard 规则源 **100% 切 capabilities.yaml**;加 cross-check 测试断言 `frame.toolName ∈ tool_schema.name 集` + enum/range 对齐。
- **[T8 iOS App 接 MLX 全套未验(oracle 实证)]** → 由 E1b 拆分规避:本 change 不引 MLX;runtime 接入 change 接入前先最小 iOS 真机冒烟。源:[mlx#2605](https://github.com/ml-explore/mlx/issues/2605)(Simulator 崩)/[jan#8046](https://github.com/janhq/jan/issues/8046)(metallib 打包)/[#770868](https://developer.apple.com/forums/thread/770868)(内存 entitlement)。
- **[T9 DemoGuard schema 门 ≠ 语义拒识门(2026-06-19 self-audit catch)]** → DemoGuard 挡 schema/range/risk/writable/互斥/前置条件,**挡不住** schema 合法的 restraint(N016/N017)/意图越界(N002);content-fallback 把这类 raw 未触发的裸 JSON 变候选→过 schema 门→执行,有已知 G3 代价(1/15→最多 3/15);真防线 = intent-routing 拒识 + LoRA 负样本(**非 change3 DemoGuard**,capabilities.yaml demo_guard 无 restraint 字段);change3 保证 trace 三口径可观测 + 不崩 + 读回真态,净影响留 change6 量化;**content-fallback 设可配置开关**。源:`dev/spike-e3/Reports/spike-e3-results.json` N002(真 toolCall 误触发)/N016/N017(裸 JSON restraint)+ `contracts/capabilities.yaml` demo_guard 无 restraint allowlist。
- [P2 mlx-swift-lm 3.x breaking] → `Package.swift` pin exact tag,升级走 change(runtime 接入 change);本 change 自定义 JSONValue **不依赖上游 tag**(解耦红利)。
- [change1 占位漂移对齐] → visualState 枚举 + store cell 集已在 change2 对齐(2026-06-18);arguments `[String:String]`→**自定义** `[String:JSONValue]`(E1b 改 typealias 决策:契约层不 import MLXLMCommon,避 Metal 栈 + Simulator 崩传染 + version-coupling;自定义 enum 镜像上游形态 null/bool/int/double/string/array/object,Codable+Hashable+Sendable)。

## Migration Plan

升级 change1 产物:`DemoGuard` 协议位 → 完整 R0–R3 门(规则源切 capabilities.yaml,修 T7 命名漂移);`ToolCallFrame.arguments` `[String:String]` → **自定义** `[String:JSONValue]`;新增错误枚举 + 两层 decode + content-fallback 候选层。本 change 不动 `Package.swift`(不引 MLX)。回滚 git revert。

## Open Questions

- content-fallback guard 后的真实 false execution rate 需在 change6 正式 benchmark 扩负例验证;当前 15 负例偏少。
- `decode_failed` / guard deny 的澄清话术(→ voice / capability change)。
- **DemoGuard R2/R3**:capabilities.yaml 8 capability 只用 **R0/R1**(空调/座椅/氛围灯/屏幕/风量/查询=R0,车窗=R1);R2/R3 门逻辑实装但用**合成 fixture** 验(无实际数据,标注 coincidental-correctness 风险)。
- **capabilities.yaml(YAML)→ Swift 消费**:推荐 **build-time codegen 成 Swift**(CLAUDE.md「capabilities.yaml 是源,其余生成物」),非运行时 Yams 解析(避 iOS bundle 放 YAML + 运行时解析失败面)。
- **MLX runtime 接入 change** 的拆分粒度(独立 change vs 并入 voice change 的 runtime 段)+ 最小 iOS 真机冒烟的归属(依赖磊哥 Apple Developer 账号配置)。
