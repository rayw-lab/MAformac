# C5 Remediation PR4 Closeout

receipt_version: c5-remediation-pr4.v1
generated_at: 2026-06-22T00:55:00+08:00
status: PR4_ARCHIVED
supersedes: `Reports/c5-lora-training-20260621T1245-r10/c5-closeout.md`

## Verdict

- PR4 task-truth verdict: PASS for closeout repair. The live `define-lora-training` task list has 34 checkbox rows; 28 were already checked and 6 were open before this PR4 pass. PR4 then tombstoned those 6 rows without adding checkbox rows.
- 3.1 smoke-only verdict: COMPLETE by existing smoke-only chain evidence. The 600-iteration smoke run is valid only as train-health/smoke-chain evidence, not as candidate quality evidence.
- 3.5 masking verdict: KEEP CHECKED. Machine receipts prove all four masking coverage fields: `train_on_turn`, `function_name`, `argument_name`, and `argument_value`.
- 6.x / 7.4 verdict: DEFER TO PR5. C6 base-vs-LoRA diff, replay fingerprints, OOD probes, dynamic/fused/quantized parity, and V-PASS candidate evaluation are not completed in `define-lora-training`; they are tombstoned into `run-lora-candidate-training`.
- Candidate status: `PR5_BLOCKED`. No LoRA candidate is signed by this closeout.

## PR2 Anchors Consumed By PR4

- `pr2_clip_verdict`: PASS. `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2a-clip-enabled/evidence-summary.md` records 32 optimizer updates, clip enabled/applied 32/32, nonfinite 0, and final train/val loss.
- `pr2_equivalence_verdict`: PASS. `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-equivalence/evidence-summary.md` records stock semantics vs repo loop clip-off parity over 32 optimizer updates with adapter digest equality.
- `pr5_training_loop`: repo loop source is eligible for PR5 only through the verified marker `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json` and 2c source-state evidence. The JSON receipt stores source-state under `environment.training_loop_source_state`, not as a top-level field.

## Observed Evidence Registry

| artifact | expected status | observed evidence | verdict use |
| --- | --- | --- | --- |
| checkbox count | 34 rows | `grep -cE '^\\s*- \\[' openspec/changes/define-lora-training/tasks.md` => `34` | Baseline for 34-row truth table. |
| pre-tombstone open task count | 6 rows | 4a baseline `openspec instructions apply --change define-lora-training --json` => 28 complete, 6 remaining | Confirms PR4 migration scope before task edits. |
| post-tombstone task state | all done | 4b `openspec instructions apply --change define-lora-training --json` => 34 complete, 0 remaining | Confirms `define-lora-training` is mechanically archive-ready before the actual archive command. |
| 600-iter smoke-only receipt | `smoke_only_ready` | `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/c5-training-receipt.json` | Completes 3.1 only; no candidate claim. |
| 600-iter smoke log | final iter 600 exists | `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/mlx-smoke-600iter-lr1e4-adamw.log` | Shows val loss 0.605, train loss 0.596, LR 1.192e-05, tokens/sec 48.737, peak mem 12.939 GB. |
| trainable v0 receipt | `trainable_v0_ready` | `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/c5-training-receipt.json` | Proves masking coverage and c71ffb offset digest for PR1/PR3 closeout lineage. |
| source-state marker | `verified` | `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json` | Makes verified repo loop source machine-checkable for PR5. |
| source-state prepare probe | `trainable_v0_ready` | `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2c-source-state-prepare-probe/c5-training-receipt.json` | Confirms formal prepare can proceed when marker matches; source-state fields are nested under `environment`. |
| PR2 source-state summary | ready for audit | `Reports/c5-pr2pr4pr5-20260621T235213/pr2-2c-source-state/evidence-summary.md` | Human-readable receipt for marker sha, script sha, tests, and source-state gate. |
| PR2 audit index | 3 PR2 audits recorded | `Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md` | Confirms continuous audit loop through PR2. |

## Task Truth Table

