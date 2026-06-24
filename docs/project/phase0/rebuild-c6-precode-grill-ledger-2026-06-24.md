---
status: active_discussion_ledger
artifact_kind: rebuild_c6_precode_grill_ledger
authority: discussion_route_control_not_contract
created_at: 2026-06-24
retire_trigger: "Retire after the accepted rebuild-c6-four-layer-bench OpenSpec carrier absorbs or explicitly rejects these Q3 replay-foundation decisions."
expires: "2026-07-15"
---

# Rebuild-C6 Pre-Code Grill Ledger

This ledger records Q3 grill decisions for the pre-code `rebuild-c6-four-layer-bench` route.

It is not C6 acceptance authorization, not D-domain base recalibration authorization, not LoRA training authorization, not golden-run authorization, not voice work, and not R-L17 closure.

## Live Git Boundary

Verified on 2026-06-24:

- Current branch: `codex/pr4-architecture-absorption-20260624`.
- Current `HEAD`: `a9ce7cf`.
- `origin/main`: `c1e7d58`.
- `HEAD` is an ancestor of `origin/main`; `origin/main` contains later UIUE commits.

Therefore Q3.1 evidence below is live-verified against the current worktree at `a9ce7cf`. Do not infer later UIUE `origin/main` behavior from this ledger unless a later reconfirm pass reads those files.

## Q3.1 Decision: C6 Replay Foundation Reuses PR4 Facts Plus Four Deltas

Decision: adopt **C6 Replay Fact Bundle** as the minimum replay foundation, but correct the physical shape.

The earlier framing "current code has no `ScopedStateKey` / `TargetResolution` / replay evidence" was too strong. The current worktree already contains a slim replay foundation from the default-scope apply path.

Verified existing foundation:

| Bundle need | Live code evidence | Decision |
|---|---|---|
| `scope_origin` | `ScopeOrigin` enum has `defaulted`, `explicit`, `fanout` in `Core/Execution/ScopeResolution.swift:3-7`. | Reuse. Do not recreate in C6. |
| `resolved_scope` + scoped state key | `ScopeResolution.keys/resolvedScopes/origin` exist in `Core/Execution/ScopeResolution.swift:9-18`; `C2ScopeResolver.resolve` emits fanout/explicit/defaulted keys and scopes at `:22-53`; `scopedKey()` renders `cellID[scope]` at `:79-81`. | Reuse as the slim `TargetResolution` / stringly `ScopedStateKey` equivalent. |
| state apply evidence | `ToolContractStateApplyResult` carries `scopeOriginEvidence` in `Core/Contracts/ToolContractCompiler.swift:398-405`; `applyWithEvidence` records scope origin per state key at `:423-445`; writes return `ToolContractStateWriteEvidence` at `:591`. | Reuse. |
| C6 consumption of apply evidence | `C6MockStateApplier.applyWithEvidence` delegates to `ToolContractStateApplier.applyWithEvidence` in `Core/Bench/C6VehicleToolBench.swift:1325-1331`; C6 evaluation consumes `scopeOriginEvidence` at `:1161-1175`; gold verification consumes it at `:936-964`. | Reuse. |
| replay fingerprints | `C6EvalRun` includes `prompt_hash`, `tool_output_digest`, and `contract_digest` coding keys in `Core/Bench/C6VehicleToolBench.swift:612-627`; required-field check enforces them at `:630-643`; the active spec requires per-run replay fingerprint fields in `openspec/specs/vehicle-tool-bench/spec.md:187`. | Partially present. Rebuild-C6 should extend only the missing bundle-level fingerprint semantics. |

Minimum Q3.1 deltas, with producer layer:

| Delta | Producer layer | `rebuild-c6` role | Rule |
|---|---|---|---|
| `no_effect_reason` | Shared `behavior_class` taxonomy source for C5/C6/apply | Consume | Must reuse the Q2.2 `behavior_class` SSOT or an explicitly reconciled equivalent. It must not create a third taxonomy beside C5 `data_class_observed_count`, C6 `C6Bucket` / selector denominators, and apply no-effect reasoning. |
| `StateApplyDiagnostics` | Apply/execution layer, extending `ToolContractStateApplyResult` / `applyWithEvidence` | Consume | Add descriptive applied-write evidence only. Unexpected mutations are C6-derived by comparing writes/final state to expected keys; apply does not know the expected set. |
| `contract_bundle_fingerprint` | `rebuild-c6` | Produce by aggregating existing C6 digest fields | Add a bundle-level fingerprint over the contract inputs needed to interpret replay, instead of relying only on per-run `contract_digest` and prompt/tool-output hashes. |
| `readback_excluded_from_model_hard_pass` | `rebuild-c6` | Produce | Add an explicit marker that readback renderer checks are separate from model hard-pass. `readbackAssertion` and renderer logic exist, but the exclusion boundary is not a first-class field. |

Scope boundaries:

- Do not build a standalone `harden-contract-runtime-spine`.
- Do not build a full `ContractReplayEngine` as a production runtime abstraction in this lane.
- Do not build a full `PlannedEffect` planner/validate/apply split unless a later defect requires it.
- Do not promote `scopedKey()` to a `ScopedStateKey` struct in the minimum foundation. That is an optional hardening only if multiple bracket parsers drift or stringly keys start causing concrete defects.
- Do not let C6 derive `ScopeOrigin` independently; C6 consumes `ScopeOrigin` from target resolution / apply evidence.
- Do not let `no_effect_reason` derive a new behavior class. It must consume the Q2.2/Q2.3 classification source after C5 data counts, C6Bucket/selector denominators, and apply no-effect reasoning are reconciled to the same source.
- Do not let C6 privately construct apply-layer `StateApplyDiagnostics`. If applied-write evidence is insufficient, extend `ToolContractStateApplyResult` / `applyWithEvidence` in the apply/execution layer and have C6 consume the result.
- Do not pass C6 expected-state knowledge into `applyWithEvidence` to compute unexpected mutations. That would couple apply/execution to C6 scoring.

Pre-mortem:

| Type | Finding | Verification step |
|---|---|---|
| Tiger | Multi-taxonomy risk: C5 `data_class_observed_count`, C6 `C6Bucket`, Q2.2 `behavior_class`, and Q3.1 `no_effect_reason` can become inconsistent labels for the same no-call/refusal/already-state rows. | `rebuild-c6` first selector task must reconcile these consumers before mechanical selectors, thresholds, or active base anchors. |
| Tiger | Second-runtime risk: if C6 invents apply diagnostics locally, it duplicates execution semantics instead of replaying the execution-layer result. | `StateApplyDiagnostics` must be produced by `ToolContractStateApplier.applyWithEvidence` or equivalent apply-layer API. |
| Tiger | Fake completeness risk: existing `applyWithEvidence` proves scope-origin evidence, not full state diagnostics or no-effect semantics. | Require the four Q3.1 deltas above before calling C6 replay foundation complete. |
| Paper-tiger | "No struct means no replay foundation." | Current code already has `ScopeResolution`, stringly scoped keys, `ScopeOrigin`, and `applyWithEvidence`; a struct promotion is not required for the minimum demo foundation. |
| Elephant | The current branch is behind `origin/main`, but Q3.1 evidence exists in the current branch itself. | Future sessions must reconfirm `HEAD` and avoid mixing UIUE-only commits into non-UIUE C6 claims. |

Physical landing for `rebuild-c6`:

```yaml
c6_replay_fact_bundle_minimum:
  reuse_existing:
    - ScopeOrigin
    - ScopeResolution.keys
    - ScopeResolution.resolvedScopes
    - C2ScopeResolver.scopedKey_string_format
    - ToolContractStateApplier.applyWithEvidence
    - ToolContractStateApplyResult.scopeOriginEvidence
  produce_upstream:
    taxonomy:
      - no_effect_reason_from_behavior_class_ssot
    apply_execution:
      - applied_writes_in_ToolContractStateApplyResult
  produce_in_rebuild_c6:
    - unexpected_mutation_keys_derived_from_applied_writes_and_expected_delta
    - contract_bundle_fingerprint_aggregates_existing_digests
    - readback_excluded_from_model_hard_pass
  optional_hardening_only:
    - ScopedStateKey_struct
    - full_ContractReplayEngine
    - full_PlannedEffect_planner_split
```

## Q3.2 Decision: Delta Ownership Is Three-Layer, Not Default-Scope vs Rebuild-C6

Decision: keep the "do not reopen default-scope" principle, but reject the two-bucket ownership frame.

The correct ownership frame is:

| Delta | Producer layer | Why | `rebuild-c6` role |
|---|---|---|---|
| `no_effect_reason` | Shared behavior-class taxonomy source | C5 data receipts, C6 denominators/selectors, and apply/execution no-effect reasoning all need the same five-class behavior source from Q2.2/Q2.3. If rebuild-C6 owns a private taxonomy, C5 and apply/execution must reverse-depend on C6. | Reference/consume. |
| `StateApplyDiagnostics` | Apply/execution layer | `ToolContractStateApplyResult` already exists with `state` and `scopeOriginEvidence`, and `applyWithEvidence` already produces it (`Core/Contracts/ToolContractCompiler.swift:398-445`). Diagnostics are the natural extension of that result. | Consume. |
| `contract_bundle_fingerprint` | Rebuild-C6 | C6 already owns per-run fingerprints and `hasRequiredFingerprintFields` (`Core/Bench/C6VehicleToolBench.swift:600-643`). The delta is an aggregation of existing C6 digest fields into bundle semantics. | Produce aggregation. |
| `readback_excluded_from_model_hard_pass` | Rebuild-C6 | This is a C6 evaluation-boundary marker for renderer/readback evidence versus model hard-pass. | Produce. |

Default-scope boundary:

- Do not reopen `define-demo-default-scope` just to host these four deltas.
- Default-scope has already produced the scope-resolution/apply-evidence basis that Q3.1 reuses.
- Reopen default-scope only for a real defect in `ScopeOrigin`, `ScopeResolution`, scoped key emission, or current apply evidence.

Apply/execution boundary:

- If `StateApplyDiagnostics` or apply evidence is incomplete, fix the apply/execution layer (`ToolContractStateApplyResult` / `applyWithEvidence`), then let C6 consume it.
- Do not patch over apply-layer gaps inside C6 scorer logic.
- Do not make apply/execution depend on C6 expected-state sets. Unexpected mutation is a C6 replay comparison, not an apply-layer fact.

Taxonomy boundary:

- If `no_effect_reason` cannot map to Q2.2 `behavior_class`, fix the shared taxonomy/reconciliation layer used by C5 data counts, C6 denominators/selectors, and apply/execution no-effect reasoning.
- Do not define a rebuild-C6-only no-effect enum.

## Q3.3 Decision: Apply Diagnostics Are Applied Writes, Not A Planner

Decision: adopt **A-prime** rather than raw A.

The user-proposed direction is right on the important axes: diagnostics must be descriptive, fail-closed, and must not grow into plan/validate/apply runtime. The correction is ownership of `unexpectedMutations`: apply/execution does not know C6's expected state set, so it cannot produce "unexpected" keys without either taking C6 scoring inputs or inventing a second policy.

Evidence:

- `ToolContractStateApplyResult` currently contains `state` and `scopeOriginEvidence` only (`Core/Contracts/ToolContractCompiler.swift:398-405`).
- `applyWithEvidence` currently throws on unclassified tools and returns the apply result on success (`Core/Contracts/ToolContractCompiler.swift:423-445`).
- C6 already owns the expected-vs-actual replay comparison. It computes `unexpectedDelta` from final state and expected keys including dependencies (`Core/Bench/C6VehicleToolBench.swift:795-808`).
- C6 calls `applyWithEvidence`, catches thrown failures, and maps them to C6 failure classes rather than asking apply to soft-fail (`Core/Bench/C6VehicleToolBench.swift:1072-1081`, `:1183-1201`).

Minimum apply-layer shape:

```swift
public struct ToolContractStateApplyResult: Equatable, Sendable {
    public var state: [String: String]
    public var scopeOriginEvidence: [String: String]
    public var appliedWrites: [StateWrite]
}

public struct StateWrite: Equatable, Sendable {
    public var stateKey: String
    public var before: String?
    public var after: String
    public var scopeOrigin: ScopeOrigin?
}
```

Producer split:

| Field / diagnostic | Producer | Reason |
|---|---|---|
| `appliedWrites` | apply/execution layer | It records what the applier actually wrote, including before/after values and scope origin. |
| `unexpectedMutationKeys` | C6 replay layer | It requires C6 expected-state knowledge and dependency allowance. Derive it from `appliedWrites` or final-state delta versus expected keys. |
| `noEffectReason` | behavior-class taxonomy / Fact Bundle | It is semantic classification, not apply-layer knowledge. |
| `errors` | no soft collection in apply layer | `applyWithEvidence` stays throwing/fail-closed. C6 catches and maps to C6 failure classes. |

