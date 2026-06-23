# Handoff 六件套 — 范式翻案(generic frame→D-domain 具名工具) + demo 特性 + 第一批 grill（2026-06-22 深夜）

> 本 session = θ-α 0/23 FAIL 处理 → **范式翻案（重大里程碑）** → demo 5 特性料头 → G4 边界 → 第一批 5 grill 拍板 → 存档级联。下个 session 继续第二批 5 grill。

---

## 件 1 — 状态指针 + 起手必读

- **当前态**：C5 recovery **范式翻案完成**，第一批 5 grill 拍板，**第二批 5 grill（6-10）待下 session 拍**（件 6 已备选项+推荐，直接可拍）。
- **起手必读顺序**：`CLAUDE.md §9 banner`（范式翻案）→ **⭐`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md §1-§13`（范式权威，本轮唯一权威源）** → 本 handoff 件 6（第二批 grill）。
- **一句话锚**：model-visible surface = **D-domain 具名工具**（generic frame 否决，但 canonical IR 仍 device×action）；demo = **MVP 10 族 + 单语中文 + 现场只说 10 族**。
- **HEAD**：`c4a7d1a`（codex θ-α wave）；本 session 全是 docs/amend/CLAUDE/MEMORY 文档更新，无代码改。

---

## 件 2 — 本 session 核心成果（范式翻案全景，详细）

### 2.1 起点：θ-α 0/23 FAIL（codex 全量训练崩塌）
- codex 全量 600-iter 训练 health 健康（val_loss 4.4→0.589），但 C6 **全 checkpoint FAIL**：iter100=0/23(乱调坍缩 set_cabin_ac)、iter400/600=0/23(全静默)。
- 根因下钻**三次翻转**（claim-vs-reality 活教材）：① gate_result tcm/sdm（tcm=0）→ ② 训练数据 assistant 全吐 `tool_call_frame` → ③ 模型实际吐 set_cabin_ac（D-domain）+ base 多样 7 种 → 钉死「训练 generic frame / eval D-domain surface mismatch + zero-negative collapse 叠加」。

### 2.2 范式翻案（核心里程碑，第4源 ground-truth）
- 派 subagent teardown 真实座舱 **TOP技能表FC + 交付手册**（`docs/research/2026-06-22-top-fc-skill-table-teardown/`）。
- 🔴 **坐实：真实座舱 = D-domain 极致密集具名工具（2045 个，intent==工具名，value 形态编码进名 `adjust_ac_temperature_to_max`）**，generic frame 被否决（理由：value 形态塞单一 action 参数→小模型判定面爆炸误吸高；具名工具=选对工具即选对 value 形态+受限解码约束）。
- **推翻 CC+GLM 的 B-frame 倾向**。θ-α 0/23 更深根因 = **generic frame 范式本身错（判定面爆炸）**，非只 surface mismatch。
- **三层模型定型**（codex 方向）：① canonical IR = device×action×value（保留）② model-visible surface = **D-domain 具名工具**（翻案）③ runtime tier = MVP 10 族 mock / 其余 unsupported。
- 措辞校准（codex catch）：「B-frame 否决」精确 = **generic frame 作 surface 否决，IR 仍 device×action**（「对模型像 D 具名工具，对系统像 IR」）。

### 2.3 demo 投机取巧（量产 ≠ demo）
- 哲学 = **借量产降误吸内核（具名工具拆判定面+受限解码）+ 砍量产全链路（FC→NLU→DS→DM/真控/2045工具）+ 加炸场包装（剧本/mock视觉/兜底）**。
- 🔴 磊哥终极约束：**现场只说 10 族 + 提前沟通** → 用演示约定消除全集鲁棒性需求（不做全集泛化兜底/动态选包）。
- 统一表述：**「10 族内自由说，族外边界沟通 + unsupported 兜底」**（覆盖旧「全集泛化」表达）。

