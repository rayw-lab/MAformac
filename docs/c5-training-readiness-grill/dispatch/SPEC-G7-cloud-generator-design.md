---
authority: commander_dispatch_d22
artifact_kind: c5_gate_construction_dispatch
dispatch_id: SPEC-G7
gate: gate7 云多源 generator + 异源 judge 三权分立编排（design/spec）
executor: hermes（跨厂商 LLM，磊哥定「云 generator 之前是 hermes 本次还是 hermes」）
grill_dimension: 维度7 云generator（SSOT 归 W1 数据线 = worker-1-data-decisions.md D-031~037；本次由跨厂商 hermes 执行 design，非 swarm codex W3 评测范式官）
worktree: /Users/wanglei/workspace/MAformac-g7 (branch c5gate/g7-cloud-generator-design, base origin/main 771f48ad = 当前 origin/main HEAD，已核)
r7_boundary: design/spec-only — 不 build 可运行生成代码 / 不 run 任何生成 / 不产训练数据/语料（retrain_c5 data generation = BLOCKED）
decision_status: ⭐-default pending 磊哥 formal lock（见 §0.5）
created: 2026-07-01
status: pending_cc_audit_round2
---

# SPEC-G7 — gate7 云多源 generator + 异源 judge 三权分立（design/spec）

> 🔴 执行方 = **hermes（跨厂商）**，不是 swarm 里的 codex W3（W3 = 评测范式官管维度 6/9/12 = `%45`）。本任务是【维度7 云generator】的 design，grill SSOT 归 W1 数据线，本次借跨厂商 hermes 之手产 design。别把 hermes 当 swarm-W3。

## §0 Preamble（你是谁 / 一句话使命 / 防什么）

你是 **hermes（跨厂商 critic/producer）**，commander = MAformac 线 claude-commander。
**一句话使命**：把 gate7「云多源 generator + 异源 judge」从【research 锁了方向、代码未闭环】推进到【**可实现的编排 design/spec**】——三权分立架构 + 模型池 + 异源 judge 协议 + diversity/dedup 门 + fixture 验证计划。🔴 **只产 design/spec 文档，绝不 build 可运行生成代码、绝不 run 任何生成、绝不产训练数据/语料（一条话术都不）。**

🔴 **你在防两次双仓惨败重演**：
- **惨败1（`0/34`）**：训练集 **0 条自然中文**（北极星缺口）；generator 自产自标自审 → self-bias + 评测虚高。
- **惨败2（θ-α）**：单源同质化 + capacity gap。
- gate7 三权分立正是防这两个：generator（多源产）/ label-gold（C1 deterministic）/ validator-judge（异源审）分离。

## §0.5 🔴 决策状态：⭐-default pending 磊哥 formal lock

本派单引的 D-031~037 当前 grill `status: proposed`（SYNTHESIS `grill_complete_pending_human_signoff`；`reduction-table.md:60` locked=0 待磊哥 §2 人审拍板）。commander 按磊哥 standing「默认你的推荐」treat ⭐ 为 working-default 推进 design。design 里的架构决策标 ⭐-default，磊哥 formal lock 后 commander 回写。

## §1 Authority & R7 边界（🔴 retrain-c5 data generation 邻接，design-only，逐项对齐 R7 blocks）

🔴 **云 generator = 训练数据生成领域 = R7 `route_deframing_blocks` 明列 `retrain_c5` + Forbidden #1「Any retrain-c5 data generation」= BLOCKED to RUN**（`docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md:20-29` + `:126`）。scope **严格 = design/spec 文档**：

**你做（design/spec）**：
- 写 generator 三权分立**架构 design 文档**（组件职责 / 数据流 / 接口契约 schema / 异源 judge 协议 / diversity·dedup·去污门 / 验收判据）。
- 写 **fixture 验证计划**（将来怎么用 fixture/dry-run 验证此 pipeline，**不真跑生成**）。

🔴 **你绝不做（= R7 `route_deframing_blocks` 全 9 项）**：
1. `retrain_c5` —— **不 build 可运行的生成代码**（不写能真调云 LLM 产 utterance 的可执行脚本）、**不 run 任何生成 / 不调云 generator 产数据**、**不产训练数据/语料**。
2. `rebuild_c6_acceptance` / 3. `d_domain_base_recalibration` / 4. `candidate_comparison` / 5. `demo_golden_run` / 6. `voice` / 7. `endpoint_readiness` / 8. `uiue_merge_to_mainline` / 9. `v_pass_s_pass_u_pass` —— 全不碰。

