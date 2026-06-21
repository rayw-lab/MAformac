# MAformac Roadmap — 新基线 2026-06-20（C6 done 起点）

> **此文是「此时此刻」往后的唯一推进事实源**。把三刀 / 38 项 / 14-repo synthesis / Qwen 可行性 / 磊哥评审全部收敛成一条从 **C6 apply done** 起步的清晰路线；2026-06-20 archive closeout 后，P0 已收口，当前入口是 P1-A C5 数据门 + P1-B Qwen spike。
> **方法论骨架 = 项目五件套 harness（OpenSpec + Pocock + Superpowers + Pi + Mastra）的精髓**（§1），后续每个 C-change 照此推进。
> 配套读：`docs/research/2026-06-20-eval-memory-deepdive-synthesis.md`（吸纳意见全料）+ `CLAUDE.md`（宪法）+ `docs/srd-three-layer-intent-routing.md`（架构）。
> 一手 file:line 锚点均已 verified（2026-06-20，§28/§30）；标「评审引用」者 = 待该 change 实装时再核。

---

## 0. 新基线快照（此时此刻，verified）

| 资产 | 状态 | 证据 |
|---|---|---|
| C1 `semantic-function-contract` / C2 `scenario-state-protocol` | **archived → `openspec/specs/`** | a9888bc |
| C3 `define-execution-contract`（单跳 ToolCallFrame + DemoGuard + mock state + 五段 trace） | **archived → `openspec/specs/tool-execution/`**；7.3 Qwen sampling 未实测，已迁移到 P1-B Qwen spike | `openspec/changes/archive/2026-06-20-define-execution-contract/` |
| C6 `define-vehicle-tool-bench`（四硬门 + judge 不洗白 + replay 指纹 eval_run + 双轴） | **archived → `openspec/specs/vehicle-tool-bench/`**；base Qwen3-1.7B 无 LoRA **hard_fail**（IrrelAcc 0.789<0.9 / hard_failure 170/225）= C5 提升的诚实可复现锚点；archive-check verify-gold pass | `Reports/c6-gold-verify-archive-check-20260620-185441/` |
| 14-repo teardown + Qwen3.5-2B 可行性 + synthesis | **committed 31edafc → push origin/main** | git |
| C4 三层路由/短时记忆 · C5 LoRA 数据 · C7 离线语音 | **未起（待解冻）** | — |

**新基线一句话**：能跑的链路（C1→C2→C3→C6）都已 archive 入 `openspec/specs/`，且 C6 已用诚实 hard_fail 标定了「LoRA 要证明什么」。**P1-A/B 收口 push `846e40c`；2026-06-21 P1-C grill Q11-Q18 收口 + C5 apply 派单就绪(hermes GLM-5.2 异源 + subagent CC 双审,2 BLOCKER[B1 enable_thinking offset 过冲 / B2 dev_selection 撞 spec.md:4]已修为显式非自主);模型训 Qwen3-1.7B;真机无 iPhone8GB(在旁可用,端侧 V-PASS 必真机)→ P1-C 拆两 V-PASS(模型质量 Mac 可达/端侧真机);下一步=派 codex 自主实装(派单 `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-21-c5-lora-training-apply-dispatch.md` + handoff `2026-06-21-p1c-grill-closeout-c5-apply-dispatch.md`)。**

---

## 1. 推进 harness：五件套精髓骨架（roadmap 方法论层）

> 这是 roadmap 的「怎么推」元层。后续任一 C-change 起手，先按这张骨架定位：**用哪个 harness 的哪个机制承载**。五件套不是并列工具，是分层咬合（Pocock 定阶段 → OpenSpec 装契约 → Superpowers 保质量 → Pi 治长任务 → Mastra 给 eval/执行工程形态）。

### 1.1 OpenSpec — 推进容器（管「做什么」+ 行为契约事实源）

- **流水线**：`/opsx:explore`（脑暴）→ `propose`（proposal + specs delta + design.md + tasks.md）→ `apply`（实现）→ `archive`（delta 才 merge 进 `specs/`）。
- **铁律**：`specs/` = 唯一事实源（只写**可观察行为**：Requirement `SHALL` + Scenario `GIVEN/WHEN/THEN`，**不写实现**）；实现细节进 `tasks.md`。Delta 用 ADDED/MODIFIED/REMOVED。
- **archive 完备门**（§30 血泪）：archive 前 spec 非空（全 supersede 留**墓碑 Requirement**）；`openspec validate --strict` ≠ archive 会成功，**必实跑 archive + `git status` 对账**。
- **roadmap 落点**：P0 = 在**未 archive 的 C6 change 内补 delta 再 archive**（不开新 change，避免带病 archive + 碎片化）；P1=C5 新 change；P2=C4/C7 各新 change。**C3 tasks 0/38 要补勾后 archive**（清旧债）。

