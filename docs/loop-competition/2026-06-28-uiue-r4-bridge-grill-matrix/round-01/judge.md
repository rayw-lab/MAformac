# Round 01 Judge Synthesis

- Date: 2026-06-28
- Round: 01
- Reviewers: RED / GREEN / BLUE
- Scope: fixed blind set `C01-C30`
- Proof class: review synthesis only

## Mechanical Check

- `round-01/brain-1.md`: required sections present; C01-C30 covered.
- `round-01/brain-2.md`: required sections present; C01-C30 covered.
- `round-01/brain-3.md`: required sections present; C01-C30 covered.

## Score Snapshot

| ID | RED | GREEN | BLUE | R1 Avg | Round 01 signal |
| --- | ---: | ---: | ---: | ---: | --- |
| C01 | 5 | 5 | 5 | 5.00 | Keep as P0 single-authority / no-second-bridge guard. |
| C02 | 5 | 5 | 5 | 5.00 | Keep as P0 proof-class anti-upgrade guard. |
| C03 | 5 | 5 | 4 | 4.67 | Keep; rewrite toward owner/input/output/blocker for co-author review. |
| C04 | 4 | 4 | 5 | 4.33 | Keep; field/fail-closed details matter. |
| C05 | 4 | 5 | 5 | 4.67 | Keep; final wording should align enum vocabulary with OpenSpec. |
| C06 | 5 | 5 | 4 | 4.67 | Keep; rewrite around Core 3-state vs bridge future `missing`. |
| C07 | 4 | 5 | 4 | 4.33 | Keep; strengthen default_scope / availability as bridge input. |
| C08 | 5 | 5 | 5 | 5.00 | Keep as P0 readback single-path item. |
| C09 | 5 | 5 | 5 | 5.00 | Keep as P0 finite proof_class / downgrade rule. |
| C10 | 4 | 4 | 5 | 4.33 | Keep; mixed outcome user-visible state is essential. |
| C11 | 4 | 3 | 5 | 4.00 | Keep or merge with C04/C10; do not lose sibling semantic state. |
| C12 | 5 | 4 | 4 | 4.33 | Keep; provenance / scope / trace boundary is important. |
| C13 | 4 | 4 | 4 | 4.00 | Keep; context fixture vs live facts boundary. |
| C14 | 5 | 4 | 5 | 4.67 | Keep; rewrite to name orb/voice choreography vs voice readiness. |
| C15 | 4 | 3 | 4 | 3.67 | Keep or merge with C14; final wording must separate choreography from runtime timing. |
| C16 | 5 | 5 | 5 | 5.00 | Keep as P0 adapter-consumes-snapshot guard. |
| C17 | 5 | 5 | 4 | 4.67 | Keep; projection sketch without rewriting C3/C6. |
| C18 | 5 | 5 | 4 | 4.67 | Keep; may be paired with C19 but not deleted. |
| C19 | 5 | 5 | 4 | 4.67 | Keep; schema existence must not unlock model/golden/voice/endpoint. |
| C20 | 4 | 4 | 5 | 4.33 | Keep; evidence replay identity. |
| C21 | 4 | 5 | 5 | 4.67 | Keep; abnormal terminal snapshot coverage. |
| C22 | 4 | 4 | 4 | 4.00 | Keep; project boundary guard. |
| C23 | 5 | 4 | 3 | 4.00 | Keep as governance guard; avoid duplicating C01. |
| C24 | 4 | 5 | 5 | 4.67 | Keep; interaction semantics must cross bridge. |
| C25 | 3 | 3 | 5 | 3.67 | Rewrite; separate bridge fields from explicit visual policy, especially reduce motion/orb. |
| C26 | 5 | 5 | 4 | 4.67 | Keep; dual-worktree proof attribution. |
| C27 | 4 | 5 | 4 | 4.33 | Keep; schema version and fixture compatibility. |
| C28 | 4 | 5 | 4 | 4.33 | Rewrite; validation lanes must be minimal and proof-class-separated. |
| C29 | 5 | 5 | 4 | 4.67 | Keep; rewrite toward concrete exit criteria and R5 split. |
| C30 | 5 | 4 | 4 | 4.33 | Keep; rewrite toward reference-only hygiene and no external-field import. |

## Consensus

Round 01 supports keeping all 30 candidates. No reviewer recommended deletion of a whole risk area.

The highest consensus hard guards are:

- Single bridge authority and no second bridge SSOT.
- Proof-class cap after R3 human review.
- Mainline co-author review as a real blocker-clearing mechanism.
- Snapshot/readback/result-kind/scope-origin single data path.
- UIUE adapter consumption boundary.
- R4 exit criteria and explicit R5 split.
- Evidence attribution across UIUE and mainline dirty worktrees.

## Rewrite Queue

The final matrix should rewrite these candidates, not discard them:

- `C03`: add concrete owner/input/output/stop condition for mainline co-author review.
- `C05`: align `result_kind` language to OpenSpec vocabulary while still preserving human-readable scenario names.
- `C06`: explicitly say `missing` is a proposed bridge addition, not current Core truth.
- `C14`: emphasize orb/voice fields are presentation choreography only.
- `C25`: avoid forcing every visual concern into bridge schema; allow explicit visual policy where correct.
- `C28`: split validation by proof class and avoid a fake all-in-one validation gate.
- `C29`: define R4 exit / R5 entry as burndown and lane split, not readiness claims.
- `C30`: strengthen external reference hygiene.

## Merge Candidates

Potential grouping in the final burndown, without reducing the final matrix count:

- `C04` + `C11`: snapshot field completeness and sibling-state semantics.
- `C14` + `C15`: choreography fields and thinking/timing boundary.
- `C18` + `C19`: post-C6 / C5 / golden / voice / endpoint non-goals.
- `C20` + `C26` + `C27`: evidence replay identity, receipt attribution, and schema versioning.

## Round 01 Verdict

`PASS_WITH_REWRITE_NOTES`.

The blind set is strong enough to advance to Round 02. The controller should keep all 30 topics, tighten wording, and preserve the proof-class and R4/R5 boundary discipline.
