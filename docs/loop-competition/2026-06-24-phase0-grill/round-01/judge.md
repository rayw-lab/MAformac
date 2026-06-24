# Round 01 Judge

## Verdict

R1 accepts all 24 candidates. No deletion is justified. The useful correction is to land several adjacent questions into shared physical artifacts, and to keep the highest-risk C5/C6/endpoint/status questions as separate grill decisions so they cannot be washed out by a merged prose roadmap.

## Reviewer Coverage

| Reviewer | Lens | File | Completion |
|---|---|---|---|
| Brain 1 | Contract / SSOT / OpenSpec / SRD governance | `round-01/brain-1.md` | 24/24 scored |
| Brain 2 | C5/C6 model quality / D-domain LoRA / endpoint parity | `round-01/brain-2.md` | 24/24 scored |
| Brain 3 | Pre-mortem / sequencing / UIUE isolation / fake-green risk | `round-01/brain-3.md` | 24/24 scored |

## Score Summary

| Candidate | B1 | B2 | B3 | Avg | Spread | R1 Priority | R1 Judge |
|---|---:|---:|---:|---:|---:|---|---|
| C01 | 22 | 20 | 24 | 22.00 | 4 | P0 | Keep, merge with C02 |
| C02 | 24 | 23 | 24 | 23.67 | 1 | P0 | Keep |
| C03 | 25 | 25 | 25 | 25.00 | 0 | P0 | Keep as standalone P0 |
| C04 | 25 | 24 | 25 | 24.67 | 1 | P0 | Keep as standalone P0 |
| C05 | 21 | 23 | 24 | 22.67 | 3 | P0 | Keep |
| C06 | 25 | 24 | 23 | 24.00 | 2 | P0 | Keep |
| C07 | 23 | 21 | 22 | 22.00 | 2 | P0 | Keep |
| C08 | 20 | 18 | 23 | 20.33 | 5 | P1/P0 edge | Keep, R2 dispute item |
| C09 | 22 | 25 | 23 | 23.33 | 3 | P0/P1 edge | Keep |
| C10 | 23 | 22 | 22 | 22.33 | 1 | P1 | Keep |
| C11 | 20 | 25 | 20 | 21.67 | 5 | P1/P0 edge | Keep, R2 dispute item |
| C12 | 20 | 24 | 23 | 22.33 | 4 | P1 | Keep, R2 dispute item |
| C13 | 25 | 25 | 25 | 25.00 | 0 | P0 | Keep as standalone P0 |
| C14 | 25 | 25 | 24 | 24.67 | 1 | P0 | Keep as standalone P0 |
| C15 | 22 | 23 | 24 | 23.00 | 2 | P0 | Keep |
| C16 | 21 | 22 | 21 | 21.33 | 1 | P1 | Keep |
| C17 | 25 | 25 | 24 | 24.67 | 1 | P0 | Keep as standalone P0 |
| C18 | 25 | 25 | 24 | 24.67 | 1 | P0 | Keep as standalone P0 |
| C19 | 23 | 25 | 23 | 23.67 | 2 | P0 | Keep |
| C20 | 25 | 25 | 25 | 25.00 | 0 | P0 | Keep as standalone P0 |
| C21 | 23 | 21 | 24 | 22.67 | 3 | P0 | Keep |
| C22 | 22 | 20 | 23 | 21.67 | 3 | P1/P0 edge | Keep |
| C23 | 22 | 21 | 21 | 21.33 | 1 | P1 | Keep |
| C24 | 25 | 25 | 25 | 25.00 | 0 | P0 | Keep as standalone P0 |

## Strongest Consensus

| Candidate | Why It Must Survive |
|---|---|
| C03 | Full/demo artifact split is a direct dual-SSOT prevention gate. All reviewers scored it 25. |
| C13 | Held-out axes are the core anti-memorization and anti-lineage-leakage guard. All reviewers scored it 25. |
| C20 | Endpoint parser/repair/whitelist policy is mandatory once endpoint GBNF is unavailable. All reviewers scored it 25. |
| C24 | Status vocabulary prevents pass-label laundering across train health, model quality, endpoint, golden run, and V/S/U pass. All reviewers scored it 25. |
| C04 | Archived spec disposition is nearly unanimous P0 because OpenSpec remains behavior SSOT. |
| C14 | Mid-training gate is the direct brake against another late all-zero discovery. |
| C17 | New D-domain base anchor must coexist with old 10/23 historical failure anchor. |
| C18 | C6 four-layer scoring denominators and fail priority define model-quality truth. |

## Main Disputes To Carry Into R2

