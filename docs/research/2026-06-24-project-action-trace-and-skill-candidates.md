---
status: draft_proposal_pending_user_decision
artifact_kind: research_analysis_skill_candidates
authority: research_artifact_not_ssot
created: 2026-06-24
as_of_git_head: c0e3477
as_of_note: "存档时 main HEAD=c0e3477（default-scope apply Task 7 done，Task 8 dirty 进行中）；别窗口在执行 apply，本档为只读分析快照。"
scope: 从项目建立到当前节点的全量动作轨迹回顾 + 候选 skill 制定方案（只读分析产出）
sources: "git log 138 commits (all refs) + repo 文件 + receipt + 4 个只读 agent 一手提取（带 file:line）"
retire_trigger: "磊哥拍板 skill 沉淀方向后，落地决策迁入对应 dispatch/plan；本档转 historical provenance。"
expires: "2026-07-24"
---

# MAformac 全量动作轨迹回顾 + 候选 Skill 方案

> 本档 = CC 主窗口一次**只读分析**的产出存档（磊哥要求归档，**方案未拍、未执行**，磊哥仍在思考）。
> 产生方式：主线程跑 git log 全量(138 commits, all refs) + 目录 inventory，派 4 个只读 general-purpose agent 并行深挖「重复动作模式」（各负责一组工作流，返回带 file:line 的结构化提取），主线程综合。
> 性质：**research artifact，非 SSOT**。所有结论来自 git log / repo 文件 / receipt / agent 一手提取；推断项已标注「推断」。

---

## A. 可访问范围 vs 不可证实范围（诚实声明）

| 范围 | 内容 | 可信度 |
|---|---|---|
| ✅ **完全可访问** | git log 全量 138 commits（all refs，2026-06-17→06-24）、所有 `docs/`/`contracts/`/`openspec/`/`Reports/`/`scripts/`/`Tests/` 文件、29 个 handoff、Makefile、phase0 manifests | ground truth，逐一核过 |
| 🟡 **部分可证实** | 26 个非 main commit（feature/`uiue`/`codex` 分支）——只读 commit message，**未逐个核分支内文件**；`Reports/` 13 个训练 receipt——agent 读了 c5 关键几个，未全读数值 | message 级可信，内容级抽样 |
| 🔴 **不可证实（本 session 没读）** | ① raw vault 源料（`~/workspace/raw/`，本机只读不入仓）② transcript 仓外归档（ultracode 各 finder 过程）③ 云端 PR 审计原文对话（GPT Pro/GLM 网页，仓内只有归档摘要）④ **别窗口 default-scope apply 实时进行态**（dirty 区在变，刚核又多了 `Tools/paper-to-skill-gate/`）⑤ UIUE worktree（`/Users/wanglei/workspace/MAformac-uiue`，HEAD `17f2af1`）当前态 ⑥ 本地 ahead origin 8 commit 的远程差异 | 仅凭仓内归档/指针，原始一手不可证 |

**关键自纠（本 session 现身的 claim-vs-reality）**：起手时凭 handoff 信"main HEAD 6f03b62 / 从 Task 7 继续"，实况已是 `c0e3477`（Task 7 done，Task 8 进行中）。**git log 是 truth，handoff/CURRENT 是入口** —— 这条教训本身就是下面 Top-skill 的依据之一。

---

## B. 项目动作时间线（8 阶段，git log 为骨）

> 8 天 138 commits。每阶段：目标 / 关键文件 / 实际动作 / 验证 / 状态 / 遗留风险。

### 阶段 0 — 项目初始化（06-17，Day1）
- **目标**：建项目宪法 + OpenSpec 工作区 + 三工具协作（Pocock/OpenSpec/Superpowers）+ S0-S6 路线
- **关键文件**：`CLAUDE.md` `AGENTS.md` `docs/project/collaboration-and-roles.md` `openspec/config.yaml` `docs/research-archive-2026-06-17.md` `docs/second-review-2026-06-17/`
- **动作**：`25287ad` 初始化(宪法+调研基座+cross-vendor 二审) → `b4edb4f` OpenSpec 工作区 → `04a25bc` 三工具协作沉淀
- **验证**：cross-vendor 二审 | **状态**：**DONE** | **风险**：—

