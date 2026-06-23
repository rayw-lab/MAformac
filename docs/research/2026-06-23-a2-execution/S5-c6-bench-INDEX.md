# S5 C6 bench expected 迁 D-domain — 综合官 + 主线程亲核 + 决策 + 一手档 INDEX

> 2026-06-23 · S5 执行线 ultracode workflow（6 finder + 综合官，7 agent / 1.26M tok / 1115s）+ 主线程亲核坐实 + 决策。
> 实现 SSOT = 综合官 README（仓外 `README-synth-spec.md`）；本文 = 亲核结论 + 决策 + 实现 6 cut + A2 边界 + DEFERRED + 指针。

## 1. 综合官决策 ⭐hybrid（主线程亲核站后者，解 finder 内部分歧）
finder 内部分歧：lens1(scoring-path) 推 IR-normalize matcher(B)；其余 4 finder + 综合官一致判 **matcher 不改（surface-string）+ irMap 只线穿 state applier**。主线程亲核站 **⭐hybrid**：
- **matcher 保持 surface-string**（C6VehicleToolBench.swift:1140 canonical name+sorted-args exact，0 改）：A2 demo 只有 D-domain 一个 model-visible surface（frame 已 paradigm-amend 否决），迁后 expected 与 base actual 都是 D-domain → exact 直接成立。
- **防 0/34 = C5/C6 同源 renderer parity 硬门**（非改 matcher）：0/34 根因是 train/eval 不同源，不是 matcher brittle。IR-normalize matcher(B) = 超 A2 code-only 边界的新设计 + 把判据推到 normalize 输出引入 normalize lottery（134/562 multi-primitive 靠 arg-value 启发式消歧）→ 否决。
- **irMap 只线穿 state applier**（IR 层，唯一需 IR 处）。

## 2. 主线程亲核坐实（独立 cite-verify，ultracode 纪律）
- **BLOCKER 1**：`C6MockStateApplier.apply`(:1155-1163) 委托 `ToolContractStateApplier.apply` 但**默认 irMap=[:]** → D-domain 名落 normalize default(:193)→logUnclassified→[]→stateDelta 全塌 ✓（S2 已建 apply(irMap:):381 接收端）
- **BLOCKER 3（parity 命门）**：`normalizeDDomain`(:201) `slots = arguments.filter{!reserved}`（reserved={name,value,value.type}）→ `{temperature:24}` 进 slots；但 `targetNumber`(:510) 读 `value.direct/offset` + slots[`percent/target_temperature/level`]（旧 set_cabin 键），**不读 temperature/fanSpeed** → 数字丢 ✓。`buildValue`(:235) 只读 `arguments["value"]` ✓
- **BLOCKER 2**：`requiresStateDelta`(:898) `hasPrefix("set_")`，唯一 caller :836（GoldVerifier，不污染 base 评分）✓；set_ 前缀仅 19/562（adjust136/close122/open112/raise50/lower49/switch28/set19）
- **迁移名**：18/19 ∈ 562 catalog ✓，仅 `query_cabin_comfort` MISSING（python 实跑 `generated/D_domain.tools.demo.json`）
- 🔴 **亲核纠综合官 ⭐C（requiresStateDelta 判据）**：综合官 ⭐C=`expectedStateDelta非空` → caller `!requiresStateDelta || !delta.isEmpty` 退化成恒真 = **guard 失效**。**主线程覆盖** = 用 D-domain 译法 `!expectedToolCalls.allSatisfy{name.hasPrefix("query_")}`（非 query=action 必有 delta），保守护语义（claim-vs-reality：亲核覆盖 finder 建议）

