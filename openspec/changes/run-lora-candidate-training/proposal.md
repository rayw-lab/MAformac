> **Historical status note 2026-07-05**: this PR5 candidate-run change is prior evidence and not current formal-1800 launch authorization. Current formal-1800 run-auth was accepted, but host gate remained HOLD, no trainer pid existed, watchdog was not armed, formal remains evidence-run-only, and candidate remains unsigned.

## Why

`define-lora-training` is now archived as the method/data-readiness contract, but MAformac still has no signed LoRA candidate. PR5 must turn PR3 natural-Chinese trainable data plus the PR2 verified repo training loop into a candidate run without repeating prior false-green risks: `scale=32` silently overriding the grill source, offset artifacts drifting, C6 release sets being used for selection, dynamic-only behavior being mistaken for endpoint readiness, or same-source Codex audits signing the candidate.

## What Changes

- Run the first formal rank16 Qwen3-1.7B MLX LoRA candidate from the PR3 final-v3 trainable data and PR2 verified repo loop.
- Change the first candidate MLX LoRA `scale` authority to `20`, matching the P1-C grill first-cut source, with `32` and other values reserved for explicit A/B after the first candidate.
- Add a hard pre-training offset gate: PR5 may train only when the final-v3 `offset_fixture.status=pass` token artifact digest matches `c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9`, unless a regenerated data pack reruns and records a new same-path artifact.
- Add PR5 candidate data-quality gates for per-seed variant cap enforcement, near-duplicate/diversity checks, ambiguous duplicate blocking, and epoch-exposure reporting.
- Add candidate eval gates migrated from `define-lora-training`: C6 base-vs-LoRA diff, replay fingerprints, held-out/OOD diagnostics, dynamic-vs-fused-vs-quantized parity, endpoint tokenizer byte parity, and two-layer V-PASS separation.
- Require final candidate signing to cite same-source Codex audit reports plus GPT Pro heterogeneous final audit; same-source subagent audits alone are not sufficient to sign a candidate.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `lora-training`: adds the formal candidate-run and signoff requirements that depend on the archived training-method contract.

## Non-Goals

- Do not reopen or rewrite the archived `define-lora-training` change.
- Do not train on raw customer material, prohibited source text, real vehicle data, or any non-redacted corpus.
- Do not use the 12k bug corpus in this first candidate.
- Do not use stock `mlx_lm.lora` or an unverified repo loop for formal candidate training.
- Do not sign endpoint candidate V-PASS from Mac-only or simulator-only evidence.
- Do not use same-source Codex subagent audits as the final candidate signer.
- Do not replace rule fast paths, DemoGuard, schema checks, mock-state readback, or C6/C7 gates.

## Success Criteria

- `openspec validate run-lora-candidate-training --strict` and `openspec validate --all --strict` pass.
- The generated candidate training receipt records `scale=20`, PR2 verified training loop source SHA, clip-on metrics, nonfinite checks, environment, metrics/log pointers, and checkpoint-selection policy.
- PR5 refuses to train if the final-v3 offset artifact digest is missing or mismatched.
- C6 eval receipts link base and LoRA runs under the same harness, prompt, parser, mock-state policy, scoring pipeline, and replay fingerprints.
- The diagnostic report records in-dist, heldout, and OOD axes and blocks leakage claims.
- Dynamic adapter, fused bf16, and fused quantized/endpoint behavior are compared by ToolCallExact delta, IrrelAcc delta, must-pass regression, parse failures, and negative false-call delta.
- Model-quality V-PASS and physical endpoint V-PASS are recorded separately; missing physical iPhone evidence blocks endpoint V-PASS without blocking Mac-side model-quality reporting.
- GPT Pro final audit is recorded before any candidate is signed.

## Non-Automated Success Signals

- A reviewer can trace every PR5 candidate claim to archived `lora-training`, PR2/PR3 evidence, C6 receipts, parity receipts, and the audit index.
- The closeout clearly distinguishes a runnable development adapter from an endpoint-ready demonstration artifact.

## Impact

- Updates `Core/Training/C5LoRATraining.swift`, `Tools/C5TrainingCLI/main.swift`, and focused tests around scale authority, offset gating, candidate training receipts, and PR5 gate fields.
- Adds candidate-run Reports under the current PR2/PR4/PR5 run root, including training metrics, C6 eval receipts, parity receipts, audits, and closeout.
- Adds a delta spec under `openspec/changes/run-lora-candidate-training/specs/lora-training/spec.md`.
- Depends on archived `openspec/specs/lora-training/spec.md` and archived change `openspec/changes/archive/2026-06-21-define-lora-training/`.
