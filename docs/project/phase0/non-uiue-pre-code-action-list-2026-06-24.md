---
status: active_discussion_ledger
artifact_kind: non_uiue_pre_code_action_list
authority: discussion_route_control_not_contract
created_at: 2026-06-24
retire_trigger: "Retire after R-L17 deframing is closed, paper-to-skill-gate packets are absorbed into accepted OpenSpec carriers, and rebuild-c6/retrain-c5 execution dispatches supersede this checklist."
expires: "2026-07-15"
---

# Non-UIUE Pre-Code Action List

## Verdict

Next mainline is **unlock-layer first**, not a standalone `harden-contract-runtime-spine`.

Order:

1. Close or explicitly keep open the R-L17 deframing gate with evidence.
2. Absorb the 8 `Tools/paper-to-skill-gate` packets into C5/C6 routing ledgers.
3. Start `rebuild-c6-four-layer-bench` as the first execution mainline, because it is the trusted acceptance gate.
4. Start `retrain-c5-lora-d-domain` after C6 has a credible yardstick.

`harden-contract-runtime-spine` is downgraded to an embedded prerequisite inside `rebuild-c6`: `ScopedStateKey` / `TargetResolution` / `PlannedEffect` / `ContractReplayEngine` are C6 replay foundations, not a separate architecture-purity track.

## Why This Supersedes The Prior Ordering

The prior proposal to make `harden-contract-runtime-spine` the next standalone mainline overweights architecture cleanliness. That has a real risk of repeating the demo over-engineering pattern: moving a production-grade contract spine ahead of the demo's actual failure mode.

Three controlling reasons:

1. Demo success is C5 quality plus C6 hard gates, not abstract spine purity. PR #4 already closed the urgent `default_scope` fail-open class; standalone spine work has low direct contribution to the 5-minute demo.
2. The 0/34 failure showed that validation must become trustworthy before training. `rebuild-c6` must precede `retrain-c5`, otherwise the next LoRA candidate can fake-green again.
3. R-L17 is the C5/C6 master gate and is decision work, not code. It requires at least one heterogeneous non-Claude-family deframing judge plus human-owner R7 review before training/evaluation claims can move.

## Scope Boundaries

This checklist does not authorize:

- LoRA data generation or training.
- C6 acceptance runs.
- D-domain base recalibration.
- Demo golden-run or golden ID freeze.
- Voice / ASR / TTS readiness.
- UIUE work in the main worktree.
- V-PASS, S-PASS, U-PASS, endpoint-ready, or mobile/true-device claims.

UIUE continues in `/Users/wanglei/workspace/MAformac-uiue`. Mainline discussion and planning here should only touch UIUE where stable domain facts, state/C3-C6 contracts, readback metadata, or golden-run IDs intersect.

## Action Checklist Before Code

### 0. Q1 Dialectic Correction

R-L17 is split conceptually, but not as a new heavy schema:

- `route_deframing_verdict`: one-time human-signed route verdict that can unlock `rebuild-c6` construction only.
- `candidate_signoff_verdict`: later human-signed signoff required before C6 acceptance, C5 candidate promotion, golden-run, or readiness claims.

Correction to the earlier argument: R5 top-failing C6 drilldown is not a circular dependency on the future `rebuild-c6` gate. R5 can consume historical failure evidence such as base 10/23 and 0/34 as feed-forward evidence. Therefore the route verdict must explicitly not be blocked by `rebuild-c6`.

Governance-strength decision:

- Do not add R-L17 route/candidate verdicts into C24 status enums.
- Do not create a heavy `check_rl17_route_gate.py` or a new schema carrier.
- Record route/candidate verdicts manually in `R7-final-route-deframing-signoff.md`.
- Keep only one future lightweight bypass guard: if the route verdict is not signed, `make verify` should fail when retrain or C6-acceptance tasks are checked off as complete.

### 1. Route Cleanup

