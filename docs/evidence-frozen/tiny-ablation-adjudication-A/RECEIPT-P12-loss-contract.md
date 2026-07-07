# RECEIPT-P12-loss-contract

## Conclusion

Status: PARTIAL.

P12 scope is implemented and locally validated: A+ loss contract is explicit, augmentation namespace is separated, coverage gate is fail-closed, and mirror gate behaves as required: old v5 data FAILS the new gate; new v6 build PASSES the new gate.

Not upgraded to DONE because repo-wide `swift test` is not green in this local checkout: one UIUE sibling fixture parity test reads `/Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload` and fails on 5 hash mismatches unrelated to the P12 touched paths. `make verify` passes.

Proof class: local / unit / integration preflight. No training, no model-quality claim, no mobile/live claim.

## Changed Files

Worktree: `/Users/wanglei/workspace/MAformac-p12-loss-contract`

| Path | Change |
|---|---|
| `Core/Training/C5LoRATraining.swift` | Added `C5LossObjectiveProfile`, `C5AugmentationProfile`, natural B-axis row ingestion, full assistant-non-think supervision masks, receipt coverage digest, fail-closed coverage evaluation. |
| `Tools/C5TrainingCLI/main.swift` | Added `--natural-tool-call-rows` ingestion and receipt rendering for supervision coverage. |
| `Tools/C5TrainingCLI/c5_mlx_train_loop.py` | Added `--preflight-loss-mask-only`, char-level supervision coverage preflight, parser-critical coverage checks, namespace checks, and fail-closed loss-mask summary. |
| `Tests/MAformacCoreTests/C5LoRATrainingTests.swift` | Added regression tests for full assistant tool-call payload, prompt/user ignore, no-tool row objective, augmentation namespace separation, coverage fail-closed, and natural tool-call rows. |

`git diff --stat`: 4 files changed, 647 insertions, 45 deletions.

## Evidence Table

| Gate | Command / Artifact | Result | Evidence |
|---|---|---|---|
| P12 unit regression | `swift test --filter C5LoRATrainingTests` | PASS | 58 tests, 0 failures. |
| Repo verify | `make verify` | PASS | Exit 0; completed snapshot, generators, refs, gold, subset manifest, shape checks, and contentview wiring. |
| Old v5 mirror | `python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --model .../build/qwen3-1_7b-training-tokenizer-patched --data .../build/mlx-data --config .../build/mlx-lora-config.yaml --require-maformac-loss-mask --preflight-loss-mask-only --train --allow-mlx-lm-version-mismatch` | EXPECTED FAIL | Exit 66; stderr begins `LOSS_MASK_PREFLIGHT_FAILED`; errors include `parser_critical_untrained:"arguments"`, `parser_critical_untrained:<tool_call>`, and `assistant_non_think_trainable_ratio_below_0.90`. |
| New v6 build | `swift run C5TrainingCLI prepare --repo-root /Users/wanglei/workspace/MAformac-p12-loss-contract --output-dir .../P12-v6-build --target-positive 44 --dev-selection 0 --theta-alpha-positive-only --allow-regenerated-offset-artifact` | P12 COVERAGE PASS; overall receipt BLOCKED by non-P12 gates | `P12-v6-build/c5-training-receipt.json` has `supervision_coverage_digest.status=pass`, `parser_critical_status=pass`, `ratio_status=pass`, `trainable_non_think_ratio=1`, leakage counts 0. Overall receipt remains `status=blocked` because generator/training-loop source/candidate quality gates are outside P12. |
| New v6 mirror | `python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --model .../P12-v6-build/qwen3-1_7b-training-tokenizer-patched --data .../P12-v6-build/mlx-data --config .../P12-v6-build/mlx-lora-config.yaml --require-maformac-loss-mask --preflight-loss-mask-only --train --allow-mlx-lm-version-mismatch` | PASS | Exit 0; JSON summary: `records=44`, `trainable_records=44`, `trainable_tokens=764`, `length_violations=[]`, `parser_critical_status=pass`, `ratio_status=pass`, `min_trainable_non_think_ratio=1.0`. |
| Repo-wide Swift tests | `swift test` | FAIL, unrelated local sibling fixture parity | 523 tests executed, 3 skipped, 5 failures in `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`; mismatches are `manifest.json`, `window_position_runtime_public_payload.v1.json`, `screen_brightness_runtime_public_payload.v1.json`, `ambient_brightness_runtime_public_payload.v1.json`, `window_position_noop_runtime_public_payload.v1.json`. |
| GitNexus scope | `detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-p12-loss-contract)` | CRITICAL blast radius flagged | 4 changed files, 125 changed symbols, 17 affected execution flows, risk `critical`; affected surface is C5 dataset builder / CLI / MLX preflight path. No high-confidence runtime failure found, but blast radius remains material. |

