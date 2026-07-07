# RECEIPT-RAT — E-2 ratification + route-board refresh PR

status: DONE
timestamp: 2026-07-02
worker: codex RAT
worktree: /Users/wanglei/workspace/MAformac-rat
branch: docs/e2-ratification-route-refresh
base: main @ 80ea379c3dea93b8b5419c192563872764b1bba1
source: 873dd11f5edd249631123b26550749dc82a04df4
commit: 127b4fdf92e0c6bd5799d03a57073f87df297201
pr: https://github.com/rayw-lab/MAformac/pull/16

## Scope

- Ported E-2 ratification docs and route-board refresh as a small docs PR.
- Did not merge the PR.
- Did not run training, generation, C6 acceptance, runtime NLU, or any R7-blocked action.

## Changed Paths

- docs/CURRENT.md
- docs/baseline-roadmap-2026-07-02-pre-lora.md
- docs/c5-training-readiness-grill/e2-subset-grill-README.md
- docs/c5-training-readiness-grill/e2-subset-SYNTHESIS.md
- docs/c5-training-readiness-grill/e2-subset-w1-decisions.md
- docs/c5-training-readiness-grill/e2-subset-w2-decisions.md
- docs/c5-training-readiness-grill/e2-subset-w3-decisions.md
- docs/c5-training-readiness-grill/e2-subset-commander-d9-premortem.md
- docs/e2-subset-design-package-2026-07-02.md
- docs/c5-training-readiness-grill/landing-matrix.md
- docs/commander-log/decisions.md
- docs/lessons-learned.md

No-diff checklist items because main already matched source:
- docs/commander-log/COMMANDER-INDEX.md
- docs/lora-loop-blueprint-2026-07-02.md

## Anti-Delete Gate

PASS. Cached diff deletion scan showed deletions only for stale pre-M1 route lines:
- docs/CURRENT.md: old 2026-07-02 / ab355f6c / pre-LoRA HOLD wording.
- docs/baseline-roadmap-2026-07-02-pre-lora.md: old ab355f6c, PR #1-#11, wave-1 pending, M1 pending, HOLD wording.

No deletion of main-new M1/D-018/D-019 content was detected.

## Validation

- `git diff --cached --check`: PASS
- `make verify-refs verify-cross-section`: PASS
  - refs=ok, ledger=ok, coverage=ok, cross-section consistent=true
- GitNexus `detect_changes(scope=staged, worktree=/Users/wanglei/workspace/MAformac-rat)`: risk_level=low, changed_files=12, affected_processes=0
- PR CI: GitHub check `verify` SUCCESS, run job https://github.com/rayw-lab/MAformac/actions/runs/28563677280/job/84686491223

## Notes

- Source commit had W1/W2/W3 E-2 worker docs still marked proposed in frontmatter/table status. Per SPEC-RAT and D-019, RAT updated only the status cascade to `ratified_locked_with_conditions` / `locked_with_conditions`; decision content was not changed.
