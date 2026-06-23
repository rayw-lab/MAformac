# C5 Recovery Grill — Amend：FC 范式 + 工具 surface 收口（第4源翻案 + demo 取巧）

> **as-of**: 2026-06-22 深夜（subagent teardown 真实座舱 TOP技能表FC+交付手册回来，第4源 ground-truth 推翻 B-frame 倾向）
> **本文档 = FC 工具组织范式终拍**（三方 CC/GLM/codex + subagent ground-truth）。一手源：`docs/research/2026-06-22-top-fc-skill-table-teardown/README.md`（subagent 完整 teardown，21 sheet xlsx + docx）+ raw `自由说Taxonomy`/`端状态打点矩阵` + 3990 contract + θ-α 实测。
> **权威边界**：范式 + 工具 surface 以本文档为准；θ-α 根因/G6-C 设计被本文档 amend（§3/§8）；`execution-gap` §1B + `g6c-design` 的 D-vs-B 框架被本文档 supersede。
> 🔴 **翻案声明**：CC + GLM 此前倾向 B-frame，**被第4源（真实座舱量产 ground-truth）推翻**。CC anti-confirmation 兑现（一直保持「等 subagent 若翻案再改」，未拍死）；GLM 在第4源前拍死「B-frame 唯一正解、不跑对照」被打脸。

---

## §1 范式翻案：真实座舱量产 = D-domain 具名工具，B-frame 否决

subagent 一手坐实（source: teardown README + xlsx col D/E）：
- **范式 = D-domain 极致密集具名工具**：`intent == 工具名`（7787/7793 行精确相等）。工具名样本：`adjust_ac_temperature_to_max / _to_number / _by_exp / query_ac_temperature`。
- **规模 = 2045 active 工具**：三级 `domain(16) → service-group(236) → tool(2045)`；window_control 一族 64 工具。
- 🔴 **value 形态编码进工具名**（最值/绝对/相对/查询 × SPOT/EXP）——**不是** generic frame `tool_call_frame{device,action,value}` 的 action 参数枚举。表里无统一 frame 工具。
- **B-frame 否决理由（深刻）**：value 形态塞进单一 action 参数 → 小模型单工具内决策 `device×action×value.type×offset` = **判定面爆炸、误吸率高**（vendor 核心痛点「泛化↑→误吸↑」）；具名工具 = 选对工具即选对 value 形态 + **受限解码更好约束**。
- 🔴 **措辞校准（codex catch，接受）**：「B-frame 否决」精确含义 = **generic frame（`tool_call_frame`）作 model-visible surface 否决**；**canonical IR 仍 device×action（B-frame 式，§2①）保留**。即「**对模型像 D-domain 具名工具，对系统像 device×action IR**」——不是全盘否决 device×action。

## §2 范式定稿 = 三层模型（codex 方向，磊哥同意）

| 层 | 定什么 | 状态 |
|---|---|---|
| **① Canonical IR**（内部表示）| `device × action_primitive × value{ref,direct,offset,type}` | ✅ 定（从 3990 派生；raw Taxonomy「原子能力」就是这层）|
| **② Model-visible surface**（模型吐什么）| **D-domain 具名工具（value 形态编码进名）** | ✅ **坐实**（第4源否决 generic frame）|
| **③ Runtime tier**（能执行多少）| MVP 10 族 `mock_execute` / 其余 `recognized_noop_or_refuse` / 越界 `unsupported` | ✅ 分层（codex + magnet MVP）|

> ⚠️ 厘清：① IR 是 device×action（B-frame 式）≠ ② surface 用 generic frame。GLM 把两层混了（「原子能力=device×action」是 IR 层，被误推成 surface 必 generic frame）。② surface 真实座舱用**具名工具**正是为降判定面/误吸。

## §3 θ-α 0/23 更深根因（amend `execution-gap`/`rootcause` 的定性）

θ-α 0/23 **不只是 surface mismatch（训练 B / eval D 错位）**，更深 = **generic frame 范式本身错**：`tool_call_frame` 让 1.7B 在单工具内决策 671 device×141 action×value 形态 = 判定面爆炸 → 小模型学不会 → 坍缩。真实座舱 2045 具名工具正是拆小判定面。→ **θ-α generic frame 训练作废，改 D-domain 具名工具训练**。

## §4 🔴 demo 投机取巧方案（量产 ≠ demo，磊哥核心命题）

真实座舱是**工程化量产**（2045 工具 + FC→NLU→DS→DM 全链路 + 协议转换适配器 + 车型适配）。MAformac 是 **demo 助手**——**借范式内核智慧、砍量产工程、加演示包装**：

| 维度 | 量产真车 | demo 投机取巧 |
|---|---|---|
| 工具数 | 2045 | 端侧只挂 **MVP 10 族炸场子集高频 value-form 工具 ~~~30-60 个~~** 🔴[SUPERSEDED→§14 G2:212：工具数不拍 ~30-60，待 value-form 实算，30-60 已废]（按 col O 线上优先级筛，不挂全 64/族）|
| 判定面拆小 | 具名工具（核心智慧）| ✅ **照借**（解 θ-α 0/23 的技术内核）|
| 训练范围 | 全量 | LoRA 锚 3990 泛化 |
| 端侧挂载 | domain 级开关分组加载 | ✅ 照借（端侧挂炸场族 + 受限解码白名单）|
| 下游链路 | FC→NLU→DS→DM→协议转换适配器 | 🔪 **砍**（demo 只 FC→mock 端态卡片+TTS）|
| 真控/车型适配 | 1024-E0Y/AH8 真设备状态上传 | 🔪 **砍**（mock 端态自包含）|
| 多意图 | FC 不支持一句话多意图(P85) | 守此边界，demo 也不做（省）|
| 评测 | 10532单轮+932多轮全覆盖 | C6 扩到炸场子集 |

**demo 取巧哲学 = 借内核（降误吸智慧）+ 砍工程（全覆盖/全链路/真控）+ 加包装（炸场剧本/mock视觉/泛化兜底）**。

🔴 **磊哥终极约束（2026-06-22）：现场只说 10 族 + 提前和客户沟通好**——用**演示约定（不说族外）直接消除全集鲁棒性需求**，比任何泛化兜底都强：
- ❌ 不需要全集 671/2045 泛化兜底（现场不说族外）；❌ 不需要 codex 的动态选包 pre-router（直接挂 10 族，不用动态选）。
- ✅ 端侧只挂 10 族 value-form 工具（~~~30-60~~ 🔴[SUPERSEDED→§14 G2:212：工具数不拍 ~30-60，待 value-form 实算]）+ 受限解码白名单；✅ 保留 L4 安全拒识（万一说危险的）+ 10 族内同义/模糊/口语泛化。
- → **demo 取巧 = 演示约定收窄说话范围 → 技术只需 10 族稳定命中**（最省一刀：不做全集、不做泛化兜底、不做动态选包）。

**10 招（落 demo 设计）**：
1. 具名工具拆小判定面（解 θ-α 0/23 技术内核）。
2. 端侧受限解码白名单（GBNF）约束只吐挂载 ~~~30-60~~ 🔴[SUPERSEDED→§14 G2:212：工具数不拍 ~30-60，待 value-form 实算] 工具 → 误吸≈0（demo 不丢脸硬保证）。
3. ~~训练全集泛化~~ + 端侧炸场子集挂载（说族内命中/族外泛化兜底）。🔴 **[SUPERSEDED → §16:216 / §13.A3:126：10 族不训全集，训练 = 10 族 562 scope 按 scope_tier 拆四类数据，族外 unsupported 拒识]**
4. value 形态分级取巧：每族只挂高频 value-form（set_max/to_number/by_exp/query），长尾不挂。
5. 砍量产 FC→NLU→DS→DM 全链路 → FC→mock 端态。
6. mock 端态自包含（卡片亮暗+TTS），砍车型真设备适配。
7. 守 vendor 边界：不做一句话多意图（P85）。
8. 炸场剧本锁定（demo-golden-run）：炸场 case 锁在挂载工具内 → 现场不脱靶。
9. 泛化兜底分层（不丢脸核心）：族外 → L2 通用 mock 兜底 + L3 越界拒识 → 不崩。
10. mock 视觉炸场做足（demo 价值=演示效果，非真控）。

## §5 写死 6 处整改方向（基于翻案，不是「换 B」）

整改 = subagent 定性「**数量错 2 个量级假派生 + 缺 service-group 中间层**」→ 从 `semantic-function-contract.jsonl` 单一 SSOT **codegen 全量具名工具目录**（col D/E→tool名, H→ToolCall schema, I→arg enum），端侧挂炸场子集，停止手写第二套：
1. `ToolContractCompiler.dDomainSurfaceNames():73-87`（硬编码6→codegen具名工具目录）
2. `ToolContractCompiler.normalize():148-160`（6 case→全量派生）
3. `ToolContractCompiler:305/311`（device→IR 硬编码）
4. `C3ExecutionPipeline:163/171`（runtime executor 2 device→分层 tier）
5. `C6VehicleToolBench` applier:1163（6工具→炸场子集）
6. `FastPathIntentEngine:12`（1 条→规则路）
+ **新增 service-group 中间层**（domain→service-group→tool 三级，量产同源）。

## §6 MVP 10 族 + 香氛边界 + 两层 scope

