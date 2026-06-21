# C5 LoRA Training Apply Closeout

receipt_version: c5-closeout.v1
generated_at: 2026-06-21T14:22:00+08:00
status: PARTIAL_T_PASS_NOT_CANDIDATE

## Verdict

- Training chain T-PASS: PASS with instability. r9 600-iter MLX smoke exited 0, no NaN/Inf, no OOM/abort, peak memory 12.28 GB, trained tokens 193028.
- Model quality V-PASS (C6 Mac): BLOCKED. C6 base-vs-LoRA diff was not run, and Q13/Q14/Q15 formal data gates remain blocked.
- Endpoint candidate V-PASS (device): BLOCKED. `xcrun devicectl list devices` returned `No devices found`; simulator output is not a V-PASS substitute.
- Candidate signing/parity: BLOCKED. Dynamic adapter vs fused bf16 vs fused quantized 4-bit endpoint parity was not run.

## Source Refs

- Dispatch readback: `/Users/wanglei/workspace/raw/05-Projects/MAformac/dispatches/2026-06-21-c5-lora-training-apply-dispatch.md:5` marks B1/B2 non-autonomous blockers.
- B1 source: dispatch `:69-73` requires assistant `\n\n` prefix plus offset correctness fixture, not render diff only.
- B2 source: dispatch `:86-90` requires `dev_selection` as a sixth data-gate bucket before train/eval.
- V-PASS split: dispatch `:92-95` separates model quality V-PASS from endpoint candidate V-PASS.
- Closeout contract: dispatch `:114-116` requires `source_refs`, `discovery_findings`, `frame_surfaced`, `physical_fields`, `failure_receipt`, and real verification commands.
- Project constraints: `CLAUDE.md:15-17`, `CLAUDE.md:67-73`, `CLAUDE.md:87-88`, and `CLAUDE.md:124-126` keep this offline, Qwen3-1.7B + LoRA, mock-only, raw read-only, and route-tier aware.
- Live data-gate spec: `openspec/changes/define-lora-data-gate/specs/lora-data-gate/spec.md:4` now permits `dev_selection`; `:72-88` requires redaction/masking/receipt fields.
- Live training spec: `openspec/changes/define-lora-training/specs/lora-training/spec.md:19-37`, `:113-155` require masking-stage evidence, diagnostics, C6 diff, and no V-PASS without parity.

## Implemented Artifacts

- Training implementation: `Core/Training/C5LoRATraining.swift`
- Training CLI: `Tools/C5TrainingCLI/main.swift`
- Data-gate split update: `Core/Bench/C5DataGate.swift`, `Tools/C5DataGateCLI/main.swift`
- Tests: `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`, `Tests/MAformacCoreTests/C5DataGateTests.swift`
- Latest dry-run dataset/config receipt: `Reports/c5-lora-training-20260621T1245-r10/c5-training-receipt.json`
- Latest data-gate rerun receipt: `Reports/c5-lora-training-20260621T1245-r10/data-gate-rerun/c5-data-gate-receipt.json`
- Runtime smoke receipt: `Reports/c5-lora-training-20260621T1245-r9/c5-smoke-receipt.json`
- Hermes audits: `Reports/c5-lora-training-20260621T1245-r9/audits/hermes-step2abc-initial-audit.md`, `Reports/c5-lora-training-20260621T1245-r9/audits/hermes-step2abc-rerun-audit.md`, `Reports/c5-lora-training-20260621T1245-r10/audits/hermes-closeout-audit.md`

## Discovery Findings

- B1 data prefix alone was not enough for stock MLX correctness. The stock tokenizer default still emitted a `<think>` prefix path; the selected implementation creates a patched training tokenizer where missing `enable_thinking` behaves as false, then verifies trained span equality.
- The r9 600-step loss was not sustained divergence. It spiked around iter 70-100, then stabilized near 4.7 by iter 600.
- r9 scheduler was not actually consumed by MLX and printed constant `2.000e-04`; r10 config now uses MLX's real `lr_schedule` object schema. The r10 3-iter preflight printed LR `8.333e-06`, proving schedule wiring.
- Deterministic semantic protocol data is useful for local format/masking/data-gate dry run, but it does not satisfy Q13 multi-source generation, Q14 cross-vendor semantic judge, or Q15 candidate semantic reassignment.
- `dev_selection` must not be treated as protected release/gold data for overlap, and must not be train-eligible.

## Frame Surfaced