- Record current live fact: UIUE PR #5 is merged into `origin/main` at `c1e7d58`.
- Mark the earlier post-PR4 handoff statement "PR #5 not visible" as stale.
- Keep existing GPT Pro architecture absorption doc and `docs/research/INDEX.md` update as pending documentation work until committed or superseded.
- Do not merge UIUE commander work back into the main worktree during this lane.

### 2. R-L17 Deframing Gate

- Re-open the evidence directory as the working checklist: `docs/project/phase0/r-l17-human-review-evidence/`.
- For each R1-R7 item, require artifact path, file:line or row id, verdict, and owner.
- Obtain at least one heterogeneous deframing audit from a non-Claude-family judge.
- Treat Codex/Claude same-vendor audits as pre-check only.
- Require human-owner R7 review for any consistent-PASS result instead of letting consensus bypass deframing.
- Keep route and candidate verdicts separate:
  - `route_deframing_verdict`: may unlock `rebuild-c6` construction only.
  - `candidate_signoff_verdict`: required before C6 acceptance, C5 candidate promotion, golden-run, or readiness claims.
- Do not let `rebuild-c6` become a `blocked_by` edge for the route verdict; R5 uses historical failure evidence before rebuild.

### 3. Paper-To-Skill-Gate Absorption

Detailed Q2 grill decisions are now tracked in `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md`.

Detailed Q3 rebuild-C6 replay-foundation decisions are tracked in `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md`.

Q2.1-Q2.5 are closed for now as deferred absorption design for later `rebuild-c6`, `retrain-c5`, and optional spike carriers. They are not execution authorization, not a claim that 0/34 is fixed, and not a reason to reorder the mainline away from the Phase 0 P0 gates.

Primary 0/34 remedy remains the P0 gate set: R-L09 sample observability, R-L02 physical masking/loss-mask proof, R-L03 byte parity, R-L05 mid-training behavior gate, R-L04 four-layer C6, R-L07 data recipe, R-L17 human deframing/review, and R-L16 governance matrix.

Q2.1 decision: absorb all 8 packets with **zero-drop, strength-tiered algorithm landing**. This supersedes any coarse "paper bucket" reading of the table below. A valid landing must preserve the algorithm's load-bearing parameter, range, prerequisite gate, or failure condition; a bare field name is not enough.

Inputs:

- `Tools/paper-to-skill-gate/trial-runs/2026-06-24-p0-five-pack-index.md`
- 8 packet files under `Tools/paper-to-skill-gate/trial-runs/*.gate.json`
- Human reports under `Tools/paper-to-skill-gate/trial-runs/*.md`

Required absorption split:

| Packet | Route | Required action before code |
|---|---|---|
| `in-vehicle-function-calling-p0` | `retrain-c5` | Preserve D-domain vehicle tool surface and add vehicle-specific success/failure distinctions. |
| `function-calling-data-generation-pack-p0` | `retrain-c5` | Add generation, lineage, diversity, negative composition, and masking gate requirements. |
| `leakage-decontamination-pack-p0` | `retrain-c5` + `rebuild-c6` | Add semantic/template/family leakage gates, not only exact ID split. |
| `learning-rate-matters-vanilla-lora-may-suffice` | `retrain-c5` | Require LR sweep or explicitly label single-LR run as train-health only. |
| `internalizing-tool-knowledge-in-slms-via-qlora` | `retrain-c5` + `rebuild-c6` | Add tool-knowledge/internalized-schema comparison as proposal input only. |
| `when2call-tool-decision-p0` | `rebuild-c6` | Add internal behavior classes for tool-call, clarify, unsupported refusal, safety refusal, and `already_state_noop`; do not carry When2Call `direct` into in-scope cockpit control. |
| `abc-rigorous-agentic-benchmarks-p0` | `rebuild-c6` | Prevent aggregate pass from hiding hard-layer failure. |
| `tinyagent-function-calling-at-the-edge` | `tool-surface-retrieval-spike` | Keep as optional offline retrieval spike; do not alter runtime or prompt surface. ToolRAG may be the first spike only if spike work is needed, but it is not demo-critical ahead of P0 gates. |

