# Rebuild C6 Four-Layer Bench Design

> DRAFT. This design records Architecture Decisions for documentation absorption into `rebuild-c6-four-layer-bench`. It is not permission to run D-domain base recalibration, evaluate model quality, train C5, claim endpoint readiness, execute demo-golden-run, run voice, close R-L17, or merge UIUE.

## Scope

This change defines the C6 construction lane first, then a later candidate comparison lane:

- **Construction lane:** D-domain expected-tool semantics, four-layer denominators, five-class behavior taxonomy, replay evidence, readback hard-pass split, contract bundle fingerprint, and future base-anchor semantics.
- **Comparison lane:** base-vs-LoRA comparison using the completed harness after `retrain-c5-lora-d-domain` produces a signed candidate and the run is explicitly authorized.

`retrain-c5-lora-d-domain` is not a whole-change prerequisite. It is a §4 comparison-lane prerequisite only.

## Architecture Decisions

### AD-C6-001: Four-layer denominators derive from case schema fields

R-L04 and D1 are accepted architecture decisions. C6 denominators derive from case schema fields and explicit behavior classification, not aggregate pass rate. C6 must not use aggregate pass rate as a substitute for golden, demo_fuzz, unsupported, safety, action, clarify, already-state, or readback denominators.

Old generic-frame base 10/23 is historical failure evidence. It informs risk and comparison design, but it is not an active D-domain threshold.

### AD-C6-002: D-domain base anchor is comparison design, not permission to run

The future D-domain base anchor defines comparison semantics only. D-domain base recalibration is deferred until separately authorized. The terms `active_base_anchor`, `current_d_domain_base_anchor`, bare `base_anchor`, and bare `d_domain_base_anchor` are banned unless explicitly prefixed as historical or future design.

### AD-C6-003: C6 exposes sampling support for C5 mid-training behavior gates

R-L05 and D2 create a dependency from retrain-C5 to C6 sample runners. This support exists for iter50/100/150 behavior-generation samples and does not make C6 release cases a checkpoint-selection oracle.

### AD-C6-004: C6 gate integrity is sign-or-block

R-L11 is an architecture decision. pass^k, hardPassVariance, layer denominators, and grader results must be enforced when claimed. A grader failure, missing evidence, or missing layer keeps the candidate unsigned.

### AD-C6-005: R-L17 is a manual route/candidate governance gate

R-L17 evidence must include human-owner participation, at least one heterogeneous judge outside the Claude-family, and a record of the R5 top-failing C6 drilldown plus R7 final route signoff under `docs/project/phase0/r-l17-human-review-evidence/`.

Default same-vendor self-checks are pre-checks only. The current route-only R7 signoff explicitly accepts the GLM audit plus Codex/OpenAI review trace for route construction; this does not sign the candidate. A four-model "consistent pass" signal does not certify route or candidate signoff. If any judge disagrees, the route escalates to human-owner review rather than majority vote.

### AD-C6-006: C6 model quality does not imply endpoint or demo readiness

C6 evidence does not imply endpoint readiness, demo-golden readiness, V-PASS, S-PASS, or U-PASS. Readback renderer evidence remains separate from model hard-pass evidence.

### AD-C6-007: Behavior-class taxonomy is shared across C5, C6, and apply

The behavior-class taxonomy has five internal values:

- `tool_call`
- `clarify_missing_slot`
- `refusal_no_available_tool`
- `refusal_safety_or_policy`
- `already_state_noop`

There is no `direct_no_call` bucket for in-scope cockpit-control commands. This taxonomy is the source for C5 `data_class_observed_count`, C6 `C6Bucket` / selector denominators, and apply/execution `no_effect_reason`. Any existing `C6Bucket` values must be reconciled to this source before executable selectors, active thresholds, or active base anchors are frozen.

### AD-C6-008: Readback plan P splits renderer evidence from model hard-pass

Model hard-pass must exclude renderer readback. `verify-gold` must retain deterministic C2 `renderReadback` validity as renderer evidence. Clarify and refusal text evidence still counts when asserted by the case schema, because that is model decision behavior, not renderer polish.

Receipts must expose exactly this observable seven-field readback split: `model_hard_pass_basis`, `model_hard_failed`, `readback_applicable`, `readback_match`, `readback_hard_failed`, `readback_excluded_from_model_hard_pass`, and `renderer_contract_digest`. Missing fields are unknown/blocking. Renderer mismatch sets renderer/readback failure but never changes the model-hard numerator.

### AD-C6-009: Contract bundle fingerprint is a versioned component manifest

`contract_bundle_fingerprint` is a bundle-level contract-input manifest, not a second opaque run hash and not a replacement for per-run identity fields.

The manifest uses an ordered list of `{component_id, version, content_digest}`. Receipt `bundle_hash` is computed from canonical JSON of `{schema_version, component_versions, component_digests}`, and JSON/Markdown summaries expose both version and digest maps. Fixed component IDs include C1 contract, C2 renderer/state cells, C6 cases, Qwen tool format, D-domain IR map, and the D-domain demo tool catalog.