Rules:

1. Descriptive, not predictive: apply diagnostics record what was written, not what should have been planned.
2. Extend, do not fork: extend `ToolContractStateApplyResult`; do not create a standalone replay engine or second applier.
3. Fail closed: apply errors still throw; do not add an `errors` array that lets callers treat failed apply as a partial pass.
4. Reference, do not classify: apply does not label `already_state`, `unsupported`, safety, or clarify. Those come from the shared behavior taxonomy and C6/C5 reconciliation.
5. C6 derives unexpected mutations: C6 may record `unexpectedMutationKeys`, but only as replay comparison output, not as apply-layer diagnostics.

Tiger:

- If `unexpectedMutations` is stored in `ToolContractStateApplyResult`, someone must pass expected keys into apply, or apply must guess. Both create a boundary leak.
- If `errors` is stored instead of thrown, failed apply can re-enter the fake-green pattern as "diagnosed but not blocking."

Paper-tiger:

- "Without `unexpectedMutations` in apply result, C6 cannot detect wrong extra writes" is false. C6 already has expected-vs-actual comparison logic and should expose the derived keys in its receipt.

Elephant:

- Enum writes currently return no write evidence, while numeric writes return `ToolContractStateWriteEvidence`. Implementing `appliedWrites` later must make enum, numeric, and dependency writes all visible. Otherwise C6 replay evidence will over-cover scoped numeric cases and under-cover enum cases.

## Q3.4 Decision: `write_kind=direct|dependency`, But Evidence Coverage Comes First

Decision: adopt `write_kind`, but bind it to two prerequisites.

The earlier Q3.4 direction was right: `write_kind` is an apply-layer fact and should be limited to `direct | dependency`; `noop` is not a write kind. The missing hard point is that `write_kind` can only label writes that are already visible. Current evidence coverage is incomplete.

Verified write coverage today:

| Write source | Live code | Current evidence | Future `write_kind` |
|---|---|---|---|
| Numeric direct writes | `for key in writeKeys { state[key] = value }` in `Core/Contracts/ToolContractCompiler.swift:585-587` | Present only as `writeKeys.map { ToolContractStateWriteEvidence(...) }` at `:591`, without before/after. | `direct` |
| Dependency writes | `for dependency in cell.dependsOn { state[dependency] = "on" }` in `Core/Contracts/ToolContractCompiler.swift:588-589` | Missing; dependencies are not included in the returned evidence at `:591`. | `dependency` |
| Enum direct writes | `state[cellID] = ...` in `Core/Contracts/ToolContractCompiler.swift:516`, `:518`, `:520`; caller returns `[]` after `applyEnumCell` at `:502-504`. | Missing; enum writes return no evidence. | `direct` |

Minimum shape:

```swift
public enum StateWriteKind: String, Codable, Equatable, Sendable {
    case direct
    case dependency
}

public struct StateWrite: Equatable, Sendable {
    public var stateKey: String
    public var before: String?
    public var after: String
    public var scopeOrigin: ScopeOrigin?
    public var writeKind: StateWriteKind
}
```

Rules:

1. Evidence before labeling: first make numeric direct, enum direct, and dependency writes all emit `appliedWrites` with `before`/`after`; then add `writeKind`.
2. Enum is direct: enum writes are target-cell writes, not a third write kind.
3. Dependency is visible: dependency writes must appear in `appliedWrites`, otherwise C6 cannot distinguish allowed dependency side effects from unexpected mutations.
4. No `noop`: no-op is a result interpretation from `before == after` plus behavior-class/no-effect semantics, not a write source.
5. No planner fields: do not add `triggeredBy`, expected/allowed keys, planner reason, or error list to `StateWrite`.

Tiger:

- If dependency writes stay invisible, C6 replay can either falsely flag allowed dependency writes as unexpected or miss dependency overreach entirely. That is an anti-fake-green gap, not just a labeling gap.
- If enum writes stay invisible, apply evidence will be biased toward numeric/scoped cells and under-report common direct state changes such as power on/off.

Paper-tiger:

- "Adding `write_kind` is overengineering" is too broad. Two write kinds mirror two existing apply-layer write sources and do not require C6 expected-state knowledge.

Elephant:

- `write_kind` is a consequence of complete applied-write evidence, not a substitute for it. A future implementation that only adds an enum field to the current `ToolContractStateWriteEvidence` while leaving enum/dependency writes invisible would be fake hardening.

Physical landing:

```yaml
state_write_minimum:
  required_before_write_kind_is_useful:
    - numeric_direct_writes_emit_before_after_evidence
    - enum_direct_writes_emit_before_after_evidence
    - dependency_writes_emit_before_after_evidence
  write_kind:
    allowed:
      - direct
      - dependency
    forbidden:
      - noop
      - planner_reason
      - expected_or_allowed_keys
      - soft_error_collection
  mapping:
    numeric_writeKeys: direct
    enum_cell_write: direct
    depends_on_write: dependency
```

## Next Grill Question

## Q3.5 Decision: `contract_bundle_fingerprint` Is A Component Manifest, Not A Second Opaque Hash

Decision: adopt `contract_bundle_fingerprint`, but correct its role.

The initial framing implied current C6 only has scattered per-run digests and needs a new bundle hash. Live code shows a stronger current state: `C6Hash.contractDigest(repoRoot:datasetText:)` already hashes five contract inputs in `Core/Bench/C6VehicleToolBench.swift:1553-1568`:

1. `contracts/semantic-function-contract.jsonl`
2. `contracts/state-cells.yaml`
3. `contracts/c6-bench-cases.jsonl` via the already-loaded `datasetText`
4. `contracts/qwen-tool-call-format.yaml`
5. `generated/d_domain_ir_map.json`

`Tools/C6BenchCLI/main.swift:72-78` loads the bench dataset and passes that aggregate `contractDigest` into `C6BenchRunner`; each run records it as required fingerprint data (`Core/Bench/C6VehicleToolBench.swift:599-608`, `:630-643`), and the active spec requires `contract_digest` plus per-run prompt/output/artifact digests (`openspec/specs/vehicle-tool-bench/spec.md:187`).

So the missing piece is not "add a bigger hash." The missing piece is a named, versioned component manifest that makes the contract input set auditable.

Minimum shape:

```yaml
contract_bundle_fingerprint:
  schema_version: c6_contract_bundle_v1
  bundle_hash: sha256(canonical_json(component_digests))
  component_digests:
    semantic_function_contract_jsonl: sha256(contracts/semantic-function-contract.jsonl)
    state_cells_yaml: sha256(contracts/state-cells.yaml)
    c6_bench_cases_jsonl: sha256(active_dataset_text)
    qwen_tool_call_format_yaml: sha256(contracts/qwen-tool-call-format.yaml)
    d_domain_ir_map_json: sha256(generated/d_domain_ir_map.json)
  legacy_contract_digest:
    source: C6Hash.contractDigest
    role: compatibility_until_rebuild_c6_migration_decides_alias_or_replacement
```

Explicit exclusions:

```yaml
excluded_from_contract_bundle_fingerprint:
  per_case_or_per_run:
    - prompt_hash
    - sampling_seed
    - tool_output_digest
    - run_id
  model_artifacts:
    - model_artifact_digest
    - tokenizer_digest
    - lora_adapter_digest
    - lora_adapter_id
    - lora_checkpoint_id
  volatile_execution:
    - elapsed_ms
    - pass_rate
    - hard_failures
```

Why:

- `prompt_hash` and `tool_output_digest` are per case/run replay facts. Putting them in the bundle makes every run produce a different "contract" and destroys cross-run comparability.
- `model_artifact_digest`, `tokenizer_digest`, and `lora_adapter_digest` are required run identity fields, but they identify the model under test, not the C6 contract bundle.
- `contract_digest` currently protects source drift but is opaque: it does not say which components were included, which schema version defined the set, or which component changed. A manifest fixes auditability without inventing a second runtime.

Rules:

1. Keep current per-run fields: do not remove `contract_digest`, `prompt_hash`, `tool_output_digest`, or artifact digests in the first rebuild-C6 proposal.
2. Add bundle semantics as component-level metadata: each component digest must be visible in the receipt, not only the final aggregate hash.
3. Compute `bundle_hash` from canonical JSON of `{schema_version, component_digests}`, not by ad hoc byte concatenation without component labels.
4. Do not include model outputs, prompts, seeds, or artifact digests in the bundle.
5. If `contract_digest` is later aliased to `bundle_hash`, that migration must be explicit and tests must keep old receipt compatibility or a clear receipt-version bump.

Tiger:

- If `contract_bundle_fingerprint` includes `tool_output_digest` or `prompt_hash`, the same C6 contract will appear different across cases/runs. That turns replay identity into result identity.
- If it excludes `generated/d_domain_ir_map.json` or `qwen-tool-call-format.yaml`, D-domain name-to-IR or parser-surface drift can fake-green old cases under a changed harness. Current `contractDigest` already includes both; do not regress.
- If it remains a single opaque string, auditors cannot tell whether a changed result came from dataset, C1, C2, format, or D-domain IR drift.

Paper-tiger:

- "`contract_bundle_fingerprint` is redundant because `contract_digest` exists" is too broad. The aggregate digest exists, but component-level accountability and schema-versioned input-set semantics do not.

Elephant:

- This is an auditability delta, not a model-quality delta. It should live in rebuild-C6 receipts and tests, but it must not be treated as C6 acceptance, base recalibration, or proof that the four-layer gates are sound.

Physical landing:

```yaml
c6_contract_bundle_fingerprint_minimum:
  produce_in_rebuild_c6:
    - contract_bundle_fingerprint.schema_version
    - contract_bundle_fingerprint.bundle_hash
    - contract_bundle_fingerprint.component_digests
  component_digests:
    required:
      - semantic_function_contract_jsonl
      - state_cells_yaml
      - c6_bench_cases_jsonl
      - qwen_tool_call_format_yaml
      - d_domain_ir_map_json
  preserve_existing_per_run_fields:
    - prompt_hash
    - sampling_seed
    - tool_output_digest
    - contract_digest
    - model_artifact_digest
    - tokenizer_digest
    - lora_adapter_digest
  forbidden_bundle_inputs:
    - prompt_hash
    - sampling_seed
    - tool_output_digest
    - model_artifact_digest
    - tokenizer_digest
    - lora_adapter_digest
```

## Next Grill Question

## Q3.6 Decision: Readback Exclusion Is A Hard-Pass Basis Split, Not Readback Deletion

Decision: adopt `readback_excluded_from_model_hard_pass`, but only as an explicit scoring-basis split.

