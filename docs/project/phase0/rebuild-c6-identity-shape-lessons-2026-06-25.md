# Rebuild-C6 Identity Shape Lessons - 2026-06-25

## Verdict

status: lessons_captured
source: Reports/rebuild-c6-identity-shape-20260624T234832Z/VERIFY.md
base_sha: ebc7933ed96123818aa781c2bb317baf769cd32e
local_head_after_phase5: 229e9b3

## Lessons

| Phase | Trigger | Bad Assumption | Repo Truth | Fix | Future Guard |
|---|---|---|---|---|---|
| L0 | Branch was ahead of upstream by two commits before implementation. | `ahead 2` automatically means code drift or blocked baseline. | The only `@{u}..HEAD` diff was the tracked execution plan carrying human authorization. | Recorded the deviation explicitly in scratch evidence and continued under the plan's authorization section. | Whenever a plan is locally amended before execution, diff `@{u}..HEAD` and verify it is plan-only before code edits. |
| Phase 4 | First audit flagged `contract_bundle_fingerprint` as an opaque string receipt. | Internal manifest helper is enough even if receipts only expose a hash. | Accepted landing required manifest-visible `schema_version / bundle_hash / component_digests`. | Replaced scalar receipt field with structured `C6ContractBundleFingerprintRecord` across run/summary/CLI/test paths. | For auditability changes, verify not just internal helper semantics but also what receipts and Markdown summaries actually expose. |
| Post-C6 architecture absorption | Later audit flagged that component `version` existed but was not part of `bundle_hash`. | Content digest alone is always enough identity. | A versioned manifest should make version identity explicit and receipt-visible. | Added `component_versions` to the receipt and included versions in the canonical `bundle_hash` input. | If a receipt field is semantically load-bearing, test both hash sensitivity and visible summary output. |
| Phase 4 | Second audit found `receipt(manifest:)` could bypass missing-component validation. | Protecting one constructor path protects sibling public entry points. | Public manifest/receipt/fingerprint overloads can drift unless they all share one validator. | Centralized fail-closed validation through `validated(manifest:)` and added bypass regression coverage. | Any new fail-closed rule must be checked against every public overload, not only the happy-path builder. |
| Phase 4 | Every `swift test` run emitted `UBIQUITOUS_LANGUAGE.md` package warning. | A new warning during this phase must come from the fingerprint changes. | The warning is pre-existing package hygiene outside the Phase 4 write set. | Treated it as non-blocking noise and kept the phase gates scoped to the intended files and tests. | Separate pre-existing package warnings from phase regressions unless the diff actually touches the warned path. |
| Phase 5 | The first green JSONL migration still failed audit on source stability. | Migrating the tracked artifact is enough if the checker passes. | Generator/source paths can recreate old shape immediately unless they are migrated too. | Pushed explicit `behavior_class` back into generator inputs, decode, and validation paths. | Any generated artifact migration must audit both the artifact and the source that can regenerate it. |
| Phase 5 | `verify-c6-shape` initially only protected `verify-ci`. | CI-only wiring is enough for a local construction lane. | Local full gates must also mechanically execute the new checker. | Wired `verify-c6-shape` into `make verify`. | If a checker is meant to prevent local fake-green, it must be in the local gate, not only CI. |
| Phase 5 | Final audit argued `clarify` should not appear in external candidate counts. | Any mismatch between diagnostic counts and runtime layers is automatically a blocker. | This plan explicitly requires `clarify` candidate counts as a diagnostic output, separate from runtime four-layer SSOT. | Kept the diagnostic counter and documented it as non-acceptance output. | Distinguish plan-mandated diagnostic reporting from runtime acceptance taxonomy before absorbing an audit suggestion. |
| GPT Pro absorption | External audit found no-call `behavior_class` did not force `expect_no_call=true`. | Explicit taxonomy fields are enough if tracked JSONL rows look correct. | A shape gate must reject forged or future rows, not only describe the current 57 rows. | Added bidirectional Python checks, Python negative tests, Swift validation, and encoding fail-closed behavior. | Any future taxonomy migration must test inverse constraints and programmatic emission paths, not just committed artifacts. |

## Scope Expansions

| Phase | Path | Reason | Invariant Protected | Tests Added/Changed | Residual Risk |
|---|---|---|---|---|---|
| 4 | `Tools/C6BenchCLI/main.swift` | `C6BenchRunner` gained a required structured contract bundle receipt and the CLI is the only production summarize call site. | Manifest-visible receipt must exist in branch-source truth, not only in tests. | Updated CLI summary rendering; exercised through Phase 4 tests and audit. | No standalone CLI integration test beyond existing summary/test coverage. |
| 5 | `Core/Bench/C6VehicleToolBench.swift` | Audit showed JSONL-only migration was not source-stable; generator/decode/validate still emitted or accepted old shape. | Explicit `behavior_class` must be true in generator/source paths, not only in committed output. | Added generator/validation tests and reran full `C6VehicleToolBenchTests`. | Compatibility helpers remain in runtime code as follow-up tightening candidates. |

## UIUE Impact Result

- verdict: `not_blocking`
- proof: read-only scan of `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md`
- rationale: the scanned UIUE dispatch stayed inside isolated visual Phase 4a boundaries and did not claim shared `contracts/`, `generated/`, or C6 readback/state-surface ownership.

## Command Surprises

| Command | Surprise | Resolution |
|---|---|---|
| `swift test ...` | SwiftPM repeatedly warns about unhandled `UBIQUITOUS_LANGUAGE.md`. | Treated as pre-existing package noise because the warned path was outside the phase write sets. |
| `git diff --no-index --stat /dev/null <new file>` | Returns exit `1` on new-file stats even when used intentionally for evidence capture. | Recorded it as expected behavior rather than a gate failure. |
| `make -n verify \| rg ...` | Needed to prove gate wiring without paying the full raw-bound verify cost in Phase 5. | Used as a topology proof only; real gate proof stayed with targeted tests + shape script + `make verify-surface`. |

## Pre-Mortem Accuracy

| Phase | Predicted Failure | Happened? | Prevention Worked? | Follow-Up |
|---|---|---|---|---|
| 4 | New fingerprint could replace existing per-run identity fields. | Partly | Yes. Tests and audit caught the receipt shape before commit. | Keep run/summary identity preservation under regression coverage. |
| 4 | Bundle validation could be partial or order-sensitive. | Yes | Partly. Missing-component coverage started incomplete and needed a second audit loop. | Use one shared validator for all public manifest/receipt/fingerprint entry points. |
| 5 | Auto-migration could infer `already_state_noop` from broad no-call signals. | No | Yes. Source-free checker forced `pre_state == expected_state_delta` proof. | Keep no-op proof mechanical and independent of broad buckets. |
| 5 | `expect_no_call` could remain the de facto success denominator. | Partly | Yes. Checker and validation tests blocked that path. | Keep explicit `behavior_class` and source-free counts as the gate. |
| 6 | Closeout could overclaim local work as external pass. | pending | pending | Final external status must remain blocked until GPT Pro audit is actually received. |
