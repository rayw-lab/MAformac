---
status: clear_with_fixes_absorbed
artifact_kind: same_vendor_plan_precheck
authority: audit_record_not_ssot
auditor: Codex subagent Boyle
audited_file: docs/superpowers/plans/2026-06-24-default-scope-apply.md
created: 2026-06-24
retire_trigger: "Retire after default-scope apply closeout receipt supersedes this plan audit."
---

# Default-Scope Apply Plan Audit — Codex Same-Vendor Pre-Check

## Verdict

`CLEAR_WITH_FIXES`, absorbed into `docs/superpowers/plans/2026-06-24-default-scope-apply.md`.

This audit is a same-vendor pre-check only. It does not close R-L17, does not approve training, does not approve C6 acceptance, and does not prove the default-scope implementation exists.

## Findings Absorbed

| ID | Severity | Finding | Absorbed In Plan |
|---|---|---|---|
| A1 | P1 | C5/C2 parity was declared as a gate but lacked a physical script and Makefile hook. Omitted-scope C5 targets also must omit executable scope args. | Added `scripts/check_c5_c2_scope_parity.py`, Makefile hook, and split omitted vs explicit C5 tests. |
| A2 | P1 | `ScopeOrigin` values drifted between plan and carrier: `.omitted` vs `defaulted`. Gate C was too narrow. | Aligned enum to `defaulted/explicit/fanout`; expanded Gate C consumers. |
| A3 | P1 | Legacy unscoped UI keys had no disposition task. | Added explicit legacy UI key disposition step for `DemoVehicleStateStore` and `ContentView`. |
| A4 | P1 | C6 JSONL instructions encouraged manual row replacement. | Replaced with source update plus `swift run C6BenchCLI generate` and trap append workflow. |
| A5 | P1 | Receipt example could fake pass by hardcoding command exit code 0. | Receipt schema now requires `evidence_path` and `sha256`; receipt capture records actual command logs and exit codes. |
| A6 | P1 | Test snippets were stale against current A2 code: missing `stateRevision`, missing `irMap` for D-domain state applier tests. | Updated snippets to pass `stateRevision: 0` and load/pass `irMap`. |
| A7 | P2 | `contracts/demo-scenarios.yaml` and `contracts/l1-demo-allowlist.yaml` were neither included nor explicitly deferred. | Added include-or-defer task and receipt boundary. |

## Remaining Open

- Physical implementation has not started.
- Three mechanical gates have not run.
- R-L17 G2-G5 remain open.
- UIUE reconfirm remains pending.
- C5 retrain, C6 acceptance, real evaluation, voice, and demo-golden-run remain blocked/deferred.
