# C6 Eval Spine — Spec

> 本 spec 描述 capability **`c6-eval-spine`** 的可观察行为：S9 三臂执行 → S9b 聚合 → S10 技术 verdict → S11 renderer ack。
>
> 它 **不** 修改 `vehicle-tool-bench` capability 正文，**不** supersede `rebuild-c6-four-layer-bench`，**不** 把 B7/V1 candidate 升格为 DONE/RATIFIED。
>
> 🔴 决策 vs 执行：D-147 已完成 T01/T02 **决策 ratification**；B7 freeze **执行**与 V1 **canonical ceremony** 仍未完成。本 capability 的 harness 绿 **不得** 被观察为 S9/S10 package DONE 或 C6 acceptance。

## ADDED Requirements

### Requirement: Spine modes separate fixture harness from real evaluation

The eval spine SHALL accept exactly three execution modes: `fixture`, `dry_run`, and `real`. When the new-adapter arm is absent, the spine SHALL allow only `fixture` or `dry_run`. A `real` mode run with an absent new adapter SHALL fail closed. Synthetic or fixture scoring paths SHALL NOT emit `score_class=real_model`.

#### Scenario: Fixture mode accepts absent new adapter

- **GIVEN** a three-arm manifest with `mode=fixture` and `arms.new.adapter_status=absent`
- **WHEN** the S9 spine preflight and fixture runner execute
- **THEN** the run SHALL complete without requiring a live S8 adapter
- **AND** every arm result SHALL use `score_class` in `{synthetic, absent}` only
- **AND** the receipt SHALL NOT claim S9 package DONE, C6 acceptance, or V-PASS

#### Scenario: Real mode without new adapter fails closed

- **GIVEN** a three-arm manifest with `mode=real` and `arms.new.adapter_status=absent`
- **WHEN** the S9 spine executes
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_MODE_REAL_WITHOUT_NEW_ADAPTER` (or an equivalent machine code)

#### Scenario: Forged real model scores fail closed

- **GIVEN** any arm result marked `score_class=real_model` while its adapter is absent or the path is synthetic-only
- **WHEN** the spine validates arm results
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_FORGED_REAL_SCORE`

---

### Requirement: S9 executes three arms base, old, and new

The S9 stage SHALL produce a three-arm evaluation surface over arms `base`, `old`, and `new`. Each arm result SHALL identify `arm_id`, `case_id`, `adapter_status` in `{present, absent}`, and `score_class` in `{real_model, synthetic, absent}`. Arm results that claim model hard-pass SHALL expose the AD-C6-008 seven-field readback split: `model_hard_pass_basis`, `model_hard_failed`, `readback_applicable`, `readback_match`, `readback_hard_failed`, `readback_excluded_from_model_hard_pass`, and `renderer_contract_digest`. Missing any of those fields SHALL fail closed.

#### Scenario: Three-arm manifest is required

- **GIVEN** an S9 run request
- **WHEN** the spine builds or loads the S9 manifest
- **THEN** the manifest SHALL declare arms `base`, `old`, and `new`
- **AND** each arm SHALL declare adapter status and score class

#### Scenario: Missing readback fields fail closed

- **GIVEN** an arm result that omits any of the seven readback fields
- **WHEN** the S9 validator checks the result
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_UNKNOWN_READBACK_FIELD`

---

### Requirement: D-127 frozen holdout is the only S9 case surface pin

S9 case materialization SHALL pin the D-127 frozen holdout identity: content SHA-256 equal to `77853caea4598f334fb4a7ed89eafc348746adf333d647306aa94f0b68da2f64`, row count `61`, and bucket counts `primary=33`, `topic_fronted=9`, `negative=10`, `particle_tail=9`. The B7 57-case release corpus SHALL NOT substitute for the holdout case surface. Holdout hash mismatch SHALL fail closed.

#### Scenario: Holdout pin mismatch fails closed

- **GIVEN** a manifest whose holdout SHA-256 differs from the D-127 frozen value by any bit
- **WHEN** S9 preflight runs
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_HOLDOUT_SHA_MISMATCH`

