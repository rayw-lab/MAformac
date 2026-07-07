# RE-EVAL-V3 Receipt — run155204 adapter on v3 original gate

status: re_eval_v3_executed_raw_counts_only
proof_class: local_model_eval_run
created_at: 2026-07-04T19:59:39+0800
claim_boundary: raw counts only; no verdict claim.

## Binding

| item | value |
|---|---|
| adapter_sha256 | `0d9b712b3fb10218873797b6e6389b9c3ef02c594dcea5d8b7bf725b56c295f4` |
| v3_cases_sha256 | `5ba023eb87ae1ea00ab466dd7b20b3151b4a0a6b4ccefc5f23465c30639c2d3c` |
| manifest_amendment_sha256 | `e79317baa0dda2b1ce2e3fc11caf5ad7b2de06bdd71257e3e1ff09f5f5b496a8` |
| probe_harness_sha256 | `2d904aa0d33eb8d2fb68656cb9a381d1a4e7b4ee789eeb0b1271811d88df354a` |
| scorer_sha256 | `d66bd9f6882221d2b957e8324165d8690b2e98ba80b30d310d1395d044f6aa4c` |
| mount_checker_sha256 | `c81de408721c4e4eafd413b9d0d35e74b07c81a40bf082f6785885a9b69ec877` |

## Mount Validity

| gate | checked | violations | status |
|---|---:|---:|---|
| v3 bundle | 64 | 0 | PASS |
| v3 probe output | 128 | 0 | PASS |

## V3 Paired Counts

| arm | A | B | D |
|---|---:|---:|---:|
| base_v3 | 3/15 | 14/15 | 18/34 |
| adapter_v3 | 15/15 | 15/15 | 19/34 |

## QA Cross-Track Rescan

| scanned_records | failure_count | original_v3_failures | expanded_existing_failures |
|---:|---:|---:|---:|
| 30 | 11 | 0 | 11 |

## Artifacts

| artifact | path |
|---|---|
| paired report v3 | `TD-eval-run155204-ready/original-gate-v3/R2B-ORIGINAL-GATE-V3-PAIRED-REPORT.md` |
| raw counts | `TD-eval-run155204-ready/original-gate-v3/RE-EVAL-V3-RAW-COUNTS.json` |
| qa scan | `TD-eval-run155204-ready/original-gate-v3/query-zero-tolerance-cross-track-v3.json` |
| mount probe output gate | `TD-eval-run155204-ready/original-gate-v3/mount-validity-v3-probe-output.json` |
