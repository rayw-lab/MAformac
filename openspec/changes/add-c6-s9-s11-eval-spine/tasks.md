# C6 S9–S11 Eval Spine — Tasks

> DRAFT. 实现任务清单（给后续 coding producer）。本 OpenSpec producer 只交付文档 carrier；**不实现** `Tools/C6EvalSpine/**` / `contracts/c6-eval-spine/**` / `scripts/check_c6_eval_spine*`（那些路径属并行实现 producer）。
>
> Superpowers：实现阶段默认 TDD（RED→GREEN）+ verification-before-completion。S8 资源窗 active 时禁 full `make verify-all` / 全量 `swift test` / GPU eval。
>
> 措辞：D-147 决策 ratified ≠ B7 freeze 执行完成 ≠ V1 ceremony RATIFIED。

## 0. OpenSpec carrier（本批文档）

- [x] 0.1 写 `proposal.md`：Why / What / Non-Goals / Success / residual enum / D-147 决策 vs 执行分诊
- [x] 0.2 写 `design.md`：AD-SPINE-001…014 + stage machine + failure taxonomy + pre-mortem
- [x] 0.3 写 `tasks.md`（本文件）
- [x] 0.4 写 `specs/c6-eval-spine/spec.md`：ADDED Requirements + GIVEN/WHEN/THEN
- [x] 0.5 `openspec validate add-c6-s9-s11-eval-spine --strict`（本 OpenSpec producer 收口：Change is valid / rc0）
- [x] 0.6 `git diff --check` rc0；touched paths exact-set = 本 change 四文件（untracked，未 commit）
- [x] 0.7 **不 commit / 不 push**（避免与实现 producer 争 index）

## 1. Schemas + failure codes + fixtures（实现 producer）

- [ ] 1.1 创建 `contracts/c6-eval-spine/manifest.v1.json`：目录身份、stage 列表、non-claims、residual enum
- [ ] 1.2 创建 schemas：`s9-three-arm-manifest.v1` / `s9-arm-result.v1` / `s9-subject.v1` / `s9b-aggregate.v1` / `s10-verdict.v1` / `s10-subject.v1` / `s11-renderer-ack.v1` / `s11-subject.v1`
- [ ] 1.3 创建 `failure-codes.v1.json`（与 design taxonomy 一致）
- [ ] 1.4 fixtures 正例：三臂 fixture manifest；new arm ABSENT；S9b pass；S10 synthetic pass（`package_b3_done=false`）；S11 ack（promotion=NOT_STARTED, signoff=UNSIGNED）
- [ ] 1.5 fixtures 负例（各至少 1，真红）：real+new absent；forged real_model；holdout sha flip；B7 digest flip；threshold reinvent；real S10 + V1 CANDIDATE；missing/dup case；unknown behavior；S11 state collapse；package DONE claim
- [ ] 1.6 Superpowers：schema 先于 runner；fixture 可被 jsonschema 校验

## 2. Identity / holdout pin / B7+V1 bind

- [ ] 2.1 `Tools/C6EvalSpine/identity.py`：subject tuple 构建 + replay_fingerprint
- [ ] 2.2 holdout pin 核 D-127 sha `77853cae…` + row_count 61 + 四桶
- [ ] 2.3 B7 bind：assembled/compat/unordered_id_set + `is_b7_done` 显式读 candidate receipt
- [ ] 2.4 V1 bind：authority_digest + status + thresholds 只读文件
- [ ] 2.5 unit：pin 错红 / B7 错红 / V1 错红（TDD）

## 3. S9 three-arm runner + resume

- [ ] 3.1 arms：base / old / new；adapter_status present|absent；score_class real_model|synthetic|absent
- [ ] 3.2 mode=fixture|dry_run：new absent 合法；禁止输出 real_model
- [ ] 3.3 mode=real + new absent → 非 0 + `E_MODE_REAL_WITHOUT_NEW_ADAPTER`
- [ ] 3.4 arm result 含 AD-C6-008 七字段；缺字段红
- [ ] 3.5 resume：partial 原子写；subject drift 全量作废；seal 后禁 append
- [ ] 3.6 claims.forbidden 含 b2_done / s9_real_done / c6_acceptance / v_pass / candidate_signed

