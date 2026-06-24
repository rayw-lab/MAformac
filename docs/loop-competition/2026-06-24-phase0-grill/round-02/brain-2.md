# Brain 2 - Round 02

## Scope And Evidence
- Role: GREEN implementation coordinator. I treated candidates as route-control questions: decide now only when a wrong answer can send implementation/training down the wrong path; carry data-tuning and UI refinement as P1/P2 when an OpenSpec carrier can safely hold them.
- Blind boundary: read `candidates-blind.md` and `contract.md`; did not read `round-01/`, other `round-02/brain-*.md`, judge files, or this loop's `ledger.md`.
- Key local evidence: project is offline demo, not production car control (`CLAUDE.md:16-18`); OpenSpec/spec-first is required (`CLAUDE.md:27`, `CLAUDE.md:97`); A2/post-A2 training and evaluation are deferred (`docs/grill-tournament/cascade-inventory.md:5`, `docs/handoffs/2026-06-24-a2-merged-d-domain.md:17-20`).
- Authority map evidence: `a2-post-roadmap` explicitly says it is a model-quality decision pack/pre-propose checklist, not SSOT (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`); the current grill SSOT and remaining grill order live in `grill-decisions-master` (`docs/grill-tournament/grill-decisions-master.md:9-20`, `docs/grill-tournament/grill-decisions-master.md:276-284`).
- D-domain evidence: canonical IR remains device/action/value while model-visible surface is D-domain named tools (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:17-25`, `docs/srd-three-layer-intent-routing.md:178-190`); `562` is intent count, not tool count (`docs/grill-tournament/grill-decisions-master.md:22-33`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:425-430`).
- Training/C6 evidence: four data classes and parity are drafted in retrain-c5 (`openspec/changes/retrain-c5-lora-d-domain/proposal.md:24-30`); heldout/lineage gates are still task placeholders (`openspec/changes/retrain-c5-lora-d-domain/tasks.md:14-28`); C6 four-layer bench is a DRAFT skeleton and not yet a complete threshold spec (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:24-30`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:18-28`).
- Endpoint and status evidence: endpoint GBNF is not available on the main endpoint path, so parser/repair/whitelist policy is real contract work (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:377-390`); Q41 already forbids conflating train-health, G6-C, model quality, endpoint, golden, and V/S/U-PASS (`docs/grill-tournament/grill-decisions-master.md:193-198`).

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C03 | 25 | Must decide now. `--scope=full` vs `--scope=demo` is a codegen/SSOT boundary, not a wording issue. Land in `migrate-d-domain-tool-surface` design plus generated surface manifest. |
| C04 | 24 | Must decide now before more specs are built on stale archived behavior. Land as an OpenSpec disposition table for archived specs. |
| C06 | 24 | Must decide now because route/runtime/bench/status fields are the glue across SRD, C3, C6, and UI. Land in SRD + trace/outcome schema. |
| C13 | 25 | Must decide before real data generation. Without split axes, C5 can look improved while leaking lineage. Land in `data_recipe.yaml` and `lora-training` spec. |
| C14 | 24 | Must decide before training. It is the direct antidote to the prior "finish training then discover 0/23" failure. Land in `mid_training_gate.yaml`. |
| C17 | 24 | Must decide now for benchmark honesty. Old 10/23 remains historical failure anchor; new D-domain base governs candidate comparison. Land in `rebuild-c6-four-layer-bench` tasks. |
| C18 | 25 | Must decide now. C6 gates define what "better" means; thresholds/fail priority cannot be retrofitted after candidate training. Land in vehicle-tool-bench design/spec. |
| C20 | 24 | Must decide before endpoint claims. No endpoint GBNF makes parser/repair/whitelist/failure enum a hard contract, not implementation detail. |
| C24 | 24 | Keep as already directionally decided, but enforce physically. Land as closeout/status vocabulary and claim templates. |

