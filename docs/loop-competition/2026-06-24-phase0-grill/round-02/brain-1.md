# Brain 1 - Round 02

## Scope And Evidence

- Blind scope honored: I read `candidates-blind.md`, `contract.md`, project entry docs, and local source files needed for line-cited evidence. I did not read round-01 outputs, other brain outputs, judge outputs, or `ledger.md`.
- Audit posture: RED. I score a grill question as valuable only if it can force a physical artifact, a commandable receipt, a frozen contract, or an explicit stop/go decision. Questions that merely rename already-shot decisions are fake rigor.
- Project baseline: MAformac is a 5-minute offline demo assistant, not production car control (`CLAUDE.md:16-18`). OpenSpec specs are the behavior SSOT and implementation must wait for agreement (`CLAUDE.md:23-27`). LoRA, safety, and SSOT discipline are explicitly non-optional even in demo-tool mode (`CLAUDE.md:95-97`).
- Failure context: C5 already failed at 0/34 before the D-domain flip (`CLAUDE.md:109-117`). Current progress authority has moved away from the old roadmap into the grill SSOT and D-domain paradigm docs (`CLAUDE.md:119-124`).
- Current authority values: the active context says 3990 semantic candidates, 671 retained, 1538 target-candidates, 10 demo families, 191/562/2159 counts, and warns not to train 3990 or treat 562 as a tool count (`CONTEXT.md:7-20`). The master grill doc calls itself the single authority for decisions and pending questions (`docs/grill-tournament/grill-decisions-master.md:11-20`).
- Open blockers are real: Q04 full/demo scope is pending, Q08 archived spec disposition is pending, Q12 Pocock stage is pending, Q16-Q21 CAS questions are pending, Q24 held-out axes are pending, Q25 four-layer C6 is partial, and Q28 endpoint parity is partial (`docs/grill-tournament/grill-decisions-master.md:56-96`). The same master ranks Q04, Q08, Q12, Q16-Q21, Q24, and Q25 as material next-order questions (`docs/grill-tournament/grill-decisions-master.md:221-284`).
- D-domain flip is not cosmetic: the project rejected the B-frame/generic action surface and anchored on the D-domain branch (`docs/grill-tournament/grill-decisions-master.md:41-45`; `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:12-17`). Demo scope remains 10 families and 562 is not a "train all tools" surface (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:50-58`).
- A2 is not a roadmap: `a2-post-roadmap` is explicitly a pre-propose checklist, not an SSOT or post-A2 roadmap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:3-6`). It says Phase 0 grill gates precede retrain (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:329-346`). The latest handoff also says A2 was code-only and recommends grilling three gaps before proposing retrain (`docs/handoffs/2026-06-24-a2-merged-d-domain.md:3-7`; `docs/handoffs/2026-06-24-a2-merged-d-domain.md:19-35`).
- The proposed OpenSpec changes are still drafts, not agreement: both retrain-c5 and rebuild-c6 say DRAFT and no training/eval execution yet (`openspec/changes/retrain-c5-lora-d-domain/proposal.md:1-8`; `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:1-8`).
- Data and eval debt is concrete: home-llm comparison exposes missing failure class, already-state handling, ratios, template/cloud mix, and held-out/mid-gate controls (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:97-101`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371-380`).

## Keep

| Candidate | Keep Reason |
|---|---|
| C03 | Keep as P0. Full/demo scope is still pending and can poison every later artifact if it has two SSOTs (`docs/grill-tournament/grill-decisions-master.md:59`; `docs/grill-tournament/grill-decisions-master.md:229-235`). |
| C04 | Keep as P0. Archived specs can silently drag old B-frame/534/2086 semantics into new D-domain work; cascade inventory already lists spec dispositions that need final ownership (`docs/grill-tournament/grill-decisions-master.md:63`; `docs/grill-tournament/cascade-inventory.md:78-93`). |
| C05 | Keep as P0. Pocock stage selection is not ceremony; it decides whether retrain/c6/endpoint work can begin or must stay in problem-shaping (`docs/grill-tournament/grill-decisions-master.md:67`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:329-346`). |
| C06 | Keep as P0. Route tiers, runtime outcomes, readback, unsupported, and safety need one enum model or downstream receipts become incomparable (`docs/srd-three-layer-intent-routing.md:37-69`; `docs/srd-three-layer-intent-routing.md:176-205`). |
| C07 | Keep as P0, but rewrite. D1-D37 and MASTER status drift is a governance risk because Q20/Q21 remain pending (`docs/grill-tournament/grill-decisions-master.md:75-76`). |
| C09 | Keep as P1. Four training classes may be insufficient because the post-roadmap audit flags missing failure/error-recovery data (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:97-101`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148`). |
| C10 | Keep as P1. Already-state and noop behavior can be mis-scored as unsupported or safety refusal unless the outcome taxonomy is frozen (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:119-122`). |
| C11 | Keep as P1. Class ratios are a training-control question, not taste; changing them without evidence recreates C5 opacity (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:70-91`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148`). |
| C12 | Keep as P1. Template versus cloud-natural language mix affects generalization and leakage, and the audit explicitly calls it a gap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:254-256`). |
| C13 | Keep as P0. Held-out axes are one of the highest-value guards against memorized LoRA green (`docs/grill-tournament/grill-decisions-master.md:79`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371-380`). |
| C14 | Keep as P0. Mid-training C6 gates are the direct anti-0/34 control; they must define sampling, thresholds, and stop rules (`docs/grill-tournament/grill-decisions-master.md:61`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156-205`). |
| C15 | Keep as P0/P1. Training stack spike evidence must be known before the project mistakes a paper recipe for a runnable recipe (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156-205`; `openspec/changes/retrain-c5-lora-d-domain/tasks.md:21-28`). |
| C16 | Keep as P1. Frozen versus variable recipe fields decide what evidence can justify reopening training knobs (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:133-138`; `openspec/changes/retrain-c5-lora-d-domain/tasks.md:21-28`). |
| C17 | Keep as P0. Old 10/23 is a historical failure anchor, not a D-domain candidate acceptance gate; confusing the two is a fake-green route error (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371-380`; `openspec/changes/retrain-c5-lora-d-domain/proposal.md:43-58`). |
| C18 | Keep as P0. Four-layer C6 denominators and fail priority are the evaluation spine; without them a pass can hide a failure at model, semantic, patch, or state-readback layer (`openspec/changes/rebuild-c6-four-layer-bench/proposal.md:10-25`; `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:11-23`). |
| C19 | Keep as P0/P1. Endpoint parity is partial and can invalidate desktop-only training wins if delayed too far (`docs/grill-tournament/grill-decisions-master.md:83`; `docs/c5-recovery-2026-06-22/roadmap.md:67-79`). |
| C20 | Keep as P0. Endpoint has no GBNF, so parser/repair/whitelist/failure-enum policy becomes the safety boundary (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:379-400`). |
| C21 | Keep as P0. The state-cell chain is where UIUE and mainline contracts meet; it needs one owner and one receipt path (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:141-143`; `docs/srd-three-layer-intent-routing.md:176-205`). |
| C22 | Keep as P1. Demo-golden-run entry conditions stop UI polish and retrain claims from being called V-PASS before stable IDs and readback exist (`docs/c5-recovery-2026-06-22/roadmap.md:102-107`; `docs/grill-tournament/grill-decisions-master.md:290-294`). |
| C23 | Keep as P1. Cross-vendor review has already found different issue classes; ground-truth reviewer triggers should be explicit, not ad hoc (`docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:74-93`). |
| C24 | Keep as P0. Status vocabulary is the cheapest guardrail against calling train-health, data readiness, C6, endpoint parity, demo, V-PASS, S-PASS, or U-PASS the same thing (`docs/grill-tournament/grill-decisions-master.md:96`; `docs/c5-recovery-2026-06-22/roadmap.md:102-107`). |

## Delete

| Candidate | Delete Reason |
|---|---|
| C01 | Delete as a standalone grill question. The role of `a2-post-roadmap` is already explicitly answered: it is a pre-propose checklist, not an SSOT or roadmap (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:3-6`). If retained, its only useful residue belongs inside C02 as a source-precedence table. |

