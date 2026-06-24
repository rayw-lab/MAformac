# Rebuild-C6 Scoring Foundation Lessons - 2026-06-25

## Verdict

status: lessons_captured
source: Reports/rebuild-c6-scoring-foundation-20260624T173024Z/VERIFY.md
base_sha: 6751be4942ebba079abb3e80c5e827c79fb43a77
local_head_after_phase3: 47b9300

## Lessons

| Phase | Trigger | Bad Assumption | Repo Truth | Fix | Future Guard |
|---|---|---|---|---|---|
| 1A | Coverage rows with `clarifyTag == .ambiguous` looked like clarify cases. | Bucket/tag names alone prove behavior class. | Coverage rows are denominator/fuzz shell inputs, not clarify behavior evidence. | `C6CaseBehaviorClassResolver` excludes `.coverage` from clarify fallback. | Keep behavior class resolution evidence-based; do not infer already/no-call/clarify from broad buckets. |
| 1B | Phase audit returned PASS_WITH_FIXES for missing durable lesson. | Passing tests are enough for phase closure. | Harness requires lessons to be written before audit closure. | Added Phase 1B lesson and reran audit to PASS. | Write a phase lesson before each audit, even when the phase is straightforward. |
| 1C | Plan expected selector red tests, but Phase 1B had already introduced selector mechanics. | Every planned red test remains red at phase start. | Live repo truth can make a planned red test already green from earlier valid implementation. | Added a stronger denominator report red test instead of weakening coverage. | Record pre-existing-green deviations and add a stronger invariant test. |
| 2 | `appliedWrites` initially did not exist. | Existing scope-origin evidence was enough apply proof. | Enum writes and dependency side effects mutated state without descriptive write facts. | Added shared `StateWrite`, `StateWriteKind`, and `ToolContractStateApplyResult.appliedWrites`. | Require producer facts for direct, dependency, and enum writes; no planner/noop/expected-set fields in apply. |
| 2 | Audit noted `StateWrite.swift` was untracked before commit. | `git diff` alone covers all phase changes. | Untracked files are omitted from ordinary diff until staged. | Inspected file directly, then staged exact path before commit. | Include `git status --short` and exact-path `git add`; do not rely only on tracked diff. |
| 3 | Red-test wrapper used `status` as a zsh variable. | Shell wrapper variable names are harmless. | `status` is read-only in zsh, interrupting the harness wrapper after valid compile failures. | Switched wrappers to `cmd_status`. | Avoid shell-reserved variable names in reusable gate wrappers. |
| 3 | Old readback fixture used `set_cabin_ac(power:on, delta:warmer)` with only temperature expected. | That fixture was purely a readback mismatch. | Applied-write provenance exposed an extra direct `ac.power` write, correctly making it a state-delta mismatch. | Changed readback-focused fixtures to temperature-only mutations. | Under provenance scoring, readback tests must not hide unexpected state writes. |
| 3 | Static grep matched negative assertions using `failureClasses.contains(.readback)`. | Negative contains assertions are acceptable after split. | Phase gate forbids the legacy assertion shape entirely. | Replaced runtime readback assertions with `readbackHardFailed` and equality against filtered readback failures. | Test readback/model split through the new fields, not legacy failure-class membership. |
| L3 | First forbidden-action scan collapsed touched files into one quoted string. | A shell string containing paths is safe to pass to `rg`. | `rg` treated the whole string as one path and reported an IO error; wrapper did not mark that as failure. | Reran with an argument-safe file list and recorded the invalid first scan. | Treat scan wrapper errors as invalid evidence; use arrays, `xargs`, or explicit path arguments. |
| GPT Pro P1 | External audit could not verify ignored `Reports/.../VERIFY.md` from branch source truth. | Local scratch receipts are enough for external reviewers. | `Reports/` is ignored, so branch-source-truth evidence was incomplete. | Added tracked evidence excerpt and updated closeout command evidence links. | Every external audit closeout needs tracked high-signal command evidence, not only ignored scratch logs. |
| GPT Pro P1 | External audit flagged thresholded `summary.status`. | A compatibility note is enough to prevent acceptance misuse. | Code still computed generic `pass`/`hard_fail` from `IrrelAcc >= 0.9`. | Changed `C6Summary.status` to `local_construction_report` and added regression coverage. | Make non-acceptance semantics mechanical in code, not just prose. |
| GPT Pro P1 | Post-commit `git diff --check HEAD~1..HEAD` failed on the copied GPT Pro Markdown report. | A report copied verbatim from the browser is commit-clean. | The Markdown used trailing spaces for hard line breaks, which violates repo whitespace gates. | Mechanically stripped trailing whitespace and amended the P1 absorption commit. | Run `git diff --check HEAD~1..HEAD` before pushing evidence-copy commits, not only before the first commit. |

## Scope Expansions

| Phase | Path | Reason | Invariant Protected | Tests Added/Changed | Residual Risk |
|---|---|---|---|---|---|
| none | none | All modified paths were in the plan's expected write set. | Route-only construction boundary. | n/a | none |

## Pre-Mortem Accuracy

| Phase | Predicted Failure | Happened? | Prevention Worked? | Follow-Up |
|---|---|---|---|---|
| 1A | Behavior class could become a C6-private taxonomy or infer from broad buckets. | Partly | Yes. Tests caught bucket/tag false-green risk. | Keep shared `VehicleToolBehaviorClass` and explicit resolver tests. |
| 1B | External layer and behavior class axes could collapse into one report. | No | Yes. Two-axis tests protected the shape. | Keep external-layer and behavior-class stats separate. |
| 1C | Selector shell could smuggle thresholds/base anchors. | No | Yes. Static scans and denominator tests stayed threshold-free. | Defer thresholds, base anchors, and candidate comparison. |
| 2 | Enum/dependency writes could stay invisible or become planner metadata. | Yes | Yes. Red tests failed before `appliedWrites`; implementation stayed descriptive. | Keep apply fail-closed and expected-set-free. |
| 3 | Dependency allowance could remain final-state-only and readback could remain model hard fail. | Yes | Yes. Focused tests exposed and then locked both boundaries. | Keep dependency proof dual-sourced: applied write provenance plus `stateCells.dependsOn`. |
| L3 | Local proof could be overstated as C6 acceptance or model quality. | No | Yes. Closeout and scans keep proof class limited. | External GPT Pro audit remains required before the work is called externally passed. |
| GPT Pro | P1 findings could remain prose-only. | Yes | Yes. P0 was empty; P1s were converted into tracked evidence and regression code. | Keep external-pass-with-absorbed-fixes contingent on command evidence after the fixes. |
