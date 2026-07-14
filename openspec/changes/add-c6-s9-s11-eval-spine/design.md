# C6 S9–S11 Eval Spine — Design

> DRAFT. 架构决策记录：**agree-before-build** 的 design 面。本文件不授权训练/点火/真三臂模型评测/B5–B6 promotion/registry DONE 翻转。
>
> 措辞分诊：D-147 = T01/T02 **决策 ratification 已完成**；B7 **freeze 执行**与 V1 **canonical ceremony** **仍未完成**。spine 绑定 candidate digests 合法；声称 package DONE / RATIFIED 非法。

## Scope

本 change 定义评测执行底座（eval spine）的：

1. **输入绑定**：D-127 holdout pin、B7 candidate digests、V1 authority digest/status/thresholds
2. **S9 三臂**：base / old / new；mode = `fixture | dry_run | real`
3. **same-subject exact join**（承接 AD-C6-014）
4. **resume-safe receipts**（partial 原子写 + subject 漂移作废）
5. **exposure / near-dup** 桥接既有 checker
6. **S9b 聚合**：缺/重/未知 fail-closed；不发明阈值
7. **S10 verdict**：阈值只读 V1；QA safety + C5 phase1 槽位；D-114 失败分流字段
8. **S11 renderer ack**：下游 envelope + `renderer_ack` / `promotion_transaction` / `candidate_signoff` 三态分离

实现落点（后续 producer，非本 design 文件写）：`Tools/C6EvalSpine/**`、`contracts/c6-eval-spine/**`、`scripts/check_c6_eval_spine*`。

## Stage state machine

```text
HARNESS_BUILT
  → S9_PREFLIGHT_GREEN          # schemas + pins + exposure
  → S9_FIXTURE_REPLAY_GREEN     # 三臂 synthetic；score_class ≠ real_model
  → S9_WAITING_S8_ADAPTER       # new arm ABSENT 合法终态之一
  → S9_REAL_THREE_ARM_DONE      # 仅 real adapter 灌入后
  → S9B_AGGREGATE_DONE
  → S10_VERDICT_CANDIDATE       # 机器 verdict 草稿，非 B3 package DONE
  → S10_BLOCKED_AUTHORITY       # V1 未 RATIFIED 或 B7 未 freeze（real path）
  → S11_RENDERER_ACK_EMITTED    # 下游 envelope，非 promotion
  → SPINE_READY_FOR_S8_FANIN    # 本任务目标上界

非法跃迁（硬拦）:
  HARNESS_BUILT → S9_REAL_THREE_ARM_DONE
  S9_FIXTURE_*  → claim B2 DONE / C6 acceptance / V-PASS
  S10_VERDICT_CANDIDATE → promotion transaction executed
  S11_RENDERER_ACK → candidate_signed
  any stage → forge score_class=real_model without present adapter
```

## Architecture Decisions

### AD-SPINE-001: Capability 独立为 `c6-eval-spine`，不改 vehicle-tool-bench 正文

S9–S11 执行底座是独立 capability delta，消费 rebuild-c6 / B7 / V1 的 digests 与阈值，**不** rewrite `rebuild-c6-four-layer-bench` 的 ADDED Requirements，**不**把 B7/V1 candidate 升格为 canonical。

### AD-SPINE-002: 三 mode 语义与 adapter 门

| mode | new adapter absent | 允许的 score_class | real S9/S10 package DONE |
|------|--------------------|--------------------|--------------------------|
| `fixture` | 合法 | `synthetic` 或 `absent` | 禁止 |
| `dry_run` | 合法 | `synthetic` 或 `absent` | 禁止 |
| `real` | **非法** → `E_MODE_REAL_WITHOUT_NEW_ADAPTER` | 仅 `real_model`（adapter present）或明确 `absent` 的 old arm | 仍须 ceremony/registry 另办 |

`score_class=real_model` 而 adapter `absent` 或路径为 synthetic → `E_FORGED_REAL_SCORE`。

### AD-SPINE-003: Holdout pin = D-127 only

S9 case 面 **唯一** pin D-127 holdout：

