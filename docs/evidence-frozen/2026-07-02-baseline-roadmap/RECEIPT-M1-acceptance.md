# RECEIPT-M1-acceptance

status: FAIL
artifact_kind: authoritative_acceptance_receipt
proof_class: local
updated_at: 2026-07-02 11:07:26 CST
task: M1 post-merge re-acceptance on `main` after PR #15 merge

## Repo Truth

- worktree: `/Users/wanglei/workspace/MAformac-m1g`
- checkout command: `git checkout main`
- pull command: `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git pull origin main`
- HEAD: `80ea379c3dea93b8b5419c192563872764b1bba1`
- branch: `main...origin/main`
- final worktree status: clean

## Command

```bash
make verify-all
```

Full log:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-02-baseline-roadmap/M1ACC-rerun-verify-all.log`

## Verdict

`make verify-all` reached `swift-test` and failed there with the known local sibling UIUE fixture mismatch.

The previous M1 acceptance blocker is fixed:

- `regen` emits `OK D_DOMAIN_TOOL_COUNT: 562 from generated/D_domain.tools.demo.json`.
- `diff` passes.
- Python test gates pass.
- `verify-contentview-wiring` passes.

The command still exits non-zero, so this receipt status is `FAIL`, not green.

## verify-all Gate Results

- `.venv/.deps.stamp`: present / no dependency install rerun observed.
- `verify-source` / `scripts/freeze_snapshot.py --check`: PASS
  - `snapshot_id=c1-2026-06-19-9b7e4b82`
  - `source_rows=3990`
- `regen` / `scripts/gen_c1.py`: PASS
  - `contract_rows=3990`
  - `quarantined_rows=0`
  - `canonical_semantics=3917`
  - `followup_transition_rows=3123`
- `regen` / `scripts/gen_tool_contract.py`: PASS
  - `D-domain catalog: demo=562 tools / full=1538 tools`
- `regen` / `scripts/gen_family_allowlist.py --emit --output-dir generated`: PASS
  - `OK D_DOMAIN_TOOL_COUNT: 562 from generated/D_domain.tools.demo.json`
  - `TOTAL: device 191/191 intent 562/562 行 2159/2159`
  - `OUT_OF_SCOPE: device 480/480 intent 976/976 行 1831/1831`
- `verify-refs`: PASS
  - `schema=ok`, `refs=ok`, `ledger=ok`, `range_conflicts=ok`, `coverage=ok`
  - `state_cells=ok`, `risk_policy=ok`, `demo_scenarios=ok`
- `verify-cross-section`: PASS
  - `consistent: true`
  - `drifts: []`
  - `caliber_violations: []`
- `verify-surface`: PASS
  - `consistent: true`
  - `missing_in_generated: []`
- `verify_gold`: PASS
  - `gold_apply_100=true`
  - `total_cases=57`
  - `violation_count=0`
- `verify-c6-shape`: PASS
  - `rows=57`
  - `behavior_class_counts={"already_state_noop":1,"clarify_missing_slot":9,"refusal_no_available_tool":8,"refusal_safety_or_policy":5,"tool_call":34}`
- `verify-default-scope`: PASS
  - `default-scope-ssot: pass`
  - `c5-c2-scope-parity: pass`
  - `scope-origin-single-source: pass`
- `diff`: PASS
- `test`: PASS
  - `test_quarantine=ok`
  - `test_fc_flags=ok`
  - `test_tool_name_sanitize=ok`
  - `test_check_c6_case_shape=ok`
  - `test_c6_bench_cli=ok`
- `verify-contentview-wiring`: PASS
  - `ContentView 真调用 familyDisplays(from: + VehicleCardsGrid 真消费 + Grid 固定列`
- `swift-test`: FAIL

## Swift Test Count

- `swift test`: FAIL
- `Executed 482 tests, with 3 tests skipped and 5 failures (0 unexpected)`
- All 5 failures are in `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`.

## Known Local Sibling UIUE Fixture Noise

Failure files:

- `manifest.json`
- `window_position_runtime_public_payload.v1.json`
- `screen_brightness_runtime_public_payload.v1.json`
- `ambient_brightness_runtime_public_payload.v1.json`
- `window_position_noop_runtime_public_payload.v1.json`

This is the same local sibling UIUE fixture mismatch class recorded in the earlier M1 acceptance/M1D receipts. It is single-listed here and not evidence of the Gate8 allowlist codegen regression returning.

## Swift Failure Full Text

```text
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("fe48c69854ec796debdf57724c99bc2d0660149f134f6f249e1284c6208549e9") is not equal to ("c183b5f43a61438c1051bb40a79c5953ed343abe857dba8002c0eb7059e2a259") - manifest.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("ed6a5dae7a87e52a98181cf7429643afbc40ab85acf681b2923d3dcfc6fbe1e6") is not equal to ("6705d11f4a9a95bdba4ff40870fca36694efd276460a0461d574cca89abd4bad") - window_position_runtime_public_payload.v1.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("f358b9162fc86d6d1366e06e1d4c4307337f46e7d81d17a104ab0feaa5747e7a") is not equal to ("353b82b0296de88f50f7df99aeee96b522011eeae52f525c5b91307ff00ad4a2") - screen_brightness_runtime_public_payload.v1.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("717c187cb0bb97c3d802cc4e83d378405104cc464edd325b6478318ee9f1ea7f") is not equal to ("627831b05009ab264a2d948fe6be438bc0169ea291b38d540b14c2fdce867488") - ambient_brightness_runtime_public_payload.v1.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("f64650e29d2fd3bd138f46379ff863b40cbcc4fc8a801a77540a90c79158791a") is not equal to ("ea30e51535fb552da30ca9ca522198b35f69babf804852c0ab40cafb59794112") - window_position_noop_runtime_public_payload.v1.json
Test Case '-[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable]' failed (0.025 seconds).
Test Suite 'MAformacPackageTests.xctest' failed at 2026-07-02 11:07:12.635.
	 Executed 482 tests, with 3 tests skipped and 5 failures (0 unexpected) in 27.416 (27.445) seconds
Test Suite 'All tests' failed at 2026-07-02 11:07:12.635.
	 Executed 482 tests, with 3 tests skipped and 5 failures (0 unexpected) in 27.416 (27.446) seconds
make: *** [swift-test] Error 1
```

## Residual Risk

- Local full acceptance remains red because `make verify-all` exits non-zero at `swift-test`.
- The remaining failure is isolated to local sibling UIUE fixture hashes; codegen/diff regression is fixed on `main@80ea379c`.
