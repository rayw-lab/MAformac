---
authority: gate7_cloud_generator_design
artifact_kind: c5_gate_construction_design
dispatch_id: SPEC-G7
gate: gate7 云多源 generator + 异源 judge 三权分立（design/spec-only）
executor: Opus subagent CC（替代故障 hermes；commander 定「Opus 对生成设计更强」）
grill_dimension: 维度7 云generator（SSOT 归 W1 数据线 = worker-1-data-decisions.md D-031~095）
worktree: /Users/wanglei/workspace/MAformac-g7 (branch c5gate/g7-cloud-generator-design, base origin/main 771f48ad)
decision_status: ⭐-default pending 磊哥 formal lock（D-031~095 grill status=proposed，本批 D-031~037 已随 D-007「都按推荐来」locked，见 reduction-table.md:60 / SYNTHESIS.md:52；round2 D-046~095 仍 proposed）
r7_boundary: design/spec-only — 不 build 可运行生成代码 / 不 run 任何生成 / 不产训练数据/语料（一条话术都不）；fixture 仅字段占位无真话术
created: 2026-07-01
status: commander_reviewed_magnet_ratified_q1a_q2a
review: commander 读全文 + python 亲核前数据集反思（100% 吻合：generator/judge 都 hermes 家族 100% same-vendor / utterance 4306 distinct 中文 mean 9.3）= CLEAR 无 P0；磊哥 2026-07-01 拍 Q1-A（GPT-5.5 纯异源 judge）+ Q2-A（0/34 口径重述），见 commander-log D-008
---

# SPEC-G7 — gate7 云多源 generator + 异源 judge 三权分立（design/spec-only）

> 🔴🔴 **R7 边界声明（文档头，最高优先）**
> 本文是 **design/spec-only** 产物。执行方 = Opus subagent CC（替代故障 hermes），**只读/反思/设计**：
> 1. **不 build 可运行生成代码**（无能真调云 LLM 产 utterance 的可执行脚本；所有伪代码不可运行、无真 API 调用）。
> 2. **不 run 任何生成 / 不调云 generator 产数据 / 不产一条训练 utterance 或语料**。
> 3. **fixture 只填字段结构/schema 占位**（值一律 `<PLACEHOLDER_*>`），**绝不填真实中文话术内容**（哪怕标"示例/fixture"也不行——填具体话术 = 产语料 = R7 BLOCKED）。
> 4. `R7: real cloud generation run BLOCKED until candidate signoff + run auth`（`docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md:20-29`,`:126`）。
> 本文交付 = 一份 design/spec markdown。**落盘 commit 由 commander 做**（把本文全文落 `MAformac-g7/docs/c5-training-readiness-grill/gate7-cloud-generator-design.md` 并 commit `c5gate/g7-cloud-generator-design` 分支）。

---

## §0 摘要 + 你在防什么

gate7 = C5 **训练集** utterance 生成的编排架构。要把它从【research 锁了方向（probe verdict + D-031~095）、代码未闭环】推进到【可实现的 design/spec】。核心 = **三权分立**：

| 权 | 组件 | 职责 | 谁不能碰 |
|---|---|---|---|
| **产** | generator（多源云 LLM） | 产**自然中文** utterance（措辞多样性） | 绝不定 label / gold（D-034,D-043） |
| **标** | label-gold（C1 契约 deterministic） | 从 `semantic-function-contract.jsonl` 确定性算 tool_call 标签 | 绝不靠 LLM 标（D-034） |
| **审** | validator-judge（**异源** LLM） | 审语义正确/自然度/OOD，出保留/拒绝 + 原因 axis | judge 厂商 ≠ generator 厂商；绝不改 label（D-036,D-043） |

🔴 **防两次双仓惨败重演**：
- **惨败1（`0/34`）**：8D 根因 = 训练侧「metadata 声称 vs code enforce」脱节（446 假删工具 / name-last 撞 Qwen / tool surface 分叉，8d 记录在 `docs/c5-recovery-2026-06-22/8d-rootcause.md:50-65`；⚠️ 8d 引的 pre-A2 代码行号 `C5LoRATraining.swift:2333/:2407/:1942` 在 A2 重构后已漂移，以 8d 文档记录为准）+ generator/judge self-bias。
- **惨败2（θ-α）**：单源同质化 + capacity gap（`docs/research/2026-06-21-c5-generator-selection-probe.md:70`,`:90`）。
- gate7 三权分立正是防这两个：**多源产 / 契约标 / 异源审** 三者分离。

> 🔴 **本文最刺眼的 grounding 发现（§1 详述，惊动整个 design）**：上一次真跑（`Reports/c5-remediation-wave-20260621T2013-pr3-full/`）**只用了 2 源，且两源都是 hermes 托管**（`hermes_glm` + `hermes_ark_standard`），"异源 judge" 实为 hermes 家族内 glm↔ark 自审——**D-032/D-036/D-037 的"跨厂商/跨家族"在实跑中被违反**（实测 100% generator 与 judge 共享 hermes 顶层厂商前缀）。gate7 design 的第一铁律就是修这个：**judge 必须跨【真厂商】边界，不是同一托管方内的两个模型名**。

---

## §1 前一次生成数据集反思（grounding，一手 file:line + 样本 + 复算）

> 磊哥新增核心指令：参考之前真跑的数据集 + 找反思，让新 design 吸收教训别重蹈。本节全部基于**实际产物 jsonl 复算**（design-only，只读不改）。

### §1.1 前一次是什么（实际产物盘点，一手）

上一次云多源生成 + judge 的实际产物在 `Reports/c5-remediation-wave-20260621T2013-pr3-full/`：
- `generated-utterances-final.jsonl` = **4500 条 pass 记录**（`final-generation-merge-summary.json`:`final_pass_records:4500`）。
- 字段结构（从实际记录读，`generated-utterances-final.jsonl:1`）：`candidate_parent_semantic_id / contract_row_id / generator_call_id / generator_model_id / prompt_hash / semantic_judge_call_id / semantic_judge_model_id / utterance / variant`。
- 覆盖 **1766 个 distinct contract_row**（复算：`distinct contract_rows:1766`）；共 **4306 条 distinct utterance**（复算：`distinct utterances overall:4306`）。
- 这些物理字段与当前代码 receipt `physicalFields` 一致（`Core/Training/C5LoRATraining.swift:2357-2359` 含 `generator_model_id/generator_call_id/semantic_judge_model_id/semantic_judge_call_id/prompt_hash`）→ **说明 pipeline 的数据 schema 已存在，gate7 是在既有 schema 上补编排 + 门，不是从零**。

### §1.2 🔴 0/34 具体埋雷点（本节最载力，逐个带证据）

