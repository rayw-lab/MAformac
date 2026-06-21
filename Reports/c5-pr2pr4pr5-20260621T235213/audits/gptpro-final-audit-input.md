# GPT Pro Final Audit Input - C5 PR2/PR4/PR5 Remediation

## Requested Verdict

Audit whether the PR2/PR4/PR5 wave is ready for an honest blocked closeout, not whether the LoRA candidate is ready to sign.

Allowed final verdicts:
- `PASS_FOR_BLOCKED_CLOSEOUT`: evidence supports closing this wave as blocked/partial with no candidate signoff.
- `FAIL`: evidence overclaims readiness, misses a required blocker, or has material receipt/task inconsistency.

The candidate MUST NOT be signed unless GPT Pro explicitly finds all hard gates passed. In this evidence pack, the expected honest outcome is blocked because C6 hard-failed.

## Project Context

MAformac is a pure on-device macOS/iOS demo assistant using Qwen3 small model + LoRA for a mock vehicle-control demo. It is not production vehicle control. Hard rules for this task:
- OpenSpec contracts are authority.
- Training health is not model-quality V-PASS.
- Mac/simulator evidence is not physical endpoint V-PASS.
- Same-source Codex subagent audits do not sign candidates.
- GPT Pro final audit is required before any candidate signing.

## Key Evidence Files

- Task ledger: `openspec/changes/run-lora-candidate-training/tasks.md`
- Candidate-run spec delta: `openspec/changes/run-lora-candidate-training/specs/lora-training/spec.md`
- Audit index: `Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md`
- 5b training receipt: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-training/c5-training-run-receipt.json`
- 5c C6 receipt: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/c6-eval-receipt.json`
- 5d parity/V-PASS receipt: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5d-parity-vpass/parity-vpass-receipt.json`
- 5c final Codex audit: `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr5-5c-c6-eval-r2.md`
- 5d Codex audit: `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr5-5d-parity-vpass-r1.md`

## Current Ledger State

Completed:
- PR2 repo-loop clip run, stock equivalence, source-state gate.
- PR4 truth table, tombstones, archive of `define-lora-training`.
- PR5 5a change chain.
- PR5 5b training preconditions, source gates, scale=20, clean data, training-health run.
- PR5 5c same-harness C6 base-vs-LoRA execution and replay fingerprints.
- PR5 5d two-layer V-PASS status recording as blocked.

Open/blocked:
- 3.3 remains open because semantic near-neighbor proof is not complete.
- 4.1 dynamic/fused/quantized parity remains open-blocked because C6 failed first.
- 4.2 endpoint tokenizer byte parity remains open-blocked because C6 failed and no target physical iOS device receipt exists.
- 4.5 GPT Pro final audit is pending until this audit is written.

## Candidate Training Facts

Training status:
- `status=train_health_pass`
- `candidate_signing_status=not_signed_c6_parity_vpass_gptpro_pending` before C6/5d receipts
- scale=20
- rank=16
- final adapter sha256: `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`
- optimizer updates=150
- clip enabled/applied recorded
- nonfinite_count=0

Important limitation:
- This is only training-health evidence. It does not imply model-quality V-PASS or endpoint readiness.

## C6 Hard-Fail Facts

5c C6 receipt:
- `verdict=C6_HARD_FAIL_BLOCKED`
- `candidate_signing_status=not_signed_c6_hard_fail_tool_surface_mismatch`
- `model_quality_vpass=blocked`
- `physical_endpoint_vpass=blocked_not_evaluated`

Metrics:
- Base hard_failure_count: 50
- LoRA hard_failure_count: 42
- Base IrrelAcc: 0.739
- LoRA IrrelAcc: 0.957
- Base positive expected tool hits: 25/34
- LoRA positive expected tool hits: 0/34
- Base average elapsed ms: about 575
- LoRA average elapsed ms: about 2033

Blocking diagnosis:
- Training outer tool names: `tool_call_frame`
- C6 expected tool names: `query_cabin_comfort`, `set_cabin_ac`, `set_cabin_ambient_light`, `set_cabin_fan`, `set_cabin_screen_brightness`, `set_cabin_window`
- Intersection: empty
- LoRA observed tool names: `tool_call`
- Tool-surface status: `fail_training_target_uses_tool_call_frame_but_c6_expects_set_cabin_tools`

Interpretation:
- LoRA improved some no-call behavior but collapsed vehicle-action positive tool exactness.
- Candidate is blocked before parity or endpoint V-PASS.

## Diagnostics Limitations

Recorded:
- all C6 release, heldout, vehicle-action-positive, OOD no-call, trap, coverage-ambiguous axes
- exact input overlap count: 0
- train parent overlap from prepare receipt: 0

Still residual:
- `near_neighbor_status=exact_input_no_overlap_only_not_semantic_near_neighbor_proof`
- Task 3.3 intentionally remains unchecked.

## Adapter Normalization Evidence

MLX Python adapter config used `num_layers=-1`; MLX Swift LoRAContainer requires non-negative suffix length. SpikeE3 evaluation normalized adapter config for eval only:
- original config sha256: `f025da20d5b9338356271183dfbf25e628274a68bf85bcd5a9e4bed520f8d592`
- normalized config sha256: `d230d0fb1f6c606bd402514bb83e8f1d7c7b660a5be8a5ed75e3cda26a6f503a`
- normalized weights are a symlink to original adapter weights
- adapter weights sha256: `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`

Codex r1 audit caught missing byte fingerprints; r2 verified the fix.

## 5d Parity/V-PASS Facts

5d receipt:
- `verdict=PARITY_VPASS_BLOCKED_BY_C6_HARD_FAIL`
- dynamic/fused/quantized parity: `blocked_not_run`
- endpoint tokenizer byte parity: `blocked_not_run`
- model-quality V-PASS: `blocked`
- physical endpoint V-PASS: `blocked`

Device probe:
- `xcrun xctrace list devices` observed only the Mac as a physical device.
- iPhone/iPad entries were simulator-only via `xcrun simctl`.
- Mac/simulator evidence is explicitly insufficient for physical endpoint V-PASS.

## Verification Already Run

- `openspec validate run-lora-candidate-training --strict`: pass
- `openspec validate --all --strict`: 9 passed, 0 failed
- `git diff --check`: pass
- `swift test`: 112 passed, 3 skipped, 0 failures

## Audit Questions

1. Does the evidence support `PASS_FOR_BLOCKED_CLOSEOUT`, or is there a material overclaim/inconsistency requiring `FAIL`?
2. Are tasks 3.3, 4.1, and 4.2 correctly left open-blocked rather than checked complete?
3. Is 4.3 correctly checked as "two-layer V-PASS status recorded as blocked", not as V-PASS passed?
4. Is there any candidate-signing overclaim?
5. Is same-source Codex audit being improperly substituted for GPT Pro? If not, this report itself should satisfy only the final audit artifact for blocked closeout, not candidate readiness.
6. Are the next required gates correctly identified: fix tool-surface mismatch, rerun C6, complete semantic near-neighbor proof, then parity/endpoint checks, then sign only if all pass?

Please output a concise markdown audit report with:
- Verdict
- Evidence Checked
- Findings by severity P0/P1/P2/P3
- Task Ledger Verdict
- Candidate Signing Verdict
- Required Next Gates
