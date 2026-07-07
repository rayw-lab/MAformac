# RECEIPT-G7A-fix — B1 subset grouping contract fix

status: DONE-G7A-FIX
proof_class: local + ci
worktree: `/Users/wanglei/workspace/MAformac-g7a`
branch: `c5gate/g7impl-a-manifest-grammar`
commit: `e6499229` (`Fix subset grouping contract authority`)
PR: https://github.com/rayw-lab/MAformac/pull/18
merge_order: RAT_FIRST_REQUIRED; G7A PR updated only, not merged

## Fix

- Removed generator-owned hardcoded `SEAT_GROUPS` / `WHOLE_DOMAIN_SINGLE_GROUPS` tables from `scripts/gen_subset_manifest.py`.
- Added authored contract `contracts/subset-grouping.yaml` with authority frontmatter/meta:
  `功能分组语义=授权输入非派生物`.
- Generator now reads `--grouping-contract` and records top-level
  `meta.grouping_contract_digest` in `generated/subset-policy-manifest.json`.
- Added fail-closed closure:
  - every mapped seat `_sg` must exist in catalog;
  - every catalog seat `_sg` must be mapped;
  - new seat `_sg` fails with explicit contract-update error;
  - whole-domain entries must name existing catalog domains.
- Added verify-chain coverage:
  - `contracts/subset-grouping.yaml` in `HANDWRITTEN_CONTRACTS`;
  - `verify_refs.py` asserts contract authority and catalog closure.
- Added regression test for unknown/missing seat `_sg` closure failure.

## Frozen Parameters

- `7200` cap unchanged.
- S-201 entry field group unchanged; only manifest top-level `meta` gained `grouping_contract` and `grouping_contract_digest`.
- `pair_mode=degraded_clarify` unchanged.
- Phase-1 construction only preserved: no runtime NLU, no real generation, no C6 acceptance, no training, no grammar vendor integration.

## Validation

- `python3 -m py_compile scripts/gen_subset_manifest.py scripts/test_subset_manifest.py scripts/verify_refs.py` PASS
- `python3 scripts/test_subset_manifest.py` PASS
- `HF_HUB_OFFLINE=1 python3.13 scripts/gen_subset_manifest.py --emit --verify-budget --budget-cap 7200 --tokenizer-mode qwen --output-dir generated` PASS
  - entries=18260
  - artifacts=115
  - degraded_pairs=1
- `make test` PASS
- `make verify-subset-budget` PASS
- `make verify-refs` PASS
  - `subset_grouping=ok (seat_groups=7 seat_sgs=36 whole_domains=5)`
- `make verify` PASS
- `git diff --check` PASS
- GitNexus `detect_changes(scope=staged, worktree=...)` advisory PASS: risk=low, affected_processes=0; index noted stale.
- PR #18 Verify CI PASS:
  - run: https://github.com/rayw-lab/MAformac/actions/runs/28564877097
  - job: https://github.com/rayw-lab/MAformac/actions/runs/28564877097/job/84689978786
  - completed: 2026-07-02T04:15:39Z

## Residual

- PR #18 is green and mergeable (`mergeStateStatus=CLEAN`) but must wait for RAT PR first per磊哥 merge-order lock.
- No product/runtime/mobile/V-PASS claim made.

REPORT G7A-FIX DONE commit=e6499229 pr=18 ci=SUCCESS local_gates=make_test,verify_subset_budget,make_verify merge=NOT_MERGED_WAIT_RAT_FIRST
