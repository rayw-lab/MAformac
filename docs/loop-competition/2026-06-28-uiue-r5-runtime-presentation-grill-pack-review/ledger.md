# Loop Competition Ledger - UIUE R5 Runtime-Presentation Grill Pack Review

## Contract

- Output directory: `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review`
- Source candidate artifact: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-r5-runtime-presentation-grill-pack-2026-06-28.md`
- Blind candidates: `215`
- Rounds: `2`
- Reviewers per round: `3`
- Scoring formula: five dimensions, 1-5, total 5-25
- Status: `COMPLETE_READY_FOR_BURNDOWN_INPUT`

## Confirmed Canonical Items

| Canonical ID | Question/Risk/Decision | Priority | Source rounds | Score | Status |
|---|---|---|---|---:|---|
| FINAL-G1 | Mainline DTO / snapshot authority must precede shared adapter and UIUE field consumption. | P0 | R1+R2 | high | keep |
| FINAL-G2 | Proof-class no-promotion ladder must become a checker/receipt schema, not just prose. | P0 | R1+R2 | high | keep |
| FINAL-G3 | Terminal snapshot/finality fixture manifest must cover cancel/interruption/timeout/partial/refusal/already-state/stale async. | P0/P1 | R1+R2 | high | keep/merge |
| FINAL-G4 | UIUE consumer mapping needs explicit crosswalk against mainline DTO, including active/refused/sibling/context gaps. | P0/P1 | R1+R2 | high | keep |
| FINAL-G5 | Direct-touch/gear/summary/a11y/product visual rows require human/product policy routing. | P1 | R1+R2 | mixed-high | human_review/uiue_first |
| FINAL-G6 | Voice/model/golden/mobile/true-device rows remain future-lane non-claim guards unless promoted. | P2 | R1+R2 | mixed | defer_future_lane |

## Eliminated Items

| Candidate | Round | Reason |
|---|---|---|
| none | final | No candidate was physically deleted from the audit trail; low-leverage rows are marked merge/drop/future-lane in final matrix. |

## Merge Records

| From | Into | Round | Reason |
|---|---|---|---|
| proof/non-claim duplicates | FINAL-G2 | R1+R2 | Repeated but critical false-green guardrail. |
| terminal fixture duplicates | FINAL-G3 | R1+R2 | Many rows are fixture coverage variants. |
| bridge/snapshot/readback duplicates | FINAL-G1/FINAL-G4 | R1+R2 | Same authority/crosswalk risk from producer and consumer sides. |
| voice/model/golden/mobile rows | FINAL-G6 | R1+R2 | Future-lane guardrails, not R5 dispatch blockers. |
| direct-touch/a11y/product rows | FINAL-G5 | R1+R2 | Need product/human-review decision before implementation truth. |

## Remaining Gaps

- Downstream burndown must decide exact work package split from `final-grill-matrix.md`.
- Human-review/product-policy rows need explicit accepted/rejected wording before implementation.
- Runtime/device/model/golden proof remains future-lane gated.

## Next Round Focus

- No further scoring round is required before burndown.
- Next step should be two-window burndown dispatch: mainline-first DTO/fixture/checker package and UIUE-first consumer/proof/human-review package.

## Phase Manifest

| Round | Candidates proposed | Reviewer files present | Judge file present | Ledger updated |
|---|---:|---|---|---|
| round-01 | 215 fixed blind candidates | 3 valid files present; original RED blocked and replacement recorded | present | updated |
| round-02 | 215 fixed blind candidates | 3 valid files present; original PURPLE blocked and replacement recorded | present | updated |
| final | 215 fixed blind candidates | 6 valid reviewer files | final matrix present | complete |

## Reviewer Replacement Log

| Round | Slot | Original agent | Status | Replacement | Result |
|---|---|---|---|---|---|
| round-01 | RED failure auditor | Harvey / `019f0ca3-0f2c-7b92-b04c-3e37ed70c72d` | BLOCKED read-only, no file | Popper / `019f0cab-2729-7de3-a890-76784af46d07` | valid `brain-1.md`, 215/215 scores and notes |
| round-02 | PURPLE systems architect | Ptolemy / `019f0cb0-5a74-7dc1-91cd-0acc635ead93` | PARTIAL read-only, no file | Herschel / `019f0cb4-bcdf-7212-a15e-0e47e1d3c99d` | valid `brain-1.md`, 215/215 scores and notes |
