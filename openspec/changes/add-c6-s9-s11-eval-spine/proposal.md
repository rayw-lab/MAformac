---
status: draft_needs_human_propose
typed_status:
  lifecycle_status: draft_needs_human_propose
  c08_disposition: NEW_CHANGE
  previous_wait: none
  wait_resolution: {}
  next_status_recommendation: run_opsx_propose_and_obtain_human_review
  status_action_this_change: keep_draft_needs_human_propose
  propose_performed_this_change: false
  implementation_authorized_this_change: false
---

# Add C6 S9–S11 Eval Spine

> DRAFT. 本 change 定义 **C6 评测执行底座（eval spine）** 的可观察行为契约：把已有 B7 corpus lineage **candidate**、V1 active authority **candidate**、以及 D-127 冻结 holdout 变成一条可重放、fail-closed、可等待 S8 新 adapter 灌入的 `S9 → S9b → S10 → S11` 机器链路。
>
> 本 carrier **不** supersede `rebuild-c6-four-layer-bench`，**不** supersede `add-b7-corpus-lineage-candidate` / `add-v1-active-authority-candidate` 的 candidate 语义；它消费它们的 digest/authority 绑定面。
>
> 🔴 **措辞分诊（D-147 已完成决策 ratification ≠ 执行完成）**：
> - D-147 已完成 **T01/T02 决策 ratification**（decision_state 层）。
> - B7 **freeze 执行**（写 `closure/receipts/B7.v1.json` status=DONE、registry flip）**仍未完成**。
> - V1 **canonical ceremony**（`status=CANDIDATE → RATIFIED`、写 `closure/receipts/V1.v1.json` DONE）**仍未完成**。
> - 本 change 允许 spine 在 fixture/dry-run 下 **绑定 candidate digests**；禁止把 B7/V1 写成 canonical/DONE/RATIFIED，禁止把 harness 绿写成 S9/S10 package DONE。

## Why

B2（S9 三臂）/ B3（S9b+S10）/ B4（S11 renderer ack）在 `contracts/closure-work-packages.v1.yaml` 中仍为 execution `blocked|planned`，native schema 分别为 `s9_three_arm_v1` / `s10_verdict_v1` / `renderer_ack_v1`。现有仓内已有：

- B7 durable **candidate**（57=45 gen+12 manual_trap；`is_b7_done=false` / `is_canonical=false`）
- V1 authority **candidate**（`status=CANDIDATE`；阈值 golden/unsupported/safety=1.0，demo_fuzz=`5*pass>=4*eligible`）
- D-127 holdout **FROZEN**（61 行四桶 33/9/10/9，sha `77853cae…`）
- exposure/near-dup 既有 checker（`scripts/check_train_eval_exposure.py`）

但缺少把上述输入拼成 **可执行、可恢复、fail-closed** 的 S9–S11 spine：三臂 manifest、same-subject exact join、resume-safe receipts、阈值只读 V1、S11 三态分离、以及「新 adapter 缺失时只允许 fixture/dry-run、禁伪造 real_model 分」的硬门。

本 change 的存在意义：先立 **行为契约 + 实现任务清单**（agree-before-build），供后续实现 producer 在独立目录 `Tools/C6EvalSpine/**` + `contracts/c6-eval-spine/**` + `scripts/check_c6_eval_spine*` 落地；本 OpenSpec carrier 本身 **不训练、不点火、不跑真三臂、不写共享 Makefile/registry DONE 信封**。

## What Changes

### 本 carrier 授权的产物面（实现阶段；本 proposal 只定义契约）

| 领域 | 目标路径（实现 producer 写集，非本 OpenSpec 文件） | 用途 |
|------|--------------------------------------------------|------|
| 执行库 | `Tools/C6EvalSpine/**` | identity / holdout pin / B7+V1 bind / 三臂 runner / S9b / S10 / S11 / resume |
| 契约 | `contracts/c6-eval-spine/**` | manifest + schemas + failure codes + deliberate-red fixtures |
| 门 | `scripts/check_c6_eval_spine*.py` + `scripts/test_check_c6_eval_spine*.py` | 独立 fail-closed 入口；不改 Makefile |
| 可选窄 helper | B7 freeze-packet / V1 ratification-packet **导出**（仅 candidate 侧） | 供后续 ceremony 消费；**不**写 DONE 信封 |

### 本 OpenSpec change 本批 writable 文件（仅文档）

| Path | Purpose |
|------|---------|
| `openspec/changes/add-c6-s9-s11-eval-spine/proposal.md` | 本文件 |
| `openspec/changes/add-c6-s9-s11-eval-spine/design.md` | 架构决策 AD-SPINE-* |
| `openspec/changes/add-c6-s9-s11-eval-spine/tasks.md` | 实现任务清单 |
| `openspec/changes/add-c6-s9-s11-eval-spine/specs/c6-eval-spine/spec.md` | 能力 `c6-eval-spine` 行为契约 delta |

### No-touch（硬）

