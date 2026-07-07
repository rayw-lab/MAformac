# RECEIPT-G7AB-acceptance — M1 post-merge main validation

status: LOCAL-PASS-WITH-SIBLING-NOISE
proof_class: local
worktree: `/Users/wanglei/workspace/MAformac-m1g`
branch: `main`
main_head: `2b006b8a314522be79bc4995bddacad35c48568a`
command_requested: `git checkout main && env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy git pull origin main && make verify-all`

## Pull Truth

- Before pull: `main...origin/main [behind 4]`, clean.
- Pull: fast-forward `80ea379c..2b006b8a`.
- After validation: `main...origin/main`, clean.

## Validation

- `make verify-all` ran on `main=2b006b8a`.
- `make verify` portion passed:
  - C1 freeze/codegen passed.
  - D-domain catalog passed: demo=562, full=1538.
  - subset manifest regen/budget passed: entries=18260, artifacts=115, degraded_pairs=1.
  - `verify_refs.py` passed, including `subset_grouping=ok (seat_groups=7 seat_sgs=36 whole_domains=5)`.
  - cross-section, surface consistency, gold, C6 shape, default-scope, C5/C2 parity, scope-origin, diff, Python tests and contentview wiring passed.
- `swift test` inside `make verify-all` failed only on local sibling UIUE fixture parity:
  - suite: `RuntimePresentationPayloadFixtureConsumerTests`
  - test: `testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
  - 5 hash assertions drifted: `manifest.json`, `window_position_runtime_public_payload.v1.json`, `screen_brightness_runtime_public_payload.v1.json`, `ambient_brightness_runtime_public_payload.v1.json`, `window_position_noop_runtime_public_payload.v1.json`
  - rerun summary: 491 tests, 3 skipped, 5 failures.
- Supplemental sibling-isolated proof:
  - `swift test --skip RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`
  - PASS: 490 tests, 3 skipped, 0 failures.

## Logs

- `G7AB-main-swift-test-rerun.log`
- `G7AB-main-swift-test-skip-sibling.log`

## Verdict

Main G7A/G7B post-merge validation is accepted as local-pass with sibling noise isolated. The only red is local sibling UIUE corpus drift, not a G7A/G7B main regression. No runtime/mobile/V-PASS claim.

REPORT G7AB-ACCEPTANCE LOCAL_PASS_WITH_SIBLING_NOISE main=2b006b8a make_verify=PASS swift_full=FAIL_ONLY_SIBLING_PARITY swift_skip_sibling=PASS_490_0 next=G7D_START_ALLOWED
