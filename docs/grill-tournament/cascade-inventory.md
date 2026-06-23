# 文档级联修改 Inventory（第一个长跑基线）

> **生成**: 2026-06-23 · 综合官合并 4 路 reader 逐文件 verdict（T0 活基线/T1 契约 SSOT/T2-T3 决策清单/T4 UIUE+voice + openspec changes）+ 主线程亲核纠正。
> **用途**: 范式翻案（generic frame `tool_call_frame` 否决 → D-domain 具名工具，canonical IR 仍 device×action）+ A2 代码重构落地后，全仓文档的级联修改总账。这是【第一个长跑】的执行基线 = §35「重大决策→文档组级联」机械账本。
> 🔴🔴 **A2 边界（磊哥 2026-06-23 校准 + 延后升级）**：A2 = **code-only 范式对齐**（让代码说 D-domain + 编译/`swift test`/`make verify` 绿），**终点落老 C5 LoRA 训练之前，不训练 / 不评测模型性能 / 不生成语料**。**A2 只绑 `migrate-d-domain-tool-surface` change**；`retrain-c5`/`rebuild-c6`/`define-demo-golden-run-and-voice` 标 **DEFERRED**（训练/数据生成/C6 评测验证/四层门/demo/voice/受限解码 = A2 之后独立重新立项）。下方各文档 verdict 仍有效（文档照改）；本账本是「哪些文档要改」，A2 范围是「改到哪为止」。执行 = 另一 CC 窗口 ultracode+/goal，派单 = `docs/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md`。
> **权威口径（磊哥 2026-06-23 亲拍终结 534/562 纠结，全仓唯一权威 = 562）**: 全集 **3990 行**（source: `contracts/semantic-function-contract.jsonl` wc -l = 3990）/ **671 device** / **1538 unique intent**；10 族 **191 device / 562 intent / 2159 行**（占全集 54.1%）；族外 **480 device / 976 intent / 1831 行**。source: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:224` §14 口径终拍=「10 族 intent = 562 / 行 = 2159 / 54.1% / 族外 976 intent / 1831 行；device 191 不变」+ `:158` G4 + boundary 文件 `docs/research/2026-06-22-mvp-10family-device-boundary.md:3` 文档头「562/2159/976/1831 = 权威」。
> **🔴 562 vs 534 口径（磊哥 2026-06-23 亲拍 562 终结纠结）**：562 = A1-A9 边界歧义裁决**前**的 explicit-allowlist 全集（paradigm §13:211「候选全集 562(CC subagent allowlist)」）；534 = A1-A9 拍板**后** GLM `execute_code` 移出若干边界 intent。534 vs 562 仁者见仁，**磊哥不纠结、亲自拍 562 为全仓唯一权威口径**（paradigm §14:224 + boundary 文件头 `:3`）。device 数 191 两期不变，是因 A4 方向盘加热并座椅为**展示层**（技术 device 不变，paradigm §13），而非「计数方法差异」。**🔴 权威 = 562**；旧 **534 / 2086 / 52.3% / 族外 1004 / 1904 系列全作废**（禁再引，散落引用待第一个长跑级联回写）。族外口径配套 562：480 device / 976 intent / 1831 行（paradigm §14:231；= 3990-2159 行 / 1538-562 intent）。
>
> 🔴 **本段角色（finding round-03）= 562-vs-534 解释性 narrative，非废口径权威定义表**。废口径的【权威定性】单一物理副本 = `grill-decisions-master.md §0 口径权威表`（本段内联的 534/2086 等数值仅作 narrative 叙述其来龙去脉，供级联执行者理解 delta 上下文，引用废口径定性以 master §0 为准）。master §0:24 已同步修正措辞（不再声称「cascade §0 删除内联列举仅留指针」——本 narrative 段有上下文价值、保留）。
> 🔴 **工具数未拍待 value-form 实算（562=intent 非工具数，派单当工具数=口径错全链路）**。
> **🔴 废口径（claim-vs-reality 第10变体，禁再引）—— 废口径【权威定义】单一清单 = `grill-decisions-master.md §0 口径权威表`（禁在本文复制其权威定义）**。废口径的权威定义只在 master §0 表格物理存在一处；本文不另建第二份权威表，引用废口径定性前一律指回 master §0（兑现 Q22 + §35 SSOT 单一化，消除「本处随之同步」的手工同步义务 = drift-waiting 反模式；finding 2026-06-23 第四轮）。**注（finding round-01）**：下文 §4.3 是【回写操作映射表】（污染出现位置→修正动作），非废口径权威源——其列举的废口径数值仅作「在哪出现、改成什么」的操作锚，权威定性以 master §0 为准；§4.3 不是「再内联列举一份权威表」。

---

## 1. Executive

### 1.1 总量
- **两口径（2026-06-23 逐 Tier 重算坐实，replace 旧 134/95/T5-58 错值）**:
  - **口径 A — 显式逐条 verdict 行 = 87**（= §2 各 Tier 表实际 verdict 行求和 8+25+5+31+3+**11**+4=87；T5 在 §2 按【类别×path 集合】列 = **11 个 category 行**，非逐 path 展开）。**决策审阅用 A**（每行一个 verdict 判定）。
  - **口径 B — 全 path 覆盖 = 153**（= T5 把 11 个 category 行展开为单 path 后求和 8+25+5+31+3+**77**+4=153；T5 path 集合 = 75 banner-batch + 2 no_change = 77，path-set 计数已 `ls`/`find` 实测，见 §1.2 T5 注 + §3 并行轨）。**下游完整性 check 用 B**（全 path 不漏覆盖）。
  - 去重：reader 4 路对若干 path 重叠 verdict（`baseline-semantic-protocol` / `paradigm-tool-surface` / `function-spec` / `demo-must-pass` / `define-intent-routing`）已合并单条 + 主线程补 3（`vehicle-capabilities` no_change / `demo-golden-run.v1.yaml`+spec new_file 捆绑 / 去重合并）。
  - 🔴 **旧值 134/95/T5-58/56 已废**（账本自身 drift：旧 T5=58 与实测 path-set 77、旧总和 134 与逐 Tier 重算 153/87 分叉，2026-06-23 逐 Tier awk 复算纠正）。
- **🔴 自检（§35 级联机械账本，每改一波必跑）**: §1.2 各 Tier「条目数」+「verdict 分布」= §2 同 Tier ```| `path``` ``` 行的 awk 复算（`awk -F'|' '{print $3}' | sort | uniq -c`），否则机械账本自身就 drift（finding 2026-06-23 第二轮：§1.2 T0/T1/T3/T4 四项与 §2 段间分叉，已纠）。**复算范围 = §1.2 ↔ §2 ↔ 各阶段段（§3 阶段 1-6）三方一致**（finding 2026-06-23 第三轮：阶段 5 标题「3 new_file」与 §1.2 T4「1 new_file」分叉——voice-pipeline/demo-golden-run 两 new_file 已归 T1 不在 T4 重复，阶段段 new_file/modify 计数须与 §1.2 同 Tier 行对齐，已纠为「2 modify + 1 new_file」）。**finding 2026-06-23 第五轮（本轮）**：① §1.1 旧 headline「134 / 95」+ §1.2 T5「58 / 56」+ 阶段 1「11 modify」+ 阶段 2「6 modify」全与 §2 实际行数分叉 —— 逐 Tier awk 复算坐实口径 A=87(verdict 行) / 口径 B=153(全 path) / T5=11 行·77 path(banner 批 75)，阶段 1=9 modify、阶段 2=7 modify+CLAUDE 微改，全部回写对齐；② T5 path-set 计数 `ls`/`find` 实测（handoffs 25 / dispatches 13 / second-review 9 / gitnexus 5 等逐组），禁手写。
- **去重说明**: 4 路对若干 path 给了重叠 verdict（如 `baseline-semantic-protocol`、`grill-decisions-amend-paradigm-tool-surface.md`、`maformac-function-spec-2026-06-19.md`、`demo-must-pass-candidate`、`define-intent-routing`），已合并为单条并取最高优先级 + 综合 what_to_change。

### 1.2 各 Tier 计数（去重后）

| Tier | 含义 | 条目数 | verdict 分布 |
|---|---|---:|---|
| **T0** | 活基线（新 session 起手读） | 8 | modify 8 / no_change 0（`CLAUDE.md` 虽 modify(微)、2 个 modify(banner) 仍属 modify；§2 T0 表 8 行全 modify 变体） |
| **T1** | 契约 SSOT | 25 | modify 9 / no_change 11 / mark_historical 3 / new_file 2（new_file 按 §2 verdict 行计=2，其中 `demo-golden-run.v1.yaml`+`openspec/specs/demo-golden-run` 同 1 行捆绑 2 path） |
| **T2** | 决策逐条标状态 | 5 | no_change 4 / modify(P0) 活决策源 1 |
| **T3** | grill SSOT 统一 | 31 | modify 2 / no_change 28 / mark_historical 1（`grill-decisions-amend-g6c-design.md` 已标 SUPERSEDED 头） |
| **T4** | UIUE + voice 落档 | 3 | modify 2 / new_file 1（`docs/research/2026-06-22-uiue-ultracode`；`voice-pipeline`/`demo-golden-run` 两 new_file spec 归 T1 已计，不在 T4 重复） |
| **T5** | 历史快照（批量 banner） | 11 行 / 77 path | §2 按 path-set 列 = **11 个 category 行**（口径 A 计 11）；展开 = **77 path**（口径 B 计 77）= mark_historical 75（进 banner 批）+ no_change 2（`_TEMPLATE.md` + `p1-b-qwen-spike-dispatch.md`，dispatches 内，不进 banner 批）。**banner 批口径=75**（§1.3/§3 的「banner 批」指此；旧「56」已废）。🔴 path-set 计数 `ls`/`find` 实测：handoffs 25（−1 no_change=24 banner）/ dispatches 13（−2 no_change=11 banner）/ second-review 9 / gitnexus 5 / 其余按 §2 列表逐组实测加和=75 |
| **T6** | 脏区清理 | 4 | delete_or_park 3 / mark_historical 1 |

> 注：同一 path 可能跨 Tier 被不同 reader 标（如 spec.md 既 T1 又被另一路标 T0），表内按【主归属 Tier】合并，跨 Tier 差异在 what_to_change 注明。

### 1.3 第一个长跑范围

| 范围 | Tier | 动作 |
|---|---|---|
| **活改区**（逐文件改正文/补段） | T0-T4 | modify / new_file — 范式翻案 + D-domain surface + 口径统一逐条落 |
| **脏区清理** | T6 | _parked 确认 + 废文件 banner/移除 |
| **批量 banner**（不改正文，只加 SUPERSEDED/HISTORICAL 头） | T5 | 75 个历史快照批量标 historical（脚本化批次；path-set 实测，旧「56」已废）。🔴 **状态 = PENDING（finding round-01 实测：handoffs 0/25、dispatches 0/13、tech-baseline-from-raw、c5-recovery/roadmap 均未加 banner）** —— T5 banner 批是【长跑后续批次】，尚未跑，非「已一次过」 |
| **不动**（已对/已权威） | 全 Tier no_change | 仅核对完整性，正文不改 |

### 1.4 主线程亲核纠正（覆盖 reader 原始 verdict）

1. **CLAUDE.md → modify（finding round-03 升级，原标 verify-only 漏 Q22）**：口径维度已落（§9 banner :111 收口 21 议题 + :113 tool_call_frame→D-domain + `device 191 / intent 562`/工具数未拍，534→562 回写已落）。🔴 **但 Q22 强制同步漏掉**：CLAUDE.md:115/:130 仍称旧 roadmap-2026-06-20 为「唯一推进事实源/必读第一」，与 Q22 已拍（roadmap 标 historical，新单源=grill SSOT + A2 exec-plan 候选，master §2:77 明文「同步 CLAUDE/README/handoff 模板」）矛盾 → finding round-03 已加 historical 注 + 改起手读顺序（grill-decisions-master/paradigm/cascade 升必读第一，旧 roadmap 降溯源）。原 verify-only 把 Q22 的 CLAUDE 同步漏成「无须改正文」= §35 级联未落地，已升 modify。**仅核**：工具数占位是否随 value-form 实算更新 + grill 批次锚点。
2. **补 `vehicle-capabilities` spec（reader 漏）**：`openspec/specs/vehicle-capabilities/spec.md` 实际存在（已是「车控能力契约已迁移至 C1/C2(本能力降为指针)」墓碑 spec），无范式漂移 → `no_change`。
3. **🔴 口径权威 = 191/562/工具数未拍，非 534**（磊哥 2026-06-23 亲拍 562 终结纠结，**覆盖本文先前版本的 534 权威定性**）：旧 inventory 曾按 paradigm §14 旧版把 534 当坐实权威、562 标废；磊哥 2026-06-23 亲自拍板 **562 为全仓唯一权威**，534/2086/52.3%/族外 1004/1904 系列**全作废**（paradigm §14:224 + boundary 文件头 `:3`）。任何文档级联以 562 为准。**562 vs 534 = A1-A9 边界裁决 delta**：562（A1-A9 前 explicit-allowlist，paradigm §13:211）；534（A1-A9 后 GLM execute_code 移出若干边界 intent）—— 磊哥不纠结、拍 562 终结。device 191 不变是因 A4 方向盘加热并座椅为展示层（技术 device 不变，paradigm §13），非「计数方法差异」。✅ **CLAUDE.md 已落 562（:113 行，2026-06-23 回写，本账本所有 CLAUDE-row 不再标待改，仅 verify-only）**（finding round-02：消除账本把已落项当 pending 的 drift）。
4. **`new_file` 三处确认不存在**：`openspec/specs/voice-pipeline`、`openspec/specs/demo-golden-run`、`contracts/demo-golden-run.v1.yaml` 实查均 NOT FOUND，new_file verdict 成立。
5. **`final-grill-list.md` 已部分有 Status 结构**：实查表头已含「优先级 + 来源轮次」+ Q01 已锚口径实算，reader 要加的 Status 列/映射表仍有效但属增量，保持 modify P1。

---

## 2. T0-T6 逐文件 inventory（按 Tier 分组）

### T0 — 活基线（新 session 起手读）

| path | verdict | what_to_change | priority |
|---|---|---|---|
| `CLAUDE.md` | **modify（finding round-03 升级，原 verify-only 漏 Q22）** | §9 banner（:111 行）已收口 21 议题 + :113 行已有 tool_call_frame→D-domain + **`device 191 / intent 562`/工具数未拍**（口径 534→562 回写已落，:113）。🔴 **finding round-03 新增改点（Q22 已拍强制同步）**：CLAUDE.md:115「⭐唯一推进事实源=roadmap-2026-06-20」+:130「必读第一」与 Q22（roadmap 标 historical，新单源=grill SSOT + A2 exec-plan 候选）矛盾 → 已加 historical 注 + 改起手读顺序（grill-decisions-master/paradigm/cascade 为必读第一，旧 roadmap 降为溯源）。原 verify-only 漏掉 Q22 强制的 CLAUDE 同步（master §2:77「同步 CLAUDE/README/handoff 模板」）= §35 决策→文档组级联未落地，故升 modify。**仅核**：工具数占位是否随 value-form 实算更新 + grill 最新批次锚点 | P1 |
| `docs/README.md` | modify | ①「Decisions 状态总览」补 D14 ASR『跨厂商二审改』改点（Paraformer/SenseVoice 中文抗噪依据）②「下一步候选 ABC」整段 v1 历史 → 标 SUPERSEDED 指向 roadmap ③新增「T2 决策统一(2026-06-22)」行：paradigm §1-§17 + final-grill-list 41 + UIUE 31 ④权威源修正：以 paradigm-amend + final-grill-list 为权威 | P0 |
| `docs/srd-three-layer-intent-routing.md` | modify | 三层路由仍有效但 surface 已翻案：①加「surface framing」段（D-domain 具名工具 vs 旧 generic frame）②「L2 runtime 泛化覆盖」叙述改「10 族内泛化 + 族外 unsupported」（非「兜底全集」）③补 canonical IR 分层定义④🔴 **训练范围断言修正（finding round-04，原 SRD:95/206「LoRA 训练层=全集 3990 泛化/训练锚全集」违 A3）**：SRD:95/206 改「LoRA 训练层 = 10 族 562 intent scope（按 scope_tier 拆四类数据），不训全集 3990」（A3 已拍 10 族不训全集；3990 = canonical IR 派生源/value-form 变体来源非训练 scope），cite §13.A3:126/§16:216。**注**：③(runtime 族外 unsupported) 与 ④(训练范围 562 不训全集) 是两件事——runtime 覆盖 vs training scope，别合成一条 surface narrative。标「v2 pending CAS2 grill」。**注**：另一路标 no_change（§4 端侧映射已述确定性 code）→ 取 modify（surface 段 + 训练范围段确需补） | P1 |
| `docs/baseline-semantic-protocol-2026-06-19.md`（MASTER） | modify(banner) | IR 层（device×action）不变，只 surface 翻案。文档头加 banner：「本文档定 canonical IR 层；model-visible surface 已翻案为 D-domain 具名工具（见 paradigm §1-§2），surface 层不在本文档」。§3「capabilities.yaml 错在哪」+ §4 内化方案补注「device+primitive→D-domain 工具名」（数量待实算） | P2 |
| `docs/roadmap-2026-06-20-from-c6-done.md` | modify(banner) | ①§3 H3 注（P0 收尾已含 P0-1/2/3/4）②补「D-domain 工具数实装确认」= A2 派单前置门（191 device / 562 intent 是 intent 粒度需映射工具数；口径 562 = 磊哥 2026-06-23 终拍）③§11 依赖图：C6 readback 改 renderReadback(SSOT) 后补 D-domain 工具契约来源声明。**注**：另一路标 mark_historical（待生成 roadmap-2026-06-23）→ 当前仍是推进事实源，先 banner 标 surface 演进，新 roadmap 待 grill 收口后写 | P1 |
| `docs/lessons-learned.md` | modify | ①§49 补 D-domain 工具数[TBD 待实算] + model-visible surface→具名工具映射引用 ②§50 补 action hard_pass 复算口径（base 10/23 硬锚）+ 脱敏规则 ③新增 §51「T2-T3 三源统一经验」：旧数字跨段分叉(534↔562，磊哥 2026-06-23 终拍 562)/SUPERSEDED 缺失/映射不清 = §35 高阶问题 + SUPERSEDED 标记制式规范 | P1 |
| `CONTEXT.md`（**仓根**，非 docs/） | **modify ✅DONE（finding round-04 执行）** | 🔴 **路径修正（finding 2026-06-23 round-01）**：文件在仓根 `./CONTEXT.md`（CLAUDE §3 引用的也是根 `CONTEXT.md`），非 `docs/CONTEXT.md`（不存在，误建会 SSOT 分叉）。✅ **round-04 已落三章**：①「Grill 权威索引」章（grill-decisions-master / paradigm / cascade / boundary / a2-audit 路由表）②「口径权威」章（3990/1538/671 全集 + 191/562/2159/54.1% 10 族 + 480/976/1831 族外 + 工具数未拍 + 废口径禁引 + 三层 scope）③「T0-T6 文件分层」章 + 「范式翻案」章（IR/surface/runtime 三层模型）。术语段保持。 | P0 |
| `docs/integration-blueprint.md` | **modify ✅DONE（finding round-04 执行）** | 已有「v2 扁平 capabilities 被 C1 supersede」标记（line 217）。✅ **round-04 已加头部范式演进 banner 三改点**：①surface 层演进（generic frame→D-domain，θ-α 0/23 根因）②训练/eval/runtime surface 三处同源 enforce（TRN2 / Q05）③10 族演示 scope 三层边界（10 族 191/562/2159 + 10 族内 LoRA 泛化 + 族外 480/976/1831 unsupported；LoRA 训练 562 不训全集）。 | P1 |

### T1 — 契约 SSOT

| path | verdict | what_to_change | priority |
|---|---|---|---|
| `openspec/specs/semantic-function-contract/spec.md` | modify | §Purpose 填 TBD：「C1 契约源行级全集(3990)，派生自冻结快照，device×action-primitive×slot 三元 + value 四件套，device/primitive 是 D-domain 具名工具生成的源，非 generic frame」。Requirement 补 exec_tier=L1 仅从 reviewed l1-demo-allowlist 派生 + 对齐 D-domain 集合 + 停用 tool_call_frame 映射。**注**：另一路标 no_change → 取 modify（Purpose TBD 必填 + surface 边界声明） | P1 |
| `openspec/specs/scenario-state-protocol/spec.md` | no_change | C2 自包含 mock 态，与 surface tool 形态正交，无漂移。**仅补 Purpose TBD** | P0 |
| `openspec/specs/tool-execution/spec.md` | modify | ①工具调用帧形态 = D-domain 具名工具[device+primitive 枚举]×slot×value[四件套]，不再 generic `tool_call_frame{device,action,value}`；场景示例改真实工具名 ②DemoGuard 读 D-domain 白名单(非 generic frame)，过期 tool_call_frame 从 scope 删 ③补 Purpose TBD | P1 |
| `openspec/specs/vehicle-tool-bench/spec.md` | modify | ①qwen-tool-call-format.yaml 应定义 D-domain 工具名集合与字段映射(非 generic frame) ②评测分层：golden 100% 硬门 / demo_fuzz / unsupported / safety 各独立门 ③expected_tool_calls 从旧 6 工具扩到 10 族炸场子集 ④Purpose TBD：base Qwen3-1.7B hard_fail 0.789 为 LoRA 提升锚点 | P0 |
| `openspec/specs/demo-experience/spec.md` | no_change | 行为契约不涉 surface 形态（tool 名 vs frame = 实现细节）。**仅补 Purpose TBD** | P0 |
| `openspec/specs/lora-training/spec.md` | modify | samples 中 expected_tool_calls 映射到 D-domain 具名工具(非 tool_call_frame)；sample_shape「tool_call_frame」改「D-domain 工具集」。**注**：Purpose 已填(非 TBD) | P2 |
| `openspec/specs/vehicle-capabilities/spec.md` | no_change | **(reader 漏，主线程补)** 已是墓碑 spec「车控能力契约已迁移至 C1/C2(本能力降为指针)」，无漂移 | P0 |
| `contracts/capabilities.yaml` | mark_historical | 仍是源但 `set_cabin_ac` 等 7 工具名为旧 B-frame 示范；A2 后升 D-domain。加 HISTORICAL banner（v1-B-frame-archived / 升级目标 D-domain 具名工具，见 paradigm §15-§17） | P0 |
| `contracts/semantic-function-contract.jsonl` | no_change | 源行级全集(3990)，device/原语/value 四件套正确，无漂移（A2 改的是 demo surface 工具名生成器，jsonl 不改） | P0 |
| `contracts/state-cells.yaml` | modify | execution_range 注释准确(18-32/1-10)；补「execution_range 权威 = C2 拥有，与 D-domain 工具映射独立」+ air_conditioner cell 注「对应 D-domain 工具中 ac_temperature 设备维度」 | P2 |
| `contracts/l1-demo-allowlist.yaml` | modify | allowlist primitives 仍准确；补「primitives 集合对应 D-domain 具名工具名空间该设备细分(adjust_ac_temp_to_number vs raise_ac_temp_by_exp)，非 generic frame 参数」+ allowlist_pending_c2 标 D-domain 设备映射 | P1 |
| `contracts/demo-scenarios.yaml` | modify | ①每场景「期望 ToolCall」映射 D-domain 具名工具名 ②expected_tool_calls 改对应真实工具集合 ③路由路径标注补 clarifyTag 对应 D-domain surface（implicit 才调慢路） | P1 |
| `contracts/qwen-tool-call-format.yaml` | modify | ①tools 字段列 D-domain 具名工具全集（数量待实算）②补 wrapper 说明 enable_thinking=false 与非 generic-frame 关系 ③补 parser 针对 D-domain 工具名的 extraction 规则。**注**：现仅 model_family/parser/wrapper 元信息，缺工具集 | P1 |
| `contracts/function-spec-full.yaml` | mark_historical | 生成物(C1 codegen)仍反映旧 generic frame 平铺。加 HISTORICAL banner(v1-generic-frame-archived / A2 后用 D-domain 生成器重派生 / 671 device×primitive→若干 D-domain 工具，数量待实算) | P0 |
| `contracts/risk-policy.yaml` | no_change | 行为约束(禁开车门等)与 tool surface 正交，无漂移 | P0 |
| `contracts/c6-bench-cases.jsonl` | modify | expected_tool_calls 现状（finding round-04 实测，replace 旧错述「57 行仍旧 frame」）= 57 行中 **34 行用旧 B-frame 粗具名工具**（`set_cabin_ac`/`set_cabin_fan`/`set_cabin_window`/`set_cabin_ambient_light`/`set_cabin_screen_brightness`/`query_cabin_comfort`，0 用 generic `tool_call_frame`，同 capabilities.yaml 自述「旧 B-frame 式」）+ **23 行空**（negative/no-call，`expect_no_call=true`）；A2 后 migration（旧粗具名 `set_cabin_*` → D-domain 细具名 `adjust_ac_temperature_to_number` 等）；P0-3 陷阱样本同步确认 expected 工具名 | P0 |
| `contracts/source-snapshot-manifest.yaml` | no_change | 只记冻结快照指纹，无漂移 | P0 |
| `contracts/function-spec-full-v0.yaml` | mark_historical | 参考模板(reference_template 手工样板)非权威源(C1 SSOT=jsonl)；已标 DO_NOT_USE，保留作 codegen schema 参考 | P2 |
| `docs/qwen3-engineering-notes.md` | no_change | Qwen3-1.7B 工程硬约束(10 条)，C3/C5/C6/C7 propose 引用，本地实证确认，不废 | P0 |
| `docs/project/collaboration-and-roles.md` | no_change | 协作角色定义(2026-06-20 更新)，治理活文档 | P0 |
| `docs/adr/0001-generated-full-contract-with-mixed-delivery.md` | no_change | status=proposed 应升 Accepted；层级架构(JSONL 行级+dedupe+分流账本)+冻结快照+manifest+drift gate 范式翻案后仍有效，Q10 被 Oracle 验证正确，勿改 | P0 |
| `openspec/changes/define-lora-data-gate` | no_change | active change 设计冻结；C5 recovery grill 决策已在 grill-decisions C1-C2 段(四类数据+masking)拍板；载体待 GOV2 转正式 change | P1 |
| `openspec/changes/run-lora-candidate-training` | no_change | active change 被多处 amend 但 change 本身未改；待 AUD2/AUD5/§16 B2 补全后 incremental；现状 0/34 candidate UNSIGNED/BLOCKED 保持 | P1 |
| `openspec/specs/voice-pipeline`（**new_file**） | new_file | 缺失规范：吸收 voice-pipeline-from-raw.md 的 ASR/TTS/VAD 决策 + SFSpeechRecognizer 主/WhisperKit/sherpa fallback + AVSpeechSynthesizer + promptTokens 热词 + SpeechTextNormalizer 层 + 8 态机，作 C1-C3 上游契约 | P1 |
| `contracts/demo-golden-run.v1.yaml` + `openspec/specs/demo-golden-run`（**new_file**） | new_file | T1 契约新建：SSOT schema=[step_id/act_id/utterance_zh/expected_readback/source_contract_row/contract_refs/expected_route_derived/must_pass/uiue_scene_tag/c6_case_id_derived]；关联 C6 must_pass + UIUE 五幕 + L1 覆盖；待 F3(K_abs) 后冻结 | P0 |

#### T1 — 新 OpenSpec change skeleton（本长跑产出，finding round-01 补记）

> 🔴 **本长跑核心 OpenSpec 交付物 = 4 个 change skeleton（2026-06-23 创建，`openspec list` 可见，validate valid）**，此前账本漏记（finding round-01：以本账本为 SSOT 的后续 session 不知其存在 = 重复创建/漏 propose 风险）。全为 **DRAFT 待人审 propose（守 agree-before-build，不进 apply / 不写实现代码）**。决策权威源 = `grill-decisions-master.md` Q03（A2 起正式 change）+ Q13（change 拆分 + 6 步依赖序 incremental）。

| change path | verdict | 决策权威源 | 依赖序 | 待 propose 状态 |
|---|---|---|---|---|
| `openspec/changes/migrate-d-domain-tool-surface` | new_change_skeleton(DRAFT) | master Q03/Q13 + paradigm §17 依赖序[1] | [1] D-domain codegen（上游，先）| DRAFT 待人审 propose |
| `openspec/changes/retrain-c5-lora-d-domain` | new_change_skeleton(DRAFT) | master Q03/Q13 + paradigm §16 C 组 | [4] C5 surface/正样本（依赖 [1]）| DRAFT 待人审 propose |
| `openspec/changes/rebuild-c6-four-layer-bench` | new_change_skeleton(DRAFT) | master Q03/Q13 + paradigm §16 议题9（4 层评测）| [5] C6 MP/coverage/readback | DRAFT 待人审 propose |
| `openspec/changes/define-demo-golden-run-and-voice` | new_change_skeleton(DRAFT) | master Q03/Q13 + Q37(F3 golden) + ASR/TTS amend | 横切（golden + voice 契约）| DRAFT 待人审 propose |

### T2 — 决策逐条标状态

| path | verdict | what_to_change | priority |
|---|---|---|---|
| `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` | no_change | C1 Q1-Q10 Oracle 加深，T2 决策权威(✅7+⚔️3，HIGH SSOT 坑钉死)；待 C1/C2 archive 后逐条标 keep/modify/superseded/defer，目前活决策源 | P0 |
| `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` | no_change | **范式+surface 权威 SSOT**（§1-§17：翻案/三层模型/demo 特性/多语种/过度工程化 catch/21 议题全收口/A2 盘点；剩 §15 GOV/CAS/TRN/UIX 35 扩散待 grill）。勿改正文 | P0 |
| `docs/research/2026-06-22-a2-codebase-audit/`（README + lens1-8） | **banner（finding round-03，原 no_change 不对称漏 README banner）** | A2 代码盘点(ultracode 8 finder+9 agent+亲核)；16 处不对齐全表 + 数字口径(README 记 191/534 = A2 盘点时口径，**全仓权威已被磊哥 2026-06-23 终拍为 562**；A2 派单时以 562 为准)/工具数未拍 + 6 步依赖序；A2 派单前必读权威依据。🔴 **finding round-03**：README 是 CLAUDE 明文「A2 派单前必读」doc，正文 5+ 处断言「534=权威」无 in-doc override → boundary 文件已加 562 banner 而同等被引的 README 没加 = 不对称处置 → 已在 README 头加 562 override banner（指回 master §0 + paradigm §14:224，正文 benchmark 历史值保留不改） | P0 |
| `docs/research/2026-06-22-mvp-10family-device-boundary.md` | **modify(P0)** | 10 族设备边界(paradigm §13 G4 拍板权威)。🔴 **正文 562 = 权威（磊哥 2026-06-23 终拍）**：boundary 文件正文(:3 文档头 + :41 intent 计数说明 + §1 per-family 表 + §2 族外 + §4 G2)持 **562 intent / 2159 行 / 54.1% / 族外 976 intent / 1831 行 = 全仓唯一权威**，旧 534/2086/52.3%/族外 1004/1904 系列在文件内已标作废。device 191 不变(A4 方向盘加热并座椅为展示层)。⚠️ **先前 inventory 记的「已回写 562→534/内联标 SUPERSEDED」是 534-权威时代旧动作，已被磊哥 2026-06-23 拍 562 supersede——boundary 文件正文已重置回 562，与本文头口径一致，无须再改正文**；本行保留 modify 仅作 562 级联追踪锚。坐实值=191/562/2159(54.1%) / 族外 480/976/1831(paradigm §14:224)。U13 拍板(卡片按 10 族 family_card_id)仍成立。🔴 **§3/§4 拍板状态级联（finding round-01 补）**：boundary §3 header 旧标「待磊哥拍」+ Q-A4 旧列 steering_wheel_heating「⭐建议族外」+ §4 「+1 device」微调句，均与 paradigm §13 A1-A9 终裁(A4 展示层并座椅·技术 device 独立·191 不变)矛盾 → 已在 boundary 正文加「A1-A9 已拍」边注 + Q-A4 改标已拍 + §4 删/改 +1 device 句(round-01 已执行)。下游执行者勿据 §3「待拍」推进 | P0 |
| `docs/优化待讨论-吸收内化措施38项-2026-06-20.md` | no_change | 38 项吸收措施总表 + Q1-Q6 grill 结论 + #39/#40；C3-C7 解冻前 adopt/backlog 入口，活文档(grill tournament 前置) | P0 |

### T3 — grill SSOT 统一

| path | verdict | what_to_change | priority |
|---|---|---|---|
| `docs/grill-tournament/final-grill-list.md` | modify | ①表头加 Status 列(🔴未grill/🟡部分/✅已拍)区分 C5 原始21 vs §15 扩散35 ②新增「映射关系」表：41 题映射 paradigm §13(G1-5)+§14(6-10)+§16(三四批)21 题 + §15(GOV/CAS/TRN/UIX)35 议题（source: paradigm §16:367「剩 §15 GOV/CAS/TRN/UIX 35 项扩散」/ §16:403；AUD 6 已转 →A2合同不计扩散，5 组含 AUD=41 见 §15:351「GOV 9 + CAS 8 + TRN 9 + UIX 9 + AUD 6 = 41 议题」）③标 final-grill-list=运行清单，paradigm §11-§17=拍板清单，同源。④**Q01 口径 534→562 裸锚回写**（finding round-02：:7 题面告诫例旧裸锚 534→562 终拍权威，与全仓一致，562=intent 非工具数；ledger:15 同步）。**注**：现表头已有优先级+来源轮次+Q01 锚口径，Status/映射属增量 | P1 |
| `/Users/wanglei/workspace/raw/05-Projects/MAformac/research/2026-06-22-uiue-ultracode/GRILL-MASTER.md` | modify | UIUE 31 条(R1-R3)：①R1-R3 逐条映射 final-grill-list UIX1-9(R2-G3→UIX1 三态/R1-G6→UIX4 工程化前置/R3-G8→UIX7 语音UI) ②补优先级显式标注对标 P0/P1 ③拍板建议改标准 status=Accepted/Deferred/InProgress | P1 |
| `docs/c5-recovery-2026-06-22/grill-decisions.md` | no_change | C5 recovery grill 决策总表(62k，15 段 Q1→θ-data)，recovery 唯一权威，活文档。**注**：另一路标 mark_historical(被 paradigm supersede 拍板框架) → 取 no_change，但**文档头加边注**「拍板框架部分已被 paradigm-amend-tool-surface supersede(B-frame 否决/D-domain 成立)，C6 真口径/readback 走 P 等 recovery 决策仍权威」 | P0 |
| `docs/grill-tournament/round-01/` ~ `round-05/` | no_change | grill 锦标赛 5 轮(41 条 adopt 拍板权威，与 final-grill-list 配对)，逐轮 grill 论证历程 | P0 |
| `docs/grill-tournament/ledger.md` | no_change | grill 锦标赛分类账，权威源索引 | P0 |
| `docs/c5-recovery-2026-06-22/grill-decisions-amend-execution-gap-reconciliation.md` | no_change | 执行 gap 和解(C3-C6 链路调和)。**注**：另一路标 mark_historical(B-vs-D 框架被 paradigm §3/§8 re-diagnosis) → 取 no_change + 文档头边注「θ-α 根因/G6-C 框架部分已被 paradigm §3/§8 supersaeded」 | P0 |
| `docs/c5-recovery-2026-06-22/grill-decisions-amend-harness-audit-enforce.md` | no_change | harness 审计强制 grill(20k)，工程 harness 权威 + 实装状态段 | P0 |
| `docs/c5-recovery-2026-06-22/grill-decisions-amend-g6c-design.md` | mark_historical | 已有「🔴🔴 SUPERSEDED-BY paradigm-tool-surface.md」段头，保留标记(勿删) | P1 |
| `docs/c5-recovery-2026-06-22/grill-decisions-amend-theta-alpha-rootcause-grill.md` | no_change | θ-α 根因 grill，根因分析权威源 | P0 |
| `docs/research/2026-06-19-architecture-validity-deepdive.md` | no_change | 架构合法性深验(6 流证据 92% 信心)，C3-C7 起手必读，不废 | P0 |
| `docs/research/2026-06-19-home-llm-teardown.md` | no_change | home-llm runtime 工程拆解，C3/C7 实装参考 | P1 |
| `docs/research/2026-06-19-home-llm-teardown-data.md` | no_change | home-llm LoRA 数据配方拆解，C5 实装参考 | P1 |
| `docs/research/2026-06-19-asr-alignment-research.md` | no_change | ASR 选型(sherpa>Whisper)+D14 二审修正，C7 活决策源 | P1 |
| `docs/research/2026-06-20-mastra-teardown-workflow-eval-trace.md` | no_change | Mastra 形态拆解(runtime 不进)，C4-C6 eval 设计复用 | P1 |
| `docs/research/2026-06-20-pi-teardown-collaboration-layer.md` | no_change | Pi 协作层(长任务 handoff/派单规范) | P1 |
| `docs/research/2026-06-20-maformac-eval-system-overview.md` | no_change | eval 体系鸟瞰，C6/C5/C4/C7 eval 设计总入口 | P1 |
| `docs/research/2026-06-20-eval-oracle-blindspots-repo-scan.md` | no_change | 第二轮 eval oracle 补盲，eval 设计参考 | P1 |
| `docs/research/2026-06-20-eval-agent-toolcall-premortem-oracle.md` | no_change | eval pre-mortem oracle，eval 设计前必读 | P1 |
| `docs/research/2026-06-20-voice-short-context-memory-oracle.md` | no_change | 语音短时上下文 oracle(15 repo)，C7/C4/C6 参考 | P1 |
| `docs/research/2026-06-20-voice-short-term-memory-oracle.md` | no_change | 语音短时记忆主报告(DialogueState/VoiceTurnContext)，C4/C7/C6 活决策源 | P1 |
| `docs/research/2026-06-20-eval-memory-deepdive-synthesis.md` | no_change | 14repo teardown+Qwen 可行性综合(H1-H7 已收敛)，C4-C7 解冻前读 | P1 |
| `docs/research/2026-06-20-qwen3.5-2b-vs-1.7b-feasibility.md` | no_change | Qwen3.5-2B 升主力可行性(H1 已拍=条件升级)，C5 训练前参考 | P1 |
| `docs/research/2026-06-20-model-selection-2026-deepdive.md` | no_change | 2026 模型选型深析(37k)，大脑选型权威 | P1 |
| `docs/research/2026-06-20-p1c-training-backend-deepdive.md` | no_change | P1C 训练后端深析(41k)，C5 实装参考 | P1 |
| `docs/research/2026-06-22-mlx-lora-quality-control.md` | no_change | MLX LoRA 质量控制(39k)，C5 实装 QC 参考 | P1 |
| `docs/research/2026-06-20-teardown-*.md`（14 个） | no_change | 14 eval/bench/voice/runtime repo 逐行深拆，各 C-change 实装按 INDEX 复用 | P1 |
| `docs/research/INDEX.md` | no_change | research 目录索引 + 应用机制(防失忆体系)，routing map | P0 |
| `docs/research/2026-06-22-top-fc-skill-table-teardown/` | no_change | 真实座舱 FC 契约 + 交付手册一手 teardown(2045 具名工具/D-domain 极致密集)，B-frame vs D-domain 决策 grill 权威源，C5/C6 口径参考 | P0 |
| `docs/research/🔴 RAW vault 5处独立证据全部指向 P.md` | no_change | C5 recovery ε=方案P 的 RAW vault 一手工程证据，readback 实装权威源 | P0 |
| `docs/handoffs/2026-06-22-paradigm-flip-d-domain-demo-features-grill.md` | no_change | 范式翻案 D-domain demo 特性 grill 决策，B-frame→D-domain 关键转向权威源 | P0 |
| `docs/dispatches/_TEMPLATE.md` | no_change | 派单模板，工具性文件 | P2 |

### T4 — UIUE + voice 落档

| path | verdict | what_to_change | priority |
|---|---|---|---|
| `docs/demo-experience-script-placeholders.md` | modify | 五幕脚本占位符 → contracts/demo-golden-run.v1.yaml 真实话术；Act2 slot4 已实，剩 14 处待补；与 demo-golden-run 单源 SSOT(grill-decisions BG3)打通 | P0 |
| `docs/voice-pipeline-from-raw.md` | modify | ASR 决策纠正：实际热词注入=promptTokens+usePrefillPrompt(非 contextualStrings)；TTS=AVSpeechSynthesizer 系统朗读；修正 §1 contextualStrings→promptTokens / §6.1 热词配置 / §6.2 TTS 调教 / §2.4 confidence_delta 实装，对齐 C7/D14 拍板 + ASR amend(SFSpeechRecognizer 主) | P1 |
| `docs/research/2026-06-22-uiue-ultracode`（落档新建） | new_file | UIUE 完整决策档：吸收 raw/GRILL-MASTER.md(8 lens×79 findings)；结构=U1-U10 已拍(paradigm §11)+U11-U31 待拍(UIX1-9 议题，§15)；逐条落点(进 demo/族外/砍 + ContentView/tool-card-map.demo10/state-cells/demo-golden-run.v1) | P1 |

> **T4 voice 落档点完整链**：`voice-pipeline-from-raw.md`(modify ASR 纠正) → `openspec/specs/voice-pipeline`(new_file 契约) 上下游成对。UIUE：`raw GRILL-MASTER.md`(modify 加映射) → `docs/research/2026-06-22-uiue-ultracode`(new_file 落档) + U13/U10/U27 已并入 demo/state-cells。

### T5 — 历史快照（批量 banner 标 historical，不改正文）

> 🔴 **批次状态 = PENDING（finding round-01）**：banner 批**尚未跑**（handoffs 0/25 / dispatches 0/13 / tech-baseline-from-raw / c5-recovery-roadmap 均无 banner，约 37/75 path 未跑）。
> **批量动作**：历史快照统一加文档头 banner，**不改正文**。banner 制式见 §3.6。逐条列出供脚本生成（path 见原始 reader verdict，此处归类汇总）。
> 🔴 **path-set 计数 = `ls`/`find` 实测，非手写**（finding 2026-06-23 第三轮：handoffs/ 手写 24 实测 25，off-by-one）：banner 脚本跑前对每个 path 集合重 `wc`/`ls` 实测后再汇总 banner 批口径，禁手写计数当一手（写错的计数会被未来 grill 当 SSOT 引用，§35 机械账本自身 drift）。

| 类别 | path 集合 | banner 指向 |
|---|---|---|
| 早期 baseline/spec 草案 | research-archive-2026-06-17.md, tech-baseline-from-raw.md, tech-baseline-supplement-v0.2.md, integration-blueprint.md(注：T0 标 modify，T5 重复标 historical → **取 T0 modify**，不入 banner 批), maformac-function-spec-2026-06-19.md, demo-must-pass-candidate-2026-06-19.md, baseline-internalization-plan-2026-06-19.md, intent-routing-explore-2026-06-18.md | baseline-semantic-protocol MASTER + semantic-function-contract.jsonl |
| pre-mortem 早期 | execution-pre-mortem-2026-06-18.md, voice-pre-mortem-2026-06-18.md, cockpit-voice-fc-premortem-2026-06-18.md | roadmap + C5/C7 grill 决策 |
| LoRA/eval 早期研究 | lora-eval-adopt-research-2026-06-19.md, research/2026-06-21-c5-generator-selection-probe.md, research/2026-06-20-model-selection-2026-finders-raw.md, research/2026-06-20-p1c-training-backend-finders-raw.md | roadmap + C5 design.md |
| 早期 spike | research/2026-06-20-p1-b-qwen35-2b-s1-s2-spike.md, research/2026-06-20-c3-home-llm-adopt-spike.md | roadmap / C3 archived spec |
| second-review-2026-06-17/（9 文件） | 00-source-ledger ~ 07-roadmap + README | baseline-semantic-protocol + srd + roadmap |
| repo-intelligence/2026-06-17-gitnexus/（5 文件） | 01-index ~ 04-query + README | srd / roadmap |
| project/ 早期 | project/brainstorm-2026-06-17-demo-mvp.md, project/cockpit-voice-fc-premortem-2026-06-18.md | C6 vehicle-tool-bench / paradigm |
| handoffs/（`ls docs/handoffs/*.md` 实测 25 文件，2026-06-18~23；除 `paradigm-flip-d-domain` no_change → **24 进 banner 批**） | 全部 closeout/checkpoint/dispatch handoff（除 paradigm-flip-d-domain 已 no_change） | 各对应 archive/recovery 权威 |
| dispatches/（13 文件） | 全部 apply/propose 派单（除 _TEMPLATE no_change / p1-b-qwen-spike 标 P1 进行中） | 各对应 archive |
| c5-recovery-2026-06-22/ 中间态 | 8d-rootcause.md, exec-plan.md, grill-checklist-30.md, dispatch-prompt-to-codex.md, roadmap.md | grill-decisions 汇总 |
| 诊断/优化分析 | research/2026-06-22-claudecode-amnesia-shallow-harness/, research/2026-06-21-lora-training-pitfalls/, research/2026-06-21-rules-skills-loading-optimization/ | 后续 grill 决策 |

> **T5 内 no_change（不入 banner 批）**：`dispatches/_TEMPLATE.md`(模板)、`dispatches/2026-06-20-p1-b-qwen-spike-dispatch.md`(P1 进行中，属活 roadmap)。

### T6 — 脏区清理

| path | verdict | what_to_change | priority |
|---|---|---|---|
| `openspec/changes/_parked/define-intent-routing/` | delete_or_park（保持 parked） | 确认 PARKED(2026-06-19 声明)：二分→三层+意图收缩，强依赖新契约(C1/C2)；已物理移出 changes/根防误 apply；保持 parked 不删，待 C1/C2 archive 后 rebase 为 C4。**范式翻案后 generic-frame intent-routing 被 supersede，三层路由重定在 paradigm §4** | P2 |
| `openspec/changes/_parked/define-lora-pipeline/` | delete_or_park（保持 parked） | 确认 SUPERSEDED(已由 define-lora-training 取代)；保留设计资产(train/eval separation/fail-closed redaction/base-vs-LoRA comparison)；parked 不删 | P2 |
| `openspec/changes/_parked/define-voice-contract/` | delete_or_park（保持 parked） | 确认 HIGH 可复用(WhisperKit/ASR/TTS/barge-in 与契约无关，整体复用→C7)；parked 不删，待 C1/C2 archive 后按新契约组织为 C7 | P2 |
| `contracts/function-spec-full-v0.yaml` | mark_historical | **(已在 T1 列，T6 重复)** 参考模板非权威，已标 DO_NOT_USE，保留作 codegen schema 参考 | P2 |

---

## 3. 长跑执行序

> 原则：**先 enforce 锚(契约 SSOT)→ 再活基线 → 再决策标 → 再 grill 统一 → 再 UIUE/voice → 最后脏区**；T5 批量 banner 脚本化一次过（与活改解耦，可并行）。每改一波即 `make verify`（verify-cross-section 守段间一致 + value-in-source 守数字）。

### 阶段 0（前置门，A2 派单前）
- **D-domain 工具数 value-form 实算**（paradigm §14 G2 / final-grill-list Q01）：562=intent 非工具数（口径终拍 §0，534 已废），必先实算工具数。**未实算前所有 T1/T0 的「工具数」字段写占位 [TBD-工具数待 value-form 实算]，不编数字**。
- 阻塞标记：`contracts/qwen-tool-call-format.yaml` tools 字段、`function-spec-full.yaml` 重派生、CLAUDE.md §9 banner（:113 行）工具数占位 全等此门。

### 阶段 1 — T1 契约 SSOT 先（9 modify + 2 new_file + 3 mark_historical；no_change 11 仅核对，与 §1.2 T1 对齐）
1. 加 HISTORICAL banner：`capabilities.yaml` / `function-spec-full.yaml` / `function-spec-full-v0.yaml`（防误当权威派生）。
   - 🔴 **mark_historical 执行状态（finding round-02 实测，与 T5 PENDING 同制追踪，防 verdict 写了执行漏一个无人追踪）**：✅ `capabilities.yaml` 已加 banner（v1-B-frame-archived）/ ✅ `function-spec-full-v0.yaml` 已加 banner（HISTORICAL 过期）/ ✅ `function-spec-full.yaml` **已加 banner（round-02 补，此前 2/3 已加假完成信号掩盖此漏；最危险——14000 行 generated 全量 spec、authority 字段自带权威感，最易被未来 session 误当 D-domain 权威源）**。3/3 已完成。
2. 填 spec Purpose TBD（5 个：semantic-function-contract/scenario-state-protocol/tool-execution/vehicle-tool-bench/demo-experience）+ surface 段（tool-execution/vehicle-tool-bench/semantic-function-contract）。
3. D-domain surface 落 contract：`demo-scenarios.yaml` / `l1-demo-allowlist.yaml` / `c6-bench-cases.jsonl`（expected_tool_calls→D-domain，工具数门后）/ `state-cells.yaml`。
4. new_file：`contracts/demo-golden-run.v1.yaml` + `openspec/specs/demo-golden-run` + `openspec/specs/voice-pipeline`。
5. `lora-training/spec.md` sample_shape→D-domain。

### 阶段 2 — T0 活基线（7 modify + CLAUDE.md 微改 verify-only = §1.2 T0 共 8）
顺序：`CONTEXT.md`(权威索引+口径，最先建索引) → `README.md`(入口+决策总览) → `srd-three-layer-intent-routing.md`(surface 段) → `baseline-semantic-protocol`(IR banner) → `integration-blueprint.md` → `roadmap-2026-06-20`(banner+工具数门) → `lessons-learned.md`(§51 新增)。CLAUDE.md 仅核对(微改)。

### 阶段 3 — T2 决策标状态（1 待逐条标）
`c1-q1-q10` 待 C1/C2 archive 后逐条标 keep/modify/superseded/defer（其余 4 个 T2 no_change，仅核对）。

### 阶段 4 — T3 grill SSOT 统一（2 modify + 边注）
1. `final-grill-list.md` 加 Status 列 + 41↔21+35 映射表。
2. `raw GRILL-MASTER.md` 加 UIUE↔UIX 映射 + status 标准化。
3. 边注（不改正文，加文档头）：`grill-decisions.md` / `grill-decisions-amend-execution-gap-reconciliation.md` 标「拍板框架部分已被 paradigm supersede，recovery 数据决策仍权威」。

### 阶段 5 — T4 UIUE/voice（2 modify + 1 new_file；voice-pipeline / demo-golden-run 两 new_file spec 见阶段 1 T1，跨 Tier 不在此重复，与 §1.2 T4 dedup 约定一致）
1. `voice-pipeline-from-raw.md` ASR 纠正(promptTokens/AVSpeechSynthesizer/SFSpeechRecognizer 主)。
2. `demo-experience-script-placeholders.md` 占位→demo-golden-run.v1.yaml SSOT。
3. new_file：UIUE 落档 `docs/research/2026-06-22-uiue-ultracode`。

### 阶段 6 — T6 脏区清理（3 parked 确认 + 1 banner）
确认 3 个 _parked README 声明仍成立；`function-spec-full-v0.yaml` banner（已在阶段1）。

### 并行轨 — T5 批量 banner（75 文件，脚本化批次；path-set 实测，旧「56」已废）
🔴 **状态 = PENDING（finding round-01）**：T5 banner 批**尚未跑**——实测 handoffs 0/25、dispatches 0/13、`tech-baseline-from-raw.md`、`c5-recovery-2026-06-22/roadmap.md` 均无 banner（约 37/75 path 未跑）。T5 是【长跑后续批次】，与阶段 1-6 解耦，单脚本批量加 SUPERSEDED/HISTORICAL 头（不改正文），跑前对每个 path 集合重 `ls`/`find` 实测。**排除**：`integration-blueprint.md`(取 T0 modify)、`_TEMPLATE.md`、`p1-b-qwen-spike-dispatch.md`(P1 进行中)、`paradigm-flip-d-domain-demo-features-grill.md`(no_change)。

---

## 4. 脏区清理清单

### 4.1 _parked（保持 parked，不删，待 rebase）
| path | 原状态 | rebase 目标 |
|---|---|---|
| `openspec/changes/_parked/define-intent-routing/` | PARKED（二分→三层+意图收缩，强依赖新契约） | C4（C1/C2 archive 后；三层路由现定在 paradigm §4，generic-frame intent-routing 已 supersede） |
| `openspec/changes/_parked/define-lora-pipeline/` | SUPERSEDED（已由 define-lora-training 取代） | 设计资产保留，无 rebase（已有正式 change） |
| `openspec/changes/_parked/define-voice-contract/` | HIGH 可复用（与契约无关，整体复用） | C7（C1/C2 archive 后） |

### 4.2 废文件 / 矛盾活文档（banner 标，不物理删）
| path | 动作 | 理由 |
|---|---|---|
| `contracts/function-spec-full-v0.yaml` | HISTORICAL banner（已标 DO_NOT_USE） | 手工样板非权威源（SSOT=jsonl），保留作 codegen schema 参考 |
| `contracts/function-spec-full.yaml` | HISTORICAL banner | 生成物反映旧 generic frame，A2 后 D-domain 生成器重派生 |
| `contracts/capabilities.yaml` | HISTORICAL banner（仍是源，但工具名旧 B-frame） | A2 后升 D-domain 具名工具 |

### 4.3 口径污染源（跨段分叉，回写 + 边注）

> 🔴 **本表性质（finding round-01）= 回写操作映射表（污染出现位置 → 修正动作），非废口径权威源**。废口径的权威定性单一物理副本 = `grill-decisions-master.md §0 口径权威表`（见本文 §0 指针）；下表列出的废口径数值仅作「在哪出现、改成什么」的操作锚，不构成本文第二份权威表（消除 §0「不再内联列举权威定义」与本表的表面矛盾）。
> 🔴🔴 **方向反转（磊哥 2026-06-23 终拍 562）**：本表先前版本把 562 列为污染源、要求「全改 534」——**方向反了**。磊哥亲拍 **562 为唯一权威**后，污染源 = **534 / 2086 / 52.3% / 族外 1004 / 1904 系列**，全改回 **562 / 2159 / 54.1% / 族外 976 / 1831**（口径终拍见 §0）。✅ **boundary 文件（mvp-10family-device-boundary.md）正文已是 562 权威态**（:3 文档头 + :41 + §1/§2/§4 全持 562/2159/976/1831，旧 534 系列文件内已标作废）——此前「回写成 534」的旧动作已被磊哥 2026-06-23 终拍 supersede，文件正文已重置回 562，**无须再 re-reverse**（见 §2 T2 verdict）。

| 污染（旧废口径） | 出现位置 | 修正（改回 562 系列） |
|---|---|---|
| `534 / 2086 / 52.3%` | A1-A9 后中间态、`mvp-10family-device-boundary.md` 错向回写残留、旧 cascade 段 | 全改 **562 / 2159 / 54.1%**（磊哥 2026-06-23 终拍权威，534 系列已废）|
| `族外 1004 / 1904` | 同上 | 全改 **族外 976 / 1831**（device 480 不变）|
| `507 / 418 / 缺486` | 旧 grill 段、handoff | 标废，以 191/562 为准（paradigm §14:230-231）|
| `223 / 507 / 680` | generated 旁路过期 | 标过期，以 191/562 为准 |
| 「工具数」当 534 或 562 | 任何派单/契约 | 全改 [TBD-工具数待 value-form 实算]，禁编数字（562=intent 非工具数）|

---

## 5. 元层守则（级联纪律，§35 实装）

1. **写任何「工具数」前**：grep 是否已 value-form 实算；未实算 → 写 `[TBD]` 占位，绝不引 534/562 当工具数。
2. **写任何分轴/计数数字前**：cite-verify 一手源（paradigm §14 / contract jsonl 行数 / gate_result 字段），禁凭印象引旧段。
3. **每改一波即 `make verify`**：verify-cross-section 守基线文档组段间一致；value-in-source 守 load-bearing 数字。🔴 **finding round-03 已落地**：`cross_section_check.py` 的 `BASELINE_GLOBS` 已纳入 `docs/grill-tournament/*.md`（cascade/master/final-grill/ledger），新增口径单值锚（`10 族 intent=562 / device=191 / 族外 intent=976`，废口径行靠 SUPERSEDED 标记跳过）。**边界**：只 enforce mechanical（口径/分数跨段分叉），治不了 correctness（口径本身错仍需异源+人）；口径锚仅在【赋值断言行】触发（表格/prose 不触发，避免误报）。GOV3 完整 enforce 设计（SUPERSEDED 策略/扩到全 grill 系列）仍待 grill（master §2 Q09），本轮只落最小机械门。
4. **SUPERSEDED 制式**（§3.6）：文档头 `> ⚠️ SUPERSEDED-BY <path> (<date>)：<一句话现行权威指向>`；旧段内联标 `[SUPERSEDED → 见 X]`，不留裸旧值。
5. **历史档只 banner 不改正文**：T5 保留一手溯源价值，仅加头部 SUPERSEDED/HISTORICAL 指针。

### 3.6 banner 制式模板
```
> ⚠️ HISTORICAL / SUPERSEDED（2026-06-23 文档级联）
> 本文档为 <阶段> 历史快照，现行权威 = <path>。
> 范式翻案后（generic frame → D-domain 具名工具，见 grill-decisions-amend-paradigm-tool-surface.md），
> 本文涉及 surface 形态 / 口径数字（562/418 等）已废，以现行权威为准。正文保留供溯源，勿据此推进。
```