**埋雷① — "多源/异源" 架构在实跑中被违反（最严重，data 铁证）**
- 复算：`generator_model_id counts: {'hermes_glm': 2249, 'hermes_ark_standard': 2251}`；`judge_model_id counts: {'hermes_ark_standard': 2249, 'hermes_glm': 2251}`。
- 复算：**records where generator & judge share top-level vendor prefix: 4500 / 4500 (100.0%)**。
- 含义：D-032 要求「Claude/GPT-5.5/Codex/GPT Pro 多源」（`worker-1-data-decisions.md:47` D-032-A），D-036/D-037 要求 judge「跨模型/跨家族」「非 Claude-family 优先」（`:51`,`:52` D-036/D-037-A）。**实跑只用 hermes 托管的 glm + ark_standard 两个模型，二者同属 hermes（火山/twofish）家族**——"异源 judge" 退化成**同一托管方内两个模型互审**，probe E3「preference leakage:judge 偏好同家族 generator」（`probe:68`）+ E1「self-preference」（`probe:66`）的防线**没建起来**。这是 gate7 最该修的第一漏。

**埋雷② — 多样性偏薄 / 尾部收窄（θ-α 同质化在 data 层的显影）**
- 复算：mean utterance = **9.3 字符**（min 2 / max 20）——短祈使句为主。
- 复算 per-seed distinct-utterance 分布：**373 个 seed 只有 1 条 distinct utterance**、676 个 2 条、562 个 3 条；仅 84+52 个 seed 到 6-7 条。
- 抽样（`generated-utterances-final.jsonl` 前 3 contract_row 的 distinct utterance，字面话术已 redacted，仅保留 shape）：
  - `c1_airControl_000002`: 只 2 条（`pattern_class=short_imperative / normalized_template=PH_DEVICE_ACTION / length=8 / hash8=1ff4b871`；`pattern_class=settings_navigation / normalized_template=PH_OPEN_DEVICE_SETTINGS / length=8 / hash8=1f2c853a`）。
  - `c1_airControl_000003`: 3 条（`pattern_class=seat_scoped_imperative / normalized_template=PH_SEAT_DEVICE_ACTION / length=9 / hash8=618a61c4`；`pattern_class=seat_scoped_polite / normalized_template=PH_SEAT_DEVICE_ACTION_POLITE / length=8 / hash8=1131ab63`；`pattern_class=side_scoped_settings / normalized_template=PH_SIDE_DEVICE_SETTINGS / length=8 / hash8=e83b88e6`）。
  - `c1_airControl_000004`: 3 条（`pattern_class=short_imperative / normalized_template=PH_DEVICE_ACTION / length=8 / hash8=0a5e5b6b`；`pattern_class=softened_imperative / normalized_template=PH_DEVICE_ACTION_SOFTENED / length=9 / hash8=656d16a3`；`pattern_class=settings_navigation / normalized_template=PH_CLOSE_DEVICE_SETTINGS / length=8 / hash8=0e732197`）。
- 含义：措辞集中在 `PH_DEVICE_ACTION` 短祈使模板 + `PH_OPEN_DEVICE_SETTINGS` 设置页导航模板——**缺 D-080 要求的 short-imperative / ellipsis / polite / context-followup 四类长短句覆盖**（`worker-1-data-round2.md:51` D-080-A），缺 D-079 的 value-form（SPOT/EXP/PERCENT）覆盖（`:50` D-079-A）。这正是 probe pre-mortem「单源同质化 distribution collapse，fc_l3 尾部仍缺」（`probe:102`）+ E7 model collapse（`probe:72`）在实测数据里的样子。**同源两模型 + per-seed 变体少 = diversity gate 形同虚设**。

**埋雷③ — 「0 条自然中文」的口径需澄清（dispute-triage：不照抄 SPEC 措辞，以一手 data 为准）**
- SPEC §0 写惨败1 = 训练集「0 条自然中文」。**但一手 data 显示 gate7 阶段确实产了 4306 条 distinct 中文 utterance**（§1.1 复算）。
- 分诊：这两者不矛盾，是**两个不同 pipeline 阶段**——
  - gate7（**生成阶段**）：产出了自然中文 utterance（本 Reports 目录证明）。
  - 训练侧（**下游 sample 组装阶段**，`prepare-final-v3/mlx-data/train.jsonl` 4556 行）：8D 根因在这里——`buildNoCallSamples` 假删工具（`8d:51-53`）、name-last 渲染（`8d:62`）、tool surface 分叉（`8d:63`）。这是**训练 sample 构造 bug，不是 generator 产 0 条中文**。
- 🔴 **对 gate7 design 的含义**：gate7 修不了训练侧 sample 组装 bug（那是 A2/P1-P9 的活）。gate7 能修的、也是本设计的边界 = **让生成阶段产的中文既自然又多样、且异源审真跨厂商、且不污染 held-out**。**别把训练侧 0/34 甩锅给 generator，也别宣称 gate7 能单独解决 0/34**（8d:68「不应把范式/scale 列为主因，但也不能宣称已排除」的纪律同源）。这条上报 commander：**惨败1 的「0 条自然中文」措辞在 gate7 语境下要重述为「自然中文虽有但薄 + 同源自审 + 下游 sample 组装崩」**。

**埋雷④ — 生成靠大量 retry 补漏，pipeline 脆（工程稳健性坑）**
- 目录里 `retry1-*` / `retry2-*` / `retry3-*` 全套 gen + judge 文件（`retry1-candidate-summary.json`:`candidates:128 missing:0`；`final-generation-merge-summary.json`:`retry3_missing:0 retry3_pass:9`）。
- 含义：初次生成有 missing/parse_errors/timeout（`raw-arkstd-rerun-timeout.jsonl` / `jobs-arkstd-rerun-timeout.jsonl` 存在），靠 3 轮 retry 才补齐到 0 missing。**gate7 design 必须把 retry/超时/parse-error 处理设进架构**（否则真跑时又是一堆 ad-hoc retry 脚本 = 惨败1「metadata/prose 声称 vs enforce」的工程版）。

### §1.3 反思结论（前教训 → gate7 design 铁律映射）

| 前一次的坑（一手证据） | gate7 design 铁律（§2-§4 落实） |
|---|---|
| 埋雷① 同源两模型互审（100% hermes） | 铁律A：**judge 必须跨【真厂商顶层边界】**，vendor 分类到「Anthropic / OpenAI / 火山-twofish(hermes) / …」层，同一托管方内两模型名不算异源（§3.2 + gate7-G1 门）|
| 埋雷② 多样性薄 mean 9.3 字 / 373 seed 只 1 变体 | 铁律B：**diversity gate 硬门**（长短句四类 + value-form + per-seed 下限），不是只按文本去重（§4.1）|
| 埋雷③ 0/34 是训练侧 sample bug 非 generator | 铁律C：**gate7 scope 严格 = 生成阶段**，不宣称解决 0/34；下游 sample 组装/masking 是 A2/P 系列的活（§0.3 边界）|
| 埋雷④ 靠 3 轮 ad-hoc retry 补漏 | 铁律D：**retry/超时/parse-error 是架构一等公民**（§3.4 生成器执行契约含 retry 策略 + 失败 receipt）|

---

## §2 三权分立架构 design（M2）

### §2.1 组件职责（三权 + 数据流）