## Contract Checks

| Requirement | Status | Evidence |
|---|---|---|
| `C5LossObjectiveProfile` enum includes `assistant_full_except_think`, `no_tool_full`, `diagnostic_span_only` | PASS | Implemented in `Core/Training/C5LoRATraining.swift`; emitted into MLX records as `loss_objective_profile`. |
| `functionName` / `argumentName` / `argumentValue` are augmentation only | PASS | Implemented as `C5AugmentationProfile` with JSON keys `function_name`, `argument_name`, `argument_value`; Python preflight rejects mixed namespace misuse. |
| Tool-call train rows cover full assistant non-think payload | PASS | New tests assert `<tool_call>`, `"name"`, `"arguments"`, and argument values are inside trainable span; new mirror ratio is 1.0. |
| `<think>` remains ignored | PASS | Test `testThinkSpanIsAlwaysIgnoredByLossMaskEvenWhenToolCallSpanTrains` passes; coverage digest think leakage count is 0. |
| Prompt/user/system remain ignored | PASS | Test `testPromptAndUserRemainIgnored` passes; coverage digest leakage counts are 0. |
| No-tool rows use `no_tool_full` and only train `NO_TOOL` | PASS | Test `testNoToolRowsFullNoToolOnly` passes. |
| Coverage double gate fail-closed | PASS | Swift digest and Python preflight both enforce parser-critical fragments plus ratio threshold >= 0.90. |
| Mirror gate: old v5 must FAIL | PASS | Old v5 preflight exit 66 with `LOSS_MASK_PREFLIGHT_FAILED`. |
| Mirror gate: new v6 must PASS | PASS | New v6 preflight exit 0 with parser/ratio pass and ratio 1.0. |
| B-axis natural Chinese row support | PASS | `--natural-tool-call-rows` added; test `testNaturalToolCallRowsOverrideUserAndTargetSurface` passes. |

## Residual Risk

- Repo-wide `swift test` is not green because of local sibling UIUE fixture drift outside P12 scope; this prevents a clean DONE receipt.
- `P12-v6-build/c5-training-receipt.json` overall status is still `blocked` due non-P12 gates: training loop source verification, cloud multi-source generator, diversity, cross-vendor semantic judge, and prior masking-complete gate. The P12 coverage digest itself is PASS.
- No LoRA training was run by design. Mirror validation used preflight-only tokenizer/loss-mask checks, not training convergence or model behavior.
- GitNexus index reported stale earlier and `detect_changes` reports critical blast radius. The mitigation is targeted C5 tests, mirror gates, and `make verify`; still requires reviewer attention before merge.

## Output Artifacts

- Receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/RECEIPT-P12-loss-contract.md`
- New v6 build artifacts: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v6-build`
- Old mirror stdout/stderr: `/tmp/p12-old-preflight.out`, `/tmp/p12-old-preflight.err`
- New mirror stdout/stderr: `/tmp/p12-new-preflight.out`, `/tmp/p12-new-preflight.err`

## Cross-review Repair 2026-07-03T01:04:54+0800

Conclusion: P12 cross-review P1-1, P1-2, and P2 are repaired in the P12 worktree. Proof class: local / unit / integration preflight. No training, live API, model-quality, endpoint, mobile, or true-device proof is claimed.

### Repair Evidence Table

| Finding | Fix | Validation | Result |
|---|---|---|---|
| P1-1 missing `loss_objective_profile` bypass | `--require-maformac-loss-mask` now fails missing objective as `loss_objective_profile_missing`; legacy compatibility requires explicit `--allow-legacy-loss-objective`; preflight summary emits `legacy_loss_objective_allowed` and `legacy_loss_objective_record_count`. | `testPythonTrainingLoopRejectsMissingLossObjectiveWhenMaskRequired`; old mirror command below. | PASS; missing-objective fixture exits 66 without legacy flag, exits 0 with explicit legacy flag and count=1. |
| P1-2 natural rows can replace canonical tool-call truth | Natural row target is parsed and must equal the canonical `C5TrainingToolCall` exactly: name, keys, values, and no extras. The row may only override user wording and provenance; assistant target and `expectedToolCalls` remain canonical. | `testNaturalToolCallRowsOverrideUserOnlyWhenCanonicalTargetMatches`; `testNaturalToolCallRowsRejectWrongCanonicalArgumentValue`; `testNaturalToolCallRowsRejectMissingCanonicalArgumentKey`; `testNaturalToolCallRowsRejectExtraCanonicalArgumentKey`. | PASS; wrong value, missing key, and extra key all fail closed with `natural_tool_call_target_mismatch`. |
| P2 fit-proof receipt frontmatter | `C5TrainingReceipt` and CLI markdown now include five machine-readable fields: `fit_proof_level`, `consumer`, `consumed_artifact`, `sufficiency_evidence`, `residual_gap`; current `fit_proof_level=mechanism_true`. | `testReceiptIncludesMachineReadableFitProofFrontmatter`; refreshed `P12-v6-build/c5-training-receipt.{json,md}`. | PASS; JSON/MD frontmatter present. |