- `sha256 = 77853caea4598f334fb4a7ed89eafc348746adf333d647306aa94f0b68da2f64`
- `row_count = 61`
- buckets = `{primary:33, topic_fronted:9, negative:10, particle_tail:9}`

B7 57-case release corpus 是 lineage/release 输入，**不是** S9 holdout 弹药（混用 → 曝光/口径污染）。holdout sha 漂移 → `E_HOLDOUT_SHA_MISMATCH`。

### AD-SPINE-004: B7 digest 绑定 ≠ B7 DONE / T02 freeze 完成

spine subject **必须**绑定 B7 candidate 的：

- `assembled_sha256`（live 例：`6952a7e8…`）
- `compat_sha256`（live 例：`47806412…`）
- `unordered_id_set_sha256`（live 例：`e4055568…`）
- `is_b7_done` 显式布尔（candidate 现为 `false`）

digest 与 candidate receipt 不一致 → `E_B7_DIGEST_MISMATCH`。
`mode=real` 的正式 S9 路径可要求 `is_b7_done=true`（freeze 执行完成后）；fixture/dry-run **允许** `false`。
D-147 只证明 **决策 ratified**，**不**证明 freeze 执行完成。

### AD-SPINE-005: V1 阈值只读 authority 文件；禁止第二 SSOT

S9b/S10 **禁止**在 manifest 或代码常量内嵌第二套四层阈值。阈值 **只能** 从 V1 authority 文档的 `subject.four_layer_thresholds`（或等价已 digest 绑定字段）解析：

- golden = 1.0
- demo_fuzz formula = `5*pass >= 4*eligible`
- unsupported = 1.0
- safety = 1.0

内嵌覆盖 → `E_THRESHOLD_REINVENT`。
authority digest 漂移 → `E_V1_DIGEST_MISMATCH`。
`mode=real` 且 `observed_status != RATIFIED` → S10 `status=BLOCKED_AUTHORITY` / `E_V1_NOT_RATIFIED`（不是 PASS）。
fixture 可产出 synthetic PASS **仅** 供 harness 自测，且 `claims.package_b3_done` 必须 `false`。

### AD-SPINE-006: same-subject exact join（承接 AD-C6-014）

比较 base/old/new 同一 `case_id` 时，下列 key 必须字节级相等（缺失/重复/不等 → `INCOMPARABLE` / `E_INCOMPARABLE_SUBJECT`，无人工 override）：

**共享 join keys（臂间必须相等）**：
`repo_head`, `holdout_sha256`, `holdout_row_count`, `b7_assembled_sha256`, `b7_compat_sha256`, `b7_unordered_id_set_sha256`, `b7_is_done`, `v1_authority_digest`, `v1_status`, `prompt_policy_digest`, `parser_id`, `mock_state_digest`, `contract_bundle_digest`, `selector_corpus_digest`, `mode`

**臂级允许不同**：
`arm_id`, `adapter_artifact_sha256`, `adapter_status`, `score_class`, `scorer_id`（若 scorer 绑定臂）、`replay_fingerprint`, `run_id`

multi-seed 扩展位保留 seeds `[17,29,43]`（AD-C6-014）；单次 harness 可 `seed=null`，但 schema 必须保留字段。

### AD-SPINE-007: Resume-safe receipts

| 机制 | 规则 |
|------|------|
| partial dir | `…/s9/partial/{case_id}.{arm_id}.json` 原子写（tmp+rename） |
| resume | 读 completed set；同 subject 才续；subject 变 → `E_RESUME_SUBJECT_DRIFT` 全量作废 |
| seal | 全 cases×arms 齐 + schema 过 → seal digest；sealed 后 append 禁止 |
| binding | receipt 绑定：`repo_head, holdout_sha, b7_digests, v1_digest, adapter_sha\|ABSENT, scorer_id, contract_bundle_ids` |

思想对齐 S8 G1 receipt chain，**不修改** S8 文件。

### AD-SPINE-008: Exposure / near-dup 桥接既有门

spine preflight **调用** `scripts/check_train_eval_exposure.py`（或等价 bridge），**默认不改其 symbol 行为**。exposure 违例 → `E_EXPOSURE_VIOLATION`（对齐既有 rc66 语义）。near-dup deliberate-red fixture 必须真红。
exposure 五级 enum 承接 AD-C6-015：`release_corpus | training | checkpoint_selection | prompt_tuning | s9_repair`。

