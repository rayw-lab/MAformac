# L04 — C6 四层最终验收门 + base recalibration（pre-propose decision-pack）

> 调研日期 2026-06-24 · 维度：C6 训练后 final gate（不管训练中途，归 L05；边界写死）· 优先级 P0
> 横切纪律：12+ 联网搜证（每条带 source+日期）· 热度交叉验证（gh star+pushedAt）· BFCL clone 一手读 file:line · 本机 c6-summary 实测 · pre-mortem 三分类 · vs rank16Mainline/home-llm baseline · 防编造（精确数字进 external_claims 待主线程核）
> Phase 0 边界：纯搜证+假想验证，**绝不执行训练/真实模型评测/数据生成**；产出供 rebuild-c6 OpenSpec propose 当弹药；治理类落 docs/research 不碰 runtime contracts/

## Summary

C6 四层独立验收门（golden 100%硬门 / demo_fuzz / unsupported / safety 各独立阈值、禁互相冒充）在业界有成熟先例：**ACEBench**（Normal/Special/Agent 三类各报 + Overall）、**When2Call**（4-class abstention + tool hallucination rate）、**BFCL**（AST per-category + Irrelevance）、**τ-bench**（state-based reward + pass^k）。C18「no aggregate pass rate masks any layer」正是 **ABC 论文（arxiv 2507.02825）** 的 Outcome Validity（O.g/O.b）核心纪律——ABC 直接点名 **「TAU-bench counts empty responses as successful」**，这正是 MAformac **0/34 灾难同根**（LoRA 塌缩成 `toolCalls=[]` 碰巧符合 `expect_no_call`/`enc=True` 拿正分）。

**这维度（四层门 + action hard_pass 按 case schema 字段拆分母 + IrrelAcc 负例 ≥20% + readback 走 renderer 不进硬门 + judge 后置不洗白）能直接提前阻止 0/34 = 真 P0。**

**base recalibration（C17）** = A2 迁 D-domain 后旧 generic-frame base 失效（本地实测旧 base：`tcm&sdm=29/57`、`readback=0`、`IrrelAcc=0.739`、model=`mlx-community/Qwen3-1.7B-4bit`、lora=NONE），须在新 D-domain surface 上重测同 harness/dataset/prompt 拿新 base anchor 作 candidate 比较门；旧 10/23 仅 historical（与 BFCL v4 / Scale MCP-Atlas 2026-04 / Meta-Harness「换 harness 须 re-score all models」同理）。held-out 防泄漏（C13，L08 主管检测，L04 评测门只消费其通过证明）按 template/tool-family 切分 + loss-based MIA。

---

## Findings（每条带 source + vs baseline）

### F1 — 四层独立门有成熟先例（ACEBench per-category）
ACEBench 按 **Normal/Special/Agent 三类各报 + Overall**，每类用不同评测方法（Normal=AST 函数+参数 check / Special=error-type matching / Agent=final state+intermediate）。这正是 C18「不合一个 pass_rate」的直接对应。
- **source**：https://aclanthology.org/2025.findings-emnlp.697/ + arxiv 2501.12851（EMNLP Findings 2025；gh ACEBench/ACEBench 187★ pushed 2025-10-29）— 查证 2026-06-24
- **vs baseline**：support C18。better than 单一 pass_rate。MAformac 四层（golden/demo_fuzz/unsupported/safety）= ACEBench 三类的车控特化。

### F2 — When2Call 4-class abstention 直映 unsupported/safety/clarify 层
When2Call（NVIDIA/Harvard, NAACL 2025）用 **4-class（direct answer / tool call / follow-up question / unable-to-answer）+ tool hallucination rate（无工具时 lower better）+ Macro-F1**，专测「when NOT to call」。
- **source**：arxiv 2504.18851 + https://aclanthology.org/2025.naacl-long.174.pdf + hf nvidia/When2Call（3652 MCQ + 300 LLM-judge；gh NVIDIA/When2Call 64★ pushed 2025-04-29 CC-BY-4.0）— 查证 2026-06-24
- **vs baseline**：support。better than home-llm（home-llm 有 refusal 样本但无独立 abstention F1 门）。MAformac IrrelAcc/expect_no_call = When2Call hallucination-rate 同口径。method-grade（64★ 不 adopt 代码，吸收四分类+hallucination-rate 口径）。

