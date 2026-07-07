# RECEIPT-HERMES-ROUND Acceptance

- receipt_kind: authoritative_local_acceptance_receipt
- verdict: PARTIAL_SIBLING_NOISE
- tested_repo: `/Users/wanglei/workspace/MAformac-m1g`
- branch: `main`
- final_head: `aac84de90b9acabb7cb934237e010796f4ef9724`
- proof_class: local/unit
- non_claims: no V-PASS, no C6 acceptance, no live model, no true-device, no UIUE merge

## Scope

终验收 Hermes 修复轮全部合流后的 `main` 本地门：

1. `git pull origin main` with proxy env unset.
2. `make verify-all`.
3. Sibling/UIUE fixture noise 单列。

## Repo Truth

```text
$ pwd && git rev-parse --show-toplevel && git status --short --branch && git rev-parse HEAD && git rev-parse --abbrev-ref HEAD
/Users/wanglei/workspace/MAformac-m1g
/Users/wanglei/workspace/MAformac-m1g
## main...origin/main [behind 3]
1d82296146951d05bf5d2f9e260b132795a90db5
main
```

Authority note: `docs/CURRENT.md` in this checkout says M1 main acceptance had one known residual: sibling UIUE fixture environment noise, not an M1 regression.

## Pull

Command:

```text
$ env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git pull origin main
From https://github.com/rayw-lab/MAformac
 * branch              main       -> FETCH_HEAD
Updating 1d822961..aac84de9
Fast-forward
 Core/Bench/C6SubsetContext.swift                   | 121 +++++++++--
 Core/Generation/Gate7GeneratorPipeline.swift       |  32 ++-
 Core/Training/C5LoRATraining.swift                 |  14 +-
 Tests/MAformacCoreTests/C5LoRATrainingTests.swift  |  25 ++-
 Tests/MAformacCoreTests/C6SubsetContextTests.swift | 222 ++++++++++++++++++++-
 .../Gate7GeneratorPipelineTests.swift              |  65 ++++++
 6 files changed, 453 insertions(+), 26 deletions(-)
```

Post-pull truth:

```text
$ git status --short --branch && git rev-parse HEAD && git log -1 --oneline --decorate
## main...origin/main
aac84de90b9acabb7cb934237e010796f4ef9724
aac84de9 (HEAD -> main, origin/main, origin/HEAD) Fix C6 subset accounting dead fields
```

Pull verdict: PASS.

## make verify-all

Command:

```text
$ make verify-all
```

Result: FAIL, exit 2, at final `swift-test` target.

Passed before `swift test`:

```text
snapshot_id=c1-2026-06-19-9b7e4b82
source_rows=3990
contract_rows=3990
quarantined_rows=0
canonical_semantics=3917
followup_transition_rows=3123
D-domain catalog: demo=562 tools / full=1538 tools ... 自洽门 PASS
OK D_DOMAIN_TOOL_COUNT: 562 from generated/D_domain.tools.demo.json
OK subset manifest: entries=18260 modes={'scene_macro': 5, 'sg_pair': 18145, 'single_group': 110} degraded_pairs=1
schema=ok
refs=ok
ledger=ok
range_conflicts=ok
coverage=ok
state_cells=ok (c1_c2_closure=active) l1_closure=ok (L1_rows=76)
risk_policy=ok (levels=3)
demo_scenarios=ok (beats=9, status=C6-seed)
subset_grouping=ok (seat_groups=7 seat_sgs=36 whole_domains=5)
"consistent": true
{"gold_apply_100": true, "total_cases": 57, "violation_count": 0, "violations": []}
default-scope-ssot: pass
c5-c2-scope-parity: pass
scope-origin-single-source: pass
test_quarantine=ok
test_fc_flags=ok
test_tool_name_sanitize=ok
test_check_c6_case_shape=ok
test_c6_bench_cli=ok
OK test_real_catalog_single_group_coverage_and_digest_identity
OK test_fixture_digest_stable
OK test_budget_gate_fails_closed_for_over_cap_single_group
OK test_grouping_contract_seat_closure_fails_closed
✅ [contentview-wiring] ContentView 真调用 familyDisplays(from: + VehicleCardsGrid 真消费 + Grid 固定列（无 LazyVGrid）
```

SwiftPM warning observed:

```text
warning: 'maformac-m1g': found 3 file(s) which are unhandled; explicitly declare them as resources or exclude from the target
    /Users/wanglei/workspace/MAformac-m1g/MAformacIOSUITests/U17GoldenPathUITests.swift
    /Users/wanglei/workspace/MAformac-m1g/MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift
    /Users/wanglei/workspace/MAformac-m1g/UBIQUITOUS_LANGUAGE.md
```