## 3. 决策（H4 自驱 + 亲核覆盖；⭐均 A2/范式/catalog 锚定，自驱拍不上抛）
| # | grill 点 | 决策 | 依据 |
|---|---|---|---|
| 1 | scorer 迁移路 | ⭐**hybrid**（surface-string matcher + irMap 线穿 state applier + parity 门）| A2 边界（IR-normalize 超边界 + normalize lottery）|
| 2 | requiresStateDelta 判据 | **`!query_ 前缀`**（非综合官 ⭐C，亲核纠 C 退化 guard）| 保 gold 自检守护 |
| 3 | MP-027 拆法（power+temp）| **单工具** `adjust_ac_temperature_to_number{temperature:24}`（power 靠 cell dependsOn ac.temp_setpoint→ac.power 复现）| 范式 §1「一句话一意图」+ dependsOn 已建 + 现 state expectation 兼容 |
| 4 | MP-028 拆法（color+brightness 跨 device）| **必拆 2 call** `[switch_atmosphere_lamp_color{value:红}, lower_atmosphere_lamp_brightness_little]`| 跨 ambient_color/ambient_brightness 两 device 无 dependsOn 桥（matcher set 比对顺序无关）|
| 5 | value-key 异构修法 | ⭐**A** normalizer `targetNumber/buildValue` 扩读 temperature/fanSpeed（不重生成 catalog）| B=重生成 catalog 连带 S4=越界 |
| 6 | MP-029 query_cabin_comfort | ⭐**B** 移出 mustPass 标 unsupported（expectNoCall 或剔除）| 562 catalog 无对应；query_ac_temperature 丢 topic 语义降级；A=加工具越界 |
| 7 | MP-016/019 window 中间% | ⭐**A** `open_window_to_number{position,value:50%}`| catalog 有 open_window_to_number(value_types[PERCENT,SPOT]) |
| 8 | surface_consistency 纳入 make verify | ⭐**A** 纳入（先改默认 path 指向 demo.json）| 0/34 根因=surface drift 无硬门 + dispatch enforce 强化 |
| 9 | strangler 删除时机 | ⭐**A** 不删（保兼容测，model-visible 全迁=满足「frame 移除」语义）| 与 S4 保留态一致，物理删延 retrain |

## 4. 实现 6 cut（incremental，每组 swift test + make verify 绿）
### Group A — scoring 基础设施（irMap 默认 [:] 向后兼容，先落 + 测）
- **Cut-2 irMap 线穿**：`C6MockStateApplier.apply` 加 `irMap` 参数透传 + `C6BenchRunner` 加 stored irMap 字段（构造注入，仿 stateCells）+ evaluate(:937)/GoldVerifier(:832) 两 caller 传入 + CLI/测试 `loadIRMap(repoRoot:)`(:160 已建)。🔴 fail-closed 加载失败抛 C6InfraError 不 fallback 空 map。`contractDigest`(:1370) 文件列表加 `generated/d_domain_ir_map.json`（防 stale）。
- **Cut-4 value-key 异构**：`targetNumber`(:510) 扩读 `ir.slots["temperature"], ir.slots["fanSpeed"]` + `buildValue`(:235) 扩读 `arguments["temperature"] ?? arguments["fanSpeed"]`（value.type 检测）。NOT 重生成 catalog。
- **Cut-3 requiresStateDelta**(:898)：`hasPrefix("set_")` → `!expectedToolCalls.allSatisfy { $0.name.hasPrefix("query_") }`（亲核纠 ⭐C）。

### Group B — 迁移（核心）
- **Cut-1 迁 CaseSpec 名 + args**（mustPassCases :356-389）：26 带 tool 的 case set_cabin_*→D-domain（迁移表见 §5）+ arg 重映射（position 英→中、color→value 键、数字键→temperature/fanSpeed/value）。MP-029 移 unsupported。MP-028 拆 2 call。NEG/COV/refusal expectNoCall 不动。改完 `C6BenchCLI generate` 重物化 `contracts/c6-bench-cases.jsonl`。
- **Cut-6 测试 sync**：C6VehicleToolBenchTests 含 set_cabin 字面量迁 D-domain；2 个 frame-behavior 测(:140,:164)是 strangler 兼容测**保留**；新增 **C5/C6 同源 parity 测**（同 intent → C5 dDomainToolCallArguments emit keys == C6 expected keys，防换皮）+ D-domain 名经 irMap 的 state parity 测。

### Group C — enforce
- **Cut-5 脚本默认 path**：`surface_consistency.py:18` + `verify_gold.py:23` 默认 `D_domain.tools.json`(6)→`D_domain.tools.demo.json`(562) + make verify 纳入 surface_consistency（决策 8）。

## 5. set_cabin_* → D-domain 迁移表（26 case，主线程已 grep 核 18/19 名 ∈ 562）
（详见综合官 README §迁移表；arg 重映射：position driver→主驾/passenger→副驾/rear_left→左后/rear_right→右后/all→全车；color red→红/blue→蓝 放 value 键；数字 target_temperature→temperature/level→fanSpeed/screen-window percent→value；旧 power/delta 键 DROP=编码进名）