### 1.2 Pocock — 阶段分诊（管「现在哪一阶段」）

- 二开路由器：S0 intake / **S1 grill** / S2 design / S3 spec / S4 build / S5 diagnose / S6 close。只推一个主技能，**grill-first**。
- **roadmap 落点**：P0=S4 build（C6 收尾，已 design 完）；Qwen spike=**S5 diagnose**（spike 验证 failure mode）；C5/C4/C7 起手=**S1 grill → S2 design → S3 spec**（每个 propose 前 grill 对齐，不跳 explore 直奔 propose）。

### 1.3 Superpowers — 质量执行（管「怎么高质量做」）

- brainstorming（**HARD-GATE：不 propose/design 对齐前不 build**）/ writing-plans / **TDD**（红→绿→重构）/ systematic-debugging / verification（6 阶段门）。
- **roadmap 落点**：C5/C4/C7 propose 前走 brainstorming HARD-GATE；codex 长跑实装走 **TDD（测试先行）**；base hard_fail 归因 + Qwen spike 走 systematic-debugging；每个 apply 收尾走 verification-loop（build→types→lint→tests→security→diff）。

### 1.4 Pi — 长任务 / 派单治理（collaboration §4.5 已落三形态）

- **事件溯源 handoff**（append-only，七段模板，**永不回改**）+ **七段 compaction 模板**（session 续接）+ **派单 before/after hook 验收门**（工具调用前置检查 + 后置验收）。
- **roadmap 落点**：每个 P 阶段收尾落 append-only handoff；派 codex C5 长跑 / subagent 审计时，dispatch 内置 before（起手读契约+跑现状命令）/ after（验收门：失败写 receipt、smoketest 实采、risk_state 枚举）gate；compact 续接靠七段模板 + continuation-prompt。

### 1.5 Mastra — eval / 执行工程形态（teardown 已扒，只借形态不进 runtime）

| Mastra 形态 | MAformac 落点 | 红线 |
|---|---|---|
| **workflow graph（冻结图 + enum Stage + code condition + RunStatus 枚举）** | C3/C4 **确定性 DemoFlow**：编排/多步/状态/安全全在 code，模型只产单跳 | **禁自由 agent loop**（Mastra #6827 重复调 mutative tool 到 maxSteps / #11273 静默终止 = 反面证据，进 C4 design Risks） |
| **TrajectoryExpectation** | C6 `expected_tool_calls` 契约 + C4 route trajectory eval（与 agentevals graph `__interrupt__` 同源） | clarify/refusal/interruption = 显式步骤一等公民非 fail |
| **scorer 四阶段 pipeline（extract → analyze → score → reason）** | C6 判分：extract toolCalls → analyze 四硬门 → score 双轴(coverage+scenario) → reason(judge) | judge 只在 reason 段、**不洗白硬门** |
| **observability span 树** | C3 五段 trace + C6 eval_run 10 字段指纹（replay 可复现） | span 落盘过脱敏门（PII/语料不入仓） |
| **LLM-as-judge（主观维度）** | C6 clarify/refusal 文本质量 | 不参与放行硬门（已锁 Q3） |

### 1.6 harness × C-change 映射速查

| 阶段 | Pocock | OpenSpec 动作 | Superpowers | Pi | Mastra 形态 |
|---|---|---|---|---|---|
| **P0 C6 收尾** | S4 build | 现 change 补 delta → archive | TDD + verification | 派 codex/审计 hook 门 | scorer pipeline / trajectory / judge / 指纹 |
| **P1 C5 数据门** | S1→S4 | 新 change（explore→propose→apply） | brainstorming HARD-GATE + TDD | codex 长跑 before/after 门 | (数据配方，无 runtime) |
| **P1 Qwen spike** | S5 diagnose | （无 change，spike 报告入 docs/research） | systematic-debugging | spike 报告含「测了/没测哪些 failure mode」 | — |
| **P2 C4 路由/记忆** | S1→S3 | 新 change | brainstorming + writing-plans | append-only handoff | DemoFlow graph / TrajectoryExpectation |
| **P2 C7 voice** | S1→S3 | 新 change | brainstorming | handoff | observability / 写史合同 |
| **C6.1 扩展** | S2→S4 | C6.1 新 change（C5 checkpoint 后） | TDD | — | pass^k / failure receipt / matcher |

