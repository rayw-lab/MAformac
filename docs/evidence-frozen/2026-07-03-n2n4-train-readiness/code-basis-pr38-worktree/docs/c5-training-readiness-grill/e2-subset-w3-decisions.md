---
artifact_kind: e2_subset_grill_worker_3_same_surface_decisions
worker: W3-same-surface-gate
scope: D5 grammar_digest + D7 training_distribution_isomorphism + D8 eval_surface_extension
id_range: S-201~260
status: ratified_locked_with_conditions（D-019）
created: 2026-07-02
proof_class: local_static + local_catalog_stats + web_research
non_claims: no_training_no_generation_no_cloud_llm_no_commit
---

# E-2 subset W3 同源门官决策矩阵

本稿只回答 D5/D7/D8 的 10 个子点；D-019 已 ratified locked_with_conditions。已承接：E-lite 方向、8K 预算、gate3 六轴同源、L1 规则快路不碰模型、Phase-1 只做 construction（manifest/codegen/训练与 C6 侧同源/digest receipt），不做 runtime 预路由实装。

核心判断：subset 的风险不是少挂工具，而是多造一套面。W3 的所有结论都服务一个物理不变量：

```text
train_target_tools ⊆ train_prompt_tools
train_prompt_tools_digest == c6_mounted_tools_digest == runtime_prompt_tools_digest == grammar_allowed_tools_digest
model_actual_tool_or_NO_TOOL ∈ grammar_allowed_set
```

## P1-P9 防惨败映射

| 代号 | 含义 |
|---|---|
| P1 | tool surface 单源派生，训练/C6/runtime/grammar 不手写第二套 |
| P2 | metadata 不是 enforce；需要物理删/物理挂/物理校验 |
| P3 | label conflict 用实际 prompt/tools/label 检，不信 metadata |
| P4 | Qwen tool-call 渲染保持 name-first，不让 grammar/schema 改出 name-last |
| P5 | NO_TOOL 与 empty collapse 分开；no-call 不能靠空输出假绿 |
| P6 | surface + scorer consistency 进机械门 |
| P7 | 审计必须一手复算/实跑，不信 receipt 聚合 |
| P8 | 重大训练/评测前先 grill frame，反例改变结论就改判 |
| P9 | 成功标准先定义，action/no-call/refusal/readback 分轴 |

## 一手证据摘要

### 本机代码与统计

