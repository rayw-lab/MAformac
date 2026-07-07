---
authority: grill_reduction_table
artifact_kind: c5_grill_reduction_table
paradigm: UIUE 215-grill 消减表（全集→纳入→消减→净 locked）
created: 2026-07-01
status: 5_gate_groups_locked_2026-07-01_others_proposed__formal_launch_cascade_2026-07-05_host_hold
---

# C5 grill 消减表（Reduction Table）

> UIUE 215-grill 范式三件套之一（决策矩阵 / **消减表** / 评分表）。全集决策 → 去重/合并/defer/superseded 消减 → 净 locked。🔴 当前 331 决策全 `proposed`，消减待 ① round-02 audit 回（去重/质量）② 人审拍板（locked/defer/superseded）。
> **2026-07-05 晚补记**：formal launch doc-cascade 已盘点。W-G2/W-H2 消减了旧 command/watchdog 双 lane ambiguity；W-I/W-I2/W-I3 坐实 host gate HOLD；formal 1800 未 launch，candidate/C6/UIUE/V-PASS 均不得声称。

## §1 全集计数（331 决策）

| 来源 | 文件 | ID 段 | 决策数 | 维度 |
|---|---|---|---:|---|
| W1 数据语料官 第一轮 | `worker-1-data-decisions.md` | D-001~045 | 45 | 2 数据集语料 / 3 C5数据gate / 7 云generator |
| W1 round-02 深化 | `worker-1-data-round2.md` | D-046~095 | 50 | 2/3/7 深化（五轴held-out/masking边界/多源编排）|
| W2 算法训练官 第一轮 | `worker-2-algo-decisions.md` | A-001~045 | 45 | 4 算法配方 / 5 论文 / 8 训练推进 |
| W2 round-02 深化 | `worker-2-algo-round2.md` | A-046~095 | 50 | 4/5/8 深化（超参论文依据/DoRA/checkpoint）|
| W3 评测范式官 第一轮 | `worker-3-eval-decisions.md` | E-001~045 | 45 | 6 C6四层 / 9 范式surface / 12 harness |
| W3 round-02 深化 | `worker-3-eval-round2.md` | E-046~095 | 50 | 6/9/12 深化（阈值数/工具数实算/异源grader）|
| commander 纵切 | `worker-commander-failure-defense-decisions.md` | F-001~046 | 46 | 1 双仓惨败→防线 / 10 gate体系+R-L17 / 11 pre-mortem |
| **全集** | | | **331** | 12 维度全覆盖 |

## §2 消减规则（UIUE 方式）

| 动作 | 判据 | 处置 |
|---|---|---|
| **locked** | 磊哥人审拍 ⭐ | 入 master + landing matrix，落 spec/code gate |
| **merge** | round2 深化与第一轮同议题（深化非新决策）| 合并到第一轮决策的子项，不重复计 |
| **defer** | 非训练前节点必需（如 DoRA 排期 V-PASS 后）| 标 defer + 触发条件 |
| **superseded** | 被更细决策替代 | 标 SUPERSEDED-BY + 不裸留 |
| **dedup** | round2 与第一轮换皮重复（audit P1 标）| 删重复，保细的 |

## §3 维度覆盖矩阵（12 维度 × 决策 + SYNTHESIS 8 gate 映射）

| 维度 | 决策来源 | SYNTHESIS gate 覆盖（audit 第一轮已核 8/8）|
|---|---|---|
| 1 双仓惨败→防线 | F-001~025 | 惨败1 九失守 + 惨败2 surface mismatch + P1-P9 PCA |
| 2 数据集语料 | D-001~015 + round2 | — |
| 3 C5数据gate | D-016~030 + round2 | **gate 5 多轴held-out**（D-016 六轴）|
| 4 算法配方 | A-001~015 + round2 | **gate 4 scale-authority=20**（A-002）/ **gate 2 masking**（A-016~018）|
| 5 论文依据 | A-021~027 + round2 | lr-matters `2602.04998`（commander WebSearch 亲核坐实 2026-02 NTU/MIT，结论 LR调好vanilla够用）|
| 6 C6四层 | E-001~015 + round2 | **gate 6 四层阈值化**（E-002~006 逐层 fail-closed）|
| 7 云generator | D-031~037 + round2 | **gate 7 多源generator+异源judge** |
| 8 训练推进 | A-028~045 + round2 | **gate 1 训练循环真跑**（A-031）|
| 9 范式surface | E-016~030 + round2 | **gate 8 D-domain codegen**（E-026）/ **gate 3 surface preflight**（E-020）|
| 10 gate体系+R-L17 | F-026~033 + F-045 | 8 gate 全 + R-L17 route-only signed / candidate blocked |
| 11 pre-mortem | F-034~044 | 7 失败模式防线 + **F-043 positive-not-diluted+OOD**（audit P1-1 补）+ **F-044 G6-C tiny ablation 裁决门**（audit P1-2 补，最关键）|
| 12 harness | E-031~045 + round2 + F-032/033 | make verify / cite-verify / sign-or-block / 异源 grader |

