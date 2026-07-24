# RECHECK-INT-V5A-by-w3 — int-v5a 修复复审

~~~yaml
status: PASS
artifact_kind: recheck_report
reviewer: w3 / Codex
producer: w1
target_worktree: /Users/wanglei/workspace/MAformac-int-v5a
head: e4d52417fed51dfe7877d78c0803df663dd2814f
branch: int/v5a-runtime-bundle-20260711
base: ef5761b3cedd39033998f7425f0b4413ff10935b
commit_a: ed4aabc42a831d1838820eb89fdbeef3535797b2
commit_b: e4d52417fed51dfe7877d78c0803df663dd2814f
source_audit: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/reports/XAUDIT-INT-V5A-by-w3.md
proof_class: local/unit/integration/static_receipt
non_claims: not runtime/operator/V-PASS; not C5/C6 acceptance; not true-device/mobile/live_api
~~~

## Verdict

**PASS.** 原 `XAUDIT-INT-V5A-by-w3.md` register 的 3 条 finding 均已修复：

- P0-1 `make verify-ci` live fail：**FIXED**
- P1-1 final receipt 缺 final `make verify-ci`：**FIXED**
- P1-2 收编门三件套 receipt 缺失：**FIXED**

## Register recheck

| ID | recheck verdict | evidence |
|---|---|---|
| P0-1 | **FIXED** | `scripts/test_verify_ci_checker_presence.py:21-27` 已包含 7 个 required checker，含两个新增 int-v5a checker；`python3 scripts/test_verify_ci_checker_presence.py` rc0，输出 7/7 delete-mutation fail-closed；我亲跑 `make verify-ci` rc0，末段 `784 tests, 6 skipped, 0 failures`。 |
| P1-1 | **FIXED** | `.build/int-v5a/receipts/final-validation.json:12-20` 已记录 final command set，含 `make verify-ci` rc0、`make verify-all` rc0、`swift test` rc0、xcodebuild rc0、runtime bundle/action probes/matrix/OpenSpec rc0；`.venv/bin/python Tools/checks/check_int_v5a_execution_receipt.py --phase final --input .build/int-v5a/receipts/final-validation.json` rc0 / `status=PASS`。 |
| P1-2 | **FIXED** | `.build/int-v5a/receipts/final-validation.json:21-26` 已补 Commit A/B exact pathspec staged list、`git diff --cached --check`、GitNexus detect-changes compare base；我亲跑 `node .gitnexus/run.cjs detect-changes --scope compare --base-ref ef5761b3... --repo MAformac` rc0，risk `medium`，无 HIGH/CRITICAL。 |

## Required hard gate evidence

| check | observed |
|---|---|
| worktree truth | `git status --short --branch` → `## int/v5a-runtime-bundle-20260711`; no dirty tracked output. |
| HEAD | `e4d52417`，subject `fix(runtime): generate default contract bundle from canonical sources`。 |
| base..HEAD shape | `git rev-list --count ef5761b3..HEAD` → `2`; commits are `ed4aabc4 refactor(c1): rename canDemo to actionDemoProven` and `e4d52417 fix(runtime): generate default contract bundle from canonical sources`。 |
| checker presence source | Makefile `verify-c1-checker-files` expects 7 checkers; `scripts/test_verify_ci_checker_presence.py` now enumerates the same 7. |
| checker-presence meta-test | `python3 scripts/test_verify_ci_checker_presence.py` rc0; output explicitly lists all 7 delete mutations fail closed. |
| manual delete probe 1 | deleted `Tools/checks/check_action_demo_proven_legacy_tokens.py` in temp sentinel repo; `make verify-ci` rc2; output `ERROR_MISSING_C1_CHECKER Tools/checks/check_action_demo_proven_legacy_tokens.py`。 |
| manual delete probe 2 | deleted `Tools/checks/check_int_v5a_execution_receipt.py` in temp sentinel repo; `make verify-ci` rc2; output `ERROR_MISSING_C1_CHECKER Tools/checks/check_int_v5a_execution_receipt.py`。 |
| final `make verify-ci` | rc0; final suite `784 tests, 6 skipped, 0 failures`; contentview display-catalog check passed. |
| final receipt schema | `.venv/bin/python Tools/checks/check_int_v5a_execution_receipt.py --phase final --input .build/int-v5a/receipts/final-validation.json` → `{"errors": [], "status": "PASS"}`。 |
| GitNexus final compare | rc0; `Changes: 42 files, 90 symbols`; risk `medium`; affected processes 5. |

## Commands register

| command | rc | note |
|---|---:|---|
| `python3 scripts/test_verify_ci_checker_presence.py` | 0 | 7/7 required checker delete mutations fail closed. |
| `make verify-ci` | 0 | 784 tests, 6 skipped, 0 failures. |
| manual temp sentinel delete: `check_action_demo_proven_legacy_tokens.py` then `make verify-ci` | 2 | expected fail-closed; missing checker marker present. |
| manual temp sentinel delete: `check_int_v5a_execution_receipt.py` then `make verify-ci` | 2 | expected fail-closed; missing checker marker present. |
| `.venv/bin/python Tools/checks/check_int_v5a_execution_receipt.py --phase final --input .build/int-v5a/receipts/final-validation.json` | 0 | final receipt schema PASS. |
| `node .gitnexus/run.cjs detect-changes --scope compare --base-ref ef5761b3cedd39033998f7425f0b4413ff10935b --repo MAformac` | 0 | risk medium; no HIGH/CRITICAL. |

## Residual risks / non-claims

- 本复审 proof class 仍是 local/unit/integration/static receipt；不等于 runtime operator-pass、V-PASS、C5/C6 acceptance、mobile/true-device/live_api。
- `make verify-ci` 证明 CI-bound local gates 绿；不证明 app 现场演示可用。
- GitNexus compare 为 advisory scope proof；本报告不提交、不 push、不合并。

## REPORT

RECHECK-V5A
