# Brain 3 - Round 01

## Scope And Evidence
- Perspective: pre-mortem/risk, route sequencing, UIUE isolation, user-decision leverage, and status vocabulary that prevents fake green.
- Blindness boundary: evaluated only `candidates-blind.md` plus mandatory source files; did not read other `brain-*.md` or `judge.md` files.
- No web used. Current local evidence was sufficient; material repo claims below cite local `file:line`.
- Key source facts:
  - `a2-post-roadmap` explicitly says it is a post-A2 C5/C6 model-quality decision pack plus pre-propose checklist, not an SSOT, live fact source, or roadmap; it also says Phase 0 must clear non-UIUE P0 grill debt before retrain propose. Evidence: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:331-346`.
  - Current project authority already moved to grill SSOT + paradigm authority + cascade ledger; old roadmap is historical. Evidence: `CLAUDE.md:119`, `CONTEXT.md:24-28`, `docs/README.md:76`.
  - A2 is code-only and explicitly excludes training, model-quality eval, data generation, demo-golden-run, voice, and backend work. Evidence: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:418`, `docs/handoffs/2026-06-24-a2-merged-d-domain.md:10`.
  - `--scope=full` vs `--scope=demo`, archived spec disposition, Pocock re-triage, runtime outcomes, D1-D37 status, held-out axes, and C6 gates are still unresolved Phase 0 grill items. Evidence: `docs/grill-tournament/grill-decisions-master.md:59-79`.
  - D-domain surface is settled, but model-visible D-domain, canonical IR, and runtime tier are distinct layers. Evidence: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:19-27`, `docs/srd-three-layer-intent-routing.md:68-79`.
  - Four-layer C6, status separation, endpoint parity, and UIUE state contract boundaries are specifically designed to prevent fake green. Evidence: `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:25-29`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:399-403`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:478-492`.

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C01 | 24 | High-leverage role classification; prevents treating a research checklist as a roadmap or SSOT. |
| C02 | 24 | Needed responsibility split across historical, decision, OpenSpec, and UIUE artifacts. |
| C03 | 25 | Directly blocks dual-SSOT drift between full and demo artifacts. |
| C04 | 25 | Archived specs are the contract surface; unresolved observable-behavior drift is a Phase 0 blocker. |
| C05 | 24 | Sequencing guard against jumping from A2 code-only into retrain/apply. |
| C06 | 23 | Central field vocabulary needed before C3/C4/C6/status receipts can converge. |
| C07 | 22 | Prevents old D1-D37/MASTER decisions from silently contradicting D-domain. |
| C08 | 23 | UIUE isolation is a real scope-leak risk; state/C3-C6 intersections still affect Phase 0. |
| C09 | 23 | Error-recovery class is a named post-A2 gap, not a generic nice-to-have. |
| C10 | 22 | `already_state` is a concrete semantic hole between unsupported and safety refusal. |
| C11 | 20 | Ratios matter, but exact values need spike evidence; keep as P1 not a direct production decision. |
| C12 | 23 | Template/cloud dual-leg decision directly affects controllability vs naturalness. |
| C13 | 25 | Leakage and memorization are the core false-positive risk for C5. |
| C14 | 24 | Mid-training gate is the direct antidote to 0/34-style late discovery. |
| C15 | 24 | Training-stack evidence is a hard physical gate before full C5 training. |
| C16 | 21 | Useful recipe guardrail; lower than C13/C14 because many recipe defaults are already directionally frozen. |
| C17 | 24 | Base-anchor coexistence prevents both erasing the failure lesson and using stale gates. |
| C18 | 24 | Four-layer C6 scoring is the main anti-fake-green bench question. |
| C19 | 23 | Endpoint evidence timing prevents Mac/model-quality evidence from becoming endpoint-ready claims. |
| C20 | 25 | No endpoint GBNF is a settled constraint; parser/whitelist/failure enums are mandatory hardening. |
| C21 | 24 | Ownership of tool-to-state-to-card chain decides whether UIUE is contract-consuming or contract-defining. |
| C22 | 23 | Golden-run without stable IDs/state cells becomes visual script, not contract replay. |
| C23 | 21 | Governance policy is useful, especially because the D-domain flip came from ground-truth review. |
| C24 | 25 | Highest fake-green prevention value; status layers must be impossible to conflate. |

## Delete
| Candidate | Reason |
|---|---|
| None | All 24 expose a material decision, sequencing risk, or false-green path. |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C01 + C02 | Define post-A2 artifact taxonomy and responsibility split across grill SSOT, paradigm authority, cascade ledger, OpenSpec changes, old roadmaps, and UIUE roadmap. | They address the same authority drift from two angles; keep both if Round 02 wants finer scoring, merge for final list. |
| C06 + C10 + C24 | Define canonical status/outcome/refusal vocabulary from route decision through runtime result and acceptance receipt. | These are distinct layers, but should be decided in one vocabulary package to prevent enum drift. |
| C11 + C12 | Define the C5 data recipe: category factors plus template/cloud generation legs, with spike evidence before production values. | Both land in `data_recipe.yaml` and both expose the same hidden assumption: "data classes listed" does not mean "recipe controlled." |
| C14 + C18 | Define C6 during-training gates and final four-layer scorer as one anti-fake-green gate family. | C14 is cadence/early-stop; C18 is final denominators/thresholds. They must share layers and receipts. |
| C21 + C22 | Define demo contract consumption boundaries: tool-to-state-to-card ownership and golden-run entry/stable ID conditions. | UIUE can only consume stable contract IDs after C21 is settled. |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C01 | What is the formal role of `a2-post-roadmap`: post-A2 C5/C6 decision pack, pre-propose checklist, or progress SSOT, and what claims is it forbidden to make? | Makes the fake-green prevention explicit. |
| C05 | For each follow-up (`retrain-c5`, `rebuild-c6`, endpoint parity, CAS cascade, G6-C, UIUE/golden-run), what Pocock stage and exit evidence are required before implementation? | Adds exit evidence, not only stage labels. |
| C06 | What canonical enum set should bind `route_tier`, `model_surface`, `runtime_scope`, `execution_outcome`, `refusal_kind`, `readback_source`, and acceptance status across C3/C4/C6/UIUE? | Avoids an over-broad "fields or enums" discussion. |
| C11 | What initial C5 data-class factors should be treated as hypothesis values, and what spike evidence is required before they become production recipe values? | Prevents initial factors from becoming unearned authority. |
| C19 | What endpoint evidence must exist before any `endpoint candidate`, `endpoint-ready`, or V-PASS-adjacent claim, and when must endpoint work start relative to retrain/C6? | Names the claims it is trying to block. |
| C24 | What exact acceptance/status vocabulary and receipt fields prevent `train_health`, `G6-C`, `C6 model-quality`, `endpoint candidate`, `demo-golden`, `V-PASS`, `S-PASS`, and `U-PASS` from substituting for one another? | Forces physical receipt separation. |

## Missing Risks
- The candidates underweight T5/historical-banner drift. `cascade-inventory` says 75 historical snapshots still need pending banner work, and stale handoffs/dispatches can reintroduce old roadmaps as authority. Evidence: `docs/grill-tournament/cascade-inventory.md:35`, `docs/grill-tournament/cascade-inventory.md:46`, `docs/grill-tournament/cascade-inventory.md:173`.
- The candidates do not explicitly require "evidence freshness" labels for post-A2 docs. A2 has since merged to main, while some skeletons remain DRAFT/DEFERRED; any future route decision must include an as-of state check. Evidence: `docs/handoffs/2026-06-24-a2-merged-d-domain.md:4-20`, `docs/grill-tournament/cascade-inventory.md:106-113`.
- There is no standalone candidate for "local/Mac evidence must not become mobile/endpoint acceptance." C19 and C24 cover it indirectly, but this should be explicit in judge synthesis. Evidence: `openspec/changes/retrain-c5-lora-d-domain/proposal.md:48`, `openspec/changes/retrain-c5-lora-d-domain/tasks.md:34`.
- There is no candidate for redline handling around raw/oracle data after new generator work. C12/C23 touch it, but retrain proposal must keep original-prose and PII boundaries visible. Evidence: `openspec/changes/retrain-c5-lora-d-domain/proposal.md:50`, `openspec/changes/retrain-c5-lora-d-domain/tasks.md:34`.

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Priority | Needs User Grill? |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C01 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C02 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C04 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C05 | 5 | 4 | 5 | 5 | 5 | 24 | P0 | Yes |
| C06 | 5 | 4 | 4 | 5 | 5 | 23 | P0 | Yes |
| C07 | 5 | 4 | 4 | 4 | 5 | 22 | P0 | Yes |
| C08 | 4 | 4 | 5 | 5 | 5 | 23 | P0 | Yes |
| C09 | 4 | 5 | 4 | 5 | 5 | 23 | P1 | Yes |
| C10 | 4 | 5 | 4 | 4 | 5 | 22 | P1 | Yes |
| C11 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C12 | 4 | 5 | 4 | 5 | 5 | 23 | P1 | Yes |
| C13 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | No |
| C14 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C15 | 5 | 5 | 5 | 5 | 4 | 24 | P0 | No |
| C16 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | Yes |
| C17 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C18 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C19 | 5 | 4 | 4 | 5 | 5 | 23 | P0 | Yes |
| C20 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | No |
| C21 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C22 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | Yes |
| C23 | 4 | 4 | 5 | 4 | 4 | 21 | P1 | Yes |
| C24 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |

## Candidate Notes
| Candidate | Verdict | Evidence | Recommended Conclusion |
|---|---|---|---|
| C01 | Keep | `a2-post-roadmap` says it is not SSOT/live fact source/roadmap, but a model-quality decision pack plus pre-propose checklist: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`; it repeats non-SSOT status at `:325`. | Classify it as a post-A2 C5/C6 decision pack and pre-propose checklist. Forbid using it as live roadmap or progress SSOT. |
| C02 | Keep | Current authority is grill SSOT + paradigm authority + cascade ledger: `CLAUDE.md:119`, `CONTEXT.md:24-28`; old roadmap is marked historical in the README: `docs/README.md:76`. | Split responsibility: grill-master owns decision status, paradigm owns surface/LoRA decisions, cascade owns doc inventory, OpenSpec owns future change carriers, old roadmaps are historical, UIUE remains branch input until contract IDs stabilize. |
| C03 | Keep | Q04 is explicitly unresolved P0: full=1538 lightweight directory, demo=562 heavy directory, both from 3990: `docs/grill-tournament/grill-decisions-master.md:59`; paradigm states the same two-scope derivation: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:265`. | Adopt an artifact matrix plus manifest/digest proof: `full` and `demo` differ by derivation depth, not by source authority. |
| C04 | Keep | Q08 requires disposition for archived specs whose observable behavior changed: `docs/grill-tournament/grill-decisions-master.md:63`; cascade already flags vehicle-tool-bench spec modification: `docs/grill-tournament/cascade-inventory.md:81`. | Create a per-spec `no_change | MODIFY | new_change | docs_cleanup` table before further implementation. |
| C05 | Keep | Q12 is unresolved P0 Pocock re-triage: `docs/grill-tournament/grill-decisions-master.md:67`; post-roadmap warns next step is Phase 0 debt, not retrain propose: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:331-346`. | Reset stage labels before work: C5/C6 changes are DRAFT/pre-propose until Phase 0 route debt clears. |
| C06 | Keep | Q18 asks to bind route/model/runtime/execution fields to C4/C6/C3 traces: `docs/grill-tournament/grill-decisions-master.md:73`; SRD already separates route tiers and D-domain surface: `docs/srd-three-layer-intent-routing.md:68-79`. | Define one minimal enum package across route tier, model surface, runtime scope, execution outcome, refusal kind, readback source, and acceptance status. |
| C07 | Keep | Q20 asks for `keep|modify|superseded|defer` manifest for D1-D37: `docs/grill-tournament/grill-decisions-master.md:75`; Q21 asks MASTER to keep IR authority while adding D-domain surface: `docs/grill-tournament/grill-decisions-master.md:76`. | Produce a decision-status manifest. Do not let old decisions mutate through prose or stale banners. |
| C08 | Keep | UIUE Q30-Q38 remain partially unresolved and mostly P1/P2, while Q31/Q37 have P0 contract intersections: `docs/grill-tournament/grill-decisions-master.md:262-274`; post-roadmap says UIUE joins only after state contract and golden IDs stabilize: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:364-367`. | Keep visual/adoption UIUE items outside mainline blockers; keep state-cells, tool-card-map, DemoVisualState, and golden-run IDs inside Phase 0 contract control. |
| C09 | Keep | The research pack says current four classes silently drop failure/error recovery: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:121`, `:126-130`; it requires explicit proposal recording: `:187-192`. | Decide explicitly. Default risk-leaning conclusion: cut failure class for demo only if recorded, otherwise add minimal recovery seeds for endpoint/parser/load failures. |
| C10 | Keep | `already_state` is called out as distinct from unsupported and not yet classified: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:77`, `:99`, `:119-120`. | Add `already_state`/state-noop as a separate refusal or runtime outcome, not safety refusal and not unsupported. |
| C11 | Keep | Factors are named as a must-pick gap: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:19`, `:132-139`; physical location is `data_recipe.yaml`: `:194-199`. | Treat initial factors as hypotheses, not production truth; write them into `data_recipe.yaml` only with a factor spike and mid-gate monitoring. |
| C12 | Keep | Dual generation legs are a required gap: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:20`, `:141-148`; pure cloud is called uncontrollable: `:201-205`. | Use deterministic template leg plus cloud natural-language leg; 70/30 can be a starting hypothesis, not an unverified final ratio. |
| C13 | Keep | Q24 is an unresolved P0 held-out/leakage question listing required axes: `docs/grill-tournament/grill-decisions-master.md:79`; retrain tasks still only say heldout/OOD diagnostics at a high level: `openspec/changes/retrain-c5-lora-d-domain/tasks.md:28`. | Require held-out by family, value_form, utterance_template, semantic_parent, tool_name, generator_source, scope_tier, and data_class. |
| C14 | Keep | Q06 is still partially unresolved for checkpoint 50/100/150 axes and thresholds: `docs/grill-tournament/grill-decisions-master.md:61`; post-roadmap prescribes early gate behavior at 50/100/150: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:177-185`. | Make mid-training C6 gate a hard retrain gate, with explicit sample axes, thresholds, and stop/human-pause criteria. |
| C15 | Keep | Training stack spike is P0 and must produce tiny-epoch physical evidence: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156-161`; current retrain tasks do not yet include this front gate: `openspec/changes/retrain-c5-lora-d-domain/tasks.md:7-35`. | Treat it as a propose-task hard gate before full C5 training: memory, speed, loss, disk, environment, and fallback receipt. |
| C16 | Keep | Recipe direction says rank16Mainline/LR stay frozen unless evidence reopens them: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:390-393`; Q23 still needs field-level frozen/variable evidence: `docs/grill-tournament/grill-decisions-master.md:78`. | Freeze rank16Mainline, LR, masking core, and parity gates; reopen only after surface/data/parity confounders are excluded by receipts. |
| C17 | Keep | Post-roadmap says 10/23 is generic-frame-era and needs a new D-domain base anchor: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:163-168`; it later says keep 10/23 as historical failure anchor, not D-domain candidate gate: `:371`. | Preserve 10/23 as historical failure anchor and add a new D-domain base recalibration anchor for candidate comparison. |
| C18 | Keep | C6 four-layer independent gates are the selected direction: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:267`; rebuild proposal requires independent four-layer scoring and no status substitution: `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:25-29`. | Define denominators, thresholds, and fail priority per layer; ban aggregate pass-rate from masking unsupported/safety/golden failures. |
| C19 | Keep | Endpoint parity is separated from render parity and endpoint decode spike: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:400`; post-roadmap warns iOS endpoint must start in parallel to avoid late failure: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:170-175`. | Start endpoint spike in parallel with retrain; require render parity, decode smoke, parser/whitelist receipt, and device evidence before endpoint-ready claims. |
| C20 | Keep | Endpoint mlx-swift has no GBNF; main path is LoRA format plus JSON defensive parsing and whitelist: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:379-390`. | Define parser, repair, whitelist digest, and failure enum policy as non-negotiable endpoint hardening; GBNF is fallback-only until proven. |
| C21 | Keep | Q31 says mock cards must be backed by state-cells/tool-card map, not just UI: `docs/grill-tournament/grill-decisions-master.md:86`; paradigm sets the physical chain `tool->IR->state_cell->card->patch`: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:399`. | Treat `tool->IR->state_cell->patch` as mainline contract; UIUE owns presentation/card styling only after consuming that map. |
| C22 | Keep | F3/golden-run requires contract refs, expected route, must-pass, and derived C6 case IDs: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:402`; post-roadmap says UIUE waits for stable golden and C6 IDs: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:366-367`. | Gate demo-golden-run on stable demo10 tool IDs, state cell IDs, C6 case IDs, and no step without mounted tool/state cell. |
| C23 | Keep | Q14 asks when ground-truth subagent review is mandatory: `docs/grill-tournament/grill-decisions-master.md:69`; paradigm says the D-domain flip came from ground-truth subagent review and should enter governance: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:318`. | Mandate ground-truth review for paradigm, SSOT, eval, safety, and raw-derived decisions; output schema should include source list, claim table, cite-verify, redlines, and verdict. |
| C24 | Keep | Q41 already states acceptance layers must not substitute for each other: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:478`; rebuild proposal repeats no mutual impersonation across model-quality/endpoint/golden layers: `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:48-62`. | Adopt a mandatory status vocabulary: `train_health`, `G6-C diagnostic`, `C6 model-quality`, `endpoint candidate`, `demo-golden-run`, `T-PASS`, `V-PASS`, `S-PASS`, `U-PASS`, each with separate receipt fields. |