### AD-SPINE-009: S9b 聚合不发明阈值

S9b 只做：

- same-subject exact join over `(case_id × arm_id)`
- per-layer / per-bucket / joint rates
- missing case / duplicate case / unknown behavior_class / missing arm（real）fail-closed

阈值读取律 = AD-SPINE-005。behavior 五类 = AD-C6-007（禁 `direct_no_call`）。readback 七字段 = AD-C6-008；缺字段 → `E_UNKNOWN_READBACK_FIELD`。

### AD-SPINE-010: S10 verdict 完整面 + 兼容 joint 子结构

`s10_verdict_v1` 是 spine 主 schema。既有 joint-only `s10-receipt.schema.json` **不扩展为 full verdict**（避免共享 schema blast）；joint 字段可作为 `joint_strike` 子结构嵌入。
S10 必须暴露：

- `status ∈ {PASS, FAIL, BLOCKED_AUTHORITY, BLOCKED_MISSING_REAL_SCORES, INCOMPARABLE}`
- authority 观察态 vs 要求态
- 四层 gate
- `qa_safety` 槽（`PASS|FAIL|NOT_RUN`）
- `c5_phase1` 槽（`PASS|FAIL|NOT_RUN`；命令意图 `make verify-c5-phase1-gates`，实现可用独立调用）
- `d114_failure_class` 字段（`runtime_qa_fail | coverage_debt | causal_bet_falsified | holdout_collapse`；holdout 塌 **禁 waiver**）
- `claims.package_b3_done=false` 在 harness/fixture 路径强制

### AD-SPINE-011: S11 三态分离

`renderer_ack`、`promotion_transaction`、`candidate_signoff` **不是同一状态**。

| 态 | S11 合法值（本 spine） | 非法 |
|----|------------------------|------|
| `renderer_ack` | `EMITTED` 或 `ABSENT` | 因 promotion 伪造成功 |
| `promotion_transaction` | `NOT_STARTED` | 仅因 S11 写 `DONE` |
| `candidate_signoff` | `UNSIGNED` | 仅因 S11 写 `SIGNED` |

混淆 → `E_STATE_COLLAPSE`。downstream envelope 可声明 consumers `B5_c2_expansion` / `B6_promotion_transaction` / `operator_lane`，但 **不执行** B5/B6。

### AD-SPINE-012: Package DONE claim 硬禁

任何 spine receipt 写 `b2_done=true` / `b3_done=true` / `b4_done=true` / `c6_acceptance` / `v_pass` / `candidate_signed` → `E_PACKAGE_DONE_CLAIM`。
harness 绿只允许 claims 如 `local_harness` / `fixture_replay` / `spine_ready_for_s8_fanin`。

### AD-SPINE-013: 独立脚本入口；共享 seam 延后

并行期 **不改** `Makefile` / registry YAML / roadmap / decisions。验证入口 = `scripts/check_c6_eval_spine.py --stage all|s9|s9b|s10|s11`。共享投影（若需）由 lane A 在确认无 S8 writer 后单次写入，不在本 change 文档阶段做。

### AD-SPINE-014: B7 freeze packet / V1 ratification packet 可导出、不可伪完成

可选 helper 导出 **ceremony 消费包**（字段冻结），落 candidate 侧或 Tools 侧：

- B7 freeze packet：assembled/compat/id-set digests + holdout_sha + exposure_acl=`must_not_train` + source_row_counts `{45,12}`；`is_b7_done→true` **仅** ceremony 写 canonical receipt
- V1 ratification packet：authority_digest + `CANDIDATE→RATIFIED` 字段 + operator_id/ceremony_ts 槽；hard_layer_denominators 策略显式

导出 helper **存在 ≠** freeze/ceremony 已完成。

## Failure taxonomy（机器码）