### F3 — 0/34 = τ-bench 已知缺陷复发（ABC 论文点名）
ABC 论文明文「**TAU-bench counts empty responses as successful**」——不改 DB state 且无 required text 的任务上 agent doing-nothing 拿正分。MAformac LoRA 塌缩成 `toolCalls=[]` 在 `expect_no_call`/`enc=True` 案例碰巧符合 = 同一 fake-green。
- **source**：arxiv 2507.02825（ABC O 节）+ arxiv 2406.12045（τ-bench；gh sierra-research/tau2-bench 1421★ pushed 2026-06-22）— 查证 2026-06-24；本地 grill-decisions.md:120 坐实 lora 0/23 全面塌缩
- **vs baseline**：support（prevents_0_34 直接证据）。MAformac spec 已防（expect_no_call + state_delta hard gate），但 base recompute 实测 `tcm&sdm=29/57` 时若把全 57 当分母会稀释——必须按 `mp_positive_action` 子集（base 10/23）拆。

### F4 — BFCL AST checker 多 gold + set match 实现蓝本
`simple_function_checker`（ast_checker.py:333）：func_name exact + required present + per-param type + `value not in possible_answer[param]`（:497，possible_answer[param]=list-of-acceptable-values=多 gold 机制）。`standardize_string`（:174 去空格/标点/大小写=容差）。`parallel_function_checker_no_order`（:554 set match 无序 greedy 消除 matched_indices）。
- **source**：/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/gorilla/.../ast_checker.py:333,497,174,554（clone git 2026-03-23；upstream gorilla 12918★ pushed 2026-04-13）— 读 2026-06-24
- **vs baseline**：support。MAformac C6 spec「alternatives quality=acceptable」+「ToolCall set match by name/args/missing/extra/redundant」与 BFCL 同构。standardize_string 是可借的容差算法，但车控数值（26度）不能去标点过松（见 premortem）。

### F5 — base recalibration（C17）= 换 surface/harness 须 re-score all
BFCL v4（2026-04）、Scale MCP-Atlas（2026-04 升判官+改 turn limit→tool budget 后 re-score 全部模型）、Meta-Harness/Harness-Bench 都证明「harness/surface 变 → 旧分作废 → 同 harness 重跑 base anchor」是业界标准。MAformac A2 迁 D-domain 后旧 generic-frame base（10/23）按 C17 仅 historical。
- **source**：https://gorilla.cs.berkeley.edu/leaderboard.html + https://labs.scale.com/leaderboard/mcp_atlas + arxiv 2603.28052（Meta-Harness，**待核**）+ arxiv 2605.27922（Harness-Bench，**待核**）— 查证 2026-06-24
- **vs baseline**：support C17。本地旧 base c6-summary.json（generic-frame, Qwen3-1.7B-4bit, tcm&sdm=29/57, readback=0, IrrelAcc=0.739, lora=NONE）正是 historical anchor。D-domain 重测须固定同 dataset/prompt/parser/mock-state/scoring（C6 spec:206 已要求）。

### F6 — ABC O.g/O.b 三铁律直击四层门假绿
ABC O.g.1（ground-truth 含 all achievable outcomes=alternatives）/ O.g.2（state space 含 relevant+irrelevant=IrrelAcc 20%）/ O.g.3（complex enough prevent random success=防塌缩碰巧符合）/ O.b.2（prevent success-by-listing-all-answers=防 alternatives 放水）。
- **source**：arxiv 2507.02825（ABC O.b/O.g 节）— 查证 2026-06-24
- **vs baseline**：support C18+C13。MAformac spec:165（≥20% no-call）=O.g.2；spec:152（state-changing gold 必声明 state_delta）=O.g.3。ABC 给 MAformac 外部权威 checklist 背书。