| Candidate | Dispute | R1 Judge Position |
|---|---|---|
| C08 | UIUE boundary scored from 18 to 23. The dispute is whether UIUE scope leakage is P0 or only P1 when it does not touch C3/C6/state/golden IDs. | Keep it, but narrow it to contract-intersection only: state-cells, tool-card-map, DemoVisualState, C6 IDs, and golden-run IDs. Pure visual work stays outside mainline blockers. |
| C11 | Data-class factors scored from 20 to 25. The dispute is whether initial ratios are a P0 production decision or a P1 hypothesis requiring spike evidence. | Keep it as a mandatory `data_recipe.yaml` question, but mark exact factor values as hypothesis until a factor spike or early C6 gate supports them. |
| C12 | Template/cloud split scored from 20 to 24. The dispute is not whether it matters, but whether a numeric split is ready before data recipe spike. | Keep it. Require dual-leg provenance and same-SSOT digest first; allow numeric ratio to start as hypothesis. |
| C01 | Role classification scored from 20 to 24 because the answer is partly already written in the source doc. | Merge into C02 in the final operating matrix, but retain enough wording to forbid treating `a2-post-roadmap` as SSOT/live roadmap. |

## Merge Decisions

| Cluster | Landing Artifact | Keep Separate In Grill? | Reason |
|---|---|---|---|
| C01 + C02 | Post-A2 authority/responsibility matrix | Mostly merged | They classify artifact authority and ownership. |
| C09 + C10 + C11 + C12 | `data_recipe.yaml` and `retrain-c5` proposal/tasks | Keep separate acceptance clauses | Taxonomy, `already_state`, factors, and generation split are one recipe package, but each prevents a different failure. |
| C13 + C14 + C18 | Anti-fake-green C5/C6 gate package | Keep separate | Held-out axes, mid-training gates, and final scoring can fail independently. |
| C19 + C20 | Endpoint parity/parser package | Keep separate | Endpoint timing and parser policy are coupled, but C20 is a hard safety contract. |
| C21 + C22 | Mainline state/golden interface | Merge landing artifact, separate entry conditions | UIUE consumes the stable interface; it must not define it. |
| C06 + C24 | Outcome/status vocabulary manifest | Keep separate headings | Runtime outcome enums and pass-label vocabulary interact but are not identical. |

## Missing Risks Added By Judge

| Risk | Why It Matters | Suggested Landing |
|---|---|---|
| Generated artifact drift gate | R1 notes that `generated/` drift and `--scope=full` fail-fast behavior are only indirectly covered by C03/C04. | Add to C03 acceptance criteria. |
| Historical-banner drift | Stale roadmaps/handoffs can resurrect old authority despite the new SSOT split. | Add to C02/C07 authority matrix tasks. |
| Local/Mac evidence laundering into endpoint/mobile claims | C19/C24 cover it indirectly, but the final synthesis should make this explicit. | Add forbidden implication rules to C24 and endpoint evidence table to C19. |
| Raw/oracle redline handling in new generator work | C12/C23 touch it, but data generation can accidentally violate project redlines if not explicit. | Add redline/provenance fields to `data_recipe.yaml` and review schema. |

## R1 Recommended Priority Bands

| Band | Candidates |
|---|---|
| P0 hard blockers | C02, C03, C04, C05, C06, C07, C13, C14, C15, C17, C18, C19, C20, C21, C24 |
| P0/P1 edge, needs sharper wording | C08, C09, C11, C22 |
| P1, must be accounted before implementation | C10, C12, C16, C23 |
| Merge-only / closeable by matrix | C01 |

## User Grill Needed After R1

Required user grill is not needed for every candidate. The high-value user decisions are:

1. C03: exact `full`/`demo` artifact contract and fail-fast semantics.
2. C04: archived spec disposition policy.
3. C09-C12: whether failure/error recovery is cut or seeded, and whether data ratios are hypothesis or production values.
4. C17-C18: D-domain base anchor and four-layer C6 pass semantics.
5. C19-C20: endpoint readiness claim boundary and parser fallback policy.
6. C21-C22: UIUE/mainline ownership boundary for state/golden IDs.
7. C24: canonical status vocabulary and forbidden implication rules.

## R2 Instructions From Judge

R2 should independently score the same 24 blind candidates. It should not receive R1 scores or recommended answers. The only process change is reviewer diversity: one hostile failure auditor, one gentle implementation coordinator, and one contrarian architecture skeptic. Their prompts may include persona and evaluation lens, but must keep the same blind candidate set and source evidence boundary.
