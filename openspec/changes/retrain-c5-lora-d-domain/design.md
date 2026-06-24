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

R-L05 and D2 are accepted architecture decisions. The gate runs at iter50, iter100, and iter150 over five end-to-end D-domain tool-call samples. The state machine is `continue | human_pause | early_stop | blocked`. This is a behavior-generation gate, not a val-loss gate; val loss alone cannot authorize continuation.

The gate must be infrastructure-enforced outside the training loop with exception/raise semantics. `human_pause` requires human review of 50 sample outputs; Codex self-review cannot release it. If any iter50 sample emits a generic-frame tool name, the candidate is `blocked` and must not proceed to iter100. Thresholds compare candidate behavior to the active base anchor: golden and demo fuzz behavior must not regress.

### AD-C5-005: Data recipe keeps negative/refusal classes and treats ratios as hypotheses

R-L07, D3, and D7 are accepted architecture decisions. Positive, unsupported, safety, and followup classes remain present. Ratio values are hypotheses until spike evidence exists. The accepted starting point is positive 20 / unsupported 6 / safety 3 / followup 2, roughly 15.4% negative samples. A ratio spike may scan 6.7% to 24%; the chosen value freezes only after finding the over-refusal bend. IrrelAcc below active base 0.789 marks the bend.

Negative samples must never be zero. Safety class must stay at or above 3%. Unsupported must include the D10 `already_state` subclass only as a distinct state-noop class, not as unsupported. Failure/error-recovery uses a minimal seed only: no HA-style three-turn recovery chain, factor <= 2, <= 50 rows in the receipt, and single-turn parser-failure to natural Chinese clarification samples. Failure turns must use the loss-mask kernel with `train_on_turn=false` so the model does not learn to generate bad calls and then recover.

### AD-C5-006: Gate integrity is sign-or-block

R-L11 is an architecture decision. First-hand artifacts, not metadata claims, decide pass status. Grader failure leaves the candidate `UNSIGNED/BLOCKED`.

D3 ratio spike, D6 general Chinese mix, and D7 failure minimal seed must run on the same LoRA candidate ID. D2 behavior gate, D3 spike, D6 regression, and D7 minimal-seed receipt remain `UNSIGNED` until physical evidence exists. A Codex/Claude statement, metadata flag, or checklist tick is not pass evidence.

### AD-C5-007: Human review is required for high-stakes route decisions

R-L17 is an architecture decision. Deframing means changing the review frame, not merely adding more same-frame agents. Codex/Claude same-vendor review is pre-check only and cannot certify the gate.

R-L17 pass requires three review lanes: the human owner participates in high-stakes signoff, at least one heterogeneous judge outside the Claude-family performs an independent deframing audit, and same-vendor Codex/Claude checks remain labeled pre-check. It does not require majority vote across many vendors, a second paid human reviewer, or an LLM-judge-over-LLM-judge loop.

The seven non-delegable evidence points are R1 first-50 sample read, R2 loss-mask print review, R3 train-eval template byte diff, R4 refusal/already_state sample comparison to home-llm refusal evidence, R5 top-failing C6 case drilldown, R6 generated utterance drift review, and R7 final route decision. Each point must produce a file under `docs/project/phase0/r-l17-human-review-evidence/`; prose-only "reviewed" claims are not pass evidence.

### AD-C5-008: Train health is not model quality

`train_health`, loss health, and training receipts do not imply `model_quality`, `lora_candidate`, `endpoint_candidate`, V-PASS, or demo readiness. A candidate remains `UNSIGNED/BLOCKED` until C6 model-quality gates and required reviews pass.

### AD-C5-009: `already_state` is distinct from unsupported and safety refusal

D10 is an accepted architecture decision. `already_state` / state-noop is an independent fifth state class, peer to unsupported, safety, success, and clarify. It is not unsupported because the device exists, and it is not safety refusal because no ASIL-style risk policy is being invoked.

Default owner is C3 plus the readback renderer. The training set may include natural-language answer templates such as "空调已经是关闭的了", but it must not train the model to decide state truth unless C6 evidence proves the base model has natural-language `already_state` false-negative rate above 20%. Readback templates must distinguish defaulted scope, explicit scope, and `already_state` scope origin.

### AD-C5-010: General Chinese mix is a regression-protection hypothesis

D6 is an accepted architecture decision. Start with 10-15% general Chinese mix inside the broader 5-25% hypothesis range. The regression base is raw Qwen3-1.7B, not another LoRA candidate. Candidate degradation greater than 5% on C-Eval/CMMLU or an equivalent Chinese zero-shot regression suite leaves the candidate `UNSIGNED`.

At least one non-tool-call task must be included to prove the model does not route every ordinary Chinese instruction into a tool call. Do not add English MMLU, knowledge-cutoff fact checking, or specialized Chinese domains such as medical/legal content to this demo gate.

### AD-C5-DS-001: Default-scope carrier blocks C5 data generation and retrain

`retrain-c5-lora-d-domain` SHALL depend on `define-demo-default-scope` for omitted-scope target rendering, C2-derived scope candidates, and scope-origin readback boundaries. C5 targets for omitted-scope utterances SHALL NOT invent `position=全车`, SHALL NOT hardcode a separate scope candidate list, and SHALL NOT redefine default-scope semantics inside this change.

## User Decision Gate

D1-D10 are accepted in `docs/project/phase0/phase0-d1-d10-user-decision-record.md`. This removes the pending user-decision gate, but this change remains non-executable until OpenSpec propose acceptance, R-L17 handling, and physical evidence gates are satisfied.

## Non-Goals

- No LoRA training run.
- No D-domain base recalibration run.
- No real model-quality evaluation.
- No endpoint-ready claim.
- No demo-golden-run execution.
- No voice work.
- No UIUE merge.
