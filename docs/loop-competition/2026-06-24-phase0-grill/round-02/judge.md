# Round 02 Judge

## Verdict

R2 confirms the R1 direction: keep the 24-question set for final scoring, but do not let all 24 become separate workstreams. The strong R2 contribution is stricter priority separation: C01 is not a standalone grill decision, C08 is only a blocker at the state/C3-C6/golden contract intersection, and C11-C12 are recipe hypotheses until spike evidence supports numeric ratios.

## Reviewer Coverage

| Reviewer | Persona | File | Completion |
|---|---|---|---|
| Brain 1 | RED hostile failure auditor | `round-02/brain-1.md` | 24/24 scored |
| Brain 2 | GREEN implementation coordinator | `round-02/brain-2.md` | 24/24 scored |
| Brain 3 | INDIGO architecture skeptic | `round-02/brain-3.md` | 24/24 scored |

## Score Summary

| Candidate | B1 | B2 | B3 | Avg | Spread | R2 Priority | R2 Judge |
|---|---:|---:|---:|---:|---:|---|---|
| C01 | 11 | 21 | 22 | 18.00 | 11 | Merge/P2 standalone | Do not keep standalone; merge into C02 |
| C02 | 15 | 21 | 24 | 20.00 | 9 | P0 support | Keep as authority matrix |
| C03 | 24 | 25 | 25 | 24.67 | 1 | P0 | Keep standalone |
| C04 | 23 | 24 | 24 | 23.67 | 1 | P0 | Keep standalone |
| C05 | 22 | 21 | 23 | 22.00 | 2 | P0 | Keep |
| C06 | 23 | 24 | 24 | 23.67 | 1 | P0 | Keep |
| C07 | 20 | 20 | 22 | 20.67 | 2 | P0/P1 split | Keep, narrow scope |
| C08 | 16 | 17 | 23 | 18.67 | 7 | P1 with P0 intersection | Keep, narrow to contract intersections |
| C09 | 21 | 21 | 21 | 21.00 | 0 | P1 | Keep |
| C10 | 19 | 19 | 20 | 19.33 | 1 | P1 | Keep, merge into taxonomy |
| C11 | 21 | 21 | 21 | 21.00 | 0 | P1 | Keep, hypothesis values only |
| C12 | 21 | 22 | 22 | 21.67 | 1 | P1 | Keep, hypothesis values only |
| C13 | 24 | 25 | 24 | 24.33 | 1 | P0 | Keep standalone |
| C14 | 25 | 24 | 24 | 24.33 | 1 | P0 | Keep standalone |
| C15 | 20 | 23 | 23 | 22.00 | 3 | P0/P1 split | Keep as propose hard gate |
| C16 | 20 | 21 | 21 | 20.67 | 1 | P1 | Keep |
| C17 | 24 | 24 | 25 | 24.33 | 1 | P0 | Keep standalone |
| C18 | 25 | 25 | 24 | 24.67 | 1 | P0 | Keep standalone |
| C19 | 21 | 22 | 21 | 21.33 | 1 | P0/P1 split | Keep, define claim boundary now |
| C20 | 23 | 24 | 22 | 23.00 | 2 | P0 | Keep standalone |
| C21 | 23 | 21 | 23 | 22.33 | 2 | P0 | Keep |
| C22 | 19 | 22 | 22 | 21.00 | 3 | P0/P1 split | Keep as entry-condition question |
| C23 | 19 | 20 | 20 | 19.67 | 1 | P1 | Keep, add negative list |
| C24 | 24 | 24 | 25 | 24.33 | 1 | P0 | Keep standalone |

## High-Confidence P0 Spine

| Candidate | R2 Reason |
|---|---|
| C03 | Full/demo must prove one SSOT; otherwise every generated, training, and eval artifact can split. |
| C04 | Archived spec disposition must be explicit because OpenSpec remains behavior authority. |
| C06 | Canonical fields/enums are the shared language for SRD, C3, C6, UI state, and status receipts. |
| C13 | Held-out axes must exist before data generation/training to stop memorization and lineage leakage. |
| C14 | Mid-training gate must stop the run before repeating a late 0/34 or 0/23 discovery. |
| C17 | Old 10/23 is historical failure evidence; new D-domain base anchor governs candidate comparison. |
| C18 | Four-layer C6 denominators and fail priority define model-quality truth. |
| C20 | Endpoint parser/repair/whitelist/failure enum is the hard boundary when endpoint GBNF is unavailable. |
| C21 | The `tool -> IR -> state_cell -> card -> patch` chain is mainline contract truth with UIUE as consumer. |
| C24 | Status vocabulary prevents train-health/model-quality/endpoint/golden/V-S-U pass conflation. |

