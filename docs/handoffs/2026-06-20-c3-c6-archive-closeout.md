# C3/C6 OpenSpec archive closeout

Date: 2026-06-20
Branch: codex/p0-2-c6-model-fingerprint
Status: V-PASS
Head before archive: 607dbe3ee70c334723ed09ae690b3c5f65b790f4

## C3 7.3 Debt

- Decision: moved to P1-B Qwen spike, not measured in C3.
- Evidence: `docs/research/2026-06-20-c3-home-llm-adopt-spike.md §7.3` says C3 has no active model runtime path for Qwen3 sampling; `docs/roadmap-2026-06-20-from-c6-done.md` assigns Qwen parser/GDN runtime proof to P1-B.
- Task update: `openspec/changes/archive/2026-06-20-define-execution-contract/tasks.md` marks 7.3 as superseded/moved and says not to hard-code sampling in C3.

## Archive Results

- C3 command: `openspec archive define-execution-contract -y`
- C3 result: archived as `openspec/changes/archive/2026-06-20-define-execution-contract/`; spec created at `openspec/specs/tool-execution/spec.md`.
- C6 readiness: `swift test` pass; `C6BenchCLI verify-gold` archive-check pass; `make verify` pass; C2 readback delta remains readback-only.
- C6 command: `openspec archive define-vehicle-tool-bench -y`
- C6 result: archived as `openspec/changes/archive/2026-06-20-define-vehicle-tool-bench/`; spec created at `openspec/specs/vehicle-tool-bench/spec.md`.

## C6 Verify Gold

- Archive-check report: `Reports/c6-gold-verify-archive-check-20260620-185441/c6-gold-verify.json`
- Status: pass
- Cases: 57
- Candidates: 59
- Gold replay pass/fail: 57 / 0

## Verification

- `openspec validate define-execution-contract --strict`: pass before C3 archive.
- `openspec validate define-vehicle-tool-bench --strict`: pass before C6 archive.
- `swift test`: pass, 80 tests, 3 skipped, 0 failures.
- `swift run C6BenchCLI verify-gold --repo-root /Users/wanglei/workspace/MAformac --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-gold-verify-archive-check-20260620-185441`: pass.
- `make verify`: pass.
- `openspec validate --specs --strict`: pass, 6 specs.
- `openspec validate --all --strict`: pass, 6 specs.
- `openspec list`: only `_parked` remains active.

## C2 Readback Delta

- Current `git diff -- contracts/state-cells.yaml`: empty.
- Historical C6 closeout delta is readback-only:
  - `ac.fan_speed`: `readback_zh: "{温区}空调风量{值}挡"`
  - `ambient.color`: `readback_zh: "氛围灯颜色{值}"`
- No range, enum, default, source refs, or state cell semantics changed.

## Next

- P1-A C5 data gate.
- P1-B Qwen spike.
- P1-C LoRA train only after P1-A and P1-B both pass.