## Merge

| Merge Set | Recommendation |
|---|---|
| C01 + C02 | Merge only the useful part into one "source precedence and conflict resolution" question. C01 alone is already answered; C02 can force a table of authoritative, historical, draft, and deprecated artifacts (`CONTEXT.md:39-51`; `docs/grill-tournament/cascade-inventory.md:46-55`). |
| C09 + C10 + C24 | Merge under an outcome/data ontology bundle. Do not let the project decide failure class, already-state behavior, and status vocabulary in three disconnected rooms (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:97-101`; `docs/grill-tournament/grill-decisions-master.md:96`). |
| C11 + C12 + C16 | Merge as the D-domain data recipe control surface: ratios, template/cloud source mix, and frozen versus variable recipe knobs need one artifact and one reopen rule (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148`; `openspec/changes/retrain-c5-lora-d-domain/tasks.md:9-19`). |
| C13 + C14 + C17 + C18 | Keep separate scores, but review as one evaluation spine. Held-out axes, mid-training gates, base recalibration, and four-layer denominators are mutually dependent; breaking them apart creates fake-green gaps (`docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371-380`; `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:49-58`). |
| C19 + C20 | Merge endpoint parity timing with parser/repair/whitelist policy. Endpoint evidence is not only "can it run"; it is also "can it fail closed without endpoint GBNF" (`docs/grill-tournament/grill-decisions-master.md:83`; `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:379-400`). |
| C08 + C21 + C22 | Merge into UIUE/mainline boundary control. External UIUE blockers matter only where they intersect state-cell IDs, card patch/readback, and demo-golden-run entry conditions (`docs/c5-recovery-2026-06-22/roadmap.md:91-98`; `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:488-492`). |
| C05 + C23 | Merge the governance path: Pocock stage and mandatory ground-truth reviewer triggers should be decided together so review is not bolted on after implementation has already started (`docs/grill-tournament/grill-decisions-master.md:67`; `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:83-93`). |

