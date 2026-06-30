# R5 D25 K1 Spike Ledger Summary

label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
status: DONE_UNDER_PROOF_CAP
created_at: 2026-06-30 Asia/Shanghai
base: origin/main@771f48ad1bbaf02740f71da2cf90ada02fc6f6c6
worktree: /Users/wanglei/workspace/.d25-worktrees/k1-spike-ledger

## D24 Baseline Truth

Live reprobe passed before D25 execution:

- PR #7: MERGED, merge commit `b7b901b32b22f2895464faa497234d3ae46dc7dd`
- PR #6: MERGED, merge commit `08032412b2ba8edb350259ccec8c70717ccb561d`
- PR #8: MERGED, merge commit `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`
- `origin/main`: `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`
- final Verify run `28431421039`: `success`, head `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`

The shared checkout had unrelated dirty/untracked files, so D25 used a clean worktree based on `origin/main`.

## Gate Verdicts

| gate | rows | status | receipt |
|---|---:|---|---|
| D25_GATE_1_EVENT_GATE_MATRIX | C082, C083, C182 | DONE | `docs/project/phase0/r5-d25-k1-event-gate-matrix-2026-06-30.md` |
| D25_GATE_2_RUNTIME_PERFORMANCE_GPU_MLX | C096 | DONE | `docs/project/phase0/r5-d25-k1-runtime-performance-gpu-mlx-2026-06-30.md` |
| D25_GATE_3_VOICE_PROOF_BOUNDARY | C117 | DONE | `docs/project/phase0/r5-d25-k1-voice-proof-boundary-2026-06-30.md` |
| D25_GATE_4_MODEL_PARSER_PROOF_GOVERNANCE | C197, C207, C208 | DONE | `docs/project/phase0/r5-d25-k1-model-parser-proof-governance-2026-06-30.md` |

## Row Ledger

| row_id | cluster | status | proof_class | promotion_decision | evidence |
|---|---|---|---|---|---|
| C082 | event_gate_matrix | PASS | docs_local + local_static | keep_spike_only | Existing event kind lacks `cards_did_start_changing`; row remains spike before implementation. |
| C083 | event_gate_matrix | PASS | docs_local + local_static | keep_spike_only | Existing snapshot has readbacks but no `readback_ready` event kind. |
| C096 | runtime_performance_gpu_mlx | PASS | docs_local + local_static | future_lane | Static shader/MLX guard exists; no bounded perf metrics. |
| C117 | voice_proof_boundary | PASS | docs_local + local_static + runtime_probe | future_lane | macOS voice inventory probe only; no true-device/premium/ASR/TTS readiness. |
| C182 | event_gate_matrix | PASS | docs_local + openspec_local | keep_spike_only | Four event names absent; future promotion should be one unified event matrix. |
| C197 | model_parser_proof_governance | PASS | docs_local + local_static | keep_spike_only | Parser repair/source trace exists; runtime adapter UX strategy remains future lane. |
| C207 | model_parser_proof_governance | PASS | docs_local + openspec_local | future_lane | Trace fields exist; endpoint parity stats not produced. |
| C208 | model_parser_proof_governance | PASS | docs_local + local_static | future_lane | No promotable grammar fixture found; future Mac dev grammar fixtures must be `dev_only`. |

## R5 Route

R5 can proceed only to a proof-capped closeout candidate if no commander/owner review finds P0/P1 in these receipts. This does not authorize C5/C6, runtime backend, golden-run, voice readiness, UIUE merge, mobile, true-device, live API, V/S/U-PASS, A-2 complete, or R5 complete.

## Changed Files

- `docs/project/phase0/r5-d25-k1-event-gate-matrix-2026-06-30.md`
- `docs/project/phase0/r5-d25-k1-runtime-performance-gpu-mlx-2026-06-30.md`
- `docs/project/phase0/r5-d25-k1-voice-proof-boundary-2026-06-30.md`
- `docs/project/phase0/r5-d25-k1-model-parser-proof-governance-2026-06-30.md`
- `docs/project/phase0/r5-d25-k1-spike-ledger-summary-2026-06-30.md`

## Validation Results

Passed:

- `openspec validate define-runtime-presentation-bridge --strict`: PASS
- `openspec validate define-demo-golden-run-and-voice --strict`: PASS
- `openspec validate rebuild-c6-four-layer-bench --strict`: PASS
- `openspec validate define-runtime-adapter-execution --strict`: PASS
- `openspec validate --all --strict`: PASS, 18 passed / 0 failed
- `git diff --cached --check`: PASS after exact-path staging of the five D25 docs files

Targeted Swift tests are not required unless code/test paths change. GitNexus is recorded as stale static aid and `not_code_change`; no symbol edits were made.

## Harness Summary

- skills_ledger: executing-plans, pre-mortem, bug-iceberg-teardown, OpenSpec, GitNexus, local/offical-doc oracle where applicable.
- lessons_learned: D20-D24 proof caps remain active; static/local/unit/mock proof cannot become runtime/mobile/true-device/live/V-PASS.
- premortem: The main failure mode was over-promoting spike rows into implementation/readiness claims.
- iceberg_teardown: Each row was an instance of proof-class/modal-boundary drift: event vs snapshot, UI effect vs MLX runtime, voice state vs true voice proof, parser metadata vs endpoint parity.
- goal_drift_check: no C5 training, no C6 acceptance, no broad runtime backend, no golden-run, no voice readiness, no UIUE merge.
- authority_check: `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `docs/project/phase0/README.md`, post-C6 roadmap, D23/D24 receipts, active OpenSpec changes, K1 matrix, and live repo truth.
- claim_vs_proof_check: achieved docs_local/local_static/openspec_local/runtime_probe only; runtime_ready/mobile/true_device/live_api/V_PASS/S_PASS/U_PASS/R5_complete not achieved.
- boundary_check: exact-path docs-only edits in clean worktree; shared checkout dirty split preserved.

## Nonclaims

- no runtime_ready
- no mobile
- no true_device
- no live_api
- no C5_training
- no C6_acceptance
- no golden_run
- no UIUE_merge
- no V_PASS
- no S_PASS
- no U_PASS
- no A_2_complete
- no R5_complete