Validation before absorption closeout:

```bash
python3 Tools/paper-to-skill-gate/scripts/validate_gate_packet.py \
  Tools/paper-to-skill-gate/trial-runs/*.gate.json
```

Passing this command only proves packet shape. It does not prove paper claims, official repo claims, model quality, or training readiness.

### 4. Rebuild-C6 Proposal First

Primary carrier: `openspec/changes/rebuild-c6-four-layer-bench`.

Before code, the proposal/design/tasks must explicitly cover:

- OpenSpec dependency topology: `rebuild-c6` construction (§2/§3 in the current task split) must not depend on a `retrain-c5` candidate. Candidate comparison (§4) requires a signed candidate and explicit run authorization. Repair stale whole-change dependency declarations in `proposal.md:11`, `proposal.md:84`, `tasks.md:3`, and `tasks.md:12` together.
- Four-layer gate shape: golden / fuzz / unsupported / safety.
- Behavior classes adapted from When2Call: tool-call, clarify, unsupported refusal, safety refusal, and MAformac `already_state_noop`; no `direct_no_call` bucket for in-scope cockpit-control commands.
- Hard-layer denominator logic and fail-closed rule: aggregate pass cannot hide a red layer.
- First pre-selector task: reconcile existing `C6Bucket` values with Q2.2 `behavior_class`, C5 `data_class_observed_count`, apply-layer `no_effect_reason`, and external four-layer reporting before any mechanical selector, active threshold, or active base anchor is frozen.
- Reconfirm current `origin/main` and the target worktree before implementing any Q3 line-level instruction. Q3 evidence was live-verified against `a9ce7cf` while `origin/main` already contained later UIUE commits; file:line references in the ledger are evidence anchors, not proof that current `origin/main` still has identical APIs or line numbers.
- C6 Replay Fact Bundle as replay foundation, not a standalone `ContractReplayEngine` architecture track.
- Reuse current `ScopeOrigin`, `ScopeResolution.keys/resolvedScopes`, `C2ScopeResolver.scopedKey()` string format, and `ToolContractStateApplier.applyWithEvidence` as the existing slim target-resolution / scoped-key / execution-evidence foundation.
- Treat the four Q3.1 deltas as three-layer ownership, not rebuild-C6 private work: `no_effect_reason` is shared behavior-class taxonomy consumed by C5 data receipts, C6 denominators/selectors, and apply/execution no-effect reasoning; `StateApplyDiagnostics` is apply/execution-layer output extending `ToolContractStateApplyResult`; and only `contract_bundle_fingerprint` plus `readback_excluded_from_model_hard_pass` are rebuild-C6-produced.
- For Q3.3, keep apply diagnostics descriptive: add `appliedWrites` to the apply result; derive `unexpectedMutationKeys` in C6 replay from applied/final state versus expected keys. Do not pass C6 expected-state sets into `applyWithEvidence`.
- For Q3.4, add `write_kind=direct|dependency` only after `appliedWrites` covers numeric direct, enum direct, and dependency writes with before/after evidence; enum writes map to `direct`, dependency writes map to `dependency`, and `noop` is forbidden as a write kind.
- For Q3.5, make `contract_bundle_fingerprint` a versioned component manifest over contract inputs, not a second opaque run/result hash. Preserve existing per-run `prompt_hash`, `tool_output_digest`, `contract_digest`, and artifact digests; exclude prompts, outputs, seeds, and model artifacts from the bundle.
- For Q3.6, make `readback_excluded_from_model_hard_pass` a hard-pass basis split, not readback deletion: model hard-pass excludes readback, `verify-gold` keeps C2 renderer readback validity, and clarify/refusal text evidence remains part of hard-pass when asserted.
- Keep `ScopedStateKey` struct promotion, full `ContractReplayEngine`, and full `PlannedEffect` planner split as optional hardening only after concrete string-key or replay-diagnostic defects.
- Unexpected mutation and dependency side-effect policy.
- Readback compare using structured facts, not receipt metadata reading itself.
- Manifest hashes: generator hash, trap migration hash, output JSONL hash, contract bundle fingerprint.
- Proof class boundary: C6 bench pass is model-quality evidence only after authorized run; it is not endpoint, demo, mobile, or V-PASS.
- Q4 OpenSpec absorption closeout: Q4.2-Q4.15 decisions in the rebuild-C6 ledger are closed for pre-code discussion. Documentation absorption may edit only OpenSpec docs/ledgers, must keep `retrain-c5` candidate as a §4-local comparison dependency, must keep `local_static_teardown` as static evidence only, and must use only the validation whitelist recorded in the Q4 ledger.