- `trainable_v0` and `masking_complete_v1` are trainability/data-format stages, not candidate readiness.
- Validation loss and smoke success are train-health signals only. They cannot produce model V-PASS without C6 base-vs-LoRA diff and artifact fingerprints.
- Simulator availability does not count for endpoint V-PASS. Device V-PASS requires a connected physical device.
- `exec_tier` remains separate metadata; `route_tier` is derived from normalized FC fuzzy/free flags.

## Physical Fields

- `devicectl`: `No devices found.`
- `xctrace`: MacBook Pro plus iOS/watch simulators only.
- Smoke adapter path: `Reports/c5-lora-training-20260621T1245-r9/adapters-smoke-600/adapters.safetensors`
- Smoke adapter sha256: `8a77b00b5c41ebf02dd6cacf0b71eba06960d98f0ae33a9f687d4c923bb6be06`
- r10 config sha256: `fa7faee5b4c93a851a77010893d6065d09eb5e7bcdf60e8672c0c14c4931cf9a`
- r10 receipt sha256: `40bc5a438c315de2a91bcddf14d90125f71d01fba16b374fa167e8cf06e7ad4c`
- r10 data-gate receipt sha256: `1b14b56be192822b8b98bda3b88b16804437f21751dcb7fb8aa674713dd669aa`

## Data And Masking

- r10 status: `step2_dry_run_ready`
- Rows: 4956 total, 4556 train-eligible, 400 `dev_selection`
- Route tiers: `fc_l2=2845`, `fc_l3=948`, `rule_l1=307`
- Rehearsal ratio: 0.074878
- No-call counterfactuals: 456, refusal ratio 0.100088, hard cap 0.20
- Prompt distractor count: 9912
- Masking coverage: `train_on_turn=true`, `function_name=true`, `argument_name=true`, `argument_value=true`
- Sample masking stage: `masking_complete_v1`
- Receipt masking stage counts: `masking_complete_v1=4956`
- Offset fixture: `pass`; trained span equals ToolCall after the assistant `\n\n` prefix.

## Audit Receipt

- Step2abc rerun Hermes audit: `PASS_WITH_FINDINGS`; remaining Q13/Q14/Q15 blockers correctly kept as blocked.
- Closeout Hermes audit: `PASS_WITH_FINDINGS`; no blocking findings. NF2 about masking-stage auditability was fixed by adding `masking_stage_counts` to the machine-readable training receipt.

## Gates

- Data gate: PASS. `must_not_train_violations=0`, `train_parent_semantic_overlap=0`, `quarantine=0`.
- Generator: BLOCKED for formal C5. `dry_run_only`; cloud multi-source generator not run.
- Validator: Layer 1 PASS; Layer 2 BLOCKED because cross-vendor semantic judge not run.
- Lineage: BLOCKED because candidate semantic reassignment was not run.
- Generalization diagnostic: `blocked_missing`; in-dist, heldout, OOD, and gap axes are explicit `null`, leakage/parent overlap are 0.
- Fuse parity: FAIL placeholder, because quantized endpoint IrrelAcc/parity were not run and must not be inferred.

## Smoke Metrics

- r9 smoke status: `t_pass_runtime_smoke_with_instability`
- Exit code: 0
- Loss trend: `early_spike_then_stabilized`
- Train loss: 5.711 -> 4.713
- Val loss: 4.473 -> 4.680
- Peak memory: 12.28 GB
- Tokens/sec at iter 600: 55.637
- Trained tokens: 193028
- Failure receipt: `formal_step2_not_complete_q13_q14_q15`, `smoke_adapter_not_candidate`, `lr_schedule_not_effective_in_r9_constant_2e-4`

## Failure Receipt

- `cloud_multi_source_generator_not_run`
- `multi_source_generator_diversity_missing`
- `cross_vendor_semantic_judge_not_run`
- `candidate_semantic_reassignment_not_run`
- `c6_base_vs_lora_diff_not_run`
- `replay_fingerprints_not_complete`
- `dynamic_fused_quantized_three_way_parity_not_run`
- `physical_device_not_connected`
- `endpoint_candidate_vpass_blocked`

## Residual Work

- Run formal Q13 generator orchestration with semantic-protocol-only prompts and per-sample generator metadata.
- Run Q14 cross-vendor semantic judge and fail closed on semantic mismatch.
- Run Q15 candidate semantic reassignment against heldout/C6/must-pass identities.
- Re-run MLX smoke/candidate with r10 scheduler config; r9 smoke proved runtime only and used the old constant-LR config.
- Run C6 base-vs-LoRA diff, replay fingerprints, dynamic/fused/quantized parity, then physical-device endpoint validation before any V-PASS claim.
