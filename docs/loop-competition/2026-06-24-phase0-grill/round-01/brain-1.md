# Brain 1 - Round 01

## Scope And Evidence

- Perspective: Contract / SSOT / OpenSpec / SRD governance. I scored whether each question forces a contract decision, prevents source-of-truth drift, and can land in specs, tasks, manifests, or generated-contract gates.
- Mode and scoring follow the local loop contract: fixed 24-candidate blind scoring, five 1-5 dimensions, local file-line evidence required (`docs/loop-competition/2026-06-24-phase0-grill/contract.md:7`, `docs/loop-competition/2026-06-24-phase0-grill/contract.md:11`, `docs/loop-competition/2026-06-24-phase0-grill/contract.md:39`).
- I did not use web research; no current external fact was materially needed. I did not read other `brain-*.md` or `judge.md` files.
- Core governance anchors: OpenSpec specs are the behavior SSOT and changes are proposals until archive (`CLAUDE.md:24`, `CLAUDE.md:27`); PRD/SRD/ARCH map to OpenSpec artifacts rather than parallel doc systems (`CLAUDE.md:43`); major work must align spec/contract/grill docs before implementation (`CLAUDE.md:97`).
- Current authority split is already partly explicit: current progress source moved from old roadmap to grill SSOT + paradigm authority + cascade inventory (`CLAUDE.md:119`, `CLAUDE.md:134`), and `a2-post-roadmap` is explicitly a decision pack / pre-propose checklist, not SSOT or live roadmap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`).
- The D-domain flip is a contract-level change: model-visible surface is D-domain named tools, while canonical IR remains `device x action` (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:17`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:24`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:25`).
- A2 is code-only and already merged; C5 data/training, C6 four-layer evaluation, demo-golden-run, voice, backend and endpoint work are deferred to separate later changes (`docs/handoffs/2026-06-24-a2-merged-d-domain.md:4`, `docs/handoffs/2026-06-24-a2-merged-d-domain.md:10`, `docs/handoffs/2026-06-24-a2-merged-d-domain.md:17`, `docs/handoffs/2026-06-24-a2-merged-d-domain.md:18`).

## Keep

| Candidate | Score | Reason |
|---|---:|---|
| C01 | 22 | Strong authority-classification question; mostly answerable from existing evidence. |
| C02 | 24 | Forces a physical responsibility matrix across old roadmap, recovery roadmap, research pack, OpenSpec changes, and UIUE. |
| C03 | 25 | Directly prevents `full`/`demo` dual-SSOT drift in codegen artifacts. |
| C04 | 25 | Highest-governance question: archived specs may now need MODIFY/new-change disposition. |
| C05 | 21 | Valuable stage-control question; should be made into a Pocock/OpenSpec carrier matrix. |
| C06 | 25 | Needed to stop SRD route tiers, runtime outcomes, refusal, readback, and bench verdicts from becoming parallel vocabularies. |
| C07 | 23 | Needed decision-status manifest for D1-D37 plus MASTER; slightly overlaps C04 but targets decisions and baseline prose, not specs. |
| C08 | 20 | Useful UIUE/mainline boundary question; lower contract leverage than C21/C22 but prevents UI work from becoming hidden blockers. |
| C09 | 22 | Forces explicit decision on whether failure/error-recovery is intentionally cut or added to C5 data. |
| C10 | 23 | Strong taxonomy question: `already_state` is neither ordinary unsupported nor safety refusal. |
| C11 | 20 | Necessary for `data_recipe.yaml`, though less foundational than data-class taxonomy and held-out gates. |
| C12 | 20 | Necessary recipe question; should be merged with C11 in the same data recipe section. |
| C13 | 25 | Critical anti-memorization and lineage-leakage contract. |
| C14 | 25 | Critical training-interrupt gate; directly prevents another end-of-run 0/34 discovery. |
| C15 | 22 | Good gate-placement question for training stack feasibility; physical output is clear. |
| C16 | 21 | Important recipe-governance question, but some fields are already partly frozen. |
| C17 | 25 | Critical benchmark-authority question after D-domain migration. |
| C18 | 25 | Critical C6 scoring contract; must define denominators, thresholds, and fail priority. |
| C19 | 23 | Endpoint-ready claims are high-risk; this forces timing and evidence boundaries. |
| C20 | 25 | Critical endpoint/runtime safety question because endpoint GBNF is not available. |
| C21 | 23 | Strong ownership-boundary question across mainline state contracts and UIUE cards. |
| C22 | 22 | Strong demo-golden readiness question; needs stable IDs and C6 linkage. |
| C23 | 22 | Strong governance lesson from the D-domain flip; requires a schema, not just "ask another model". |
| C24 | 25 | Highest-priority status vocabulary question; prevents pass-label laundering. |

