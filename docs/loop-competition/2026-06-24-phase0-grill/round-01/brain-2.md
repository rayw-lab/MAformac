# Brain 2 - Round 01

## Scope And Evidence
- Perspective: C5/C6 model quality, D-domain LoRA data recipe, LoRA failure prevention, home-llm gap absorption, endpoint parity, and model-quality status separation.
- Source boundary: local-only review. I did not use web because no new external time-sensitive fact was needed for scoring.
- Blindness boundary: I did not read other `brain-*.md` files or any `judge.md` file.
- High-weight source used: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md`, which explicitly classifies itself as a "post-A2 C5/C6 model-quality decision pack + pre-propose checklist" and not as SSOT/live roadmap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`).
- Key local anchors:
  - Current grill SSOT and scope facts: `docs/grill-tournament/grill-decisions-master.md:11`, `docs/grill-tournament/grill-decisions-master.md:22`, `docs/grill-tournament/grill-decisions-master.md:27`, `docs/grill-tournament/grill-decisions-master.md:41`.
  - D-domain surface and 0/23 root cause: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:15`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:16`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:31`.
  - C5 data/recipe gaps: `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:68`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:91`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:121`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:134`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:143`.
  - C6 and endpoint separation: `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:24`, `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:29`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:357`, `docs/grill-tournament/grill-decisions-master.md:197`.

## Keep
| Candidate | Score | Reason |
|---|---:|---|
| C03 | 25 | Full/demo artifact boundary is a P0 SSOT failure-prevention question; it blocks duplicated training/eval surfaces. |
| C09 | 25 | Failure/error-recovery class is the clearest home-llm gap and prevents silent recipe loss. |
| C11 | 25 | Data-class ratios directly control false gains/collapse and are missing from current skeleton. |
| C13 | 25 | Held-out axes are the main defense against memorization and lineage leakage. |
| C14 | 25 | Mid-training C6 gate is the direct 0/34 recurrence brake. |
| C17 | 25 | Base anchor coexistence is mandatory to avoid comparing a D-domain candidate against a stale generic-frame anchor. |
| C18 | 25 | C6 scoring layers and denominators define model-quality truth; weak scoring makes every later pass suspect. |
| C19 | 25 | Endpoint parity must start early or Mac model-quality will be mistaken for endpoint readiness. |
| C20 | 25 | Endpoint without GBNF makes parser/repair/whitelist/failure enum the real safety boundary. |
| C24 | 25 | Status vocabulary prevents train-health/model-quality/endpoint/demo pass conflation, a recurring project failure mode. |
| C04 | 24 | Archived specs may now be behaviorally stale; disposition must be explicit. |
| C06 | 24 | Canonical enums/fields are needed to keep route, surface, runtime, safety, and readback layers from faking each other. |
| C12 | 24 | Template-vs-cloud generation ratio is a concrete home-llm absorption decision. |
| C02 | 23 | Responsibility split among roadmap-like artifacts is needed before propose/apply resumes. |
| C05 | 23 | Pocock stage triage prevents "docs look done, start training" recurrence. |
| C15 | 23 | Training stack spike is a hard physical precondition before full C5 training. |

## Delete
| Candidate | Reason |
|---|---|
| None | All 24 candidates have at least some verifiable decision leverage. The low-scoring ones should be rewritten or merged, not deleted. |

## Merge
| Candidates | Proposed canonical wording | Reason |
|---|---|---|
| C01 + C02 | "Classify each roadmap-like artifact and define its authority boundary, owner, and allowed use before retrain/rebuild proposes." | C01 is answerable from source; C02 is the higher-leverage operating map. |
| C09 + C10 | "Define the C5 data/refusal taxonomy, including failure, already_state, unsupported, safety, and readback renderer exclusions." | Same taxonomy surface. C10 is a subcase of C09 unless it forces separate labels. |
| C11 + C12 | "Define C5 data_recipe.yaml: category_factors plus deterministic template/cloud generation legs and spike evidence." | Both land in the same data recipe artifact and spike. |
| C13 + C18 | "Co-design held-out axes with C6 denominators so memorization, unsupported, safety, and positive regression are measured independently." | Split axes without scoring layers is paper coverage; scoring without split axes is leakage-prone. |
| C19 + C20 | "Define endpoint parity: render diff, decode smoke, parser/repair/whitelist policy, failure enums, and minimum endpoint-ready evidence." | Endpoint readiness is meaningless without the parser/repair policy. |
| C21 + C22 | "Stabilize tool-to-state-to-card IDs before demo-golden-run/UIUE consumption." | Golden-run and UIUE need the same ID chain and ownership boundary. |

