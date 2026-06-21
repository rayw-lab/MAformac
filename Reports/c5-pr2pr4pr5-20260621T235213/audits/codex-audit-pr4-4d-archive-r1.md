# PR4 4d Archive Audit

Verdict: PASS_WITH_NOTES

## Findings
- P3 `Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md:13` registers PR4 4a and 4b, but not this PR4 4d archive audit. This is not an archive blocker because this report did not exist before this audit run, and the user explicitly assigned INDEX backfill to the main agent. Concrete fix: after accepting this report, add an INDEX row for `codex-audit-pr4-4d-archive-r1.md` with verdict `PASS_WITH_NOTES` and note that archive/list/spec/validate checks passed.

## Checks Run
- `openspec list --json` no longer lists `define-lora-training` as an active change. Active names observed: `run-lora-candidate-training`, `define-lora-data-gate`, `_parked`.
- `find openspec/changes/archive/2026-06-21-define-lora-training -maxdepth 4 -type f | sort` confirms required archive files exist: `.openspec.yaml`, `proposal.md`, `design.md`, `specs/lora-training/spec.md`, and `tasks.md`.
- `grep -cE '^\s*- \[[ xX]\]' openspec/changes/archive/2026-06-21-define-lora-training/tasks.md` => `34`.
- `grep -cE '^\s*- \[ \]' openspec/changes/archive/2026-06-21-define-lora-training/tasks.md` => `0`.
- `openspec validate lora-training --strict` => `Specification 'lora-training' is valid`.
- `openspec validate --all --strict` => 8 passed, 0 failed: `change/define-lora-data-gate`, `spec/demo-experience`, `spec/lora-training`, `spec/scenario-state-protocol`, `spec/semantic-function-contract`, `spec/tool-execution`, `spec/vehicle-capabilities`, `spec/vehicle-tool-bench`.
- Main spec Purpose is non-placeholder at `openspec/specs/lora-training/spec.md:3`-`openspec/specs/lora-training/spec.md:4`, and states C5 keeps train-health separate from C6 model-quality and physical endpoint V-PASS.
- Smoke-only is not candidate readiness: `openspec/specs/lora-training/spec.md:22`-`openspec/specs/lora-training/spec.md:29` requires `smoke_only`, `train_eligible=false`, and smoke health signals only.
- Candidate readiness preserves C6 diff/fingerprints/fuse parity/endpoint byte parity: `openspec/specs/lora-training/spec.md:155`-`openspec/specs/lora-training/spec.md:189`.
- Validation loss cannot sign V-PASS: `openspec/specs/lora-training/spec.md:191`-`openspec/specs/lora-training/spec.md:203` limits low-loss/no-C6 status to `acceptance_stage=train_health`.
- Closeout archive receipt accurately states archive status at `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:97`-`Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:106`.
- Closeout does not overclaim PR5 candidate quality: `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:13`-`Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:14` defer C6/parity/V-PASS to PR5 and mark `PR5_BLOCKED`; `Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:108`-`Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md:112` repeats the non-claims.
- Audit INDEX contains PR4 4a and 4b rows at `Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md:12`-`Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md:13`; 4d is absent as expected before this report is indexed.

## Notes
- No P0/P1/P2 archive-blocking issue found.
- No stale active-change status, missing spec sync, open archived checkbox, placeholder main spec Purpose, or PR5 candidate overclaim found.
- `git status --short -- openspec/changes/archive/2026-06-21-define-lora-training openspec/specs/lora-training/spec.md Reports/c5-pr2pr4pr5-20260621T235213/pr4-closeout/c5-remediation-closeout.md Reports/c5-pr2pr4pr5-20260621T235213/audits/INDEX.md` currently reports those target artifacts as untracked. This is not a 4d archive blocker, but final PR4/PR5 commit hygiene must stage the archived change, synced main spec, closeout, INDEX update, and this audit report together.
