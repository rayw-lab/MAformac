## Why

C6 base Qwen3-1.7B without LoRA is an honest hard-fail anchor for refusal/generalization, so C5 must define the LoRA training path before implementation can safely start. The agreed Q1-Q10 grill decisions now need a single OpenSpec source for how MAformac trains Qwen3-1.7B LoRA to map fuzzy vehicle-control utterances to single-hop ToolCallFrame outputs while preserving no-call behavior and deployment parity.

This change intentionally replaces the parked `define-lora-pipeline` as the active C5 proposal. It reuses the parked change's useful success criteria and bucket/separation ideas, but supersedes its flat-contract assumptions and PEFT-alpha training vocabulary with the current semantic protocol, normalized `fc_flags`, MLX `scale`, and data-gate contracts.

## What Changes

- Define the C5 LoRA training contract for single-turn vehicle-control training samples, including `route_tier`, `masking_stage`, value-type strategy, counterfactual refusal metadata, and train eligibility.
- Define the training progression from `smoke_only` to `trainable_v0` to `masking_complete_v1`, with `smoke_only` excluded from formal candidate claims.
- Define how C5 consumes the live `define-lora-data-gate` requirements for protected splits, parent-overlap blocking, shared Qwen tool-call format, redaction, and masking coverage receipts.
- Define the MLX LoRA configuration contract: Qwen3-1.7B, MLX `scale` vocabulary, explicit linear projection keys, rank16 mainline, and post-training checkpoint comparison.
- Define acceptance behavior for C5 candidates: C6 base-vs-LoRA diff, three-axis generalization diagnostics, replay fingerprints, and dynamic-adapter vs fused-model parity before V-PASS.
- Preserve the runtime boundary: the model produces only one ToolCallFrame or no-call/clarify per invocation; multi-turn followup training waits for C4 DialogueState and is not part of this change.

## Capabilities

### New Capabilities

- `lora-training`: governs C5 LoRA training data readiness, masking/augmentation semantics, MLX training configuration, refusal sampling, diagnostic evaluation, and candidate acceptance.

### Modified Capabilities

- None. This change consumes existing archived specs and the live `define-lora-data-gate` change, but does not modify those requirements.

## Impact

- New OpenSpec artifacts under `openspec/changes/define-lora-training/`.
- Future implementation will touch C5 data generation, training receipts, MLX config generation, C6 diff invocation, and fuse-parity evaluation. This propose step does not implement those changes.
- Downstream C6 evaluation remains the release gate; C5 records candidate readiness and diagnostics without redefining the C6 IrrelAcc threshold.
- Parked `openspec/changes/_parked/define-lora-pipeline/` should be marked superseded after this proposal is accepted, to avoid two competing C5 sources.

## Non-goals

- Do not rebuild `define-lora-data-gate`; this change consumes its current live requirements.
- Do not train a model, generate a training dataset, run MLX training, fuse weights, or create LoRA artifacts in this propose stage.
- Do not switch to Qwen3.5-2B, Qwen3-1.8B, cloud CUDA training, or any training backend other than local MLX for this C5 path.
- Do not train followup/multi-turn dialogue; followup remains `followup_after_c4` after C4 DialogueState fixes the context schema.
- Do not store raw source utterances, training JSONL, real vehicle data, or prohibited raw project material in the repo.
- Do not replace rule fast-paths, schema validation, DemoGuard, readback, or safety checks with LoRA behavior.

## Success Criteria

- `openspec validate define-lora-training --strict` and `openspec validate --all --strict` pass.
- The proposal, design, tasks, and `specs/lora-training/spec.md` artifacts exist and cover Q1-Q10 decisions from `docs/p1c-training-grill-decisions.md`.
- The spec states observable behavior only; implementation details remain in design/tasks.
- The design distinguishes `route_tier` from `exec_tier`, MLX `scale` from PEFT `alpha`, eval negative-sample composition from IrrelAcc threshold, and training refusal ratio from both.
- Git status after propose contains only `openspec/changes/define-lora-training/` additions.

## Non-automated Success Signals

- The C5 proposal is understandable to a future implementation agent without reopening the source xlsx files.
- A reviewer can trace each major design decision back to Q1-Q10 and to the live C5/C6 gate contracts.
