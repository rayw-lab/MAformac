# Supplemental Round 02 Judge

- Date: 2026-06-28
- Round: 02
- Reviewers: PURPLE / ORANGE / BLACK
- Scope: `C31-C50`
- Proof class: review synthesis only

## Mechanical Check

- `round-02/brain-1.md`: required sections present; C31-C50 covered. Initial PURPLE response failed the file-output gate and was repaired by the same reviewer with a valid markdown file.
- `round-02/brain-2.md`: required sections present; C31-C50 covered.
- `round-02/brain-3.md`: required sections present; C31-C50 covered.

## Score Snapshot

| ID | PURPLE | ORANGE | BLACK | R2 Avg | Signal |
| --- | ---: | ---: | ---: | ---: | --- |
| C31 | 2 | 5 | 5 | 4.00 | Keep as rewritten visual-policy/evidence manifest; do not create second bridge SSOT. |
| C32 | 4 | 4 | 4 | 4.00 | Keep/merge; source mapping is valuable. |
| C33 | 4 | 5 | 5 | 4.67 | Keep; attention sequencing is real. |
| C34 | 3 | 4 | 3 | 3.33 | Rewrite; user/product route decision plus gesture/evidence gate. |
| C35 | 5 | 5 | 4 | 4.67 | Keep; gesture arbitration is core. |
| C36 | 4 | 4 | 5 | 4.33 | Keep/rewrite; operator surface boundary is important. |
| C37 | 4 | 4 | 4 | 4.00 | Keep/merge; top capsule priority belongs in visual policy. |
| C38 | 4 | 5 | 5 | 4.67 | Keep; raw vehicle-state display redline. |
| C39 | 2 | 3 | 2 | 2.33 | Merge; layout pair is not standalone R4 bridge schema. |
| C40 | 5 | 5 | 5 | 5.00 | Keep; snapshot lifecycle is central. |
| C41 | 4 | 4 | 4 | 4.00 | Keep/rewrite; multi-action compression risk. |
| C42 | 4 | 5 | 5 | 4.67 | Keep/merge with lifecycle; stale clearing is real. |
| C43 | 4 | 4 | 4 | 4.00 | Keep/merge; scroll ownership policy. |
| C44 | 4 | 4 | 4 | 4.00 | Keep/rewrite; spatial memory and overlay state. |
| C45 | 5 | 5 | 4 | 4.67 | Keep; z-order/hit-testing is a hard UI evidence gate. |
| C46 | 5 | 5 | 4 | 4.67 | Keep; a11y alternatives are necessary. |
| C47 | 5 | 5 | 5 | 5.00 | Keep; zone-wise reduce motion proof is essential. |
| C48 | 4 | 4 | 4 | 4.00 | Keep; platform proof split. |
| C49 | 4 | 5 | 3 | 4.00 | Keep/rewrite as evidence checklist, not universal requirement. |
| C50 | 5 | 5 | 5 | 5.00 | Keep as final classification governor. |

## Consensus

Round 02 agrees that the supplement is valid, but it also corrects the likely failure mode: these UI details must not all become bridge schema fields.

The final synthesis should split each item into one of three buckets:

- `bridge schema`: fields or enums that producers/consumers must share.
- `visual policy`: UIUE behavior rules that consume bridge state but do not define runtime.
- `evidence checklist`: screenshots, video, UI tree, a11y, or timing proof.

## Disputes

| Candidate | Dispute type | Resolution |
| --- | --- | --- |
| C31 | 混合 | Keep, but rewrite away from bridge-owned `zone manifest`; route to visual policy plus evidence manifest. |
| C34 | 混合 | Keep as a question because the user called out 1.5s long-press/console, but mark route as user-decision + visual policy, not current bridge proof. |
| C39 | 口径型 | Do not keep as standalone P0; merge into zone layout evidence. |
| C49 | 口径型 | Keep as timing-evidence guard; do not require video for every static claim. |
| C50 | 口径型 but decisive | Use as final governor; it prevents the supplement from becoming a UI implementation dump. |

## Round 02 Verdict

`PASS_WITH_BOUNDARY_REWRITE`.

The supplemental candidates should be accepted into a v2 matrix, with `C50` acting as the classification gate and with lower standalone value items marked `merge` rather than deleted.
