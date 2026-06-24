# Retrain C5 LoRA D-Domain Design

> DRAFT. This design records Architecture Decisions for the post-A2 C5 retrain proposal. It is not permission to generate data, run training, evaluate model quality, claim endpoint readiness, execute demo-golden-run, run voice, or merge UIUE.

## Scope

This change carries the C5 model-facing retrain contract after A2 D-domain surface migration. It depends on the D-domain surface produced by `migrate-d-domain-tool-surface` and on explicit user review of D1-D10 before apply.

## Architecture Decisions

### AD-C5-001: D-domain surface is a single-source train/eval/runtime contract

R-L02 is an architecture decision. Train, eval, and runtime surface digests must derive from the same A2 D-domain source. Generic `tool_call_frame` residue blocks retrain.

### AD-C5-002: Sample observability is computed from physical tools, not metadata

R-L09 is an architecture decision. No-call target presence must be computed from the actual sample `tools` field, and `label_conflict_flag` must be zero. Metadata claims are not sufficient evidence.

### AD-C5-003: Endpoint byte parity is blocked until endpoint render bytes exist

R-L03 is an architecture decision. Nil endpoint render cannot pass byte parity. Training render bytes, endpoint render bytes, think signature, and mask offset start token are separate evidence fields.

### AD-C5-004: Mid-training behavior gate is a four-state stop-the-train mechanism

R-L05 is an architecture decision. The state machine is `continue | human_pause | early_stop | blocked`; val loss alone cannot authorize continuation.

### AD-C5-005: Data recipe keeps negative/refusal classes and treats ratios as hypotheses

R-L07 is an architecture decision. Positive, unsupported, safety, and followup classes remain present. Ratio values, general Chinese mix, and failure/error-recovery seed inclusion are hypotheses until user decision and spike evidence.

### AD-C5-006: Gate integrity is sign-or-block

R-L11 is an architecture decision. First-hand artifacts, not metadata claims, decide pass status. Grader failure leaves the candidate `UNSIGNED/BLOCKED`.

### AD-C5-007: Human review is required for high-stakes route decisions

R-L17 is an architecture decision. Codex subagent review is same-vendor pre-check only; final high-stakes signoff requires an explicitly deframing heterogeneous review or a recorded user waiver.

### AD-C5-008: Train health is not model quality

`train_health`, loss health, and training receipts do not imply `model_quality`, `lora_candidate`, `endpoint_candidate`, V-PASS, or demo readiness. A candidate remains `UNSIGNED/BLOCKED` until C6 model-quality gates and required reviews pass.

### AD-C5-009: `already_state` is distinct from unsupported and safety refusal

D10 is an architecture decision candidate. `already_state` / state-noop handling must be classified separately from unsupported and safety refusal. Default owner is code/readback renderer unless C6 evidence proves model training is needed.

## User Decision Gate

D1-D10 must be visible in the Phase 0 decision record before apply. Until every row is accepted, modified, or explicitly deferred by the user, task rewrites in this change remain draft gate language rather than accepted gate policy.

## Non-Goals

- No LoRA training run.
- No D-domain base recalibration run.
- No real model-quality evaluation.
- No endpoint-ready claim.
- No demo-golden-run execution.
- No voice work.
- No UIUE merge.