## Rewrite

| Candidate | Rewrite Required |
|---|---|
| C02 | Replace "split responsibility" with "produce a precedence table for old roadmap, recovery roadmap, A2 checklist, OpenSpec drafts, current grill SSOT, and UIUE branch roadmap, including conflict resolution and banner text." |
| C03 | Require concrete artifacts: exact `--scope=full` and `--scope=demo` definitions, candidate/input/output counts, derivation command, artifact digest, and the one file that downstream scripts must import. |
| C04 | Require a disposition matrix for every archived spec: no-change, modify, replace by new change, or deprecate, with owner and test/update obligation. Do not accept "review later." |
| C05 | Ask for a stop/go ladder: which items remain problem-framing, which are ready for OpenSpec proposal, which are ready for implementation, and what receipt moves each stage. |
| C06 | Rewrite to name canonical field owners: route tier, intent id, action family, execution outcome, unsupported reason, safety reason, readback state, state_cell id, and claim status. |
| C07 | Rewrite around a status manifest for D1-D37 plus MASTER entries: current, superseded, partial, draft, pending, or deprecated, with one owner for mechanical verification. |
| C08 | Narrow it. "Outside UIUE blockers" is too broad; ask which blockers can invalidate Phase 0 state contracts, C3/C5/C6 receipts, or demo-golden-run entry. |
| C09 | Require a yes/no decision on adding failure/error-recovery data class, the exact artifact it lands in, and whether it affects training, runtime enum, eval, or all three. |
| C10 | Require classification examples for `already_state`, `state_noop`, unsupported capability, safety refusal, ambiguous intent, parser failure, and execution failure. |
| C11 | Require minimum evidence before changing ratios: source pool size, per-class example counts, failure-mode coverage, and expected held-out distribution. |
| C12 | Require an explicit generator contract: deterministic template share, cloud paraphrase share, dedupe method, leakage guard, and human spot-check threshold. |
| C13 | Require held-out axes before data generation, not after training: family, slot, language form, unsupported/safety/error, paraphrase source, and state condition. |
| C14 | Require stop rules at 50/100/150: sample size, layer-specific thresholds, mandatory failure taxonomy, and whether a fail stops train or changes data recipe. |
| C15 | Require a runnable spike receipt: environment, backend, train command, tiny dataset, saved adapter, load path, and one failing/one passing C6 probe. |
| C16 | Tie frozen/variable fields to C15. Frozen fields cannot be reopened without a named evidence class; variable fields need max ranges and logging. |
| C17 | Reframe as base-anchor policy. Old 10/23 remains historical failure evidence; new D-domain base must be recalibrated before LoRA delta claims are meaningful. |
| C18 | Require four separate denominators and fail priority: model output, semantic action, patch/card update, and readback state. A high aggregate cannot mask a layer-zero failure. |
| C19 | Require minimum endpoint evidence by stage: before training, before C6 candidate pass, before demo-golden-run, and before any V/S/U-PASS claim. |
| C20 | Add the no-GBNF premise. Define what parser repair may repair, what it must refuse, whitelist digest ownership, and failure enum mapping. |
| C21 | Require an interface contract for `tool -> IR -> state_cell -> card -> patch -> readback`, including fixture IDs and owner boundary between mainline and UIUE. |
| C22 | Require entry conditions, not just a run list: stable IDs, frozen scope, C6 layer thresholds, endpoint parity receipt, UIUE state-cell receipt, and status wording. |
| C23 | Require a trigger matrix: which decision types require subagent/cross-vendor review, expected output schema, contradiction handling, and who can override. |
| C24 | Require a claim-language table mapping every status to allowed and forbidden public/internal claims. This is where train-health must be blocked from becoming V-PASS. |

