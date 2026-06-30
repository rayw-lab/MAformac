# Round 02 Judge Synthesis

- Date: 2026-06-28
- Round: 02
- Reviewers: PURPLE / ORANGE / BLACK
- Scope: fixed blind set `C01-C30`
- Proof class: review synthesis only

## Mechanical Check

- `round-02/brain-1.md`: required sections present; C01-C30 covered.
- `round-02/brain-2.md`: required sections present; C01-C30 covered.
- `round-02/brain-3.md`: required sections present; C01-C30 covered.

## Round 02 Score Snapshot

| ID | PURPLE | ORANGE | BLACK | R2 Avg | Round 02 signal |
| --- | ---: | ---: | ---: | ---: | --- |
| C01 | 5 | 5 | 5 | 5.00 | Single authority remains the top R4 contract risk. |
| C02 | 5 | 5 | 5 | 5.00 | Proof-class separation is non-negotiable. |
| C03 | 5 | 4 | 5 | 4.67 | Co-author review must have owner/input/output/blocker. |
| C04 | 5 | 5 | 4 | 4.67 | Snapshot contract is core; rewrite for precision. |
| C05 | 5 | 5 | 4 | 4.67 | Result kind is a testable mixed-outcome hinge. |
| C06 | 5 | 4 | 5 | 4.67 | `missing` must be treated as proposed addition, not current Core truth. |
| C07 | 2 | 4 | 4 | 3.33 | Useful but overlaps; final should narrow to bridge-carried interaction semantics. |
| C08 | 3 | 5 | 5 | 4.33 | Keep as single-path readback guard. |
| C09 | 5 | 5 | 5 | 5.00 | Fail-closed proof_class is a hard evidence gate. |
| C10 | 5 | 5 | 4 | 4.67 | Mixed outcome remains a core presentation/runtime pressure test. |
| C11 | 4 | 4 | 4 | 4.00 | Keep, likely grouped with snapshot and mixed outcome. |
| C12 | 5 | 4 | 5 | 4.67 | Provenance/scope/trace boundary is architectural. |
| C13 | 4 | 4 | 4 | 4.00 | Keep as demo-context vs live-truth guard. |
| C14 | 4 | 3 | 5 | 4.00 | Keep; tie to proof boundary and voice non-readiness. |
| C15 | 3 | 4 | 4 | 3.67 | Keep or merge; focus on semantic timing boundaries. |
| C16 | 5 | 4 | 5 | 4.67 | Snapshot consumption boundary is essential. |
| C17 | 5 | 4 | 5 | 4.67 | Mainline projection seam is essential. |
| C18 | 4 | 3 | 5 | 4.00 | Keep as post-C6 non-goal guard. |
| C19 | 5 | 3 | 5 | 4.33 | Keep as R5 unlock guard. |
| C20 | 4 | 5 | 4 | 4.33 | Keep; write as replay alignment condition. |
| C21 | 5 | 5 | 5 | 5.00 | Terminal snapshot for abnormal paths is hard. |
| C22 | 4 | 3 | 5 | 4.00 | Keep as project-constitution boundary. |
| C23 | 5 | 4 | 5 | 4.67 | Derived artefact vs authority is a hard SSOT guard. |
| C24 | 4 | 5 | 4 | 4.33 | Keep; action semantics must be bridge-visible. |
| C25 | 3 | 4 | 4 | 3.67 | Rewrite to avoid overloading schema with all visual policy. |
| C26 | 4 | 5 | 5 | 4.67 | Receipt attribution is required in dual-worktree state. |
| C27 | 5 | 5 | 5 | 5.00 | Versioning and fixture compatibility are hard. |
| C28 | 4 | 5 | 4 | 4.33 | Keep; validation must be split by proof class. |
| C29 | 5 | 5 | 5 | 5.00 | R4 exit / R5 split is a hard transition gate. |
| C30 | 4 | 3 | 4 | 3.67 | Keep as hygiene guard; may be grouped under roadmap/reference policy. |

## Consensus

Round 02 also supports keeping all 30 risk areas. It is stricter than Round 01 about overlap and wording.

Hard agreement:

- The main risk is not lack of ideas; it is category collapse between bridge contract, UIUE mock consumption, mainline runtime acceptance, and R5 readiness.
- R4 must be a contract and evidence transition, not a stealth runtime/voice/model implementation phase.
- The final checklist should preserve all 30 questions but tighten some into precise, testable R4 gates.

## Rewrite Queue

- `C04`: require explicit snapshot fields and fail-closed behavior.
- `C06`: distinguish current Core state from bridge-proposed future state.
- `C07`: narrow to interaction semantics carried by bridge, not a repeat of R1 local tests.
- `C14` and `C15`: group around choreography versus runtime/voice proof.
- `C25`: explicitly allow an `explicit visual policy` path where bridge schema should not own visual styling.
- `C28`: split validation by schema, fixture, unit, simulator, evidence, and contract validation.
- `C30`: keep as reference-only hygiene, not a broad anti-external slogan.

## Round 02 Verdict

`PASS_WITH_REWRITE_NOTES`.

The final matrix should carry all six reviewer scores and use P0/P1 priority to decide burndown order, not remove lower-scored topics.