### Repair Validation

| Gate | Command / Artifact | Result | Evidence |
|---|---|---|---|
| Python syntax | `python3 -m py_compile Tools/C5TrainingCLI/c5_mlx_train_loop.py` | PASS | Exit 0. |
| P12 focused unit/integration | `swift test --filter C5LoRATrainingTests` | PASS | 63 tests, 0 failures. |
| Old v5 mirror | `/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --model .../build/qwen3-1_7b-training-tokenizer-patched --data .../build/mlx-data --config .../build/mlx-lora-config.yaml --require-maformac-loss-mask --preflight-loss-mask-only --train --allow-mlx-lm-version-mismatch` | EXPECTED FAIL | Exit 66; `/tmp/p12-fix-old-preflight.err` contains `LOSS_MASK_PREFLIGHT_FAILED` and `train:1:loss_objective_profile_missing`. |
| Refresh new v6 receipt | `swift run C5TrainingCLI prepare --repo-root /Users/wanglei/workspace/MAformac-p12-loss-contract --output-dir .../P12-v6-build --target-positive 44 --dev-selection 0 --theta-alpha-positive-only --allow-regenerated-offset-artifact` | P12 artifacts written; overall receipt still BLOCKED by non-P12 gates | Exit 65 because receipt status remains `blocked`; stdout confirms `rows=44`; JSON has `fit_proof_level=mechanism_true`, `supervision_coverage_digest.status=pass`, ratio=1. |
| New v6 mirror | `/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --model .../P12-v6-build/qwen3-1_7b-training-tokenizer-patched --data .../P12-v6-build/mlx-data --config .../P12-v6-build/mlx-lora-config.yaml --require-maformac-loss-mask --preflight-loss-mask-only --train --allow-mlx-lm-version-mismatch` | PASS | Exit 0; `/tmp/p12-fix-new-preflight.out` summary has `records=44`, `trainable_records=44`, `trainable_tokens=764`, `parser_critical_status=pass`, `ratio_status=pass`, `min_trainable_non_think_ratio=1.0`, `legacy_loss_objective_record_count=0`. |
| Diff hygiene | `git diff --check` | PASS | Exit 0. |
| GitNexus scope | `detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-p12-loss-contract)` | CRITICAL blast radius flagged | 4 changed files, 140 changed symbols, 17 affected execution flows; affected surface remains C5 builder / CLI / training loop preflight. |

### Updated Artifacts

- Worktree: `/Users/wanglei/workspace/MAformac-p12-loss-contract`
- Refreshed v6 receipt: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v6-build/c5-training-receipt.json`
- Refreshed v6 markdown: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v6-build/c5-training-receipt.md`
- Old mirror stdout/stderr: `/tmp/p12-fix-old-preflight.out`, `/tmp/p12-fix-old-preflight.err`
- New mirror stdout/stderr: `/tmp/p12-fix-new-preflight.out`, `/tmp/p12-fix-new-preflight.err`
- Prepare stdout/stderr: `/tmp/p12-fix-prepare.out`, `/tmp/p12-fix-prepare.err`

### Repair Residual Risk

- `P12-v6-build/c5-training-receipt.json` remains `status=blocked` for non-P12 gates: generator diversity / cross-vendor judge / training-loop source verification / candidate quality / endpoint parity. P12 coverage and fit-proof fields are green, but the receipt is not a training authorization.
- No LoRA training was run; mirror gates are preflight-only consumption checks.
- GitNexus reports critical blast radius because the touched C5 builder and CLI sit on the training-data path; mitigation is the 63-test focused suite plus old/new mirror gates, not a repo-wide merge approval.

## GF-153 EOS Supervision Repair 2026-07-03T01:41+0800

Conclusion: GF-153 is implemented in the P12 worktree on branch `codex/p12-v61-eos-span-20260703`. The v6.1 data contract now declares `loss_mask.trainable_assistant_end_token="<|im_end|>"`; the MLX preflight requires that contract for trainable rows and labels the tokenizer-rendered assistant end token before loss. Proof class: local / unit / integration preflight. No LoRA training, C6 model-quality verdict, endpoint, mobile, or true-device proof is claimed.

### GF-153 Changed Files

