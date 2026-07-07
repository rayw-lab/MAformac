# RECEIPT-M1D

status: PARTIAL_LOCAL_SWIFT_KNOWN_NOISE
artifact_kind: authoritative_fix_receipt
proof_class: local
created_at: 2026-07-02 11:01:14 CST
task: M1 acceptance diff-gate fix for Gate8 allowlist codegen SSOT

## Repo Truth

- worktree: `/Users/wanglei/workspace/MAformac-m1g`
- branch: `fix/g8-allowlist-codegen-ssot`
- base: `main`
- HEAD: `1f0422f9b47410c54ce27e9dbe46b5c1ee7d5b9e`
- commit: `Fix family allowlist tool count codegen`
- PR: https://github.com/rayw-lab/MAformac/pull/15
- PR state: OPEN
- merge: not merged

## Scope

R7 codegen fix only.

Changed files:

- `scripts/gen_family_allowlist.py`
- `Makefile`

No training, no data generation, no UIUE fixture repair, no merge.

## Fix

- `scripts/gen_family_allowlist.py` now reads `generated/D_domain.tools.demo.json` and derives `meta.tool_count` from the catalog length.
- The emitted `tool_count_derivation` string matches the committed generated JSON value:
  `ToolContractCompiler.loadDDomainCatalog(repoRoot:).count over generated/D_domain.tools.demo.json; value-form expanded D-domain named tool catalog, not demo_intents reuse.`
- `Makefile regen` now runs tool-contract/allowlist in two convergence passes:
  `gen_tool_contract -> gen_family_allowlist -> gen_tool_contract -> gen_family_allowlist`.
  This prevents allowlist from reading a stale-by-one demo catalog and leaves both generated surfaces consistent.

## Impact

- GitNexus `context(build_manifest)`: direct caller is `scripts/gen_family_allowlist.py:main`.
- GitNexus `detect_changes(compare main)`: low risk, 2 files changed, affected processes 0.

## Validation

Logs:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-02-baseline-roadmap/M1D-verify-all-after-commit.log`
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-02-baseline-roadmap/M1D-swift-toolcontract.log`

Commands and results:

- `python3 scripts/gen_tool_contract.py --contract contracts/semantic-function-contract.jsonl --output-dir generated && python3 scripts/gen_family_allowlist.py --check`: PASS
  - `D-domain catalog: demo=562 tools / full=1538 tools`
  - `OK D_DOMAIN_TOOL_COUNT: 562 from generated/D_domain.tools.demo.json`
- `make verify-all`: PARTIAL
  - PASS through `verify-source`
  - PASS through `regen`
  - PASS through `verify-refs`
  - PASS through `verify-cross-section`
  - PASS through `verify-surface`
  - PASS through `verify-c6-shape`
  - PASS through `verify-default-scope`
  - PASS `diff`
  - PASS Python `test`
  - PASS `verify-contentview-wiring`
  - FAIL only at `swift-test`
- `swift test --filter ToolContractCompilerTests`: PASS
  - `Executed 22 tests, with 0 failures (0 unexpected)`

## Swift Test Count

`make verify-all` reached `swift-test` and then failed with the known local sibling UIUE fixture mismatch class:

- `Executed 482 tests, with 3 tests skipped and 5 failures (0 unexpected)`
- failure test: `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
- failure files:
  - `manifest.json`
  - `window_position_runtime_public_payload.v1.json`
  - `screen_brightness_runtime_public_payload.v1.json`
  - `ambient_brightness_runtime_public_payload.v1.json`
  - `window_position_noop_runtime_public_payload.v1.json`

This is the same known sibling UIUE fixture environment noise recorded in `RECEIPT-M1BG.md` / `RECEIPT-M1-acceptance.md`, not a codegen regression.

## Swift Failure Full Text

```text
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("fe48c69854ec796debdf57724c99bc2d0660149f134f6f249e1284c6208549e9") is not equal to ("c183b5f43a61438c1051bb40a79c5953ed343abe857dba8002c0eb7059e2a259") - manifest.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("ed6a5dae7a87e52a98181cf7429643afbc40ab85acf681b2923d3dcfc6fbe1e6") is not equal to ("6705d11f4a9a95bdba4ff40870fca36694efd276460a0461d574cca89abd4bad") - window_position_runtime_public_payload.v1.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("f358b9162fc86d6d1366e06e1d4c4307337f46e7d81d17a104ab0feaa5747e7a") is not equal to ("353b82b0296de88f50f7df99aeee96b522011eeae52f525c5b91307ff00ad4a2") - screen_brightness_runtime_public_payload.v1.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("717c187cb0bb97c3d802cc4e83d378405104cc464edd325b6478318ee9f1ea7f") is not equal to ("627831b05009ab264a2d948fe6be438bc0169ea291b38d540b14c2fdce867488") - ambient_brightness_runtime_public_payload.v1.json
/Users/wanglei/workspace/MAformac-m1g/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:336: error: -[MAformacCoreTests.RuntimePresentationPayloadFixtureConsumerTests testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable] : XCTAssertEqual failed: ("f64650e29d2fd3bd138f46379ff863b40cbcc4fc8a801a77540a90c79158791a") is not equal to ("ea30e51535fb552da30ca9ca522198b35f69babf804852c0ab40cafb59794112") - window_position_noop_runtime_public_payload.v1.json
Test Suite 'MAformacPackageTests.xctest' failed at 2026-07-02 10:59:49.063.
	 Executed 482 tests, with 3 tests skipped and 5 failures (0 unexpected) in 28.062 (28.092) seconds
Test Suite 'All tests' failed at 2026-07-02 10:59:49.063.
	 Executed 482 tests, with 3 tests skipped and 5 failures (0 unexpected) in 28.062 (28.092) seconds
make: *** [swift-test] Error 1
```

## Push / PR

- push command used proxy-stripped environment:
  `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git push -u origin fix/g8-allowlist-codegen-ssot`
- PR create command used proxy-stripped environment:
  `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy gh pr create --base main --head fix/g8-allowlist-codegen-ssot`
- PR URL: https://github.com/rayw-lab/MAformac/pull/15
- PR checks at receipt time: `verify` pending
  - https://github.com/rayw-lab/MAformac/actions/runs/28562256018/job/84682124471

## Residual Risk

- Local `make verify-all` is not full green because the local sibling UIUE fixture mismatch still fails `swift-test`.
- Codegen acceptance signal is clean: the original M1 acceptance `diff` failure is fixed, and `ToolContractCompilerTests` passes.
