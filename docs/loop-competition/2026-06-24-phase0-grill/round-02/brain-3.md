# Brain 3 - Round 02

## Scope And Evidence
- Blind scope: I read `candidates-blind.md`, `contract.md`, and local source files from the contract source pool. I did not read round-01 files, other round-02 brain files, judge files, or `ledger.md`. No web evidence was used.
- Architectural lens: INDIGO, contrarian architecture skeptic. I score higher where a question prevents authority drift, boundary pollution, premature implementation, or status conflation.
- Core evidence anchors:
  - OpenSpec is the behavioral authority layer, and `openspec/specs/` is the fact source after archive; "agree before build" is explicit in `CLAUDE.md:22-27`, `CLAUDE.md:45`, and `CLAUDE.md:97`.
  - Current authority is split, not simple. `CLAUDE.md:119-134` says the old roadmap is historical and current authority is grill SSOT + paradigm authority + cascade inventory; `CONTEXT.md:22-37` gives the same routing map.
  - `a2-post-roadmap` self-classifies as "post-A2 C5/C6 model-quality decision pack + pre-propose checklist", not SSOT/live roadmap, at `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6` and `:325`.
  - Grill decision authority is centralized in `docs/grill-tournament/grill-decisions-master.md:9-19`, with pending question status in `:49-80` and remaining grill order in `:276-284`.
  - D-domain surface is authoritative while canonical IR remains device/action/value: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:19-27`; SRD repeats the same split in `docs/srd-three-layer-intent-routing.md:64-78` and `:178-190`.
  - A2 is complete as code-only, not as training/eval/golden/voice completion: `docs/handoffs/2026-06-24-a2-merged-d-domain.md:4-19`, `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:14-18`, and `:49-51`.
  - The retrain and C6 OpenSpec changes are DRAFT skeletons and explicitly deferred until human-reviewed propose: `openspec/changes/retrain-c5-lora-d-domain/proposal.md:1-6`, `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:1-6`.
  - Several old/current documents still carry drift risk: `docs/README.md:17` still names the old roadmap as "推进事实源", while `CLAUDE.md:119` says that role has migrated; `docs/grill-tournament/cascade-inventory.md:173-175` says T5 historical banner work is still pending.

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C03 | 25 | Full/demo is the highest-risk false dichotomy. It can silently create two SSOTs unless artifact depth, derivation path, and drift gates are defined from the 3990 source. |
| C17 | 25 | Base 10/23 vs a new D-domain base anchor decides whether later candidate claims are honest comparisons or moving baselines. |
| C24 | 25 | Status vocabulary is a project-wide safety rail. The repo repeatedly separates train health, model quality, endpoint, demo, and V/S/U pass states; this question prevents false completion. |
| C02 | 24 | Authority split must be resolved before any downstream propose/apply. It prevents old roadmaps, research packs, and DRAFT OpenSpec skeletons from carrying the wrong authority. |
| C04 | 24 | Archived specs are the contract layer. If D-domain/four-layer C6 changed observable behavior, the disposition must be explicit, not hidden in docs cleanup. |
| C06 | 24 | Cross-layer enum/field normalization is needed before C3/C4/C6 traces and UI states can be compared without semantic drift. |
| C13 | 24 | Held-out axes are the main defense against D-domain memorization, lineage leakage, and fake gains. |
| C14 | 24 | Mid-training gates are the direct countermeasure to the 0/34/0/23 failure mode. |
| C18 | 24 | Four-layer C6 only works if denominators, thresholds, and fail priority are explicit; otherwise aggregation reintroduces fake-green. |
| C05 | 23 | Pocock staging is not ceremony here. It blocks the sequence error of jumping from research checklist to implementation. |
| C08 | 23 | UIUE can either enrich the demo or pollute Phase 0. This question forces the contract intersection boundary. |
| C15 | 23 | Training-stack feasibility must produce physical evidence before the project commits to formal C5 training. |
| C21 | 23 | The `tool -> IR -> state_cell -> card -> patch` chain crosses mainline and UIUE. Ownership must be drawn before UI work becomes an implicit contract. |

## Delete
| Candidate | Reason |
|---|---|
| None | All 24 candidates expose a real decision or risk. Some should be merged or rewritten, but none should be deleted outright. |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C01 + C02 | Define the authority matrix for post-A2 artifacts: classify `a2-post-roadmap`, old roadmap, C5 recovery roadmap, grill SSOT, OpenSpec DRAFT changes, and UIUE roadmap by role, allowed claims, forbidden claims, and next carrier. | C01 is a sub-question of C02. Treating it alone risks over-promoting a research checklist into a roadmap. |
| C09 + C10 | Define the C5 outcome/data taxonomy for positive, followup, unsupported, safety refusal, already_state/no-op, and optional failure recovery; specify whether each is trained, rendered in code, or excluded with rationale. | Both questions are really about refusal/no-op taxonomy and whether MAformac silently drops useful negative/recovery behavior. |
| C11 + C12 | Define C5 data recipe controls: category factors plus deterministic-template/cloud-natural-language mix, with spike evidence required before production values freeze. | Ratios and generation source mix are coupled. Separate answers can create contradictory recipe authority. |
| C14 + C18 | Define C6 gating as one contract family: mid-training sample gates plus final four-layer denominators, thresholds, fail priority, and blocked/continue/human-pause semantics. | The mid-training gate and final bench are different moments in the same measurement system. They should share vocabulary and denominator rules. |
| C19 + C20 | Define endpoint-readiness policy: when endpoint parity starts, what evidence is minimum, and what parser/repair/whitelist/failure-enum rules apply without endpoint GBNF. | Endpoint timing without parser policy is toothless; parser policy without timing can become premature endpoint implementation. |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C01 | What claims may `a2-post-roadmap` make as a decision pack/pre-propose checklist, and what claims must remain owned by grill SSOT or OpenSpec changes? | The source already says it is not SSOT or a live roadmap. The useful question is boundary enforcement. |
| C04 | For each archived spec touched by D-domain or four-layer C6, decide `no observable change`, `MODIFY via OpenSpec change`, `new capability/change`, or `docs-only cleanup`, with evidence. | "Which specs changed" is too broad unless the disposition path is part of the answer. |
| C05 | For each follow-up item, state current Pocock stage, exit evidence, forbidden next action, and OpenSpec carrier before implementation. | The stage label alone can become process theater. The exit and forbidden action are what prevent premature build. |
| C07 | For D14/D16/D30/D35/D37 and any D1-D37 item directly touched by D-domain, publish `keep/modify/superseded/defer` with evidence; do not re-open unaffected decisions. | "All D1-D37" risks expensive document churn. Scope it to touched decisions plus a catch-all grep. |
| C11 | What initial category-factor hypotheses should go into the proposal, and what small spike evidence is required before those ratios become production defaults? | Freezing ratios before a spike repeats the "metadata says ready" failure pattern. |
| C15 | Treat training-stack spike as a propose hard gate: what tiny epoch evidence, resource receipt, and fallback trigger must exist before any full C5 training task can be checked done? | It should not be a loose pre-propose research task or a hidden apply task. |
| C19 | What endpoint evidence can run in parallel without becoming an endpoint-ready claim, and what must wait for C5/C6 model-quality evidence? | This avoids the false choice between "serial endpoint too late" and "endpoint pollutes training/C6 now." |
| C23 | Which decision classes require ground-truth/cross-vendor review, and which are explicitly excluded to avoid governance inflation? | Mandatory review for everything would become boundary pollution and slow the demo. |

## Missing Risks
- The most dangerous missing risk is document-role inflation: a strong research checklist can accidentally become a live roadmap. The repo already warns that `a2-post-roadmap` is not SSOT (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`) and that its gates should be written into OpenSpec tasks rather than run as standalone spikes (`:346`).
- `docs/README.md` still contains an older "roadmap as推进事实源" line at `docs/README.md:17`, while `CLAUDE.md:119` says that authority has migrated. The review should explicitly catch this kind of split-brain source routing.
- `c5-recovery-2026-06-22/roadmap.md` is still not fully bannered as historical per `docs/grill-tournament/cascade-inventory.md:173-175`. Any question that reuses it must classify it as historical context, not current authority.
- C20 needs a stronger repair-rate and fail-closed dimension. Without endpoint GBNF, parser repair can quietly become "repair-to-action"; SRD warns parser repair must fail closed after semantic/precondition gates (`docs/srd-three-layer-intent-routing.md:310-315`).
- C21/C22 should explicitly require stable IDs before UIUE consumes contracts. Otherwise golden-run and UI cards will freeze around unstable state cells/case IDs.
- C23 should include a negative list. "Mandatory ground-truth review" is valuable for SSOT/eval/safety/raw-derived decisions, but broadening it to every UI or copy decision would be governance theater.

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Priority | Needs User Grill? |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C01 | 5 | 5 | 4 | 4 | 4 | 22 | P0 | No |
| C02 | 5 | 5 | 5 | 5 | 4 | 24 | P0 | Yes |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C04 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C05 | 5 | 4 | 5 | 5 | 4 | 23 | P0 | Yes |
| C06 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C07 | 4 | 4 | 4 | 5 | 5 | 22 | P0 | Yes |
| C08 | 5 | 4 | 5 | 4 | 5 | 23 | P0 | Yes |
| C09 | 4 | 4 | 4 | 4 | 5 | 21 | P1 | Yes |
| C10 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C11 | 4 | 4 | 4 | 5 | 4 | 21 | P1 | Yes |
| C12 | 4 | 5 | 4 | 5 | 4 | 22 | P1 | Yes |
| C13 | 5 | 5 | 5 | 4 | 5 | 24 | P0 | No |
| C14 | 5 | 5 | 5 | 5 | 4 | 24 | P0 | Yes |
| C15 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | No |
| C16 | 4 | 4 | 4 | 5 | 4 | 21 | P1 | Yes |
| C17 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C18 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C19 | 4 | 4 | 4 | 5 | 4 | 21 | P1 | Yes |
| C20 | 4 | 5 | 4 | 5 | 4 | 22 | P0 | No |
| C21 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | Yes |
| C22 | 4 | 5 | 4 | 5 | 4 | 22 | P0 | Yes |
| C23 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C24 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |

