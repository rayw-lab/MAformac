# RECEIPT-G7A — E-2 manifest grammar construction

status: PARTIAL_LOCAL_PASS_WITH_KNOWN_SIBLING_FIXTURE_NOISE_AND_CI_GREEN
proof_class: local
worktree: /Users/wanglei/workspace/MAformac-g7a
branch: c5gate/g7impl-a-manifest-grammar
base: 80ea379c3dea93b8b5419c192563872764b1bba1
commit: f3090899
pr: https://github.com/rayw-lab/MAformac/pull/18
ci: https://github.com/rayw-lab/MAformac/actions/runs/28564066439/job/84687631667

## Scope

- Phase-1 construction only.
- Implemented manifest codegen, static subset budget gate, grammar data artifacts, and regression tests.
- No runtime NLU, no real data generation, no C6 acceptance, no training, no grammar vendor integration.

## Frozen Parameters

- cap remains `7200`.
- S-201 manifest/digest field group remains present.
- over-cap pair strategy remains `pair_mode=degraded_clarify`.
- Runtime trimming remains forbidden.

## Outputs

- `scripts/gen_subset_manifest.py`
- `scripts/test_subset_manifest.py`
- `generated/subset-policy-manifest.json`
- `generated/subset-grammar-artifacts.json`
- `Makefile` target `verify-subset-budget`

Manifest summary:
- entries: 18260
- single_group: 110
- sg_pair: 18145
- scene_macro: 5
- degraded_pairs: 1 (`seat_massage_force+volume`, 7343 > 7200)
- fail_over_budget: 0

## Validation

- `make test`: PASS
- `make verify-subset-budget`: PASS
- `git diff --check`: PASS
- `python3 -m py_compile scripts/gen_subset_manifest.py scripts/test_subset_manifest.py`: PASS
- `python3.13 -m py_compile scripts/gen_subset_manifest.py`: PASS
- `mcp__gitnexus.detect_changes(scope=staged, worktree=/Users/wanglei/workspace/MAformac-g7a)`: LOW, 0 indexed symbols, 0 affected processes
- `make verify-all`: PARTIAL
  - PASS through source snapshot, regen, refs, cross-section, surface, c6 shape, default-scope, diff, python tests, contentview wiring.
  - FAIL only at full local `swift test`: `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`, 5 sibling main fixture hash mismatches.
  - This is the known sibling UIUE fixture environment noise called out in the current route board, not a G7A touched path.
- `swift test --skip RuntimePresentationPayloadFixtureConsumerTests/testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`: PASS, 481 tests, 3 skipped, 0 failures.
- PR #18 CI `Verify`: PASS (`Run source-free verification gates`, whitespace, and CI receipt upload all succeeded).

## Merge Discipline

- PR #18 is open for review only.
- Per Lei instruction, RAT PR must merge first.
- G7A must not be merged into main ahead of RAT.

REPORT G7A status=PARTIAL_LOCAL_PASS_CI_GREEN pr=https://github.com/rayw-lab/MAformac/pull/18 commit=f3090899 merge_gate=RAT_FIRST validation="make test PASS; verify-subset-budget PASS; make verify-all PARTIAL only sibling fixture noise; swift skip sibling PASS 481/0; PR verify CI PASS"