### F7 — held-out 防泄漏按 template/tool-family 切分 + loss-based MIA（C13，L08 主管）
按 template/tool-family 切分（no family in both splits）+ loss-based MIA（train loss 远低于 held-out=member/泄漏）；exact dedup 不够（paraphrase/distilled 残留沿 lineage 递归传播）。C13 的 8 轴 held-out（family/value form/template/parent/tool name/generator source/scope tier/data class）与此一致。
- **source**：arxiv 2509.26553 + arxiv 2502.06215v1（LessLeak-Bench）+ https://www.deeplearning.ai/the-batch/the-problem-with-benchmark-contamination-in-ai/ — 查证 2026-06-24
- **vs baseline**：support C13（L08 主管检测，L04 评测门只消费 held-out 通过证明）。better than home-llm（无显式 held-out 轴切分）。MAformac must_not_train（spec:214）+ parent_overlap 真 0（P1-A receipt）是 dedup 层；family-split+loss-MIA 是语义层（L08）。

### F8 — judge 后置仅评话术（ABC O.c.1 + MAformac 更严）
MAformac C6 spec 已强制「Judge SHALL run only after deterministic hard gates pass」「Judge SHALL NOT change hard-gate pass/fail」「仅 clarify/refusal 话术」——避开 ACEBench 被批的 LLM-judge overhead/不稳。
- **source**：本地 spec.md:173-184 + arxiv 2507.02825（ABC O.c.1）+ ACEBench LLM-judge 批评 https://aclanthology.org/2025.findings-emnlp.697/ — 查证 2026-06-24
- **vs baseline**：support。MAformac 比 ACEBench/τ-bench 更严（judge 不能洗白 hard-gate 失败，spec『Hard-gate failure blocks judge washing』Scenario）。

---

## 本机一手实测（grounded，非外部声称）

跑 `python3` 解析 `./Reports/c5-theta-alpha-20260622T162757/c6-base-full/c6-summary.json`（57 runs，generic-frame base）：

```
total runs=57  tcm=29 sdm=37 tcm&sdm=29 readback=0 clarify=39 hard_failed=50
model_id: mlx-community/Qwen3-1.7B-4bit | lora: NONE(base) | IrrelAcc: 0.739
```

`gate_result` schema 字段（一手 SSOT，四层门重组的源）：
`tool_call_set_match` / `state_delta_match` / `readback_match` / `clarify_match` / `no_tool_false_positive_count` / `hard_failed` / `failure_classes`

**坐实点**：① 四层门所需字段已在 gate_result schema 里，重组成四层即可（无需新建评测维度）。② 全 57 当分母会稀释（tcm&sdm=29 看似过半，真 action positive 子集分母=23，base 10/23=43%，grill-decisions.md:120 口径）。③ readback=0/57 是 base 单发 FC chunkText='' 真实行为（ε 拍方案 P：readback 走端 renderer 不计 model hard_pass）。④ 这是旧 generic-frame base = C17 的 historical anchor，D-domain 须重测。

---

## 假想验证（MAformac 真实场景：Qwen3-1.7B+LoRA+D-domain 562 intent+端侧 8GB+mlx）

**预测**：base recalibration 这步技术可行、低风险（纯确定性 replay + AST set match，不需训练），D-domain 新 base anchor 大概率 ≥ 旧 generic-frame base 10/23（甚至更高）——范式翻案核心假设=D-domain 拆判定面，1.7B 更易学，base zero/few-shot 也应更稳（具名工具名直接编码 value 形态）。四层独立门设计本身无失败模式（ACEBench/BFCL/When2Call 三家先例 + 本地 gate_result 四字段已在，重组即可）。

**依据**：本机实测 gate_result 四字段齐 + BFCL ast_checker 证明 set-match+多 gold+容差是稳定可移植算法。

**失败模式（三个，按概率）**：
1. **聚合掩盖复发（最高，=0/34 同根）**：D-domain base recompute 若把全 57/562 当分母会稀释，必须按 `mp_positive_action` 子集 + 四层各分母拆。本地实测已暴露：全57跑 tcm&sdm=29 看似过半，真 action 分母 23。修法：`build_axes_from_summary.py`（grill 已定 deliverable）固化「按 case schema 字段（expect_no_call/clarify_tag/scope_tier/failure_class）拆」进 verify 门。
2. **D-domain base readback=0 假阴**：base 单发 FC readback 仍 0/N（行为没变），若误计进四层硬门会虚高 LoRA 提升空间。修法：readback 是 informational gate（方案 P，ε 拍），不进 release-blocking 四层硬门分母。
3. **alternatives 容差过松放水（中）**：BFCL standardize_string 去标点对车控数值危险（26度 vs 不是26度）。修法：D-domain 四层门 value 用 state_delta_exact，alternatives quality=acceptable 必经 verify-gold perfect-agent replay 验真（spec 已有），不靠 standardize 模糊匹配数值。