## Delete

| Candidate | Reason |
|---|---|
| None | All 24 candidates have some contract or governance value. The issue is merge/wording, not deletion. |

## Merge

| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C01 + C02 | Create an authority matrix naming each roadmap/research/OpenSpec/UIUE artifact as `SSOT`, `decision-pack`, `historical`, `pre-propose checklist`, `deferred change skeleton`, or `UIUE branch artifact`, with update rules. | C01 asks identity; C02 asks responsibility split. They should land in one `progress_authority_matrix` instead of two prose decisions. |
| C09 + C10 + C11 + C12 | Define `data_recipe.yaml`: data classes, `already_state` semantics, category factors, and template/cloud legs, with explicit "failure class included or intentionally cut" rationale. | These are one C5 data recipe cluster. Score separately, but land together. |
| C13 + C14 + C18 | Define C5/C6 anti-fake-green gates: held-out axes, mid-training gate, and final four-layer scoring denominators/fail priority. | They form the training/eval gate spine. Keep separate acceptance clauses inside one change. |
| C21 + C22 | Define demo-visible contract linkage: `tool -> IR -> state_cell -> card -> patch` and `demo-golden-run` stable IDs / C6 case derivation. | Same interface between mainline contract and UIUE consumption. |
| C24 + C18 + C19 | Define acceptance/status vocabulary and prohibit endpoint/golden/model-quality/V-PASS conflation. | C24 is the vocabulary; C18/C19 are two major consumers. |

## Rewrite

| Candidate | Proposed wording | Reason |
|---|---|---|
| C01 | What is the exact role of `a2-post-roadmap` in the authority matrix, and which claims are forbidden because it is not SSOT/live roadmap? | Existing evidence already says it is not SSOT, so the useful question is enforcement. |
| C05 | For each pending workstream, what Pocock stage, OpenSpec carrier, exit condition, and forbidden race condition apply before implementation? | Stage alone is too soft; the contract needs carrier and exit gate. |
| C08 | Which UIUE findings are non-blocking presentation work, and which touch C3/C6/state-cell/acceptance contracts enough to remain Phase 0 blockers? | Sharper contract boundary than "outside mainline blockers" alone. |
| C09 | Should C5 add a fifth `failure/error_recovery` class, or explicitly cut it with a rationale and minimal endpoint-error seed policy? | Prevents silent drop of home-llm failure class. |
| C11 | What initial category factors must `data_recipe.yaml` use, and what spike/evidence permits changing them? | Lands directly in a manifest. |
| C12 | What deterministic-template/cloud-generation split must `data_recipe.yaml` declare, and what digest/provenance proves both legs derive from the same SSOT? | The important risk is same-source proof, not just ratio. |
| C15 | Is the training-stack feasibility check a `retrain-c5` task hard-precondition, and what receipt must it write before real data generation or training? | Source evidence points to OpenSpec tasks, not an independent pre-propose track. |
| C23 | Which decision classes require ground-truth or cross-vendor review, what file schema must the review produce, and where is it indexed back into the decision SSOT? | Avoids vague "ask subagents" governance. |