### 2.4 G4 边界（subagent，磊哥拍我 subagent）
- 权威 = `docs/research/2026-06-22-mvp-10family-device-boundary.md`：10 族 explicit allowlist = **191 device / 562 intent / 2159 行（54.1% 全集）**（非 naive 误命中 422/397）。族外 480 device → unsupported tier。
- A1-A9 device 歧义全按 ⭐ 裁决，**A4 方向盘加热 = 磊哥拍展示层并座椅（技术层独立 device）、A5 HUD 不做（纯族外）**。

### 2.5 demo 5 特性 + LoRA 四类数据
| 特性 | demo 做法 | LoRA 数据类 |
|---|---|---|
| 模糊说（感受词→value）| LoRA 核心，10 族 EXP(734)，云 paraphrase 不定标签 | `single_tool_fuzzy_positive` |
| 短时记忆+歧义指代 | DialogueState 3 轮继承+反问（砍长时云），second_turn_refs(427) | `followup_rewrite` + clarify |
| 多意图 | 连续两句 splitter 拆两单跳 FC | `bounded_multi_intent_split` |
| 复杂推理 | 🔴**预留场景宏**（磊哥要真做但 1.7B 难，LoRA 学推理后续升级）| (预留 `complex_reasoning_multi_tool`) |
| 安全门 | 行驶中开门拒识/确认 | `unsupported/safety_refusal` |

→ 短期 LoRA **四类**（positive/followup/unsupported/safety+distractor-in-prompt 构造）。

### 2.6 多语种约束（磊哥点名，影响全链路）
- **LoRA 只训单语基础语义中文**，多语种 = `ASR(多语种)→NLU(转基础语义)→LoRA(单语)→协议转换` 复用（非重训），印证交付手册「协议转换适配器=语言无关层」。

### 2.7 过度工程化 catch（磊哥提醒，demo 轻治理）
codex `source_of_truth_matrix` 13字段 / GLM ActionPlanner 多阶+session_ttl 两层+写史合同+context_age门+device-map digest → **全砍**。轻治理铁律：LoRA/安全门/契约 SSOT 不省，编排/ttl/digest/matrix 砍。

---

## 件 3 — 决策晶体速查（已拍，别重 grill）

| 决策 | 拍板 | 落点 |
|---|---|---|
| 范式三层 | IR=device×action / surface=D 具名工具 / runtime 分层 | paradigm §2 |
| MVP 10 族 | 空调/座椅/车窗/车门/灯光/屏幕/音量/雨刮/天窗遮阳/香氛（HUD不做）| paradigm §6 |
| A4 方向盘加热 | 展示层并座椅·技术层独立 | paradigm §13 |
| 基础语义语言 | 中文（多语种协议转换）| G5 |
| LoRA 范围 | 10 族 scope_tier 拆（非 562 全 positive）| A3 |
| 现场约定 | 只说 10 族，族外 unsupported 兜底 | paradigm §13 |
| 复杂推理 | 预留场景宏（LoRA 学推理后续）| H 组 |
| 多意图 | 连续两句 splitter | H 组 |
| G1 根因 | 双因叠加 working diagnosis，G6-C 终判 | G1 |
| C1 语料 | 云 generator+异源 judge+contract 定标签+原文 oracle+四类数据 | C1 |
| G4 边界 | 191/562 allowlist | paradigm §13 |

---

## 件 4 — 待 grill 清单

**第二批 5 grill（6-10，下 session 第一件事，件 6 备选项+推荐）**：A1 SSOT对账 / A2 codegen具名工具目录 / C2 masking / C4 C6 demo分层评测 / D1 G6-C cell设计。

**剩 ~16 待 grill**（第三批+）：B1 端侧工具子集+受限解码 / B2 多intent→少mock卡片 / C3 配方 / C5 端侧parity / D2 subset门 / D3 真前置 / E2 大级联 / F1 θ-β安全门 / F3 demo-golden-run κ / G3 语料量级 / G6 复杂推理预留边界。

> 完整待 grill 清单见 `paradigm-tool-surface.md §11`（A-G 组）+ §12（H 特性）+ §13（拍板）。

---

## 件 5 — 本 session 元认知 + 错误（防重蹈）