## Missing Risks

- The candidate pool underweights T5/banner cleanup. Cascade inventory says T5 banner work is pending (`docs/grill-tournament/cascade-inventory.md:46`; `docs/grill-tournament/cascade-inventory.md:239-240`). Without banners, old roadmaps and drafts can be misread as authority.
- The pool does not directly ask for a generated-artifact drift gate. The paradigm amendment notes generated artifacts are outside the drift gate surface (`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:443-454`), which can let generated files keep stale semantics.
- The pool asks about endpoint parity and parser policy, but not enough about failure receipts. Every refusal, parser repair, safety block, and state-noop needs a replayable fixture and expected enum, or "works locally" will become another fake-green claim.
- The pool does not force a single machine-readable status manifest. Human-readable docs are already numerous; the risk is that scripts, reviewers, and handoffs each quote a different authority.
- The pool does not explicitly forbid using old B-frame/base results as D-domain proof. C17 partly covers this, but the risk deserves stronger wording because old 10/23 appears in draft success criteria (`openspec/changes/retrain-c5-lora-d-domain/proposal.md:43-58`).
- The pool should ask who owns "stop the train" authority. Mid-training gates are useless if a fail only creates another TODO instead of stopping the run.
- The pool does not ask for minimum negative controls in C6: unsupported intent, safety violation, ambiguous instruction, parser malformed output, and already-state/noop.
- The pool does not explicitly require a live-device or endpoint-class distinction in closeout vocabulary. The old roadmap warns not to claim simulator V-PASS or metadata-only success (`docs/c5-recovery-2026-06-22/roadmap.md:102-107`).

