# GPT Pro External Audit — MAformac Rebuild-C6 Scoring Foundation

## Status

**status: PASS_WITH_FIXES**

**P0 empty:** yes
**P1 empty:** no — 2 P1 findings
**P2 empty:** no — 3 P2 findings

## Audit basis

- Repository: `rayw-lab/MAformac`
- Branch/ref audited: `codex/rebuild-c6-doc-absorption-20260624`
- HEAD audited: `5a5021133b6453035660ffa45856ebe71078bb0b`
- Commit range audited: `6751be4942ebba079abb3e80c5e827c79fb43a77..5a5021133b6453035660ffa45856ebe71078bb0b`
- Scope audited only: construction-scope rebuild-C6 scoring foundation claims listed in the request.
- Explicitly not audited/passed: retrain-C5, C6 acceptance, D-domain base recalibration, Section 4 candidate comparison, model evaluation/model quality, golden-run, voice, endpoint readiness, UIUE merge, R-L17 candidate signoff, V-PASS/S-PASS/U-PASS.

## Access note

The public/unauthenticated branch URL returned GitHub 404, but authenticated GitHub repository access succeeded and branch file fetches succeeded. This audit is therefore not BLOCKED; it is based on authenticated GitHub branch content and the supplied HEAD commit.

## Executive verdict

The source implementation substantially satisfies the intended construction mechanics:

- shared `VehicleToolBehaviorClass` taxonomy exists outside C6-private code;
- `C6BenchCase` has backward-compatible `behavior_class` decode/encode;
- behavior-class and external-layer reporting are distinct axes;
- `StateWrite` and `StateWriteKind.direct|dependency` exist as shared descriptive apply facts;
- apply/execution produces direct and dependency write facts;
- C6 gate results consume `appliedWrites`, expose dependency write keys, and reject unexpected mutations;
- readback failure is split from model hard failure;
- forbidden work boundaries were mostly respected at the changed-file level.

However, the branch is **not ready as-is** for the next long-run because two P1 issues remain:

1. The closeout evidence is not complete as branch-source-truth: the durable closeout references an ignored/local `Reports/.../VERIFY.md` file that is not present in the branch, and there are no workflow runs/status checks on HEAD to substitute for it.
2. The code still exposes and computes an active legacy thresholded `summary.status` using `IrrelAccThreshold = 0.9`, which contradicts a literal “no active thresholds” construction claim unless downstream consumers are forced to treat it as legacy/non-acceptance.

After these P1s are fixed, the branch is suitable to enter the next long-run: Phase 4-6 identity and shape closeout.

## Findings

### P0

None.

### P1

#### P1-1 — Closeout evidence is not complete in branch source truth

**Anchors**

- `docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md:L47-L56`
- Referenced but absent: `Reports/rebuild-c6-scoring-foundation-20260624T173024Z/VERIFY.md`
- HEAD workflow/status evidence: none found through GitHub connector

**Evidence**

The closeout table records the expected verification commands and marks them exit 0, but each command points to `Reports/rebuild-c6-scoring-foundation-20260624T173024Z/VERIFY.md`. That `Reports/.../VERIFY.md` file is not available in the branch. The branch also has no GitHub workflow runs/status checks for the audited HEAD.

**Impact**

This does not prove the code is wrong. It does block treating the local-pass closeout as complete branch-source-truth evidence. An external reviewer cannot verify the claimed `local_unit`, `local_static_contract`, and `local_receipt_consistency` command outputs from the branch itself.

**Required fix**

Add a tracked durable evidence excerpt, or expand the closeout file with high-signal stdout/stderr snippets and exact command outputs. The fix should include at minimum:

- `swift test --filter C6VehicleToolBenchTests`
- `swift test --filter ToolContractCompilerTests`
- `make verify-surface`
- `openspec validate rebuild-c6-four-layer-bench --strict`
- `openspec validate --all --strict`
- `git diff --check`

#### P1-2 — Legacy thresholded `summary.status` remains active and can be mistaken for C6 acceptance

**Anchors**

- `Core/Bench/C6VehicleToolBench.swift:L1356-L1384`
- `Core/Bench/C6VehicleToolBench.swift:L1397-L1400`
- `docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md:L74-L78`

**Evidence**

`C6BenchRunner.summarize` still computes:

- `let threshold = 0.9`
- `status = hardFailures == 0 && irrelAcc >= threshold && validation.isValid && scenarioIDs.count >= 5 ? "pass" : "hard_fail"`
- `IrrelAccThreshold: threshold`

The closeout says thresholds, base anchors, candidate comparison, and model-quality acceptance remain unauthorized/deferred, and says legacy `IrrelAcc` is not an active four-layer acceptance gate. The code still exposes a pass/hard-fail status computed from a fixed threshold.

**Impact**

This is not evidence of D-domain base recalibration; the threshold appears legacy/unchanged. The risk is semantic: a downstream consumer can still treat `summary.status == "pass"` as a C6 acceptance or model-quality signal, which is explicitly out of scope.

**Required fix**

Choose one of:

- make the status explicitly non-acceptance/legacy in schema and docs;
- add a separate construction-only status and stop using thresholded `summary.status` for this route;
- add tests and closeout language that fail if the new denominator selector/layer reporting is interpreted as C6 acceptance.