- `Tools/C6EvalSpine/**`、`contracts/c6-eval-spine/**`、`scripts/check_c6_eval_spine*` —— **本 OpenSpec producer 本批不写**；留给实现 producer
- `App/**`、`Core/**`、`Makefile`、`contracts/closure-work-packages.v1.yaml`
- `docs/roadmap*`、`docs/commander-log/decisions.md`、`docs/CURRENT.md`
- S8 recipe / trainpack / adapter / model / lease / launcher / completion receipt
- canonical `closure/receipts/{B2,B3,B4,B7,V1}.v1.json`（DONE 信封留给 ceremony / 后续 fan-in）
- 不改 `add-b7-corpus-lineage-candidate` / `add-v1-active-authority-candidate` / `rebuild-c6-four-layer-bench` 既有正文以「做绿」

## Decision / authority sources

- 派单：`runs/2026-07-14-v9-parallel-longruns/dispatches/CODEXAPP-SOL-HIGH-LONGRUN-A-AUTHORITY-EVAL-SPINE.md`
- 设计包：`lane-a-authority-eval/evidence/GROK45-ARCHITECTURE.md`（design-only evidence）
- `docs/commander-log/decisions.md` D-127（holdout FROZEN）/ D-147（T01/T02 **决策** ratification）/ D-114（S10 失败四类分流）
- `contracts/closure-work-packages.v1.yaml` B2/B3/B4/B7/V1
- `openspec/changes/rebuild-c6-four-layer-bench` AD-C6-007/008/014/015/016
- `openspec/changes/add-b7-corpus-lineage-candidate` + live `closure/candidates/B7/**`
- `openspec/changes/add-v1-active-authority-candidate` + live `contracts/c6-active-authority/authority.v1.candidate.json`
- `scripts/check_train_eval_exposure.py`（exposure 既有门，bridge 调用不改其行为）

## Live input snapshot（实现须 reconfirm，禁静默漂移）

| 输入 | 现态 | spine 用法 |
|------|------|------------|
| Holdout D-127 | FROZEN 61 行；sha **`77853caea4598f334fb4a7ed89eafc348746adf333d647306aa94f0b68da2f64`**；桶 33/9/10/9 | S9 case 面 pin；sha 错 → fail-closed |
| B7 candidate | assembled=`6952a7e8…`；compat=`47806412…`；unordered_id_set=`e4055568…`；`is_b7_done=false` | subject 绑定 digest；**非** T02 freeze DONE |
| V1 candidate | digest=`adc6b42c…`；`status=CANDIDATE`；阈值在 `subject.four_layer_thresholds` | 阈值 **只读** 此文件；real verdict 要求 RATIFIED |
| S8 new adapter | 缺失 / NOT_READY | 仅 `mode=fixture\|dry_run`；`score_class≠real_model` |

## Success Criteria（本 OpenSpec 文档 carrier）

- `openspec validate add-c6-s9-s11-eval-spine --strict` 通过
- `git diff --check` 通过
- touched paths **exact-set** = 本 change 四文件（及必要父目录）
- proposal / design / tasks / spec 均显式分离：决策 ratification vs freeze/ceremony 执行；harness 绿 vs package DONE；fixture vs real_model
- spec 覆盖可观察行为：S9 三臂、D-127 holdout、B7/V1 digest bind、same-subject join、resume-safe receipts、exposure/near-dup、S9b aggregate、S10 阈值只读 V1 + QA safety/C5 gate、missing/unknown/duplicate fail-closed、S11 三态分离、new adapter 缺失只允许 fixture/dry-run、禁伪造模型分

## Non-Goals（硬边界）

- ❌ 不训练、不点火、不启动 S8、不碰 S8 recipe/trainpack/adapter/model/lease/launcher/receipt
- ❌ 不把 B7/V1 **candidate** 写成 **canonical / DONE / RATIFIED**
- ❌ 不执行 B5/B6 promotion transaction
- ❌ 不写 `Makefile` / `closure-work-packages.v1.yaml` / roadmap / decisions / App / Core
- ❌ 不声明 S9 / S9b / S10 / S11 **package DONE**、C6 acceptance、V-PASS、operator-pass、candidate signed
- ❌ 不伪造 real 三臂模型分数；fixture 绿 ≠ 评测绿
- ❌ 不把 C6 57 release corpus 当作 S9 holdout 弹药（holdout=D-127 61）
- ❌ 不在 spine 代码常量内嵌第二套阈值（阈值只从 V1 authority 文件读）
- ❌ 本 OpenSpec producer **不 commit / 不 push**（避免与并行实现 producer 争 git index）

## Impact

- 新增 capability 行为面 `c6-eval-spine`（OpenSpec delta only）。
- 实现后为 B2/B3/B4 提供可机械消费的 harness 与 receipt 形状；**不自动**翻转 registry execution_state。
- 与任务 B（product/operator lane）写集正交；与 S8 训练窗正交（S8 active 时仅 schema/fixture/小型 checker）。

## Residual enum（实现收口必选，与派单一致）

任一存在则不得写 S9/S10 DONE：

| residual | 当前默认 |
|----------|----------|
| `missing_s8_adapter` | 是 |
| `missing_t01_t02_ratification` | **决策层否 / 执行层是**（D-147 decision ratified；B7 freeze 执行 + V1 ceremony 仍缺） |
| `no_real_three_arm_scores` | 是 |
| `none` | 否 |

目标终态上界：`DONE_LOCAL_EVAL_SPINE_READY_FOR_S8_FANIN`（仅 harness 就绪），residual **不得** 写成 `none`。
