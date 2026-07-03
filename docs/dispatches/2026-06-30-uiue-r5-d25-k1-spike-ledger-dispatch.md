---
artifact_kind: commander_dispatch
label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
d_range: D25
status: SEND_READY_CODEX_SUBAGENT_AUDIT_PASS
created_at: 2026-06-30
target_thread: 019f17cf-8ae2-70b2-9255-30e5ad5602d6
commander_receipt_target: commander_current_thread
execution_mode: executing_plans_four_gate_spike
proof_class_ceiling: docs_local + local_static + local_unit + local_integration + openspec_local + gitnexus_static + runtime_probe_if_explicitly_bounded
pre_send_audit: codex_subagent_read_only_dispatch_audit_outside_execution_budget
pre_send_audit_result: PASS_SEND_READY_P0_P1_P2_EMPTY
pre_send_audit_source_thread: 019f173c-e34f-75d1-a764-992a9280891d
skills_execution_contract: executing-plans + pre-mortem + bug-iceberg-teardown + oracle/local-official-docs + openspec + gitnexus
cloud_review_policy: no_cloud_merge_required_for_D25
---

# UIUE R5 D25 K1 Spike Ledger Four-Gate Supertrain Dispatch

## 0. Commander Preamble

Read this file first. Do not rely on chat prose alone.

Target execution thread: `019f17cf-8ae2-70b2-9255-30e5ad5602d6`.

Primary repo:

- main: `/Users/wanglei/workspace/MAformac`

Read-only provenance repo, only if needed for source citations:

- UIUE: `/Users/wanglei/workspace/MAformac-uiue`

D25 is one integrated four-gate spike-ledger task. It is not eight independent implementation projects and not a broad runtime train. Its job is to convert the eight K1 `spike_required` rows into bounded receipts with proof class, evidence, and promotion/no-promotion decisions.

This dispatch authorizes bounded local/static/unit/runtime-probe work needed to classify the K1 rows. It authorizes exact-path docs/test/spec/code edits only when a gate proves a minimal guard is required. It does not authorize merge, branch deletion, production runtime, C5/C6 training or acceptance, voice readiness, golden-run, UIUE merge, mobile/true-device/live proof, V/S/U-PASS, A-2 complete, or R5 complete claims.

The commander pre-send Codex subagent audit for this dispatch file is outside D25 execution scope. If the worker receives this dispatch without a commander note saying the pre-send audit passed, stop and ask the commander to provide the audit verdict.

## 0A. First Response Required

Return only this ack first, then start execution:

```yaml
ack:
  label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
  status: RECEIVED
  mode: executing_plans
  will_reprobe_live_truth: true
  will_preserve_dirty_split: true
  gates:
    - D25_GATE_1_EVENT_GATE_MATRIX
    - D25_GATE_2_RUNTIME_PERFORMANCE_GPU_MLX
    - D25_GATE_3_VOICE_PROOF_BOUNDARY
    - D25_GATE_4_MODEL_PARSER_PROOF_GOVERNANCE
  will_not_run:
    - C5_training
    - C6_acceptance
    - broad_runtime_backend
    - golden_run
    - voice_readiness
    - UIUE_merge
```

## 1. Operating Mode: Executing Plans

At task start, explicitly announce:

`I'm using the executing-plans skill to implement this D25 four-gate spike ledger.`

Then:

1. Load this dispatch as the written plan.
2. Review it critically once.
3. Create todos for Gate 0 and D25 Gate 1-4.
4. Execute continuously until all four gate receipts and final YAML are complete, or until a stop condition is reached.
5. Keep D25 as spike/falsification. Do not turn any row into implementation without the row receipt proving promotion is safe.

Risk-skill use is not a proof class. Use `pre-mortem`, `bug-iceberg-teardown`, local oracle/official docs, OpenSpec, and GitNexus as execution disciplines. Record their use in each gate receipt.

## 2. Live Truth Candidates To Re-Probe

These values were commander-observed while drafting. They are candidates only. Re-probe before editing and before final YAML.

| item | candidate truth |
|---|---|
| `origin/main` | `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6` |
| PR #7 | `MERGED`, merge commit `b7b901b32b22f2895464faa497234d3ae46dc7dd` |
| PR #6 | `MERGED`, merge commit `08032412b2ba8edb350259ccec8c70717ccb561d` |
| PR #8 | `MERGED`, merge commit `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6` |
| final cloud Verify | GitHub Actions run `28431421039`, `success`, head `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6` |
| GitHub-hosted macOS billing | not fixed; D24 used temporary self-hosted Actions proof, then cleaned it up |