#### Scenario: Clean holdout pin is accepted for fixture replay

- **GIVEN** a manifest that pins holdout SHA-256 `77853cae…`, row_count `61`, and the four bucket counts above
- **WHEN** S9 preflight runs in `fixture` mode
- **THEN** the holdout pin check SHALL pass
- **AND** the spine SHALL still treat package B2 as not DONE

---

### Requirement: B7 candidate digests bind the subject without claiming freeze DONE

The spine subject SHALL bind B7 candidate digests for assembled content, compatibility fingerprint, and unordered id-set, and SHALL carry an explicit boolean `b7_is_done` / `is_b7_done`. Digest mismatch against the live B7 candidate receipt SHALL fail closed. A true value of `is_b7_done` SHALL NOT be inferred from D-147 decision ratification alone. Fixture and dry-run modes MAY proceed with `is_b7_done=false`. Real S9 freeze-required paths MAY require `is_b7_done=true` and SHALL fail closed when freeze execution is still incomplete.

#### Scenario: B7 digest mismatch fails closed

- **GIVEN** a manifest whose `b7_assembled_sha256` (or compat / unordered-id-set digest) does not match the live B7 candidate receipt
- **WHEN** S9 preflight runs
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_B7_DIGEST_MISMATCH`

#### Scenario: Candidate non-done remains honest under harness green

- **GIVEN** a fixture-mode full chain that passes with B7 candidate digests bound and `is_b7_done=false`
- **WHEN** status is reported from spine receipts alone
- **THEN** reporting SHALL keep B7 as non-canonical / non-DONE
- **AND** it SHALL NOT claim T02 freeze execution complete solely because D-147 ratified T02 decisions

---

### Requirement: V1 authority digest and thresholds are the only yardstick source

The spine SHALL bind a V1 authority digest and observed status. S9b aggregation and S10 verdict thresholds SHALL be read only from the bound V1 authority document fields for four-layer thresholds (`golden`, `demo_fuzz` formula `5*pass >= 4*eligible`, `unsupported`, `safety`). A second embedded threshold set in the spine manifest or code path SHALL fail closed as threshold reinvention. V1 digest mismatch SHALL fail closed. Decision ratification of T01 under D-147 SHALL NOT be observed as V1 `RATIFIED` ceremony completion while the authority document remains `CANDIDATE`.

#### Scenario: Threshold reinvention fails closed

- **GIVEN** an S9b or S10 input that embeds a second four-layer threshold set different from the bound V1 authority file
- **WHEN** the spine loads thresholds
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_THRESHOLD_REINVENT`

#### Scenario: Real verdict blocks on non-ratified V1

- **GIVEN** `mode=real` and a bound V1 authority whose `status=CANDIDATE`
- **WHEN** S10 produces a technical verdict
- **THEN** the verdict status SHALL be `BLOCKED_AUTHORITY` (or equivalent non-PASS)
- **AND** the failure code or authority block SHALL identify `E_V1_NOT_RATIFIED`
- **AND** the receipt SHALL NOT claim B3 package DONE

#### Scenario: Fixture synthetic pass keeps package claims false

- **GIVEN** a fixture-mode S10 run whose layer arithmetic would pass under V1 thresholds
- **WHEN** the spine emits an S10 verdict for harness self-test
- **THEN** the verdict MAY report a synthetic PASS for harness purposes
- **AND** `claims.package_b3_done` SHALL be false
- **AND** the receipt SHALL NOT claim C6 acceptance, V-PASS, or candidate signed

---

### Requirement: Same-subject exact join governs multi-arm comparison

Base/old/new comparison for the same `case_id` SHALL require byte-equal shared subject keys for repository head, holdout identity, B7 digests and done flag, V1 digest and status, prompt policy, parser, mock state, contract bundle, selector/corpus identity, and mode. Missing, duplicate, or unequal shared keys SHALL make results incomparable without manual override. Arm-local fields (`arm_id`, adapter artifact, adapter status, score class, run id, arm replay fingerprint) MAY differ across arms.

