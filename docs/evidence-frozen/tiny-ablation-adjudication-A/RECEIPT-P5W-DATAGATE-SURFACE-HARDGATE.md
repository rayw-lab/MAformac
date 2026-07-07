---
artifact_kind: p5w_datagate_surface_hardgate_receipt
status: DONE
proof_class:
  - local_unit
  - local_cli
  - local_mock
created: 2026-07-03
worktree: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge
branch: codex/p5w-wave1-bridge-20260703
not_claimed:
  - live cloud generation
  - training run
  - mobile/true-device acceptance
---

# P5W DataGate Surface Hardgate Receipt

## Output Files

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/governance-fit-grill/gf-reduction-draft.md` rev2: GF-126 absorbed into G04.
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-surface-hardgate-dry-run/gate7-wave1-dry-run-receipt.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-surface-hardgate-dry-run/gate7-wave1-dry-run-receipt.md`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-surface-hardgate-dry-run/gate7-wave1-candidates.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-data-gate-surface-hardgate-probe/missing-surface-candidate.jsonl`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-data-gate-surface-hardgate-probe/formal-no-legacy/c5-data-gate-receipt.json`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-data-gate-surface-hardgate-probe/legacy-allowed/c5-data-gate-receipt.json`

## Code Changes

- `Core/Bench/C5DataGate.swift`: added `allowLegacyMissingSurface`, surface count receipt fields, fail-closed missing-surface check, markdown receipt fields, and fix suggestion.
- `Tools/C5DataGateCLI/main.swift`: added `--allow-legacy-missing-surface` explicit compatibility flag.
- `Tools/Gate7DryRunCLI/main.swift`: carries DataGate surface hardgate counters into dry-run receipt.
- `Tests/MAformacCoreTests/C5DataGateTests.swift`: added formal missing-surface fail-closed, legacy explicit allowance, and full-surface pass tests.
- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`: legacy/frame helper explicitly opts into missing-surface allowance.

## Evidence Table

| Claim | Evidence | Result |
|---|---|---|
| GF-126 absorbed into G04 rev2 | `gf-reduction-draft.md:4`, `:26`, `:92`, `:94`, `:375` | PASS |
| DataGate default formal path fails closed on missing surface | `C5DataGate.swift:268-286`, `:503-517`, `:580-581`, `:605-608`; CLI probe no-flag exit 65; `formal-no-legacy/c5-data-gate-receipt.md:3`, `:21-24` | PASS |
| Legacy schema compatibility is explicit and receipt-recorded | `Tools/C5DataGateCLI/main.swift:29-35`, `:151-179`; CLI probe with `--allow-legacy-missing-surface` exit 0; `legacy-allowed/c5-data-gate-receipt.md:3`, `:21-24` | PASS |
| Gate7 formal dry-run still carries full surface through DataGate | `gate7-wave1-dry-run-receipt.md:14-23`, `:28-33`; JSONL jq count = rows 21, tools/mounted/subset all 21 | PASS |
| Regression tests cover negative, legacy, formal pass, G7, and C5LoRA legacy interactions | `swift test --filter 'C5DataGateTests|Gate7GeneratorPipelineTests|C5LoRATrainingTests'` = 81 tests, 0 failures | PASS |
| Diff hygiene and impact | `git diff --check` exit 0; GitNexus `impact(C5DataGateValidator.receipt)` risk LOW; `detect_changes` risk MEDIUM, affected flows limited to DataGate CLI validator paths | PASS |

## Residual Risk

- `C5DataGateReceipt` keeps new receipt fields optional for backward JSON decode compatibility; new receipts always populate them.
- `Tools/Gate7DryRunCLI/` remains an untracked P5W tool directory from prior surface work; this receipt validates it but does not stage/commit.
- No live cloud generation, training run, or mobile/true-device acceptance was performed.