- `mlx-swift-structured` 的 Qwen3 tool-calling grammar 用 `TriggeredTagsFormat` 触发 `<tool_call>`，每个工具包一层 `TagFormat`，arguments 走 `JSONSchemaFormat(schema: tool.parameters)`：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/mlx-swift-structured/README.md:93-108`。
- 该 grammar 可直接传给 `generate(..., grammar:)`：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/mlx-swift-structured/README.md:113-120`。
- `GrammarMaskedLogitProcessor` 每步从 `grammarMatcher.nextTokenMask()` 得 mask 后加到 logits；这说明 grammar 是逐 token 输出约束，不是 prompt 压缩：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/mlx-swift-structured/Sources/MLXStructured/GrammarMaskedLogitProcessor.swift:25-45`。
- grammar compiler 按 tokenizer 构造，compiler 按 `ModelConfiguration` 缓存，但每个 grammar 仍会 `compiler.compile(grammar:)` 后建 matcher：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/mlx-swift-structured/Sources/MLXStructured/GrammarMatcherFactory.swift:13-31`，`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/mlx-swift-structured/Sources/MLXStructured/GrammarCompiler.swift:84-120`。
- README 自带性能表：Qwen3 4B constrained 约 6.0% slower，Qwen3 14B 约 3.0% slower；复杂 grammar 预计不超过约 10% 慢：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/mlx-swift-structured/README.md:180-191`。
- C5 当前 D-domain catalog 从 `generated/D_domain.tools.demo.json` 读取，`DDomainToolEntry` 已带 `_domain` 与 `_sg`，用于同族/同设备 distractor：`/Users/wanglei/workspace/MAformac/Core/Contracts/ToolContractCompiler.swift:27-30`，`/Users/wanglei/workspace/MAformac/Core/Contracts/ToolContractCompiler.swift:100-110`。
- 本机只读统计：当前 `generated/D_domain.tools.demo.json` = 562 tools / 10 family / 191 `_sg`；family 分布为 seat 126、light 113、screen 75、ac 68、door 48、volume 32、sunroof 30、wiper 27、window 27、fragrance 16；`_sg` 单组最小 1、最大 10。
- 当前训练 renderer 的 same-family distractor 已按 `_sg` 优先、再 `_domain`、再其他，默认 K=3：`/Users/wanglei/workspace/MAformac/Core/Training/C5LoRATraining.swift:2177-2201`；D-domain positive prompt 当前是目标工具 + distractors：`/Users/wanglei/workspace/MAformac/Core/Training/C5LoRATraining.swift:2667-2673`。
- C6 case 现有字段覆盖 source/tags/input/expected/no-call/state/readback/clarify/failure/behavior，但没有 subset/mounted/grammar digest：`/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift:158-186`。
- C6 eval run 现有 prompt/toolOutput/contract/bundle digest，但没有 mounted/grammar digest：`/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift:683-735`。
- C6 现有四层 selector 为 golden/demo_fuzz/unsupported/safety：`/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift:292-311`；behavior class 能区分 tool/refusal/clarify/safety/noop：`/Users/wanglei/workspace/MAformac/Core/Contracts/VehicleToolBehaviorClass.swift:3-10`。

### 联网搜证（抓取日 2026-07-02）

| ID | 来源 | URL | 日期 | 对本轮的作用 |
|---|---|---|---|---|
| W3-WEB-01 | XGrammar technical report | https://arxiv.org/abs/2411.15100 | 2024-11-22 | CFG constrained decoding 有运行时开销，XGrammar 通过预检/栈优化降低 overhead，支持 grammar 作为性能可控输出门。 |
| W3-WEB-02 | XGrammar GitHub | https://github.com/mlc-ai/xgrammar | 2024-11 release；抓取 2026-07-02 | XGrammar 支持 JSON/regex/custom CFG，强调 structural correctness；支撑 grammar 只保证形状，不保证语义选对。 |
| W3-WEB-03 | MLC XGrammar blog | https://blog.mlc.ai/2024/11/22/achieving-efficient-flexible-portable-structured-generation-with-xgrammar | 2024-11-22 | masking logits overhead 和 TPOT 需要被当作预算项，不应 runtime 动态编译复杂 grammar。 |
| W3-WEB-04 | vLLM structured outputs docs | https://docs.vllm.ai/en/latest/features/structured_outputs/ | 抓取 2026-07-02 | vLLM structured outputs 支持 xgrammar/guidance backend；支撑“structured output 是输出门，不是 prompt 面压缩”。 |
| W3-WEB-05 | Less-is-More edge function calling | https://www.engr.siu.edu/staff/iraklis.anagnostopoulos/files/papers/Less_is_More_Optimizing_Function_Calling_for_LLM_Execution_on_Edge_Devices.pdf | arXiv 2024-11-23 | 论文直接说明减少可见工具数可提高正确率、降低延迟和功耗，支撑 subset 是必要而非装饰。 |
| W3-WEB-06 | Google Gemini function calling docs | https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/tools/function-calling | 抓取 2026-07-02 | 官方建议只给上下文相关工具，active set 最好 10-20；支撑 device-group/scene subset 而非全量。 |
| W3-WEB-07 | llama.cpp GBNF guide | https://github.com/ggml-org/llama.cpp/blob/master/grammars/README.md | 抓取 2026-07-02 | GBNF 是约束输出格式的 formal grammar；支撑本地/端侧 grammar 实践可行，但仍是输出约束。 |
| W3-WEB-08 | JSONSchemaBench | https://arxiv.org/html/2501.10868v1 | 2025-01-18 | 结构化输出应按 efficiency/coverage/quality 三维评估；支撑 W3 把 grammar latency、schema coverage、semantic quality 分账。 |
| W3-WEB-09 | Meta-Tool / Meta-Bench | https://aclanthology.org/2025.acl-long.1481.pdf | ACL 2025 | open-world function calling benchmark 包含 7,361 tools，并区分 tool selection accuracy 与 parameter accuracy；支撑 tool-count 与选择正确率分轴。 |
| W3-WEB-10 | BFCL PMLR | https://proceedings.mlr.press/v267/patil25a.html | ICML 2025-07-13~19 | BFCL 使用 AST evaluation，可扩到 thousands of functions；支撑 C6 不应只看 name-only。 |
| W3-WEB-11 | How Many Tools Should an LLM Agent See? | https://arxiv.org/html/2605.24660v1 | 2026-05 | 直接把“给模型看多少工具”作为评价对象；列出工具注册表 20~3251，支撑 D7 需要 tool-count distribution gate。 |
| W3-WEB-12 | Benchmarking Function Calling in LLMs | https://liu.diva-portal.org/smash/get/diva2%3A2072520/FULLTEXT01.pdf | 2026 | 把 tool selection、format validity、argument correctness、strict success 分开，并按 toolset size 分析退化；支撑 C6 subset 字段必须进 per-case/per-run。 |

## 决策矩阵

| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line 或 URL+日期) | 状态 | 🔴防惨败列 cite P1-P9 |
|---|---|---|---|---|---|---|
| S-201 | 5a digest 到底 hash 什么 | A 只 hash tool name set；B hash mounted prompt 文本；C hash canonical manifest entry：`subset_policy_id/group_id/mount_mode/tool_ids_ordered/tool_schema_digest/no_tool_outlet_digest/qwen_format_version/tokenizer_id/grammar_builder_version` | ⭐C | prompt tools 由 D-domain catalog 渲染，schema 来 `dDomainToolSchemas`：`Core/Contracts/ToolContractCompiler.swift:49-68`；grammar 用 tool.name + schema 约束 arguments：`mlx-swift-structured/README.md:100-104`。XGrammar/JSONSchemaBench 都说明结构约束与 schema coverage 有实际差异（W3-WEB-01/W3-WEB-08）。 | locked_with_conditions | 防只比 name 漏掉 schema drift；P1 单源、P6 consistency、P7 一手复算。 |
| S-202 | 5b grammar 生成时点 | A runtime 每次按当前候选动态编译；B 只有 compiler cache，grammar 仍 runtime 动态；C manifest build 时 per group/macro 静态生成 grammar artifact，runtime 只按 digest 取缓存，缺失即 fail | ⭐C | `GrammarMatcherFactory.from` 只缓存 compiler，仍对 grammar 调 `compile` 并建 matcher：`mlx-swift-structured/Sources/MLXStructured/GrammarMatcherFactory.swift:13-31`；compiler 支持多线程/cache 但 compile 是显式动作：`GrammarCompiler.swift:32-37`, `GrammarCompiler.swift:84-120`；复杂 grammar 有 3~10% slowdown：`README.md:180-191`。 | locked_with_conditions | 防 runtime 动态裁剪/动态 grammar 让训练面与运行面漂移；P1/P2/P6。 |
| S-203 | 5c digest 失配 fail 形状 | A 降级无 grammar 继续跑；B warning + 日志；C hard refusal：不调用模型或不解析工具，返回 `subset_digest_mismatch` infra/refusal receipt，要求重建/重载 manifest | ⭐C | grammar processor 是逐 token mask，不是可有可无的后处理：`GrammarMaskedLogitProcessor.swift:25-45`；E-lite seed 已锁 runtime prompt 与 grammar allowed 同 digest，任一失配 BLOCKED：`docs/e2-subset-design-package-2026-07-02.md:43`。 | locked_with_conditions | 防“降级无 grammar”制造第二 surface；P6 consistency、P7 不信 receipt、P9 成功标准分层。 |
| S-204 | 5d NO_TOOL grammar 出口 | A grammar 只允许真实工具；B 允许自由文本拒识；C grammar 内加入虚拟非执行出口 `NO_TOOL`，schema 为 `{reason: group_out_of_mount|mvp_unsupported|global_unsupported|safety_or_policy|need_clarify}`，parser 映射为 `toolCalls=[]` + behavior/failure reason，不进入 DemoGuard | ⭐C | README 明确 `TriggeredTagsFormat(... .atLeastOne ...)` 会至少生成一个 `<tool_call>`：`mlx-swift-structured/README.md:100`；C6 现有 no-call/refusal 通过 `expectedToolCalls=[]`、`expectNoCall`、behaviorClass 表达：`Core/Bench/C6VehicleToolBench.swift:158-186`；F-005 已指出 empty=hit 会虚高，本场景的对偶是“想拒绝但 grammar 逼着输出工具”：`docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md:23`。 | locked_with_conditions | 🔴核心防线：防 grammar 强制幻觉工具；P5 NO_TOOL≠empty、P6 scorer consistency、P9 no-call/refusal 成功标准。 |
| S-205 | 5e think span × grammar | A 允许 runtime 自由 think/no-think；B grammar 永远包 `<think>`；C Phase-1 digest 显式记录 `thinking_mode=no_think|think_optional`，默认 no_think；若启用 think，grammar 的 optional `<think>` 与训练/eval/runtime 三处同源 | ⭐C | Qwen3 grammar 示例在 `forceThinking` 时先包 `<think>` 再进入 tool_call trigger：`mlx-swift-structured/README.md:93-100`；C5 已有 think/no-think surface 分叉风险作为 F-047：`docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md:76`。 | locked_with_conditions | 防 think/no-think 成第七轴 surface drift；P6 consistency、P8 frame 纪律。 |
| S-206 | 7a 训练面统计同构 | A 只保证目标工具在 prompt；B 只记录平均工具数；C 对 train/C6/runtime 都记录 `mounted_tool_count/mounted_token_count/subset_group_id/subset_policy_digest`，按 bins 与 family/_sg 计算分布差异，超阈值 BLOCKED | ⭐C | 当前 catalog 本机统计 = 562 tools / 191 `_sg` / `_sg` 最大 10；训练 renderer 当前 positive prompt 是目标 + 3 distractors：`Core/Training/C5LoRATraining.swift:2667-2673`，而 runtime group 可能 1~10；外部研究直接把 visible tool count 作为影响准确率的变量（W3-WEB-05/W3-WEB-11/W3-WEB-12）。 | locked_with_conditions | 防 train 总见 4 个工具、runtime 挂 10/40 个工具造成 count distribution shift；P1/P6/P7/P8。 |
| S-207 | 7b distractor 采样 × group | A 继续随机全局 distractor；B 只同 family；C manifest 固化 `same_sg_then_same_domain_then_other,k=3`，top-2/宏样本另记 `distractor_pool_group_ids`，C6 与训练复用同一 policy digest | ⭐C | 当前 sameFamilyDistractors 已按 `_sg`→`_domain`→其他排序，默认 count=3：`Core/Training/C5LoRATraining.swift:2177-2201`；data quality gate 的 duplicate key 已把 distractors 纳入冲突上下文：`Core/Training/C5LoRATraining.swift:663-667`。 | locked_with_conditions | 防错域 distractor 反噬或 metadata 声称同源；P3 conflict、P6 surface consistency、P8 反例收窄。 |
| S-208 | 8a C6 case schema 加 subset 字段 | A 把 subset 字段塞进 tags.sampleKind；B 只在 eval run 记录；C add-only 新增 `C6SubsetContext` 到 case 和 eval run：`subset_policy_id/subset_group_id/mount_mode/mounted_tool_ids_digest/grammar_allowed_digest/no_tool_outlet_digest/expected_in_mounted/grammar_contains_expected_or_no_tool` | ⭐C | C6BenchCase 现有字段没有 subset/mounted/grammar digest：`Core/Bench/C6VehicleToolBench.swift:158-186`；C6EvalRun 已有 prompt/toolOutput/contract/bundle digest，可 add-only 承接 mounted/grammar digest：`Core/Bench/C6VehicleToolBench.swift:683-735`。 | locked_with_conditions | 防 C6 expected 仍在全量面上验，runtime 实际挂载另一个面；P1/P6/P7/P9。 |
| S-209 | 8b 四层语义受 subset 影响 | A 沿用 golden/demo_fuzz/unsupported/safety 不加子语义；B subset 失败都算 infra；C 四层不变，但 gate_result 增 `subset_failure_class`: missing_expected_in_mounted / actual_not_in_allowed / no_tool_outlet_missing / group_out_of_mount_refusal / digest_mismatch | ⭐C | C6 四层 selector 已存在：`Core/Bench/C6VehicleToolBench.swift:292-311`；evaluate 已分 tool/state/readback/clarify/refusal failure classes：`Core/Bench/C6VehicleToolBench.swift:1305-1385`。subset 不应重写四层，只应增加 orthogonal failure axis。 | locked_with_conditions | 防把漏挂错算成模型语义失败，或把模型误吸错算成 subset infra；P6 scorer consistency、P7 axis 下钻、P9 成功标准。 |
| S-210 | 8c 三层“不支持”分层 | A 全部 `refusal_no_available_tool`；B 全部尝试重路由；C 明确三层：`group_out_of_mount`（10族内但当前 group 未挂，允许重载/澄清，不算全球 unsupported）、`mvp_unsupported`（10族外但车控全集内，拒识并可引导）、`global_unsupported`（非车控/全集外，直接拒识）；safety 仍独立 | ⭐C | VehicleToolBehaviorClass 只有 refusal/noop/safety/clarify/tool，无法表达 subset 语境差异：`Core/Contracts/VehicleToolBehaviorClass.swift:3-10`；C6 unsupported 当前由 `refusalNoAvailableTool` 进 unsupported 层：`Core/Bench/C6VehicleToolBench.swift:299-305`。Google docs 也建议大工具集动态选择上下文相关工具，不是把未挂工具都当能力不存在（W3-WEB-06）。 | locked_with_conditions | 防 group 外但族内被错拒成“我不会”，也防 10族外被 grammar 逼成工具调用；P5/P6/P8/P9。 |

## C6 add-only schema 草案

不建议改写现有 C6 scorer；先 add-only，引入 subset 轴：

```swift
public struct C6SubsetContext: Codable, Equatable, Sendable {
    public var subsetPolicyID: String                 // "e2-lite-v1"
    public var subsetPolicyDigest: String             // canonical manifest digest
    public var subsetGroupID: String                  // e.g. "ac_temperature" / "scene_act_1"
    public var mountMode: String                      // group | top2 | scene_macro | rule_bypass
    public var mountedToolIDsDigest: String
    public var grammarAllowedDigest: String
    public var noToolOutletDigest: String
    public var expectedInMounted: Bool
    public var grammarContainsExpectedOrNoTool: Bool
    public var unsupportedScope: String?              // group_out_of_mount | mvp_unsupported | global_unsupported
}
```

落点：

- `C6BenchCase.subsetContext: C6SubsetContext?`：case 期望在什么挂载面下测。
- `C6EvalRun.subsetContext: C6SubsetContext?`：实际运行面回填，必须与 case 期望 digest 对齐。
- `C6GateResult.subsetFailureClasses: [String]`：不污染现有 `failureClasses`，但 release gate 可单列 fail-closed。
- `C6Summary.subsetDistributionStats`：按 mounted count/token/family/group 输出 train-vs-C6-vs-runtime 对比。

## 消减与 landing

| 维度 | 输入子点 | 消减后决策 | D-019 locked | landing |
|---|---:|---:|---|---|
| D5 grammar digest | 5 | 5 | S-204 `NO_TOOL` 虚拟出口是否按本稿形态拍板 | subset manifest + grammar artifact + parser mapping + digest preflight/runtime assert |
| D7 训练面统计同构 | 2 | 2 | S-206 分布差异阈值后续由 implementation plan 定量 | training sample metadata + C6/eval run subset stats |
| D8 评测面扩展 | 3 | 3 | S-210 三层 unsupported 话术/期望行为是否进入 C6 schema | `C6SubsetContext` add-only + subset failure axis |

## 残余风险

- 本稿不实现 runtime 预路由，不证明端侧 `mlx-swift-structured` 已集成到 MAformac runtime；只给 construction 形态。
- 本稿未跑 tokenizer 组合矩阵；D7 只使用 L4 已实算总量与本轮 catalog 统计，具体 group token 阈值应由 W1/W2 或 implementation worker 逐组实算。
- `NO_TOOL` 虚拟出口需要 parser 明确不进入 DemoGuard，否则会把 refusal 伪装成工具调用，这是 S-204 的实现硬门。
- grammar 性能数字来自 raw repo README 与外部论文/文档，端侧 M 系列真实延迟仍需 future runtime spike，不能据此声称 V-PASS。
