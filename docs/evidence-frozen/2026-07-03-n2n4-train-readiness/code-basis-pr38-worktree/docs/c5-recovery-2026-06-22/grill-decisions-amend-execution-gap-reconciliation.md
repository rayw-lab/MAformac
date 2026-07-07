# C5 Recovery Grill — Amend：决策 × 派单执行对账（悬空点盘点）

> 🔴 **部分 SUPERSEDED-BY `grill-decisions-amend-paradigm-tool-surface.md`（2026-06-22 范式翻案）**：本文档 §5/§6 的「θ-α 失败 = surface mismatch vs collapse 两竞争假设」已被加深——第4源坐实根因 = **generic frame 范式错（单工具判定面爆炸、小模型学不会）**，generic frame 作 surface 否决、D-domain 具名工具坐实。θ-α 实测数据 + 悬空点（§1-§6）仍有效，但**范式/方向以 paradigm amend 为准**。

> **as-of**: 2026-06-22 晚（θ-α 全量训练中，codex 复测 iter400/iter600；另一窗口 CC harness 线在 `scripts/` 建语义脚本 18:07-18:10）
> **本文档 = grill-decisions.md + amend-harness 的第三份 amend**：放「**grill 决策 → 两份派单**的执行对账快照」——哪些拍了没实施(悬空)、哪些还没 grill。**非新决策**，是 §33(分析→执行原子写回)+§35(决策→文档组级联)的 reconciliation，防 orphaned finding。
> **权威边界**：C5 训练决策仍以 `grill-decisions.md` 为准 / 审计+harness 以 `grill-decisions-amend-harness-audit-enforce.md` 为准 / 本文档只记「对账状态」，不改决策内容。
> 🔴 **状态 disclaimer(§20)**：下方「一手状态」是 as-of 此刻 grep/Read/find 坐实；**两条线在跑、状态会变**，复核入口在每条末标注(grep/Makefile/find)。

---

## 0. 对账输入（三源）

- **grill-decisions.md**（406 行，C5 训练 SSOT，Q1→θtrain 全段）
- **grill-decisions-amend-harness-audit-enforce.md**（23 题 + EN1-6，审计+harness）
- **codex 派单** `~/workspace/raw/.../dispatches/2026-06-22-c5-theta-alpha-execution-dispatch.md`（θ-α 三件套 PR1/PR2/PR3）
- **harness 派单** `~/workspace/raw/.../dispatches/2026-06-22-harness-enforce-audit-implementation-dispatch.md`（v3）

**两条执行线在跑**：① codex = θ-α 三件套（全量训练中）② 另一窗口 CC = harness 23 题（scripts/ 建语义脚本中）。

---

## 1. 维度一：决策了但还没实施

### A. 在两条派单线内（在跑，非 gap）

| 决策 | 落点 | 派单 | 一手状态 |
|---|---|---|---|
| G9 name-first | grill-decisions G5-G9 | codex PR1 | ✅ done |
| α compiler scaffold / D1 RouteDeriverV2 | α段 / D1段 | codex PR2 | ⚠️ **partial**（`ToolContractNormalizer` 仍硬写 D-domain `set_cabin_*` IR 映射，"no second normalizer" 未闭合；见 `Reports/c5-theta-alpha-20260622T162757/completion-audit.md` PR2「no second hardcoded normalizer = partial」行）|
| θd-1 positive / η / θtrain | θ-data/η/θtrain段 | codex PR3 | ❌ **实测 FAIL**（全 checkpoint，详 §5）|
| amend 23 题（A1-E3+EN1-6）| amend 批1-5 | harness v3 | 🔄 另一窗口在建 `scripts/{surface_consistency,scorer_single,axis_schema,verify_gold,action_hard_pass_recompute}.py`（18:07-18:10）|

### B. 🔴 悬空——既不在 codex θ-α、也不在 harness 派单