Preferred D25 execution surface:

- Use a clean worktree or clean branch based on `origin/main`.
- If running in the shared `/Users/wanglei/workspace/MAformac` checkout, preserve all existing dirty/untracked files and stage exact paths only.
- If the current checkout is an old D24 branch or has unrelated dirty state that blocks clean D25 execution, create a clean local worktree from `origin/main` and record the path in the final YAML.

Before editing, run and record:

```bash
git -C /Users/wanglei/workspace/MAformac status --short --branch
git -C /Users/wanglei/workspace/MAformac fetch origin main
git -C /Users/wanglei/workspace/MAformac rev-parse origin/main
git -C /Users/wanglei/workspace/MAformac log --oneline --max-count=8 origin/main
gh -R rayw-lab/MAformac pr view 7 --json number,state,mergedAt,mergeCommit,headRefOid,url
gh -R rayw-lab/MAformac pr view 6 --json number,state,mergedAt,mergeCommit,headRefOid,url
gh -R rayw-lab/MAformac pr view 8 --json number,state,mergedAt,mergeCommit,headRefOid,url
gh -R rayw-lab/MAformac run view 28431421039 --json status,conclusion,headSha,url
```

If D24 is not merged in live cloud truth, stop with:

`blocked at Gate 0 after D24 truth reprobe; only missing post-D24 merged baseline`.

## 3. Authority And Reading Order

Read first:

1. main `CLAUDE.md`
2. main `docs/CURRENT.md`
3. main `docs/README.md`
4. main `docs/project/phase0/README.md`
5. main `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`
6. main `docs/project/phase0/r5-d23-shared-schema-checker-commander-verdict-2026-06-30.md`
7. main `docs/project/phase0/r5-d24-local-cloud-dual-repo-full-absorption-merge-plan-2026-06-30.md`
8. main `docs/project/phase0/r5-d24-route-control-pr-merge-closeout-2026-06-30.md`
9. main `openspec/changes/define-runtime-presentation-bridge/`
10. main `openspec/changes/define-runtime-adapter-execution/`
11. UIUE read-only K1 provenance anchors listed below.
12. If a clean `origin/main` worktree proves D24-absorbed copies exist, prefer those mainline copies only after verifying the paths with `test -e`.

Minimum K1 source files to inspect and cite.

Use these UIUE provenance files read-only unless the executor first creates a clean `origin/main` worktree and proves the same artifacts exist there. Do not assume the shared current checkout contains these paths, because it may still be on an old D24 branch with unrelated dirty state.

- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/candidate-map-private.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationConsumerMapping.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationConsumerMappingTests.swift`

Mainline route-control artifacts to cross-check:

- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/README.md`
- `/Users/wanglei/workspace/MAformac/docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`

## 4. Goal And Non-Goals

### Goal

Produce D25 K1 spike-ledger receipts for:

- `C082`: `cardsDidStartChanging` event-gate question.
- `C083`: `readbackReady` event-gate question.
- `C096`: shader/GPU budget versus MLX runtime contention.
- `C117`: premium Mandarin voice preflight/fallback proof boundary.
- `C182`: unified event-kind matrix for `cards_did_start_changing`, `readback_ready`, `tts_start`, and `tts_end`.
- `C197`: C3 parser fallback/repair in runtime adapter error-feedback strategy.
- `C207`: endpoint decode parity statistics boundary.
- `C208`: Mac dev Outlines/XGrammar fixture `dev_only` no-promotion guard.

Each row must exit as `PASS`, `PARTIAL`, or `BLOCKED`, with proof class and one of:

- `promote`
- `keep_spike_only`
- `future_lane`
- `blocked`

### Non-Goals

- No C5 data generation, LoRA training, train-health, candidate promotion, or model signing.
- No C6 acceptance/comparison execution.
- No broad iOS/macOS runtime backend implementation.
- No demo-golden-run execution or golden ID freeze.
- No voice-ready claim from voiceState, UI fixture, simulator, or local TTS enumeration alone.
- No UIUE merge.
- No mobile, true-device, live API, endpoint-ready, V-PASS, S-PASS, U-PASS, A-2 complete, or R5 complete claim.
- No D24 merge replay, branch deletion, or GitHub check bypass.

## 5. Dirty Tree, Worktree, And Staging Rules