## Rewrite
| Candidate | Proposed wording | Reason |
|---|---|---|
| C01 | "Record `a2-post-roadmap` as a pre-propose model-quality decision pack, and list what it may feed into OpenSpec tasks." | Current wording asks a question already answered by the document banner; rewrite into a closeout action. |
| C08 | "Which UIUE findings are non-blocking visual work, and which state/C3-C6 contract intersections must remain Phase 0 blockers?" | The useful part is the contract intersection, not UIUE triage in general. |
| C15 | "Should training-stack spike be a proposed task that must run before full training, and what receipt proves the chosen backend?" | The evidence says do not run it as a separate pre-propose spike; write it into the change tasks. |
| C17 | "How should old generic-frame base 10/23 remain as historical failure anchor while new D-domain base becomes candidate gate?" | Prevents the false binary of keeping or deleting the old anchor. |
| C23 | "Which decision classes require ground-truth or cross-vendor review, and what schema proves independence, source coverage, and verdict deltas?" | Needs an output schema, not just a policy statement. |

## Missing Risks
- C5 data taxonomy is missing an explicit `already_state` status/no-op refusal owner. This can be confused with unsupported or safety refusal even though home-llm treats it as a separate refusal reason (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:77`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:99`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:119`).
- Endpoint parity needs both model-output format and runtime parse policy. The docs already say endpoint GBNF is not available and must fall back to LoRA format plus JSON defensive parsing and whitelist enforcement (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:379`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:390`).
- D-domain base recalibration must not erase the old base 10/23. The old anchor explains the failure; the new anchor governs D-domain candidate comparison (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:165`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371`).
- Demo golden-run should not consume unstable IDs. UIUE can only merge after `tool -> IR -> state_cell -> card -> patch` and C6 case IDs are stable (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:364`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:366`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:367`).

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Priority | Needs User Grill? |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C01 | 4 | 5 | 3 | 4 | 4 | 20 | P0 | No |
| C02 | 5 | 4 | 4 | 5 | 5 | 23 | P0 | Yes |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C04 | 5 | 5 | 5 | 5 | 4 | 24 | P0 | Yes |
| C05 | 5 | 4 | 4 | 5 | 5 | 23 | P0 | Yes |
| C06 | 5 | 4 | 5 | 5 | 5 | 24 | P0 | Yes |
| C07 | 4 | 4 | 4 | 5 | 4 | 21 | P0 | Yes |
| C08 | 3 | 4 | 4 | 3 | 4 | 18 | P1 | Yes |
| C09 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C10 | 4 | 5 | 4 | 4 | 5 | 22 | P1 | Yes |
| C11 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C12 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C13 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C14 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C15 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | Yes |
| C16 | 4 | 5 | 4 | 5 | 4 | 22 | P1 | Yes |
| C17 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C18 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C19 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C20 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C21 | 4 | 5 | 4 | 4 | 4 | 21 | P0 | Yes |
| C22 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C23 | 4 | 4 | 4 | 4 | 5 | 21 | P1 | Yes |
| C24 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |

## Candidate Notes
| Candidate | Verdict | Evidence | Recommended Conclusion |
|---|---|---|---|
| C01 | Keep as rewrite/merge | The audit file already declares it is a model-quality decision pack/pre-propose checklist and not SSOT/live roadmap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`); it also says the next step is Phase 0 grill debt, not retrain propose (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:331`). | Classify `a2-post-roadmap` as a high-weight research decision pack and pre-propose checklist, not progress SSOT or live roadmap. Merge into C02 for authority mapping. |
| C02 | Keep | Current SSOT is grill-master plus paradigm authority (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:6`); grill-master says it is the unified grill decision authority (`docs/grill-tournament/grill-decisions-master.md:11`); A2/retrain/rebuild/golden are DEFERRED outside A2 (`docs/grill-tournament/cascade-inventory.md:5`). | Produce an authority matrix: grill-master owns decisions, paradigm owns surface, OpenSpec changes own executable contracts after propose, `a2-post-roadmap` feeds C5/C6 tasks, old roadmaps are historical or recovery references, UIUE is gated by stable state/C6 IDs. |
| C03 | Keep | Q04 is explicitly pending P0 for `--scope=full` vs `--scope=demo` artifact boundary (`docs/grill-tournament/grill-decisions-master.md:59`, `docs/grill-tournament/grill-decisions-master.md:233`); A2 codegen says both scopes derive from 3990 and are not two SSOTs (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:265`). | Decide a concrete artifact matrix: full=1538 lightweight skeleton for unsupported/OOS, demo=562 heavy training/eval surface, both generated from one 3990 contract with digest/diff proof. |
| C04 | Keep | Q08 asks which archived specs changed (`docs/grill-tournament/grill-decisions-master.md:63`); cascade already marks semantic-function, tool-execution, vehicle-tool-bench, and lora-training as needing modifications or boundary statements (`docs/grill-tournament/cascade-inventory.md:78`, `docs/grill-tournament/cascade-inventory.md:80`, `docs/grill-tournament/cascade-inventory.md:81`, `docs/grill-tournament/cascade-inventory.md:83`). | Keep as P0. Decide per archived spec: no-change, docs cleanup, MODIFY change, or new change. Do not silently rely on archived specs after D-domain and four-layer C6. |
| C05 | Keep | Q12 is pending P0 stage triage (`docs/grill-tournament/grill-decisions-master.md:67`); the audit says A2 done does not mean retrain/base recalibration should start (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:331`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:346`). | Assign stages before implementation: Phase 0 grill debt first, then propose retrain/rebuild with embedded gates, then apply physical spikes/training only after agreement. |
| C06 | Keep | SRD separates route tags (`explicit/implicit/ambiguous/rejected/passthrough`) from D-domain surface (`docs/srd-three-layer-intent-routing.md:52`, `docs/srd-three-layer-intent-routing.md:64`); three-layer model distinguishes canonical IR, model-visible surface, runtime tier (`docs/srd-three-layer-intent-routing.md:178`, `docs/srd-three-layer-intent-routing.md:182`, `docs/srd-three-layer-intent-routing.md:188`). | Define canonical enums and trace fields for route_tier, clarify_tag, model_surface, runtime_scope, execution_outcome, readback_result, unsupported_reason, and safety_refusal_reason. |
| C07 | Keep, lower than C03/C04/C06 | Q20 and Q21 remain pending P0 (`docs/grill-tournament/grill-decisions-master.md:75`, `docs/grill-tournament/grill-decisions-master.md:76`); key decisions D30/D35/D37 have already evolved in CLAUDE (`CLAUDE.md:77`, `CLAUDE.md:81`). | Build a manifest for D1-D37 and MASTER protocol: keep/modify/superseded/deferred with one evidence line and cascade target. Do not bulk-rewrite. |
| C08 | Keep as rewrite | UIUE has many pending items but the model-quality link is the state/C3-C6 intersection (`docs/grill-tournament/grill-decisions-master.md:265`, `docs/grill-tournament/grill-decisions-master.md:271`); UIUE must wait for stable state and C6 IDs (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:364`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:367`). | Keep only the blocker split: UIUE visual work stays outside mainline blockers, but state contract, tool-card map, C6 IDs, and demo-golden linkage stay Phase 0. |
| C09 | Keep | home-llm has five data classes including failure (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:70`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:78`); MAformac four-class recipe silently drops failure (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:121`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128`). | Must grill. Recommended default: explicitly omit failure class for demo scope unless endpoint/parser instability argues for a tiny recovery seed. Record the delta in retrain-c5 proposal. |
| C10 | Keep, merge with C09 | home-llm refusal distinguishes `not_available` from `already_state` (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:77`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:99`); MAformac safety refusal is not equivalent (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:119`). | Classify `already_state` as state-noop/readback outcome, not unsupported and not safety refusal. It may be renderer/code-owned rather than LoRA-owned, but must be named. |
| C11 | Keep | home-llm ratios are explicit and heavily weight templated data (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:80`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:91`); MAformac lacks ratios and risks false collapse/gains (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:134`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:135`). | Set initial factors in `data_recipe.yaml`, likely positive=20, unsupported=8, safety=4, followup=2, then require a small spike before production. |
| C12 | Keep | Template parameterization is the deterministic coverage leg (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:143`); pure cloud generator is natural but less controllable (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:144`); suggested split is template 70 percent/cloud 30 percent (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:145`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:148`). | Use two legs: deterministic template leg for coverage and parameter invariants, cloud natural-language leg for demo phrasing, with explicit ratio and judge rules. |
| C13 | Keep | Q24 requires D-domain/four-class held-out axes (`docs/grill-tournament/grill-decisions-master.md:79`); SRD warns training-distribution self-eval creates fake gains and needs held-out/multi-harness decontamination (`docs/srd-three-layer-intent-routing.md:263`). | Define held-out axes across family, value_form, tool_name, semantic_parent, utterance template, generator source, scope_tier, and data_class. Tie these axes to C6 denominators. |
| C14 | Keep | D1 already locks 50/100/150 checkpoints (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:267`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:391`); post-roadmap says mid-training gate is needed to avoid discovering all-zero at the end (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:177`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:181`). | Add `mid_training_gate.yaml`: sample golden and fuzz at 50/100/150, pause/stop on trigger/action collapse, and never wait until final checkpoint to learn it is 0. |
| C15 | Keep with rewrite | Training stack spike is P0 because home-llm assumes CUDA/24GB VRAM while Qwen3-1.7B is larger (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:159`); the same doc says these gates should be written into OpenSpec tasks, not run as separate pre-propose spikes (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:346`). | Make it a proposed hard task before full training: tiny epoch receipt with memory, speed, loss, env, and backend choice. Do not treat it as a standalone task before propose alignment. |
| C16 | Keep | Recipe is locked: rank16Mainline, scale=20, LR1e-4, no recipe reopen for A2 surface migration (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:391`, `openspec/changes/retrain-c5-lora-d-domain/proposal.md:28`, `openspec/changes/retrain-c5-lora-d-domain/proposal.md:44`). | Freeze rank/scale/LR/masking semantics unless surface parity, data quality, and C6 gates are already clean. Backend is variable only through C15 stack evidence. |
| C17 | Keep | 10/23 base is old generic-frame anchor and will change under D-domain surface (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:165`); new D-domain base anchor should govern candidate diff while old 10/23 remains historical failure evidence (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:166`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371`). | Keep two anchors: old generic 10/23 as failure history, new D-domain base as candidate gate. Do not compare LoRA candidate to stale generic-frame base as the main release criterion. |
| C18 | Keep | Rebuild-C6 proposal requires D-domain expected calls, four independent doors, action hard_pass, readback renderer, and base-vs-LoRA same harness (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:24`, `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:25`, `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:29`). | Define exact layers, denominators, thresholds, and fail priority for golden, demo_fuzz, unsupported, safety, model-quality, endpoint, and readback. No aggregate pass_rate can mask an axis. |
| C19 | Keep | Endpoint/iOS must start in parallel because late LoRA loading, parsing, TTFT, or OOM failure would be a demo disaster (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:170`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:173`); endpoint V-PASS is explicitly not signed by Mac/simulator evidence (`openspec/changes/retrain-c5-lora-d-domain/proposal.md:48`). | Start endpoint spike alongside retrain preparation. Minimum evidence: target device, LoRA load, parser/repair path, whitelist digest, render parity, smoke decode, TTFT/memory receipt. |
| C20 | Keep | Endpoint constrained decoding is not guaranteed; the project must use LoRA format plus defensive JSON parsing and whitelist enforcement (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:379`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:390`); SRD says parser repair must still pass semantic gate and fail closed (`docs/srd-three-layer-intent-routing.md:310`, `docs/srd-three-layer-intent-routing.md:311`). | Define parser policy as fail-closed: repair format only, then whitelist/tool schema/semantic/precondition gates; unknown tool, extra tool, stale state, length finish, or repair over threshold become explicit failure enums. |
| C21 | Keep | B2 maps tool to IR to state_cell to card to patch and requires 10-family state-cells expansion (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:399`); UIUE should wait until state contract is aligned (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:364`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:366`). | Treat the chain as mainline contract artifact with UIUE as consumer. UI can own rendering, but the ID chain and patch semantics must live in C2/C3/C6 contracts. |
| C22 | Keep, lower priority than C19-C21 | Demo-golden-run should only begin after C5/C6 contracts are green and identifiers are stable (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:361`, `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:367`); golden-run should be contract playback, not only a script (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:490`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:491`). | Entry condition: stable tool IDs, IR IDs, state_cell IDs, card IDs, C6 case IDs, expected_state_delta, readback renderer, and must_pass semantics. UIUE consumes only after that. |
| C23 | Keep | The D-domain flip was made because ground-truth source contradicted prior B-frame assumptions (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:3`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:6`); cross-vendor audit caught different bug sets and was not redundant (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:53`, `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:54`). | Require ground-truth/cross-vendor review for paradigm, SSOT, eval scoring, safety, raw-derived, endpoint, and release-pass decisions. Schema should include source coverage, dissent, verifier commands, and verdict deltas. |
| C24 | Keep | Grill-master Q41 already forbids T-PASS/G6-C/C6 model-quality/endpoint/demo/V-S-U pass conflation (`docs/grill-tournament/grill-decisions-master.md:197`, `docs/grill-tournament/grill-decisions-master.md:478`); post-roadmap says train-health, model-quality, endpoint, and readback must be signed separately (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:357`). | Define status vocabulary now: data_ready, train_health, lora_candidate, g6c_diagnostic, c6_model_quality, endpoint_candidate, demo_golden_ready, T-PASS, V-PASS, S-PASS, U-PASS, with forbidden implication rules. |

## Rationale
The highest scores go to candidates that physically prevent a repeat of the C5 failure pattern: train/eval/runtime surface mismatch, stale base comparison, missing mid-training gate, under-specified data recipe, endpoint readiness claims from Mac-only evidence, and pass-status conflation.

The main negative finding is that several candidates are phrased as separate questions but must land in the same artifacts. The strongest landing artifacts are `retrain-c5` `data_recipe.yaml`, `retrain-c5` `design.md` mid-training gate, `rebuild-c6` scoring spec, endpoint parity receipt, and a status vocabulary table. The project should avoid turning these into parallel prose decisions that never become machine-checkable.
