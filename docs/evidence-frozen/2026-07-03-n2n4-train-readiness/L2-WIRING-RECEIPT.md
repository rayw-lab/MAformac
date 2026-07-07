---
artifact_kind: l2_wave1_generation_wiring_receipt
status: done_pr_open
proof_class: local/unit/integration_mock
repo: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge
branch: codex/l2-wave1-genwiring-20260703
base_requested: b33d8eba152e5326f69bbe85fc356b73419ee9c3
head: 357255b8
pr: https://github.com/rayw-lab/MAformac/pull/36
generated_at: 2026-07-03T12:36:00+08:00
---

# L2 WIRING RECEIPT

## Verdict

DONE. Wave-1 generation wiring is implemented, committed, pushed, and opened as PR #36.

Commit: `357255b8 feat(c5): wire wave1 hash and batch manifest gates`

Note: local `origin/main` advanced after branch creation to `788fcee8` (`ci: run whitespace diff only on PR events`, only `.github/workflows/verify.yml`). This branch intentionally keeps the user-requested `main_pin_sha=b33d8eba152e5326f69bbe85fc356b73419ee9c3` in the warmup manifest.

## Changed Files

- `Core/Bench/C5DataGate.swift`
- `Core/Generation/Gate7GeneratorPipeline.swift`
- `Core/Training/C5LoRATraining.swift`
- `Tools/C5TrainingCLI/main.swift`
- `Tools/Gate7DryRunCLI/main.swift`
- `Tests/MAformacCoreTests/C5DataGateTests.swift`
- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift`

## Contract Anchors

- N5E-002 hash recompute clause: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/BATCH-CONTRACT-rev2.md:270-301`
- Warmup N=50 and quota SSOT clauses: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/BATCH-CONTRACT-rev2.md:33-38`
- Live hash recipe anchors:
  - `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Core/Training/C5LoRATraining.swift:2834`
  - `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Core/Training/C5LoRATraining.swift:2846`
  - `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge/Core/Bench/C6VehicleToolBench.swift:2329-2331`

## Validation

- `swift test --filter C5DataGateTests` -> PASS, 26 tests.
- `swift test --filter C5LoRATrainingTests` -> PASS, 68 tests.
- `swift test --filter Gate7GeneratorPipelineTests` -> PASS, 13 tests.
- `swift run C5TrainingCLI prepare --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge --output-dir /tmp/maformac-l2-missing-refusal-check` -> exit 64, missing refusal config fail-closed.
- `swift run Gate7DryRunCLI --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L2-wave1-genwiring-dry-run --limit 50 --batch-id wave1-warmup-0001 --lane-id lane-1 --main-pin-sha b33d8eba152e5326f69bbe85fc356b73419ee9c3` -> `status=PASS samples=50 data_gate=data_gate_ready manifest=pass quarantine=1`.
- `swift run C5DataGateCLI --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L2-wave1-genwiring-dry-run/gate7-wave1-candidates.jsonl --source-authorization authorized_fixture --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L2-wave1-genwiring-datagate` -> `status=data_gate_ready rows=51`.
- `git diff --check` -> PASS.
- `gitnexus detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-p5w-wave1-bridge)` -> high risk expected; affected shared DataGate/Training CLI paths covered by tests above.

## Artifacts

- Dry-run receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L2-wave1-genwiring-dry-run/gate7-wave1-dry-run-receipt.json`
  - sha256 `ed0a92375396013ff049a292d5fbe08bbe01de5a30cb7d9a86dce0820b834055`
- Warmup manifest: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L2-wave1-genwiring-dry-run/wave1-warmup-batch-manifest.json`
  - sha256 `a45b13282a2d1435118e3a2af4e556e20fb057fb40826d7b45b737c750db1701`
- Candidate rows: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L2-wave1-genwiring-dry-run/gate7-wave1-candidates.jsonl`
  - sha256 `528b83e90bee0b5dbac9761bf9d4c28aac1453b5623d8c83b39429e1c759aa25`
- Independent DataGate receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L2-wave1-genwiring-datagate/c5-data-gate-receipt.json`
  - sha256 `6f7670b2fc92748e177dbc1aae053e076c8da5a0172391fb97d9e1c558734dab`

## Residual

- SwiftPM still prints pre-existing unhandled file warnings for unrelated UI test/docs/pycache files; no new unhandled files were added.
- `docs/c5-training-readiness-grill/n5-expansion-grill-2026-07-03.md` was not present on `b33d8eba`; implementation used the run-dir `BATCH-CONTRACT-rev2.md` locked clauses and live source anchors.