| Path | Change |
|---|---|
| `Core/Training/C5LoRATraining.swift` | Added `trainable_assistant_end_token` to `C5MLXLossMask`, defaulting trainable rows to `<|im_end|>` and all-masked rows to nil; formal builder gate now fails trainable samples missing EOS supervision. |
| `Tools/C5TrainingCLI/c5_mlx_train_loop.py` | Added fail-closed EOS contract validation, tokenizer `<|im_end|>` id lookup, assistant-end token label assignment, and summary count `assistant_end_token_supervised_records`. |
| `Tests/MAformacCoreTests/C5LoRATrainingTests.swift` | Added schema assertions plus real-tokenizer positive/negative preflight regression for EOS supervision. |

### GF-153 Validation Evidence

| Gate | Command / Artifact | Result | Evidence |
|---|---|---|---|
| Python syntax | `/opt/homebrew/opt/python@3.13/bin/python3.13 -m py_compile Tools/C5TrainingCLI/c5_mlx_train_loop.py` | PASS | Exit 0. |
| Focused C5 tests | `swift test --filter C5LoRATrainingTests` | PASS | 64 tests, 0 failures. |
| Diff whitespace | `git diff --check` | PASS | Exit 0. |
| Prepare v6.1 build | `swift run C5TrainingCLI prepare --repo-root /Users/wanglei/workspace/MAformac-p12-loss-contract --output-dir .../P12-v61-build --target-positive 44 --dev-selection 0 --theta-alpha-positive-only --allow-regenerated-offset-artifact` | ARTIFACTS WRITTEN; overall receipt still BLOCKED by non-P12 gates | Exit 65; stdout: `wrote .../P12-v61-build/c5-training-receipt.json`, `wrote .../P12-v61-build/mlx-data/train.jsonl`, `status=blocked rows=44 train_eligible=44 ... dev_selection=0`; elapsed `real 2.20`. |
| New v6.1 mirror | `/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --model .../P12-v61-build/qwen3-1_7b-training-tokenizer-patched --data .../P12-v61-build/mlx-data --config .../P12-v61-build/mlx-lora-config.yaml --require-maformac-loss-mask --preflight-loss-mask-only --train --allow-mlx-lm-version-mismatch` | PASS | Exit 0; summary has `records=44`, `trainable_records=44`, `assistant_end_token_supervised_records=44`, `trainable_tokens=808`, `min_trainable_non_think_ratio=1.0`; elapsed `real 0.87`. |
| Token-level EOS check | One-off import of `build_maformac_token_labels` over first `P12-v61-build/mlx-data/train.jsonl` row | PASS | Output: `im_end_token_id=151645`, `assistant_end_token_index=754`, `labeled_im_end_count=1`, `assistant_end_token_supervised=true`. |
| Old v5 mirror | `/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/C5TrainingCLI/c5_mlx_train_loop.py --model .../build/qwen3-1_7b-training-tokenizer-patched --data .../build/mlx-data --config .../build/mlx-lora-config.yaml --require-maformac-loss-mask --preflight-loss-mask-only --train --allow-mlx-lm-version-mismatch` | EXPECTED FAIL | Exit 66; stderr contains `LOSS_MASK_PREFLIGHT_FAILED`; old data fails before EOS gate on `loss_objective_profile_missing`, so old v5 cannot pass the new contract. |
| GitNexus scope | `detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-p12-loss-contract)` | MEDIUM | 3 changed files, 21 changed symbols, 2 affected processes; index is stale to main, so tests/preflight above are controlling proof. |

### GF-153 Artifacts

- PR: https://github.com/rayw-lab/MAformac/pull/28
- v6.1 build: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P12-v61-build`
- Prepare stdout/stderr/status: `/tmp/p12-v61-prepare.out`, `/tmp/p12-v61-prepare.err`, `/tmp/p12-v61-prepare.status`
- New mirror stdout/stderr: `/tmp/p12-v61-new-preflight.out`, `/tmp/p12-v61-new-preflight.err`
- Old mirror stdout/stderr: `/tmp/p12-v61-old-preflight.out`, `/tmp/p12-v61-old-preflight.err`
- Token-level check: `/tmp/p12-v61-im-end-token-check.out`, `/tmp/p12-v61-im-end-token-check.err`

### GF-153 Residual Risk

- `P12-v61-build/c5-training-receipt.json` still reports `status=blocked` for non-P12 gates: training-loop source verification, cloud multi-source generator, diversity, cross-vendor semantic judge, and masking-complete augmentation. This repair only proves the EOS supervision contract and preflight consumption.
- Old v5 mirror fails on the older missing-objective gate before reaching the new EOS gate. That preserves the required fail-closed mirror semantics, but it is not a dedicated old-v5 EOS-field failure.
- No LoRA training was run by design; v6.1 retrain remains a separate commander/user authorization step.
- GitHub Actions for PR #27 and PR #28 currently fail before job startup with annotation: `The job was not started because recent account payments have failed or your spending limit needs to be increased`; this is an external billing/spending-limit blocker, not a source/test failure.