## 6. 🔴🔴 A2 边界铁律（S5，跑 base 验【格式】NOT 评性能）
- base Qwen 无 LoRA hard_fail 是预期诚实锚点，**只验 D-domain expected 可 normalize + gold-replay 自检全绿 + 26 case gate 不抛 C6InfraError + swift test 绿 + make verify 绿**；base 0/N 是格式副产物，**任何性能定性=越界**。
- NOT 跑 C6BenchCLI summarize（旧 base envelope = 评性能）；用 fixture-driven evaluate 验管道。
- surface 改 IR 不变（CaseSpec device×actionPrimitive 字段保持）；irMap 只接线不改 IR 语义（normalizeDDomain/buildValue 语义/resolvePrimitive 不碰，仅 targetNumber/buildValue 读键扩展）。
- C5/C6 同源 = 防 0/34 唯一硬门（parity 单测）。

## 7. DEFERRED（A2 后 retrain-c5/受限解码独立立项）
- 多意图训练样本（MP-027/028 base/lora 都 0 是结构性，C5 单 seed 单 call）→ retrain-c5 补
- car_door 族受限解码白名单（MP-024/025/026 refusal）→ 受限解码 vendor
- strangler（set_cabin_*/tool_call_frame normalize 分支 + frameToolSchema）物理删 → retrain 全迁后
- query 族完整 D-domain 化（query_cabin_comfort 综合查询）→ 后续扩

> **数字源（主线程 python 实跑核实，cite-verify）**：set_ 前缀 19/562、multi-primitive(ir_primitives>1) 134/562、迁移名 18/19 ∈ catalog（query_cabin_comfort MISSING）—— 复现：`python3` 遍历 `generated/D_domain.tools.demo.json`(562) + `generated/d_domain_ir_map.json`。file:line 用 `Core/Bench/C6VehicleToolBench.swift` / `Core/Contracts/ToolContractCompiler.swift` 简写。`0/34` = 历史 C5 PR5 灾难锚（项目既有）。

## 7b. S5 审计线 verdict（2026-06-23, superpowers:code-reviewer 异源对抗审 + 实跑）
**NEEDS-REVISION → 已闭合**（无 P0 BLOCK；配方零碰/名空间 parity/A2 边界 NOT 评性能/irMap fail-closed 全 ✅ 实跑坐实；swift test 144→145/0、verify-gold 57/57、make verify exit 0 实跑绿）。
- **P1-1 已闭合**：C5/C6 值键 parity 原只测 2/3 腿（catalog schema 腿 + C6 jsonl 腿），漏 **C5 emit 侧异构键（temperature/fanSpeed）实产断言**。matcher 是 surface-string 字面键比对 → 漏这腿 = retrain 时 0/N 换皮复发点。**闭合** = 加 `testC5EmitsHeterogeneousValueKeyMatchingC6ForNumberIntents`（C5LoRATrainingTests）：真实 contract slot_keys 坐实 ac_temperature 含 temperature / ac_windspeed 含 fanSpeed（value.type 空，数字走异构槽非 value）→ build surface=.dDomain 实跑断言 emit `temperature`/`fanSpeed` 键、非 `value` 键。**测过 = parity 三腿全坐实**（非声称）。
- **P2-1 已收**：requiresStateDelta 黑名单假设（非 query_=state-mutating）加注释，依赖 562 catalog 当前只读前缀只有 query_；未来加 get_/show_ 须回看（Core/Bench/C6VehicleToolBench.swift:901）。
- **P2-2 已收**：migrate_c6_trap_to_d_domain.py 加幂等守护（jsonl 已含 C6-TRAP- → exit 1 阻断重复 append）。
- paper-tiger（实测安全）：irMap 默认 [:] 向后兼容不致 D-domain 静默假绿（负证测 testGoldReplayFailsWithoutIRMap 主动证 state 塌→fail）。

## 8. 一手档指针（仓外 raw）
`~/workspace/raw/05-Projects/MAformac/research/2026-06-23-a2-s5-c6-bench/`：`w1o909no1.output.json`(最一手) + `transcript-wf_de99753a-a42/`(15 files) + `README-synth-spec.md`(综合官全 spec) + `lens-*.md`(6 finder full_markdown)