## Delete
| Candidate | Reason |
|---|---|
| None | All 24 expose a real decision or artifact boundary. Some should be merged or carried, not deleted. |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C01 + C02 | Define the post-A2 source-of-truth map: classify `a2-post-roadmap`, old roadmap, C5 recovery roadmap, OpenSpec changes, and UIUE roadmap by authority, stage, and allowed use. | C01 is the artifact identity; C02 is the routing map. They should land together in `CONTEXT.md` / `docs/README.md` / grill-master Q22 crystal. |
| C09 + C10 | Decide C5 data/outcome taxonomy: four classes vs failure class, and classify `already_state`/noop separately from unsupported and safety. | Same semantic boundary. Avoid creating two partially overlapping refusal taxonomies. Land in `retrain-c5` proposal + `data_recipe.yaml` + runtime outcome enum. |
| C11 + C12 | Define C5 data recipe ratios: category factors plus deterministic-template vs cloud-natural-language legs, with spike evidence required before changing them. | Same physical artifact: `data_recipe.yaml` and data recipe spike. Keep separate rows in scoring, but execute as one recipe decision. |
| C19 + C20 | Define endpoint readiness bundle: start timing, minimum endpoint evidence, parser/repair/whitelist/failure-enum contract, and no-GBNF fallback. | Endpoint timing without parser policy is incomplete; parser policy without endpoint evidence can become paper-only. |
| C21 + C22 | Define demo contract handoff: `tool -> IR -> state_cell -> card -> patch` ownership plus golden-run entry IDs before UIUE consumes it. | Same state-to-demo boundary. Mainline owns state/IR/patch correctness; UIUE owns presentation once IDs are stable. |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C07 | Split into: (a) D1-D37 status manifest; (b) MASTER semantic protocol banner preserving IR while adding surface-derived D-domain layer. | The current wording mixes decision governance and one specific authority document. They land in different artifacts. |
| C08 | Which UIUE items are mainline blockers because they touch C3-C6/state/golden contracts, and which are visual/SOP backlog outside Phase 0? | Avoid treating all UIUE findings as either blockers or decoration. |
| C15 | Should training-stack spike be an explicit task inside `retrain-c5` propose/apply, and what receipt proves local mlx-lm vs cloud-GPU choice before full training? | The source already warns not to run it as an untracked standalone spike. |
| C17 | How should the old generic-frame base 10/23 remain as historical failure evidence while a new D-domain base anchor becomes the candidate gate? | The old anchor is not "invalid"; it is invalid as the new candidate comparator. |
| C24 | What machine-readable status vocabulary and final-summary sentence forms prevent train-health, C6 model-quality, endpoint candidate, golden-run, and V/S/U-PASS conflation? | Make it enforceable; a discussion-only vocabulary will not prevent claim drift. |

