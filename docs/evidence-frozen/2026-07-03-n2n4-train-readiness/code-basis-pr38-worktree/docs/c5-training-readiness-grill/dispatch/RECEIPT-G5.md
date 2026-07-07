# RECEIPT-G5 — gate5 multiaxis held-out splitter + tiny ablation harness

## Verdict

DONE（tooling-only）。已在 `/Users/wanglei/workspace/MAformac-g5` 实装 D-016 六轴 held-out overlap gate 和 F-044 tiny ablation dry-run harness。

R7 边界保持：未 run 训练、未生成数据、未真跑 ablation；`28/34` 与 `<5/34` 只作为 harness 常量和 mock metric 判定。

## M1 reconfirm

- worktree: `/Users/wanglei/workspace/MAformac-g5`
- branch/head: `c5gate/g5-multiaxis-heldout...origin/main`, `771f48ad1bbaf02740f71da2cf90ada02fc6f6c6`
- 初始目标文件锚点已核：
  - `Core/Bench/C5DataGate.swift:3` `C5DataGateCandidate`
  - `Core/Bench/C5DataGate.swift:345` `splitWhitelist`
  - `Core/Bench/C5DataGate.swift:358-361` 原 parent overlap 计算
  - `Core/Bench/C5DataGate.swift:381-382` parent failure
  - `Core/Bench/C5DataGate.swift:234-240` `hasHardFailure`
  - `Core/Bench/C5DataGate.swift:429-431` `status = "blocked"`
- GitNexus pre-edit context/impact:
  - `context(C5DataGateValidator)` 直接 caller：`Core/Training/C5LoRATraining.swift:C5TrainingDatasetBuilder.build#4`、`Tests/MAformacCoreTests/C5DataGateTests.swift:C5DataGateTests.makeReceipt#2`、`Tools/C5DataGateCLI/main.swift:C5DataGateCLI.run#1`
  - `impact(C5DataGateValidator, upstream)` risk=`HIGH`, impacted=`14`, affected processes=`Tools/C5DataGateCLI/main.swift` / `Tools/C5TrainingCLI/main.swift` / `Core/Training/C5LoRATraining.swift`

## Changes

- `Core/Bench/C5DataGate.swift`
  - `C5DataGateCandidate` 增加 optional/back-compatible 五轴字段：`device/tool_name/value_type/template_family/generator_source`，旧 JSON 不带字段可继续 decode；`tool_name` 可从 `tool_call` / `expected_tool_calls` fallback，`generator_source` 可从 `generator_model_id` fallback（`Core/Bench/C5DataGate.swift:10-14`, `Core/Bench/C5DataGate.swift:115-123`）。
  - 新增 table-driven `C5HeldOutOverlapAxis` 六轴：`parent_semantic_id/device/tool_name/value_type/template_family/generator_source`，集中 failure reason（`Core/Bench/C5DataGate.swift:243-286`）。
  - `C5DataGateReceipt` 增加 optional `held_out_axis_overlaps` / `train_held_out_axis_overlap_count`，并接入 `hasHardFailure`（`Core/Bench/C5DataGate.swift:187-240`）。
  - validator 对 train vs protected held-out split 做六轴 overlap，`dev_selection/quarantine` 延续原 parent 逻辑不作为 protected held-out；新五轴 overlap 直接追加 failure 且触发 `status="blocked"`（`Core/Bench/C5DataGate.swift:362-390`, `Core/Bench/C5DataGate.swift:429-451`, `Core/Bench/C5DataGate.swift:534-555`）。
- `Core/Training/C5LoRATraining.swift`
  - `C5TrainingSample.dataGateCandidate` 填入现有可得的 gate 轴：`toolName/valueType/templateFamily/generatorSource`，不新增 training sample schema（`Core/Training/C5LoRATraining.swift:370-388`）。
- `Core/Training/C5TinyAblationHarness.swift`
  - 新增 dry-run harness，只消费外部/mock metrics，常量 `baseline=28/34`、目标 `<5/34`、sample range `20...50`，不 import/call MLX 或训练 backend（`Core/Training/C5TinyAblationHarness.swift:33-64`）。
- Tests:
  - 六轴 overlap、parent 不撞但 device 撞、clean split、legacy receipt decode（`Tests/MAformacCoreTests/C5DataGateTests.swift:98-188`）。
  - tiny ablation dry-run pass/block 阈值（`Tests/MAformacCoreTests/C5TinyAblationHarnessTests.swift:4-38`）。

## Validation

- `swift build` PASS（warning only: existing unhandled files `UBIQUITOUS_LANGUAGE.md`, `MAformacIOSUITests/...`）。
- `swift test --filter C5DataGate` PASS：12 tests, 0 failures。
- `swift test --filter TinyAblation` PASS：3 tests, 0 failures。
- `git diff --check` PASS。
- `git diff --stat` tracked diff:
  - `Core/Bench/C5DataGate.swift` 149 lines
  - `Core/Training/C5LoRATraining.swift` 4 lines
  - `Tests/MAformacCoreTests/C5DataGateTests.swift` 75 lines
  - tracked total: 3 files, 227 insertions, 1 deletion
- untracked new files:
  - `Core/Training/C5TinyAblationHarness.swift`
  - `Tests/MAformacCoreTests/C5TinyAblationHarnessTests.swift`
- GitNexus `detect_changes(scope=compare, base_ref=main, worktree=/Users/wanglei/workspace/MAformac-g5)`:
  - risk=`medium`
  - changed_count=`61`, affected_count=`4`, changed_files=`3`
  - affected processes: `Main → C5DataGateFailure`, `Main → NormalizedCandidate`, `Main → NormalizedSplit`, `Main → ContainsProhibitedText`
  - note: GitNexus diff did not count untracked new harness/test files; they were compiled by `swift build` and tested by `swift test --filter TinyAblation`.

## Residual risks

- `device` cannot be faithfully derived from current `C5TrainingSample` without widening sample schema; current training conversion maps only tool/value/template/generator axes and leaves `device` for explicit candidate JSON/future sample schema.
- `value_type` on training conversion uses `valueStrategy.rawValue`, because raw `EXP/PERCENT/FREE` is not stored in `C5TrainingSample`; explicit candidate JSON can still provide real `value_type`.
- No real ablation metric was produced by design; R7 keeps real 20-50 sample overfit ablation BLOCKED as training.