## Dispute Triage

| Candidate | Spread | Dispute Type | Judge Route |
|---|---:|---|---|
| C01 | 11 | 口径型 | Stop re-scoring. The source already self-classifies `a2-post-roadmap`; final answer should merge it into C02 and mark no standalone user grill. |
| C02 | 9 | 混合 | Keep. The red reviewer penalized it as too broad, but authority drift is still physical because docs disagree on current source routing. Require a table, not discussion. |
| C08 | 7 | 口径型 | Stop re-scoring. Final answer should use the contract-boundary frame: visual/UIUE backlog is non-blocking; state/C3-C6/golden intersections remain mainline. |
| C15 | 3 | 混合 | Split: carrier decision is P0, physical spike execution belongs inside `retrain-c5` tasks before full training. |
| C22 | 3 | 混合 | Split: entry conditions are P0 for future demo-golden-run; actual golden-run execution remains deferred. |

## Merge Decisions

| Cluster | R2 Landing Artifact | Judge Decision |
|---|---|---|
| C01 + C02 | Post-A2 source authority matrix | Merge C01 into C02; do not ask C01 as standalone. |
| C09 + C10 | C5 data/outcome taxonomy | Keep both clauses; decide failure class and `already_state` classification in same taxonomy. |
| C11 + C12 + C16 | `data_recipe.yaml` + recipe reopen policy | Keep as P1 recipe package; numeric values start as hypotheses. |
| C13 + C14 + C18 | C5/C6 anti-fake-green gate family | Keep separate P0 decisions because each can fail independently. |
| C19 + C20 | Endpoint evidence + parser policy | Keep C20 standalone P0; C19 defines timing and claim boundary. |
| C21 + C22 | Mainline state/golden interface | Mainline owns IDs/state/patch/readback; UIUE consumes after stability. |

## R2 Missing Risks To Carry Forward

| Risk | Final Handling |
|---|---|
| Historical and README banner drift | Add to final C02/C07 recommendation. `a2-post-roadmap` and old recovery roadmap must not become live roadmap by force of depth. |
| Generated artifact drift gate | Add to final C03/C04 acceptance criteria. Generated D-domain artifacts need mechanical drift proof. |
| Local/Mac success laundering into endpoint/V-pass | Add to final C19/C24 forbidden implication rules. |
| Raw/oracle redlines in generator work | Add to final C11/C12/C23 recommendation. Data recipe must distinguish oracle evidence from train text. |
| Negative controls in C6 | Add to final C18 recommendation: unsupported, safety, ambiguous, parser malformed, and already-state/no-op need explicit denominators or fixtures. |
| Stop-the-train authority | Add to final C14 recommendation. A gate without stop/pause authority is just logging. |

## User Grill Needed After R2

User participation is still valuable, but not for all 24 items. R2 narrows it to policy/claim decisions:

1. C02: source authority matrix and whether old roadmaps are historical only.
2. C03: exact `full`/`demo` artifact boundary and generated drift proof.
3. C04/C07: spec and decision manifest disposition where behavior changed.
4. C09-C12: whether failure/error recovery is cut or seeded, and whether ratios are hypotheses.
5. C14/C18: stop/pause thresholds and four-layer fail-priority semantics.
6. C17: D-domain base anchor wording so old 10/23 remains historical, not candidate gate.
7. C19-C20: endpoint evidence and no-GBNF parser/repair/fail-closed policy.
8. C21-C22: mainline/UIUE ownership of state/golden IDs.
9. C24: final status vocabulary and forbidden claim language.

## R2 Judge Bottom Line

The route should not proceed into retrain propose until the P0 authority, scope, spec-disposition, enum/status, held-out, C6, endpoint-parser, and state/golden boundary questions are converted into OpenSpec-ready tasks or manifests. C09-C12/C16 are essential, but their exact numeric values should be treated as recipe hypotheses pending spike evidence. C01 is resolved enough to stop asking it as a standalone question.
