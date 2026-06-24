---
status: active_discussion_ledger
artifact_kind: paper_to_skill_gate_absorption_ledger
authority: discussion_route_control_not_contract
created_at: 2026-06-24
retire_trigger: "Retire after the accepted rebuild-c6 and retrain-c5 OpenSpec carriers absorb or explicitly reject these paper-to-skill-gate decisions."
expires: "2026-07-15"
---

# Paper-To-Skill-Gate Absorption Ledger

This ledger records grill decisions for absorbing the 8 legacy `Tools/paper-to-skill-gate` packets into later `rebuild-c6`, `retrain-c5`, and spike carriers.

It is not training authorization, not C6 acceptance authorization, not golden-run authorization, not voice work, and not R-L17 closure.

Validation status:

```bash
python3 Tools/paper-to-skill-gate/scripts/validate_gate_packet.py \
  Tools/paper-to-skill-gate/trial-runs/*.gate.json
```

Result on 2026-06-24: all 8 packet JSON files passed schema validation. This proves packet shape only. It does not prove paper claims, official repo claims, model quality, train readiness, C6 readiness, or product readiness.

## Q2 Series Closeout Boundary

Status: Q2.1-Q2.5 are closed for now as discussion-route decisions.

These decisions are deferred absorption design for later OpenSpec carriers. They are not authorization to run `rebuild-c6`, `retrain-c5`, C6 acceptance, golden-run, model training, voice work, or R-L17 closure.

They are also not the primary 0/34 remedy. The primary remedy remains the Phase 0 P0 gate set:

- R-L09 sample observability.
- R-L02 loss-mask / masking physical proof.
- R-L03 byte parity.
- R-L05 mid-training behavior gate.
- R-L04 four-layer C6 gate.
- R-L07 data recipe.
- R-L17 human deframing / review.
- R-L16 governance matrix.

Paper absorption strengthens later data quality, leakage control, behavior labels, prompt-surface experiments, LoRA-method discipline, and evaluation rigor. It must not be framed as "enough paper absorption fixes 0/34."

## Q2.1 Decision: Zero-Drop Algorithm Landing

Decision: adopt **zero-drop, strength-tiered absorption**.

Meaning:

- Every packet must have at least one checkable MAformac landing.
- A checkable landing must carry the algorithm's load-bearing parameter, range, prerequisite gate, or failure condition.
- A bare field name is not enough.
- Absorbing a paper into design does not authorize executing training, C6 acceptance, C6 base recalibration, golden-run, voice, or readiness claims.

Physical landing tiers:

| Tier | Meaning | Candidate carriers |
|---|---|---|
| `hard_gate` | Fail-closed gate before quality claims. Must read actual artifacts, not self-reported metadata. | `rebuild-c6`, `retrain-c5`, future `make verify` checks |
| `receipt_field` | Required evidence field. Must include range/algorithm semantics where applicable. | C5/C6 receipts and OpenSpec tasks |
| `spike` | Contained experiment before runtime/training adoption. Must have prereq gates and stop conditions. | `tool-surface-retrieval-spike`, future prompt-surface/internalization spikes |
| `teaching_note` | Domain or design checklist that informs later proposals but does not become a gate. | Research/design notes |

## Q2.1 HIGH Constraints

### HIGH-1: Hard Gates Must Be Value-In-Source

Hard gates must inspect actual value sources, not metadata written by the same generator being checked.

Examples:

- A no-call/refusal gate must compute from the actual available tool list and label outcome, not from a `no_call_target_present` metadata claim.
- A leakage gate must consume re-judged `candidate_parent_semantic_id`, not only inherited seed IDs.
- A C6 anti-coincidence gate must use per-case all-runs-pass or equivalent enforced variance logic, not only pooled `hardFailures == 0`.
- Any high-stakes gate needs an independent grader or reviewer path plus sign-or-block semantics before quality claims.

Tiger addressed: 0/34-style self-reading gates can become the eleventh fake-green pit.

### HIGH-2: Receipt Fields Must Carry Algorithm Constraints

Receipt fields must encode the useful algorithm, not just the vocabulary.

Required constraints:

- `negative_ratio` / `clarify_ratio` / `refusal_ratio` must carry the working hypothesis: start near 15-20% total negative/clarify/refusal pressure and run a bounded ratio spike before promoting a production recipe. Do not silently hard-code 24%.
- `lr_grid` must encode LR-first ordering: tune vanilla LoRA around the stable `1e-4` anchor before comparing rank changes or PEFT variants.
- `semantic_overlap_receipt` must name an embedding or semantic judge strategy before it can block or clear leakage. A placeholder field without model/threshold/review-band ownership is not an absorption.
- `source_snapshot_digest` must bind data rows to a generated tool catalog or semantic contract snapshot before they become train-eligible.

Tiger addressed: "checkable landing" can degrade into a field-name checklist while the algorithm's load-bearing interval is lost.

### HIGH-3: Spike Items Need Prerequisite Gates

Spike does not mean "safe to try anything." Each spike has a prerequisite gate:

| Spike | Required prereq gate | Reason |
|---|---|---|
| Description-free/internalized tool knowledge | Retention/non-regression probe, plus explicit compatibility check with D-domain named tools. | Prompt compression is attractive, but may fight A2's model-visible D-domain surface and may degrade general capability. |
| DoRA rank8 | Vanilla LoRA LR sweep reaches a credible local peak first. | Otherwise DoRA can look better only because vanilla LR was mistuned. |
| TinyAgent-style ToolRAG | Retrieved subset must contain the gold tool for must-pass cases and report dangerous distractor rate. | If retrieval misses the gold D-domain tool, the model cannot recover downstream. |

Tiger addressed: spikes can add new failure surfaces to a freshly repaired C5/C6 route.

## Q2.2 Decision: When2Call Domain Adaptation

Decision: use **5 internal behavior classes / 4 external C6 layers**, but the fifth internal class is `already_state_noop`, not `direct_no_call`.

Rationale:

- When2Call's verified upstream labels include `direct`, `tool_call`, `request_for_info`, and `cannot_answer` (`Tools/paper-to-skill-gate/trial-runs/when2call-tool-decision-p0.md:26-35`).
- MAformac is a vehicle-control demo, not a general chat assistant. There is no first-class "answer directly without tool/control semantics" path for in-scope cockpit commands.
- Treating `direct_no_call` as valid would create a legal-looking bucket for `toolCalls=[]` collapse, reproducing the fake-green shape that the C6 rebuild is meant to prevent.
- MAformac already has `already_state` as an accepted seed in C06, explicitly not equivalent to unsupported, safety refusal, success-with-state-delta, or clarify (`docs/project/phase0/c06-runtime-outcome-enum-skeleton.schema.yaml:37-45`).
- C06 also separates `already_state_readback` as renderer-owned, not model-owned state truth (`docs/project/phase0/c06-runtime-outcome-enum-skeleton.schema.yaml:56-63`).
- D10 accepted `already_state` as an independent fifth state class with default ownership in C3 + readback renderer (`docs/project/phase0/phase0-d1-d10-user-decision-record.md:29`).
- home-llm's refusal generator has a concrete `reason_type == "already_state"` branch (`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/home-llm/data/generate_data.py:563-590`).

Internal `behavior_class` values:

```yaml
behavior_class:
  - tool_call
  - clarify_missing_slot
  - refusal_no_available_tool
  - refusal_safety_or_policy
  - already_state_noop
```

Mapping:

| Internal class | Paper/domain source | External C6 layer |
|---|---|---|
| `tool_call` | When2Call `tool_call` | `golden` / `fuzz`, depending on case family |
| `clarify_missing_slot` | When2Call `request_for_info` / missing required parameter | `unsupported`-adjacent C6 behavior, counted in clarify denominator |
| `refusal_no_available_tool` | Split from When2Call `cannot_answer` | `unsupported` |
| `refusal_safety_or_policy` | Split from When2Call `cannot_answer` through MAformac risk policy | `safety` |
| `already_state_noop` | MAformac C06/D10 + home-llm `already_state` evidence | `golden` state-noop behavior, renderer-owned readback |

Ratio rule:

- Count all five buckets independently.
- `clarify_missing_slot` must not be folded into refusal ratio.
- `already_state_noop` must not be folded into refusal ratio, unsupported ratio, or safety ratio.
- Correct no-op, incorrect no-call collapse, unsupported refusal, and safety refusal must remain distinguishable even if their raw model/tool-call surface can all look like `toolCalls=[]`.