### 5. Retrain-C5 Follows C6

Primary carrier: `openspec/changes/retrain-c5-lora-d-domain`.

Before code, the proposal/design/tasks must explicitly depend on C6 readiness and cover:

- Surface source: D-domain named tools remain the model-visible surface.
- Data composition: positive, no-call, clarify/refusal, unsupported/safety, and hard negatives.
- Sample observability computed from actual tools and labels, not metadata. Q2.4 narrows the minimum data-receipt delta to value-in-source derivations for `no_call_target_present`, physical `masking_coverage`, `data_class_observed_count`, `tool_surface_kind`, and `leakage_receipt`; do not expand this into a broad training receipt schema.
- Semantic/template/family leakage scan.
- LR grid / rank grid / seed policy / best-checkpoint policy.
- DoRA rank8 remains a conditional escape hatch only; it is not a pre-unlocked spike and cannot bypass surface/byte/mid-gate/masking diagnostics or vanilla LR-first discipline.
- Mid-training behavior gate using C6 support without turning C6 release cases into a checkpoint-selection oracle.
- Endpoint byte parity remains blocked until endpoint render bytes exist.
- Train-health, C6 model-quality, and endpoint/demo readiness remain separate statuses.

### 6. Governance And Discussion Work

- Update route language so old plans are treated as implementation history or route-control inputs, not active instructions to re-run.
- Keep `docs/project/phase0/stop-the-train-openspec-carrier-map.md` as the row-preservation anchor for R-L09/R-L02/R-L03/R-L05/R-L04/R-L07/R-L17/R-L11.
- Add a focused grill before any code dispatch:
  1. What is the minimum C6 replay foundation that must land before data generation?
  2. Which paper packet claims are strong enough for OpenSpec requirements versus only notes?
  3. What exact R-L17 evidence is still missing?
  4. What is the first acceptable C6 proof class?
  5. What status vocabulary is allowed in C6 and C5 closeouts?
- Prepare dispatches with lane separation:
  - R-L17 deframing evidence lane.
  - Paper packet absorption lane.
  - `rebuild-c6` proposal/design/tasks lane.
  - `retrain-c5` proposal/design/tasks lane.
  - Optional `tool-surface-retrieval-spike` lane.

## Stop Conditions

Stop before code if any of the following is true:

- R-L17 evidence status is unknown or falsely treated as closed.
- `route_deframing_verdict` is treated as C6 acceptance, retrain authorization, golden-run readiness, or V-PASS.
- Paper packet output is cited as implementation authorization.
- `rebuild-c6` proposal cannot state hard-layer denominators and fake-green prevention.
- `retrain-c5` attempts to run before C6 yardstick exists.
- UIUE visual work becomes a main worktree blocker without a state/C3-C6/readback/golden intersection.
- A closeout tries to promote local/mock/CI evidence to C6 acceptance, endpoint readiness, mobile proof, true-device proof, or V-PASS.

## Minimal Next Artifact

The Q3 rebuild-C6 grill packet is now recorded in `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md`.

The next useful artifact is still not Swift code. It is a documentation-only OpenSpec absorption pass for `openspec/changes/rebuild-c6-four-layer-bench` that maps Q2/Q3/Q4 decisions into proposal/design/tasks/spec delta without authorizing C6 acceptance, D-domain base recalibration, C5 training, golden-run, voice, endpoint readiness, or R-L17 closure.