## Rationale
The strongest candidates are not the ones that ask for the most work; they are the ones that stop an unsafe route transition. C03, C04, C13, C20, and C24 score 25 because each blocks a concrete fake-green path: dual SSOT, stale archived specs, leakage, endpoint parser assumptions, and acceptance vocabulary collapse.

C01/C02 are high score despite duplication because the repo currently contains multiple artifact types with adjacent authority. The hidden assumption to challenge is: "because a document deeply analyzes the next technical route, it is a roadmap." The source explicitly rejects that for `a2-post-roadmap`.

C09-C12 should not be read as "go implement data recipe now." They are pre-propose decisions and spike gates. The risk is that suggested values such as `positive=20` or `template=70%` become production authority without evidence.

C08/C21/C22 are the UIUE isolation cluster. The correct framing is not "UIUE is outside Phase 0" or "UIUE blocks Phase 0"; the boundary is contract consumption. State cells, tool-card mapping, visual state, C6 case IDs, and golden-run IDs are mainline contract surfaces. Visual language and component adoption are UIUE/P1+ unless they touch those surfaces.

C24 should be treated as a top-line judge item even if other candidates cover parts of it. A loop can still "pass" every local technical question and fail the project if train health, model quality, endpoint readiness, and demo proof are allowed to share a green word.