The fix must make it mechanically hard to confuse this branch’s local construction proof with C6 acceptance.

### P2

#### P2-1 — Unresolved behavior-class rows are reported but not blocking

**Anchors**

- `Core/Bench/C6VehicleToolBench.swift:L1451-L1462`
- `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:L877-L920`
- `docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md:L74-L79`

**Evidence**

`denominatorReport` records `unresolved_behavior_class_case_ids`, and tests explicitly prove unresolved legacy rows can be summarized without blocking. The closeout also notes current C6 JSONL rows may still lack explicit `behavior_class`.

**Impact**

Acceptable for this construction slice, but it remains a fake-green path for Phase 4-6 if unresolved behavior-class rows are ignored by downstream reporting.

**Expected next-run handling**

Make explicit `behavior_class` migration and unresolved-class gating part of Phase 4-6 identity/shape closeout.

#### P2-2 — Dependency proof depends on producer honesty for `writeKind`

**Anchors**

- `Core/Contracts/StateWrite.swift:L3-L27`
- `Core/Contracts/ToolContractCompiler.swift:L595-L617`
- `Core/Bench/C6VehicleToolBench.swift:L910-L964`
- `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:L433-L483`
- `contracts/state-cells.yaml:L57-L72`

**Evidence**

The branch has the correct dual-source shape: dependency writes are produced by apply/execution and then checked against `stateCells.dependsOn`. The remaining risk is that `writeKind` is self-reported by the producer. The current tests cover the important AC temperature dependency path and reject a dependency key not declared by `dependsOn`, but broader producer-matrix coverage is still limited.

**Impact**

Not a blocker for this construction pass. It should be expanded before treating applied-write provenance as robust across all D-domain cells.

#### P2-3 — Readback split is correct, but consumers must read the new fields

**Anchors**

- `Core/Bench/C6VehicleToolBench.swift:L1329-L1347`
- `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:L486-L503`
- `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:L520-L550`

**Evidence**

Runtime `failureClasses` no longer includes `.readback` when readback fails; `modelHardFailed` and `readbackHardFailed` are separate. Tests assert that a machine-string readback mismatch does not set model hard failure and that readback failures are represented via `readbackHardFailed`.

**Impact**

This is correct for the requested split, but old consumers that only check `hardFailed` or `failureClasses` can fake-green readback. This must be documented and enforced in report consumers.

## Claim-by-claim audit

| Claim | Result | Notes |
|---|---:|---|
| 1. Shared `VehicleToolBehaviorClass` taxonomy and C6 case adapter | PASS | Shared enum exists in `Core/Contracts`; C6 case schema has optional `behavior_class`; tests cover explicit decode and prevent broad bucket inference. |
| 2. Two-axis C6 reporting | PASS | `VehicleToolBehaviorClassStats`, `C6ExternalLayerStats`, and `C6DenominatorReport` are distinct; summary carries behavior and layer stats separately. |
| 3. Denominator selector shell with no thresholds/base recalibration | PASS_WITH_FIXES | Denominator report exists and no base recalibration was found, but active legacy thresholded `summary.status` remains. See P1-2. |
| 4. Apply `StateWrite` facts and `write_kind` direct/dependency semantics | PASS | `StateWriteKind` has only `direct` and `dependency`; apply emits enum/numeric direct writes and dependency writes. |
| 5. C6 applied-write consumption and dependency `dependsOn` proof | PASS | C6 consumes `appliedWrites`, computes dependency keys, rejects unexpected mutations, and allows only dependency keys declared by expected state cells’ `dependsOn`. |
| 6. Readback split from model hard pass | PASS | Runtime model hard fail excludes readback; readback is separately reported via `readbackHardFailed`. |
| 7. Forbidden-work boundaries | PASS | Audited changed files are in construction/test/docs scope. Closeout and plan explicitly exclude retrain, C6 acceptance, base recalibration, model evaluation, golden-run, voice, endpoint, UIUE, R-L17 signoff, and V/S/U-pass claims. |
| 8. Closeout evidence completeness | FAIL as evidence, not as implementation | The closeout references a local/ignored report that is not present in branch source truth. See P1-1. |

## Teardown — top 3 fake-green paths still possible

1. **Legacy acceptance-looking status path**
   `summary.status == "pass"` can still be mistaken for C6 acceptance because it is thresholded and named generically, even though this branch is only local construction proof.

2. **Unresolved behavior-class denominator path**
   Rows without resolved/explicit behavior class are only reported, not blocked. Phase 4-6 can look green if it ignores `denominatorReport.unresolved_behavior_class_case_ids`.

3. **Self-attested dependency-write path**
   Dependency proof is shaped correctly, but the producer controls `writeKind`. If apply code mislabels a side effect as `.dependency` and the key appears in `dependsOn`, C6 will accept it unless broader producer tests catch it.

## Readiness for next long-run

**Ready as-is:** no.

**Ready after fixes:** yes, after the two P1 findings are fixed.

Phase 4-6 should start only after:

1. durable tracked verification evidence is available in the branch, and
2. legacy thresholded status is made mechanically non-acceptance or separated from the new denominator/layer shell.

Then Phase 4-6 can focus on identity and shape closeout: `contract_bundle_fingerprint`, explicit C6 D-domain case shape migration, behavior-class denominator closure, and final closeout evidence.