- **MVP 10 族 device（磊哥拍）**：空调/座椅/车窗/车门/灯光氛围/屏幕/音量/雨刮 + 天窗遮阳帘 + 香氛（跳过头枕）。
- 🔴 **香氛边界（raw 一手 + 磊哥认同）**：只支持**强度/开关**（on/off+浓度档），**不支持选味道**（raw「香氛味道不承接」）。
- **两层 scope（防混层）**：MVP 10 族 = 演示层（demo炸场+C6测+端侧FC精做）；~~LoRA 训练锚 3990 全集（能力层泛化）——10 族外靠泛化+mock兜底。10 族 ≠ 训练范围。~~ 🔴 **[SUPERSEDED → §16:216 / §13.A3:126：10 族不训全集，LoRA 训练 = 10 族 562 scope 按 scope_tier 拆四类数据；族外走 unsupported 兜底非泛化；3990 仅 canonical IR 派生源/value-form 变体来源非训练 scope]**

## §7 🔴 三表关系 elephant（待厘清，影响 SSOT + LoRA 范围）

三个"全集"表，关系未厘清，**必须坐实谁是 SSOT**：
- **TOP技能表 FC**（subagent）：7787 intent / 2045 工具 / 10532+932 测试。
- **semantic-function-contract.jsonl**（仓内 C1）：3990 行 / 671 device / 141 action_primitive / service{carControl2656/cmd1156/airControl178}。
- **codex 称 7867 条** service+intent+slots（carControl2544≠仓内2656）。
- 🔴 **疑问**：TOP技能表 vs contract 是否同源？谁派生谁？LoRA 范围 3990 暂定，**若 TOP 更全 → 扩到它**（磊哥「subagent 有收获可加」）。
- ✅ **verify 坐实（2026-06-22，CC 核 + 两轮校准）**：3990 与 TOP **intent 命名一字不差**（3990 实有 `adjust_ac_temperature_to_max/_to_min/_to_number/_to_exp/_no_value`，TOP 同样式）= **同源、命名高度一致**。
  - 🔴 **两次过强对称校准**：codex 先凭「service3 vs domain16」推「不同源」过强；CC 后推「3990 是 TOP 严格子集（缺486）」也过强。**codex 复算证伪严格子集**：contract 有 **43 intent 不在 TOP**、TOP 有 **529 intent 不在 contract**（精确数 codex 复算，待 D1 matrix 坐实）= **非严格包含、双向有独有**。
  - **正确表述**：**同协议族、命名高度同源、非严格子集；3990 = 当前 SSOT（仓内+脱敏+可 codegen）；TOP = 更全 oracle 补缺**（不是直接替代 SSOT）。
- 待厘清（grill A1/G4）：**先定 10 族 device 边界**（CC 422 vs GLM 397 intent 不一致 = 边界未定义，各拍正则）→ 再核 contract∩TOP / contract-only 43 / TOP-only 529 + 10 族在 3990 的 intent 数（= 工具/训练范围，CC jq 暂得 422 待边界定后重算）。

## §8 G6-C 重定义（磊哥同意 codex 方向）

G6-C 从「D-vs-B 对照」→ **「canonical IR(device×action) + derived surface(具名工具) 是否同源/可训/可执行」三层验证**：
- ② surface 已坐实 = D-domain 具名工具（generic frame 否决，不再对照 B）。
- G6-C 实测点 = **MAformac demo 端侧具名工具子集（~~~30-60~~ 🔴[SUPERSEDED→§14 G2:212：工具数不拍 ~30-60，待 value-form 实算] value-form 工具）+ 受限解码 能否让 Qwen3-1.7B 学会（trigger 恢复 + action_hard_pass）+ 炸场不丢脸**。
- cell 重设：D-domain 具名工具训练（不是 generic frame）× distractor 域 × multi-checkpoint；anchor = θ-α generic frame 0/23（失败锚）。
- 真前置 = 从 contract codegen 具名工具目录（替 §5 硬编码）+ 端侧受限解码白名单。

## §9 辩证账（翻案 · 不护短）

- 🔴 **CC + GLM 翻案**：倾向 B-frame 错。根因 = 把「原子能力 IR(device×action)」误推成「model-visible surface 必 generic frame」（混层）；真实座舱用具名工具（连 value 形态编码进名）降判定面/误吸。
- **CC anti-confirmation 兑现**：一直「等 subagent 若翻案再改」，未拍死 → 翻案成本低。
- **GLM 过强被打脸**：第4源前拍「B 唯一正解、不跑对照」+ 混层 + 没更新 MVP 10 族。
- **codex 方向对**：三层模型 + 「B-frame 暂定 canonical 非唯一」+ 三层 tier + 「独立功能工具」一手 catch（倾向 facade 被 subagent 坐实）。codex 比 GLM 稳（没拍死，留三层）。
- **subagent ground-truth 决定性**：第4源（真实座舱量产）才是终判，验证了「据一手不凭推/不凭倾向」。

## §10 级联 + 下一步

- 级联：`g6c-design.md`（D-vs-B → 三层验证，标 supersede）/ `execution-gap §1B`（B vs D → D-domain 具名工具坐实）/ `rootcause`（θ-α 根因加深：generic frame 判定面）/ `CLAUDE §9 banner`（范式翻案）/ A1 段（amend）。
- 🔴 **下一步**：① 厘清三表关系（§7，定 SSOT + LoRA 范围）② codegen 具名工具目录 + service-group 中间层（替 §5 硬编码）③ 端侧炸场子集 + 受限解码 ④ 重定义 G6-C cell（D-domain 具名工具训练）。

---

## §11 翻案后 grill 清单（统一待 grill 议题 = 磊哥三步 + 前面未答 + LoRA 流程新议题）

> 范式翻案（generic frame surface 否决 → D-domain 具名工具 + 10 族 + 3990 SSOT）后，C5 recovery grill 焦点全变。本清单**替代旧 D-vs-B 框架**，统一翻案后所有待 grill。状态 🔴未grill / 🟡部分 / ✅已拍。

### A. SSOT + 工具目录（最高优先，codegen 前置）
- **A1 三表 SSOT 对账** ✅（grill 6 拍）：简单 allowlist + scope_tier 标签；562 intent 锚定（🔴 磊哥 2026-06-23 亲拍权威，旧 534 作废）；contract↔TOP 对账延后不阻塞 demo。
- **A2 从 3990 codegen 具名工具目录** ✅（grill 7 拍）：两层 scope（full=1538 轻量 / demo=562 重度，🔴 磊哥 2026-06-23 亲拍权威旧 534 作废）；废 §5 六处硬编码。
- **A3 LoRA 范围** ✅（grill 3 拍）：10 族子集（562，🔴 磊哥 2026-06-23 亲拍权威旧 534 作废），族外 unsupported 拒识；按 scope_tier 拆四类数据。

### B. demo 范式落地（10 族）
- **B1 端侧工具子集 + 受限解码** 🔴：10 族 value-form 工具（~~~30-60，col O 优先级筛~~ 🔴[SUPERSEDED→§14 G2:212 / §16:385：工具数不拍 ~30-60，待 value-form 实算]）+ 受限解码白名单（GBNF/Outlines）实装。
- **B2 多 intent→少 mock 卡片映射** 🔴：seat 30 intent → 几个座椅卡片状态字段（具名工具多→mock 卡片少，codex 点）。
- **B3 演示约定 + 安全兜底** 🟡：现场只说 10 族（✅磊哥拍）+ L4 安全拒识（万一说危险）+ 炸场剧本锁 10 族（demo-golden-run）。

### C. 🔴🔴 整体 LoRA 流程重走（磊哥新点名，最该 grill）
- **C1 10 族语料生成** ✅（grill 5 拍）：云多源 generator + 异源 judge + contract 定标签 + 原文 oracle 非训练集(红线) + 单语中文 + 四类数据（positive/followup/unsupported_refusal/safety_refusal）+ distractor-in-prompt。
- **C2 masking** ✅（grill 8 拍）：train_on_turn loss mask + name/args token 进 loss；**masking=学得准 ≠ 解 collapse**（C1 negative=不坍缩，两机制正交）。
- **C3 配方** 🟡：rank16Mainline 守？判定面变小（具名工具）是否需调 rank/scale/iter？
- **C4 评测 C6 demo 分层** ✅（grill 9 拍）：4 层独立门（golden 100%硬门 / fuzz+unsupported+safety 各设阈值），不合 pass_rate。
- **C5 端侧 parity** 🔴：受限解码 + 具名工具的 mlx-swift 端侧一致性。

### D. G6-C 重定义后 cell（验具名工具可训，替 D-vs-B）
- **D1 cell 设计** ✅（grill 10 拍）：具名工具+三类样本 × multi-checkpoint(50/100/150)；anchor=θ-α 0/23；须能区分两因；依赖链终点（A2+C2+C1 就绪后跑）。
- **D2 subset/门**（继承旧 §9，D-vs-B 改具名）🟡：subset 600/768 / checkpoint 50/100/150 / 诊断门（trigger 主 + action≥2 辅，非 candidate >base 10/23）。
- **D3 真前置变更** 🔴：从「训练改 D renderer」→「codegen 具名工具目录(A2) + 受限解码(B1)」。

### E. 级联（磊哥三步②③）
- **E1 最小 banner**（磊哥三步②，codex 建议）🔴：`g6c-design.md`/`execution-gap` 顶部标 `surface framing superseded, pending SSOT reconciliation`，不改正文。
- **E2 SSOT 定后大级联**（磊哥三步③）🔴：CLAUDE §9 banner / G6-C cells / execution-gap 根因 / codegen 派单。