## 4. Exposure / near-dup bridge

- [ ] 4.1 bridge 调用 `scripts/check_train_eval_exposure.py`（不改其行为；必要时 thin wrapper 在 C6EvalSpine）
- [ ] 4.2 preflight 要求 exposure report rc0；违例 `E_EXPOSURE_VIOLATION`
- [ ] 4.3 deliberate near-dup 负例真红

## 5. S9b aggregate

- [ ] 5.1 exact join over (case_id × arm_id) + shared subject keys
- [ ] 5.2 missing / duplicate / unknown behavior / missing arm(real) fail-closed
- [ ] 5.3 输出 layer/bucket/joint 表；**不**内嵌阈值
- [ ] 5.4 seeds `[17,29,43]` 字段预留

## 6. S10 verdict

- [ ] 6.1 阈值只从 V1 `four_layer_thresholds` 解析；第二套阈值 → `E_THRESHOLD_REINVENT`
- [ ] 6.2 real + V1 CANDIDATE → `BLOCKED_AUTHORITY`
- [ ] 6.3 fixture synthetic PASS 允许且 `package_b3_done=false`
- [ ] 6.4 qa_safety + c5_phase1 槽位；harness 绿时 NOT_RUN 合法；real 签署前必跑语义写进 contract
- [ ] 6.5 `d114_failure_class` 四类字段；holdout_collapse 禁 waiver
- [ ] 6.6 joint_strike 子结构兼容既有 s10 joint 字段（不改共享 schema 文件）

## 7. S11 renderer ack

- [ ] 7.1 emit renderer_ack + s10_verdict_digest + renderer_contract_digest
- [ ] 7.2 downstream_envelope.payload_kind=renderer_ack；not 列表含 promotion_transaction / candidate_signoff
- [ ] 7.3 state_separation 三态；promotion/signoff 混淆负例 `E_STATE_COLLAPSE`
- [ ] 7.4 不执行 B5/B6

## 8. Checkers + synthetic full-chain

- [ ] 8.1 `scripts/check_c6_eval_spine.py --stage all|s9|s9b|s10|s11 --mode fixture|dry_run|real`
- [ ] 8.2 `scripts/test_check_c6_eval_spine*.py`：正例 + design 所列负例
- [ ] 8.3 synthetic full chain：S9→S9b→S10→S11 seal；rc0 且 status_labels 不含 B2/B3/B4 DONE
- [ ] 8.4 回归：`check_c6_corpus_lineage_candidate` + `check_c6_active_authority_candidate` 仍绿
- [ ] 8.5 **不改 Makefile**（共享投影延后）

## 9. Optional B7/V1 ceremony packets（窄，可选）

- [ ] 9.1 B7 freeze-packet schema + export helper（不写 `closure/receipts/B7.v1.json` DONE）
- [ ] 9.2 V1 ratification-packet schema + export helper（不翻 status=RATIFIED）
- [ ] 9.3 文档声明：packet 存在 ≠ freeze/ceremony 完成

## 10. 实现收口（实现 producer / commander）

- [ ] 10.1 lane CLOSEOUT：`DONE_LOCAL_EVAL_SPINE_READY_FOR_S8_FANIN` 或 PARTIAL；residual 三枚举诚实
- [ ] 10.2 HANDOFF.json：status/branch/head/base/touched_paths/validation/proof_class/residual
- [ ] 10.3 Non-claims 复述：非 S9/S10 DONE、非 B7/V1 DONE/RATIFIED、非 C6 acceptance/V-PASS、非 real three-arm、非 B5/B6
- [ ] 10.4 仅在授权时 commit owned paths；禁 `git add .`；禁 push force

## Verification commands（实现后）

```bash
openspec validate add-c6-s9-s11-eval-spine --strict
python3 -B scripts/test_check_c6_eval_spine.py
python3 -B scripts/check_c6_eval_spine.py --stage all --mode fixture
python3 -B scripts/check_c6_corpus_lineage_candidate.py
python3 -B scripts/check_c6_active_authority_candidate.py \
  contracts/c6-active-authority/authority.v1.candidate.json
git diff --check
```