| # | 决策 | 落点 file:line | 一手状态（as-of 核实）| 为什么悬空 | 复核入口 |
|---|---|---|---|---|---|
| **B1** | ε 删 `:1039` readback failure + readback 单列 release-total gate 形态B | grill-decisions ε段 / `Core/Bench/C6VehicleToolBench.swift:1039` | ❌ `:1039 failures.append(.readback)` **仍在**（`:865` gold path 也在）| codex θ-α §7「另派，本三件套不碰」；harness 是审计线不碰 eval；**无 ε 派单文件** | `grep -n 'failures.append(.readback)' Core/Bench/C6VehicleToolBench.swift` |
| **B2** | δ `scripts/build_axes_from_summary.py`（γ1 三轴产生器）+ check#7（axis-schema-conformance/readback-decoupling）接 make verify | grill-decisions δ段/axes-catch γ1 | ❌ 该名脚本未建；harness 线建的 `action_hard_pass_recompute.py`/`axis_schema.py` 功能近似但非同一物 | δ 标「codex 收口后」，未进 θ-α 派单 | `find . -name 'build_axes*'` |
| **B3** | D2 + G5-G9 的 make verify tests 挂进 Makefile `test` target | grill-decisions D2/G5-G9 | ❌ `Makefile:26-28` test target **只有 `test_quarantine + test_fc_flags` 两个**；scripts/ 虽有 surface_consistency/scorer_single/verify_gold 等，但**未 wire 进 verify** | 脚本建了≠门挂上（claim-vs-reality 铁律1 活案例）| `sed -n '26,28p' Makefile` |
| **B4** | ι 同义词表（SAFE-001 放宽 `textEvidenceMatches`，扩'行驶中'安全语境词）| grill-decisions δ段/η段（「可并行」）| ❌ 无派单无实施 | η 说「不依赖训练数据可并行」，无人接 | `grep -rn 'textEvidenceMatches' Core/Bench/` |
| **B5** | audit-template.md（审计 SOP 文档）| audit-framework段 generated_artifacts | ❌ 未建 | harness 派单聚焦 hook/lib，SOP 文档未明确产出（amend A2-A5 实质替代部分，作为交付物缺）| `find . -name 'audit-template*'` |
| **B6** | Q2 `generated/safety-gates.c6.json` + `GeneratedSafetyGate.swift` | Q1/Q2段 | ❌ 未生成 | 属 safety=θ-β，θ-α 不碰（**合理延后，非真 gap**）| — |

---

## 2. 维度二：还没 grill 存下来的点

| # | 议题 | 状态 | 触发时机 |
|---|---|---|---|
| **D0** 🔴 | **θ-α 失败定向**（先判别 training-dynamics collapse vs train/eval surface mismatch 两竞争假设 → 再定 5 方向：合 θ-β/加 distractor 监督/改配方/重训/调 η scope）| codex 实测全 checkpoint 失败，方向未拍 | **现在（最高优先，详 §6）** |
| **D1** | θ-β 第二刀**训练落地**（θd-5 配比 grid 实跑 / θd-6 invariant 倍数 / 安全门与 positive 同训 or 分阶段）| 配方已拍(θ-data)，**落地未 grill** | θ-α 训完后（**或并入 D0 若拍合 θ-β**）|
| **D2** | 范式 G6（D-双层 vs B-frame 裁决）| 据 tiny 对照实验，不凭推 | θ-α tiny 对照产出后 |
| **D3** | demo scope κ + ζ 绝对门 K_abs | DEFERRED | demo-golden-run 解冻后 |
| **D4** | G16 contract version/diff policy（breaking/non-breaking 规则）| `diff` target 有，规则未 grill | Compiler 稳定后 |
| **D5** | G30 真机 iOS endpoint 采购 | 阻塞链，磊哥手动未拍 | 越早越好（V-PASS 阻塞）|
| **D6** | audit-framework 议题3（正交视角 vs 异源 定义）| amend A4/A5 部分覆盖，"正交≠异源"完整定义未单拍 | 审计线收口 |

> ⚠️ checklist-30 顶部「未 grill：G2-G9/G14-G26/G28-G32」**已过期**（写于 11:59，grill-decisions 更到 17:07）：G5-G9 已拍(G5-G9段) / G17-G26 已拍(A0/δ/θ-data) / G27-G29 在 amend。以 grill-decisions 实际段为准。

---

## 3. 🔴 协调风险（最该 surface）

`scripts/` 的 5 语义脚本（surface_consistency / scorer_single / axis_schema / verify_gold / action_hard_pass_recompute）是 **C5 线（δ/D2/G5-G9 的 make verify 门）和 harness 线（C++ 签发门语义集）的天然交集**。harness 派单 §3 内核4 让另一窗口在 `MAformac/scripts/` 建（已建，18:07-18:10）。**但「接进 `make verify` test target」是 C5 线 D2/δ 要的门**——两边可能都以为对方做 → **`Makefile` test 仍 2 个 = 脚本建好、门没人挂**。归属不明确 → B2/B3 持续悬空。

---

## 4. 下一步建议（待磊哥拍）

1. **补 B1+B4+B5 小派单**（ε:1039 / ι 同义词表 / audit-template.md）——都不依赖 θ-α 训练结果，可并行，悬空最久；**B1 影响 θ-α 验收口径**（ζ 门用 without_readback，:1039 没删则代码默认口径含 readback，每轮手剔易错）。
2. **grill D1 θ-β 训练落地**（等 θ-α 训完，议题可先备）。
3. **拍 B2/B3 + 协调风险归属**（scripts/ 脚本 wire 进 make verify 归哪条线）。

---

## 5. 🔴 θ-α 实测结果级联（2026-06-22 训练完成后回写）