## Scores

| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Priority | Needs User Grill? |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C01 | 2 | 4 | 1 | 2 | 2 | 11 | P2 | No |
| C02 | 3 | 4 | 2 | 3 | 3 | 15 | P1 | Yes |
| C03 | 5 | 5 | 5 | 5 | 4 | 24 | P0 | Yes |
| C04 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | Yes |
| C05 | 5 | 4 | 4 | 5 | 4 | 22 | P0 | Yes |
| C06 | 5 | 4 | 4 | 5 | 5 | 23 | P0 | Yes |
| C07 | 4 | 4 | 4 | 4 | 4 | 20 | P0 | Yes |
| C08 | 3 | 3 | 3 | 3 | 4 | 16 | P1 | Yes |
| C09 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | Yes |
| C10 | 4 | 4 | 4 | 4 | 3 | 19 | P1 | Yes |
| C11 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | Yes |
| C12 | 4 | 5 | 4 | 4 | 4 | 21 | P1 | Yes |
| C13 | 5 | 5 | 5 | 5 | 4 | 24 | P0 | Yes |
| C14 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C15 | 4 | 5 | 3 | 4 | 4 | 20 | P0 | Yes |
| C16 | 4 | 4 | 4 | 4 | 4 | 20 | P1 | Yes |
| C17 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |
| C18 | 5 | 5 | 5 | 5 | 5 | 25 | P0 | Yes |
| C19 | 4 | 4 | 4 | 4 | 5 | 21 | P0 | Yes |
| C20 | 5 | 4 | 4 | 5 | 5 | 23 | P0 | Yes |
| C21 | 5 | 5 | 4 | 5 | 4 | 23 | P0 | Yes |
| C22 | 4 | 4 | 3 | 4 | 4 | 19 | P1 | Yes |
| C23 | 3 | 4 | 4 | 4 | 4 | 19 | P1 | Yes |
| C24 | 5 | 5 | 4 | 5 | 5 | 24 | P0 | Yes |

## Candidate Notes

