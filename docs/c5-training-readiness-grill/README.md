---
authority: grill_ssot_not_decided
artifact_kind: c5_training_readiness_grill_master
goal: 推进到「C5 可以开始 LoRA 训练前的节点」（8 gate + R-L17 物理就绪，守「严禁跳 gate 直接训」，到节点为止不真训）
paradigm: UIUE 215-grill（决策矩阵 + 消减表 + 评分表 + landing matrix）
target_decisions: 300-500
created: 2026-07-01
status: skeleton_dispatched
---

# C5 Training-Readiness Grill — SSOT（300-500 决策单一权威）

> 🔴 **本文 = C5 训练就绪 grill 的待 grill + 已拍单一权威**。3 codex worker + commander 脑暴 300-500 关键决策，覆盖 C5 训练前节点的方方面面（经验教训/论文/算法/语料 + teardown+pre-mortem 出的维度）。按 UIUE 215-grill 范式（决策矩阵 + 消减表 + 评分表）。磊哥人审拍板。
> **Goal**：推进到「C5 可开始 LoRA 训练前节点」——把 8 道 gate（SYNTHESIS-LORA §三）+ R-L17 候选签名前置补齐到「万事俱备、只欠按训练键」。守 D-003 铁律「严禁跳 gate 直接训」（R7 signoff：retrain-c5 + data generation 仍 BLOCKED，到节点为止）。
> **2026-07-05 晚状态补记**：C5 formal 1800 已从“训练前节点”推进到 launch flow，但当前 **NO-GO/HOST_GATE_HOLD/NOT_LAUNCHED**。run-auth 已接受，command v2 与 watchdog v2 已收敛；host 三采样低于 21GB，未给 `host-waiver-key`。本 grill 目录继续承担决策/消减/防惨败账，不得把 run-auth、static packet、GitNexus analyze 或 formal evidence-run 写成 candidate/C6/V-PASS。

## §0 SSOT 声明 + 推进事实源