### F. 残留复核（翻案前议题，需确认仍成立）
- **F1 θ-β 安全门**（θd-2/3/4）🟡：翻案后安全门是否变（具名安全工具 vs risk-policy overlay）。
- **F2 真机 endpoint** 🔴：采购（阻塞链）。
- **F3 demo-golden-run κ** 🟡：炸场剧本锁 10 族 + 绝对门 K_abs。

### G. 🔴 两助手第二轮新增（codex/GLM catch + 磊哥认同，2026-06-22）
- **G1 θ-α 0/23 根因 re-diagnosis** ✅（grill 1 拍）：双因叠加（surface mismatch + zero-negative collapse）= working diagnosis；G6-C 实验终判，须能区分两因。
- **G2 10 族工具子集数量 tradeoff** ✅（grill 4 拍）：不拍数先出分布；🔴 blocker：col O 不在仓内 jsonl（在 xlsx），用 exec_tier/fc_flags 替代或 raw xlsx 提取。
- **G3 10 族语料增广量级** ✅（grill 5 拍，并入 C1）：四类数据 + 云多源 generator。
- **G4 10 族 device 边界定义** ✅（§13 收口 + §14 cite-verify）：191 device / 562 intent / 2159 行（🔴 磊哥 2026-06-23 亲拍权威，旧 534/2086 作废）；A1-A9 裁决见 §13。
- **🔴 codex catch 2 → 改 C1/D2/D6（三类样本）** ✅（§13 并入 C1 四类数据）。
- **G5 基础语义语言选定** ✅（grill 2 拍）：中文。
- **G6 复杂推理预留边界** 🟡（§12 预留）：短期场景宏，LoRA 学推理后续升级。

> **grill 顺序建议（第二轮校准，G1 升最高）**：~~I1 banner（✅已做）~~ → **G4 device 边界 + G1 根因 re-diagnosis（★地基，最高★，没验证前范式翻案是强假设）** → A1（SSOT 对账，含 G2 工具数实算）→ D2（10 族范围，含 codex 三类样本）→ C1（语料生成，含 G3 量级）→ A2/B1（codegen + 受限解码）→ C2-C5 / D6（LoRA 流程 + G6-C cell 验范式地基）→ E2（大级联）→ F（残留）。

---

## §12 demo 特性料头 + 多语种约束 + 第二轮收口（2026-06-22，三方 CC/codex/GLM + 磊哥拍）

### H 组 · demo 5 特性（磊哥拍 + LoRA 短期四类数据）
| 特性 | demo 做法 | LoRA 数据类 | 状态 |
|---|---|---|---|
| 模糊说（感受词→value）| LoRA 核心，10 族 EXP（3990 `value.type=EXP` 734 行）云 paraphrase 不定标签 | `single_tool_fuzzy_positive` | ✅核心 |
| 短时记忆 + 歧义指代 | DialogueState 记最近 3 轮继承 + 反问（砍长时云）；数据基座 `second_turn_refs` 427 | `followup_rewrite` + `clarify_or_safety_refusal` | ✅ |
| 多意图 | 连续两句 splitter 拆两单跳 FC（不模型自拆/不 ActionPlanner）| `bounded_multi_intent_split` | ✅磊哥拍连续两句 |
| 复杂推理 | 🔴 **预留**：短期场景宏（确定性查表"下雨→关窗天窗"），LoRA 学推理后续升级位 | `complex_reasoning_multi_tool`（预留，不进短期训练）| 🟡预留 |
| 安全门 | 行驶中开门拒识/确认 | `clarify_or_safety_refusal` | ✅ |

→ 短期 LoRA **四类数据**（复杂推理走场景宏，第五类 LoRA 学推理预留）。

### 🔴 多语种约束（磊哥点名，影响全链路）
- **LoRA 只训单语基础语义**（中/英一种，不多语种混训=容量集中），多语种进来**协议转换复用**——印证交付手册「协议转换适配器=语言无关层」。
- 架构：`ASR(多语种) → NLU(多语种→基础语义 intent) → LoRA(单语→ToolCall) → 协议转换 → mock`。
- 影响：C1 语料单语 / demo 现场单语 / 多语种协议转换层预留。基础语义语言（中 vs 英）= **G5 待拍**。

### 🔴 过度工程化 catch（磊哥提醒，demo 轻治理砍）
codex `source_of_truth_matrix` 13 字段(含 digest/decision_status) → 简单 allowlist；GLM 多意图 ActionPlanner 多阶+补槽 → 轻量 splitter；GLM 短时记忆 session_ttl 两层+写史合同 → DialogueState 3 轮；GLM 歧义 context_age 门+slot_source → last_target+反问；GLM device-map.json+digest → 简单 allowlist。**轻治理铁律（CLAUDE §7）：LoRA/安全门/契约 SSOT 不省，编排/ttl/digest/matrix 砍。**

### G4 收口（磊哥拍我 subagent）
- 权威 = `docs/research/2026-06-22-mvp-10family-device-boundary.md`（explicit allowlist，191 device / **562 intent / 2159 行 = 54.1% 全集**，🔴 磊哥 2026-06-23 亲拍权威，见本文档 §14:222-235；旧 534/2086/52.3% A1-A9 后口径作废；非 naive 误命中 422/397）。族外 480 device → L3 unsupported tier。A1-A9 边界歧义已磊哥拍（见 §13）。

### G1 根因更新（验证范围）
θ-α 0/23 re-diagnosis 验证范围更新：**「D-domain 具名工具 + LoRA 四类数据(含三类样本) + 单语基础语义 + 复杂推理走场景宏」能否恢复 trigger**（解 surface + collapse 双因）。

### 新增 grill 议题
- **G5 基础语义语言选定**（中 vs 英）🔴：LoRA 单语锚哪个？倾向中文（3990 中文 + 现场中文免翻译）。
- **G6 复杂推理预留边界** 🟡：短期场景宏范围（哪几个跨域宏）+ LoRA 学推理升级触发条件。

---

## §13 第一批 grill 拍板 + A1-A9 裁决（2026-06-22 磊哥拍，三方辩证）

### A1-A9 device 边界裁决（全按 subagent ⭐ + 磊哥单挑 A4）
- A1 `interior_heat`→族外 / A2 `volume_mute/unmute/current_volume`→音量 / A3 声浪→族外 / **A4 `steering_wheel_heating`→🔴磊哥拍：demo 展示层归座椅「舒适」子域联动（客户「我冷了」感知接触面，不分座椅/方向盘），技术层仍独立 device+工具名（不脏）** / A5 `hud*`→🔴**HUD 不考虑（磊哥拍·纯族外 unsupported，不做独立 HUD 工具）** / A6 `backlight/button`→族外 / A7 `console`→族外 / A8 `windshield`→车窗·`nozzle`→族外 / A9 `theme/wallpaper`→屏幕。
- → 权威 allowlist = `docs/research/2026-06-22-mvp-10family-device-boundary.md`（A4 并座椅展示层后微调；技术 device 数不变）。

### 第一批 5 grill 拍板
| # | 拍板 |
|---|---|
| **G1 根因** | ✅ **双因叠加（surface mismatch + zero-negative collapse）**，文案 = `working diagnosis`（非已证实，codex）；**G6-C 实验设计须能区分两因**（trigger 恢复但 action 低→collapse 更重；trigger 不恢复→surface 更重，GLM）。终判靠 G6-C 重训。|
| **G5 语言** | ✅ **中文**（三方零争议；多语种走协议转换非 LoRA 层）|
| **A3 范围** | ✅ 10 族不训全集。🔴 **修正：训练 ≠ 562 全 positive，按 `scope_tier` 拆 = compact positive + unsupported + safety + followup 四类**。数字三口径待统一：候选全集 562(CC subagent allowlist)/507(GLM definite)，compact positive 418(codex)——A1-A9+scope_tier 拆后重算。|
| **G2 工具数** | ✅ 不拍 30-60/562，实算。🔴 **blocker：`col O` 线上优先级不在仓内 jsonl（在 xlsx 第15列）** → raw xlsx 提取(只读) 或 `exec_tier/fc_flags` 替代。运行态炸场小包 vs 训练态 compact 更宽（分开）。|
| **C1 语料** | ✅ 云多源 generator paraphrase + 异源 judge + **contract 定标签(LLM 不定)** + 原文 oracle 非训练集(红线) + 单语中文 + **四类数据**（positive/followup/unsupported_refusal[解collapse]/safety_refusal[R0-R3]）+ distractor-in-prompt 构造(When2Call) |

### 🔴 统一表述修正（codex catch，覆盖旧「全集泛化兜底」）
**「10 族内自由说，族外边界沟通 + unsupported 兜底」**——现场只说 10 族（提前沟通），10 族内 LoRA 泛化自由说法，10 族外 = unsupported tier 拒识兜底（不追全集泛化）。覆盖前文一切「训练全集泛化/族外泛化兜底」旧表达。

---

## §14 第二批 grill 拍板 + cite-verify 数字坐实 + second_turn_refs 数据（2026-06-22 磊哥拍）

### 🔴 cite-verify 数字坐实（codex catch + 🔴 磊哥 2026-06-23 口径终拍）

> 🔴🔴 **口径终拍（磊哥 2026-06-23 亲自决策，终结 534/562 纠结）**：**10 族 intent = 562 / 行 = 2159 / 54.1% / 族外 976 intent / 1831 行**；device 191 不变。534 vs 562 仁者见仁（534=A1-A9 边界裁决后移出若干边界 intent；562=A1-A9 前 explicit allowlist 全集），**磊哥不纠结、亲自拍 562 为全仓唯一权威口径**。🔴 534/2086/52.3%/1004/1904 系列**全作废**；全仓散落 534→562（+2086→2159 / 52.3→54.1 / 1004→976 / 1904→1831）回写 = **第一个长跑文档级联任务**。下表已按 562 校准。