```
                     ┌──────────────────────────────────────────────────────────┐
   真实种子锚点        │  C1 契约 SSOT: contracts/semantic-function-contract.jsonl  │
   (3990 语义, 191    │  (device × primitive × value 四件套; D-domain 具名工具)     │
    device, 562 intent│  → 只喂【语义协议】给云, 绝不喂原文语料 (D-040)             │
    10 族 scope)      └──────────────────────────────────────────────────────────┘
        │                          │ (seed = parent_semantic_id + 语义协议 prompt)
        ▼                          ▼
  ┌─────────────┐          ┌──────────────────┐         ┌───────────────────────┐
  │ ① GENERATOR │  产 utter │ ② LABEL-GOLD     │  标 tool │ ③ VALIDATOR-JUDGE     │
  │ 多源云 LLM   │─────────▶│ C1 契约          │◀────────│ 异源 LLM (跨真厂商)     │
  │ (Claude 主力/│  自然中文  │ deterministic    │ 审语义   │ 判 keep/reject+axis   │
  │  GPT-5.5/    │  utterance│ 出 tool_call     │ 正确性   │ 绝不改 label (D-043)   │
  │  Codex 低权/ │          │ (非 LLM, D-034)  │         │ judge≠generator家族    │
  │  GPT Pro 补难)│         └──────────────────┘         └───────────────────────┘
  └─────────────┘                  │                              │
        │                          │ (label 附加)                  │ (verdict 附加)
        └──────────────┬───────────┴──────────────────────────────┘
                       ▼
         ┌──────────────────────────────────────────────────┐
         │  ④ POST-GATE (确定性机器门, 非 LLM)                │
         │  redaction → label_conflict → dedupe/diversity   │
         │  → held-out 去污 (六轴 D-016) → OOD 分账          │
         │  → per-source/per-family coverage 报表            │
         └──────────────────────────────────────────────────┘
                       │ (全过 → 候选池 candidate)
                       ▼   (❌ 不进 train: R7 BLOCKED, 需 candidate signoff + run auth)
              [ candidate pool → (下游) C5DataGate → train-eligible ]
```

- **① generator**（`worker-1-data-decisions.md:47` D-032-A / `:60` D-068-A）：多源云 LLM，**只产中文 utterance 措辞**，**不产 tool-call JSON**（D-041-A：`worker-1-data-decisions.md` D-041「generator 只产中文 utterance，不产 tool-call JSON」防 name-last/wrapper 再错）。device slug/工具名/enum 一律由 codegen，generator 不改写（D-093/D-094）。
- **② label-gold**（`probe:48-49` / `worker-1-data-decisions.md:60` D-034-A）：从 C1 契约 **deterministic** 出 tool_call 标签。**label 权威 = C1 契约，非 LLM，非 judge**（D-034-A / D-043-A）。value-form 编码进 tool_name（`{verb}_{device}_{slot?}_{value_form}`，D-090/D-092），gold 稳定可复算。
- **③ validator-judge**（`probe:96-97` / `worker-1-data-decisions.md:51` D-036/D-037-A / `worker-1-data-round2.md:41` D-069-A）：**异源** LLM 审语义正确性 + 自然度 + OOD，输出**保留/拒绝 + 原因 axis，不改 label**（D-043-A）。
- **④ post-gate**（`probe:48-50` pipeline / `worker-1-data-decisions.md` D-038/D-045）：**确定性机器门**（非 LLM）——redaction / label_conflict / dedupe / diversity / held-out 去污 / OOD 分账 / coverage 报表。

🔴 **架构不变量（三权互斥，防惨败1「metadata 声称 vs enforce」）**：
- generator ⟂ label：generator 输出**进不了 label 字段**（label 只由 C1 契约填，§3.3 接口 schema 保证 generator 输出无 label 键）。
- judge ⟂ label：judge verdict schema **无 label 修改字段**（D-043-A / D-069-A：judge 只出 keep/reject/reason/axis）。
- 这两条互斥用**接口 schema 强制**（§3 每组件输入/输出 schema 物理隔离字段），不靠 prose 声称（8d 根因 = 声称层 vs 事实层脱节 `8d:69`）。

### §2.2 数据流分段（每段一等产物 + 谁产谁标谁审）

| 段 | 输入 | 处理方 | 输出（字段占位 schema，值 `<PLACEHOLDER>`） | cite |
|---|---|---|---|---|
| S1 seed | C1 contract row | 确定性（读 jsonl） | `{parent_semantic_id, semantic_protocol_prompt:"<PLACEHOLDER_semantic_only_no_raw>", scope_tier, family, value_type}` | D-040 `worker-1-data-decisions.md` D-040 |
| S2 gen | seed | generator 云 LLM | `{utterance:"<PLACEHOLDER_zh_utterance>", generator_model_id, generator_call_id, prompt_hash, variant, generator_source_vendor}` | D-032,D-042,D-074 |
| S3 label | utterance + seed | C1 契约 deterministic | `{expected_tool_call_signature:"<PLACEHOLDER_tool_sig>", tool_name, required_args_keys, value_form}` | D-034 `worker-1-data-decisions.md` D-034 |
| S4 judge | utterance + label | 异源 LLM | `{judge_model_id, judge_call_id, judge_verdict:"keep|reject", reject_reason_axis, semantic_ok, naturalness_score, ood_flag}` | D-036,D-043,D-073 |
| S5 post-gate | S2-S4 合并记录 | 确定性机器门 | `{redaction_ok, label_conflict, dedupe_group_id, diversity_axis_tags, heldout_collision, ood_bucket}` | D-038,D-045,D-016,D-055 |
| S6 candidate | 全过记录 | 确定性 | `{...全字段, gate7_status:"candidate"}` → **不进 train（R7）** | D-045,D-095 |

> 🔴 S2 `generator_source_vendor` 是 gate7 **新增关键字段**（前一次 data 只有 `generator_model_id` = 模型名，无法区分「hermes_glm / hermes_ark 同厂商」，导致埋雷①无法在门里 catch）。gate7 必须把 vendor 顶层身份显式化，让 gate7-G1 门能查「judge_vendor ≠ generator_vendor」。

---

## §3 模型池 + 异源 judge 协议 design（M3）

### §3.1 模型池 + 权重（⭐-default，D-032/D-039/D-068~071）

| 源 | 角色 | 权重 | vendor（顶层真厂商） | cite |
|---|---|---|---|---|
| **Claude** | 主力 generator（自然中文 paraphrase） | 高 | Anthropic | D-068-A `worker-1-data-round2.md:39`；D-033-A 第一刀主力 `worker-1-data-decisions.md:48` |
| **GPT-5.5** | 主力 generator + Claude 样本的**异源 judge** | 高（gen）/ judge | OpenAI 系 | D-069-A `worker-1-data-round2.md:40`；probe 结论2 `probe:126` |
| **Codex** | **低权重** generator（只产边界/结构化变体，不做口语主力） | 低 | OpenAI 系（偏代码） | D-070-A `worker-1-data-round2.md:41`；probe 负空间「Codex 偏代码，口语权重低」`probe:137` |
| **GPT Pro** | **只补难样本/长尾**，非唯一源 | 补充 | OpenAI 系（最巨） | D-071-A `worker-1-data-round2.md`；probe「最巨模型做难样本补充非唯一源」`probe:93`,`:129` |