Prompts, model outputs, seeds, model artifacts, tokenizer digests, and LoRA adapter digests remain per-run identity or model-artifact fields. They must not be absorbed into the contract bundle fingerprint.

Canonical JSON encoding for identity digests is throwing. Encoding failure is an infrastructure error and must not be converted to empty data.

### AD-C6-009A: Summarize consumes complete known case envelopes only

`C6BenchCLI summarize` must fail closed when a model-results envelope contains unknown result IDs or omits any expected C6 case ID. Partial or extra envelopes cannot produce C6 summary receipts because they can downgrade proof by silently shrinking denominator coverage.

### AD-C6-010: Apply diagnostics are upstream facts, not C6-owned runtime logic

`StateApplyDiagnostics` belongs to the apply/execution layer as an extension of `ToolContractStateApplyResult` / `applyWithEvidence`. Rebuild-C6 may consume applied-write evidence, but it must not implement a private apply engine or duplicate apply semantics.

This carrier may coordinate a bounded upstream producer subtask that extends `ToolContractStateApplyResult` with `appliedWrites` and makes `applyWithEvidence` populate those descriptive facts. That subtask is owned as apply/execution-layer producer work carried by this OpenSpec change, not as C6 runtime or scorer logic. It must not change existing throw-on-failure semantics, scope resolution policy, or apply policy.

Minimum applied-write evidence is descriptive: state key, before value, after value, scope origin, and write kind (`direct` or `dependency`). `noop` is not a write kind. Enum writes map to `direct`; dependency side effects map to `dependency`.

C6 derives `unexpectedMutationKeys` by comparing applied/final state to the case's expected keys and allowed dependency policy. C6 expected-state sets must not be passed into `applyWithEvidence`.

### AD-C6-011: Documentation absorption uses local static proof only

Q2/Q3/Q4 absorption into this OpenSpec carrier is documentation work. It may cite static paper/repo/code teardown as design evidence, but teardown is not validation. The proof class is `local` / `local_static_teardown`.

Allowed documentation-absorption validation is limited to:

- `openspec validate rebuild-c6-four-layer-bench --strict`
- `openspec validate --all --strict`
- `git diff --check`

This lane must not run Swift tests, `make verify`, C6 acceptance, model evaluation, D-domain base recalibration, golden-run, endpoint checks, voice, or any model/data training command as proof for documentation absorption.

### AD-C6-012: Implementation must reconfirm baseline and load-bearing APIs

Q3 file:line evidence was gathered against a historical branch. Before any implementation, record branch, `HEAD`, `origin/main`, and current symbol presence for `ScopeOrigin`, `ScopeResolution.keys`, `ScopeResolution.resolvedScopes`, `C2ScopeResolver.scopedKey()`, and `ToolContractStateApplier.applyWithEvidence`. If any symbol moved, disappeared, or changed semantics, halt and re-grill instead of applying stale line-level instructions.

### AD-C6-013: Demo-fuzz family v2 has one selector and fresh identity owner

Only `demo_fuzz` uses the seven-family roster keyed by `tags.contract_device`. The selector owns the eligible denominator; the corpus manifest owns canonical case bytes; the run manifest joins selector digest, corpus digest, family roster digest, result-set digest, and receipt digest. Every digest is recomputed from fresh bytes. A family with denominator zero, a missing family run, or denominator-positive/pass-zero is an extinction failure. No separate per-family 80% rule is introduced.

### AD-C6-014: Comparison identity is a typed same-subject join

Base and candidate comparison uses `n=3`, seeds `[17,29,43]`, all `3/3` runs present, and hard-pass spread `max-min <= 1` percentage point. Each paired run must have equal prompt, parser, mock-state, scorer, selector/corpus, contract bundle, and replay fingerprint identities. Missing, duplicate, or unequal join fields make results incomparable; there is no manual override.

### AD-C6-015: Promotion governance has five independent axes

Construction, candidate formation, authorization, execution, and acceptance are separate state axes. Artifact builders own construction facts; candidate assembly owns immutable candidate identity; the human authority owns authorization; the runner owns execution facts but never signing; acceptance consumes completed evidence and sign-or-block predicates. `required_judge_lanes=[]` means no automated judge can silently become acceptance authority.

Release corpus carries `must_not_train=true`. Exposure is a five-level enum: `release_corpus`, `training`, `checkpoint_selection`, `prompt_tuning`, `s9_repair`, with any non-release exposure blocking candidate and verdict until revoked and rematerialized from clean inputs.

### AD-C6-016: Legacy cutover is shadow-first and authority-monotonic

Before activation, old runner and fixtures are `legacy_observation_only`: they may emit diagnostics but cannot sign acceptance. The new gate must shadow the current 57-case snapshot, N1-N6, and named deliberate-red fixtures before an activation receipt changes authority. Rollback stops new promotion and returns execution to diagnostic observation; it never restores old acceptance authority.

## Non-Goals

- No D-domain base recalibration run in this documentation absorption.
- No C6 acceptance or model-quality run.
- No LoRA candidate comparison without a signed candidate and explicit run authorization.
- No endpoint-ready claim.
- No demo-golden-run execution.
- No voice work.
- No UIUE merge claim.
- No R-L17 closure.