---

## 2. 统一口径（评审金句，升为 roadmap 宪法）

> **字段不降级，runtime 不膨胀；合同先保留，执行按依赖分批。**

| 不过度工程化 — 该砍/延后（撞红线/重治理/demo 用不上） | 不降级 — 不能砍（字段/合同/硬门） |
|---|---|
| Python·Node·Mastra·Pi runtime 进 iOS | failure receipt（红了要能复现） |
| 自由 ReAct / agent loop（撞单跳铁律） | model·prompt·contract·**权重** fingerprint（diff 可信） |
| 向量 DB / 长期记忆 / Mem0 / Letta 首版 | no-call / restraint 一等硬门（自信乱调 > 漏调） |
| LLM 自动摘要 runtime | state_delta + readback（验收以 mock 态读回为准） |
| 云 provider / WebRTC / k8s / redis / 多 agent 委派 | judge 主观项（澄清/拒识质量，但不洗白硬门） |
| 大型时间演化仿真 v1（C6.1 后期） | alternatives + quality 多正解（acceptable 也过，degraded 才扣） |
| | DialogueState（多轮/锁域/打断/低置信 ASR 靠结构化态） |
| | matcher override（温度±1/颜色近似/车窗范围，不每容差写一 scorer） |

---

## 3. 7 个 HIGH 拍板（H1–H7，磊哥评审已拍 + 我核实细化）

| # | 决策 | 拍板（磊哥） | 我核实后的执行细化 |
|---|---|---|---|
| **H1** | Qwen3.5-2B 升主力 | **条件升级**：先 S1 parser + S2 iPhone GDN TTFT，**不先训 LoRA** | ⚠️ 纠偏：spike **必须在 C5 LoRA train 之前收口**（它定训哪个模型）；与 P0/P1 数据门**并行**，gate 在 train 前。S1+S2 过→训 2B；S1 不过→训 1.7B 守主力 |
| **H2** | 短时记忆落 C4 | **落 C4 DialogueState，不新建层**；补 `session_ttl=300 / focus_ttl=90` 两层 | C4 = `DialogueStateStore + FollowupResolver`，加载现成 `contracts/semantic-followup-transitions.jsonl`（已 verified 存在）；不建 DB 不上向量 |
| **H3** | C6.1 时机 | **C6.1 接收，但先做 C5 前置修复；NIT1/NIT3/trap/verify_gold 不能等二期** | ⚠️ 状态更新：base 已跑出 hard_fail，「等 base 真跑」已过时 → 现在是 **P0 收尾**（这 4 项），见 §4-P0 |
| **H4** | C5 先数据门 vs 先训 | **先数据门，升为阻塞**（receipt/split/masking/must_not_train=0） | 数据门**模型无关**可先做；train 等数据门过 + Qwen spike 定模型 |
| **H5** | C7 打断 | **按钮首版（D13），写史合同首版即上、加硬** | 按钮打断可简化，写史合同不可简化：首版即记 `tts_committed_text / interrupted / played_until_offset / history_commit_boundary`；raw ASR 只入 trace 非权威态 |
| **H6** | judge + 多正解进金标 | **进**：judge 不洗白硬门 + 金标带 alternative+quality | ⚠️ 纠偏拆分：**金标带 alternatives（acceptable 集）+ superset 匹配 提前到 P0**（防 trap 冤杀）；**quality 四档分级 + 数值容差 matcher override 留 C6.1** |
| **H7** | UI/UE 重评估 | **追加**：C7 后、S6 演示包前重评 | 审美 5 Gate；最终不降级优化 |

---

## 4. 执行序列 P0 → P1 → P2（依赖分批，每项带 file:line + harness 落点）

### 🔴 P0 — C6 完备化收尾（在未 archive 的 C6 change 内补 delta，补完 archive；**不做完不训 LoRA**）

