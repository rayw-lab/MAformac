# RECEIPT-P1FIX

captured_at: 2026-07-02 14:47:24 CST

## Verdict

P1 fix implemented and pushed. PR opened, not merged.

- PR: https://github.com/rayw-lab/MAformac/pull/22
- Branch: `fix/g7d-policy-authority`
- Worktree: `/Users/wanglei/workspace/MAformac-p1fix`
- Base requested: `main@1d822961`
- Commit: `ea8c909dd66d780706da5972345dc0549983d88d`

## Scope

Changed files:

- `Core/Training/C5LoRATraining.swift`
- `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`

Implemented:

- Added Swift expected policy id constant `e2-lite-v1`, with source comment pointing to `scripts/gen_subset_manifest.py:24 POLICY_ID`.
- Loader now validates every manifest entry has one consistent `subset_policy_id`.
- Loader now validates that id equals the generator authority value.
- Wrong or mixed policy ids fail closed with `G7D_SUBSET_POLICY_MISMATCH` and `subset_policy_mismatch`.
- Added permanent regression test `testDDomainSubsetManifestWrongPolicyProbe`.

## Validation

Proof class: local/unit/static.

Passed:

- `swift test --filter C5LoRATrainingTests/testDDomainSubsetManifestWrongPolicyProbe`
  - result: pass, 1 test / 0 failures
- `swift test --filter C5LoRATrainingTests`
  - result: pass, 53 tests / 0 failures
- `swift test --skip RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
  - result: pass, 501 tests / 3 skipped / 0 failures
- `make verify`
  - result: pass
  - evidence included subset manifest generation with `--budget-cap 7200`, `subset_grouping=ok`, `test_subset_manifest=ok`, and contentview wiring check pass
- `git diff --check`
  - result: pass
- GitNexus `detect_changes(scope=all, repo=MAformac-r5-main-current, worktree=/Users/wanglei/workspace/MAformac-p1fix)`
  - result: low risk, 2 changed files, affected_processes=0

Sibling noise, not fixed in this P1 branch:

- Raw `swift test` still fails only the existing sibling fixture parity test:
  `RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
- Failure shape observed before skip proof: 5 hash mismatches:
  `manifest.json`, `window_position_runtime_public_payload.v1.json`,
  `screen_brightness_runtime_public_payload.v1.json`,
  `ambient_brightness_runtime_public_payload.v1.json`,
  `window_position_noop_runtime_public_payload.v1.json`

## Git/PR

- `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git push -u origin fix/g7d-policy-authority`
  - result: pushed
- PR #22 opened against `main`
  - mergeStateStatus at creation check: `UNSTABLE`
  - no merge performed

## Residual Risk

- Full `swift test` is not green in this local workspace because of the existing sibling UIUE fixture parity mismatch. This receipt does not promote that to full-suite green.
- No runtime/mobile/live proof was run or claimed.