🔴 **8 gate 覆盖 = 8/8**（audit 第一轮逐道核：gate1→A-031 / gate2→D-025+A-016~018 / gate3→E-020 / gate4→A-002 / gate5→D-016 / gate6→E-002~006 / gate7→D-031~037 / gate8→D-005+E-026）。

## §4 消减状态（待填）

| 状态 | 数量 | 备注 |
|---|---:|---|
| proposed（其余待人审拍）| ~316 | 非本批 5 gate 的决策仍 proposed，随各自 construction 排期再 lock |
| **locked（2026-07-01 D-007 磊哥拍「都按推荐来」）** | **5 gate ⭐ 组（~15 ID）** | **E-002~006 四层阈值化 / F-043 positive-not-diluted / D-016 六轴 held-out / F-044 tiny-ablation 裁决门 / D-031~037 云 generator 三权分立**（construction 已派发 g6/g5/g7）|
| merge（round2 深化合并）| TBD | round-02 audit 回评估重复率后定 |
| defer | TBD | 非训练前节点必需项 |
| superseded | TBD | — |
| **净 locked（本批 5 gate 训练前节点决策集）** | **5 组** | D-007 收口，construction 跑中 |

## §5 消减待办

1. round-02 audit 回（agentId 跑中）→ 评估重复率（round2 vs 第一轮）+ cite 真实性 → 标 dedup/merge。
2. 人审拍板 → 每决策 locked/defer/superseded。
3. 净 locked 决策 → landing matrix（grill→spec→code gate）+ master 收口。

## §6 2026-07-05 formal launch 消减增量

| 议题 | 原状态 / 风险 | 新证据 | 消减结论 |
|---|---|---|---|
| run-auth 是否等于可起跑 | 旧计划/交接曾写“等 run-auth 起 formal”，容易被误读为授权后直接 launch | `STATUS-BOARD.md` 记录 run-auth accepted 但不替代 host/watchdog/LR gates | **消减为分层口径**：run-auth=entry authorization；launch 仍需 host PASS/waiver + watchdog armed + first-real LR |
| launch command vs watchdog source | W-J 抓到 v1 `COMMAND-CANDIDATES.txt` 仍指 shorttrain `f044_watchdog.py` | W-G2 v2 supersede 旧 watchdog 段；W-H2 audit clear | **已消减**：command/watchdog lane ambiguity 关闭；v2 只能在 host PASS/waiver 后由 high executor 使用 |
| watchdog readiness | formal watchdog template ready，但未绑真 trainer pid | W-H2 `WATCHDOG_V2_CLEAR_BUT_HOST_HOLD` | **保留 runtime 门**：watchdog path clear != armed proof；无 trainer pid 时不能写 armed |
| host gate | quiet/forced resample 后仍低于 21GB | W-I `17.867GB<21`；W-I2/W-I3 `18.554GB<21`；swap pass 不覆盖 free fail | **active blocker**：`NO_GO_HOST_GATE_HOLD`；下一步只有 close GUI resample PASS 或 `host-waiver-key` |
| formal evidence-run 到 candidate/C6 | formal 1800 容易被写成候选或 C6 通过 | baseline §0.3 / launch secretary non-claims | **不消减为通过**：formal 仍 evidence-run-only；candidate unsigned；无 C6/UIUE/voice/V-PASS |