> **Status 2026-06-20 archive closeout**: P0-1/P0-2/P0-3/P0-4 已完成并 archive；C3 7.3 债已迁移到 P1-B Qwen spike；C3/C6 active changes 均已移动到 `openspec/changes/archive/`。

> Pocock S4 build · OpenSpec「现 change 补 delta → archive」· Superpowers TDD · Mastra scorer/trajectory/judge。
> **为何不开 C5-0 新 change**：C6 ✓ Complete 但未 archive，这 4 项修的全是 C6 资产（harness/cases/envelope）；带 NIT archive = 带病归档（§30），新 change = 碎片化。补完才是 C6 真 done。

| 项 | 做什么 | 一手 file:line（verified） | harness |
|---|---|---|---|
| **P0-1 readback 门复用 SSOT** | `C6ReadbackRenderer.render` 现退化成 `key=value` 机器拼接丢中文 → 改为调 `StateCellContractLookup.renderReadback`（吃 C2 `readback_zh` 模板渲中文），与 C3 真实执行同一口径再比对。硬门：①state_delta 对 ②readback 文本来自 mock state 经模板渲染 ③含设备/状态/数值中文 ④no-call case 不许虚假 readback | `C6VehicleToolBench.swift:896`(退化) → 复用 `Core/Contracts/ContractLookups.swift:164`(`renderReadback`)，对齐 `C3ExecutionPipeline.swift:115` | OpenSpec MODIFIED「readback」Req（行为变更入 spec）+ Mastra scorer.analyze |
| **P0-2 model 权重 fingerprint** | `C6EvalRun` 现锁 modelID 字符串非权重 hash → 补 `model_artifact_digest / tokenizer_digest / lora_adapter_digest`（调现成 `sha256OfFile`），base↔LoRA diff 才可信 | `C6VehicleToolBench.swift:511`(envelope) + `:951`(`sha256OfFile` 基建已有) | OpenSpec MODIFIED「replay 指纹」Req |
| **P0-3 判断陷阱样本 + alternatives 金标** | 现 45 cases=30MP+8NEG+7COV，缺**语义陷阱**。从 3990 协议 + 12000 bug 挖 **12-18 条**：否定(别开空调开窗)/诱饵(26度有点热别再查温度)/冗余(不是车窗是屏幕)/模糊(凉飕飕的)/安全(行驶中继续开)/低置信 ASR(座椅通分)。每条带 `expected + alternatives(acceptable集) + quality 标`；匹配支持 **superset**(命中 alternatives 之一=pass，防冤杀) | `contracts/c6-bench-cases.jsonl`(现状) + 一手源 `~/workspace/raw/`（协议/bug，只读脱敏不入仓） | OpenSpec tasks（cases 数据）+ MODIFIED「金标 schema」Req（加 alternatives）+ Mastra TrajectoryExpectation |
| **P0-4 verify_gold 自洽守护** | 缺（grep=0）→ 新建：deterministic 完美 agent 回放金标，**先证 bench 自己的金标全过**再评模型；区分「模型蠢 vs 金标坏」 | `C6VehicleToolBench.swift`（新增） | OpenSpec ADDED「bench SHALL verify_gold 自验」Req + Superpowers TDD |

**P0 收尾**：补完 → `openspec archive define-vehicle-tool-bench`（实跑 + `git status` 对账，§30）→ C6 真 done。**顺手清债**：C3 `tasks` 补勾 → archive `define-execution-contract`。

### 🟡 P1 — C5 数据门 + Qwen spike（并行）

> **Status 2026-06-20 晚（push origin/main `846e40c`）**：P1-A ✅ **V-PASS** · P1-B ✅ **done=BLOCKED（守 1.7B）** · P1-C ⚠️ **仍 blocked**（差 masking 数据生成 + 训练环境，需 grill）。两单单工作树并行、文件域不重叠、各拆 clean commit + CC 二层对抗审计*2（P1-A CLEAR / P1-B CLEAR+修 VL 披露 BLOCKER-1）。
> C5：Pocock S1→S4 · OpenSpec 新 change · Superpowers brainstorming HARD-GATE + TDD · Pi codex 长跑 before/after 门。