| 数 | 值 | 状态 |
|---|---|---|
| 10 族 intent | 🔴 **562** | ✅ **磊哥 2026-06-23 亲自拍板（全仓唯一权威）** |
| 10 族 device / 行 | 191 / **2159（54.1%）** | ✅ 磊哥拍 562 配套 |
| 全集 | 3990 行 / 671 device / 1538 unique intent | ✅ 坐实（3990 是行数，unique intent=1538） |
| 族外 | 480 device / **976 intent / 1831 行** | ✅ 配套 562（1538-562 / 3990-2159）|
| compact positive 418 | codex 数、口径不同 | ⚠️ 待 A1 按 scope_tier 拆后重算 |
| ~~缺 ~486 intent~~ | — | 🔴 **已证伪**：codex §7 证 3990↔TOP 双向独有（contract-only 43 / TOP-only 529），非严格子集 |

> ⚠️ 口径史：534（A1-A9 后 GLM `execute_code` 算）一度被当坐实，**磊哥 2026-06-23 亲自拍 562 终结纠结**（仁者见仁，取 A1-A9 前 explicit allowlist 全集）。**全仓以 562 为唯一权威**；旧 534/2086/52.3%/1004/1904 全废，散落引用待第一个长跑级联回写。这也解除了 wzulqp1f7 审计 STOPPED 的根因（534 vs 562 口径矛盾，磊哥一拍即解）。

### second_turn_refs 10 族分布（特性 1/5 短时记忆+歧义消解数据基础）

> GLM `execute_code` 从 3990 contract 逐行算，A1-A9 拍板后 definite device scope。
>
> 🔴🔴 **口径边注（finding 2026-06-23：本表 per-family 分母 = 534-era 旧口径，已废，见本节 :224 终拍 banner）**：本表 per-family **分母**（空调 156 / 座椅 658 / 灯光 414 / 车窗 82 / 车门 80 / 屏幕 265 / 音量 221 / 雨刮 80 / 天窗 98 / 香氛 32，求和 = **2086**）= A1-A9 后 534-era device scope 的族内行数，**与权威 562/2159 口径的 per-family 行数不一致**（权威族行见 boundary 文件 §1：空调 212 / 座椅 696 / 灯光 468 / 车窗 82 / 车门 129 / 屏幕 205 / 音量 153 / 雨刮 80 / 天窗 102 / 香氛 32，求和 = 2159）。**本表为经验测量（分子 = 该族 second_turn 非空计数，与分母同口径）→ 占比/族间相对排序仍可用作 demo 多轮剧本选族依据**；但**绝对分母 2086 = 废口径，未来 grill 禁当 562 时代一手分母引用**，按 562 重算待 GLM `execute_code` 以 explicit-allowlist 562 scope 重跑整表（分子 + 分母同步）。下表合计「260/2086」中 2086 为废口径，仅作 534-era 内部一致性参考。

| 族 | second_turn_refs 非空 | 占族内% | demo 多轮价值 |
|---|---|---|---|
| 香氛 | 14/32 | **44%** | ⭐⭐⭐ 最高 |
| 雨刮 | 25/80 | **31%** | ⭐⭐⭐ |
| 车窗 | 25/82 | **30%** | ⭐⭐⭐ |
| 空调 | 46/156 | **29%** | ⭐⭐⭐ |
| 天窗遮阳帘 | 26/98 | **27%** | ⭐⭐ |
| 车门 | 14/80 | 18% | ⭐⭐ |
| 座椅 | 89/658 | 14% | ⭐⭐ |
| 灯光氛围 | 18/414 | 4% | ⭐ |
| 屏幕 | 3/265 | 1% | × |
| 音量 | 0/221 | **0%** | × |
| **合计** | **260/2086**（🔴 分母 2086 = 废口径，见上方边注；分子 260 = 各族非空求和实测；按权威 2159 分母重算占比 = 12.0%） | **12.5%**（534-era 口径） | — |

→ demo 炸场多轮剧本优先选 **空调/车窗/雨刮/香氛**（二次交互高频族，占比相对排序与口径无关）。屏幕/音量是"说完就执行"的单轮族，不适合展示记忆。
> 🔴 注（finding 2026-06-23）：占比绝对值（44%/31% 等）= 534-era 族内分母算；权威 562/2159 口径下逐族分母不同（如空调 156→212、座椅 658→696），占比会变，但**族间高低排序不变**（香氛/雨刮/车窗/空调仍居前）→ 选族结论不受口径反转影响。绝对占比待按 562 重算。

### 第二批 5 grill 拍板（6-10）

| # | 议题 | 拍板 | catch 修正 |
|---|---|---|---|
| **6** | **A1 SSOT 对账** | ✅ 简单 allowlist + `scope_tier` 标签（候选/positive/unsupported/safety/followup），不搞 codex 13 字段 matrix（轻治理砍）。A1 验证器用 G4 device allowlist（非正则）断言族归属。 | 🔍 ① **562 已坐实可锚（534 已废→562，§14 终拍）**；418 不直接拍，A1 产出按 scope_tier 从 562 拆后重算。② 不用「缺486」——改「contract↔TOP 对账延后到 D1 matrix（43/529 待坐实），demo 只认 10 族 562，族外 unsupported」。 |
| **7** | **A2 codegen 具名工具目录** | ✅ `gen_tool_contract.py` 扩展：intent→tool名 / value 形态编码 / arg enum + domain→sg→tool 三级。**两层 scope**：`--scope=full` 出轻量目录（1538 tool名+三级，族外只用于 unsupported 拒识）；`--scope=demo` 出重度目录（**562 完整 value-form**+arg enum+ds_protocol，534 已废→562，§14 终拍）。两层都从 3990 派生，派生深度不同，非两套 SSOT。 | 🔍 全量目录 codegen + 端侧只挂 10 族（目录是派生物便宜，挂载才是成本）——两层 scope 对齐 paradigm §6。 |
| **8** | **C2 masking** | ✅ `train_on_turn` loss mask + 具名工具 name token + required args token 进 loss（home-llm 范式）+ unsupported/safety 拒识话术 token 进 loss。 | 🔍 **framing 纠正**：masking ≠ 解 collapse。collapse（零负样本坍缩）由 C1 四类数据加 negative 解；masking 解的是 loss 聚焦工具名/args、防学偏话术/死记。两机制正交——masking=「学得准」，C1 negative=「不坍缩」。 |
| **9** | **C4 C6 demo 分层** | ✅ codex 4 层：golden_demo(炸场剧本 100%) / demo_fuzz(同义稳) / unsupported(族外拒识) / safety(行驶安全门)，替旧 23 条 6 工具假评测。 | 🔍 4 层应**各设独立门**（golden 100% 硬门 / fuzz+unsupported+safety 各设阈值），**不合一个 pass_rate**（旧 0/23 教训=聚合数掩盖分轴）。 |
| **10** | **D1 G6-C cell 设计** | ✅ cell = 具名工具 + 三类样本 × multi-checkpoint(50/100/150)，anchor = generic frame θ-α 0/23（失败锚）。G6-C 实验须能区分两因（trigger 恢复但 action 低→collapse 重 / trigger 不恢复→surface 重）。 | 🔍 D1 是依赖链终点（A2 codegen + C2 masking + C1 语料就绪后才跑），别先跑。50/100/150 密 checkpoint 看 trigger 何时恢复——比 θ-α 的 100/400/600 更早看到信号。 |

### 依赖链（6→7→8+9→10）

```
6 A1(SSOT allowlist + scope_tier)
  → 7 A2(codegen 两层 scope 目录)
    → 8 C2(masking) + 9 C4(分层评测)
      → 10 D1(G6-C 终判实验)
```

### 10 族 value.type / fc_flags 分布（A2/C1 数据基础）

> 🔴 **口径边注（finding 2026-06-23）**：本表 per-family value.type/fc_flags 计数 = 534-era device scope 族内行数（逐族求和 = 2086，与上方 second_turn 表同口径），**与权威 562/2159 per-family 行数不一致**（权威族行见 boundary §1）。本表用途 = value.type 相对趋势（哪族 EXP+SPOT 丰富 = LoRA 核心），**相对排序不受口径反转影响**；绝对计数待按 explicit-allowlist 562 scope 用 GLM `execute_code` 重算。

| 族 | value.type 分布 | fc_flags 分布 | LoRA 训练信号 |
|---|---|---|---|
| 空调 | 全空(156) | fuzzy 156 / free 50 | 规则路为主，free 50 行进 LoRA |
| 座椅 | 空232/EXP164/SPOT150/PERCENT112 | fuzzy 404/rule 254/free 34 | **EXP+SPOT 最丰富**，LoRA 核心 |
| 车窗 | 空44/PERCENT22/SPOT10/EXP6 | fuzzy 54/rule 28 | 中等 |
| 车门 | PERCENT32/空28/EXP16/SPOT4 | rule 80 | **纯规则路**，不进 LoRA |
| 灯光氛围 | 空193/EXP111/SPOT63/PERCENT47 | rule 254/fuzzy 160/free 26 | EXP 丰富 |
| 屏幕 | 空224/EXP19/SPOT16/PERCENT6 | rule 180/fuzzy 85 | 多规则路 |
| 音量 | 空115/EXP58/SPOT27/PERCENT21 | fuzzy 111/rule 110/free 36 | EXP 中等 |
| 雨刮 | EXP26/空24/SPOT18/PERCENT12 | rule 60/fuzzy 20 | 多规则路 |
| 天窗遮阳帘 | PERCENT40/空32/SPOT16/EXP10 | fuzzy 86/rule 12 | fuzzy 为主 |
| 香氛 | 空12/SPOT10/EXP10 | fuzzy 28/rule 4 | fuzzy 为主 |