- **capacity gap 缓解**（D-039-A / `probe:90`,`:93`）：**中等-强模型（Claude/GPT-5.5）主力**，GPT Pro 只补难样本。理由 = probe E5「curse of capacity gap:大 teacher 蒸更差 student」（`probe:70`）——但被「teacher 只产 hard utterance 文本 + label 由契约定，不学 teacher soft 分布」缓解（D-044-A / `probe:90`）。
- **起步规模**（D-033-A / `probe:138`,`:159`）：⭐**第一刀 Claude 主力 + GPT-5.5 异源 judge 两源起步**（不四源全开，防 probe 4d「过度工程化 ceremony」`probe:138`）；后续扩 Codex（边界）+ GPT Pro（难样本）。

> 🔴 **口径型分歧上报 commander（§6 grill 消减，磊哥拍）**：起步「两源」里的第二源用 **GPT-5.5** 还是别的？probe 写「Claude 主力 + GPT-5.5」（`probe:138`），但**GPT-5.5 与 Codex/GPT Pro 同属 OpenAI 系**——若 generator 用 Claude(Anthropic) + judge 用 GPT-5.5(OpenAI)，跨厂商成立✅；但若 generator 也想加 GPT-5.5 做第二 generator，则「GPT-5.5 既 gen 又 judge」需 D-069-A 明确「judge 只审【别的源】产的样本，不审自己产的」（自审仍是 self-bias）。**这条是执行细则口径，列选项上报**（见 §6）。

### §3.2 🔴 异源 judge 协议（核心，修埋雷①）

**judge 选型铁律（D-036/D-037，+ 埋雷①修法）**：
- **judge vendor ≠ generator vendor**（跨**真厂商顶层边界**，`worker-1-data-decisions.md:51` D-036-A「跨模型/跨家族」；D-037-A「非 Claude-family 优先做 Claude 生成样本 judge」`:52`）。
- 🔴 **vendor 定义到顶层托管方**（修埋雷①）：`Anthropic(Claude) / OpenAI系(GPT-5.5/Codex/GPT Pro) / 火山-twofish(hermes 系: glm, ark_standard)`。**同一托管方内两个模型名（如 hermes_glm vs hermes_ark_standard）不算异源**——这是前一次 100% same-family 的根因。gate7-G1 门查 `judge_source_vendor != generator_source_vendor` 用**顶层 vendor 枚举**，不用 model_id 字符串。
- judge **最小异源数**（D-072-A / `grill-decisions.md:394`）：solo demo 至少 **1 路异源 judge**，但必须**绑定语义维度**（不是「多路但审合规」安慰剂）。

**judge 打分维度**（D-036 + probe H2/H3 + D-073 taxonomy）：
| 维度 | 判什么 | 输出 |
|---|---|---|
| semantic_ok | utterance 语义是否匹配 seed 的 device×primitive×value | bool |
| naturalness | 是否自然口语（非模板/非代码味） | score 0-1 |
| label_consistency | utterance 意图与 C1 契约算出的 label 是否一致 | bool |
| ood_flag | 是否越出 10 族 scope（族外应转 unsupported，非误命中） | bool |

**judge 输出形态**（D-043-A `worker-1-data-decisions.md`）：judge **只判 keep/reject + reason_axis，不改 label**。reject 原因 taxonomy（D-073-A / `worker-1-data-round2.md`）**5 类枚举**：`semantic_wrong / value_wrong / style_too_complex / policy_leak / near_duplicate`（free-text 不进 gate，防 prose 混入）。

### §3.3 仲裁规则（judge 分歧怎么收，M3 + §6 teardown 去扩散）

> probe 未直接给「多 judge 分歧仲裁」规则（`probe:145` 只留「评测集 gold 是否需 LLM」待解之问）。本节 teardown 补——**design 有模糊点必深挖 probe 一手 + pre-mortem，不拍脑袋**（SPEC §6 铁律）。

分诊：仲裁分两种情况——
1. **单 judge 制（起步两源，D-072「至少 1 路异源 judge」）**：无分歧问题，judge=keep 则保留、reject 则按 axis 丢弃。**起步默认单异源 judge**（`grill-decisions.md:394` Gap3「异源 receipt ≥1」）。
2. **多 judge 制（扩展后，可选）**：若后续加第二异源 judge，仲裁规则（⭐-default，上报 commander 确认）：
   - **保留 = 全 judge 一致 keep**（AND 语义，从严）。理由 = probe pre-mortem「eval 污染宁可从严过滤」+ Self-Instruct「generate-then-filter 丢弃~58%」（`probe:73` E8）——训练集宁缺毋滥。
   - **任一 judge reject → 该条进 quarantine**（不训，D-027-A quarantine 永不训练 `worker-1-data-decisions.md:42`），记录哪个 judge 因何 axis reject。
   - **judge 分歧率（keep/reject 不一致比例）进 receipt**（作为 judge 质量监控 axis，防某 judge 失守）。
- 🔴 **仲裁绝不由 generator 家族的 judge 主导**（D-037-A）：多 judge 时，跨厂商那一路 judge 的 reject 具**否决权**（veto），同厂商 judge 的 keep 不能覆盖异源 judge 的 reject。

### §3.4 生成器执行契约（retry/超时/parse-error，修埋雷④）

> 前一次靠 3 轮 ad-hoc retry 补漏（§1.2 埋雷④）。gate7 把这些设进架构（design-only，不写可运行代码）：

- **retry 策略**（design）：每 generator call 有 `max_retries` + `timeout`；missing / parse_error / timeout 的 seed 进 retry 队列，retry 用**不同 variant seed**（避免同 prompt 反复超时）。
- **parse gate**：generator 输出必须是**纯中文 utterance 字符串**（D-041：不产 JSON）；若模型误产 JSON/markdown/解释 → parse_error，进 retry，**不进候选**。
- **失败 receipt**（呼应 D-030 receipt 必备字段 `worker-1-data-decisions.md:44` / claim-vs-reality「机械操作实跑非推理」）：每 seed 记 `{gen_status: ok|missing|parse_error|timeout, retry_count, final_source_vendor}`；retry 用尽仍失败的 seed 显式标 `unfilled`，**不静默吞**（防惨败1「default 吞错」）。

---

## §4 diversity / dedup / 去污门 design（M4，确定性机器门）

> 🔴 全部**确定性机器门（非 LLM）**——judge 出 finding（软），机器门做 pass/block（硬），呼应 `visual-acceptance`「几何走确定性机器门、VLM 只出 finding」同源纪律 + 8d P3「grouping key 用实际 prompt 文本非 metadata」（`8d:99`）。

### §4.1 diversity 门（修埋雷②，D-078/D-079/D-080）

