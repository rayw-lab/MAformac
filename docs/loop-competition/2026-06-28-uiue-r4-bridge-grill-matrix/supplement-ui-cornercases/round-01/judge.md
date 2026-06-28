# Supplemental Round 01 Judge

- Date: 2026-06-28
- Round: 01
- Reviewers: RED / GREEN / BLUE
- Scope: `C31-C50`
- Proof class: review synthesis only

## Mechanical Check

- `round-01/brain-1.md`: required sections present; C31-C50 covered.
- `round-01/brain-2.md`: required sections present; C31-C50 covered.
- `round-01/brain-3.md`: required sections present; C31-C50 covered.

## Score Snapshot

| ID | RED | GREEN | BLUE | R1 Avg | Signal |
| --- | ---: | ---: | ---: | ---: | --- |
| C31 | 5 | 4 | 5 | 4.67 | Keep; zone topology must become explicit. |
| C32 | 5 | 4 | 4 | 4.33 | Keep/merge with C31; maps zones to snapshot/policy sources. |
| C33 | 5 | 5 | 5 | 5.00 | Keep; cross-zone attention sequencing is hard. |
| C34 | 5 | 3 | 4 | 4.00 | Rewrite; long-press/console question is real but too implementation-shaped. |
| C35 | 5 | 5 | 5 | 5.00 | Keep; gesture arbitration is core. |
| C36 | 5 | 5 | 4 | 4.67 | Keep/rewrite; demo/operator surface boundary is important. |
| C37 | 4 | 4 | 5 | 4.33 | Keep; top context priority is visible. |
| C38 | 5 | 4 | 5 | 4.67 | Keep/rewrite; no raw speed/gear display as control. |
| C39 | 3 | 3 | 3 | 3.00 | Merge into zone/layout evidence; not a standalone high gate. |
| C40 | 5 | 4 | 5 | 4.67 | Keep/rewrite; lifecycle semantics are material. |
| C41 | 4 | 5 | 4 | 4.33 | Keep/merge; multi-zone macro must not be flattened. |
| C42 | 5 | 3 | 5 | 4.33 | Keep/merge with C40; stale-state clearing is important. |
| C43 | 4 | 4 | 5 | 4.33 | Keep; scroll focus conflict is real. |
| C44 | 3 | 5 | 4 | 4.00 | Keep/merge; spatial memory and overlay state boundary. |
| C45 | 4 | 5 | 5 | 4.67 | Keep; z-order / hit-testing has demo-failure potential. |
| C46 | 4 | 4 | 4 | 4.00 | Keep/rewrite; a11y alternatives must be specific. |
| C47 | 5 | 5 | 5 | 5.00 | Keep/rewrite; reduce motion needs zone-wise proof. |
| C48 | 4 | 4 | 5 | 4.33 | Keep; Mac/iPhone proof cannot substitute each other. |
| C49 | 5 | 5 | 5 | 5.00 | Keep/rewrite; moving evidence is necessary for timing claims. |
| C50 | 5 | 5 | 5 | 5.00 | Keep/rewrite; schema vs visual policy vs evidence classification is the governor. |

## Consensus

Round 01 confirms the user's concern: the original R4 matrix under-specified UI corner cases. These gaps are not mere visual polish. They define whether R4's bridge contract can explain real UIUE behavior without accidentally becoming a runtime/UI implementation bucket.

## Rewrite And Merge Queue

- `C31` + `C32` + part of `C39`: produce one zone manifest / ownership / evidence item plus a layout-pair sub-question.
- `C34`: rewrite to avoid implying the feature is already implemented; ask for route contract, proof, and boundary.
- `C36`: tighten demo/operator surface language.
- `C40` + `C42`: merge around lifecycle and stale clearing.
- `C41` + `C44`: keep distinct if final count permits; otherwise group macro multi-zone changes with spatial-memory proof.
- `C46`: specify non-gesture alternatives and identifiers.
- `C47`: require zone-wise reduce-motion proof, not one global screenshot.
- `C49`: require video/multi-frame only for timing claims, not all visual claims.
- `C50`: convert into a final classification table requirement.

## Round 01 Verdict

`PASS_WITH_REWRITE_NOTES`.

Proceed to Round 02 blind review with the same `C31-C50` set.

