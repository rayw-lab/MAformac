# RECEIPT-G7D - C5 Builder Manifest Load

Date: 2026-07-02
Worktree: `/Users/wanglei/workspace/MAformac-g7d`
Base: `2b006b8a314522be79bc4995bddacad35c48568a`
Branch: `c5gate/g7impl-d-c5-builder-manifest`
Commit: `9a62d36b`
PR: https://github.com/rayw-lab/MAformac/pull/20

## Verdict

LOCAL_PASS_WITH_SIBLING_NOISE.

G7D construction scope is implemented: C5 D-domain builder mounts target tool surface from `generated/subset-policy-manifest.json` single_group entries, records subset metadata on generated samples, and fails closed for manifest/target/policy/catalog mismatches.

No merge to `main` was performed.

## Scope Discipline

- Construction only: no real data generation, no training, no C6 acceptance.
- No changes to `scripts/` or `generated/`.
- Frozen parameters unchanged: cap `7200`, digest口径, `degraded_clarify`, and S-201 entry fields.

## Changed Files

- `Core/Training/C5LoRATraining.swift`
- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`

## Validation

- `swift test --filter C5LoRATrainingTests`
  - PASS: 52 tests, 0 failures.
- `make verify`
  - PASS.
  - Includes `HF_HUB_OFFLINE=1 python3.13 scripts/gen_subset_manifest.py --emit --verify-budget --budget-cap 7200 --tokenizer-mode qwen --output-dir generated`.
  - Subset output: `entries=18260`, modes `scene_macro=5`, `sg_pair=18145`, `single_group=110`, `degraded_pairs=1`.
  - `verify_refs.py`: `subset_grouping=ok`.
- `make verify-all`
  - FAIL only at sibling parity test.
  - Final suite summary: 495 tests, 3 skipped, 5 failures.
- `swift test --filter RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
  - FAIL: same sibling fixture parity noise, 5 hash mismatches:
    - `manifest.json`
    - `window_position_runtime_public_payload.v1.json`
    - `screen_brightness_runtime_public_payload.v1.json`
    - `ambient_brightness_runtime_public_payload.v1.json`
    - `window_position_noop_runtime_public_payload.v1.json`
- `swift test --skip RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
  - PASS: 494 tests, 3 skipped, 0 failures.
- GitNexus `detect_changes(scope=all, worktree=/Users/wanglei/workspace/MAformac-g7d)`
  - `changed_files=2`, `risk_level=medium`, `affected_count=1`.

## Residual Risk

The only red gate is sibling UIUE/main fixture parity outside G7D owned files and reproduced independently. This is the same sibling-noise class observed during G7AB main acceptance.