🔴🔴 **fixture 的精确边界（最敏感，你 hermes 本身是 generator 候选源，易手滑）**：fixture 验证计划里**只写【字段结构/schema 占位】**（如 `{utterance: "<PLACEHOLDER_zh_utterance>", source: "claude|gpt55|...", parent_semantic_id: "<id>", ...}` 的字段骨架），**绝不填真实中文 utterance 话术内容**（哪怕标"示例/fixture"也不行）——**填具体话术 = 产语料 = R7 BLOCKED**。

**deliverable = 一份 design/spec markdown**（+ 可选**不可运行**接口伪代码/schema 占位，不调真 API、不含真话术值）。

## §2 Worktree & 路径

- **代码/文档工作区** = `/Users/wanglei/workspace/MAformac-g7`（branch `c5gate/g7-cloud-generator-design`，base origin/main 771f48ad）。
- 🔴 **design 文档唯一落点** = `/Users/wanglei/workspace/MAformac-g7/docs/c5-training-readiness-grill/gate7-cloud-generator-design.md`（见 §8 落盘方式）。
- **grill SSOT + research（只读，绝对路径主 worktree）**：
  - `/Users/wanglei/workspace/MAformac/docs/c5-training-readiness-grill/worker-1-data-decisions.md`（D-031~037 全文）+ `worker-1-data-round2.md`（D-046~095 深化：多源编排）
  - 🔑 `/Users/wanglei/workspace/MAformac/docs/research/2026-06-21-c5-generator-selection-probe.md`（generator 选型 probe = 你的一手蓝本，163 行，三权分立结论源）
  - `/Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/8d-rootcause.md`（惨败1根因）
- ⚠️ **不 commit 到 main**。

## §3 Inlined Grill 决策（SSOT 逐字；⭐-default pending lock 见 §0.5）

### gate7 三权分立（W1 数据官 grill，`worker-1-data-decisions.md:46-47`）
- **D-031 generator 总体架构**：⭐**A = generator-label-validator/judge 三权分立**（B 自产自标自审 / C 人工全包 均否）。依据 = probe verdict：**训练 LLM 多源产 utterance，label/gold 由 C1 deterministic，validator/judge 异源**（`docs/research/2026-06-21-c5-generator-selection-probe.md:9`,`:46`,`:49`）。防 self-bias 和评测虚高；cite **P7 审计语义正确性**。
- **D-032 generator 模型池**：⭐**A = Claude / GPT-5.5 / Codex / GPT Pro 多源，Codex 低权重**（B 单一最强 GPT Pro / C 本机小模型 均否）。依据 = probe 结论2 多源云、结论3 本机小模型错、Codex 偏代码权重低（`probe:126`,`:132`,`:137`）。防单源同质化和 capacity gap；cite **P8 训练/eval/runtime 同源**。
- **D-033~037**（多源编排 / 标签确定性 / validator 异源 / diversity / 去污 深化）：🔴 **全文读 `worker-1-data-decisions.md:48-52` D-033~037 + round2 D-046~095**（绝对路径），逐条 inline 进你的 design，**别只引编号**。

🔴 **关键架构约束（probe + 惨败教训，design 必体现，inline 具体规则）**：
- **三权分立**：① generator（多源云 LLM 产**自然中文** utterance 的**架构设计**，补 0/34「0 条自然中文」缺口——但本派单只设计架构，不真产）② label/gold（C1 contract **deterministic** 出标签，不靠 LLM 标）③ validator/judge（**异源** LLM 审语义正确性，厂商 ≠ generator，防 self-bias）。
- **模型池权重**：多源（Claude/GPT-5.5/Codex/GPT Pro），Codex 低权重（偏代码）。
- **diversity/dedup/去污**：防同质化 + 防训练集污染 held-out（呼应 gate5 六轴 held-out D-016 + C6 release final-only AD-C6-003）。
- **异源 judge**：judge 厂商 ≠ generator 厂商（cross-vendor，防同 family bias）。

## §4 Mission（design/spec，逐节）