> 本段 = §1 维度一 A 行「θd-1/η/θtrain codex PR3」从「🔄 训练中」→「❌ 实测 FAIL」的状态更新。一手源 = `docs/lessons-learned.md` #49 + `Reports/c5-theta-alpha-20260622T162757/generated-positive-data/`（codex `scripts/action_hard_pass_recompute.py` 统一口径复算）+ codex 实跑流水。
> **数字 source（CC 2026-06-22 jq 亲核坐实，非凭对话）**：`c6-iter100/spike-e3-results.json` `.summary.g1TriggerRate=0.588` / `.g3NegativeFalseCallRate=0.435` / `.g2ContentToolCallRate=0`（wrapper drift=0）；`c6-iter{100,400,600}/c6-summary.json` `.IrrelAcc=0.565 / 1.0 / 1.0`；action hard_pass（0/23、base 10/23）= `action_hard_pass_recompute.py` 复算。

**verdict：θ-α generated-positive 全 checkpoint FAIL，candidate 维持 UNSIGNED/BLOCKED。**

| arm | action hard_pass（without_readback，口径 base 10/23）| 触发率 / IrrelAcc | 行为定性 |
|---|---|---|---|
| base | 10/23 | — | 锚点 |
| tiny LoRA(162757) | 9/23 | — | 略低于 base |
| generated-positive iter100 | **0/23** | 触发 58.8% / 误触发 43.5% / IrrelAcc 0.565 | 乱调（泛化成 set_cabin_ac）|
| generated-positive iter400 | **0/23** | 触发 0 / IrrelAcc 1.0 | 不调 |
| generated-positive iter600 | **0/23** | 触发 0 / IrrelAcc 1.0 | 不调 |

- **训练数值健康但 C6 行为全塌**：val_loss 4.424→0.655→0.589→0.598、无 OOM = claim-vs-reality 铁律2「train-health ≠ model-quality」活案例（已入 lessons #49）。
- **末段过训假设排除**：iter400（val 最优）也 0/23。
- **诊断假设（待 grill 拍，codex 列两竞争假设，均未拍）**：
  1. training-dynamics collapse（θ-α 零 negative → 学「沉默=安全」）= η-scope-split tiger 显形。
  2. surface mismatch（`tool_call_frame` 训练 target vs D-domain SpikeE3 tools 不同源）= 关联 §1 维度一 A 行 PR2 partial `ToolContractNormalizer` 硬编码 + B-frame state_delta 失效。
  - channel/extractor confounder 已被 base/tiny/iter100 tool events + iter400/600 raw dump **排除**（channel 通，模型早期能触发）。
- **🔴 下一步 = grill 拍方向**（合 θ-β / 加监督 / 改配方 / 重训 / 调 η scope），codex 与 CC **均不自拍**——这是维度二新增的「θ-α 失败定向」grill 议题（接 D1 之前）。

---

## 6. codex 临时收口归档（2026-06-22，磊哥喊停不再审计）

> codex 2h28m / ~1.5M tokens 后磊哥令临时收口。一手归档 = `Reports/c5-theta-alpha-20260622T162757/process-archive.md`（请求清单/已做/按红线没做/未解决缺口/验证快照）+ `completion-audit.md`（verdict 改 `AMENDED_CLOSEOUT_COMPLETE_WITH_FAILED_C6_METRIC_AND_COMPILER_SCAFFOLD_GAP`）。数字同 §5（jq 核）+ process-archive「What remains unresolved」。

**收口状态**：失败证据固化，lessons #49 + receipt + process-archive 落盘，candidate `UNSIGNED/BLOCKED`，无方向决策/重训/改配方。

**4 未解决缺口（= 下一步 grill 弹药）**：
1. θ-α C6 gate 仍 failed（no LoRA beats base，详 §5）。
2. iter100 unsafe/noisy（触发但乱调 + 误触发，详 §5）。
3. iter400/600 silent——**codex raw dump 坐实 `toolCalls=[] + chunkText=""` = 真不吐非提取漏**（钉死 collapse，排除 channel）。
4. **PR2 仍 scaffold**：`ToolContractNormalizer` 仍硬写 D-domain 映射（= §1 B 行 / B1，未闭合）→ **surface mismatch 竞争假设的物理载体**。

**verification 注意（两线交汇）**：`make verify`/`swift test` 早先过，**最终 report-only closeout 后未重跑**——因 worktree 有另一窗口 CC（harness 线）unstaged 的 `Makefile` cross-section 改动；codex 注意到没碰（正确，不跨线）。→ 收尾需补一次干净 `make verify`（待 Makefile 两线改动 settle）。

**🔴 下一步 = θ-α 失败定向 grill（维度二 D0，最高优先）**：先**判别两竞争假设**（claim-vs-reality：下钻不凭聚合）——拆 iter100 的 0/23 为 `tool_call_set_match` vs `state_delta_match`（调对名却 state_delta fail → 偏 surface mismatch/PR2 normalizer；iter400/600 真不吐 → 偏 collapse；**两假设可能作用在不同 checkpoint**），再定 5 方向（合 θ-β / 加 distractor 监督 / 改配方 / 重训 / 调 η scope）。
