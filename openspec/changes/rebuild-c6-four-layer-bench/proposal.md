> DRAFT SKELETON（2026-06-24 Q1-Q4 文档吸收版，待人审 propose）
>
> This change is an OpenSpec carrier for rebuilding C6 as the trusted yardstick before C5 retraining. It is documentation absorption only until propose acceptance and route gates are satisfied.
>
> **Supersession note:** this replaces the 2026-06-23 A2-era banner that deferred all §3 four-layer work. Under the 2026-06-24 unlock-layer route, C6 construction may be proposed first, but C6 acceptance, D-domain base recalibration, C5 training, candidate comparison, golden-run, voice, endpoint readiness, UIUE merge, and R-L17 closure remain unauthorized.

## Why

MAformac's demo failure mode is not architecture purity; it is C5 quality judged by a credible C6 yardstick. The previous C5 0/34 failure exposed fake-green risks in denominators, no-call buckets, metadata-derived receipts, readback scoring, and training-before-verification ordering.

This change rebuilds C6 as a four-layer bench with independent denominators and replay evidence before `retrain-c5-lora-d-domain` produces a candidate. It keeps `harden-contract-runtime-spine` embedded as the minimum C6 replay foundation rather than a standalone track.

## Route And Dependency Topology

This change has two lanes:

- **C6 Construction Lane (§2/§3):** migrate C6 expected-tool semantics onto the D-domain surface, define four independent layers, reconcile behavior-class taxonomy, define replay evidence, define receipt/fingerprint/readback boundaries, and design a future D-domain base anchor. This lane does **not** depend on a retrain-C5 LoRA candidate.
- **Candidate Comparison Lane (§4):** compare a signed retrain-C5 candidate against base with the completed C6 harness. This lane depends on a signed candidate and explicit run authorization.

The stale whole-change dependency on `retrain-c5-lora-d-domain` is intentionally downgraded to a §4-local dependency. This preserves the 0/34 lesson: the trusted verification gate must exist before later training claims can be trusted.

## Decision Sources

- `docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md`
- `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md`
- `docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md`
- `UBIQUITOUS_LANGUAGE.md`
- `docs/research/2026-06-24-pr4-gptpro-architecture-absorption.md`
- Existing C6/spec evidence from `docs/c5-recovery-2026-06-22/grill-decisions.md`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`, and archived `openspec/specs/vehicle-tool-bench/spec.md`

## What Changes

- **Expected tool calls move to D-domain named tools.** C6 release cases must stop relying on generic `tool_call_frame` semantics and must reference the D-domain tool surface defined by `qwen-tool-call-format.yaml`.
- **Four independent external layers.** C6 reports golden, demo_fuzz, unsupported, and safety independently. Aggregate pass rate cannot hide a hard layer failure.
- **Five internal behavior classes.** C6 behavior classification uses `tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, and `already_state_noop`. In-scope cockpit control has no `direct_no_call` bucket.
- **Behavior-class SSOT across C5/C6/apply.** The shared taxonomy must cover C5 `data_class_observed_count`, C6 `C6Bucket` / denominator selectors, and apply/execution `no_effect_reason`. `C6Bucket` must be reconciled to this source before executable selectors, active thresholds, or active base anchors are frozen.
- **C6 replay fact bundle, not a second runtime.** Reuse current `ScopeOrigin`, `ScopeResolution`, stringly scoped keys, and apply evidence. C6 consumes apply-layer `appliedWrites` when available, and derives `unexpectedMutationKeys` itself from applied/final state versus expected keys.
- **Contract bundle fingerprint.** Add a versioned component manifest over contract inputs and a bundle hash, while preserving existing per-run prompt/output/model/artifact digests.
- **Readback plan P.** Model hard-pass excludes renderer readback; `verify-gold` keeps deterministic C2 renderer readback validity; clarify/refusal text evidence still counts when asserted.
- **Historical vs future base semantics.** Old 10/23 generic-frame evidence remains `historical_base_anchor`; future D-domain base-anchor design is deferred semantics, not permission to rerun recalibration.