- **族内覆盖**（D-078-A `worker-1-data-round2.md:49`）：每个 10 族都报 `device/tool/value/template/source` coverage，**不只全局报**（防某族全空但全局好看，8d:88 聚合数误导）。
- **value-form 覆盖**（D-079-A `worker-1-data-round2.md:50`）：每 tool family 至少覆盖 SPOT / EXP / PERCENT 或明确标 N/A（防「只会打开/关闭不会参数规划」——正是埋雷②「mean 9.3 字祈使句」的病）。
- **长短句覆盖**（D-080-A `worker-1-data-round2.md:51`）：`short_imperative / ellipsis / polite / context_followup` 四类都标 + 都有量（前一次全是 short_imperative，缺后三类）。
- **diversity 硬门判据**（⭐-default）：族内任一维度 coverage=0（该族该维度零样本）→ **block 该族扩量**，先补齐再放行。度量落 receipt 分轴（D-042 generator_source axis + D-078 族内 axis）。

### §4.2 dedupe 门（D-076/D-077）

- **文本粒度三键**（D-076-A `worker-1-data-round2.md:47`）：`normalized_utterance + slot_skeleton + tool_signature` 三键去重（不只 exact text——前一次 `pattern_class=softened_imperative / normalized_template=PH_DEVICE_ACTION / hash8_pair=0a5e5b6b,656d16a3` 这类近重复应被 catch）。
- **语义粒度**（D-077-A `worker-1-data-round2.md:48`）：同 `parent + tool + value_type + slot值` 等价 → 近重复（防 value 等价样本穿过 held-out）。
- **per-seed 上限**（D-075-A `worker-1-data-round2.md:46` / `probe:59`）：每 seed 每 generator ≤2，总候选 ≤8（防单 seed 风格淹没 + 死记）。

### §4.3 🔴 去污门（held-out 六轴，D-016/D-046~055，修「训练集污染评测」惨败1 pre-mortem#1）

> probe pre-mortem#1「评测集被 generator 污染 → 评测虚高真机翻车」（`probe:101`）是 0/34 灾难的孪生风险。去污门是 gate7 的生死门。

- **六轴 held-out 硬切**（D-016-A `worker-1-data-decisions.md:31` / D-046-A `worker-1-data-round2.md:17`）：`parent_semantic_id + device + tool_name + value_type + template_family + generator_source` **六轴都做 hard split**（当前代码只 parent 级 overlap `Core/Bench/C5DataGate.swift:252,282`，六轴未实装——landing-matrix.md:21 标 ❌）。
- **去污规则**（gate7 生成的 utterance 不得撞下游 held-out / C6 release）：
  - 生成的候选 utterance **不得与 gate5 六轴 held-out 集碰撞**（D-016 held-out 是 C5DataGate 侧的隔离；gate7 生成前先读 held-out 的 parent/tool/value keys，**同 key 的不生成或生成后 quarantine**，D-054-A 近邻污染 `worker-1-data-round2.md:25`）。
  - 生成的候选 **不得撞 C6 release final-only case**（呼应 SPEC §3「C6 release final-only AD-C6-003」；C6 评测 gold 规则锚定 + 人审，generator 绝不碰 `worker-1-data-decisions.md:50` D-035-A）。
- **近邻污染**（D-054-A `worker-1-data-round2.md:25`）：训练候选若与 held-out **同 parent + 同 tool + 同 value_type 只换话术** → **quarantine**（不训），不是「只文本相同才删」。
- **OOD 分账**（D-055-A `worker-1-data-round2.md:26`）：`leakage-heldout`（管泄漏）与 `OOD smoke`（管绕弯说法）**分两账**，不混一个 held-out（防 in-distribution 飘绿但现场 OOD 全塌）。

### §4.4 redaction 门（红线，D-040/D-081~084）

- **输入侧**（D-040-A `worker-1-data-decisions.md`）：喂云 generator 的 prompt **只含 device×primitive×value 语义协议**，**绝不喂 raw 原文语料 / 12000 bug 原文 / PII**（`probe:134`,`:137`,`:162` 红线）。
- **扫描范围**（D-081-A `worker-1-data-round2.md`）：`inputText + assistantText + prompt_hash source text` 都扫（当前只扫 inputText/assistantText `Core/Bench/C5DataGate.swift:436-437`）。
- **词表分级**（D-082-A / D-083-A `worker-1-data-round2.md`）：P0 secret/PII/禁止外传、P1 客户/车型/报价同义、P2 内部流程词（当前词表窄 `:439-447`，需扩报价/价格/成本/合同/客户名/项目名/手机号变体 + 英文 secret 类）。
- **顺序**（D-084-A `worker-1-data-round2.md`）：**先 redaction 后 generator，generator 输出再 redaction**（双向扫，防敏感输入进云 or 敏感输出进 train）。redaction violation = **P0 block**（`Core/Bench/C5DataGate.swift:301`）。

---

## §5 fixture 验证计划（M5，🔴 字段占位无真话术，design-only）

> 🔴🔴 **R7 边界（本节最敏感）**：fixture **只写字段结构/schema 占位**（值 `<PLACEHOLDER>`），**绝不填真实中文话术**。**将来怎么验此 pipeline 而不真跑生成** = 用占位 fixture 走通三权流程的 dry-run 测试设计。
> **`R7: real cloud generation run BLOCKED until candidate signoff + run auth；fixture 仅字段占位无真话术`**（`R7-final-route-deframing-signoff.md:20-29`）。

### §5.1 fixture schema（字段骨架，值全 `<PLACEHOLDER>`）

**seed fixture**（S1，不含 raw）：
```json
{
  "parent_semantic_id": "<PLACEHOLDER_semantic_id>",
  "contract_row_id": "<PLACEHOLDER_c1_row_id>",
  "family": "<PLACEHOLDER_one_of_10_families>",
  "scope_tier": "<PLACEHOLDER_compact_positive|long_tail|unsupported>",
  "value_type": "<PLACEHOLDER_SPOT|EXP|PERCENT>",
  "semantic_protocol_prompt": "<PLACEHOLDER_semantic_only_device_primitive_value_NO_RAW_NO_utterance>"
}
```

**generator-output fixture**（S2，🔴 utterance 是占位不是真话术）：
```json
{
  "utterance": "<PLACEHOLDER_zh_utterance_NO_REAL_TEXT>",
  "generator_model_id": "<PLACEHOLDER_model_name>",
  "generator_source_vendor": "<PLACEHOLDER_Anthropic|OpenAI|Volc-twofish>",
  "generator_call_id": "<PLACEHOLDER_call_id>",
  "prompt_hash": "<PLACEHOLDER_sha256>",
  "variant": "<PLACEHOLDER_int>"
}
```

**label fixture**（S3，C1 契约算，占位）：
```json
{
  "expected_tool_call_signature": "<PLACEHOLDER_tool_sig>",
  "tool_name": "<PLACEHOLDER_verb_device_slot_valueform>",
  "required_args_keys": ["<PLACEHOLDER_arg_key>"],
  "value_form": "<PLACEHOLDER_to_number|to_max|by_exp|no_value>"
}
```