## Missing Risks
- The C6 DRAFT skeleton says `c6-bench-cases.jsonl` has 57 old generic-frame rows, but the cascade inventory later corrects this to 34 old B-frame expected calls plus 23 no-call rows (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:9`, `docs/grill-tournament/cascade-inventory.md:93`). C04/C18 must reconcile this before the spec is treated as clean.
- The candidate set asks endpoint parity, but not the related portability debt: A2 closeout says tests still depend on local base-model/python paths, which undermines remote/CI-style verification (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:23-29`, `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:49-51`).
- Raw-data redlines are implicit in C11/C12 but should be explicit in the data recipe: original bug/customer prose is oracle/input evidence, not training text (`openspec/changes/retrain-c5-lora-d-domain/proposal.md:42-50`).
- C23 should require a schema that distinguishes "ground-truth subagent" from "ordinary review"; otherwise it will become process theater. The A2 closeout shows different reviewers caught different true bugs (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:53-56`).

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Priority | Needs User Grill? |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C01 | 4 | 5 | 3 | 5 | 4 | 21 | P0 | No |
| C02 | 5 | 4 | 3 | 5 | 4 | 21 | P0 | Yes |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C04 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C05 | 4 | 4 | 4 | 5 | 4 | 21 | P0 | Yes |
| C06 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C07 | 4 | 4 | 3 | 5 | 4 | 20 | P0/P1 split | Yes |
| C08 | 3 | 4 | 3 | 4 | 3 | 17 | P1 | No |
| C09 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | Yes |
| C10 | 3 | 5 | 3 | 4 | 4 | 19 | P1 | Yes |
| C11 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | Yes |
| C12 | 4 | 5 | 4 | 5 | 4 | 22 | P1 | Yes |
| C13 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | No |
| C14 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C15 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | Yes |
| C16 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | No |
| C17 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | No |
| C18 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C19 | 5 | 4 | 4 | 5 | 4 | 22 | P0 | Yes |
| C20 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | No |
| C21 | 4 | 5 | 4 | 4 | 4 | 21 | P0/P1 split | No |
| C22 | 4 | 5 | 4 | 5 | 4 | 22 | P0 | Yes |
| C23 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C24 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | No |

## Candidate Notes
| Candidate | Verdict | Evidence | Recommended Conclusion |
|---|---|---|---|
| C01 | Keep merged | `a2-post-roadmap` declares itself a decision pack/pre-propose checklist, not SSOT (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`). | Already decidable: classify as pre-propose checklist / model-quality decision pack. Land in header and source map; no user grill needed unless changing role. |
| C02 | Keep merged | Q22 says progress SSOT should be single; old roadmap becomes historical, new single source is grill SSOT plus A2 exec-plan candidate (`docs/grill-tournament/grill-decisions-master.md:193-198`). | Decide now as a source-of-truth map. Land in `CONTEXT.md`, `docs/README.md`, and grill-master Q22 crystal. |
| C03 | Keep | A2 codegen has two scopes from one 3990-derived source: full=1538 light, demo=562 heavy (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:262-266`). | Must grill now. Artifact: generated surface manifest with source digest, `scope`, `depth`, and proof both derive from one source. |
| C04 | Keep | Cascade marks multiple specs as modify/no-change/new-file, including semantic-function, tool-execution, vehicle-tool-bench, demo-experience, and lora-training (`docs/grill-tournament/cascade-inventory.md:78-102`). | Must grill now. Artifact: OpenSpec spec disposition table before applying new changes. |
| C05 | Keep | Current methodology requires Pocock stage routing before propose/build (`CLAUDE.md:20-28`), and Q12 is still P0 pending (`docs/grill-tournament/grill-decisions-master.md:225-227`). | Decide now enough to prevent starting training/eval too early. Land in grill-master Q12 and change entry criteria. |
| C06 | Keep | SRD defines clarifyTag, D-domain surface, runtime tier, and scope rules, but CAS4/Q18 still asks for unified runtime fields (`docs/srd-three-layer-intent-routing.md:52-60`, `docs/grill-tournament/grill-decisions-master.md:241-244`). | Must grill now. Artifact: canonical enum set across SRD, C3 trace, C6 scoring, and UI visual state. |
| C07 | Rewrite | D1-D37 status manifest is Q20; MASTER/IR banner is Q21 (`docs/grill-tournament/grill-decisions-master.md:245-246`). | Split. D1-D37 manifest is P0; MASTER banner can be P1 if no implementation depends on it today. |
| C08 | Rewrite | UIUE has U1-U31, but only some intersect hard contracts such as state UI, golden-run, and card-map (`docs/grill-tournament/grill-decisions-master.md:151`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:364-367`). | Carry as P1 after mainline contract blockers; rewrite around blocker vs backlog. |
| C09 | Merge | Home-llm audit identifies failure class as a silent-drop gap and says it must be explicitly cut or included (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:187-192`). | P1, not a Phase 0 route blocker. Land in `retrain-c5` proposal "why 4 not 5". |
| C10 | Merge | `already_state` is distinct from not_available and safety refusal in home-llm comparison (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:115-122`). | Merge into C09/C18 taxonomy. Keep as separate enum decision only if it affects C6 denominators. |
| C11 | Keep merged | Current retrain skeleton has four classes but no category factors; audit proposes factors and a spike (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:194-200`). | P1. Land in `data_recipe.yaml` with spike receipt before formal training. |
| C12 | Keep merged | Audit recommends template leg plus cloud leg, because pure cloud generator is uncontrollable and judge can miss (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:201-205`). | P1, same artifact as C11. Decide before data generation, not before Phase 0 cleanup. |
| C13 | Keep | Grill-master Q24 lists required split/leakage axes, and tasks only say heldout/OOD diagnostics as placeholders (`docs/grill-tournament/grill-decisions-master.md:252-260`, `openspec/changes/retrain-c5-lora-d-domain/tasks.md:26-28`). | Must define in propose. Engineering can draft; user grill only if axes trade off demo scope. |
| C14 | Keep | D1 locks 50/100/150 checkpoints; Q06 still needs sample axes and thresholds (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:262-268`, `docs/grill-tournament/grill-decisions-master.md:252-253`). | Must grill now because thresholds are decision, not implementation. Land in `mid_training_gate.yaml`. |
| C15 | Keep rewritten | A2-post says training stack spike must enter retrain-c5 tasks, not become an untracked standalone spike (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156-162`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:329-347`). | Decide as propose-task hard gate. User grill needed for local-vs-cloud cost/risk. |
| C16 | Keep | Recipe mainline is already rank16Mainline + LR1e-4; Q23 asks what evidence can reopen it (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:387-394`, `docs/grill-tournament/grill-decisions-master.md:252-254`). | Carry P1. Land in recipe reopen policy; do not block Phase 0. |
| C17 | Keep rewritten | A2-post explicitly says 10/23 remains historical failure anchor while new D-domain base governs candidate gate (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:163-169`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:369-372`). | Must record now in `rebuild-c6` before candidate comparison. No user grill unless changing comparator philosophy. |
| C18 | Keep | C6 proposal lists four independent layers but thresholds/scorers are DRAFT placeholders (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:24-30`, `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:18-24`). | Must grill now. Artifact: `vehicle-tool-bench` design with denominators, thresholds, and fail priority. |
| C19 | Keep merged | Endpoint/iOS true device must start in parallel; simulator/Mac-only cannot sign endpoint V-PASS (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:170-176`, `openspec/changes/retrain-c5-lora-d-domain/proposal.md:48`). | P0 operational decision. Land in endpoint spike/procurement checklist. |
| C20 | Keep merged | Endpoint path has no GBNF; D-domain endpoint uses LoRA format plus JSON defense parsing and whitelist (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:377-390`). | P0 engineering contract. Land in parser/failure enum spec and endpoint decode spike. |
| C21 | Keep merged | B2 maps `tool→IR→state_cell→card→patch`, with state-cells expansion as mainline prerequisite (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:396-400`). | Split ownership: mainline owns IR/state/patch correctness; UIUE owns visual presentation. |
| C22 | Keep merged | Golden-run must be contract playback with stable IDs and C6 links, not a script-only artifact (`docs/grill-tournament/cascade-inventory.md:102`, `docs/grill-tournament/grill-decisions-master.md:121-124`). | P0 for demo contract, but after state/tool IDs stabilize. Needs user grill for actual golden steps. |
| C23 | Keep | Q14 asks what decisions require ground-truth subagent; A2 closeout shows cross-vendor findings were non-overlapping (`docs/grill-tournament/grill-decisions-master.md:225-227`, `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:53-56`). | P1 governance. Land in collaboration rules plus a structured review schema. |
| C24 | Keep rewritten | Q41 is already accepted: status layers must not impersonate one another (`docs/grill-tournament/grill-decisions-master.md:193-198`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:474-479`). | Enforce now in closeout and claim templates; no user grill needed unless renaming statuses. |

## Rationale
The true P0s are the ones that can corrupt downstream artifacts if left vague: C03, C04, C06, C13, C14, C17, C18, C19/C20, C21/C22, and C24. These define SSOT boundaries, spec disposition, outcome/status fields, leakage protection, training interruption gates, candidate comparators, endpoint evidence, and golden-run ownership.

The P1/P2 group should not block Phase 0 cleanup: C09-C12 and C16 are important for `retrain-c5` propose, but they can be carried into `data_recipe.yaml` and spike receipts; C08 and C23 are governance/UIUE shaping work that should not stop spec hygiene. The coordinator route is: first make the artifacts that prevent false starts, then fold recipe/UI/process refinements into the relevant OpenSpec carriers.