#### Scenario: Unequal shared subject keys are incomparable

- **GIVEN** base and new arm results for the same `case_id` whose shared holdout or B7 or V1 digests differ
- **WHEN** S9b joins arms
- **THEN** the aggregate SHALL mark the pair `INCOMPARABLE`
- **AND** the process SHALL fail closed without human override

#### Scenario: Missing or duplicate case ids fail closed

- **GIVEN** an arm result set missing an expected holdout `case_id` or containing a duplicate `case_id`
- **WHEN** S9b aggregates
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_MISSING_CASE` or `E_DUPLICATE_CASE`

---

### Requirement: Receipts are resume-safe and subject-bound

Partial S9 progress SHALL be written atomically per `{case_id, arm_id}`. Resume SHALL continue only when the partial set shares the same subject identity as the active manifest. Subject drift SHALL invalidate the partial set. A sealed receipt SHALL bind repository head, holdout hash, B7 digests, V1 digest, adapter identity or ABSENT, scorer id, and contract bundle identity. Append after seal SHALL fail closed.

#### Scenario: Resume subject drift invalidates partials

- **GIVEN** partial arm results sealed under subject A
- **WHEN** a resume attempt starts with subject B that differs in any shared subject key
- **THEN** the spine SHALL refuse to merge partials
- **AND** the failure code SHALL identify `E_RESUME_SUBJECT_DRIFT`

#### Scenario: Successful resume reuses completed case-arm pairs

- **GIVEN** partial results under an identical subject for a subset of case-arm pairs
- **WHEN** resume continues
- **THEN** completed pairs SHALL not be recomputed
- **AND** remaining pairs SHALL run until full coverage can seal

---

### Requirement: Exposure and near-dup defenses fail closed

S9 preflight SHALL run an exposure / near-dup gate over train versus eval/holdout surfaces. A near-duplicate or training-exposure violation SHALL fail closed. The exposure surface SHALL be classifiable under the AD-C6-015 exposure enum levels: `release_corpus`, `training`, `checkpoint_selection`, `prompt_tuning`, and `s9_repair`.

#### Scenario: Near-dup exposure turns preflight red

- **GIVEN** a deliberate near-duplicate between a training surface and the pinned holdout
- **WHEN** exposure preflight runs
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_EXPOSURE_VIOLATION`

#### Scenario: Clean exposure allows fixture preflight to continue

- **GIVEN** an exposure report with no train/holdout leak for the pinned subject
- **WHEN** fixture-mode preflight runs
- **THEN** the exposure gate SHALL pass
- **AND** the spine SHALL still forbid claiming real three-arm DONE

---

### Requirement: S9b aggregates without inventing thresholds

S9b SHALL aggregate per-layer, per-bucket, and joint rates from joined arm results. It SHALL NOT redefine thresholds. Unknown behavior classes outside the five-class taxonomy (`tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`) SHALL fail closed. Real-mode aggregation with a missing arm SHALL fail closed.

#### Scenario: Unknown behavior class fails closed

- **GIVEN** an arm result whose `behavior_class_observed` is `direct_no_call` or another non-taxonomy value
- **WHEN** S9b aggregates
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_UNKNOWN_BEHAVIOR_CLASS`

#### Scenario: Real mode missing arm fails closed

- **GIVEN** `mode=real` and arm results for only two of the three arms
- **WHEN** S9b aggregates
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_MISSING_ARM`

---

### Requirement: S10 technical verdict reads V1 thresholds and records safety gates

S10 SHALL emit a technical verdict with status in `{PASS, FAIL, BLOCKED_AUTHORITY, BLOCKED_MISSING_REAL_SCORES, INCOMPARABLE}`. Layer gates SHALL use only V1-bound thresholds. The verdict SHALL expose slots for QA safety and C5 phase-1 gate outcomes with values in `{PASS, FAIL, NOT_RUN}`. Fixture harness green MAY leave those slots `NOT_RUN`. Real signing paths that claim complete technical acceptance SHALL not treat permanent `NOT_RUN` as success. The verdict SHALL expose a D-114 failure-class field whose holdout-collapse class SHALL NOT be waived.