**judge-verdict fixture**（S4，异源，占位）：
```json
{
  "judge_model_id": "<PLACEHOLDER_model_name>",
  "judge_source_vendor": "<PLACEHOLDER_MUST_DIFFER_FROM_generator_source_vendor>",
  "judge_call_id": "<PLACEHOLDER_call_id>",
  "judge_verdict": "<PLACEHOLDER_keep|reject>",
  "reject_reason_axis": "<PLACEHOLDER_semantic_wrong|value_wrong|style_too_complex|policy_leak|near_duplicate>",
  "semantic_ok": "<PLACEHOLDER_bool>",
  "naturalness_score": "<PLACEHOLDER_0_to_1>",
  "label_consistency": "<PLACEHOLDER_bool>",
  "ood_flag": "<PLACEHOLDER_bool>"
}
```

**post-gate fixture**（S5，确定性门，占位）：
```json
{
  "redaction_ok": "<PLACEHOLDER_bool>",
  "label_conflict": "<PLACEHOLDER_bool>",
  "dedupe_group_id": "<PLACEHOLDER_group_id>",
  "diversity_axis_tags": {"family":"<PH>","value_form":"<PH>","sentence_style":"<PH>","source_vendor":"<PH>"},
  "heldout_collision": "<PLACEHOLDER_bool>",
  "ood_bucket": "<PLACEHOLDER_leakage_heldout|ood_smoke|in_dist>"
}
```

### §5.2 dry-run 验证设计（用占位 fixture 走门，不真跑生成）

> 🔴 dry-run = **喂占位 fixture 记录进【确定性机器门】验门逻辑**，**不调云 LLM、不产真 utterance**。judge 段在 dry-run 里用**预置 verdict fixture**（占位 keep/reject），不真调 judge。

| 验证项 | fixture 构造（占位） | 期望门行为 | 对应门 |
|---|---|---|---|
| V1 异源判定 | judge_vendor == generator_vendor（都 `<PH_Volc-twofish>`）| gate7-G1 **block**（同厂商 self-judge）| §3.2 铁律A（正是埋雷①的回归 fixture）|
| V2 label 互斥 | generator-output fixture 里塞一个 `label` 键 | schema reject（generator 不得含 label）| §2.1 不变量 |
| V3 judge 不改 label | judge-verdict fixture 里塞 `label` 修改键 | schema reject（judge 只出 verdict）| D-043 |
| V4 diversity 空轴 | 某族 value_form 全 `<PH_SPOT>` 无 EXP/PERCENT | diversity 门 block 该族扩量 | §4.1 |
| V5 dedupe 近重复 | 两条 normalized_utterance 占位相同 slot_skeleton | dedupe 合并同 group | §4.2 |
| V6 held-out 撞车 | heldout_collision=true 占位 | quarantine（不进候选）| §4.3 |
| V7 redaction | inputText 占位含 `<PH_P0_secret_token>` | P0 block | §4.4 |
| V8 retry 失败不吞 | gen_status=`<PH_timeout>` retry 用尽 | 标 unfilled，不静默丢 | §3.4 |

- **验收判据**：8 个 dry-run 门用例**全部按期望 pass/block**（尤其 V1 = 埋雷①的机器门回归）。
- 🔴 **fixture 里没有一条真中文话术**（utterance 全 `<PLACEHOLDER_zh_utterance_NO_REAL_TEXT>`）——门逻辑只看字段结构/枚举/bool，不看话术内容，所以占位足够验门。**真跑生成（真调云产真 utterance）= R7 BLOCKED，须 candidate signoff + run auth 后另立**（D-095-A「50 条拍板后先转 spec/gate，不直接生成数据」`worker-1-data-round2.md`）。

---

## §6 pre-mortem 段（M6，tiger/paper-tiger/elephant，带依据）

> pre-mortem = 此 pipeline「6 个月后灾难性失败」搜坑（`probe:100-105` 基础 + gate7 新增）。

### 🐯 tiger（明确威胁，带验证清单）

| # | tiger | 依据 | 验证清单（真跑前必查）|
|---|---|---|---|
| T1 | **judge 同源自审失守**（埋雷①重演：以为跨厂商实为同托管方两模型）| 前一次 100% same hermes family（§1.2 复算）；probe E3 preference leakage `probe:68`；D-036/D-037 `worker-1-data-decisions.md:51-52` | gate7-G1 门：`judge_source_vendor != generator_source_vendor` 用顶层 vendor 枚举复算，不用 model_id 字符串。dry-run V1 必 block |
| T2 | **训练集污染评测（held-out 泄漏）→ 评测虚高真机翻车** | probe pre-mortem#1 `probe:101`；D-016 六轴 `worker-1-data-decisions.md:31`；当前只 parent 级 `Core/Bench/C5DataGate.swift:282` | 六轴 held-out hard split 实装 + 近邻污染 quarantine（D-054）+ dry-run V6 |
| T3 | **单源同质化 / 多样性薄**（埋雷②：mean 9.3 字祈使句尾部收窄）| §1.2 复算 373 seed 只 1 变体；probe pre-mortem#2 `probe:102`；E7 collapse `probe:72` | diversity 硬门（族内 + value-form + 长短句四类，D-078~080）+ 多源占比 report + dry-run V4 |
| T4 | **格式污染**（各厂商 tool-call 格式渗入，name-last 类事故）| probe pre-mortem#3 `probe:103`；8d name-last `8d:62`；D-041 generator 只产中文不产 JSON | generator 输出 = 纯中文 utterance（parse gate 拒 JSON/markdown）；label 走 C1 契约渲染，name-first（8d P4 `8d:100`）|
| T5 | **capacity gap**（teacher 太强产 1.7B 学不动的复杂长句）| probe E5 `probe:70`；pre-mortem#4 `probe:104`；D-039/D-071 | 主力中等-强（Claude/GPT-5.5），GPT Pro 只补难；judge naturalness/style_too_complex axis 过滤长句 |

### 🐘 paper-tiger（看似威胁实际安全，给证据）

| # | paper-tiger | 为什么实际安全（证据）|
|---|---|---|
| P1 | 「云 generator 产数据 = 数据出境红线」 | 产的是**合成话术变体**（非原文语料/PII），喂云的 prompt 只含**语义协议**（device×primitive×value），不喂原文（`probe:134`,D-040-A）；redaction 双向门兜底（§4.4）。红线不破。|
| P2 | 「label 靠 LLM 会漂移」 | label **不靠 LLM**——由 C1 契约 deterministic 出（D-034-A `probe:48-49`）；generator/judge 都碰不到 label（§2.1 互斥不变量）。label 稳定可复算。|
| P3 | 「多模型编排 = 过度工程 ceremony 过重」 | **起步只两源**（Claude 主力 + GPT-5.5 异源 judge，D-033-A `probe:138`），不四源全开；扩量是 trainable_v0 才需要（probe 少数派 `probe:142`）。solo demo 轻治理。|

### 🦣 elephant（没人提但该提）