| 项 | 状态 | 结果 / 前置 |
|---|---|---|
| **P1-A C5 数据门** | ✅ **V-PASS** | `define-lora-data-gate` + C5DataGate validator + receipt(3670 行:train2320/heldout1200/must_pass30/quar120;must_not_train=0/parent_overlap 真 0 字段级 lineage/C6 42+12 trap 零进 train/validator exit65 真阻断/digest 可复算/raw 只读)。⚠️ **masking_coverage 全 false**(未实现 masking 三形态)=P1-C 硬前置未完 |
| **P1-B Qwen spike** | ✅ **BLOCKED** | S1 真采(mlx-swift-lm 3.31.3→xmlFunction):**Qwen3.5-2B 8/11=72.7% 全面劣于 1.7B baseline 9/11=81.8%**(漏触发"屏幕太暗"/否定 trap);S2 无真机 blocked_env;artifact 实为 **VL 多模态**(借文本塔)。decision=守 1.7B,s1_only_candidate。**模型已定=训 Qwen3-1.7B** |
| **P1-C LoRA train** | ⚠️ **仍 blocked** | **两前置须 grill 拍**:① **masking 数据生成**(P1-A masking_coverage→true:train_on_turn/arg-token/function masking,Hammer/GOAT 配方,防死记 3HIGH 之一)② **训练环境未定**(unsloth 要 CUDA,Mac M5 无 N 卡→云 GPU or mlx-lm 本机 LoRA,须联网搜证)。模型=1.7B 已定;train=same C6 harness diff + 权重 fingerprint(P0-2)锁 |

### 🟢 P2 — C4 + C7 propose 解冻（C5 第一轮 checkpoint 后 / 可并行设计）

> Pocock S1→S3 · OpenSpec explore→propose · Superpowers brainstorming HARD-GATE · Mastra DemoFlow graph。

**P2-A C4 DialogueState（H2）** — `DialogueStateStore + FollowupResolver`，加载 `contracts/semantic-followup-transitions.jsonl`（+ `demo-scenarios.yaml` scene3 followup，评审引用待核）：
```yaml
dialogue_state:
  session_ttl_seconds: 300        # session 层
  focus_ttl_seconds: 90           # focus/锁域层(更短防串台)
  focus: { domain, device, scope, followup_transition_id, state_revision_seen }
  last_execution: { tool_call_frame_id, state_delta, readback_ok, tts_committed_text, interrupted }
  risk_context: { vehicle.speed, vehicle.gear }   # safety cells 每轮 fresh read,memory 不绕 risk-policy
```
- ContextGate + RangeSlot（HassIL `requires/excludes_context` + range list 形态，**数值从 C2 execution_range 来不照搬蓝本**）。
- route trajectory eval（agentevals graph：L1 必走规则快路 = 步骤序列死门，误入慢路即 fail）。
- **不建 DB / 不上向量记忆**；Mastra agent loop 失败 #6827/#11273 进 design Risks。

**P2-B C7 VoiceTurnContext（H5）** — 写史合同首版即上（按钮打断 D13）：
```yaml
voice_turn_context:
  raw_asr_text: trace_only          # 只入 trace,非权威记忆
  normalized_text: route_input       # TextNormalizer(NFC+全角) 后进路由
  asr_confidence: float              # 低置信→拼音 fuzzy 澄清(D14 Paraformer)
  interruption_state: enum
  spoken_prefix / tts_committed_text: committed_only  # 只记用户实际听到那截
  interrupted: bool
  played_until_offset_ms: int?
```
- assistant message 只有 TTS committed boundary 后进短时上下文；被打断/未完成 turn 不更新 focus。
- `INTERRUPTION_TIMEOUT` 超时兜底首版上（防现场卡死）；`/no_think` 抑制思考 token（延迟死门，TTS 绝不念思考链）。
- 语音自动打断（双门 min_duration∩min_words 中文字数门 + pause-not-kill + false-interruption resume）= **C7 第二刀**。D14 sherpa-onnx 中文主 + WhisperKit fallback + ASRBackend 抽象已锁。

### ⏭️ C6.1 — 延后不砍（C5 第一轮 checkpoint 后）
pass^k / run_repetitions 多跑方差（base/边界 case N≥5，temp=0）+ failure receipt 脊柱（nano 6 字段 + 4 类归因 + 3 样本字节同一 flaky）+ **容差 matcher override**（数值±1/颜色近似，agentevals）+ **quality 四档分级**（degraded 扣分非 fail）+ wrong-tool histogram + 零依赖 HTML report + 时间演化 case（simuhome，最后）。

