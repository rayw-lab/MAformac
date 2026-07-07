# P0-3/P0-4 C6 trap-gold closeout

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

Date: 2026-06-20
Branch: codex/p0-2-c6-model-fingerprint
Status: T-PASS
Ready for archive: true

## Scope

- P0-1 NIT fixed: `C6ReadbackRenderer.render` is private; readback hard gate uses `matches`.
- P0-2 NIT fixed: base envelope plus `--lora-adapter` exits usage error.
- P0-3a implemented: `C6BenchCase.alternatives` supports old JSONL default `[]`; only `quality="acceptable"` can pass.
- P0-4a implemented: `C6GoldVerifier` and `C6BenchCLI verify-gold` replay primary + acceptable candidates and fail closed.
- Final subagent audit findings fixed: rejection/clarification hard gate now requires asserted text evidence, and no-call readback is reported as non-applicable instead of pass.

## Authorized C2 Readback Delta

- Initial P0-4a baseline exposed 5 old gold readback failures: `C6-MP-008`, `C6-MP-009`, `C6-MP-010`, `C6-MP-011`, `C6-MP-028`.
- Root cause: old gold already referenced legal cells `ac.fan_speed` and `ambient.color`, but those cells lacked `readback_zh`.
- User authorized a narrow C2 readback-only fix: add templates for those two existing cells only.
- No state cell semantics, ranges, enums, or source refs were changed.

## P0-3 Trap Dataset

- Trap cases added: 12
- Category counts: negation=2, numeric_lure=2, correction=2, ambiguous=2, safety_inheritance=2, low_confidence_asr=2
- Alternatives count: 2, only on ambiguous cases
- Source refs unresolved: 0
- All `must_pass=true` trap cases are `must_not_train=true`.

## P0-4 Verify Gold

- Baseline report: `Reports/c6-gold-verify-baseline-readback-authorized-20260620-182330/c6-gold-verify.json`
- Baseline status: pass, cases=45, candidates=45, failures=0
- Final report: `Reports/c6-gold-verify-final-post-audit-fix-20260620-183639/c6-gold-verify.json`
- Final status: pass, cases=57, candidates=59, failures=0

## Verification

- `swift test --filter C6VehicleToolBenchTests`: pass, 32 tests
- `swift run C6BenchCLI verify-gold ...final-post-audit-fix...`: pass
- `openspec validate define-vehicle-tool-bench --strict`: pass
- `swift test`: pass, 80 tests, 3 skipped
- `make verify`: pass, including protected contract diff check

## Next

- Commit and push branch `codex/p0-2-c6-model-fingerprint`.