| # | elephant | 为什么该提 |
|---|---|---|
| E1 | 🔴 **「0 条自然中文」措辞误导：gate7 修不了 0/34**（埋雷③）| SPEC §0 把 0/34 归因「0 条自然中文」，但一手 data 证明 gate7 阶段产了 4306 条中文（§1.2 埋雷③）；0/34 真根因在**训练侧 sample 组装**（假删工具 `8d:51` / name-last `8d:62`），是 A2/P1-P9 的活。**gate7 别背 0/34 的锅、也别宣称能单独解决它**（8d:68 纪律）。上报 commander 重述惨败1 措辞。|
| E2 | **judge 自身也可能被 self-bias（judge 质量无监控）** | 前一次 judge 是 hermes 内两模型，无「judge 质量 axis」监控。gate7 应记 **judge 分歧率 + reject axis 分布**进 receipt（§3.3），否则某 judge 失守（乱 keep）无人发现——8d 审计盲区「审合规不审语义」`8d:80` 的孪生。|
| E3 | **fixture 验证只验门逻辑，验不了「真 utterance 质量」** | dry-run 用占位 fixture 只能验门的 pass/block 逻辑，**验不了真产的 utterance 自不自然**（占位无话术）。真跑后仍需 judge naturalness + 人抽审（这是 R7 gate 之后的活，不是 fixture 能覆盖的）。别把「dry-run 8 门全过」当「pipeline 会产好数据」（claim-vs-reality「fixture 门过≠真跑成功」同源）。|
| E4 | **gate7 scope 与 A2 D-domain surface 强耦合但本任务不碰 A2** | label 走 D-domain 具名工具（D-090~094），但 A2 surface 重构是另一条线。gate7 design 假设 A2 已把 surface codegen 好；若 A2 未落，gate7 的 label deterministic 会踩到旧 generic frame。上报：gate7 真跑前置 = A2 D-domain surface 已 codegen（依赖，非 gate7 内解决）。|

---

## §7 teardown 去扩散 + grill 消减记录（SPEC §6 铁律）

> 遇模糊点深挖 probe 一手 + pre-mortem，不简化绕过；扩散出的子方案消减到 ⭐ + 理由。

| 模糊点 | 扩散的子方案 | 消减动作 | ⭐ 结论 + 理由 |
|---|---|---|---|
| judge 仲裁规则（probe 未给，`probe:145` 待解之问）| 单judge / 多judge-AND / 多judge-OR / veto | **merge**：起步单异源 judge（D-072 至少1路），扩展才多judge | ⭐ 起步单异源 judge；多judge 时 AND(从严) + 异源 veto（§3.3）。理由 = 训练集宁缺毋滥（E8 丢弃58% `probe:73`）|
| 「异源」定义（埋雷①暴露 model_id 不够）| model_id 不同 / family 不同 / 顶层 vendor 不同 | **locked**：顶层 vendor 枚举 | ⭐ vendor 定义到顶层托管方（Anthropic/OpenAI/Volc-twofish），同托管方两模型不算异源（§3.2）。理由 = 前一次 100% same hermes 铁证 |
| capacity gap 怎么补 | 全弱 / 全强 / 中强主力+最巨补难 | **locked**：D-039-A | ⭐ 中等-强主力 + GPT Pro 只补难样本。理由 = probe E5 + hard-data 缓解 `probe:90` |
| 去污 key 粒度 | 只 parent / 六轴 / 文本 embedding | **locked**：D-016 六轴 | ⭐ 六轴 hard split（parent+device+tool+value+template+source）+ 近邻 quarantine。理由 = D-016-A + probe pre-mortem#1 |
| 起步第二源用谁（口径型，上报磊哥）| GPT-5.5 / Codex / GPT Pro | **defer 上报**：列选项 §6-Q1 | ⭐-default GPT-5.5（probe:138），但「GPT-5.5 既 gen 又 judge 是否 self-bias」需磊哥/commander 拍 |

### 🔴 口径型分歧（磊哥 2026-07-01 已拍 ✅ = D-008）

> ✅ **磊哥拍板（2026-07-01「同意」）**：**Q1 = A**（Claude generator 主力[Anthropic] + GPT-5.5 纯异源 judge[OpenAI]，跨厂商干净修埋雷①）；**Q2 = A**（惨败1 措辞在 gate7 语境重述为「自然中文虽有但薄 + 同源自审 100% hermes + 下游 sample 组装崩」，gate7 别背 0/34 锅）。
> 🔴 **nuance（commander 补，别过度修正）**：「**训练集** 0 条自然中文」对【训练集本身】准确（训练用了协议串 `C5LoRATraining:1767`）；Q2 修正的是别把它误读成「生成阶段产不出中文」——一手 data 证明**生成阶段真产了 4306 条中文**（§1.2 埋雷③）。两个不同 pipeline 阶段，不矛盾。历史研究档（c5-superaudit 等）的「训练集 0 条自然中文」保持不动（对训练集准确）。

**（以下为拍板前的选项记录，留档）**

**Q1（执行细则口径）**：起步「两源」的第二源 GPT-5.5，其角色边界？
- **A（⭐-default）**：Claude = generator 主力（Anthropic），GPT-5.5 = **纯异源 judge**（OpenAI）——跨厂商干净，无 self-bias。（probe:138 原义）
- **B**：Claude + GPT-5.5 **都做 generator**（双源产），judge 另找第三方——diversity 更高但 judge 源需第三厂商，起步就三源（略重）。
- **C**：GPT-5.5 既 generator 又 judge，但 judge 只审【Claude 产的】不审自己产的（D-069-A 精神）——省源但 GPT-5.5 判自己那批时仍 self-bias。
- 理由：A 最干净合 probe 起步意图 + 修埋雷①；B/C 涉及「同模型多角色」的 self-bias 边界，属口径选择。**上报磊哥拍**。

**Q2（口径）**：「0 条自然中文」措辞（elephant E1）是否重述？
- gate7 一手 data 证明生成阶段产了 4306 条中文，0/34 真因在训练侧 sample 组装。建议惨败1 措辞在 gate7 语境重述为「**自然中文虽有但薄（mean 9.3 字/373 seed 单变体）+ 同源自审（100% hermes）+ 下游 sample 组装崩**」。**上报 commander 确认是否回写惨败1 描述**（避免 gate7 背 0/34 锅 / 宣称能单独解决 0/34）。

---

## §8 cite 清单（load-bearing 决策 → 一手 file:line）

**probe（三权分立结论源，`docs/research/2026-06-21-c5-generator-selection-probe.md`）**：
- 三权分立 pipeline：`:46-52`；label=C1 deterministic：`:48-49`,`:122`；eval gold 规则锚定 generator 不碰：`:41`,`:52-53`
- 多源>单源 E6：`:71`；self-preference E1：`:66`；preference leakage E3：`:68`；benchmark self-bias E4：`:69`；capacity gap E5：`:70`；model collapse E7：`:72`；丢弃58% E8：`:73`
- 结论2 多源云 Codex 低权：`:126`,`:132`,`:137`；起步两源：`:138`,`:159`；capacity gap 缓解：`:90`,`:93`,`:129`
- 红线只喂语义协议：`:134`,`:137`,`:162`；pre-mortem 四坑：`:101-104`；待解之问（judge 仲裁）：`:145`

