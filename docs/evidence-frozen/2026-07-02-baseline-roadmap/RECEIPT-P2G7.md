# RECEIPT-P2G7 - Gate7 No-op Field Fix

REPORT P2G7: status=DONE proof=local/unit/ci pr=21 head=dd4d44d402fe66218b960cd5bccf38bda9d830a4

## Scope

- Branch: `fix/g7c-noop-fields`
- Worktree: `/Users/wanglei/workspace/MAformac-p2g7`
- Base: `1d82296146951d05bf5d2f9e260b132795a90db5`
- PR: https://github.com/rayw-lab/MAformac/pull/21
- Writable surface used:
  - `Core/Generation/Gate7GeneratorPipeline.swift`
  - `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift`

## Change

- `timeoutMilliseconds` is now load-bearing:
  - clamped to at least 1 ms in `Gate7ExecutionContract`;
  - each provider attempt is timed;
  - over-budget attempts are normalized to `.timeout` with `error_code=timeout_exceeded`;
  - `Gate7AttemptReceipt` records `timeout_policy_ms`, `elapsed_ms`, and `timed_out`.
- `rawPayload` is now consumed by attempt receipts:
  - receipts carry `raw_payload_sha256` and `raw_payload_bytes`;
  - raw payload body is not encoded into the receipt.

## Evidence

- `Core/Generation/Gate7GeneratorPipeline.swift:102-130` - execution timeout clamp and new receipt fields.
- `Core/Generation/Gate7GeneratorPipeline.swift:370-392` - elapsed-time timeout decision and raw payload digest/size recording.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:86-107` - timeout policy path test.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:110-135` - raw payload digest-only receipt test.

## Validation

- `swift test --filter Gate7GeneratorPipelineTests` -> PASS, 8 tests, 0 failures.
- `swift test` -> local RED: 503 tests executed, 3 skipped, 5 failures, all in `RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable` sibling UIUE fixture hash parity noise.
- `swift test --skip RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable` -> PASS, 502 tests, 3 skipped, 0 failures.
- `git diff --check` -> PASS.
- GitNexus:
  - `impact Gate7AttemptReceipt` -> symbol not found, index stale for G7C new symbols.
  - `detect_changes compare base=1d822961` -> changed_files=2, risk_level=low, changed_symbols=0 due same stale index limitation.
- GitHub PR #21 `verify` -> SUCCESS, started `2026-07-02T06:45:30Z`, completed `2026-07-02T06:47:55Z`.

## R7 Boundary

No true training, true data generation, eval run, or external LLM call was performed. This is code/test-only construction repair.

## Residual

- Local bare `swift test` remains red only because this checkout has the known sibling UIUE fixture corpus mismatch. CI `verify` is green.
- Hermes delta re-review is prepared for later coordination after the remaining two repair PRs exist; no Hermes rerun was launched in this task.