Boundary:

- `direct` from When2Call is dropped for in-scope MAformac cockpit-control behavior.
- If future out-of-scope assistant/chat behavior is introduced, it must use a new OpenSpec carrier and cannot backfill this C5/C6 behavior class.

## Q2.3 Decision: Freeze Denominator Logic, Not Mechanical Selectors Yet

Decision: freeze the **C6 denominator logic** now, but do not freeze executable selectors, active thresholds, denominator counts, or active base anchors until `C6Bucket`, Q2.2 `behavior_class`, and the external four-layer report are reconciled. Q3 later extends this same SSOT line across C5 `data_class_observed_count` and apply/execution `no_effect_reason`; do not treat this Q2.3 C6-local wording as the final taxonomy boundary.

What can be frozen now:

- Four-layer gate reports must be split by case semantics, not by one aggregate pass rate.
- Full 57-case or full 562-intent denominators are forbidden for action hard-pass.
- Old generic-frame `10/23` is historical only, not the active D-domain base.
- `must_pass=true` is not a golden/action denominator by itself because safety, clarify, unsupported, and already-state cases can also be must-pass.
- `expect_no_call=true` is not a unified success bucket because it can represent correct no-op, unsupported refusal, safety refusal, clarification, or erroneous model collapse.
- Readback remains renderer/informational for this gate; it must not enter the model hard-pass denominator.

What cannot be frozen yet:

- Executable selectors that depend on `behavior_class`, because `C6BenchCase` has no `behavior_class` field today (`Core/Bench/C6VehicleToolBench.swift:158-185`).
- Active threshold values, because D-domain base recalibration has not run.
- Active base anchors, because the old `10/23` anchor belongs to the generic-frame surface.
- Any selector that lets `C6Bucket.noCall` or `C6Bucket.refusal` remain a coarse substitute for Q2.2 behavior classes.

Current field reality:

- Existing `C6Bucket` values are `action`, `no_call`, `state`, `clarify`, `refusal`, and `coverage` (`Core/Bench/C6VehicleToolBench.swift:25-32`).
- Existing C6 case fields include `expect_no_call`, `expected_state_delta`, `clarify_tag`, `failure_class`, `tags.bucket`, and `source_refs.risk_rule_ids` (`Core/Bench/C6VehicleToolBench.swift:158-185`).
- Existing negative counting still uses broad `expectNoCall || bucket == noCall || bucket == refusal` logic (`Core/Bench/C6VehicleToolBench.swift:324`), so it cannot be the future four-layer selector without reconciliation.

Three-way reconciliation required before mechanical selector implementation:

| External layer | Q2.2 `behavior_class` | Existing `C6Bucket` reconciliation | Field status |
|---|---|---|---|
| `golden` | `tool_call` | `action` + applicable `state` cases | Existing fields can identify candidates through `expect_no_call=false`, tool calls, state delta, and `failure_class=none`. |
| `golden` | `already_state_noop` | No current bucket; cannot infer from `no_call`. | Requires `behavior_class` or an equivalent explicit marker. |
| `demo_fuzz` | Held-out variants across behavior classes | Usually `coverage`, but must not mean "all coverage rows". | Requires family/template split proof before use as fuzz denominator. |
| `unsupported` | `refusal_no_available_tool` | Split out of broad `refusal` / `no_call`. | Requires re-labeling or `behavior_class`. |
| `safety` | `refusal_safety_or_policy` | Split out of broad `refusal` with `risk_rule_ids` nonempty. | `risk_rule_ids` exists, but broad refusal bucket must be split. |
| separate denominator | `clarify_missing_slot` | `clarify` | `clarify_tag` exists; still must not be folded into refusal. |
| none | erroneous collapse | Can be hidden inside `no_call` today. | Must be excluded from every correct behavior denominator. |

Rebuild-C6 first task:

```yaml
pre_selector_gate:
  id: c6_bucket_behavior_class_four_layer_reconcile
  required_before:
    - executable_denominator_selectors
    - active_thresholds
    - active_base_anchor
  checks:
    - C6Bucket.no_call is not treated as already_state_noop
    - C6Bucket.refusal is split into unsupported and safety through behavior_class or equivalent source fields
    - expect_no_call is never a success denominator alone
    - demo_fuzz rows require held-out family/template proof
    - erroneous empty toolCalls collapse maps to failure, not to any correct no-call class
```