`swift test` final result:

```text
Test Suite 'MAformacPackageTests.xctest' failed
Executed 513 tests, with 3 tests skipped and 5 failures (0 unexpected)
Test Suite 'All tests' failed
Executed 513 tests, with 3 tests skipped and 5 failures (0 unexpected)
make: *** [swift-test] Error 1
```

## Sibling Noise

All 5 failures are inside one sibling-corpus comparison test:

```text
RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable
Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336
```

The test explicitly compares this checkout's UIUE fixture corpus against a sibling main repo path:

```text
mainFixtureDirectory = repoRoot.deletingLastPathComponent().appendingPathComponent("MAformac/Tests/Fixtures/RuntimePresentationPayload")
```

Hash mismatches:

```text
manifest.json
  uiue/checkouted hash: fe48c69854ec796debdf57724c99bc2d0660149f134f6f249e1284c6208549e9
  sibling main hash:    c183b5f43a61438c1051bb40a79c5953ed343abe857dba8002c0eb7059e2a259

window_position_runtime_public_payload.v1.json
  uiue/checkouted hash: ed6a5dae7a87e52a98181cf7429643afbc40ab85acf681b2923d3dcfc6fbe1e6
  sibling main hash:    6705d11f4a9a95bdba4ff40870fca36694efd276460a0461d574cca89abd4bad

screen_brightness_runtime_public_payload.v1.json
  uiue/checkouted hash: f358b9162fc86d6d1366e06e1d4c4307337f46e7d81d17a104ab0feaa5747e7a
  sibling main hash:    353b82b0296de88f50f7df99aeee96b522011eeae52f525c5b91307ff00ad4a2

ambient_brightness_runtime_public_payload.v1.json
  uiue/checkouted hash: 717c187cb0bb97c3d802cc4e83d378405104cc464edd325b6478318ee9f1ea7f
  sibling main hash:    627831b05009ab264a2d948fe6be438bc0169ea291b38d540b14c2fdce867488

window_position_noop_runtime_public_payload.v1.json
  uiue/checkouted hash: f64650e29d2fd3bd138f46379ff863b40cbcc4fc8a801a77540a90c79158791a
  sibling main hash:    ea30e51535fb552da30ca9ca522198b35f69babf804852c0ab40cafb59794112
```

This matches the route-board residual: sibling UIUE fixture environment noise. It is still a hard `make verify-all` failure in this checkout and must not be reported as clean PASS.

## Hermes Round Target Evidence

The merged repair targets passed in the rerun evidence:

```text
C5LoRATrainingTests: Executed 53 tests, with 0 failures
C6SubsetContextTests: Executed 18 tests, with 0 failures
Gate7GeneratorPipelineTests: Executed 8 tests, with 0 failures
```

Important lines from the rerun log:

```text
C6SubsetContextTests testRunnerAllowsGlobalUnsupportedClassWhenNoToolReasonMatches passed
C6SubsetContextTests testRunnerSubsetSummaryBlocksOnUnsupportedClassMismatch passed
Gate7GeneratorPipelineTests testExecutionContractRecordsTimeoutPolicyOnAttemptReceipt passed
Gate7GeneratorPipelineTests testAttemptReceiptCarriesRawPayloadDigestWithoutRawBody passed
C5LoRATrainingTests testDDomainSubsetManifestWrongPolicyProbe passed
C5LoRATrainingTests testPythonTrainingLoopRejectsLossMaskRowsWhenFlagMissing passed
```

## Conclusion

`git pull origin main`: PASS.

`make verify-all`: PARTIAL_SIBLING_NOISE / exit 2.

Hermes repair round target suites are green locally, but full local acceptance is not clean because `make verify-all` fails on the known sibling fixture hash-drift test. This receipt is therefore not a V-PASS, not C6 acceptance, and not UIUE merge readiness.

DONE-HRA

REPORT HRA verdict=PARTIAL_SIBLING_NOISE head=aac84de9 pull=PASS verify_all=FAIL_exit2 main_verify_gates=PASS swift_test="513 tests, 3 skipped, 5 failures" sibling_noise="RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable 5 hash mismatches" hermes_targets="C5 53/0, C6Subset 18/0, G7 8/0" proof=local/unit

<!-- M2-SALVAGE-SOURCE: /Users/wanglei/workspace/MAformac-m1g/RECEIPT-HERMES-ROUND-acceptance.md; branch=main; head=aac84de9; original_sha256=4c35a9295e23667046e2271b3a6636be13d4cfff55091736e5d3958712f74fe8; archived_at=2026-07-03T10:56:07+0800 -->
