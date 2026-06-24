# Loop Competition Ledger

## Contract

- Source: fixed 24 Phase 0 grill candidates in `candidates-blind.md`
- Output directory: `docs/loop-competition/2026-06-24-phase0-grill`
- Rounds: 2
- Candidates per round: 24 fixed candidates
- Reviewers per round: 3
- Final target count: 24 scored candidates
- Scoring formula: 5 dimensions, 1-5 each, total 5-25
- Acceptance: all 24 final candidates accepted by user on 2026-06-24; see `acceptance-archive.md`

## Confirmed Canonical Items

| Canonical ID | Question | Priority | Source rounds | Score | Status |
|---|---|---|---|---:|---|
| C01 | `a2-post-roadmap` role classification and forbidden authority claims | Merge/P2 standalone | R1+R2 | 20.00 | Merge into C02; no standalone user grill |
| C02 | Post-A2 responsibility split across roadmap-like artifacts | P0 | R1+R2 | 21.83 | Keep; authority matrix |
| C03 | `full`/`demo` artifact matrix and one-SSOT proof | P0 | R1+R2 | 24.83 | Keep; standalone blocker |
| C04 | Archived spec disposition after D-domain and C6 shifts | P0 | R1+R2 | 24.17 | Keep; standalone blocker |
| C05 | Pocock/OpenSpec stage triage before implementation | P0 | R1+R2 | 22.33 | Keep |
| C06 | Canonical route/runtime/outcome/readback/refusal fields | P0 | R1+R2 | 23.83 | Keep |
| C07 | D1-D37 and MASTER decision-status manifest | P0 | R1+R2 | 21.33 | Keep; narrow to touched decisions + manifest |
| C08 | UIUE isolation versus state/C3-C6/golden contract intersections | P1 with P0 intersection | R1+R2 | 19.50 | Keep only contract-intersection frame |
| C09 | Failure/error-recovery class cut-or-seed decision | P1 | R1+R2 | 22.17 | Keep; retrain-propose taxonomy |
| C10 | `already_state` / state-noop classification | P1 | R1+R2 | 20.83 | Keep; merge into taxonomy |
| C11 | C5 data-class factors and evidence threshold | P1 | R1+R2 | 21.33 | Keep; hypothesis values pending spike |
| C12 | Deterministic-template versus cloud-generation split | P1 | R1+R2 | 22.00 | Keep; same recipe package |
| C13 | Held-out axes and leakage defense | P0 | R1+R2 | 24.67 | Keep; standalone blocker |
| C14 | Mid-training C6 gate and stop/pause policy | P0 | R1+R2 | 24.50 | Keep; standalone blocker |
| C15 | Training-stack tiny-epoch spike as hard precondition | P0 carrier / P1 execution | R1+R2 | 22.50 | Keep; propose-task hard gate |
| C16 | Frozen versus variable LoRA recipe knobs | P1 | R1+R2 | 21.00 | Keep |
| C17 | Old 10/23 historical anchor versus new D-domain base anchor | P0 | R1+R2 | 24.50 | Keep; standalone blocker |
| C18 | C6 four-layer denominators, thresholds, and fail priority | P0 | R1+R2 | 24.67 | Keep; standalone blocker |
| C19 | Endpoint parity timing and evidence boundary | P0 boundary / P1 execution | R1+R2 | 22.50 | Keep; forbid endpoint-ready claim laundering |
| C20 | Endpoint parser/repair/whitelist/failure enum policy | P0 | R1+R2 | 24.00 | Keep; standalone blocker |
| C21 | Mainline ownership of `tool -> IR -> state_cell -> card -> patch` | P0 | R1+R2 | 22.50 | Keep |
| C22 | Demo-golden-run stable IDs and C6 linkage | P0 entry / P1 execution | R1+R2 | 21.33 | Keep; entry conditions only |
| C23 | Mandatory ground-truth/cross-vendor review trigger/schema | P1 | R1+R2 | 20.50 | Keep; add negative list |
| C24 | Acceptance/status vocabulary and forbidden implication rules | P0 | R1+R2 | 24.67 | Keep; standalone blocker |

## Eliminated Items

| Candidate | Round | Reason |
|---|---|---|

## Merge Records

| From | Into | Round | Reason |
|---|---|---|---|
| C01 | C02 | R1 | Role classification and responsibility split should land in one authority matrix. |
| C09, C10, C11, C12 | C5 data recipe package | R1 | Data taxonomy, `already_state`, category factors, and template/cloud generation split should land together while preserving separate acceptance clauses. |
| C13, C14, C18 | Anti-fake-green C5/C6 gate package | R1 | Held-out axes, mid-training gate, and final C6 scoring must share layers/receipts but fail independently. |
| C19, C20 | Endpoint parity/parser package | R1 | Endpoint evidence timing and parser policy are coupled; parser policy remains standalone hard gate. |
| C21, C22 | Mainline state/golden interface | R1 | UIUE consumes stable IDs and mappings; mainline owns contract truth. |
| C06, C24 | Outcome/status vocabulary package | R1 | Runtime outcome enums and acceptance pass labels must be aligned without being collapsed. |

## Remaining Gaps

- No remaining competition gaps. Final synthesis, acceptance archive, and skill update are complete.
- Remaining project work is outside the competition loop: convert accepted Phase 0 decisions into OpenSpec-ready manifests/tasks.

## Next Round Focus

- No further competition round.
- Next project action: Phase 0 materialization, starting with C02/C03/C04/C05/C06/C07/C24.

## Phase Manifest

| Round | Candidates proposed | Reviewer files present | Judge file present | Ledger updated |
|---|---:|---|---|---|
| R1 | 24 | 3/3 | yes | yes |
| R2 | 24 | 3/3 | yes | yes |