**结论**：unknown→better。技术零风险（确定性 replay），prevents_0_34 强。唯一真风险是「重跑口径拆错」（人/纪律层非技术），须固化「按 schema 字段拆分母」进 verify 门。

---

## Pre-mortem 三分类

**Tigers（明确威胁+验证清单）**
- T1 聚合掩盖：四层汇成 overall pass_rate / action 按全集分母 = 0/34 复发。验证：本地实测全57跑 tcm&sdm=29 但真 action 分母=23；grep build_axes_from_summary.py 是否按 schema 字段拆四层（ABC O.g.3 + grill 第6同坑坐实）。
- T2 base diff 不可比：D-domain 新 base 与旧 base 用了不同 dataset/prompt/parser。验证：C6 spec:206 要求 same harness；D-domain base run 的 contract_digest/prompt_hash 须与 candidate 一致（spec:187 replay fingerprint）；旧 generic-frame base 标 historical（C17）。
- T3 readback 误进硬门：base chunkText='' 致 readback 恒 0/N，计进硬门虚高提升空间（=A0→grill 四轮被误导同坑）。验证：ε 拍方案 P，eval 删 `failures.append(.readback)`（:1039）单列 informational；本地实测 base readback=0/57 是真实行为非 bug。

**Paper-tigers（看似威胁实际安全+证据）**
- PT1「BFCL v4/τ-bench/ACEBench 都 multi-turn，MAformac 需要 trajectory state-hash 吗？」→ 安全。MAformac single-turn + continuous-two-sentence splitter（非 multi-turn agent loop，范式翻案砍长时云框架，DialogueState 仅 3 轮）。吸收 per-category 报分+state-based reward+abstention 四分类口径（method-grade），multi-turn harness 不适用载体 drop。
- PT2「NVIDIA Qwen3-8B 单发95%/multi-turn卡10-22%怎么调数据都不动，MAformac 会卡吗？」→ 部分安全（留意 elephant）。该案例卡 multi-turn，MAformac single-turn 不直接适用；其结论『multi-turn 塌缩是 training-dynamics/架构非数据量』支持范式翻案『换 surface 比堆数据有效』逻辑。不构成四层门威胁（评测门不决定训练成败，只诚实量化）。

**Elephants（没人提但该提）**
- E1 D-domain 新 base 可能本身很高（surface 选对了）→ candidate 比较门若设『严格 > base』在 base 已高时难达标。须预留：四层各阈值=『≥ base 不退化』（防负优化）+『demo_critical 子集绝对达标』，非『> base 越多越好』。C17『new D-domain base as candidate comparison gate』的阈值设计须 propose 拍。
- E2 demo_fuzz 层评测数据从哪来？golden 是确定性派生，unsupported/safety 有 risk-policy 源，但 demo_fuzz『模糊说法』变体若用 LoRA 同源生成测自己 = 循环失守。须 held-out（C13/L08）保证 demo_fuzz 评测集与训练集 family/template 不重叠，否则 demo_fuzz 层假绿（测记忆非泛化）。这是 L04 评测门与 L08 泄漏检测的真实接缝。
- E3 四层门全绿 ≠ demo 现场不丢脸。四层门是『确定性可观测行为』门（tool/state/clarify/no-call），但 demo 北极星是『5 分钟惊艳+断网跑』——TTS 听感、端侧延迟（TTFT/内存）、ASR 澄清自然度这些 S-PASS/U-PASS 不在 C6 自动四层门内（spec 明示 TTS 走 human S-PASS、ASR 走 C7）。须防『四层门绿了就宣布 demo ready』的 claim-vs-reality（completion-claim-triage：四层门绿=评测态完成，≠ demo 端到端 ready）。这是 C24 status vocabulary 禁『C6 model-quality 推 demo-golden/endpoint ready』的承载。