- **M1**：读一手蓝本——`2026-06-21-c5-generator-selection-probe.md` 全文 + `worker-1-data-decisions.md` D-031~037 + round2 + `8d-rootcause.md` 惨败1（0 条自然中文 / self-bias）。
- **M2（架构 design）**：写三权分立架构——组件（generator / label-gold / validator-judge）职责 + 数据流图（utterance 产出 → C1 确定性标 → 异源 judge 审 → diversity/dedup/去污 → 入候选池）+ 每组件接口契约（输入/输出 schema 占位，**伪代码不可运行、无真话术值**）。
- **M3（模型池 + 异源 judge 协议）**：定义模型池 + 权重（D-032）+ 异源 judge 选型（厂商 ≠ generator，打分维度：语义正确/自然度/标签一致/OOD）+ 仲裁规则（judge 分歧怎么收）。
- **M4（diversity/dedup/去污门）**：定义多样性度量 + 去重 key + **去污规则**（生成的 utterance 不得撞 gate5 六轴 held-out / C6 release case，呼应 D-016 + AD-C6-003 release final-only）。
- **M5（fixture 验证计划）**：写「将来怎么验此 pipeline 而不真跑生成」——用**字段占位 fixture**（值 `<PLACEHOLDER>`，§1 边界）走通三权流程的 dry-run 测试设计 + 验收判据。**显式标 `R7: real cloud generation run BLOCKED until candidate signoff + run auth；fixture 仅字段占位无真话术`。**
- **M6（pre-mortem 段）**：列此 pipeline 会炸的坑（单源 collapse / judge 同源失守 / 标签漂移 / 去污漏 / capacity gap），tiger/paper-tiger/elephant 三分类带依据。

## §5 验收门（design/spec 质量门）

- design 文档**自洽完整**：三权分立每组件职责/接口明确 / 模型池+权重定义 / 异源 judge 协议定义 / diversity·dedup·去污门定义 / fixture 验证计划（字段占位无真话术）/ pre-mortem 段。
- 🔴 **每个 load-bearing 架构决策 cite 一手**（probe file:line / D- 编号 / 8d 根因），不凭印象、不编造行号。
- 🔴 **守 R7 声明显式在文档头**：design-only，real generation run BLOCKED，fixture 无真话术。

## §6 🔴 teardown 去扩散 + grill 消减纪律（磊哥 2026-07-01 新铁律）

- **遇问题积极 teardown 去扩散**：架构有模糊点（judge 仲裁规则 / 去污 key / capacity gap 怎么补）→ **深挖 probe 一手 + pre-mortem 搜坑扩展调查**，别简化绕过或拍脑袋定。
- **grill 消减收敛**：扩散出 N 子方案 → 按 `reduction-table.md §2` 消减到 ⭐（locked/merge/defer/superseded/dedup），每点收敛成带 ⭐ + 理由的 design 决策，子决策不 sprawl。
- design 里**未决的口径型分歧**（仁者见仁）→ 列成选择题 + ⭐ 默认上报 commander 转磊哥拍，别自拍。

## §7 Stop Conditions

1. 要写能真调云 API / 真跑生成的可执行代码 → 停（R7 BLOCKED，design-only）。
2. 要真产一条训练 utterance/语料（含 fixture 里填真中文话术）→ 停（BLOCKED，§1 fixture 只占位）。
3. 架构决策与 probe 一手冲突或你想偏离 ⭐ → 停 + grill 消减上报。

## §8 输出 + 回执（hermes = stateless Agent，产出与落盘分离）

- 🔴 **你（hermes）= 把 design 文档【全文内容】通过 Agent 最终消息返回给 commander**（不要自己 git commit；stateless Agent 不保证有 g7 worktree 写权限/cwd）。**落盘 commit 由 commander 做**（commander 把你返回的全文落 `/Users/wanglei/workspace/MAformac-g7/docs/c5-training-readiness-grill/gate7-cloud-generator-design.md` 并 commit `c5gate/g7-cloud-generator-design` 分支）。
- Agent 返回含：① design 文档**全文** ② 三权分立架构摘要 ③ 关键决策 cite 清单（probe file:line / D- 编号）④ teardown-消减记录 ⑤ 守 R7 声明（design-only 未 run 生成、fixture 无真话术）⑥ pre-mortem 三分类。
- **First Response 确认对齐**（返回开头一句）：`ACK-G7: gate7 云 generator design/spec-only（hermes 执行非 swarm-W3）, 三权分立 D-031~037, R7 不 build 可运行生成代码/不 run 生成/不产数据/fixture 仅占位`。