Current accepted C6 behavior still treats state/readback as a hard gate in the archived/current spec (`openspec/specs/vehicle-tool-bench/spec.md:71`, `:83-100`), and current runner appends `.readback` into `failureClasses` when readback is applicable and does not match (`Core/Bench/C6VehicleToolBench.swift:1167-1198`). The rebuild-C6 change text already points in the new direction: readback follows plan P, endpoint renderer owns the utterance, eval does not count readback into action hard-pass, and gold verification keeps readback validation (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:27`, `:65-77`; `tasks.md:23-25`; `design.md:35`).

So the delta is not "remove readback." It is: split **model hard-pass** from **renderer/readback evidence** in receipts and tests.

Minimum per-run/gate shape:

```yaml
gate_result:
  model_hard_pass_basis: tool_call_state_clarify_without_readback
  readback_excluded_from_model_hard_pass: true
  tool_call_set_match: true|false
  no_tool_false_positive_count: 0
  state_delta_match: true|false
  clarify_match: true|false
  hard_failed: true|false              # computed without readback
  failure_classes: []                  # model hard-failure classes; excludes readback when exclusion=true
  readback_applicable: true|false
  readback_match: true|false
  readback_evidence_source: c2_renderer_template|not_applicable
```

Gold verification split:

```yaml
verify_gold:
  readback_template_validity_gate: required_for_state_changing_gold
  readback_excluded_from_model_hard_pass: not_applicable
```

Rules:

1. Do not delete readback evidence. Keep `readback_match` and add `readback_applicable`, because `false` means different things for no-call non-applicable cases and state-changing readback failures.
2. Do not put `.readback` into model `failure_classes` when `readback_excluded_from_model_hard_pass=true`; otherwise `hard_failed = !failure_classes.isEmpty` still counts readback.
3. Keep readback in `verify-gold` for state-changing gold validity. If C2 cannot render the expected readback template, the gold candidate is invalid; that is a contract-data problem, not a model hard-pass failure.
4. Do not exempt clarify/refusal text evidence. Rejected or ambiguous no-call cases may still use `readback_assertion.contains` as deterministic text evidence (`openspec/specs/vehicle-tool-bench/spec.md:93-97`; `Core/Bench/C6VehicleToolBench.swift:1271-1285`). That text gate remains part of clarify/refusal hard-pass.
5. Do not make readback a judge score. Renderer/readback evidence is deterministic and receipt-visible; it is not a subjective judge wash.

Tiger:

- If `.readback` remains in `failure_classes`, the new marker is cosmetic: aggregate hard-pass still counts readback through `hard_failed`.
- If `readback_match=false` lacks `readback_applicable`, no-call non-applicable cases and failed state readback look identical. That recreates the no-call bucket ambiguity Q2.2 rejected.
- If `readback_assertion.contains` is globally ignored, refusal/safety/clarify text evidence can pass empty. That would weaken the safety and unsupported layers.

Paper-tiger:

- "Readback excluded from model hard-pass means readback is unimportant" is false. It remains required for gold data validity and renderer/release evidence; it is excluded only from model-quality hard-pass.

Elephant:

- This is the main Q3 place where the current accepted spec and the rebuild-C6 draft intentionally diverge. The proposal must call the migration out explicitly, or a future implementation can satisfy both by accident in neither direction: readback half-counted in code, half-described as renderer evidence in docs.

Physical landing:

```yaml
readback_plan_p_minimum:
  model_eval:
    add_fields:
      - model_hard_pass_basis
      - readback_excluded_from_model_hard_pass
      - readback_applicable
      - readback_evidence_source
    keep_fields:
      - readback_match
      - clarify_match
    hard_pass_excludes:
      - readback
    hard_pass_keeps:
      - tool_call_set_match
      - no_tool_false_positive_count
      - state_delta_match
      - clarify_match
      - refusal_text_evidence_when_asserted
  verify_gold:
    readback_template_validity_gate: keep
    c2_renderReadback_source: required_for_state_changing_gold
  forbidden:
    - deleting_readback_evidence
    - counting_readback_failure_in_model_failure_classes
    - treating_refusal_text_evidence_as_readback_renderer_output
    - moving_readback_to_subjective_judge_score
```

## Q3 Closeout

Q3 is now closed for pre-code discussion purposes.

Closed decisions:

1. Q3.1: C6 replay foundation is a **C6 Replay Fact Bundle** that reuses default-scope facts plus four deltas.
2. Q3.2: delta ownership is three-layer: shared taxonomy, apply/execution, and rebuild-C6 receipt/scoring.
3. Q3.3: apply diagnostics are `appliedWrites`, while `unexpectedMutationKeys` are C6-derived.
4. Q3.4: `write_kind=direct|dependency`, only after numeric direct, enum direct, and dependency writes all emit before/after evidence.
5. Q3.5: `contract_bundle_fingerprint` is a versioned component manifest, not a second opaque run/result hash.
6. Q3.6: readback exclusion is a model-hard-pass basis split, not readback deletion.

Q3 does not authorize Swift implementation, C6 acceptance, D-domain base recalibration, C5 training, golden-run, voice, endpoint readiness, or R-L17 closure. It is ready to be absorbed into the `rebuild-c6-four-layer-bench` OpenSpec carrier after the route gate allows construction work.

## Q4.1 Decision: OpenSpec Absorption Must Fix Stale Whole-Change Candidate Dependency

Question: when Q2/Q3 decisions are absorbed into `openspec/changes/rebuild-c6-four-layer-bench`, should the existing `retrain-c5-lora-d-domain` candidate dependency remain a precondition?

Decision: no. The correction is more precise than the first pass: the tasks already have a rough lane split; the stale topology is in the whole-change dependency declaration layer.

Live evidence:

- The current non-UIUE route says `rebuild-c6` precedes `retrain-c5` because validation must become trustworthy before training (`docs/project/phase0/non-uiue-pre-code-action-list-2026-06-24.md:18-21`, `:32`).
- The current rebuild-C6 proposal still says the change depends on `retrain-c5-lora-d-domain` for a candidate comparison (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:11`, `:84`).
- The current rebuild-C6 task list makes candidate availability a front precondition (`openspec/changes/rebuild-c6-four-layer-bench/tasks.md:9-12`).
- The current rebuild-C6 task structure already separates construction from comparison: §2 covers expected-tool migration, §3 covers four-layer gates and base-anchor design, and §4 covers base-vs-LoRA comparison (`openspec/changes/rebuild-c6-four-layer-bench/tasks.md:14-44`).
- §3.5.G2 already places D-domain base-anchor semantics in the construction lane while explicitly not authorizing recalibration (`openspec/changes/rebuild-c6-four-layer-bench/tasks.md:27`).
- The design is closer to the right split: it says C6 depends on `retrain-c5-lora-d-domain` only when a signed candidate is available for base-vs-LoRA comparison (`openspec/changes/rebuild-c6-four-layer-bench/design.md:7`), and also says no candidate comparison without a signed candidate (`:48`).

The hidden frame problem: `rebuild-c6` is overloaded. The executable task structure mostly distinguishes "construct the trusted C6 yardstick" from "compare a signed LoRA candidate against base", but the proposal/front-matter dependency text still describes the whole change as if it depends on the candidate. That stale declaration can override the correct §3/§4 structure in the next implementation session.

Correct dependency edges:

```yaml
rebuild_c6_open_spec_absorption:
  c6_construction_lane:
    unlocked_by:
      - route_deframing_verdict_signed
      - openspec_propose_acceptance
      - origin_main_reconfirmed
    must_not_depend_on:
      - retrain_c5_candidate
      - c6_acceptance_run
      - d_domain_base_recalibration
  candidate_comparison_lane:
    unlocked_by:
      - c6_construction_lane_complete
      - candidate_signoff_verdict_signed
      - signed_retrain_c5_candidate_available
    may_include:
      - base_vs_lora_same_harness_comparison
      - future_d_domain_base_anchor_after_authorization
```

Physical landing for the existing OpenSpec carrier:

1. Change `tasks.md` item `1.2 确认 retrain-c5-lora-d-domain candidate 可引用` from whole-change precondition to §4 `candidate_comparison` local precondition.
2. Rewrite `proposal.md:11` so the whole change does not depend on `retrain-c5-lora-d-domain`; only base-vs-LoRA comparison depends on a signed retrain-c5 candidate.
3. Rewrite `proposal.md:84` impact dependency to separate construction dependencies from comparison dependencies.
4. Rewrite `tasks.md:3` top comment so it does not state the whole change depends on `retrain-c5(candidate)`.
5. Preserve the existing §3/§4 task split and explicitly confirm that §3.5.G2 base-anchor design belongs to construction while any base recalibration run remains deferred/unauthorized.
6. Rewrite OpenSpec dependency wording so `rebuild-c6` construction depends on D-domain surface/default-scope/reconfirmed current repo state, while only candidate comparison depends on a signed `retrain-c5` candidate.
7. Split Success Criteria into:
   - construction criteria: spec/design/tasks filled, selectors/denominators/replay receipts defined, no execution authorization.
   - candidate comparison criteria: future only, requires signed candidate and explicit run authorization.
8. Keep the top DEFERRED/no-authorization banner, but do not let it hide the wrong dependency edge.

Tiger:

- If candidate availability stays in `tasks.md` front matter, the next session can either block C6 construction waiting for retrain, or worse, run retrain first to satisfy a false precondition. Both violate the accepted route.
- If only one of the four stale declarations is corrected (`tasks.md:3`, `tasks.md:12`, `proposal.md:11`, `proposal.md:84`), the documents will retain a split-brain topology.
- If D-domain base-anchor design is confused with D-domain base recalibration, construction can be falsely blocked on an unauthorized run.

Paper-tiger:

- Keeping candidate comparison in the rebuild-C6 carrier is not itself wrong. §4 is already the right local section, because C6 is the harness that will eventually compare base and signed LoRA. The mistake is making §4 candidate availability a precondition for §2/§3 construction.
- The fact that `design.md` already says "only when a signed candidate is available" reduces the fix surface; it does not remove the need to repair proposal/tasks, because implementers execute checklists before nuance.

Elephant:

- This is the same class of failure as Q2/Q3 fake absorption: a correct decision exists in one document and even partly in the task sections, but a stale whole-change dependency declaration creates the executable truth. For implementers, unchecked task topology beats prose intent. Therefore Q4 absorption must repair declaration topology across all four stale sites, not re-split lanes that already exist.

## Q4 Series Decisions

These Q4 decisions close the OpenSpec-absorption grill. They are route-control decisions for later documentation absorption. They do not modify the OpenSpec carrier yet, do not authorize Swift implementation, and do not authorize C6 acceptance, D-domain base recalibration, C5 training, golden-run, voice, endpoint readiness, or R-L17 closure.

| ID | Verdict | Decision | Physical landing |
|---|---|---|---|
| Q4.2 | ACCEPT + adjust | Distribute Q2/Q3 by decision type, not evenly across files. Runtime/replay invariants go to spec delta as SHALLs; tradeoffs go to `design.md`; verification checklists go to `tasks.md`; rejected options and paper trail stay in ledgers. | `proposal.md` gets route/scope/ordering; `design.md` gets ADs/tradeoffs; `tasks.md` gets checkable work; spec delta gets normative SHALLs; ledgers keep rationale and rejected/rejected-for-now options. |
| Q4.3 | ACCEPT + preserve supersession note | Rewrite the stale A2-era DEFERRED banner for the unlock-layer route, while keeping no-authorization boundaries. | New banner should state construction can be documented/proposed after route signoff; C6 acceptance, base recalibration, C5 training, golden-run, voice, and R-L17 closure remain deferred. Add a one-line supersession note for the 2026-06-23 all-§3-DEFERRED banner to prevent stale-banner override. |
| Q4.4 | ACCEPT + define documentation absorption | Documentation absorption can be prepared before implementation gates; apply/implementation still requires route gate and accepted proposal. | Allowed documentation paths: `proposal.md`, `design.md`, `tasks.md`, `specs/*.md`, ledgers. Forbidden paths in documentation absorption: `Core/Bench/**.swift`, `contracts/c6-bench-cases.jsonl`, `contracts/qwen-tool-call-format.yaml`, model/data artifacts. Allowed validation: OpenSpec validation and `git diff --check` only. |
| Q4.5 | ACCEPT + require one SSOT name | `behavior_class` cannot coexist indefinitely with `C6Bucket`, C5 data-count labels, or apply no-effect labels as separate SSOT names. | First construction task must include SSOT naming decision across C5 `data_class_observed_count`, C6 `C6Bucket` / selector denominators, and apply `no_effect_reason`: either rename `C6Bucket` to `BehaviorClass`, or leave `C6Bucket` as deprecated/typealias/mapped legacy with a deletion window. No selectors, thresholds, active anchors, or apply no-effect labels before this reconciliation. |
| Q4.6 | ACCEPT + one SHALL group | Readback plan P should be one coherent spec requirement, not four scattered SHALLs. | Spec delta SHALL state model hard-pass must not include readback; verify-gold must keep C2 renderer readback validity; clarify/refusal text evidence still counts when asserted. Receipt-schema fields include `model_hard_pass_basis`, `readback_applicable`, `readback_match`, and `readback_excluded_from_model_hard_pass`. |
| Q4.7 | ACCEPT + make versioned manifest concrete | `contract_bundle_fingerprint` must be a versioned component manifest, not raw byte concatenation or a second opaque hash. | Manifest shape: ordered list of `{component_id, version, content_digest}`; fixed `component_id` enum includes C1 contract, C2 renderer/state cells, C6 cases, Qwen tool format, and D-domain IR map; `fingerprint = sha256(canonicalize(manifest))`; exclude prompts, outputs, seeds, model artifacts. |
| Q4.8 | ACCEPT + boundary correction | `appliedWrites` producer work belongs to apply/execution, not C6 implementation. Rebuild-C6 may reference it as an upstream dependency and consume it, but must not own the producer implementation task. | `design.md` records producer/consumer boundary. `tasks.md` may include a C6 consumer task and an external dependency/checkpoint, but not "implement `ToolContractStateApplier.appliedWrites`" as rebuild-C6-owned work. Producer lands in a future apply-layer carrier or equivalent upstream contract. |
| Q4.9 | ACCEPT + whitelist verify-gold shape-only | First rebuild-C6 closeout can use local documentation/static proof only. `verify-gold` is allowed only as shape/contract replay verification, not model-quality evaluation. | Allowed proof classes: `local` OpenSpec validation, `local_static_teardown`, static/receipt review, and `archive-check verify-gold` only if no model is run and it checks contract/shape/D-domain expected-tool validity. Forbidden: C6 acceptance, model run, base recalibration, endpoint, mobile/true-device, demo-golden, V-PASS. |
| Q4.10 | ACCEPT + name bypass-guard placeholder | R-L17 route/candidate verdicts enter tasks as manual signoff checkpoints, not runtime enums. The future lightweight guard needs a named placeholder to avoid being forgotten. | Add manual signoff task references to R7 fields. Do not add C24 enums. Reserve placeholder change name `add-route-verdict-verify-guard` for the future make-verify bypass guard; do not implement it in this lane. |
| Q4.11 | ACCEPT + fixed reconfirm symbol list | Implementation must reconfirm the target worktree and load-bearing APIs because Q3 file:lines were from `a9ce7cf` while `origin/main` had later UIUE commits. | Before implementation: record branch/HEAD/origin-main, then `rg` current HEAD for `ScopeOrigin`, `ScopeResolution.keys`, `ScopeResolution.resolvedScopes`, `C2ScopeResolver.scopedKey()`, and `ToolContractStateApplier.applyWithEvidence`. If any symbol moved/renamed/disappeared, halt and re-grill. |
| Q4.12 | ACCEPT + forbid third carrier | Do not spawn a separate `candidate-comparison` OpenSpec change. | `rebuild-c6` construction remains in `rebuild-c6-four-layer-bench`; training data/LR/LoRA choices stay in `retrain-c5-lora-d-domain`; base-vs-LoRA comparison remains §4 of rebuild-C6 and is gated by signed candidate plus explicit run authorization. |
| Q4.13 | ACCEPT + banned-name list | Historical generic-frame base evidence and future D-domain base semantics must not share a vague name. | Use `historical_base_anchor` for old generic-frame evidence and `future_d_domain_base_anchor_design` for deferred semantics. Ban bare or misleading names: `active_base_anchor`, `current_d_domain_base_anchor`, bare `base_anchor`, and bare `d_domain_base_anchor` unless prefixed by historical/future semantics. |
| Q4.14 | ACCEPT + strict validation whitelist | OpenSpec absorption validation must not accidentally trigger paper tooling, Swift builds, model loads, training, or bench runs. | Allowed for OpenSpec absorption: `openspec validate rebuild-c6-four-layer-bench --strict`, `openspec validate --all --strict`, and `git diff --check`. Forbidden here: `python Tools/**` scripts including `validate_gate_packet.py`, Swift build/test, C6 bench, model eval, training, golden-run, and `make verify` unless separately proven pure text/static for this lane. This does not invalidate paper-packet schema validation in the paper ledger; it only keeps OpenSpec absorption proof clean. |
| Q4.15 | ACCEPT + row-level retirement | Ledgers retire row by row, not as whole files. | Each Q2.x/Q3.x/Q4.x row gets `superseded_by:` or `rejected_in:` pointing to proposal/design/tasks/spec line or AD. Whole-ledger retirement is allowed only after every row has an absorption or rejection pointer. Until then, ledgers remain route-control inputs, not executable contracts. |

