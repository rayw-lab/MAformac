# Supplemental Loop Ledger - R4 UI Corner Cases

- Date: 2026-06-28
- Parent: `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix`
- Scope: supplemental grill candidates `C31-C50`
- Working directory: `/Users/wanglei/workspace/MAformac-uiue`

## Live Snapshot

- UIUE branch observed: `uiue/phase4-default-scope-presentation`
- UIUE HEAD observed: `4a4aabb`
- Dirty tree: heavy; this supplement only writes under `docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/supplement-ui-cornercases/` plus parent `final-grill-matrix-v2.md`.

## Sequence

- [x] Reload loop-competition workflow.
- [x] Re-probe repo truth and current dirty boundary.
- [x] Re-read relevant UIUE authority, R0-R2 matrix/burndown, current R4 matrix, and live UI code anchors.
- [x] Write deductive gap analysis.
- [x] Create supplemental blind candidates C31-C50.
- [x] Round 01: dispatch RED/GREEN/BLUE reviewers.
- [x] Round 01: verify three reviewer markdown files and C31-C50 coverage.
- [x] Round 01: write judge synthesis.
- [x] Round 02: dispatch PURPLE/ORANGE/BLACK reviewers.
- [x] Round 02: verify three reviewer markdown files and C31-C50 coverage.
- [x] Round 02: write judge synthesis.
- [x] Write final supplemental matrix.

## Round 02 File Gate Note

PURPLE initially returned a prose summary and explicitly did not write `round-02/brain-1.md`. The controller rejected that as invalid under the user's markdown-retention requirement and sent a repair instruction. PURPLE then wrote the required Markdown file; only the repaired file is counted in final scoring.
- [x] Write parent combined `final-grill-matrix-v2.md`.
- [x] Mechanical verification.

## Final Verification

- Six supplemental reviewer markdown files exist and cover `C31-C50`.
- `final-supplement-matrix.md` contains exactly 20 supplemental rows.
- Parent `../final-grill-matrix-v2.md` contains exactly 50 R4 rows.
- `git diff --check -- docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix`: pass.
- Readiness terms in final artifacts appear only as negative guardrails, not as positive claims.

## Final Verdict

`PASS_WITH_BOUNDARY_REWRITE`.

The original 30-item R4 bridge matrix was valid but incomplete for UIUE stage corner cases. The accepted supplement adds `C31-C50` and requires R4 to classify UI details as bridge schema, visual policy, or evidence checklist before burndown.

## Deductive Hypothesis

The original `C01-C30` matrix is correct but incomplete. It treats many stage details as broad `PresentationSnapshot` or `visual policy` concerns. R4 needs supplemental questions because zone topology, gesture arbitration, top vehicle/context style switching, long-press thinking/console, macro lifecycle, accessibility, reduce motion, and moving evidence can otherwise fall between bridge contract and R5 implementation.