→ **LoRA 训练重点族**（EXP+SPOT 丰富 = 模糊说→规整动作核心）：座椅(314 EXP+SPOT) > 灯光氛围(174) > 音量(85) > 车窗(16) > 雨刮(44)。车门纯规则路不进 LoRA。

---

## §15 第三批+ 扩散 grill 议题（磊哥 2026-06-22 点名扩散：治理 / 级联 / LoRA 机制 / UIUE）

> ⚠️ **SUPERSEDED-BY `docs/grill-tournament/grill-decisions-master.md`（2026-06-23）**：本节待 grill 清单（GOV/CAS/TRN/UIX 35 扩散，承载行见 §16:367 / :403；含 AUD 6 共 5 组 = 41，承载行见 §15:351「GOV 9 + CAS 8 + TRN 9 + UIX 9 + AUD 6 = 41 议题」；AUD 6 已转 →A2合同不计待 grill 扩散）已统一收口至 grill-decisions-master §2 锦标赛 41（Q22 progress/grill SSOT 单一化）。新 grill 拍板回写 master §2 状态 + §4 晶体，**本节不再独立追加**，保留供溯源。§1-§14/§16/§17/§18 的【已拍内容】仍权威。（行号已 2026-06-23 grep 实核：旧自引 365/401/349 = 空行/§16标题/空行，已纠为 351/367/403。）
>
> 磊哥点名 4 个维度让 CC 发散追加（**本节只追加待 grill，不拍板、不预答**）。
> ⚠️ **范围声明**：本节是「统一待 grill 清单」的项目级扩散（超出 §1-§14 范式+surface+第二批定位）。范式/第二批权威仍 §1-§14；下列议题拍板后各落对应文件（SRD / CLAUDE / decisions / openspec specs / UIUE 调研），不在本文档展开正文。
> 状态全 🔴未grill。组号 GOV/CAS/TRN/UIX（避免与 §11 A-G、§12 H 撞）。优先级见各组末。
> **本节引用的既有锚点 source**（非本节新断言，防未来 grill 误引）：`0/34`（PR5 candidate，source: CLAUDE §9 banner + `docs/handoffs/2026-06-22-c5-recovery-grill-marathon-closeout.md`）/ `0/23`（θ-α，source: 本文档 §3 + `grill-decisions-amend-execution-gap-reconciliation.md` §5）/ 口径 **§14 终拍 562/191/2159（534 已反转废，旧「§14 坐实 534/191/2086」误述已纠 round-01）**，source: §14:224。

### 组 GOV · 治理体系（openspec+pi+mastra+superpowers）+ 项目管理推进流程升级（磊哥维度①）
- **GOV1** 🔴 范式翻案推翻哪些已 archived OpenSpec specs？逐核 `openspec/specs/` 下 C1(semantic-function-contract)/C3(tool-execution)/C6(vehicle-tool-bench) 行为契约——D-domain 具名工具 surface + 4 层评测 是否需 MODIFY change？
- **GOV2** 🔴 C5 recovery 一直 amend 文档堆叠（paradigm/execution-gap/g6c/rootcause），从没走 OpenSpec change(propose→apply→archive)。决策：继续 amend（轻）vs 即起正式 change 让 specs 成 SSOT？什么节点收敛？
- **GOV3** 🔴 decision log 段间分叉是已发生事实——**本文档 §14 cite-verify 坐实（旧 418/缺486 废 → §14 终拍 562/191/2159；534/2086 系列亦反转废）正是它的实证**（注：此处旧版误述「§14 坐实 534/191/2086」，534 早已反转废，已纠 round-01）：旧数字在 §7/§13/handoff 件6 间分叉，靠人工 catch 才纠。升级：把「grill 拍板→基线文档组级联 + cross-section 一致性」做成 harness enforce（`make verify` cross-section 扩到 grill-decisions 系列）+ SUPERSEDED 标记规范，不靠每次人工 catch？（claim-vs-reality 第10变体 + 全局元认知 §35）
- **GOV4** 🔴 Pi 长任务规范 3 形态（事件溯源 handoff/七段 compaction 模板/工具 hook 验收门，`docs/research/2026-06-20-pi-teardown-collaboration-layer.md`）——C5 recovery 跨 N session，adopt 哪几个防 drift？（star>1000 不降级 vs demo 轻治理 平衡）
- **GOV5** 🔴 Mastra 形态（workflow graph→C4 DemoFlow / TrajectoryExpectation→C6 expected_tool_calls / observability→C3 五段 trace，`2026-06-20-mastra-teardown-workflow-eval-trace.md`）——C6 改 4 层后 adopt TrajectoryExpectation 契约？C4 DemoFlow 确定性编排在 demo-golden-run 怎么落？
- **GOV6** 🔴🔴 0/34+0/23 灾难根因之一 = codex 自主跑无中途验证 gate。机制升级：adopt Superpowers subagent-driven-development + verification-before-completion + writing/executing-plans，给重训阶段加「训练中途 C6 抽样 gate + 人 checkpoint」？
- **GOV7** 🔴 Pocock 分诊现停 S5 diagnose（recovery）。范式翻案后整个推进阶段重新分诊：哪些 change 回 S2 design / S3 spec？
- **GOV8** 🔴 OpenSpec change 拆分 + 依赖图：A2 codegen / C 组重训 / C4 评测 / B+C5 端侧 拆成几个 change？粒度 + 依赖排序（与 §14 依赖链 6→7→8/9→10 对齐）。
- **GOV9** 🔴 本轮范式翻案靠 subagent ground-truth + 三方辩证翻的，非 OpenSpec/Pocock 流程兜底发现。教训入治理：重大范式决策前强制派 ground-truth subagent（写进 collaboration §7 + CLAUDE §8 维护纪律）？
> GOV 优先级：GOV1/GOV2（specs SSOT 收敛）+ GOV6（防灾难 gate）最高；GOV3（级联 enforce）紧随。

### 组 CAS · SRD + 其他文件级联清单（磊哥维度②）
- **CAS1** 🔴🔴（meta-grill，先做）列全「范式翻案 + 第一/二批拍板」影响的**全部文件清单**逐个判改/不改/怎么改，别零散漏：CLAUDE §4/§5/§9 · D1-D37 decisions · SRD · baseline-semantic-protocol MASTER · integration-blueprint · roadmap(×2) · 各 ADR · CONTEXT.md · openspec specs。
- **CAS2** 🔴 SRD（`docs/srd-three-layer-intent-routing.md` 架构铁律）——surface 改 D-domain 具名工具后，SRD「L2 意图收缩 clarifyTag→FC 泛化」层描述要改？「FC 泛化」=「10 族内具名工具泛化」。
- **CAS3** 🔴 SRD L1 精做（~5 设备规则快路）vs MVP 10 族——L1 规则路覆盖哪些族？10 族全走 L1+L2 还是部分纯 LoRA？L1/L2 边界在 10 族下重定义（与 §14 fc_flags 分布对齐：车门纯 rule 路、座椅 EXP+SPOT 走 LoRA）。
- **CAS4** 🔴 SRD 分层执行兜底 L1/L2/L3/L4 vs 范式新 runtime tier（10 族 mock/族外 unsupported/越界/安全）——两套分层怎么对齐合并？
- **CAS5** 🔴 SRD「意图收缩+落域」——现场只说 10 族 + 约定后，收缩/落域收窄成「10 族内 + 族外 unsupported」？多 domain（导航/音乐/外卖 MCP 二期）标延后？
- **CAS6** 🔴 D1-D37 逐个核 supersede（CLAUDE §5）：D16 端态 / D30 训练栈(unsloth→mlx-lm 已变) / D35 bench(must-pass→4层) / D37 安全门 / D14 ASR——哪些被翻案/第一二批推翻，逐个标。
- **CAS7** 🔴 baseline-semantic-protocol MASTER（3990 金钥匙）——IR 层 value 四件套/抠槽/逆规整不变，补「surface 层 = D-domain 具名工具（intent==工具名/value 形态编码进名）」+ IR↔surface 两层关系说明？
- **CAS8** 🔴 roadmap-2026-06-20（CLAUDE §9 标旧基线）+ c5-recovery/roadmap.md + exec-plan.md——翻案后重写 vs 标 superseded+增量？新基线推进事实源定哪个文件（防多 roadmap 并存 drift）？
> CAS 优先级：CAS1（meta 全清单）必先做，否则后续零散级联漏文件（§35 教训）。