---

## must_answer 5 答

1. **prevents_0_34**：**yes**。四层独立门 + action hard_pass 按 schema 字段拆分母（23 而非全 57/562）+ IrrelAcc 负例 ≥20% + readback 走 renderer 不进硬门 + judge 后置不洗白 = 结构性阻止『LoRA 塌缩拿 no-call 正分』。ABC 论文点名 τ-bench『empty responses count as successful』正是 0/34 同根，四层门+schema-field 拆是外部权威背书的解药。本机实测坐实全 57 当分母会稀释（tcm&sdm=29 看似过半，真 action 分母 23）。
2. **vs_rank16mainline**：**support**。base recalibration 不碰配方（rank16/scale20/LR1e-4/adamw+wd/epochs3 全冻结，C16 freeze unless evidence excludes confounders）。四层门是评测侧与训练正交，确定性 replay 无训练，零碰配方（A2 PR#3 实证配方零碰可守）。
3. **requires_a2_surface_change**：**no**。本路消费 A2 已完成的 D-domain surface（具名工具名+qwen-tool-call-format.yaml），不改它；A2 迁 D-domain 正是 base recalibration 前提（旧 generic-frame base 因 surface 变而 historical）。四层门是 A2 surface 下游消费方。
4. **introduces_deferred**：**no（不越界）**。重跑 base + 跑 candidate 评测都是 deferred（须真实模型评测，Phase 0 明示绝不执行）。本路产出=四层门 spec/口径/分母拆法/阈值范式/base recalibration 协议（治理类落 docs/research 不碰 contracts/），供 rebuild-c6 propose 当弹药。实际跑 base recalibration + 四层评测属 rebuild-c6 apply 阶段（C5/C6 contract path 绿之后），本路不执行。措辞守 completion-claim-triage：交付『评测门设计 decision-pack』（计划态）非『评测跑完』（执行态）。
5. **priority_self**：**P0**（能直接提前阻止 0/34）。

---

## 给 propose 的弹药（喂回主线程 grill）

- **G-L04-1（C18 四层分母）**：四层门各自分母按 case schema 字段拆（golden=positive_action 子集 / unsupported=expect_no_call∩scope_tier=out / safety=risk-policy refusal / demo_fuzz=口语变体 held-out）；禁全集分母稀释。⭐ 默认：固化 `build_axes_from_summary.py` 按 schema 字段拆进 `make verify`。
- **G-L04-2（C17 base 阈值）**：D-domain candidate 比较门 = 四层各『≥ D-domain base 不退化』+『demo_critical 子集绝对达标』，非『> base 越多越好』。⭐ 默认：旧 generic-frame base 10/23 标 historical-only，新 D-domain base 重测作 anchor。
- **G-L04-3（readback 归属）**：readback informational gate（方案 P，走端 renderer），不进 release-blocking 四层硬门分母。⭐ 默认：维持 ε 决策（删 eval `:1039`，单列 informational）。
- **G-L04-4（judge 范围）**：judge 后置 + 仅 clarify/refusal 话术 + 不改 hard gate（spec 已有）；ABC O.c.1 加 judge accuracy+self-consistency 验。⭐ 默认：保持现状（比 ACEBench 严）。
- **G-L04-5（demo_fuzz 泄漏接缝）**：demo_fuzz 评测集须与训练集 family/template 不重叠（held-out，C13/L08 落实），否则 demo_fuzz 层测记忆非泛化。⭐ 默认：demo_fuzz held-out 由 L08 family-split 保证，L04 评测门消费其通过证明。

## 存档落点
本档 = lens4 一手结构化（full_markdown），主线程落盘 `docs/research/<date>-c6-gate-base-recalib/lens4.md`。一手锚：本机 c6-summary.json 实测 + BFCL ast_checker.py file:line + ABC/τ-bench/When2Call/ACEBench source URL（external_claims 精确数字待主线程 gh/WebSearch 核，尤 Meta-Harness/Harness-Bench arxiv 2603/2605 cutoff 后 ID 高编造风险）。