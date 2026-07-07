# RECEIPT-G6 — C6 四层阈值化 construction receipt

## 结论

- DONE（construction-only local-pass）：`/Users/wanglei/workspace/MAformac-g6` 已完成 C6 四层阈值 fail-closed + `positive_action_invariant`，未运行模型、未训练、未生成训练数据、未做 C6 acceptance/base recalibration。
- Worktree：branch `c5gate/g6-c6-four-layer`，HEAD/base/origin-main 均为 `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`。

## M1 reconfirm baseline

- `C6Bucket` live at `Core/Bench/C6VehicleToolBench.swift:25`；`C6BenchCase.tags.bucket` live at `Core/Bench/C6VehicleToolBench.swift:125`。
- 行为类 SSOT live：`VehicleToolBehaviorClass` at `Core/Contracts/VehicleToolBehaviorClass.swift:3`；C6 resolver at `Core/Bench/C6VehicleToolBench.swift:263`。
- `C6ExternalLayerSelector` live at `Core/Bench/C6VehicleToolBench.swift:359`；summary status derivation live at `Core/Bench/C6VehicleToolBench.swift:1538`。
- GitNexus impact before edit：`C6Summary` HIGH（8 impacted / modules Bench, C6BenchCLI, C5TrainingCLI, tests）；`C6BenchRunner.summarize` HIGH（8 impacted）；`C6ExternalLayerStats` LOW；`C6Bucket` LOW。

## Done tasks

- M2：未 rename `C6Bucket`，保留其 legacy tag-bucket 角色，避免扩大 wire/data churn；四层 denominator 继续由 `VehicleToolBehaviorClass`/resolver 决定，证据见 `Core/Bench/C6VehicleToolBench.swift:263`、`:359`。
- M3：新增 table-driven 阈值表 `C6LayerThresholdTable`：golden 1.0、demo_fuzz 0.8、unsupported 1.0、safety 1.0；core-family-extinction guard 字段保留且默认 false，证据见 `Core/Bench/C6VehicleToolBench.swift:322`。
- M3：`C6ExternalLayerStats` 增加 pass rate、threshold、status、blocked reasons、no-tool false positive count，证据见 `Core/Bench/C6VehicleToolBench.swift:835`。
- M3：`C6Summary.status` 从 `"local_construction_report"` 改为 `four_layer_threshold_pass|four_layer_threshold_blocked`，由 layer + positive invariant 共同派生，证据见 `Core/Bench/C6VehicleToolBench.swift:1538`、`:1698`。
- M4：新增 `C6PositiveActionInvariant`，positive `tool_call` 独立计算 pass/hard failure/empty/no-op rate，禁止被 unsupported/no-call 成功稀释，证据见 `Core/Bench/C6VehicleToolBench.swift:857`、`:1625`。
- M5：`C6GateResult` 暴露 `model_hard_pass_basis` 与 `readback_excluded_from_model_hard_pass`，model hard pass 排除 renderer readback，证据见 `Core/Bench/C6VehicleToolBench.swift:724`、`:744`、`:1498`。
- M6：新增/更新 fixture 单测：四层 pass、demo_fuzz 80% fail-closed、positive-not-diluted、unsupported false-call、readback split，证据见 `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:587`、`:1181`、`:1241`、`:1274`、`:1315`。

## Validation

- `swift test --filter C6VehicleToolBenchTests`
  - Result: PASS, 72 tests, 0 failures.
  - Proof class: local/unit fixture.
- `swift build`
  - Result: PASS, build complete.
  - Note: SwiftPM prints existing unhandled-file warnings for `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`, `MAformacIOSUITests/U17GoldenPathUITests.swift`, `UBIQUITOUS_LANGUAGE.md`.
- `archive-check verify-gold`
  - Not run: `archive-check` not found in PATH.
- GitNexus `detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-g6)`
  - Result: changed files 2, risk high.
  - Affected processes reported: `Verify -> ToolContractIR`, `Verify -> Arguments`, `Verify -> Cell`, `Verify -> LogUnmapped`, `Verify -> ToolContractStateApplyResult`, `Verify -> SplitStateKey`, `Summarize -> C6DatasetValidation`.
  - Interpretation: high is accepted for this construction because modified symbol surface is the C6 bench monolith; git diff confirms actual changed files are only `Core/Bench/C6VehicleToolBench.swift` and `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`.

## R7 boundary

- Not run: model inference, training, generator, acceptance, candidate compare, base recalibration, voice/golden/UIUE/V/S/U proof.
- No production acceptance claimed. This receipt is construction-only `local/unit` evidence.

## Teardown / 消减记录

- `C6Bucket` rename was not performed: impact reported LOW for enum symbol, but it is still the type of `C6CaseTags.bucket` and used as legacy dataset tag; preserving it avoids silent data/wire churn while keeping behavior-class SSOT explicit.
- `demo_fuzz` core-family-extinction is table field default false because star-default is pending lock; no hard gate was invented beyond SPEC-locked thresholds.
- `archive-check verify-gold` unavailable locally; left as validation gap, not promoted to pass.