## Candidate Notes
| Candidate | Verdict | Evidence | Recommended Conclusion |
|---|---|---|---|
| C01 | Keep, merge into C02 | `a2-post-roadmap` self-classifies as decision pack/pre-propose checklist, not SSOT or live roadmap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`, `:325`). | Keep as authority-boundary subquestion; do not re-litigate its identity unless a source contradicts the banner. |
| C02 | Keep | Current authority is grill SSOT + paradigm + cascade per `CLAUDE.md:119`; `docs/README.md:17` still has older wording. | P0 authority matrix before any propose/apply. |
| C03 | Keep | Scope split is already directionally set: full=1538 light catalog, demo=562 heavy catalog, both derived from 3990 (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:264-266`; `docs/grill-tournament/grill-decisions-master.md:59`). | Highest-priority grill. Demand artifact matrix and drift proof from one SSOT. |
| C04 | Keep, rewrite | Archived specs are behavior facts (`CLAUDE.md:27`, `:58`); cascade marks `tool-execution`, `vehicle-tool-bench`, `lora-training`, and semantic-function-contract as modify candidates (`docs/grill-tournament/cascade-inventory.md:78-83`). | P0 disposition table per archived spec. |
| C05 | Keep, rewrite | Pocock gates stage before OpenSpec/apply (`CLAUDE.md:22-27`, `docs/project/collaboration-and-roles.md:76-101`); post-roadmap warns next is Phase 0 grill, not retrain propose (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:329-347`). | Keep, but require exit conditions and forbidden next actions. |
| C06 | Keep | SRD now has route tags and D-domain surface framing (`docs/srd-three-layer-intent-routing.md:52-60`, `:64-78`); C6/Q41 status separation is locked (`docs/grill-tournament/grill-decisions-master.md:193-198`). | Define shared enum vocabulary before C3/C4/C6/UIUE consume it. |
| C07 | Keep, rewrite narrower | D1-D37 are locked but known touched decisions include D14/D16/D30/D35/D37 (`CLAUDE.md:77-81`); master flags Q20 as pending P0 (`docs/grill-tournament/grill-decisions-master.md:75`, `:245`). | Keep, but avoid reopening untouched decisions. |
| C08 | Keep | UIUE is partially mapped but still pending in U11-U31 (`docs/grill-tournament/grill-decisions-master.md:126-151`); handoff says UIUE is a next branch, not current C5 training (`docs/handoffs/2026-06-24-a2-merged-d-domain.md:19-20`). | Decide mainline intersections only: state contract, C3/C6 fields, golden IDs. |
| C09 | Keep, merge with C10 | `a2-post-roadmap` identifies missing failure class as GAP 1 and current four classes as silent-drop risk (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:115-130`). | Explicitly record whether failure recovery is excluded, code-rendered, or trained. |
| C10 | Keep, merge with C09 | `already_state` is distinct from unsupported and safety in home-llm evidence (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:77-79`, `:119-121`). | Classify state-noop separately; do not hide it under safety refusal. |
| C11 | Keep, merge with C12 | Factors are not fixed; home-llm-derived examples are evidence, not final production defaults (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:132-139`, `:194-199`). | Put initial hypotheses in `data_recipe.yaml`, gated by a spike. |
| C12 | Keep, merge with C11 | Template plus cloud dual-leg is recommended because pure cloud is uncontrolled (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:141-149`, `:201-205`). | Define dual-leg ratio with evidence, not taste. |
| C13 | Keep | D-domain data needs multi-axis leakage defense; master Q24 names family, value_form, template, parent, tool, generator, scope_tier, data_class axes (`docs/grill-tournament/grill-decisions-master.md:79`). | P0 technical requirement; can be drafted without user grill if evidence is clear. |
| C14 | Keep, merge with C18 | Multi-checkpoint 50/100/150 is already partially accepted but lacks axes and thresholds (`docs/grill-tournament/grill-decisions-master.md:61`, `:252`). | P0; user should approve blocked/pause semantics. |
| C15 | Keep, rewrite | Training stack spike is called out as P0-1 with tiny epoch evidence (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156-162`); retrain proposal is DRAFT/deferred (`openspec/changes/retrain-c5-lora-d-domain/proposal.md:1-6`). | Make it a propose hard gate before full training. |
| C16 | Keep | Recipe is mostly frozen around rank16Mainline/LR, but re-open evidence remains pending (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:390-394`; `docs/grill-tournament/grill-decisions-master.md:78`). | Keep as P1. It prevents casual recipe thrash. |
| C17 | Keep | Base 10/23 is historical/generic-frame-era and needs D-domain recalibration without erasing the old failure anchor (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:163-169`, `:369-372`). | P0. Preserve old anchor as history; govern new candidate comparison by D-domain base. |
| C18 | Keep | Four-layer C6 is accepted direction but final denominators/thresholds are pending (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:266-268`; `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:18-24`). | P0 C6 contract question. |
| C19 | Keep, rewrite | Endpoint/iOS parallel start is a risk control, but A2 explicitly did not claim endpoint readiness (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:170-176`; `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:14-18`). | Run endpoint spike in parallel, but forbid endpoint-ready claims until minimum evidence exists. |
| C20 | Keep | Endpoint GBNF is not available on the main endpoint path; parser/whitelist/fail-closed policy is required (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:377-390`; `docs/lessons-learned.md:17-18`). | P0 technical policy; can be specified without broad user debate. |
| C21 | Keep | Tool-to-card chain is explicitly named as B2/UIUE boundary (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:396-404`; `docs/grill-tournament/grill-decisions-master.md:86`). | Define shared contract ownership before UIUE hardens visuals. |
| C22 | Keep | Golden-run must be contract replay, not a visual script, and must avoid unbuilt cells/tools (`docs/grill-tournament/grill-decisions-master.md:92`, `:121-124`; paradigm `:401-403`). | P0 entry condition for demo-golden-run. |
| C23 | Keep, rewrite | Ground-truth subagent caught the D-domain paradigm flip; master has Q14 pending (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:104-110`; `docs/grill-tournament/grill-decisions-master.md:69`). | Keep, but include trigger and exclusion list. |
| C24 | Keep | Q41 locks separation of T-PASS, G6-C, C6 model-quality, endpoint candidate, demo-golden-run, V/S/U pass (`docs/grill-tournament/grill-decisions-master.md:193-198`); lessons also warn train health is not model quality (`docs/lessons-learned.md:34-35`). | Top-tier P0. Establish a status vocabulary before any closeout. |

## Rationale
The strongest candidates are not the most implementation-shaped ones. They are the ones that stop the repo from letting the wrong document carry authority. The current repo state has several overlapping carriers: grill SSOT, paradigm authority, cascade inventory, DRAFT OpenSpec skeletons, historical roadmaps, an A2 closeout, and `a2-post-roadmap`. The first job is to mark what each may decide.

The main false dichotomies are:
- "roadmap vs not roadmap" for C01/C02. The better frame is claim boundary by artifact.
- "`--scope=full` vs `--scope=demo`" for C03. The real risk is not two scopes; it is two SSOTs.
- "train now vs do more research" for C11-C16. The better frame is proposal hard gates with physical evidence.
- "UIUE outside vs mainline" for C08/C21/C22. The correct split is contract ownership: IDs, state cells, trace/outcome fields, and golden case references stay mainline; visual presentation can remain UIUE.
- "old base 10/23 is invalid vs still governs everything" for C17. It should remain a historical failure anchor, while a new D-domain base governs candidate comparison.

My bottom line: keep all 24, but do not let all 24 become separate workstreams. Merge taxonomy pairs, recipe pairs, C6 gate pairs, and endpoint policy pairs. Then force the remaining P0 set to produce authority matrices, disposition tables, enums, gates, and status vocabulary before any implementation can honestly start.