- **决策单一权威** = 本目录（README + 各 worker 决策矩阵 + 综合 master）。
- **上游 SSOT（grill 论据回溯）**：`runs/2026-06-30-lora-teardown/SYNTHESIS-LORA.md`（8 gate）+ `docs/c5-recovery-2026-06-22/`（0/34 复盘 + grill-decisions）+ `docs/project/phase0/r-l17-human-review-evidence/`（R-L17）+ `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（范式）。
- **范式样板** = `docs/grill-tournament/grill-decisions-master.md`（UIUE 215-grill 结构）+ `cascade-inventory.md`（landing matrix）。
- **D-053/T1-OOM 最新补充（2026-07-03）**：T1 smoke 已真跑且 FAIL（Metal OOM before first optimizer update）。后续训练线先看三份新档：`t1-oom-premortem-iceberg-advice-2026-07-03.md`（结论口径）/ `t1-oom-diagnostic-runbook-2026-07-03.md`（T1D 诊断矩阵）/ `token-budget-supervision-ledger-2026-07-03.md`（token 长度账 vs 监督面账）。N4 local 绿不得再被引用为 formal train-ready。
- **D-108/D-110 后 formal launch 最新补充（2026-07-05 晚）**：Phase 4=B 允许 formal evidence-run；Phase 1/Launch Packet static gates clear；W-G2/W-H2 消减旧 launch-command/watchdog lane 矛盾；active blocker 只剩 host PASS/waiver + runtime armed proof。当前状态板：`~/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/secretary/STATUS-BOARD.md`。

## §1 🔴 双仓惨败回忆纪律（每条决策必过，定时回忆）

> 磊哥铁律：**定时回忆双仓 LoRA 惨败 + 数据集 + 后续训练推进方法**。每条 grill 决策必填【防惨败列】= 「这条怎么防下面两次惨败重演」。
>
> 🔴 **行号 banner（commander 复核 audit P1-3，2026-07-01）**：下表 9 失守的代码行号是 **0/34 时点（2026-06-22 `8d-rootcause.md`）历史快照**，多处对应根因**已在代码层修复**——buildNoCallSamples 假删→**真删** `Core/Training/C5LoRATraining.swift:2612`（`sample.tools = positive.tools.filter{≠removedName}`）+ 活样本断言 `:2613-2614`（cut5）/ name-last→**name-first** `:1823` / tool_call_frame 已是 strangler `:2677`（待 retrain 全迁删，注释 `:77`）。惨败表**保留旧行号供溯源**；防线落地时核当前代码行号。🔴 **别把已修根因当当前威胁**——grill 决策是「确保这些修复在 retrain 时仍 enforce + 补未实装 gate」，非「修已修的」。

| 惨败 | 一手 | 9 大失守（claim-vs-reality 三处 × 构建/验证/诊断） |
|---|---|---|
| **惨败 1：C5 PR5 `0/34`** | `8d-rootcause.md` | ①buildNoCallSamples 假删（metadata 谎、`sample.tools` 没删→446 矛盾监督 `:2333`）②矛盾检测器被同一谎蒙蔽（grouping key 用 metadata `:600`）③tool surface 双分叉（训练 `:1942` ⟂ C6 `:397`）④两套 scorer 口径相反（name-only vs hard_pass）⑤empty=hit 掩盖（`:161`）⑥name-last 违 Qwen（`:2409`）⑦数据门无 label_conflict 维度⑧spec 自身缺陷（要求记 metadata 不要求物理删）⑨审计只审合规不实跑 + CC 三次同坑（凭聚合数推根因）|
| **惨败 2：θ-α generated-positive 全塌** | `grill-decisions-amend-theta-alpha-rootcause-grill.md` | 训练数值健康（loss 正常）但 C6 action 行为全 checkpoint FAIL（乱调→不调，未过 base 10/23）= surface 没同源就训 / generic frame 判定面爆炸 1.7B 学不会 |

🔴 **PCA 防线（P1-P9，8d D5）**：ToolContractCompiler 单源派生 / 真删工具 / label_conflict 硬门 / name-first / C6 口径修 / surface+scorer consistency `make verify` 门 / 审计加语义维度+实跑 / grill frame 纪律「训练==eval==runtime 同源」/ recovery 成功标准定义。**每条 grill 决策的【防惨败列】须 cite 对应 PCA 或新挖防线。**

## §2 12 grill 维度（commander teardown + pre-mortem 出，每维度 30-50 决策 → 360-600）

| # | 维度 | 核心料 / 上游 file | 归属 |
|---|---|---|---|
| **1** 🔴 | 双仓惨败复盘 → 再败防线 | `8d-rootcause` 9 失守 + θ-α 全塌 + P1-P9 PCA | **commander 纵切** |
| **2** | 数据集 + 语料 | 3990 范式/12000bug/raw + D-domain 具名工具 + value 四件套 + 双仓旧数据集 | W1 |
| **3** | C5 数据 gate | 多轴 held-out/parent overlap/redaction/masking coverage/must_not_train（`C5DataGate.swift`）| W1 |
| **4** | 算法 + 配方 | rank16Mainline LR1e-4/scale20/gradClip1.0/warmup8%/adamw+wd/repo-loop/DoRA/masking 三形态（`Core/Training/C5LoRATraining.swift:1261`）| W2 |
| **5** | 论文依据 | lr-matters`2602.04998`/Hammer`2410.04587`/When2Call`2504.18851`/SemDeDup/TinyAgent/agentevals/nano-eval/quality-control | W2 |
| **6** | C6 评测四层 | golden/demo_fuzz/unsupported/safety 阈值化 fail-closed/ToolCall exact/IrrelAcc/judge/readback/fingerprint（`Core/Bench/C6VehicleToolBench.swift:1423`）| W3 |
| **7** | 云 generator + 异源 judge | 三权分立/多源/diversity/self-bias/label C1 deterministic/原文不入训练（`c5-generator-selection-probe`）| W1 |
| **8** | 训练推进方法 | mlx-lm 本机训/训练循环真跑验证`:2281`/checkpoint best-by-task/端侧 parity/two-stage | W2 |
| **9** | 范式 surface | D-domain 具名工具/generic frame 否决/canonical IR/工具数 value-form 实算（`paradigm-tool-surface`）| W3 |
| **10** | gate 体系 + R-L17 | 8 gate/route-only signed/candidate signoff/run auth/proof class（`R7-final-route-deframing-signoff`）| **commander 贯穿** |
| **11** | pre-mortem 失败模式 | 假删假绿/审计只看 receipt/loss 绿当模型绿/surface 错位/collapse/假提升 + commander 新挖 | **commander 贯穿** |
| **12** | harness + enforce | cite-verify/sign-or-block/recompute/cross-section/make verify/异源 grader（`grill-decisions-amend-harness-audit-enforce`）| W3 |

## §3 三 worker 角色（灵活定义 + persona lens，swarm §2.5 互不重叠）

| worker | pane | 角色（专业视角，persona-dispatch-lens）| 维度 | 目标决策 |
|---|---|---|---|---|
| **W1 数据语料官** | `%44` | 数据工程师 + 语料标注负责人视角 | 2/3/7 | ~120 |
| **W2 算法训练官** | `%43` | LoRA 训练算法工程师 + 论文复现视角 | 4/5/8 | ~120 |
| **W3 评测范式官** | `%45` | eval/benchmark 工程师 + 契约架构师视角 | 6/9/12 | ~120 |
| **commander 惨败防线官 + 综合官** | `%42` | 项目总监 + 事故复盘官视角 | 1/10/11 纵切 | ~60 + 综合 |

> 角色灵活：worker 在自己维度内可代入该专业角色挑剔点深 grill；交叉维度（如数据×评测的 held-out）由 commander 综合时缝合。

## §4 grill 范式（UIUE 215：决策矩阵 + 消减表 + 评分表）

### 决策矩阵格式（每 worker 产 `worker-N-<线>-decisions.md`）
```
| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line/arxiv) | 状态 | 🔴防惨败(cite PCA或新挖) |
```
- **ID 编号**：W1=`D-`/W2=`A-`/W3=`E-`/commander=`F-`（防撞，如 `D-001`/`A-001`/`E-001`/`F-001`）。
- **状态枚举**：`proposed`（待磊哥拍）/ `locked`（已拍）/ `superseded`（被替代）/ `defer`（延后）。
- **论据必 cite 一手**（file:line 或 arxiv ID，claim-vs-reality；外部 arxiv ID commander 抽核）。
- 🔴 **防惨败列非可选**：每条必答「怎么防 0/34 + θ-α 重演」，cite P1-P9 PCA 或新挖防线。

### 消减表（`reduction-table.md`，全集→纳入消减，像 cascade-inventory Tier）
全集决策按维度计数 → 纳入/合并去重/defer/superseded 消减 → 净 locked 决策数。

### 评分表（`scoring-table.md`，关键选型多维打分选 ⭐）
关键选型决策（如 generator 选型/held-out 切法/masking 形态）多维度评分（防0/34力/工程量/论文背书/端侧可行）选 ⭐。

## §5 landing matrix 骨架（预留，grill-baseline-skeleton-upfront）

> 决策落地跟踪：grill 拍板 → spec → code gate → 物理就绪。**grill 每拍一条同步填格，不攒。**

| 决策 ID | 维度 | grill 拍 | → spec(openspec change) | → code gate | → 物理就绪验证 |
|---|---|---|---|---|---|
| _（grill 收口后逐条填，骨架待填）_ | | | | | |

## §6 维护纪律

1. 每轮 grill worker 回稿 → commander 自核（file:line/arxiv 亲核，不信 prose）+ subagent CC 审回稿（磊哥铁律：派单+回稿都审）。
2. 每收口一批 → 回写 landing matrix + cross-section check（数字/ID/状态段间一致）。
3. 🔴 定时回忆双仓惨败（§1）+ 数据集 + 训练推进——每维度 grill 必过【防惨败列】。
4. 关键节点 → commander-log `decisions.md` D-005 + 刷 INDEX（记忆图谱）。
5. 收口 → 综合 master（`grill-decisions-master.md` 仿 UIUE）+ 消减表 + 评分表 + landing matrix + 人审拍板清单。
