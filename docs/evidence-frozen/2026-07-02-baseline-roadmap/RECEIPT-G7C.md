# RECEIPT-G7C — gate7 generator pipeline construction

captured_at: 2026-07-02 12:38 Asia/Shanghai
worktree: `/Users/wanglei/workspace/MAformac-g7c`
branch: `c5gate/g7impl-c-generator-pipeline`
base: `2b006b8a314522be79bc4995bddacad35c48568a`
commit: `eaaa9101c80a505dcaea98e51daa7e27b2e37bfe`
pr: https://github.com/rayw-lab/MAformac/pull/19
ci: https://github.com/rayw-lab/MAformac/actions/runs/28565668116/job/84692334891

## Verdict

`PARTIAL_LOCAL_PASS_WITH_KNOWN_SIBLING_FIXTURE_NOISE_AND_CI_GREEN`

原因：G7C scope 内实现、targeted tests、build、CI 均通过；本地 `make verify-all` 仅在 embedded full `swift test` 的既有 UIUE sibling fixture SHA parity 测试失败。该失败与本 PR 新增文件无关，且 `swift test --skip ...sibling...` 全量替代门通过。

## Changed Files

- `Core/Generation/Gate7GeneratorPipeline.swift`
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift`

文件面符合 SPEC：只新增 `Core/Generation/` + `Tests/` 新文件；未改 `scripts/`、`generated/`、`Core/Bench/`、`Package.swift`。

## Implemented Scope

- 多源 LLM 桩：`Gate7LLMProvider` protocol + `Gate7MockLLMProvider` stub；`Gate7BlockedLiveLLMProvider` 对非 stub 路径返回 `blocked_r7`，无真 API/云调用路径。
- vendor-enum G1 门：顶层 `Gate7Vendor` 枚举为 `anthropic|openai|volc_twofish`；`Gate7GeneratorPipeline.run` 对 `generator.vendor == judge.vendor` fail-closed。
- 执行契约：`Gate7ExecutionContract` + `Gate7AttemptReceipt` 记录 retry/timeout/parse-error/retry-exhausted。
- 真 manifest 接口：`Gate7SubsetManifest` 读取 `generated/subset-policy-manifest.json`；样本 metadata 写入 `subset_policy_digest`、`mounted_tool_count`、`token_count`、`group_id` 与 `C6SubsetContext`。
- deterministic label：`Gate7DeterministicLabeler` 由目标 D-domain tool name 生成 gold `C6ToolCall`，LLM 零参与。
- 四确定性门：diversity / dedupe / decontamination / redaction。
  - decontamination 通过 `C5DataGateValidator` 复用既有六轴 held-out split 检查。
- quota 骨架：intent baseline + bug pressure + demo/safety floor + sparse family floor；测试锁定 wiper sparse floor 12 不砍。
- precision 骨架：`min(50,max(20,10%候选))` 抽样计算器 + `precision < 0.8` 停族判定。

## Evidence Anchors

- `Core/Generation/Gate7GeneratorPipeline.swift:3` — vendor enum raw values.
- `Core/Generation/Gate7GeneratorPipeline.swift:81` — non-stub live provider returns `blocked_r7`.
- `Core/Generation/Gate7GeneratorPipeline.swift:291` — pipeline G1 same-vendor fail-closed + live-provider R7 block.
- `Core/Generation/Gate7GeneratorPipeline.swift:352` — structured execution attempts for retry/timeout/parse-error.
- `Core/Generation/Gate7GeneratorPipeline.swift:380` — deterministic label/sample metadata assembly from manifest + C6 subset context.
- `Core/Generation/Gate7GeneratorPipeline.swift:427` — diversity gate.
- `Core/Generation/Gate7GeneratorPipeline.swift:470` — dedupe gate.
- `Core/Generation/Gate7GeneratorPipeline.swift:488` — redaction gate.
- `Core/Generation/Gate7GeneratorPipeline.swift:503` — decontamination gate reuses C5DataGateValidator.
- `Core/Generation/Gate7GeneratorPipeline.swift:611` — quota calculator.
- `Core/Generation/Gate7GeneratorPipeline.swift:631` — precision gate.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:5` — same-vendor G1 failure test.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:20` — live provider blocked_r7 test.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:35` — real manifest + subset metadata test.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:64` — parse-error retry receipt test.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:85` — four deterministic gates block test.
- `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:136` — quota + precision skeleton test.

## Validation

- `swift test --filter Gate7GeneratorPipelineTests` → PASS, 6 tests, 0 failures.
- `swift build` → PASS.
- `make verify-all` → PARTIAL:
  - PASS before embedded Swift test: source snapshot, codegen/regen, subset manifest regen, refs, cross-section, surface, gold, C6 case shape, default-scope, C5/C2 parity, scope-origin, git diff over generated/contracts/scripts/Makefile, Python smoke tests, ContentView wiring.
  - FAIL only at embedded `swift test`: `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`, 5 sibling fixture SHA mismatches.
- `swift test --filter RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable` → FAIL only on known sibling files:
  - `manifest.json`
  - `window_position_runtime_public_payload.v1.json`
  - `screen_brightness_runtime_public_payload.v1.json`
  - `ambient_brightness_runtime_public_payload.v1.json`
  - `window_position_noop_runtime_public_payload.v1.json`
- `swift test --skip RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable` → PASS, 496 tests, 3 skipped, 0 failures.
- `git diff --cached --check` → PASS before commit.
- R7 scan over changed files → no `URLSession`, `http(s)`, API key, secret, checkpoint, weight artifact, V/S/U-PASS, or true model path. Only `sourceAuthorization` fixture labels matched.
- `mcp__gitnexus.detect_changes(scope=staged, worktree=/Users/wanglei/workspace/MAformac-g7c)` → LOW, 2 changed files, 0 indexed symbols, 0 affected processes.
- PR #19 GitHub `verify` → SUCCESS.

## Non-Claims

- No true LLM/API/cloud call.
- No real generation.
- No training.
- No evaluation artifact.
- No C6 acceptance.
- No candidate comparison.
- No V/S/U-PASS.
- No runtime app launch.

REPORT G7C status=PARTIAL_LOCAL_PASS_CI_GREEN pr=https://github.com/rayw-lab/MAformac/pull/19 commit=eaaa9101 validation="new suite PASS 6/0; swift build PASS; make verify-all PARTIAL only sibling fixture SHA parity; swift skip sibling PASS 496/0; PR verify CI SUCCESS"

