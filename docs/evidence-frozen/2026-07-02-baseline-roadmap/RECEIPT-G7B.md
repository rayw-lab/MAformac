# RECEIPT-G7B — C6 subset schema receipt construction

captured_at: 2026-07-02 11:47 Asia/Shanghai
worktree: `/Users/wanglei/workspace/MAformac-g7b`
branch: `c5gate/g7impl-b-c6schema-receipt`
base: `80ea379c`
commit: `102987f6`
pr: https://github.com/rayw-lab/MAformac/pull/17

## Verdict

`PARTIAL / adapter_receipt_proof_plus_runner_extension_behavior_proof`

原因：本轮遵守 add-only + 只新增 `Core/Bench/`、`Tests/` 文件，没有侵入修改既有 `C6GateResult` / `C6Summary` 原生 schema。因此不得声称 `C6 schema fully integrated`。已证明的是：

- subset 字段可 legacy-compatible decode；
- `C6BenchRunner` add-only extension 会消费 subset case/run，并输出 `subset_failure_class`；
- subset failure 会驱动 subset summary status；
- 六轴 digest receipt 任一 mismatch fail-closed 到 `BLOCKED`。

## Changed Files

- `Core/Bench/C6SubsetContext.swift`
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift`

## Consumption Points

- `Core/Bench/C6SubsetContext.swift:164` — `C6BenchRunner.evaluate(subsetCase:output:mountedToolIDs:allowedToolIDs:)` 调用既有 `evaluate(case:output:)`，再用 mounted/allowed sets 派生 `subset_failure_class`。
- `Core/Bench/C6SubsetContext.swift:187` — `C6BenchRunner.summarize(subsetCases:subsetRuns:validation:)` 调用既有 `summarize(cases:runs:validation:)`，再由 subset failure counts 派生 `construction_subset_blocked`。
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:167` — 行为测试证明带 subset 字段的 case 进入 runner 后输出 `missing_expected_in_mounted`。
- `Tests/MAformacCoreTests/C6SubsetContextTests.swift:192` — 行为测试证明 subset failure 驱动 summary status。

## Validation

- `swift test --filter C6SubsetContextTests` → PASS, 9 tests.
- `swift test --filter C6` → PASS, 89 tests.
- `git diff --check` / `git diff --cached --check` → PASS.
- `make verify-all` → PARTIAL: verify-source / regen / refs / cross-section / surface / gold / case-shape / Python smoke / ContentView wiring passed, then final embedded `swift test` failed only on existing sibling UIUE fixture hash parity test.

Known sibling noise:

- `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
- mismatched files: `manifest.json`, `window_position_runtime_public_payload.v1.json`, `screen_brightness_runtime_public_payload.v1.json`, `ambient_brightness_runtime_public_payload.v1.json`, `window_position_noop_runtime_public_payload.v1.json`.

## Merge Discipline

- RAT PR must merge first.
- PR #17 is open for review only.
- Do not merge PR #17 before RAT lands and PR #17 is rechecked.

## Non-Claims

- No C6 acceptance.
- No true model eval.
- No training or data generation.
- No V/S/U-PASS.
- No native existing `C6GateResult` / `C6Summary` schema mutation.