**D-031~095（`worker-1-data-decisions.md` D-031~045 / `worker-1-data-round2.md` D-046~095）**：
- D-031 三权分立 `worker-1-data-decisions.md:46`；D-032 模型池 `:47`；D-033 起步两源 `:48`；D-034 label 权威 `:60`；D-035 eval gold `:60`；D-036 异源 judge `:51`；D-037 judge 家族 `:52`；D-038 diversity `:60`；D-040 cloud prompt `:60`；D-041 vendor 格式 `:60`；D-042 source 记录 `:60`；D-043 judge 输出 `:60`；D-044 hard-data `:60`；D-045 第一轮验收门 `:60`
- D-016 六轴 held-out `worker-1-data-decisions.md:31`；D-027 quarantine `:42`
- D-046 六轴 `worker-1-data-round2.md:17`；D-054 近邻污染 `:25`；D-055 OOD 分账 `:26`；D-068 Claude 分工 `:39`；D-069 GPT-5.5 judge `:40`；D-070 Codex 权重 `:41`；D-072 judge 最小异源 `:43`；D-073 reject taxonomy `:44`；D-074 prompt hash `:45`；D-075 per-seed 上限 `:46`；D-076/D-077 dedupe `:47-48`；D-078/D-079/D-080 diversity `:49-51`；D-081~084 redaction；D-090~094 D-domain 命名 codegen；D-095 前置门

**8d 根因（`docs/c5-recovery-2026-06-22/8d-rootcause.md`，均为 8d 文档行号；⚠️ 8d 引的 pre-A2 源码行号 `:2333/:2407/:1942` A2 后已漂移，以 8d 文档记录为准）**：
- 假删工具（8d 记录）`8d:50-53`；name-last `8d:62`；tool surface 分叉 `8d:63`；两套 scorer `8d:64`；empty=hit `8d:65`；声称vs事实脱节 `8d:68`；范式/scale 不宣称已排除 `8d:68`；grouping key 用实际文本 `8d:99`；审合规不审语义 `8d:80`；聚合数误导 `8d:88`；P4 name-first `8d:100`；P3/P7 修法 `8d:99`,`8d:103`

**前一次实际产物（`Reports/c5-remediation-wave-20260621T2013-pr3-full/`，复算一手）**：
- 4500 pass：`final-generation-merge-summary.json`；字段结构：`generated-utterances-final.jsonl:1`；100% same hermes family：复算 4500/4500；mean 9.3 字 / 373 seed 单变体：复算 per-seed 分布；receipt 物理字段：`Core/Training/C5LoRATraining.swift:2357-2359`

**R7 边界（`docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md`）**：`:20-29`,`:126`

---

## §9 守 R7 声明（收口）

- ✅ **design/spec-only**：本文只产 design 文档 + 不可运行 schema/伪代码占位。
- ✅ **未 run 任何生成**：没调任何云 LLM，没产一条 utterance。
- ✅ **未产训练数据/语料**：fixture 全部 `<PLACEHOLDER>`，**无一条真中文话术**（V1-V8 dry-run 用例的 utterance 字段全 `<PLACEHOLDER_zh_utterance_NO_REAL_TEXT>`）。
- ✅ **只读一手源复算**：前一次 data 的复算是只读（`Reports/` 目录读，无写无改）。
- 🔴 `R7: real cloud generation run BLOCKED until candidate signoff + run auth；fixture 仅字段占位无真话术`。
- 🔴 未决口径型分歧（§6 Q1/Q2）→ **磊哥已拍 D-008**（Q1-A GPT-5.5 纯异源 judge / Q2-A 口径重述）。

---

## §10 grounded round landing（D-010 locked，2026-07-01 磊哥「全部同意」）

> grounded grill round（本 session 经验发现驱动，110 决策，`docs/c5-training-readiness-grill/SYNTHESIS-grounded-round.md`）净新载力 ⭐ 已 locked，回写进本 design。

### §10.1 vendor-enum 异源 G1 门（A-096/097 locked，确认 §3.2）
§3.2 顶层 vendor 枚举（Anthropic/OpenAI/Volc-twofish）+ G1 门 `judge_source_vendor≠generator_source_vendor` = **A-096/097 locked** 确认。补：G1 receipt 记 `same_vendor_count/total/same_vendor_pct`（A-101）；unknown/empty vendor 直接 block（A-099）。

### §10.2 bug-derived precision 门（E-098/129 locked，新增）
WS2 bug shortlist（1730/4053）= 弱监督非 gold → 新增 precision 门：每族 min(50,max(20,10%候选)) 人审、小族全审，**precision<0.8 该族不扩量**；任一族 redaction fail / judge reject axis 单项>20% / heldout collision>0 即停该族（E-129）。bug 候选**默认 quarantine**，过 precision+redaction+label-gold 才转候选（E-096/121）。

### §10.3 source tags（E-128 / D-125 locked，S2/S5 字段新增）
S2/S5 fixture 加 bug 溯源字段：`source=bug_derived_pattern` / `raw_source_redacted=true` / `raw_text_absent=true` / `ws2_family` / `ws2_failure_mode`（E-128）；配比来源 `quota_source=intent|bug|scene|recovery`（D-125）——防审计无法区分 raw bug / 派生 pattern / 合成 utterance。

### §10.4 生成配比（D-096~125 locked，喂真生成，R7 BLOCKED）
每族每类 quota = intent 基线 + bug 压力 + demo/安全地板混合公式（D-096）；🔴 **bug 多 ≠ 多训 positive**（音量/屏幕 bug 多是 failure/refusal，屏幕黑屏→failure 不→调亮度 positive，D-097/E-109/E-110）；稀疏族地板 + scene-trigger（雨刮 12/天窗 34 不砍，靠「下雨了」场景，D-098/E-113）；followup 屏幕/音量补 scene-derived 标 source 不伪造 transition lineage（D-102/117）。🔴 这是**真生成时的配比**，R7 BLOCKED 不现在跑。

### §10.5 bug 失败模式→C6 层映射（E-100~130 locked，喂 C6 eval）
809 执行失败→failure receipt/C6 trap **不入 action train**（E-100/124）；415 多意图→C6 multi-action trap（E-102）；380 unsupported→no-call/refusal（E-104）；234 clarify→demo_fuzz clarify（E-106）；97 口语体感词→自然中文 positive/clarify 按 value-form（E-107）；58 safety→safety layer 一票否决（E-108）。bug→C6 四层默认矩阵见 E-115。

### §10.6 旧 3804 复用（M4 reconcile locked）
旧 3804 utterance **TEXT 可作 recovery candidate**（逐条重过 redaction/label_conflict/diversity/**新 vendor-enum 异源 judge**/六轴 held-out，D-103），但**旧 hermes judge verdict 作废**（假异源 100% same-vendor 不可信，A-131）→ 不吃旧 verdict、全部重判。旧 696 非 10 族只进 unsupported candidate 或丢（D-104）；旧样本不喂新 cloud prompt（D-105）。

### §10.7 R7 边界（不变）
🔴 grounded round lock 的是 **grill 决策 + design 回写**，**真生成/真训练仍 BLOCKED**（candidate signoff + run auth 才 lift）。gate7 scope = 生成阶段，**别背 0/34 训练侧锅**（E-117/F-049）。