## Row-Level Absorption Pointers (Q4.15)

These pointers satisfy Q4.15 for Q3/Q4 rows. They do not retire this ledger as a whole until human review accepts that every row has a durable absorption or rejection pointer.

### Q3 Pointers

| Row | Disposition | Pointer |
|---|---|---|
| Q3.1 C6 Replay Foundation Reuses PR4 Facts Plus Four Deltas | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#What-Changes`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-007-Behavior-class-taxonomy-is-shared-across-C5-C6-and-apply`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-008-Readback-plan-P-splits-renderer-evidence-from-model-hard-pass`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-009-Contract-bundle-fingerprint-is-a-versioned-component-manifest`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-010-Apply-diagnostics-are-upstream-facts-not-C6-owned-runtime-logic` |
| Q3.2 Delta Ownership Is Three-Layer, Not Default-Scope vs Rebuild-C6 | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-007-Behavior-class-taxonomy-is-shared-across-C5-C6-and-apply`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-010-Apply-diagnostics-are-upstream-facts-not-C6-owned-runtime-logic`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction` |
| Q3.3 Apply Diagnostics Are Applied Writes, Not A Planner | Absorbed as C6 consumer boundary; producer implementation remains upstream apply/execution work. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-010-Apply-diagnostics-are-upstream-facts-not-C6-owned-runtime-logic`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Replay-facts-SHALL-consume-apply-layer-applied-writes`; `rejected_in: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-010-Apply-diagnostics-are-upstream-facts-not-C6-owned-runtime-logic` for full planner/runtime ownership inside C6 |
| Q3.4 `write_kind=direct|dependency`, But Evidence Coverage Comes First | Absorbed as boundary and dependency; producer implementation remains upstream apply/execution work. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-010-Apply-diagnostics-are-upstream-facts-not-C6-owned-runtime-logic`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Replay-facts-SHALL-consume-apply-layer-applied-writes`; `rejected_in: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-010-Apply-diagnostics-are-upstream-facts-not-C6-owned-runtime-logic` for `noop` as write kind or C6-owned producer task |
| Q3.5 `contract_bundle_fingerprint` Is A Component Manifest, Not A Second Opaque Hash | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-009-Contract-bundle-fingerprint-is-a-versioned-component-manifest`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Replay-fingerprint-SHALL-be-recorded-per-eval-run` |
| Q3.6 Readback Exclusion Is A Hard-Pass Basis Split, Not Readback Deletion | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-008-Readback-plan-P-splits-renderer-evidence-from-model-hard-pass`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Readback-gate-SHALL-reuse-C2-readback-templates`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Four-deterministic-hard-gates-SHALL-decide-release-blocking` |

### Q4 Pointers