Frame check:

This is the same SSOT line as Q2.2. If `C6Bucket`, `behavior_class`, and external four-layer reports each classify cases independently, C6 will recreate the 0/34 failure shape: multiple plausible-looking fields, no single trusted behavior source.

Post-Q3 extension: the final behavior-class SSOT scope is broader than this Q2.3 table. The same behavior source must also feed C5 `data_class_observed_count` and apply/execution `no_effect_reason`; otherwise C5 data ratios, C6 denominators, and apply no-effect reasoning can still drift into a three-way SSOT split.

## Q2.4 Decision: C5 Data Receipt Needs Derivation Rules, Not Field Sprawl

Decision: Q2.4 is limited to data-receipt design. It does not authorize training, adapter promotion, C6 acceptance, LR/rank sweeps, or semantic embedding runs.

Core correction:

The C5 data receipt schema is already fairly complete. The fake-absorption risk is not primarily missing fields; it is load-bearing fields being populated from metadata claims, caller assertions, or proxy flags instead of value-in-source derivations.

Existing fields already present:

| Existing field / concept | Code anchor | Status |
|---|---|---|
| `candidate_parent_semantic_id` | `Core/Bench/C5DataGate.swift:9`, `:25`, `:92` | Present, but current overlap logic still falls back through `overlapParentSemanticID`. |
| `scenario_family_id` fallback into parent identity | `Core/Bench/C5DataGate.swift:27`, `:89-92` | Present as input fallback. |
| `source_snapshot_digest` | `Core/Bench/C5DataGate.swift:137-153`, `:160-162`, `:330-336` | Present in run context and receipt. |
| `receipt_version` | `Core/Bench/C5DataGate.swift:156-181`, `:330-332` | Present. |
| `masking` flags: `function_name`, `argument_name`, `argument_value`, `train_on_turn` | `Core/Bench/C5DataGate.swift:111-135`, `:207-218` | Present, but must not be trusted as proof of real mask/augmentation execution. |
| `masking_coverage` summary | `Core/Bench/C5DataGate.swift:310-315`, `:382-386`; `Tools/C5TrainingCLI/main.swift:254` | Present, currently derived as any-candidate flag coverage. |
| `max_variants_per_seed` and candidate diversity fields | `Core/Training/C5LoRATraining.swift:625-648`; `Tools/C5TrainingCLI/main.swift:245-253` | Present in training receipt layer, not a reason to add more data-gate fields. |
| parent overlap / format / redaction / quarantine summary | `Core/Bench/C5DataGate.swift:156-205`, `:330-349` | Present. |

Minimum delta: five value-in-source derivations.

| Delta | Prevents | Required derivation rule |
|---|---|---|
| `no_call_target_present` | 446-style false deletion where metadata says the target tool was removed but the actual tool list still contains it. | Compute from the sample's actual available tools and target label. Do not read `removedToolID` or equivalent generator metadata as truth. |
| `masking_coverage` physical proof | Masking flags exist but the mechanism is not actually applied. | Verify real tokenizer/loss-mask or concrete data-augmentation evidence. Do not flip pass from `C5MaskingFlags` alone. |
| `data_class_observed_count` | "Four behavior classes" or "natural Chinese coverage" is claimed, but the actual train rows do not contain the classes. | Count actual samples by Q2.2 `behavior_class`; report all five buckets independently and check negative/clarify/refusal pressure against the 15-20% starting hypothesis before any production recipe. |
| `tool_surface_kind` | Train rows use generic/frame surface while eval/runtime use D-domain named tools. | Derive from actual `tool_call.name` values and/or rendered tool surface digest. Do not read a declared surface label as proof. |
| `leakage_receipt` derivation rule | `candidate_parent_semantic_id` exists but gate relies on inherited exact-ID overlap and can pass semantic drift. | Gate must consume re-judged candidate semantic identity before inherited parent identity; require augment-after-split/family partition. If embedding model or semantic judge is not selected, mark the semantic scan `deferred`, not pass. |

Meta-rule:

```yaml
c5_data_receipt_value_in_source:
  required: true
  failure_mode: "calculation_missing_or_conflicting"
  result: "fail_closed_exit_65_or_blocked"
  forbidden:
    - self_reported_metadata_as_gate_truth
    - proxy_boolean_flags_as_physical_proof
    - missing_derivation_defaults_to_pass
  review:
    - independent_grader_or_human_sign_or_block_for_high_stakes_claims
```

Scope out for Q2.4:

- `lr_grid`, `rank_grid`, seed policy, and best-checkpoint policy belong to training-method or training receipt design, not this minimum data receipt.
- DPO, PEFT variants, and DoRA are outside Q2.4.
- Semantic embedding scan execution is deferred until an embedding/judge strategy is selected. The receipt may reserve the slot, but it must not greenlight it.
- Do not add theory-complete but 0/34-unanchored metrics such as perplexity, token histograms, or broad diversity dashboards into the minimum set.

Frame check:

Q2.4 is the data-side counterpart of Q2.2 and Q2.3. C5 sample class counts must use the same `behavior_class` source as C6 denominator reconciliation; otherwise C5 data ratio and C6 evaluation denominators will drift into another dual-SSOT failure.

## Q2.5 Decision: Spike Unlock Is Not A Linear Queue

Decision: do not use a linear `ToolRAG -> description-free -> DoRA` unlock queue.

The three candidates are different kinds of work:

- ToolRAG is an optional offline retrieval spike.
- Description-free/internalized catalog is a demo-after prompt-surface and training-paradigm spike.
- DoRA rank8 is a conditional escape hatch, not an active spike to pre-unlock.

Evaluation against the three criteria:

| Candidate | Minimal and reversible | Serves C6/C5 | D-domain surface impact | Route |
|---|---|---|---|---|
| ToolRAG | High: offline subset retrieval can be tested without changing runtime or prompt surface. | Medium: valuable for future 562-tool scaling, less urgent for current 10-family demo. | Low disruption: retrieves over D-domain named tools instead of replacing them. | Optional first spike, after P0 gates, not urgent. |
| Description-free/internalized catalog | Low: requires training and has no code-confirmed official repo in the packet. | Medium: attractive prompt compression, but must prove tool accuracy and retention. | High disruption: challenges A2's model-visible D-domain named-tool surface. | Demo-after, with hard prerequisites. |
| DoRA rank8 | Medium: mlx-lm path can support it and MAformac already records `dora_rank8_secondary`, but it still requires training/eval. | Weak by default: current evidence says vanilla LoRA after LR tuning remains the baseline; DoRA is only an escape hatch. | Orthogonal to D-domain surface. | Conditional C16 escape hatch, removed from active spike ordering. |

ToolRAG decision:

- It may be the first spike if a spike is needed, because TinyAgent's packet has a concrete ToolRAG insertion point: retrieve a small D-domain subset before model call and record gold-tool miss / dangerous-distractor rates (`Tools/paper-to-skill-gate/trial-runs/tinyagent-function-calling-at-the-edge.md:42-67`).
- It must remain offline and optional until an accepted OpenSpec carrier exists.
- It must not alter rendered D-domain tools, C3 execution, model-visible prompt surface, C5 training data, or C6 JSONL during this ledger phase.
- Unlock condition: report gold-tool coverage for must-pass cases, false-negative rate, dangerous-distractor rate, and parser/tool-name miss class.
- Stop condition: any gold-tool miss on must-pass retrieval rows blocks downstream model-quality claims for the retrieved-subset path.

DoRA rank8 decision:

- Remove DoRA from "which spike first" ordering.
- Treat it as a C16-style conditional escape hatch only.
- Reopen it only after diagnosis shows an undercapacity signature: held-out probe train and validation both low, plus loss plateau.
- Before DoRA can be tried, exclude surface mismatch, byte-parity mismatch, mid-gate defects, and masking/data-receipt defects.
- Vanilla LoRA must be tuned around the stable LR anchor first; otherwise DoRA can win only because the baseline was mistuned.
- Current code evidence supports "escape hatch recorded, not active": `rank16Mainline` uses `fineTuneType: "lora"`, `learningRate: 0.0001`, and records `secondaryExperiments: ["rank32_confirmation", "dora_rank8_secondary"]` (`Core/Training/C5LoRATraining.swift:1261-1285`).

Description-free/internalized decision:

- Defer until after the demo-critical P0 gates and after the current D-domain surface is stable.
- Before any training, run a paper/design A/B compatibility review: can description-free internalization coexist with A2 D-domain named tools, or does it erase the very surface that C5/C6 are trying to stabilize?
- Add a retention/non-regression gate because the packet reports Qwen3-4B retention risk and no official implementation repo (`Tools/paper-to-skill-gate/trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.md:21-36`).
- Any future C6 branch must test tool selection, argument quality, dependency correctness, state/readback behavior, and retention before accepting internalization (`Tools/paper-to-skill-gate/trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.md:38-60`).

Frame check:

All three spike candidates are below the P0 gate set in priority. None of them fixes the 0/34 failure mode by itself. They may improve future scaling or method discipline, but they do not replace sample observability, physical masking proof, byte parity, mid-training behavior gates, four-layer C6, data recipe, human deframing, or governance.

## Algorithm Landing Matrix

| Packet / paper cluster | Algorithm essence | Landing strength | Physical landing |
|---|---|---|---|
| `when2call-tool-decision-p0` | Distinguish tool call, clarify/missing-info, split refusal/cannot-answer, and MAformac `already_state_noop`; generate negative examples by removing correct tools or required parameters. Drop When2Call `direct` for in-scope cockpit control. | `hard_gate` + `receipt_field` | C6 internal `behavior_class`; C5 label distribution and generator checks. Clarify, unsupported refusal, safety refusal, and already-state no-op must not collapse into one negative/no-call bucket. |
| `abc-rigorous-agentic-benchmarks-p0` | Prevent reward/outcome bugs, empty-success, aggregate masking, and judge washing. | `hard_gate` | C6 four-layer denominators by case schema fields; aggregate pass cannot hide red hard layers. |
| `function-calling-data-generation-pack-p0` | Generate high-quality function-calling data with verified positives, irrelevance/no-call negatives, missing-slot cases, distractors, and validation. | `receipt_field` + future `hard_gate` | C5 data recipe: source snapshot, diversity, lineage, negative composition, tool-surface digest, masking checks, and stop-on-rule-fail validation. |
| `leakage-decontamination-pack-p0` | Exact-ID split is insufficient; use augment-after-split, semantic/family/template split, near-duplicate scan, and quarantine. | `hard_gate` + `receipt_field` | C5/C6 leakage receipts, semantic overlap scan, family/template partitions, OOD value buckets, fail-closed quarantine. |
| `learning-rate-matters-vanilla-lora-may-suffice` | LR sensitivity dominates many PEFT variant claims; compare variants only after vanilla LoRA is tuned. | `receipt_field` | C5 `lr_grid`, `rank_grid`, `seed_count`, `best_checkpoint_policy`, and "single-LR train-health only" label if no sweep exists. |
| `internalizing-tool-knowledge-in-slms-via-qlora` | Move fixed tool catalog knowledge into adapter weights to reduce prompt overhead, but guard retention and surface compatibility. | `spike` | Demo-after prompt-surface comparison: full catalog vs retrieved subset vs description-free/internalized. Requires paper/design A/B compatibility with D-domain named tools plus retention/non-regression before any training. |
| `tinyagent-function-calling-at-the-edge` | Retrieve a small tool subset and examples before function-calling on edge SLMs; parser miss should be a first-class failure. | `spike` + future `receipt_field` | Optional offline `tool-surface-retrieval-spike`: gold-tool coverage, dangerous distractor rate, parser/tool-name miss failure class. Useful first spike only after P0 gates; not current demo-critical path. |
| `in-vehicle-function-calling-p0` | Vehicle function calling is edge deployment plus domain-specific function surface, not generic assistant text. | `teaching_note` + future `receipt_field` | C5/C6 domain checklist: vehicle state-change success, missing argument handling, no-call/refusal, latency/memory pressure. No Phi/pruning/healing adoption. |

## Frame Check

The paper packets are not the whole 0/34 remedy.

0/34 root causes were engineering failures around surface mismatch, masking false deletion, train/eval/runtime source mismatch, absence of natural Chinese coverage, sample observability, and weak mid-training behavior gates. Paper absorption strengthens data quality, leakage control, tool-use decision labels, and evaluation rigor. It does not replace the Phase 0 P0 gates already identified in the 18-lens package.