| code | 触发 |
|------|------|
| `E_MODE_REAL_WITHOUT_NEW_ADAPTER` | mode=real & new absent |
| `E_FORGED_REAL_SCORE` | real_model 无 present adapter |
| `E_HOLDOUT_SHA_MISMATCH` | pin ≠ D-127 sha |
| `E_B7_DIGEST_MISMATCH` | B7 digests 漂移 |
| `E_V1_DIGEST_MISMATCH` | V1 digest 漂移 |
| `E_THRESHOLD_REINVENT` | 内嵌第二套阈值 |
| `E_V1_NOT_RATIFIED` | real verdict 时 status≠RATIFIED |
| `E_B7_NOT_FROZEN` | real S9 要求 freeze 而 is_b7_done=false |
| `E_EXPOSURE_VIOLATION` | train/eval leak / near-dup |
| `E_UNKNOWN_BEHAVIOR_CLASS` | 非五类或 direct_no_call |
| `E_UNKNOWN_READBACK_FIELD` | Plan-P 七字段缺 |
| `E_MISSING_CASE` / `E_DUPLICATE_CASE` | join 破 |
| `E_MISSING_ARM` | real 三臂不全 |
| `E_RESUME_SUBJECT_DRIFT` | partial subject 不等 |
| `E_STATE_COLLAPSE` | S11 冒充 promotion/signoff |
| `E_PACKAGE_DONE_CLAIM` | harness 写 B2/B3/B4 DONE 等 |
| `E_INCOMPARABLE_SUBJECT` | same-subject fail |
| `E_LAYER_DENOM_ZERO_EXTINCTION` | demo_fuzz 等灭绝条件 |
| `E_D114_HOLDOUT_COLLAPSE` | holdout 塌（禁 waiver） |
| `E_QA_SAFETY_FAIL` / `E_C5_PHASE1_FAIL` | 对应门红 |

## 已实现的文档级联

以下文档已在实现阶段创建或更新，反映 spine 最终行为：

| 文档 | 路径 | 类型 | 内容 |
|------|------|------|------|
| Durable lessons | `Tools/C6EvalSpine/LESSONS.md` | 新建 | L1-L10 可复用教训 |
| Corpus lineage operator guide | `Tools/C6CorpusLineage/README.md` | 新建 | B7 freeze packet 操作手册 |
| Authority packet guide | `Tools/C6ActiveAuthority/README.md` | 更新 | 追加 V1 ratification packet 导出/ceremony 边界 |
| Eval spine README | `Tools/C6EvalSpine/README.md` | 已有（并行 producer 可能已更新） | 不在此 change 覆盖 |

## Pre-Mortem（已知失败模式）

| tiger | 来源 | 防护 |
|-------|------|------|
| fixture 绿写成 S9/S10 DONE | claim-vs-reality / 0/34 同源 | AD-SPINE-012 + residual enum |
| 阈值写死代码双 SSOT | 历史 scorer 分叉 | AD-SPINE-005 |
| C6 57 当 holdout | 弹药污染 | AD-SPINE-003 |
| candidate 标 DONE 绕 exit envelope | exit schema 强制 DONE | AD-SPINE-004/014；candidate 故意不进 DONE 信封 |
| S11 与 promotion 状态坍缩 | 产品链路抢跑 | AD-SPINE-011 |
| 改 Makefile 撞共享 seam | 并行 S8/B 写面 | AD-SPINE-013 |
| 伪造 real_model | 无 adapter 假评测 | AD-SPINE-002 |

## Non-Goals

- 不训练 / 不点火 / 不跑真三臂模型质量
- 不执行 B5/B6
- 不写 Makefile / registry / roadmap / decisions / App / Core
- 不声称 B7 freeze 执行完成或 V1 RATIFIED ceremony 完成
- 不声称 S9/S10 package DONE / C6 acceptance / V-PASS / operator-pass / candidate signed
- 不 supersede rebuild-c6 或 B7/V1 candidate carriers 的诚实非 DONE 自声明

## Authority conflict order（实现时）

1. live candidate JSON / holdout 文件字节 + registry YAML 字段
2. D-127 / D-147 / D-114 decisions
3. rebuild-c6 AD-C6-*
4. B7/V1 OpenSpec carriers
5. 本 design / proposal
6. 旧 handoff / CURRENT（router only）

B7 receipt 与 tracked 57 冲突 → B7 checker 红优先，禁改 tracked 凑绿。
V1 阈值与 spine 常量冲突 → V1 文件优先，删常量。
