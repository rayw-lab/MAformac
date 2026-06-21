## Context

`define-lora-training` has been archived into `openspec/specs/lora-training/spec.md`. It defines the C5 LoRA training method, data readiness, masking stages, MLX scale terminology, C6 diff, replay fingerprints, parity, and the rule that validation loss is never enough for V-PASS.

PR5 is the first formal candidate execution on top of that contract. The approved inputs are:

- PR3 final-v3 natural-Chinese trainable data under `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3`.
- PR1 offset artifact digest `c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9`.
- PR2 verified repo training loop marker `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json`.
- PR2 clip and stock-equivalence evidence under `Reports/c5-pr2pr4pr5-20260621T235213/`.

The current code still has a known authority conflict: `C5MLXLoRAConfig.rank16Mainline()` renders `scale: 32`, while the P1-C grill first-cut source says MLX `scale` is not PEFT alpha and the first version should use approximately the MLX default `20`. PR5 resolves that conflict by making the first candidate use `scale=20` and moving `32` into explicit A/B work.

## Goals / Non-Goals

**Goals:**

- Create the PR5 candidate execution contract after `define-lora-training` archive.
- Train the first rank16 candidate with PR3 final-v3 data and PR2 verified repo loop, using `scale=20`.
- Block formal training when offset artifact status/digest, verified loop marker, clip evidence, or candidate data-quality gates are missing.
- Record candidate receipts that are replayable: source digests, environment, training curve, checkpoint selection, model/tokenizer/adapter digests, and contract digests.
- Run C6 base-vs-LoRA diff under one harness and split checkpoint selection from final release evaluation.
- Run held-out/OOD diagnostics designed to catch memorization, not just train-set fit.
- Compare dynamic adapter, fused bf16, and fused quantized/endpoint behavior by deltas and hard regressions.
- Record model-quality V-PASS and physical endpoint V-PASS separately.
- Require GPT Pro final audit before candidate signing.

**Non-Goals:**

- Do not reopen the archived `define-lora-training` change.
- Do not train on raw customer material or the 12k bug corpus.
- Do not use stock `mlx_lm.lora` for formal candidate training.
- Do not tune checkpoint selection on C6 release cases.
- Do not sign endpoint readiness from Mac-only or simulator evidence.
- Do not treat same-source Codex subagent audits as final candidate signoff.

## Decisions

### 1. PR5 depends on the archived lora-training spec

The new change modifies `lora-training` with PR5 candidate-run requirements. It must cite the archived main spec and archived change path, not the old active change directory.

Alternative rejected: keep editing `define-lora-training` after archive. That would break the dependency chain and make PR4 archive evidence stale.

### 2. First candidate uses `scale=20`

`scale=20` is the first candidate authority. Existing `scale=32` code and tests are changed to the first-candidate value, while `32` remains a later A/B option. The closeout must include `scale_authority_resolution` with the source reference and observed value.

Alternative rejected: keep `scale=32` because it is already in code. That repeats the exact failure mode the dispatch calls out: implementation defaults silently overriding the grill source.

### 3. Offset digest and verified repo loop are hard pre-training gates

Formal training may start only when the final data pack records `offset_fixture.status=pass` and the token artifact digest matches the approved final-v3 digest, or when a regenerated pack records a new same-path artifact and digest. The training loop marker must match the current repo loop source SHA and verification refs.

Alternative rejected: use existence of `mlx-train-command.txt` as authorization. Earlier PR2 evidence showed blocked prepare can still write command files before exiting.

### 4. Data-quality gates are preventive, not cosmetic

PR5 must enforce per-seed variant caps, diversity/near-duplicate checks, ambiguous duplicate blocking, and epoch-exposure reporting before candidate training. Distribution summaries alone are not sufficient because near-duplicate synthetic data can pass format and judge checks while still encouraging memorization.

Alternative rejected: rely on the final-v3 judge pass alone. Semantic pass proves label correctness, not diversity or non-memorization.

### 5. Checkpoint selection uses dev_selection; C6 release stays final-only

Candidate checkpoint selection uses `dev_selection` and C6 metric family. C6 release cases are opened for final candidate evaluation and every open is recorded. This avoids optimizing on the release set.

Alternative rejected: use C6 release metrics to pick checkpoints. That contaminates the release gate and makes later improvement claims weaker.

### 6. Candidate evaluation is multi-layer

PR5 records:

- C6 base-vs-LoRA diff under the same harness, prompt, parser, mock-state policy, and scoring pipeline.
- Replay fingerprints for model, tokenizer, adapter/checkpoint, prompt, tool output, and contract.
- Diagnostic axes: in-dist, heldout, and OOD with lineage/near-neighbor checks.
- Dynamic/fused/quantized parity by ToolCallExact delta, IrrelAcc delta, must-pass regression, parse failures, and negative false-call delta.
- Endpoint tokenizer byte parity.

Validation loss and training health remain secondary stop hints.

### 7. V-PASS is split and final audit is heterogeneous

Mac-side model-quality V-PASS may be reported separately if C6/parity gates pass. Physical endpoint V-PASS remains blocked without target device evidence. A final GPT Pro audit is mandatory before signing any candidate; Codex subagent audits remain implementation-level checks only.

## Risks / Trade-offs

- [Scale authority drift] Existing tests assert `scale=32` and will fail when corrected. Mitigation: update tests and receipt expectations to `scale=20`, and put `32` in A/B records only.
- [Offset artifact drift] Regenerating data may invalidate the approved digest. Mitigation: block unless the regenerated data reruns the same-path offset fixture and records a new digest.
- [Synthetic memorization] Natural Chinese judge pass can still create near duplicates. Mitigation: diversity, near-neighbor, lineage, and epoch-exposure gates.
- [Release-set contamination] Repeated C6 opens can become selection pressure. Mitigation: use `dev_selection` for checkpoint selection; final C6 opens are logged.
- [Dynamic-only false readiness] A dynamic adapter can pass while fused/quantized behavior regresses. Mitigation: three-way parity and delta checks.
- [Endpoint false readiness] Mac or simulator success can be mistaken for endpoint V-PASS. Mitigation: split model-quality and physical endpoint V-PASS.
- [Same-source audit bias] Codex subagents can miss shared framing errors. Mitigation: GPT Pro final audit before candidate signing.

## Migration Plan

1. Validate archive state: `define-lora-training` is archived and `openspec/specs/lora-training/spec.md` exists.
2. Apply PR5 gates in code and tests: scale authority, offset digest gate, verified loop gate, data-quality gate fields, and receipt fields.
3. Prepare candidate data from PR3 final-v3 and verify PR2 loop marker/clip evidence.
4. Run candidate training with repo loop clip enabled and source snapshots.
5. Run C6 base-vs-LoRA, diagnostics, replay fingerprints, parity, endpoint byte parity, and physical-device checks when available.
6. Run subagent audits per subphase and GPT Pro final audit before any candidate signing.

Rollback is conservative: leave generated candidate artifacts as Reports evidence, set candidate status to blocked/deferred, and keep the archived `lora-training` method spec unchanged.

## Open Questions

- Whether physical iPhone target evidence is available during this PR5 run. If not, endpoint V-PASS remains blocked while Mac model-quality reporting can continue.
- Whether C6/parity tooling already supports all replay fingerprint fields or needs small adapter code in this change.
