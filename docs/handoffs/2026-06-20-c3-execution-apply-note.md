# C3 execution apply note — 2026-06-20

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## Scope

This apply implements `define-execution-contract` in Swift. The change consumes C1/C2 contract artifacts as read-only inputs and does not modify `contracts/`, `openspec/specs/`, or `openspec/changes/define-execution-contract/`.

## Verified inputs

- `openspec validate define-execution-contract --strict`: pass on branch `feat/c3-execution-apply`.
- `make verify`: pass with `state_cells=ok`, `c1_c2_closure=active`, `l1_closure=ok`, `risk_policy=ok`, and `demo_scenarios=ok`.
- Initial `git diff -- contracts openspec/specs openspec/changes/define-execution-contract`: empty.

## Apply rule

If implementation requires changing C1/C2 contracts, OpenSpec specs, or the aligned `define-execution-contract` artifacts, stop and open a separate change. Do not silently patch the contract from C3 apply.