### 阶段 1 — change1/2 + spike E3（06-18，Day2）
- **目标**：第一批 OpenSpec change（capability-contract + demo-mvp-contract）+ 座舱三层原理调研 + spike E3 (FC 可行性)
- **关键文件**：`openspec/changes/archive/2026-06-18-define-capability-contract`、`-define-demo-mvp-contract`、`docs/dispatches/2026-06-18-*`、`docs/intent-routing-explore-2026-06-18.md`、`docs/*-pre-mortem-2026-06-18.md`
- **动作**：`9311432` change1/2 实装+archive + spike E3 dispatch
- **验证**：`openspec validate` + archive | **状态**：**DONE（archived）** | **风险**：早期扁平契约 Day3 即被 v2 推翻（→ SUPERSEDED）

### 阶段 2 — 全量重构 v2 + C1/C2 契约 SSOT + LoRA dataset（06-19，Day3）
- **目标**：推翻扁平 8 能力 → 立 **C1 semantic-function-contract + C2 scenario-state-protocol** 为契约 SSOT；park 旧 7-change；LoRA dataset 重型派单（Codex worktree 隔离）
- **关键文件**：`contracts/semantic-function-contract.jsonl` `state-cells.yaml`、`openspec/changes/define-c1c2-contract`、`docs/baseline-semantic-protocol-2026-06-19.md`(3990 范式 MASTER)、`docs/srd-three-layer-intent-routing.md`、`docs/adr/0001`、分支 `feat/lora-dataset-build`(stages a-e)
- **动作**：`564609d` 基座内化+推翻7-change → `d1b2fef` 全量重构 v2 → `4018b6a` P0 function-spec 全集 671device → `a42dc5a` C1 codegen → `6bb9be3` T2 C1↔C2 闭合；GPT Pro 审 PR#2 多轮(`a646d57`/`6c478f3`/`b1badf2`)
- **验证**：`openspec validate`、`verify_refs.py`、GPT Pro audit closeout | **状态**：**DONE（C1/C2 次日 archived）** | **风险**：dataset build（feat/lora-dataset-build）后被 C5 重做 = SUPERSEDED

### 阶段 3 — C3 execution apply + C6 bench + archive + 14repo 深扒（06-20，Day4）
- **目标**：C3 执行契约层 apply（codex TDD 长跑）+ C6 vehicle-tool-bench propose/apply/archive + 14 repo teardown + 模型选型 + 3990 范式 MASTER 沉淀
- **关键文件**：`openspec/specs/tool-execution`、`vehicle-tool-bench`、`Core/Execution/`、`Core/Bench/`、`docs/research/2026-06-20-teardown-*`(14个)、`Reports/c6-base`
- **动作**：C1/C2 archive(`a9888bc`) → C3 group0-7(`b9e08aa`..`f38865f`) → audit-fix gap#1-6(`5eed87a`..`150302a`) → C6 propose+apply group1-9(`401f728`..`6d02771`) → C3/C6 archive(`883f1af`/`607dbe3`) → MASTER 沉淀(`3476723`) → P1-A data gate(`4bc4874`)/P1-B qwen spike(`846e40c`)
- **验证**：`swift test`、`make verify`、`verify-gold`（**C6 base Qwen3-1.7B 无 LoRA hard_fail IrrelAcc 0.789<0.9 = C5 提升诚实锚**）| **状态**：**DONE（archived）** | **风险**：C3 §7.3 Qwen sampling 未实测（迁 P1-B）