## Phase 0 Decisions Required Before Apply

D1-D10 user decisions are accepted in `docs/project/phase0/phase0-d1-d10-user-decision-record.md`. This removes the pending user-decision gate only; it does not authorize implementation, D-domain base recalibration, model-quality evaluation, endpoint-ready claims, voice, demo-golden execution, or R-L17 closure.

- R-L17 route deframing may unlock C6 construction only. Candidate signoff is still required before C6 acceptance, candidate promotion, golden-run, or readiness claims.
- R-L17 route/candidate verdicts are manual governance signoffs, not runtime status enums.
- Before implementation, reconfirm current `origin/main`, target worktree, and load-bearing APIs because Q3 evidence used historical file:line anchors.
- Documentation absorption may use `local_static_teardown` evidence for design, but cannot promote teardown into C6 acceptance or model-quality proof.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `vehicle-tool-bench`: D-domain expected tool calls, four-layer reporting, shared behavior-class taxonomy, replay evidence boundaries, contract bundle fingerprint, and readback hard-pass split.

## Non-Goals

- No training, model run, C6 acceptance, D-domain base recalibration, golden-run, voice, endpoint-readiness claim, V-PASS/S-PASS/U-PASS, UIUE merge, or R-L17 closure.
- No standalone `harden-contract-runtime-spine`, full `ContractReplayEngine`, full `PlannedEffect` planner, or mandatory `ScopedStateKey` struct promotion in the minimum construction lane.
- No `direct_no_call` behavior class for in-scope cockpit-control commands.
- No private C6-only taxonomy for no-effect/already-state/refusal buckets.
- No C6-owned implementation of apply diagnostics. Apply/execution produces applied-write evidence; C6 consumes it.
- No use of C6 release cases as checkpoint-selection oracle.
- No copying raw cockpit/customer source text, PII, secrets, or "internal only" material into bench cases.

## Success Criteria

Documentation absorption criteria:

- `openspec validate rebuild-c6-four-layer-bench --strict` passes.
- `openspec validate --all --strict` passes.
- `git diff --check` passes.
- OpenSpec text contains the construction/comparison topology split and does not declare the whole change dependent on retrain-C5 candidate availability.
- `proposal.md`, `design.md`, `tasks.md`, and spec delta carry Q2/Q3/Q4 decisions without authorizing forbidden runs.

Future construction criteria, after propose/apply authorization:

- Expected tool calls are D-domain named tools, with no generic `tool_call_frame` dependency in release cases.
- Four external layers and five internal behavior classes are independently reported.
- Behavior-class SSOT is reconciled across C5 data counts, C6 selectors/denominators, and apply no-effect reasoning.
- Readback exclusion, replay fact bundle, applied-write consumption, unexpected mutation derivation, and contract bundle fingerprint are recorded in receipts.

Future comparison criteria, after signed candidate and explicit run authorization:

- Base-vs-LoRA comparison uses the same prompt/parser/mock-state/scoring/replay fingerprint harness.
- Candidate comparison does not claim endpoint readiness, demo readiness, V-PASS, S-PASS, or U-PASS.

## Impact

- Primary OpenSpec carrier: `openspec/changes/rebuild-c6-four-layer-bench`.
- Construction lane depends on the D-domain/default-scope contract state being reconfirmed at current `origin/main`.
- Candidate comparison lane depends on `retrain-c5-lora-d-domain` only when a signed candidate exists and the run is explicitly authorized.
- Future implementation may affect `Core/Bench/C6VehicleToolBench.swift`, `contracts/c6-bench-cases.jsonl`, `contracts/qwen-tool-call-format.yaml`, and renderer/readback receipt fields, but this documentation absorption does not touch those paths.