| Candidate | Verdict | Evidence | Note |
|---|---|---|---|
| C01 | Delete | `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:3-6` | Already answered. Asking it again wastes grill budget unless converted into C02 precedence wording. |
| C02 | Rewrite | `CONTEXT.md:39-51`; `docs/grill-tournament/cascade-inventory.md:46-55` | Useful only if it forces a source-precedence table and banner/cleanup obligations. |
| C03 | Keep/Rewrite | `docs/grill-tournament/grill-decisions-master.md:59`; `docs/grill-tournament/grill-decisions-master.md:229-235` | Highest-leverage scope question. Must produce exact artifact boundaries, not a prose compromise. |
| C04 | Keep/Rewrite | `docs/grill-tournament/grill-decisions-master.md:63`; `docs/grill-tournament/cascade-inventory.md:78-93` | Spec drift is a real blocker because archived specs can smuggle old semantics into new OpenSpec changes. |
| C05 | Keep/Rewrite | `docs/grill-tournament/grill-decisions-master.md:67`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:329-346` | Forces phase discipline before retrain/C6/endpoint work starts. |
| C06 | Keep/Rewrite | `docs/srd-three-layer-intent-routing.md:37-69`; `docs/srd-three-layer-intent-routing.md:176-205` | Core CAS/status question. Without canonical fields, later scores cannot be compared. |
| C07 | Keep/Rewrite | `docs/grill-tournament/grill-decisions-master.md:75-76`; `docs/grill-tournament/grill-decisions-master.md:290-294` | Needs a manifest, not a meeting answer. Useful to prevent D1-D37 drift after D-domain flip. |
| C08 | Merge/Rewrite | `docs/c5-recovery-2026-06-22/roadmap.md:91-98`; `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:488-492` | Too broad as written. Keep only intersections that can block state contracts or demo acceptance. |
| C09 | Keep/Rewrite | `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:97-101`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148` | Real data-class gap. It exposes whether the four-class plan is underfitting failure behavior. |
| C10 | Merge/Rewrite | `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:119-122` | Should merge with outcome taxonomy. Its danger is mislabeling state-noop as refusal or unsupported. |
| C11 | Keep/Merge | `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:70-91`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148` | Ratios are materially grillable if evidence thresholds are required before change. |
| C12 | Keep/Merge | `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:128-148`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:254-256` | Important because demo shortcut cannot become recipe shortcut. |
| C13 | Keep | `docs/grill-tournament/grill-decisions-master.md:79`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371-380` | Must be answered before data generation/training, or C5 green can just be memorization. |
| C14 | Keep/Rewrite | `docs/grill-tournament/grill-decisions-master.md:61`; `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156-205` | Strongest direct guard against another late 0/34 discovery. Needs stop rules. |
| C15 | Keep/Rewrite | `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:156-205`; `openspec/changes/retrain-c5-lora-d-domain/tasks.md:21-28` | Prevents a non-runnable training stack from being discovered after data generation. |
| C16 | Merge/Rewrite | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:133-138`; `openspec/changes/retrain-c5-lora-d-domain/tasks.md:21-28` | Belongs with data recipe and training stack. Useful only with reopen evidence rules. |
| C17 | Keep/Rewrite | `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md:371-380`; `openspec/changes/retrain-c5-lora-d-domain/proposal.md:43-58` | Critical route-error question. Old baseline is not the new D-domain proof. |
| C18 | Keep/Rewrite | `openspec/changes/rebuild-c6-four-layer-bench/proposal.md:10-25`; `openspec/changes/rebuild-c6-four-layer-bench/tasks.md:11-23` | Highest fake-green exposure. Four layers need separate denominators and fail priority. |
| C19 | Keep/Merge | `docs/grill-tournament/grill-decisions-master.md:83`; `docs/c5-recovery-2026-06-22/roadmap.md:67-79` | Endpoint parity cannot be postponed until after every desktop artifact is green. |
| C20 | Keep/Rewrite | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:379-400` | Safety-critical because no endpoint GBNF means repair/whitelist policy is the failure boundary. |
| C21 | Keep/Rewrite | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:141-143`; `docs/srd-three-layer-intent-routing.md:176-205` | The most important UIUE/mainline bridge question. It forces readback truth instead of UI-only claims. |
| C22 | Keep/Merge | `docs/c5-recovery-2026-06-22/roadmap.md:102-107`; `docs/grill-tournament/grill-decisions-master.md:290-294` | Needs entry conditions and status wording, not only a golden-run checklist. |
| C23 | Keep/Merge | `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:74-93` | Lower technical leverage than C13/C18, but valuable because cross-vendor audits found different issues. |
| C24 | Keep/Rewrite | `docs/grill-tournament/grill-decisions-master.md:96`; `docs/c5-recovery-2026-06-22/roadmap.md:102-107` | Mandatory. Claim vocabulary is how fake-green gets stopped before it reaches closeout. |

## Rationale

The dangerous path is not "the team forgot a question." The dangerous path is "the team answers questions in prose, declares Phase 0 green, and starts retraining while scope, data recipe, baseline, endpoint failure policy, C6 denominators, and status vocabulary remain unfrozen." That is how a C5-style failure repeats with better-looking documents.

My P0 spine is C03, C04, C05, C06, C07, C13, C14, C15, C17, C18, C19, C20, C21, and C24. If the loop must cut scope, do not cut from that spine. C01 is the only clean delete because its core premise is already answered by the source itself. C02 is not a delete only because source precedence and banner cleanup remain a real operational risk.

The judge should penalize any answer that says "decided" without a file path, line, artifact owner, command, digest, denominator, threshold, or allowed claim string. In this project, a green label without a receipt is not evidence. It is a route error.