## Missing Risks

- `generated/` drift-gate status is not directly represented in the 24 questions, except indirectly by C03/C04. It matters because A2 review found generated D-domain artifacts needed machine-checkable gate coverage (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:33`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:443`).
- `--scope=full` is not a training surface in the same way as `--scope=demo`; candidate C03 should force fail-fast semantics for invalid full-schema decoding, not just a directory naming convention (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:10`, `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:28`).
- Local verification remains `make verify`, not remote CI; any governance question that says "CI gate" should be rewritten to "local verification gate / receipt" unless CI prerequisites are deliberately added (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:17`).
- The old frame/set_cabin strangler path still exists by design after A2; candidate C04/C20 should distinguish "canonical consumer" from "historical compatibility branch" rather than demanding blind deletion (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:16`, `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:47`).

## Scores

| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Priority | Needs User Grill? |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C01 | 4 | 5 | 4 | 5 | 4 | 22 | P0 | No |
| C02 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C04 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C05 | 4 | 4 | 4 | 5 | 4 | 21 | P0 | Yes |
| C06 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C07 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | Yes |
| C08 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C09 | 4 | 5 | 4 | 4 | 5 | 22 | P1 | Yes |
| C10 | 4 | 5 | 5 | 4 | 5 | 23 | P0 | Yes |
| C11 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C12 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C13 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C14 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C15 | 4 | 5 | 4 | 5 | 4 | 22 | P0 | Yes |
| C16 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | Yes |
| C17 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C18 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C19 | 4 | 5 | 4 | 5 | 5 | 23 | P0 | Yes |
| C20 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C21 | 4 | 5 | 4 | 5 | 5 | 23 | P0 | Yes |
| C22 | 4 | 5 | 4 | 5 | 4 | 22 | P0 | Yes |
| C23 | 4 | 4 | 5 | 4 | 5 | 22 | P1 | Yes |
| C24 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |

## Candidate Notes

| Candidate | Verdict | Evidence | Recommended Conclusion |
|---|---|---|---|
| C01 | Keep / closeable | `a2-post-roadmap` explicitly says it is a model-quality decision pack + pre-propose checklist, not SSOT/live roadmap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`). | Close as: `decision_pack` and `pre_propose_checklist`; forbid treating it as progress SSOT or live roadmap. |
| C02 | Keep | Progress SSOT moved to grill master + paradigm + cascade, while old roadmap is historical/context (`CLAUDE.md:119`, `CLAUDE.md:134`); grill master says Q22 already decided progress SSOT single-source direction (`docs/grill-tournament/grill-decisions-master.md:77`, `docs/grill-tournament/grill-decisions-master.md:194`). | Produce an authority/responsibility matrix and sync it into handoff/README templates. |
| C03 | Keep | Q04 is explicitly P0 pending: `full=1538` lightweight, `demo=562` heavy, both from 3990 and not two SSOTs (`docs/grill-tournament/grill-decisions-master.md:59`, `docs/grill-tournament/grill-decisions-master.md:233`). A2 S_CLOSE also flags `full` fail-fast semantics (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:10`). | Define artifact matrix: source rows, generated files, schema depth, consumer, validation gate, and fail-fast behavior for both scopes. |
| C04 | Keep | Q08 is P0 pending and must decide `no-change/MODIFY/new change/docs cleanup` for archived specs (`docs/grill-tournament/grill-decisions-master.md:63`, `docs/grill-tournament/grill-decisions-master.md:221`). OpenSpec specs are behavior SSOT (`CLAUDE.md:27`). | Produce `archived_spec_impact_manifest.md` and convert changed behavior into formal OpenSpec MODIFY/new changes. |
| C05 | Keep / rewrite | Q12 is P0 pending and asks for stage, evidence, exit condition, forbidden race, and OpenSpec carrier (`docs/grill-tournament/grill-decisions-master.md:67`). | Keep as a Pocock stage matrix, but require `stage`, `carrier`, `exit_condition`, and `forbidden_race`. |
| C06 | Keep | SRD says route architecture is valid but surface changed to D-domain (`docs/srd-three-layer-intent-routing.md:3`, `docs/srd-three-layer-intent-routing.md:68`); Q18 asks to unify runtime outcomes and L1-L4 fields to prevent false-green layering (`docs/grill-tournament/grill-decisions-master.md:243`). | Define canonical enums/fields for `route_tier`, `model_surface`, `runtime_scope`, `execution_outcome`, `readback_result`, `refusal_kind`, `safety_reason`. |
| C07 | Keep | Q20 requires D1-D37 `keep/modify/superseded/defer` manifest (`docs/grill-tournament/grill-decisions-master.md:75`, `docs/grill-tournament/grill-decisions-master.md:245`); MASTER should keep IR authority while adding D-domain surface layer (`docs/grill-tournament/grill-decisions-master.md:76`, `CONTEXT.md:37`). | Create decision-status manifest and MASTER banner/update plan; do not silently mutate historical decisions. |
| C08 | Keep / lower | UIUE has accepted and pending items mapped to Q30-Q38 (`docs/grill-tournament/grill-decisions-master.md:85`, `docs/grill-tournament/grill-decisions-master.md:266`, `docs/grill-tournament/grill-decisions-master.md:271`); C5/UIUE intersect through contract SSOT (`docs/c5-recovery-2026-06-22/roadmap.md:36`, `docs/c5-recovery-2026-06-22/roadmap.md:38`). | Keep as a UIUE boundary manifest: `blocked_mainline`, `design_parallel`, `contract_intersection`, `deferred`. |
| C09 | Keep / merge | Home-llm comparison found MAformac has four classes while failure/error recovery is missing and must be explicitly cut or added (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:121`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:187`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:192`). | Decide fifth class vs explicit cut; land in `retrain-c5` proposal and `data_recipe.yaml`. |
| C10 | Keep | `already_state` is identified as a distinct refusal reason and not equivalent to ASIL safety refusal (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:77`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:99`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:119`). | Add `state_noop/already_state` as its own outcome/refusal kind, separate from `unsupported_refusal` and `safety_refusal`. |
| C11 | Keep / merge | Data factor ratios are called out as unset and material; suggested initial factors are documented but not yet contract (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:19`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:136`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:197`). | Put initial factors in `data_recipe.yaml`; require evidence/spike before changing them. |
| C12 | Keep / merge | Template parameterization is a main generalization leg and current A2 has deterministic `dDomainToolCallArguments`, but retrain-c5 has not contractually tied it in (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:98`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:117`). | Define template/cloud dual-leg ratio, provenance, digest, and same-SSOT derivation in `data_recipe.yaml`. |
| C13 | Keep | Q24 is P0 pending for D-domain + four-class held-out split (`docs/grill-tournament/grill-decisions-master.md:254`); retrain tasks already include heldout/OOD leakage diagnosis placeholder (`openspec/changes/retrain-c5-lora-d-domain/tasks.md:28`). | Require held-out axes: family, device, value_form, utterance_template, semantic_parent, tool_name, generator_source, scope_tier, and data_class. |
| C14 | Keep | Mid-training 50/100/150 gate is partly decided but missing sample axes/thresholds/sign-or-block receipt (`docs/grill-tournament/grill-decisions-master.md:61`, `docs/grill-tournament/grill-decisions-master.md:252`); post-roadmap says this is a direct 0/34 prevention gate (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:177`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:181`). | Define `mid_training_gate.yaml` with samples, thresholds, continue/pause/early-stop/blocked actions, and receipts. |
| C15 | Keep / rewrite | Training stack spike is listed as P0-1 and should land as the first `retrain-c5` OpenSpec task (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:161`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:288`). | Classify as `retrain-c5` task hard-precondition, not a free-floating spike; require runtime, memory, dataset-scale, and backend receipt. |
| C16 | Keep | Recipe is partly frozen: rank16Mainline + LR1e-4 are to be preserved unless later evidence reopens them (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:33`, `openspec/changes/retrain-c5-lora-d-domain/proposal.md:28`, `openspec/changes/retrain-c5-lora-d-domain/tasks.md:21`). | Produce `recipe_knobs.yaml`: frozen fields, variable fields, and reopen evidence after surface/parity/data gates pass. |
| C17 | Keep | Base 10/23 is old generic-frame anchor and must coexist with new D-domain base recalibration (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:15`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:163`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371`). | Preserve old 10/23 as historical failure anchor; require new D-domain base anchor before candidate comparison. |
| C18 | Keep | Rebuild C6 proposal already says four layers must be independent and no pass labels may masquerade as others (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:25`, `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:48`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:20`). | Define layer denominators, thresholds, fail priority, and aggregation prohibition in `vehicle-tool-bench` delta. |
| C19 | Keep | Endpoint parity is P0-ish because serializing it until after training risks discovering device failures too late (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:170`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:172`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:173`). | Start endpoint smoke in parallel with retrain-c5; endpoint-ready requires real device/parser/whitelist/LoRA load receipt, not Mac C6 success. |
| C20 | Keep | Endpoint GBNF assumption is explicitly superseded; endpoint must use LoRA format + JSON three-layer defensive parser + whitelist, with GBNF only fallback (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:379`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:390`, `docs/grill-tournament/grill-decisions-master.md:83`). | Define parser repair limits, whitelist digest, unknown-tool enum, repair-failed enum, and fail-closed policy before endpoint claims. |
| C21 | Keep | State-cell/card ownership is not just UI: state-cells must expand to 10 families and map `tool -> IR -> state_cell -> card -> patch` (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:399`, `docs/grill-tournament/grill-decisions-master.md:87`, `docs/grill-tournament/grill-decisions-master.md:266`). | Treat mapping as mainline contract artifact consumed by UIUE; UIUE owns presentation, not source mapping truth. |
| C22 | Keep | Golden-run is a contract replay, not a visual script; missing state cell or C6 linkage forbids entry (`docs/grill-tournament/grill-decisions-master.md:118`, `docs/grill-tournament/grill-decisions-master.md:122`, `docs/grill-tournament/grill-decisions-master.md:123`). | Entry conditions: stable tool IDs, IR IDs, state_cell IDs, C6 case IDs, expected state delta, readback TTS, and `must_pass` flags. |
| C23 | Keep | D-domain flip was decided by ground-truth subagent evidence, and Q14 asks to formalize when that is mandatory (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:109`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:110`, `docs/grill-tournament/grill-decisions-master.md:69`, `docs/grill-tournament/grill-decisions-master.md:226`). | Define review triggers and output schema: sources read, evidence lines, contradictory findings, decision impact, write-back target. |
| C24 | Keep | Q41 already states status layers must not masquerade as one another (`docs/grill-tournament/grill-decisions-master.md:197`); post-roadmap repeats train-health/model-quality/endpoint/readback must be separately signed (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:357`). | Create a status vocabulary manifest and forbid using `train_health`, `C6 model-quality`, `endpoint candidate`, `demo-golden`, `V-PASS`, `S-PASS`, or `U-PASS` interchangeably. |

## Rationale

The strongest candidates are the ones that either force an artifact with a bounded owner (`archived_spec_impact_manifest`, `data_recipe.yaml`, `mid_training_gate.yaml`, `vehicle-tool-bench` delta, status vocabulary manifest) or block a known failure mode: dual SSOT, fake pass labels, endpoint claims without device proof, or data/eval leakage.

The weakest still should not be deleted because they reveal useful boundaries, but several should be merged into physical contract artifacts. In this round I would prioritize C03, C04, C06, C13, C14, C17, C18, C20, and C24 as the highest-leverage P0 set.