Therefore:

- Paper absorption may feed `rebuild-c6` and `retrain-c5` proposals.
- Paper absorption must not be used to claim C5 fixed, C6 trusted, adapter ready, endpoint ready, or demo ready.
- Later OpenSpec carriers must cite whether each item is adopted as `hard_gate`, `receipt_field`, `spike`, or `teaching_note`.

## Row-Level Absorption Pointers (Q4.15)

These pointers satisfy Q4.15 for the Q2 decision rows. They do not retire this ledger as a whole. Rows with C5/training-only remainder stay live until `retrain-c5-lora-d-domain` absorbs or rejects them.

| Row | Disposition | Pointer |
|---|---|---|
| Q2.1 Zero-Drop Algorithm Landing | Partially absorbed for rebuild-C6; C5/training recipe details remain live for retrain-C5. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#Decision-Sources`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-011-Documentation-absorption-uses-local-static-proof-only`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Documentation-absorption-SHALL-keep-proof-class-boundaries-explicit`; `remaining_owner: openspec/changes/retrain-c5-lora-d-domain` |
| Q2.1 HIGH constraints | Absorbed for rebuild-C6 fake-green boundaries; C5 recipe constraints remain live for retrain-C5. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-004-C6-gate-integrity-is-sign-or-block`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-007-Behavior-class-taxonomy-is-shared-across-C5-C6-and-apply`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`; `remaining_owner: openspec/changes/retrain-c5-lora-d-domain` |
| Q2.2 When2Call Domain Adaptation | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#What-Changes`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-007-Behavior-class-taxonomy-is-shared-across-C5-C6-and-apply`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Case-schema-SHALL-carry-deterministic-expectations` |
| Q2.3 Freeze Denominator Logic, Not Mechanical Selectors Yet | Absorbed. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-001-Four-layer-denominators-derive-from-case-schema-fields`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-007-Behavior-class-taxonomy-is-shared-across-C5-C6-and-apply`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#3-Four-Layer-Bench-Construction`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Four-deterministic-hard-gates-SHALL-decide-release-blocking` |
| Q2.4 C5 Data Receipt Derivation Rules | Partially absorbed for shared taxonomy and anti-metadata proof boundary; C5 receipt implementation remains live for retrain-C5. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/design.md#AD-C6-007-Behavior-class-taxonomy-is-shared-across-C5-C6-and-apply`, `openspec/changes/rebuild-c6-four-layer-bench/specs/vehicle-tool-bench/spec.md#Requirement-Behavior-class-taxonomy-SHALL-be-shared-across-C5-C6-and-apply`; `remaining_owner: openspec/changes/retrain-c5-lora-d-domain` |
| Q2.5 Spike Unlock Is Not A Linear Queue | Absorbed as non-goal/deferred boundary for rebuild-C6; spike-specific execution remains outside this carrier. | `superseded_by: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#Non-Goals`, `openspec/changes/rebuild-c6-four-layer-bench/design.md#Non-Goals`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md#5-Red-Lines`; `rejected_in: openspec/changes/rebuild-c6-four-layer-bench/proposal.md#Non-Goals` for treating ToolRAG, description-free, or DoRA as current rebuild-C6 construction work |

### Human Review Result (2026-06-24)

Status: `APPROVED_FOR_DOCUMENTATION_CLOSEOUT`.

Human review checked Q2.1-Q2.5 row-level pointers against the Q4.15 rule:

- Q2.1 and Q2.1 HIGH constraints correctly split rebuild-C6 fake-green/documentation absorption from remaining `retrain-c5-lora-d-domain` work.
- Q2.2 and Q2.3 are correctly marked absorbed by rebuild-C6.
- Q2.4 correctly remains partial: shared taxonomy and anti-metadata proof boundary are absorbed, while C5 receipt implementation remains owned by `retrain-c5-lora-d-domain`.
- Q2.5 correctly rejects treating ToolRAG, description-free, or DoRA as current rebuild-C6 construction work.

Conclusion: `PASS`. This ledger remains live only for rows with `remaining_owner`; it is not whole-file retired.

## Next Grill Questions

Q2.1-Q2.5 are closed for now. Continue only if a new user question reopens a specific packet, gate, or OpenSpec carrier.