### 阶段 4 — C5 LoRA training apply + 整改 wave（06-21，Day5）
- **目标**：C5 LoRA training apply scaffolding + P1-C grill Q11-Q18 + ultracode 训练调研 + 8 维 superaudit + PR1/PR3 整改
- **关键文件**：`Core/Training/C5LoRATraining.swift`、`openspec/specs/lora-training`、`Reports/c5-lora-training-*`(7个) + `c5-remediation-wave-*`、`docs/p1c-training-grill-decisions.md`、`docs/research/2026-06-21-lora-training-pitfalls`
- **动作**：`073cdac` fc_flags bug fix → `1231bdd` accept lora training → `727a2af` C5 scaffolding → `181b66f` ultracode 调研+8维superaudit → `eba8218` harden offset/generation gates
- **验证**：`c5-training-receipt.json`、`c5-data-gate-receipt`、`swift test` | **状态**：**PARTIAL→BLOCKED**（superaudit = No-Ship；candidate UNSIGNED）| **风险**：`masking_coverage` 全 false、offset gate 假绿、0 条自然中文样本

### 阶段 5 — C5 `0/34` 灾难 + recovery grill + 范式翻案 + harness enforce（06-22，Day6）
- **目标**：通宵 wave candidate **`0/34` 灾难** → 8D 复盘 + recovery grill(15 决策 Q1→θ-data) + **范式翻案**(generic frame `tool_call_frame` → D-domain 具名工具) + harness enforce 层上线
- **关键文件**：`docs/c5-recovery-2026-06-22/`(8d-rootcause + grill-decisions + 5 amend)、`docs/research/2026-06-22-a2-codebase-audit`、`-top-fc-skill-table-teardown`、`-claudecode-amnesia-shallow-harness`
- **动作**：`c4a7d1a` harden candidate gates and close blocked wave(0/34) + 大量 recovery/范式 docs
- **验证**：`make verify cross-section`、cite-verify hook | **状态**：**BLOCKED**（candidate 报废 UNSIGNED；范式翻案推翻 B-frame）| **风险**：claim-vs-reality **9 次同坑变体**（派生表征当一手）

### 阶段 6 — 文档级联 + A2 D-domain code-only 重构（06-23，Day7）
- **目标**：范式翻案落文档级联（**口径终拍 562** + grill SSOT + cascade-inventory + UIUE U1-31 + 4 change skeleton）+ **A2 六步 D-domain code-only 重构**
- **关键文件**：`docs/grill-tournament/grill-decisions-master.md` `cascade-inventory.md`、`openspec/changes/migrate-d-domain-tool-surface`、`docs/research/2026-06-23-a2-execution`(S0-S5)、`scripts/gen_tool_contract.py`、`generated/D_domain.tools.*.json`
- **动作**：`dca1000` 文档级联(562 终拍) → A2 S0(`6307b04` 口径191/562/2159)→S1(`a3a8c60` 工具目录)→S2(`722b93d` surface)→S3(`59975c6` state-cells)→S4(`4b634b5` C5)→S5(`8db0ae9`/`8496695` C6 bench)
- **验证**：`swift test`、`make verify`、`verify-surface`、parity gate | **状态**：**DONE**（S0-S5 + push `doc-cascade/...` branch）| **风险**：A2 大爆炸（用 strangler 模式规避）