### 组 TRN · 后续 LoRA 训练机制（磊哥维度③，还没系统讨论）
- **TRN1** 🔴 P1-C 已定配方（LR1e-4/rank16Mainline/adamw+wd/repo-loop 裁剪/metrics.jsonl，`docs/p1c-training-grill-decisions.md`）是 generic frame 时代定的——翻案（判定面变小）后逐项重审（与 §14 议题 8 C2/议题 10 D1 衔接，C3 配方扩）。
- **TRN2** 🔴🔴 训练数据 SSOT 同源 enforce（claim-vs-reality 铁律1，0/34 train/eval surface mismatch 根因）：训练数据从 §14 议题 7 A2 codegen 目录派生，怎么 enforce train→eval→runtime tool surface 三处同源永不再 mismatch？（compiler 单源 + CI 硬门）
- **TRN3** 🔴🔴 训练中途 C6 抽样 gate（0/34+0/23 核心教训）：练到 iter50/100 抽样测 trigger 恢复，不练完 600 才发现全 0。early-stop / 中途门设计（与 GOV6 呼应）。
- **TRN4** 🔴 held-out 切法 + 数据门（P1-A C5DataGate must_not_train/parent_overlap/held-out）在 D-domain 具名工具 + 4 类数据下怎么改？按族切 vs 按 value 形态切防死记。
- **TRN5** 🔴 防假提升/防死记 3 HIGH（masking+held-out+IrrelAcc≥20%）翻案后仍成立？IrrelAcc（拒识率）在含 unsupported/safety negative 的 4 类数据下怎么测、阈值？
- **TRN6** 🔴 云 generator 语料机制具体化（§14 议题 C1 方向：云多源+异源 judge+contract 定标签+原文 oracle 红线+四类数据+distractor-in-prompt）——generator/judge 选型 + 量级(G3 ~400 seed×N) + 去污 + 红线 enforce（原文不进训练集）。
- **TRN7** 🔴 mlx-lm 0.31.1 本机能力边界：4 类×seed×N 变体数据量级，本机训练时长/显存够？checkpoint 频率(§14 D1 50/100/150)实跑可行性。
- **TRN8** 🔴 端侧 two-stage parity（mlx-swift）——受限解码(GBNF/Outlines)+具名工具端侧一致性怎么验（C5 扩）？训练态受限解码 vs 端侧 parity。
- **TRN9** 🔴 DoRA/训练技术升级排期（P1-C 定 V-PASS 后）翻案后还做吗？复杂推理「LoRA 学推理」后续升级位（§12 H 组预留）属哪个训练阶段？
> TRN 优先级：TRN2（同源 enforce）+ TRN3（中途 gate）最高，直接防 0/34 复发；与 §14 议题 7/8/10 衔接。

### 组 UIX · UIUE（41 维度调研，30+ 前端问题）按最新 grill 重讨论（磊哥维度④）
> 一手 = `~/workspace/raw/05-Projects/MAformac/research/2026-06-22-uiue-ultracode/`（8 lens × 79 findings + round2/round3 迭代 + pre-mortem 三分类 + adopt 清单 + grill 弹药；综合 README + lens1-8 一手档）。⚠️ **待磊哥确认「41 维度/30+问题」对应哪份清单**（round2/round3 维度文件 d0x），grill 时逐条过。
- **UIX1** 🔴 30+ UIUE findings/问题按最新 grill（MVP 10 族 + demo 取巧 + 现场只说 10 族）逐条三分：进 MVP demo（炸场必需）/ 因 10 族收窄不相关（族外 UI 不做）/ 砍（过度）。
- **UIX2** 🔴 10 族各自 mock 端态卡片视觉（亮暗+数值+图标+breathe glow），按 value.type 三分动效（SPOT 抠槽/EXP 逆规整/PERCENT，lens7/8）。哪些族卡片是炸场核心（与 §14 value.type 分布对齐：座椅 EXP+SPOT 最丰富）？
- **UIX3** 🔴 UIUE README §三 steelman 结论「守现状（深空辉光暗底三屏分层）+ native SwiftUI 弥合 gap」——翻案/10 族后仍成立？需 grill 重确认 vs 重起？
- **UIX4** 🔴🔴 工程化硬前置（README §六.1/elephant）：App target 缺 Info.plist/.entitlements（麦克风崩+OOM）——这是「能跑」非「美化」，是否提最高优先（G6 工程化前置）？
- **UIX5** 🔴 pre-mortem TIGER 现场炸场坑（证书7天/jetsam/低电量禁动画/Liquid Glass卡顿/mlx冻UI）——哪些「Mac 主设备」约定消除、哪些 demo SOP 必守（README §四+§六.8）。
- **UIX6** 🔴 三层路由 UI 态映射（L1 秒回 .animation / L2-5 PhaseAnimator / clarifyTag redacted+shimmer，§六.4）翻案后调？DialogueState 3 轮 + 歧义反问 UI 呈现（与 §14 second_turn_refs 高频族 空调/车窗/雨刮/香氛 对齐）。
- **UIX7** 🔴 语音交互 UI（barge-in 按钮打断 D13 / push-to-talk / 语音 orb 四态 / VUI 7 项缺 4：earcons/音量反馈/clarifyTag re-prompt/多模 handoff，lens4）——MVP demo 语音 UI 范围。
- **UIX8** 🔴 炸场剧本 UI 编排（demo-golden-run/五幕脚本/断网高潮 morph+「100%端侧·0网络」徽章/场景切换 morph+座椅多维联动=被低估最大 wow，README §四 elephant+§六.7）——视觉节奏，关联 F3 demo-golden-run κ。
- **UIX9** 🔴 adopt 组件（hanlin-ai/Orb/WhisperKit）落地过审美 5 Gate + **客户实际查看环境验收**（claim-vs-reality 视觉纪律：投影/iPhone 现场实查非高清导出）。
> UIX 优先级：UIX4（能跑硬前置）> UIX1（10 族重筛）> UIX2/UIX8（炸场核心）；其余炸场细节随 demo 落地。

### §15 待 grill 总数
GOV 9 + CAS 8 + TRN 9 + UIX 9 + **AUD 6** = **41 议题**（全 🔴未grill）。与 §11（A-G）+ §12（H）+ §13/§14/§16 已拍 合并 = C5 recovery 完整待 grill 池。

**🔴 组 AUD · 多轮审计 amend（A2 盘点 ultracode + codex 异源审计 + 主线程亲核，2026-06-22/23，最高优先=A2 派单地基；详 §17 多轮审计 amend）**：
- **AUD1** generated/ drift gate 补闭合（P0-1，已亲核 Makefile：`GENERATED_CONTRACTS` 仅含 contracts/ 无 generated/）。
- **AUD2** G2 工具数实算（562=intent 非工具数，534 已反转废→562，§14 终拍，按 value-form 实算，col O 在 xlsx 第15列）。
- **AUD3** A2 治理载体（OpenSpec change vs amend）+ 6 步依赖序 incremental（GOV2+GOV8）。
- **AUD4** demo(562)/full(1538) 两层 codegen 产物 + 都纳 drift gate（534 已反转废→562，§14 终拍）。
- **AUD5** train/eval/runtime surface 同源 enforce（TRN2，防 0/34）+ 训练中途 C6 抽样 gate（GOV6）。
- **AUD6** 文档级联全仓梳理（CAS1 meta，磊哥「工作量巨大务必梳理全仓」）：grep 全仓 tool_call_frame/set_cabin/B_frame/223/534/2086 定位过期点（534/2086 系列为废口径旧锚，562/2159 是终拍权威**非**过期点，§14；旧版误把 562 列为 grep 旧锚已纠 round-01）。

**建议批次（多轮审计后重排，AUD 最高优先=A2 派单地基）**：**第五批 = AUD2(口径)+AUD1(drift gate)+AUD3(载体切刀)+AUD6(全仓级联)+AUD5(同源 enforce)** → 第六批 GOV1/2/6 + TRN2/3 → UIX 落地 → GOV/CAS 剩余收尾。

---

## §16 第三+四批 grill 拍板（C5 LoRA 原始 21 议题收口）+ cite-verify + drift SUPERSEDED

> 2026-06-22 深夜，磊哥拍第三批「接受」+ 第四批 codex 辩证 + CC cite-verify。**至此 C5 LoRA 原始 21 主议题全部 grill 收口**（§13 第一批5 + §14 第二批5 + 本节第三批5+第四批6）。剩 §15 GOV/CAS/TRN/UIX 35 项扩散。
> 阅读序：§13→§14→**§16（原始收口）**→§15（扩散）。

### cite-verify 结论（codex 第三+四批 file:line，CC 全核）
codex 两批辩证 file:line **核心全部属实**，暴露 2 重大点 + 2 处 drift：
- ★ **重大1（动摇 B1/C5）**：`model-selection-2026-deepdive.md:215`「**mlx-swift 暂无 GBNF**」→ 端侧主线 = **LoRA 训格式 + JSON 三层防御解析**（home-llm 移植），GBNF 仅 llama.cpp fallback。**推翻第三批 B1「端侧 GBNF/xgrammar 受限解码」假设**（见下 B1 修正）。
- ★ **重大2（B2 真前置）**：`state-cells.yaml` 当前只有 **4 device cell 组**（ac/window/screen/ambient）+ safety_cells，**未覆盖 10 族**（:29 + 全 device 行核）→ B2 硬前置 = **state-cells 从 4 扩到 10 族**。
- per_seed≤8 有据（`generator-selection-probe.md:59`）；K_abs DEFERRED 属实（`grill-decisions.md:309`，不拍数）；demo-scenarios c6_seed_interim 非闭合（:19）；risk-policy R0-R3 单源（:23）但 **C1 contract 行 risk 字段全空**（未挂，F1 gap）；verify-cross-section 已有本地门（`Makefile:19`）。