| Row | Disposition | Pointer |
|---|---|---|
| Q4.1 Stale Whole-Change Candidate Dependency | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#Route-And-Dependency-Topology`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#4-Candidate-Comparison-Lane`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Base-Qwen3-1-7B-baseline-SHALL-run-before-LoRA-diff` |
| Q4.2 Decision Distribution By File Type | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#Route-And-Dependency-Topology`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#Architecture-Decisions`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#0-Documentation-Absorption-Closeout`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#MODIFIED-Requirements` |
| Q4.3 Supersession Banner | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#top`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#top`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#top` |
| Q4.4 Documentation Absorption Boundary | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-011-Documentation-absorption-uses-local-static-proof-only`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#0-Documentation-Absorption-Closeout`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#5-Red-Lines`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Documentation-absorption-SHALL-keep-proof-class-boundaries-explicit` |
| Q4.5 BehaviorClass SSOT Name | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-007-Behavior-class-taxonomy-is-shared-across-C5-C6-and-apply`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Behavior-class-taxonomy-SHALL-be-shared-across-C5-C6-and-apply` |
| Q4.6 Readback Plan P SHALL Group | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-008-Readback-plan-P-splits-renderer-evidence-from-model-hard-pass`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Readback-gate-SHALL-reuse-C2-readback-templates` |
| Q4.7 Contract Bundle Manifest | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-009-Contract-bundle-fingerprint-is-a-versioned-component-manifest`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Replay-fingerprint-SHALL-be-recorded-per-eval-run` |
| Q4.8 AppliedWrites Producer/Consumer Boundary | Absorbed as boundary; producer implementation remains upstream. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-010-Apply-diagnostics-are-upstream-facts-not-C6-owned-runtime-logic`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Replay-facts-SHALL-consume-apply-layer-applied-writes`; `rejected_in: openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction` for C6-owned producer implementation |
| Q4.9 Proof Class / Verify-Gold Shape Only | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-011-Documentation-absorption-uses-local-static-proof-only`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-C6-SHALL-provide-deterministic-gold-self-verification`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Documentation-absorption-SHALL-keep-proof-class-boundaries-explicit` |
| Q4.10 R-L17 Manual Signoff / Bypass Placeholder | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-005-R-L17-is-a-manual-route-candidate-governance-gate`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#1-Construction-Preconditions`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`; `rejected_in: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-005-R-L17-is-a-manual-route-candidate-governance-gate` for runtime enum treatment |
| Q4.11 Baseline / Load-Bearing API Reconfirm | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-012-Implementation-must-reconfirm-baseline-and-load-bearing-APIs`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#1-Construction-Preconditions` |
| Q4.12 No Third Candidate-Comparison Carrier | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#Route-And-Dependency-Topology`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#4-Candidate-Comparison-Lane`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Base-Qwen3-1-7B-baseline-SHALL-run-before-LoRA-diff` |
| Q4.13 Base-Anchor Naming | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#What-Changes`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-002-D-domain-base-anchor-is-comparison-design-not-permission-to-run`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction` |
| Q4.14 Validation Whitelist | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-011-Documentation-absorption-uses-local-static-proof-only`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#0-Documentation-Absorption-Closeout`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Documentation-absorption-SHALL-keep-proof-class-boundaries-explicit` |
| Q4.15 Row-Level Retirement | Absorbed for Q3/Q4 by this section and for Q2 by `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md#Row-Level-Absorption-Pointers-Q4-15`. | `superseded_by: docs/project/phase0/rebuild-c6-precode-grill-ledger-2026-06-24.md#Row-Level-Absorption-Pointers-Q4-15`, `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md#Row-Level-Absorption-Pointers-Q4-15` |

### Human Review Result (2026-06-24)

Status: `APPROVED_FOR_DOCUMENTATION_CLOSEOUT`.

Human review checked the six review surfaces requested for Q4.15 closeout:

1. Paper ledger Q2.1-Q2.5 row-level pointers: `PASS`. Q2.1/Q2.4 retain `retrain-c5-lora-d-domain` ownership where appropriate and do not fake full rebuild-C6 absorption.
2. Rebuild-C6 ledger Q3/Q4 row-level pointers: `PASS`. Q3.1-Q3.6 and Q4.1-Q4.15 all have durable absorption or rejection pointers, while the ledger is not whole-file retired.
3. `proposal.md` route topology: `PASS`. C6 construction is independent of a retrain-C5 candidate; candidate comparison is §4-local and requires signed candidate plus explicit run authorization.
4. `design.md` AD-C6-007/010/011: `PASS`. BehaviorClass covers C5/C6/apply; apply diagnostics remain apply/execution-produced and C6-consumed; `local_static_teardown` remains static proof with a narrow validation whitelist.
5. `tasks.md` §0/§5: `PASS`. Documentation closeout is limited to OpenSpec validation plus `git diff --check`; training, C6 acceptance, base recalibration, golden-run, voice, endpoint/model-quality eval, UIUE merge claim, and R-L17 closure remain forbidden.
6. Spec delta behavior taxonomy requirement: `PASS`. `Behavior-class taxonomy SHALL be shared across C5, C6, and apply` is normative and includes `SHALL NOT` against private C6 no-effect enum / unreconciled `C6Bucket`.

Non-blocking mild issues recorded by human review:

| ID | Issue | Disposition |
|---|---|---|
| M1 | `***` markdown separators in `proposal.md` around future criteria render as horizontal rules. | Resolved in current file state: no `***` separators remain in `openspec/changes/rebuild-c6-four-layer-bench/proposal.md`. |
| M2 | Q4.5 SSOT naming appears as construction task §3.4 rather than §1 precondition. | Resolved by `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#1-Construction-Preconditions` item 1.5, which gates selector/threshold/anchor/apply no-effect freeze on the BehaviorClass SSOT naming/reconciliation task. |
| M3 | Future `tool-surface-retrieval-spike` carrier does not exist for Q2.5 spike table. | Non-blocking because Q2.5 row rejects current rebuild-C6 construction ownership; add owner when a spike carrier is proposed. |

R-L17 remains `pending` / `unsigned`. This human review approves documentation absorption closeout only; it does not close route deframing, candidate signoff, C6 acceptance, training, golden-run, voice, endpoint readiness, UIUE merge, or V/S/U-PASS.

### Q4 Cross-Cutting Corrections

1. Do not create third names/carriers/anchors: no third SSOT name for behavior class, no standalone candidate-comparison change, no vague third base-anchor term.
2. Do not put apply-layer producer tasks into rebuild-C6. Rebuild-C6 consumes `appliedWrites`; apply/execution produces them.
3. Give the future R-L17 bypass guard a searchable placeholder: `add-route-verdict-verify-guard`, but do not implement it now.
4. Treat paper `local_static_teardown` as static evidence only. Teardown proof and packet schema validation can support absorption design, but they are not executed validation, C6 acceptance, or model-quality evidence.

### Q4 Closeout

Q4 is closed for pre-code discussion purposes.

Next artifact: a documentation-only OpenSpec absorption edit to `openspec/changes/rebuild-c6-four-layer-bench` that applies Q4.1-Q4.15. That edit must stay within documentation paths, keep the validation whitelist above, and must not run or imply C6 acceptance, D-domain base recalibration, C5 training, golden-run, voice, endpoint readiness, or R-L17 closure.