### 阶段 7 — A2 merge main + default-scope apply + UIUE + phase0 D1-D10（06-24，Day8，**当前**）
- **目标**：A2 三厂商终审闭合+merge；phase0 D1-D10 accept + R-L17 gates；default-scope carrier propose+apply；UIUE Phase 5 grill（独立 worktree）
- **关键文件**：`docs/project/phase0/`、`docs/superpowers/plans/2026-06-24-default-scope-apply.md`、`openspec/changes/define-demo-default-scope`、`docs/research/2026-06-24-lora-zero-failure-deepdive`(18路)、三审 `2026-06-23-a2-execution/audits/`
- **动作**：`fd2220b` A2 merge(#3) → `927e276`/`9627164` 三审闭合 → `883f1c4`/`1143b50` phase0 D1-D10 → default-scope `3bad3b8`(propose)→`14060bf`(closeout)→`8517f70`..`c0e3477`(Task 0-7) → UIUE Phase5(`209dff1`..`8334044` on uiue branch)
- **验证**：`swift test 146/0`、`make verify`、`verify-gold 57/57`、3 道 mechanical gate（Task 9 未做）

| 子线 | 状态 |
|---|---|
| A2 merge main | ✅ **DONE** |
| phase0 D1-D10 accept | ✅ **DONE**（pending=0） |
| **R-L17 human-review** | 🔴 **OPEN/BLOCKED**（同厂商审计只算 pre-check，G2-G5 未过） |
| **default-scope apply** | 🟡 **PARTIAL**（Task 0-7 committed，Task 8 dirty 进行中，Task 9/10 todo） |
| UIUE | 🟡 **PARTIAL**（worktree 隔离，不 merge main） |
| retrain-c5 / rebuild-c6 / golden-run / voice | ⬜ **DEFERRED/BLOCKED**（apply 全绿 + R-L17 过才动） |

### C. 横切「长期阻塞 / V-PASS」（贯穿多阶段）
- **C5 candidate `0/34` UNSIGNED**（阶段4-5）—— 报废，范式翻案后走 retrain-c5（DEFERRED）
- **C6 base hard_fail 0.789** —— 不是 bug，是诚实 baseline 锚（C5 须超它）
- **R-L17 human deframing OPEN** —— 7 个不可委托点 + R1-R7 evidence stub，同厂商不能 certify
- **V-PASS / model-quality / endpoint / golden-run / 真机 spike S2** —— 全 DEFERRED/BLOCKED，严禁冒充
- **计划态≠执行态**（completion-claim-triage 实证）—— apply plan `apply_authorized` 但物理实现 Task 8 才进行

---

## D. 候选 Skill 清单（覆盖 13 维度 + 补充 3 维）

> 标注 **[NEW]新建 / [EXTEND]扩展现有 / [ADOPT]已有直接用**。关键判据（rules-vs-skill-loading）：**recognition（该动手的时机）→ 留 rule always-on；procedure（怎么做的步骤）→ 才做 skill**。已有 skill/rule 的维度优先 adopt/extend，不重造。

| # | skill_name | 维度 | 触发场景 | 解决的重复动作 | 输入文件 | 步骤（精简） | 输出 artifact | 验证命令 | 不能做什么 | 全局/MAformac | 优先级 | 难度 | 类型 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `maformac-onboard` | ①onboarding | 新 session 起手 | 读链 + **核 git 实况 vs handoff 声称** | CLAUDE→CURRENT→README→grill-master→paradigm→handoffs | 读6链→`git log/status`核实况→对账handoff声称→报当前真态 | 上下文恢复 + 实况对账表 | `git status -sb`/`git log --oneline -8` | 不改文件/不信 handoff 当 truth | MAformac | **P1** | 低 | NEW |
| 2 | `archive-research-pack` | ④research应用 | ultracode 调研完成 | 综合官 README+lensN+INDEX+transcript 仓外指针 手搓重建 | workflow return + finder findings | 建目录模板→落 README(精华表+P0/P1/P2)→lensN 一手→INDEX(run_id/transcript指针)→脱敏检查入仓 | `docs/research/<date>-<topic>/`全套 | grep 脱敏 `raw/\|禁外传` | 不改正文/不入密钥PII | 全局 | **P0** | 中 | NEW |
| 3 | `verify-external-claims` | ④反证 | 调研引 arxiv/数字/star | 主线程亲核 finder 外部声称(防编造) | finder findings + arxiv/repo 引用 | 抽 load-bearing 数字/ID→WebSearch+`gh`核→建核实表→finder回稿逐条对照→catch 编造 | external-claims-verification 表 | `gh repo view`/WebSearch | 不信"综合官说核了" | 全局 | **P0** | 中 | NEW |
| 4 | `cross-vendor-audit-archive` | ⑨audit调度 | 重大产出终审 | ≥3厂商8维表+辩证收4-step+DEFERRED三分类归档 | PR/diff + 派单 prompt | 同prompt派GPT Pro/GLM/Codex(≥1实跑)→8维表→并集findings→辩证收(亲核/steelman/honest defer)→post-fix subagent仲裁 | `audits/{gptpro,glm,codex}.md`+absorption | 各审实跑命令 | 同厂商不算 cross-frame/不盲信全修 | 全局 | **P0/P1** | 中 | NEW(rule已recognition) |
| 5 | `make-verify-gate` | ⑫gate体系 | 改 contract/codegen | SSOT codegen→verify-refs→cross-section→surface→diff→test fail-closed | Makefile + scripts/*.py | regen→verify-refs(契约自洽+leak)→cross-section(段间一致)→surface(工具名⊆catalog)→diff(漂移)→test | verify 全绿 + exit code | `make verify` / `make verify-all` | 不查 correctness(只 mechanical) | MAformac | **P1** | 低(已存在,固化用法) | EXTEND |
| 6 | `completion-vpass-gate` | ⑫V-PASS | 断言"完成/可推进" | 分级 OpenSpec-pass/local-pass/train-health/model-quality/V-PASS 防冒充 | receipt + 状态声明 | 分诊计划态vs执行态→跑实际验证→按 enum 标级→禁裸PASS | 分级 verdict | `swift test`/`make verify-all` | 不冒充 V-PASS/不凭 artifact 存在推完成 | MAformac | **P1** | 低 | NEW(rule已recognition) |
| 7 | `closeout-receipt-writer` | ⑩closeout | 任务收口 | receipt JSON+MD twin + sha256 + status enum + verify table 手搓 | dispatch §7 schema + 实跑 log | 收集 commands[].{cmd,exit,verdict,evidence_path,sha256}→填 mechanical_gates→claim_boundaries→twin 渲染 | `Reports/<task>-<ts>/receipt.json+md` | schema validate | 禁 hardcoded pass / verdict 必来自 evidence_path | 全局 | **P1** | 中 | NEW |
| 8 | `worktree-isolation` | ⑬worktree | 多窗口/worktree 并发 | 单工作树共享 index 警告 + doc 暂存 raw 错开 + dirty 不 reset | git status + 分支态 | 核 dirty 归属→判单工作树 vs worktree→CC 产出暂存 raw→不碰别窗口 dirty | 并发安全协调 | `git status -sb`/`git worktree list` | 不 reset 别窗口/不 `git add -A` 卷入 | 全局 | **P1** | 低 | NEW(memory已有) |
| 9 | `c6-bench-parity` | ⑥bench/parity | A2 后 / C6 改 | verify-gold + surface parity + 四层门(golden/fuzz/unsupported/safety) | C6 cases + D-domain catalog | 工具名⊆catalog→gold replay→四层分母按 schema 拆→不评模型性能 | parity verdict | `make verify-surface`/`verify_gold.py` | 不评 model-quality(A2 边界) | MAformac | **P1** | 低 | EXTEND |
| 10 | `doc-cascade-sweep` | (补)级联 | 范式翻案/口径回写 | grep 全仓→T0-T6 分诊→活基线改/历史档 banner | cascade-inventory + grep 命中 | grep 锚点→逐文件 T0-T6 判→活基线 modify/历史档 banner/脏区 park→dual-count 自检 | cascade-inventory 更新 | `cross_section_check.py`/`awk` 复算 | grep命中≠都改/不改T5历史正文 | 全局 | **P1** | 中 | NEW(rule已recognition) |
| 11 | `maformac-openspec-change` | ②OpenSpec | 起 change | 4-artifact+spec delta+双向依赖死锁规避+apply前置 | openspec/changes/ | proposal/design/tasks/spec delta(ADDED/MODIFIED/REMOVED)→互依用一change两spec同波archive | change 文件夹 | `openspec validate --strict` | 不 archive 半写入/不留空 spec | MAformac | **P2** | 低(global opsx 已覆盖) | EXTEND |
| 12 | `apply-preflight-redtest` | ⑦default-scope | apply plan 落地 | frontmatter authority+same-vendor吸收+N Task red-test-first+mechanical gate | apply plan | red-test(RED)→实现(GREEN)→3道 gate fail-closed→closeout receipt | apply 全绿 + receipt | `make verify` + gate scripts | spec 未对齐不写实现 | MAformac | **P1** | 中 | NEW |
| 13 | `c5-lora-receipt-gate` | ⑤C5 data/train | retrain-c5 启动后 | masking_coverage/offset/source_digest 校验 + verdict from evidence | c5-*-receipt.json | 选 receipt→校 masking 三形态→offset byte-parity→fail-closed verdict(非 metadata flag) | data/train gate verdict | `swift test --filter C5*` | verdict 禁读 metadata flag 自证 | MAformac | **P2**(训练 DEFERRED) | 中 | NEW |
| 14 | `codegen-ssot-scaffold` | (补)codegen | 新契约装 SSOT | freeze_snapshot→gen_*→diff gate 双hash+caliber fail-closed | source-snapshot-manifest + gen_*.py | 冻结快照(双hash)→codegen 派生→纳 diff gate→caliber 自验 | 派生物 + diff 门 | `make regen`+`make diff` | 手改生成物=违约 | MAformac(模式可全局) | **P2** | 中 | EXTEND |
| 15 | `claim-cite-verify` | ③claim-vs-reality | 写 load-bearing 数字 | value-in-source 核 + 实跑复算 vs 读 receipt | 文档/报告 + 一手源 | 抽数字→grep/读源行 value-in-source→实跑复算→失效引用 block | cite-verify 报告 | `cross_section_check.py` + hook | hook 治 mechanical 非 correctness | 全局 | **P1**(hook已部分) | 低 | EXTEND(rule+hook已有) |
| 16 | `maformac-dispatch` | (补)派单 | 派 codex/agent 长跑 | 8-section 模板+prerequisite+risk_state enum+3硬约束+pre-mortem | dispatches/_TEMPLATE.md | 填 0-7 段→prerequisite bash→验收门+pre-mortem 三分类→status 回报 schema | dispatch md | — | 不写死运行态数字(标 snapshot) | MAformac | **P2**(CC自驱降频) | 低 | EXTEND |

**维度⑧ grill/tournament / ⑪ evidence-index 已被现有 skill 覆盖**（见 F 节 adopt 清单），不重复列新建。

---

## E. Top 10 最该先沉淀的 Skills（+ 为什么）

> 排序逻辑：**真缺 procedure 载体 × 高频重复 × 当前/近期会用 × 价值高**。已有 skill（loop-competition/loopaudit/heavy-work）直接 adopt，不进 Top10。

1. **`archive-research-pack`（P0，全局）** —— 18路 lora-deepdive、a2-codebase-audit、各 teardown **结构几乎一字不差**却每次手搓重建；`ultracode-7lens` rule 只描述了"三层一手性"recognition，**没有 procedure 载体**。最高频、最该机械化的归档动作。
2. **`verify-external-claims`（P0，全局）** —— finder 编造是**结构性风险**：18路 80+ arxiv 抽样就 catch 1 个编造（`2603.03203` 单路 5 次）。主线程亲核纯手工、长尾有漏网。enforce > 自觉的活证据。
3. **`cross-vendor-audit-archive`（P0/P1，全局）** —— A2 三厂商终审是项目质量护城河（GPT Pro 抓 P0 / GLM 抓 P1-2 / Codex 实跑抓 warning，findings 是**并集**）；`cross-vendor-final-audit` rule 是 recognition，**辩证收 4-step + DEFERRED 三分类 + post-fix 仲裁的 procedure 缺载体**。
4. **`maformac-onboard`（P1，MAformac）** —— 每 session 起手必跑；**本 session 就踩了"handoff 状态过期"**。把"读链 + git 实况对账声称"固化，直接防 completion-claim drift。
5. **`make-verify-gate`（P1，MAformac）** —— `0/34` 灾难根因之一就是 `generated/` 漂移无门；这套 7-step fail-closed（SSOT codegen+diff+cross-section+surface）是把 claim-vs-reality 三铁律机械化的骨架，改 contract 必跑。
6. **`completion-vpass-gate`（P1，MAformac）** —— "计划态≠执行态"**反复踩**（本 session + apply plan + C5）；V-PASS/local-pass/train-health 分级防冒充是 demo 收口的关键门。
7. **`closeout-receipt-writer`（P1，全局）** —— 18 个 receipt + 29 个 handoff 手搓；`0/34` 灾难本质是 receipt 读自己 metadata flag 翻 pass。强制 verdict from evidence_path+sha256 是结构答案。
8. **`worktree-isolation`（P1，全局）** —— **当前正活跃**：别窗口 default-scope dirty + UIUE worktree 并发；单工作树共享 index 撞车是灾难，memory 有 recognition 但缺 procedure。
9. **`doc-cascade-sweep`（P1，全局）** —— 范式翻案/口径 562 回写涉及 162 文件；T0-T6 分诊（活基线改 vs 历史档 banner）+ dual-count 自检是高频高错动作（cascade-inventory 自身记录 5 轮 self-drift）。
10. **`apply-preflight-redtest`（P1，MAformac）** —— **下一步就要用**（default-scope Task 8-10 + 训练线 retrain-c5/rebuild-c6 apply）；frontmatter authority + same-vendor 吸收 + red-test-first + 3 道 mechanical gate 是 MAformac apply 的确定性模板。

---

## F. 关键判断：adopt > build（别重造）+ 一个重要观察

**已有 skill/rule 覆盖，直接 adopt/extend，不列新建**：
- **维度⑧ grill tournament** → 全局 `loop-competition` skill 已实现 round-N×brains×judge×ledger×dedupe/trim-to-target，**完全匹配** `docs/grill-tournament/` 结构；answer-defense 有 `codex-answer-grill` skill。→ extend 加 MAformac 的 T0-T6/decision-pack/R-L17 即可。
- **维度⑨ loopaudit** → `loopaudit` skill 已有（多审并行→合并 P0/P1→修→再审 + 收敛定律 `修复⊇审计⊇执行`）。
- **维度⑩ long-run** → `heavy-work` skill 已有（重型长跑骨架 + harness 7 强制项 + 坑点库 H1-H12）。
- **维度④ teardown** → `blueprint-teardown` rule（8 步）+ `pre-mortem` skill 已有。
- **维度③ claim-vs-reality** → `claim-vs-reality-gap` rule（always-on）+ `cross_section_check.py` + cite-verify hook 已机械化大半 —— **这是 recognition，不该转 skill**（rules-vs-skill-loading 铁律），新建只补 cite-verify procedure。

🔴 **重要观察（与本任务直接相关）**：`Tools/paper-to-skill-gate/`（untracked 新目录）里 clone 了 **`DeepPaperNote/`** —— 一个完整 skill skeleton（`SKILL.md` + `agents/` + `references/*.md` + `scripts/run_pipeline.py` + **`lint_grounding.py`/`lint_note.py`**），是"extract structure → gate/lint → emit reusable artifact"的 prior-art。**推断**：磊哥可能正在准备一个"paper/原料 → skill"的带质量门 pipeline。若属实，上面的候选 skill 应该**走这个 gate 沉淀**（lint_grounding 正好对应 #2 verify-external-claims / #15 cite-verify 的 grounding 校验）。这是 adopt 的最佳蓝本——建议沉淀前先 teardown `DeepPaperNote/`。

---

## G. 下一步（待磊哥拍板，本档不决策）

落地建议序（**未拍**）：① 先 teardown `Tools/paper-to-skill-gate/DeepPaperNote` 定沉淀骨架 → ② 从 Top10 P0 三个起（`archive-research-pack` / `verify-external-claims` / `cross-vendor-audit-archive`，都全局高频）→ ③ 每个 skill 走 `loop-competition`/异源审一遍再锁。

**本次只做方案，未执行、未建任何 skill。磊哥仍在思考沉淀方向。**

---
*存档：2026-06-24 · CC 主窗口只读分析 · research_artifact_not_ssot*