| task | checkbox before PR4 | actual status | evidence ref | PR4 action |
| --- | --- | --- | --- | --- |
| 1.1 | checked | complete | `openspec/changes/define-lora-training/proposal.md`; parked change treated as superseded in apply path | Keep checked. |
| 1.2 | checked | complete | `openspec/changes/define-lora-data-gate/specs/lora-data-gate/spec.md`; C5 receipts include upstream gate fields | Keep checked. |
| 1.3 | checked | complete | `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/c5-training-receipt.json` | Keep checked. |
| 1.4 | checked | complete | `Tools/C5TrainingCLI/main.swift`; offline prepare/train command rendering | Keep checked. |
| 2.1 | checked | complete | `Core/Training/C5LoRATraining.swift`; generated `samples/c5-training-samples.jsonl` | Keep checked. |
| 2.2 | checked | complete | `Tests/MAformacCoreTests/C5LoRATrainingTests.swift` route-tier tests | Keep checked. |
| 2.3 | checked | complete | route-tier implementation and tests keep execution metadata separate | Keep checked. |
| 2.4 | checked | complete | PR3 final receipt route-tier counts and rehearsal ratio | Keep checked. |
| 3.1 | open | complete_smoke_only | `Reports/c5-lora-training-20260621T1609-smoke-only-lr1e4-adamw/c5-training-receipt.json`; `mlx-smoke-600iter-lr1e4-adamw.log` | Mark checked with train-health-only caveat. |
| 3.2 | checked | complete | `offset_fixture.status=pass`; c71ffb artifact in PR1/PR3 closeout | Keep checked. |
| 3.3 | checked | complete | distractor-only name augmentation in implementation/tests | Keep checked. |
| 3.4 | checked | complete | value strategy implementation/tests for slot, inverse-normalized, and percent values | Keep checked. |
| 3.5 | checked | complete | `masking_coverage` four-field truth in PR3 final receipt and 2c prepare probe | Keep checked; do not mechanically uncheck. |
| 3.6 | checked | complete | candidate parent semantic recomputation implementation/tests | Keep checked. |
| 4.1 | checked | complete | no-call paired counterfactual receipt fields and tests | Keep checked. |
| 4.2 | checked | complete | no-call schema fields in generated samples | Keep checked. |
| 4.3 | checked | complete | refusal ratio 0.100088 in PR3 final receipt, hard cap 0.20 | Keep checked. |
| 4.4 | checked | complete | prompt distractor count 9912 in PR3 final receipt | Keep checked. |
| 5.1 | checked | complete | MLX config uses `scale`; no PEFT `alpha` authority | Keep checked. |
| 5.2 | checked | complete | MLX config target modules exclude tied embeddings | Keep checked. |
| 5.3 | checked | complete | rank16, lr 1e-4 cosine, warmup, AdamW, batch/accum, bf16, sequence length in config receipt | Keep checked. |
| 5.4 | checked | complete | rank32/DoRA classified as secondary A/B, not first-candidate blocker | Keep checked. |
| 6.1 | open | deferred_to_PR5 | No C6 base-vs-LoRA diff has been run for candidate claim | Tombstone to `run-lora-candidate-training`. |
| 6.2 | open | deferred_to_PR5 | Replay fingerprints require candidate adapter/checkpoint after PR5 training | Tombstone to `run-lora-candidate-training`. |
| 6.3 | checked | complete_contract_only | diagnostic contract fields exist; live diagnostic still belongs to PR5 candidate eval | Keep checked, preserve no-generalization-claim caveat. |
| 6.4 | open | deferred_to_PR5 | OOD probes must be constructed after PR5 candidate/eval pack definition | Tombstone to `run-lora-candidate-training`. |
| 6.5 | open | deferred_to_PR5 | dynamic/fused/quantized parity cannot run before candidate adapter exists | Tombstone to `run-lora-candidate-training`. |
| 6.6 | checked | complete_contract_only | acceptance-stage gate prevents low-loss V-PASS | Keep checked. |
| 6.7 | checked | complete_contract_only | endpoint tokenizer byte-parity fields/gate exist; real endpoint validation still PR5/device | Keep checked. |
| 7.1 | checked | complete | `swift test` passed after PR2/PR4 code state: 107 tests, 3 skipped, 0 failures | Keep checked. |
| 7.2 | checked | complete | `openspec validate --all --strict` passed 8/8 after PR2 source-state wiring | Keep checked. |
| 7.3 | checked | complete | data-gate validator and prepare receipts show zero protected leakage and masking coverage | Keep checked. |
| 7.4 | open | deferred_to_PR5 | C6 base-vs-LoRA diff, fuse parity, and endpoint tokenizer byte parity not run as candidate eval | Tombstone to `run-lora-candidate-training`. |
| 7.5 | checked | complete_after_PR4_closeout | This closeout supersedes r10 closeout and distinguishes train health from V-PASS | Keep checked. |

## Scenario Gap Registry

| gap id | status | owning change | blocker if ignored |
| --- | --- | --- | --- |
| c6-base-vs-lora | deferred | `run-lora-candidate-training` | Any improvement claim becomes unsupported. |
| replay-fingerprints | deferred | `run-lora-candidate-training` | Candidate run cannot be replayed or audited. |
| heldout-ood-axes | deferred | `run-lora-candidate-training` | High score could be memorization rather than generalization. |
| three-way-parity | deferred | `run-lora-candidate-training` | Dynamic adapter behavior could diverge from fused/quantized endpoint behavior. |
| physical-device-vpass | blocked_until_device | `run-lora-candidate-training` | Mac/simulator result could be mis-signed as endpoint V-PASS. |
| gptpro-final-audit | deferred | final PR5 closeout | Same-source Codex audits are not enough to sign candidate. |

## Archive Gate

Before archiving `define-lora-training`, PR4 completed these mechanical checks:

- `grep -cE '^\\s*- \\[' openspec/changes/define-lora-training/tasks.md` remains `34`.
- `openspec instructions apply --change define-lora-training --json` reports `remaining=0` after tombstones are written.
- `openspec validate define-lora-training --strict` passes.
- `openspec validate --all --strict` passes.
- Final PR2/PR4/PR5 commit hygiene still must show the source-state marker and training loop script are not accidentally left out.

## Archive Receipt

- Command: `openspec archive define-lora-training --yes`
- Result: exit 0.
- CLI summary: `lora-training: create`; `+ 10 added`; `Specs updated successfully`; archived as `2026-06-21-define-lora-training`.
- Archived path: `openspec/changes/archive/2026-06-21-define-lora-training/`
- Main spec path: `openspec/specs/lora-training/spec.md`
- Active-change check: `openspec list --json` no longer lists `define-lora-training`.
- Post-archive validate: `openspec validate --all --strict` reports 8 passed, 0 failed, including `spec/lora-training`.
- Post-archive quality fix: main spec Purpose was rewritten from the OpenSpec placeholder to the C5 LoRA training purpose.

## Non-Claims

- This closeout does not claim PR5 candidate quality.
- This closeout does not claim C6 improvement, held-out generalization, fuse parity, endpoint byte parity, or physical-device V-PASS.
- This closeout does not replace the required GPT Pro final audit before candidate signing.