### 2 处 drift → SUPERSEDED
1. `grill-decisions.md:367` 引 rank16Mainline `:1164-1188` 子行号**过期** → 实际 `C5LoRATraining.swift:1175`(func)/`:1180`(rank:16)/`:1181`(scale:20)。**SUPERSEDED**：配方 SSOT 以 `:1175-1188` 实际代码为准。
2. `paradigm:129` B1「~30-60 col O 筛」**已被 §14 G2「不拍 30-60 实算」推翻** → **SUPERSEDED**。

### 第三批 5 拍板（B1/C3/G3/D2/D3）— 接受 codex 纠偏 + CC 增量
| # | 拍板 | 物理落点 |
|---|---|---|
| **B1** | 受限解码只压 surface drift 非 intent error；🔴**端侧修正(重大1)**：端侧 mlx-swift 走 **LoRA 格式 + JSON 三层防御解析 + 挂载白名单(解析层 enforce)**，GBNF 仅 llama.cpp fallback；训练态可用 grammar。intent error 归 C4/D2 | A2 出 demo10 目录 → B1 出挂载白名单 + `tool_not_in_whitelist=0`(解析层) + 端侧防御解析；端侧 grammar 可行性 = C5 spike |
| **C3** | 守 `rank16Mainline`(:1175-1188)，不重开 recipe；只开 checkpoint 节奏 + TRN2 同源 enforce | baseline 不动(G6-C 只比 50/100/150 早期曲线)；新增 `verify-tool-surface-parity`(train/eval/runtime 三处从 A2 单源) |
| **G3** | scope_tier/高频低频/四类分层扩增 + per_seed≤8 | `data_recipe.yaml`: per_seed≤8 + source=derived\|augmented + label_authority=contract + judge_family!=generator + **四类配比+总量级(待实算)** |
| **D2** | `:356` 多条件 AND 门(防简化成单 >base10/23)；IrrelAcc demo 口径单定 | `experiments/g6c-named-tool-cell.v1.yaml` 固化 AND 门 + subset600/768 + ckpt50/100/150 |
| **D3** | precheck 非实验；训练只吃 A2 目录+B1 可挂载面 | precheck: generated/D_domain.tools.json + demo10 mounted + 防御解析/normalizer + `make verify` 绿(**需扩 verify 项**)；缺一不跑 G6-C |

### 第四批 6 拍板（B2/C5/F1/F3/G6/E2）— codex 辩证 + CC cite-verify + 增量
| # | 拍板 | 物理落点 |
|---|---|---|
| **B2** | 工具多→端态字段少→卡片更少；🔴**前置(重大2)=state-cells 扩 10 族**；映射在 code 非模型 | `generated/tool-card-map.demo10.json`: tool→IR{device,action,value}→state_cell_id→card_id→patch；接 `C3ExecutionPipeline:105` planTransitions→applyMockTransition；**先扩 state-cells 4→10 族** |
| **C5** | parity 拍，但**不预设端侧受限解码可行**；拆 `render_parity_diff=0`(阻 G6-C) + `endpoint_decode_spike`(没过不能宣称端侧 constrained decoding V-PASS) | parity harness 跑 golden_demo 两端 diff=0；端侧 decode spike 验 LoRA 格式+防御解析(非 GBNF) |
| **F1** | 安全动作**不能变模型可选工具**；θ-β 样本只训 `toolCalls=[]+safety_refusal 话术+risk_rule_ids`，拦截走 DemoGuard/riskPolicy(`C3:94`)；🔴**CC 错误增量已撤**（codex F1 纠偏，主线程亲核 `contracts/risk-policy.yaml:1,5` 确认）：~~risk 挂 C1 行~~ → risk **不挂 C1 行**（文件头明确「独立不写 C1」+ `verify_contract_invariants` 强制 risk 空、risk!="" 即报错、挂 C1 会炸 make verify + T2 耦合本 change 不做）；F1 真缺的是 θ-β safety_refusal 数据 + D-domain 后安全 eval | `contracts/risk-policy.yaml` 独立单源 R0-R3 + safety_refusal LoRA 话术 + 拦截走 riskPolicy.evaluate(`C3ExecutionPipeline.swift:94`)，**不动 C1 risk 字段** |
| **F3** | golden 100% 硬门；**K_abs 不拍数**(DEFERRED `:309`)；demo-scenarios 非闭合(`:19`)→先冻结 golden contract | `contracts/demo-golden-run.v1.yaml`: step_id/act_id/contract_refs/expected_route_derived/must_pass/c6_case_id_derived；`K_abs = required must_pass step count`(解冻后推) |
| **G6** | code 场景宏；🔴**宏不能引未挂载工具/未建 cell**(否则新脱靶源)；首批 4 宏(待磊哥点) | `contracts/scenario-macros.yaml` 3-5 个: id/trigger_tags/pre_state/steps/allowed_tools/required_state_cells/readback_template；首批建议=上车迎宾/离车收尾/雨天关窗天窗/夜间舒适；未挂载标 `planned_not_golden` |
| **E2** | 级联执行非设计；CAS1 先出 meta 清单→E2 只改命中文件→make verify verify-cross-section(`Makefile:19`) | CAS1 清单字段: target_file/section/old_frame/new_frame/gate；E2 收口靠现有 verify-cross-section |

### 合并点（不重复 grill）
C5 ≡ §15 TRN8 / E2 ≡ §15 CAS1（CAS1 列清单→E2 执行）/ F1 safety_refusal ≡ C1 四类数据 / G6 ≡ §12 H 组复杂推理预留。

### C5 LoRA 原始议题收口声明
**21 主议题全拍**（A1-3/B1-3/C1-5/D1-3/E1-2/F1-3/G1-6 + A1-A9 device）。剩 = §15 GOV/CAS/TRN/UIX 35 扩散 + G6 首批宏待磊哥点。

---

## §17 A2 代码盘点 ultracode 调研结论（级联，2026-06-22）

> ultracode 8 路 finder + 综合官（9 agent / 1.1M tok / 936s）盘点 C1→C2→C3→C5→C6 全链路 + 业内代码质量 + Swift/mlx codegen + A2 真实范围。**完整归档 → `docs/research/2026-06-22-a2-codebase-audit/`**（README 亲核版 + lens1-8 一手档 + codex-checks + INDEX；transcript 最一手归档仓外 raw `-transcripts/`）。主线程已 python 复算口径 + gh api 核 star。

> 🔴🔴 **A2 边界澄清（磊哥 2026-06-23 校准 + 延后升级，盘点正文不改，本边注覆盖范围定性）**：A2 = **code-only 范式对齐**——把代码改成说 D-domain + 编译/`swift test`/`make verify` 绿，**终点落老 C5 LoRA 训练之前，不训练 / 不评测模型性能 / 不生成语料**。下方依赖序 **[4] 仅"C5 样本生成器 surface 代码改"(预留接口) 属 A2**（§2.2 数据生成 / 实际重训 = DEFERRED）；**[5] 仅"C6 bench expected 迁 surface + 跑 base 验格式"属 A2**（四层门 / 跑 LoRA 评性能 = DEFERRED）；[6] parity gate 在 A2 = **结构回归门**（compiler 单测 + swift test + make verify + C6 跑 base，非模型性能门，性能 parity 延后）。**A2 只绑 `migrate-d-domain-tool-surface` change**；`retrain-c5`/`rebuild-c6`/`define-demo-golden-run-and-voice` 标 DEFERRED（训练/数据/评测/四层门/demo/voice/受限解码 = A2 之后独立重新立项）。执行 = 另一 CC 窗口 ultracode+/goal。派单 = `docs/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md`。

### A2 = 重型重构（坐实，非补丁）
- 范围：~14-16 文件（复用升级 8 / 重写 4-5 / 新建 2-3）、~1500-2500 行净改 + 生成物 diff 另计。
- 本质：model-visible surface 范式（generic frame `tool_call_frame` → D-domain 具名工具）是 C1 编译器核心 + 训练样本 + bench 期望三处共同输入，连带 state cells/执行映射/命名清债 = 磊哥「立项至今大部分代码改」量级。
- 依赖序（违反=返工）：[0]统一口径 → [1]Python codegen 产 D-domain 目录 → [2]ToolContractCompiler 消费 JSON → [3]state-cells 扩 10族+命名清债 → [4]C5 surface/正样本/用户文本 → [5]C6 MP/coverage/readback → [6]C6 parity gate 验收。

### 🔴 数字口径坐实（主线程 python 复算，A2 派单最关键）
- 全集 = 3990行/671 device/1538 intent（jsonl 实跑）。
- **device 权威 = 191**（`generated/10-family-device-map.json` = **223** 含 disputed = 旧 codegen 口径**过期**；boundary md 161/223 子串/精确混）。
- **intent 权威 = 562**（🔴 磊哥 2026-06-23 亲拍，§14；534=A1-A9 后旧口径已作废 / 507/680=boundary 子串口径）。
- **工具数 = 未拍待实算**（G2，col O 优先级在 xlsx 第15列不在 jsonl）；`generated/D_domain.tools.json`=6 是 spike 冻结。
- ⚠️ **「562」是 intent 数不是工具数**（🔴 磊哥 2026-06-23 亲拍权威，旧 534 作废）——A2 派单把 intent 数当工具数 = 口径错全链路（综合官最强 catch）。

### codex 6 处言论 cite-verify（workflow + 主线程）
全 confirmed（除「risk 挂 C1」是 CC 错误增量，codex F1 纠偏正确已撤，见 §16）。详 `docs/research/2026-06-22-a2-codebase-audit/codex-checks.md`。