- 🔴 **三次翻转 + 范式翻案**（claim-vs-reality 极致活教材）：判别经历 gate_result→训练surface→模型实际吐什么 三次下钻翻转；B-frame 倾向→D-domain 具名工具翻案。**CC anti-confirmation 兑现**（一直「等 subagent 若翻案再改」，未拍死 → 翻案成本低）；**GLM 拍死「B-frame 唯一正解」被第4源打脸**。教训：重大范式决策等一手 ground-truth，别凭倾向/推断拍死。
- 🔴 **数字口径混乱**（claim-vs-reality）：422/397/562/507/418 五个 10 族 intent 数全不同——根因 = naive 正则误命中（`^ac` 吸 accelerator）+ scope_tier 不同（候选/compact/definite）。**多个独立核的数全不一致 = 边界/口径未定义**，要 explicit allowlist + scope_tier 统一。
- **catch codex/GLM**（不迎合）：codex「不同源」过强（实为同源命名一致）/ GLM 拍死 B-frame / 两者过度工程化 / GLM entropy 算错(1.93→2.437) / GLM 数字归属错(562 是 CC subagent 非 codex)。
- **harness hook 活体 catch**：H2a cite-verify hook 本 session 反复 catch 我引用的数字无 inline source（completion-audit.md 路径不完整 / jq 字段 source 不认）= **enforce>自觉 活证据**；hook 一个盲区（JSON 数字 source 用 `file#字段`）已被另一窗口修进 CLAUDE §8。
- **复杂推理我守边界守过头**：先倾向场景宏，被磊哥纠「复杂推理是核心诉求+LoRA 目的」→ 收回，改预留场景宏（短期）+ LoRA 学推理（后续升级）。

---

## 件 6 — 起手 step + 下次第一步（第二批 5 grill，直接可拍）

**起手**：读件套（尤件 2 翻案全景 + 件 5 元认知）→ 内化「D-domain 具名工具 + 10 族单语中文」范式。

**🔴 下次第一步 = 拍第二批 5 grill（6-10）**，选项+推荐已备（磊哥批量拍/调）：

| # | 议题 | ⭐推荐 |
|---|---|---|
| **6 A1 SSOT 对账** | ⭐ 简单 allowlist + scope_tier 标签（候选/positive/unsupported/safety/followup），**不搞 codex 13字段 matrix**；统一 562(候选)/418(compact positive)；缺~486 大部分族外 unsupported demo 不需要 |
| **7 A2 codegen 具名工具目录** | ⭐ `gen_tool_contract.py` 扩展：从 3990 全 intent codegen 具名工具(intent→tool名/value形态编码/arg enum) + **domain→service-group→tool 三级中间层**；废 `dDomainSurfaceNames`/`normalize`/C3executor/applier/FastPath 六处硬编码 |
| **8 C2 masking**（解 collapse 关键）| ⭐ `train_on_turn` loss mask + **具名工具 name token + required args token 进 loss**(home-llm 范式)；unsupported/safety 拒识话术 token 也进 loss |
| **9 C4 C6 demo 分层评测** | ⭐ codex 4 层：`golden_demo`(炸场剧本100%)/`demo_fuzz`(同义稳)/`unsupported`(族外拒识)/`safety`(行驶安全门)；替旧 23条6工具假评测 |
| **10 D1 G6-C cell 设计**（地基终判）| ⭐ cell=具名工具+三类样本 × multi-checkpoint(50/100/150)，anchor=generic frame θ-α 0/23；**GLM 区分两因判据**：trigger 恢复但 action 低→collapse 更重 / trigger 不恢复→surface 更重 |

依赖链：A1(根)→A2(codegen)→C2(masking)+C4(评测)→D1(G6-C 终判)。

**纪律**（件 5 强化）：数字当场 cite-verify 一手（grep allowlist/jsonl/代码）禁凭印象；多数字口径不一致先定 scope_tier；重大范式决策等 ground-truth 不凭倾向拍死；demo 轻治理（编排/ttl/digest/matrix 砍）。