### 🎨 H7 — UI/UE 重评估（C7 后、S6 演示包前）
审美 5 Gate；最终不降级优化。

---

## 5. 坑点先行（tiger / paper-tiger / elephant）

- 🐯 **Qwen3.5「支持」≠ tool-call 可用** → 必须 endpoint 实采结构化 `tool_calls`（S1，撞项目 T2 坑放大）。
- 🐯 **短时记忆写 raw ASR 或未播完 TTS → 下轮上下文撒谎** → 写史合同（committed_only + raw ASR trace-only）。
- 🐯 **无 verify_gold + split + must_not_train → LoRA 提升不可信** → P0-4 + P1-A 硬门。
- 🐯 **GDN 端侧 prefill 退化（14x latency）** → S2 真机 + CoreML 双模型兜底。
- 📄 **短上下文不是降级** → 是 Qwen3.5/GDN 现场延迟风险下的**正确护栏**（paper-tiger）。
- 🐘 **真正难点是 dataset 作者纪律不是 runner 代码** → 陷阱样本 + gold 自洽要人拍死（P0-3/P0-4）；gold 不是天授会被修订（tau2 75+ fixes）。

---

## 6. 三条不可违反纪律（贯穿全路径）

1. **依赖序**：C6 优先于 C5（评测先于训练）；数据门先于扩数据；C6 base 先于 LoRA diff；**Qwen spike 先于 train（定模型）**。
2. **架构红线**：单发（MAX_ITER=0）+ 安全是代码不是 prompt + Python·Node 零进 iOS + 禁自由 agent loop。
3. **不降级**：star>1000 工程价值全量吸收，只 filter 真不适用载体；C6.1 分批 apply ≠ 降级，是依赖序（base 真跑暴露真实需求）。

---

## 7. 关键路径依赖图（含 harness 标注）

```text
[新基线] C1/C2 archived · C3 apply done(tasks待勾) · C6 ✓Complete · base hard_fail 0.789
   │
   ├─🔴 P0 C6 收尾 ─────────────────────────────────────────────────┐ OpenSpec(现change补delta)
   │   P0-1 readback 复用 renderReadback(SSOT)                       │ Mastra scorer.analyze
   │   P0-2 model 权重 fingerprint(sha256OfFile)                    │ + Superpowers TDD
   │   P0-3 12-18 trap cases + alternatives 金标(superset 防冤杀)    │ + Pocock S4
   │   P0-4 verify_gold 自洽守护                                     │
   │        └─→ archive C6(实跑+git对账,§30) + 清债 archive C3 ──────┘
   │
   ├─🟡 P1-B Qwen spike(S1 parser/S2 GDN TTFT) ──┐ Pocock S5 · Superpowers debug
   │   (与 P0/P1-A 并行, gate 在 train 前)         │ → 定训 2B 还是守 1.7B
   │                                              │
   ├─🟡 P1-A C5 数据门(receipt/split/masking) ────┤ OpenSpec 新change · Pi codex门
   │   (模型无关可先做)                            │
   │                                              ▼
   │   P1-C LoRA train(数据门过 + spike 定模型) ── same C6 harness diff(指纹锁)
   │                                              │
   ├─🟢 P2-A C4 DialogueState(followup sidecar) ──┤ OpenSpec propose · Mastra DemoFlow
   ├─🟢 P2-B C7 写史合同(committed_only) ──────────┤ · Superpowers brainstorming HARD-GATE
   │                                              │
   ├─⏭️ C6.1(pass^k/failure receipt/matcher/quality) C5 checkpoint 后
   │                                              │
   └─🎨 H7 UI/UE 重评 ── C7 后 / S6 演示包前
```

**起手第一步**：**P1-C 启动评估 grill**（P1-A ✅V-PASS / P1-B ✅守 1.7B 已 push `846e40c`）— 拍 ① masking 数据生成 ② 训练环境（Mac M5 无 N 卡，云 GPU or mlx-lm 本机）。两前置过才训 Qwen3-1.7B LoRA。P2 C4/C7 在 C5 第一轮 checkpoint 后解冻。

---

> 维护：本 roadmap 是活文档。每个 P 阶段推进 / HIGH 再拍 / 坑点命中 → 立即回写本文件 + `CLAUDE.md §9` 指针 + memory（CLAUDE §8 级联）。append-only handoff 记每阶段收尾。