- No `git add .`.
- Stage exact paths only.
- Preserve unrelated dirty files: `AGENTS.md`, `CLAUDE.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`, D24 dispatch/verdict drafts, and any user/other-agent work.
- Do not revert, clean, overwrite, or format unrelated files.
- Prefer creating a clean D25 worktree from `origin/main` if the shared checkout state is stale or noisy.
- If code/test edits are required, run GitNexus impact before symbol edits and `detect_changes` before commit.
- If D25 remains docs-only, record `gitnexus: not_code_change` and still run `git diff --check`.

If commits are made, required sequence:

```bash
git status --short
git diff --name-only
git add -- <exact paths>
git diff --cached --name-only
git diff --cached --check
```

No push is required for D25 unless the commander/user explicitly asks later. If the worker chooses to push for a review PR, stop and ask because this dispatch does not authorize new PRs or cloud merge.

## 6. Required Harness In Every Gate Receipt

Every gate receipt must include:

- `skills_ledger`: executing-plans, pre-mortem, bug-iceberg-teardown, OpenSpec, GitNexus, local/offical-doc oracle as applicable.
- `lessons_learned`: one D20-D24/D25 lesson.
- `metacognitive_check`: one unsafe assumption avoided.
- `pre_mortem`: main failure mode for the gate.
- `iceberg_teardown`: visible symptom vs deeper class.
- `local_search`: exact commands/files searched.
- `external_or_official_truth`: only when current platform/API behavior matters; prefer official docs or live CLI/API output.
- `goal_drift_check`: confirm no C5/C6/runtime backend/voice/golden/UIUE merge drift.
- `authority_check`: which repo docs/specs governed the gate.
- `claim_vs_proof_check`: every claim mapped to proof class.
- `boundary_check`: nonclaims/no-touch.
- `self_question`: "If this were wrong, what file/line/command would prove it?"
- `promotion_decision`: row-level promotion/no-promotion.

## 7. D25 Four-Gate Topology

Strict serial gates. Do not start a later gate until the current gate has a receipt.

### D25_GATE_1_EVENT_GATE_MATRIX

Rows: `C082`, `C083`, `C182`.

User stories:

- `C082`: As a UI presentation consumer, I need to know whether `cardsDidStartChanging` is an independent event gate so UIUE does not infer animation start from card diffs.
- `C083`: As a readback/TTS consumer, I need to know whether `readbackReady` is an independent gate so UI/TTS never reads stale or incomplete readbacks.
- `C182`: As a bridge contract owner, I need one event-kind matrix for `cards_did_start_changing`, `readback_ready`, `tts_start`, and `tts_end` so C082/C083/TTS lifecycle do not create a third mapper.

Required work:

1. Inspect current Runtime -> Presentation contract, payload fixtures, result/snapshot/event naming, and UIUE mapping evidence.
2. Determine whether each state is already derivable from terminal snapshots/readbacks/voice state, or requires a typed event/snapshot field.
3. Produce one unified event-gate matrix but one receipt row per K1 ID.
4. If a minimal spec/test/doc guard is required, edit only the exact main-owned path and validate.

Writable paths, only if needed:

- `docs/project/phase0/r5-d25-k1-event-gate-matrix-2026-06-30.md`
- `openspec/changes/define-runtime-presentation-bridge/`
- `Tests/MAformacCoreTests/`
- `Core/Presentation/`

Validation:

```bash
openspec validate define-runtime-presentation-bridge --strict
swift test --filter 'RuntimePresentation|Presentation'
git diff --check
```

If no code/spec edit is required, still write the gate receipt and run `git diff --check` plus relevant read-only grep/static checks.

### D25_GATE_2_RUNTIME_PERFORMANCE_GPU_MLX

Row: `C096`.

User story:

- As a现场 demo operator, I need to know whether shader/GPU effects contend with MLX runtime enough to damage perceived responsiveness.

Required work:

1. Identify current presentation effects and runtime/MLX execution boundaries from repo evidence.
2. Decide whether D25 can run a bounded local runtime/perf probe safely, or whether current evidence only supports a future perf lane.
3. Classify C096 as R5 blocker, guarded non-blocker, future perf lane, or blocked for missing runtime data.
4. Do not fabricate numeric perf claims. Any number must come from a command, profile, or documented source.

Writable paths, only if needed:

- `docs/project/phase0/r5-d25-k1-runtime-performance-gpu-mlx-2026-06-30.md`
- optional local test/probe docs under `docs/project/phase0/`

Validation:

```bash
git diff --check
swift test --filter 'RuntimePresentation|DemoRuntime|C3'
```

If a real runtime probe is run, record hardware, command, captured_at, and proof class `runtime_probe`. Runtime probe still does not equal mobile, true-device, live API, or V-PASS.

### D25_GATE_3_VOICE_PROOF_BOUNDARY

Row: `C117`.

User story:

- As a现场 demo operator, I need premium Mandarin voice preflight and fallback boundaries so an unavailable high-quality voice is not reported as voice-ready.

Required work:

1. Inspect current voice/orb/proof-class docs and any voiceState usage.
2. Decide whether D25 only records a future voice lane boundary or can add a minimal no-promotion guard.
3. If probing local voice availability, record exact command/API and platform; do not claim true-device or product voice readiness.
4. Preserve the rule: UI `voiceState`, simulator, fixture, or local TTS enumeration is not true TTS/ASR readiness proof.

Writable paths, only if needed:

- `docs/project/phase0/r5-d25-k1-voice-proof-boundary-2026-06-30.md`
- `openspec/changes/define-demo-golden-run-and-voice/` only if a no-claim task note is missing and a minimal note is required.

Validation:

```bash
openspec validate define-demo-golden-run-and-voice --strict
git diff --check
```

### D25_GATE_4_MODEL_PARSER_PROOF_GOVERNANCE

Rows: `C197`, `C207`, `C208`.

User stories:

- `C197`: As a runtime adapter owner, I need to know whether C3 parser fallback/repair belongs in the runtime adapter error-feedback strategy so repair is not displayed as generic unsupported or crash.
- `C207`: As a C6/model evaluator, I need endpoint decode parity stats for `toolCall`, content JSON, parser repair, and false tool calls so aggregate scores do not hide model failure modes.
- `C208`: As a proof-governance owner, I need Mac dev Outlines/XGrammar fixtures marked `dev_only` so they cannot be cited as iOS/runtime proof.

Required work:

1. Inspect current C3/runtime outcome taxonomy, parser/decode error handling, C6 bench proof boundaries, and proof-class/fixture wording.
2. For `C197`, classify whether current runtime adapter taxonomy is sufficient, needs a minimal guard, or belongs to future runtime/model lane.
3. For `C207`, decide whether D25 records only a future C6 metric requirement or adds a no-claim guard.
4. For `C208`, verify whether dev-only grammar fixtures are already prevented from becoming iOS/runtime proof. Add a minimal docs/test guard only if missing.
5. Produce one governance receipt plus row-level decisions.

Writable paths, only if needed:

- `docs/project/phase0/r5-d25-k1-model-parser-proof-governance-2026-06-30.md`
- `openspec/changes/rebuild-c6-four-layer-bench/`
- `openspec/changes/define-runtime-adapter-execution/`
- `Tests/` only for minimal proof-class/no-promotion tests.

Validation:

```bash
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate define-runtime-adapter-execution --strict
swift test --filter 'C6|Runtime|Proof|Fixture'
git diff --check
```

## 8. D25 Final Summary Receipt

After Gate 4, create or update:

- `docs/project/phase0/r5-d25-k1-spike-ledger-summary-2026-06-30.md`

The summary must include:

- D24 post-merge baseline truth.
- The four D25 gate verdicts.
- One row-level table for all eight K1 rows.
- Any promoted rows, future-lane rows, blocked rows, or keep-spike-only rows.
- Whether R5 can proceed to proof-capped closeout candidate.
- Explicit nonclaims.
- Changed files and validation.

## 9. Required Validation

Minimum final validation:

```bash
openspec validate --all --strict
git diff --check
```

If Swift/source/test paths changed, also run targeted `swift test` filters from the touched gate and, if feasible, `make verify-ci`. If `make verify-ci` is not feasible, state why and list the narrower gates that passed.

Run GitNexus:

- Before editing Swift symbols: `impact`.
- Before commit/final closeout when code/test/config changed: `detect_changes`.
- For docs-only work: record `not_code_change` and do not invent GitNexus proof.

## 10. Final YAML Required

Return final YAML in the execution thread. If the worker can message commander directly, also send it back to commander. If not, set `commander_verdict_required: true`.

Required shape:

```yaml
label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
status: DONE_UNDER_PROOF_CAP | PARTIAL | BLOCKED
completed_at: "2026-06-30 Asia/Shanghai"
commander_verdict_required: true
execution_surface:
  repo: /Users/wanglei/workspace/MAformac
  worktree_or_branch: "<path/ref>"
  base: origin/main@771f48ad1bbaf02740f71da2cf90ada02fc6f6c6
d24_baseline:
  pr7: MERGED
  pr6: MERGED
  pr8: MERGED
  final_verify: SUCCESS
gates:
  D25_GATE_1_EVENT_GATE_MATRIX:
    status: DONE | PARTIAL | BLOCKED
    rows: [C082, C083, C182]
    validation: []
  D25_GATE_2_RUNTIME_PERFORMANCE_GPU_MLX:
    status: DONE | PARTIAL | BLOCKED
    rows: [C096]
    validation: []
  D25_GATE_3_VOICE_PROOF_BOUNDARY:
    status: DONE | PARTIAL | BLOCKED
    rows: [C117]
    validation: []
  D25_GATE_4_MODEL_PARSER_PROOF_GOVERNANCE:
    status: DONE | PARTIAL | BLOCKED
    rows: [C197, C207, C208]
    validation: []
row_verdicts:
  - row_id: C082
    cluster: event_gate_matrix
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
  - row_id: C083
    cluster: event_gate_matrix
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
  - row_id: C096
    cluster: runtime_performance_gpu_mlx
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
  - row_id: C117
    cluster: voice_proof_boundary
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
  - row_id: C182
    cluster: event_gate_matrix
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
  - row_id: C197
    cluster: model_parser_proof_governance
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
  - row_id: C207
    cluster: model_parser_proof_governance
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
  - row_id: C208
    cluster: model_parser_proof_governance
    status: PASS | PARTIAL | BLOCKED
    proof_class: docs_local | local_static | local_unit | runtime_probe
    promotion_decision: promote | keep_spike_only | future_lane | blocked
    evidence: []
proof_class:
  achieved: []
  not_achieved:
    - runtime_ready
    - mobile
    - true_device
    - live_api
    - V_PASS
    - S_PASS
    - U_PASS
    - R5_complete
changed_files: []
validation: []
harness:
  skills_ledger: []
  lessons_learned: []
  premortem: []
  iceberg_teardown: []
  goal_drift_check: ""
  authority_check: ""
  claim_vs_proof_check: ""
  boundary_check: ""
dirty_split:
  preserved_unowned: []
next_route:
  if_no_P0_P1: R5 proof-capped closeout candidate, then separate child plans for C5/C6/runtime/golden-voice-UIUE
  if_P0_P1: fix_or_keep_blocked_before_R5_closeout
nonclaims:
  - no runtime_ready
  - no mobile
  - no true_device
  - no live_api
  - no C5_training
  - no C6_acceptance
  - no golden_run
  - no UIUE_merge
  - no V_PASS
  - no R5_complete
```

## 11. Stop Conditions

Stop as `BLOCKED` or `PARTIAL` if:

- D24 merged baseline cannot be re-probed.
- The execution surface cannot be made clean enough to avoid unrelated dirty writes.
- Any K1 row requires a product/runtime/model decision outside D25.
- A gate needs C5/C6/voice/golden/UIUE merge work to continue.
- A validation failure cannot be fixed inside the gate without expanding scope.
- GitNexus reports HIGH/CRITICAL on production symbols and no user/commander approval exists.
- Any artifact would need to claim runtime-ready, mobile, true-device, live, V/S/U-PASS, A-2 complete, R5 complete, voice-ready, model-ready, golden-ready, or endpoint-ready.

Use this blocker format:

`blocked at D25_GATE_N after attempts A/B/C; only missing X`

## 12. Pre-Send Dispatch Audit Requirement

Before commander sends this dispatch:

1. Run `git diff --check`.
2. Spawn one read-only Codex subagent reviewer.
3. Ask it to audit dispatch completeness, label uniqueness, target thread, Gate 1-4 scope, D22/D23/D24 harness inheritance, dirty-tree rules, proof caps, final YAML shape, and send-readiness.
4. If it returns P0/P1/send-blocking findings, fix this dispatch and rerun the pre-send audit.
5. Send to `019f17cf-8ae2-70b2-9255-30e5ad5602d6` only after PASS/send-ready.

## 13. Source Anchors

Primary K1 anchors:

- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`: K1 table rows `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208`.
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md`: final `spike_required` route and scores.
- `/Users/wanglei/workspace/MAformac/docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`: Post-D24 bird's-eye route, D25 user stories, and receipt contract.
- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`: current D25 route board.
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/README.md`: Phase 0 D20-D24/D25 index.
