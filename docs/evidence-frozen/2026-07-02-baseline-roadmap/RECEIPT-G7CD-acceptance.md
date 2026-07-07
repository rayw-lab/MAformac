# RECEIPT-G7CD Acceptance

Date: 2026-07-02
Worktree: `/Users/wanglei/workspace/MAformac-m1g`
Branch: `main`
HEAD: `1d82296146951d05bf5d2f9e260b132795a90db5`
Receipt kind: authoritative local post-merge acceptance evidence

## Verdict

LOCAL_PASS_WITH_SIBLING_NOISE.

G7C/G7D merged main acceptance reached the expected main head and passed all local gates except the known sibling UIUE/main runtime fixture parity check.

## Pull

Command:

```bash
cd ~/workspace/MAformac-m1g
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git pull origin main
```

Result:

- Fast-forward: `2b006b8a..1d822961`
- Changed files from pull:
  - `Core/Generation/Gate7GeneratorPipeline.swift`
  - `Core/Training/C5LoRATraining.swift`
  - `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`
  - `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift`
- Final HEAD: `1d82296146951d05bf5d2f9e260b132795a90db5`

## Validation

Command:

```bash
make verify-all
```

Result:

- `make verify` portion passed.
- Subset manifest budget gate ran with cap `7200`:
  - `HF_HUB_OFFLINE=1 python3.13 scripts/gen_subset_manifest.py --emit --verify-budget --budget-cap 7200 --tokenizer-mode qwen --output-dir generated`
  - output: `entries=18260`, modes `scene_macro=5`, `sg_pair=18145`, `single_group=110`, `degraded_pairs=1`
- `verify_refs.py` passed, including `subset_grouping=ok`.
- Final `swift test` failed only on sibling parity:
  - full suite summary: 501 tests, 3 skipped, 5 failures.

Sibling parity isolation:

```bash
swift test --filter RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable
```

Result:

- FAIL: 1 test, 5 hash assertion failures.
- Files:
  - `manifest.json`
  - `window_position_runtime_public_payload.v1.json`
  - `screen_brightness_runtime_public_payload.v1.json`
  - `ambient_brightness_runtime_public_payload.v1.json`
  - `window_position_noop_runtime_public_payload.v1.json`

Skip-sibling proof:

```bash
swift test --skip RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable
```

Result:

- PASS: 500 tests, 3 skipped, 0 failures.

## Worktree State

Post-validation `git status --short --branch`:

```text
## main...origin/main
```

No tracked diff after regen/verification.

## Proof Class

`local`: local static/codegen/test acceptance only. No runtime, mobile, true-device, live API, training, data generation, or C6 acceptance claim.