### A2 关键坑（pre-mortem，详 README 附录 F）
- 🐯 大爆炸式一刀改完 = Netscape 红 flag → A2 必 incremental（每刀后 swift test + make verify 绿，旧路径 strangler 保活）。
- 🐯 训练面=推理面 parity（C5 0/34 根因 = 训/eval surface 异源）。
- 🐯 守 `rank16Mainline` 配方 + LR 1e-4（A2 是 surface 迁移非配方问题，不重开）。
- 🐘 parity gate 比「相对 A2-before 不退化」非绝对全绿（base 已 hard_fail）；生成物 commit 与手写 commit **分开**（jsonl 7.4M diff 淹没逻辑改动）。
- 🐘 frame surface 须**显式移除**（不靠 drift gate——它对 compiler-derived 的债不报警）。

### 守现状（steelman，别推翻）
Python codegen + Makefile 漂移门（⚠️ **codex 异源 catch + 主线程亲核 Makefile:4-9/51 坐实：`generated/` 产物 regen 后【不在】diff gate**——`GENERATED_CONTRACTS` 仅含 5 个 `contracts/` 文件无 `generated/`，CC 原断「generated/ 入仓=漂移门已闭合」**错**；A2 硬编码避免**必补** generated/ D-domain 产物进 `GENERATED_CONTRACTS`，否则 codegen 产物漂移无门）/ risk-policy 独立设计 / `rank16Mainline` 配方 / spike-e3 mlx pin / C1-C6 archived specs。A2 **不引入新 Swift codegen 框架**（Sourcery/SwiftSyntax = 造第二套 SSOT 反模式），只扩 Python codegen surface。

### 🔴 多轮审计 amend（workflow 综合官 + codex 异源审计 + 主线程亲核，2026-06-22/23）
> 综合官 README 是 **discovery pack 非派单合同**（codex 定性）。6 处 catch 全经主线程亲核确认，写回此处防误导执行：
- **P0-1 `generated/` 不在 drift gate**（已亲核 Makefile，见上守现状段）→ A2 必补。
- **P0-2 「intent=工具数」话术残留**：lens1/3/6 + README 后文仍有「具名工具/精确解=intent 数」→ 统一口径 = **191 device / 562 intent（🔴 磊哥 2026-06-23 亲拍权威，旧 534 作废）/ G2 工具数待 col O(xlsx 第15列)+value-form 实算**（562 是 intent 非工具数）。
- **P1-1 综合官输入截断**：workflow script `JSON.stringify(synthInput).slice(0,60000)` → README 是二次收敛非完整综合，**`lens1-8.md` 才是完整一手档**（INDEX 已标）。
- **P1-2 lens2 false positive**：lens2.md:436「NO DEFAULT CASE」**错**——`ToolContractCompiler:170/319 都有 default`（已亲核）；真问题 = default `return []/return` **静默吞** unknown tool/device 无日志。
- **P1-3 lens2 假标 fixed**（claim-vs-reality 活体）：lens2.md:643 标 `[x] P1a 已修复`，但 `C5DataGate:503` 仍 `try?`、`ContractLookups:62` 仍一行 map throw（已亲核）= **未修**，报告假标。
- **P1-4 lens3 设计草案非可执行计划**：lens3:22「40-60 files/8-12K lines」vs README「14-16/1500-2500」冲突 + 用 `Sources/MAformac/Generated/` 不贴当前 `Core/` 仓布局 → A2 范围**以实算为锚**，lens3 只吸收方向。
- **坐实不变**：ToolContractCompiler:23/50 frame+D 并挂 / C5LoRATraining:2362/2408/1767 / C6:420/1039 + _c6_axis_lib:11 / risk-policy 独立设计（F1 撤已确认）。数字口径锚 §14（🔴 磊哥 2026-06-23 亲拍 562 intent/191 device/2159 行，旧 534/2086 作废；全集 3990/671/1538），generated/10-family-device-boundary.md 旧 223/507/680 旁路不当口径。
→ **A2 不直接重写 C5+compiler**（codex 执行建议）：先补合同（generated/ 入 drift gate + G2 实算 + demo/full 两层产物）→ OpenSpec 切刀 → B1 受限解码单独 spike（mlx-swift-structured 74★/xgrammar 1752★ 已核 star，但「44K/唯一可用/100%精确」未验收不当事实）。

---

## §18 多轮审计收口拍板（2026-06-23：锦标赛 adopt + A2 合同 + GOV 拍板 + UIUE 第一批）

### 文档先行（磊哥 2026-06-23 定，已写 CLAUDE §7）
重大重构/派单前先把 spec/契约/级联/grill 文档做对再动代码（A2 重型实证）。本节即文档先行产物。

### grill SSOT 收口 = 锦标赛 41 题（归并 §15）
- **`docs/grill-tournament/final-grill-list.md` 41 题 = 待 grill 单一权威**（在 §15 基础上 codex 20-agent×5 轮精炼）；**§15 转 historical**（待 grill 以锦标赛 41 为 SSOT，避免两份清单 drift = Q22 精神）。
- 主线程 check 结论：可信（source=§15 精炼/评分 5 维/去重合并有据/数字未编/异源交叉验证 Q01·02·05·39=我亲核 P0-2/P0-1/G5/F1）。
- 🔍 ledger 一处措辞 catch：R4-Q02「broad parity already exists」**错**（parity 门未建，Q05 才建）。

### Q01/Q02/Q05/Q39 → A2 派单合同条款（已主线程亲核坐实，不再 grill）
- Q01 口径：191 device / 562 intent（🔴 磊哥 2026-06-23 亲拍权威，旧 534 作废）/ 工具数按 value-form 实算（562=intent 非工具数）。
- Q02 generated/ drift gate：generated/ D-domain 产物补进 `GENERATED_CONTRACTS`。
- Q05 surface parity：train/eval/runtime 三处从 A2 codegen 单源派生 + fail-closed。
- Q39 安全门：risk 独立不当 model-visible tool（F1 错误增量已撤）。

### GOV 层拍板（磊哥 2026-06-23 拍）
- **Q22** progress SSOT 单一化（旧 roadmap-2026-06-20 标 historical，新单源待定 = A2 exec-plan 候选）。
- **Q03** A2 起正式 **OpenSpec change** 承载（决策进 design/specs/tasks，非续 amend）。
- **Q13** change 拆分 + 6 步依赖序 **incremental**（禁大爆炸）。
- **Q41** 验收分层：T-PASS/G6-C/C6 model-quality/endpoint candidate/demo-golden-run/V-S-U-PASS 禁互相冒充。

### UIUE 第一批 U1-U10 拍板（磊哥 + codex cite-verify + CC verdict）
| U | 议题 | 结论 | 物理落点（codex 核 file:line）|
|---|---|---|---|
| U1 | 主演示设备 | ✅ Mac 主+iPhone 加分，**别写成免检牌** | `demo_sop.primary_device=mac` + `iphone_role=bonus` + preflight/fallback 表（Q34）|
| U2 | Liquid Glass | ✅ 只功能层 | UI token `surface_role=control_glass / content_glow`（非全局主题开关），内容卡绑 state/readback |
| U3 | 环形仪表 | ✅ 限连续值主卡 | tool-card-map.demo10.json 加 `presentation_kind=dial / card / badge`（座椅/灯光/音量优先，§14 value.type 支撑）|
| U4 | 氛围灯开场 | ✅ 进 MVP 作 **golden step**（非「铺满屏」本身进）| demo-golden-run.v1.yaml 一步 `visual_cue=ambient_color_wash + expected_state_delta + readback_tts`|
| U5 | Metal 水波 | 🔴 **一期做**（磊哥改，非二期）| Inferno RippleEffect 一期落 |
| U6 | App 工程前置 | 🔴✅ 最高优先 demo-blocker | A2/demo preflight：NSMicrophoneUsageDescription + memory entitlement + Release launch receipt（README:59 / Q33）|
| U7 | 保留 scheme1 | ✅ 但 ≠ 保留现状代码 | native SwiftUI translation（ContentView:121 现 7 态压绿/灰二值→补全，非重开审美/非 HTML 交付）|
| U8 | 演示编排 change | 🔧 **不新起独立** → 并入 demo-golden-run carrier | 项目已锁 demo 脚本单源 `contracts/demo-golden-run.v1.yaml`（grill-decisions:86）+ A2 切刀图 |
| U9 | golden-run | ✅ 升级「**合同回放**」非脚本回放 | `step_id/expected_state_delta/readback_tts/c6_case_id_derived`，未建 state cell 步禁进 golden（Q37）|
| U10 | 状态 UI 四态（clarify/unsupported/safety/crash，旧「三态」已废→见 master §3/U27） | 🔴✅ 最高优先 | 消费 `DemoVisualState` 7 态（DemoVehicleStateStore:17）+ trace guardReason/readbackResult，clarify/unsupported/safety_refusal/crash 分开显示（ContentView:51 现万能红字混=翻车，Q35）|
- 剩 **U11-U31**（R2-G4~G13 + R3-G1~G11）待续批。UIUE 源 = `raw/.../2026-06-22-uiue-ultracode/GRILL-MASTER.md`（31 条），归位 docs/research/ 待 codex 工作树空闲。

### A2 派单前 grill 弹药（8 议题，呈磊哥拍，详 README 附录 G）
口径锚定(562=intent非工具数，🔴 磊哥 2026-06-23 亲拍权威旧 534 作废) / 生成物两层 scope 入仓 / compiler 复用边界 / 重构切刀序 / parity gate 基线 / 端侧受限解码 adopt(mlx-swift-structured vendor) / 训练配方守不守 / 自然中文数据防假绿。