#### Scenario: Missing real scores block real verdict

- **GIVEN** `mode=real` without complete real three-arm scores
- **WHEN** S10 verdict is produced
- **THEN** status SHALL be `BLOCKED_MISSING_REAL_SCORES` or FAIL-closed equivalent
- **AND** the receipt SHALL NOT claim B3 DONE

#### Scenario: Holdout collapse is non-waivable

- **GIVEN** S10 evidence that classifies failure as holdout collapse under D-114
- **WHEN** the verdict is emitted
- **THEN** `d114_failure_class` SHALL equal `holdout_collapse` (or equivalent)
- **AND** the spine SHALL NOT accept a waiver that converts the failure into PASS

#### Scenario: QA safety and C5 phase1 slots are explicit

- **GIVEN** an S10 verdict object
- **WHEN** it is validated
- **THEN** it SHALL contain explicit `qa_safety.status` and `c5_phase1.status` fields
- **AND** unknown/omitted slots SHALL NOT be silently treated as PASS

---

### Requirement: S11 emits renderer ack and downstream envelope without promotion or signoff collapse

S11 SHALL emit a renderer-ack artifact bound to an S10 verdict digest and a renderer contract digest. The downstream envelope SHALL declare payload kind `renderer_ack` and SHALL explicitly exclude promotion transaction, candidate signoff, and apply execution as the payload kind. The receipt SHALL keep three separate states: `renderer_ack`, `promotion_transaction`, and `candidate_signoff`. Emitting renderer ack SHALL NOT set promotion to DONE or candidate signoff to SIGNED.

#### Scenario: Renderer ack emission keeps promotion and signoff separate

- **GIVEN** a sealed S10 verdict
- **WHEN** S11 emits renderer ack
- **THEN** `state_separation.renderer_ack` SHALL be `EMITTED`
- **AND** `promotion_transaction` SHALL remain `NOT_STARTED`
- **AND** `candidate_signoff` SHALL remain `UNSIGNED`

#### Scenario: State collapse fails closed

- **GIVEN** an S11 receipt that sets `promotion_transaction=DONE` or `candidate_signoff=SIGNED` solely because renderer ack was generated
- **WHEN** the S11 validator runs
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_STATE_COLLAPSE`

#### Scenario: Downstream consumers are declared without execution

- **GIVEN** an S11 downstream envelope listing consumers such as B5 expansion, B6 promotion transaction, or operator lane
- **WHEN** the spine finishes S11
- **THEN** the envelope MAY be consumed by later packages
- **AND** the spine itself SHALL NOT execute B5 or B6 promotion

---

### Requirement: Missing, unknown, and duplicate inputs fail closed everywhere

Across S9, S9b, S10, and S11, missing required fields, unknown enum values, duplicate identities, and unequal same-subject joins SHALL fail closed. Silent drop, silent merge, or human override paths that convert those defects into PASS SHALL be forbidden.

#### Scenario: Package DONE claims from harness fail closed

- **GIVEN** any spine receipt that sets `b2_done`, `b3_done`, `b4_done`, `c6_acceptance`, `v_pass`, or `candidate_signed` to true from harness/fixture evidence alone
- **WHEN** claims validation runs
- **THEN** the process SHALL exit non-zero
- **AND** the failure code SHALL identify `E_PACKAGE_DONE_CLAIM`

#### Scenario: Full fixture chain can be green without evaluation success claims

- **GIVEN** a synthetic full chain S9 → S9b → S10 → S11 under `mode=fixture` with absent or synthetic new adapter
- **WHEN** the spine checker runs `--stage all --mode fixture`
- **THEN** the process MAY exit 0 for harness readiness
- **AND** residual readiness reporting SHALL still allow `missing_s8_adapter`, incomplete freeze/ceremony execution, and `no_real_three_arm_scores`
- **AND** reporting SHALL NOT claim S9/S10 package DONE, B7 freeze DONE, V1 RATIFIED ceremony complete, C6 acceptance, V-PASS, or operator-pass
