# Lane-C Numeric Value Constant Repair Receipt

status: REPAIR_COMPLETE_PENDING_SCOPED_REJUDGE
proof_class: local/repair-lane
lane: `r2b-s2-lane-c`
repair_id: `LANEC-NVC-REPAIR`
scope: add `numeric_value_constant` to 8 target candidate rows; recompute target row hashes; sync ledger candidate hashes

## Files

| artifact | path |
| --- | --- |
| candidates | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/candidates.jsonl` |
| ledger | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/value_change_ledger.jsonl` |
| SHA256SUMS | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/SHA256SUMS.txt` |
| before snapshot | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/_scratch/nvc-repair-before-20260704/` |

## Field Patch

| sample_id | line | `numeric_value_constant` | rationale |
| --- | ---: | --- | --- |
| `r2b-s2-c-031` | 31 | `value_is_cue` | little-vs-number tested cue |
| `r2b-s2-c-032` | 32 | `value_is_cue` | little-vs-number tested cue |
| `r2b-s2-c-033` | 33 | `value_is_cue` | extremum-vs-number tested cue |
| `r2b-s2-c-034` | 34 | `value_is_cue` | extremum-vs-number tested cue |
| `r2b-s2-c-061` | 61 | `true` | `wrf1_1`, both 4 |
| `r2b-s2-c-062` | 62 | `true` | `wrf1_1`, both 4 |
| `r2b-s2-c-063` | 63 | `true` | `wrf1_2`, both 2 |
| `r2b-s2-c-064` | 64 | `true` | `wrf1_2`, both 2 |

No non-target candidate row received `numeric_value_constant`.

## Hash Chain

Controller recipe/quota SHA values were preserved:

- `recipe_manifest_sha=sha256:35de977aef3f2459366dfb3a5434348c1c88ef5fcb8def1d0f3a708ed316f293`
- `quota_config_sha=sha256:9e8e41dce32734624906ab61e245a8b29ec18d75782efe840a880d6149fa5ef2`

Target row `candidate_row_sha` changes:

| sample_id | old sha | new sha |
| --- | --- | --- |
| `r2b-s2-c-031` | `22d2e47b812b13c1ceb840d17aff1c1a9b9968158ab96adb34312703c6ce1c63` | `547317b9113e3bc70fd7306c4ed68c2f9c89e2e16507023c93036a5ebfa673cb` |
| `r2b-s2-c-032` | `2abb5f35effcc7b85b5c462b8b59efb514c61e960da6d00ddedb34ac1e5234f2` | `b0785e53c8da2e2a3c53efc68f60df6d84f23b4d5b81202cc073a025a571135d` |
| `r2b-s2-c-033` | `fad6906b06a62f4c117e934be46a119e150cd817f4b1be1ec024a8ce9a2c9cb1` | `fe16079d4ce3c6771f7f22f1a5438250e9d403716758abc34ea53fe35a9835e8` |
| `r2b-s2-c-034` | `18a21f1c9e7f081a757f628b310bcb0eefea4bf85c368d353d8b7a32d4e60595` | `201a6c7bd88c29a8f08f337acb792cbce691b2760baa5c78735821f2b9aa6ea1` |
| `r2b-s2-c-061` | `cd5e07cf4ac459a7c9a42c9dae6e30d4bc9f6e8aaf5a1da810294235d6471303` | `d7f69db44889ef9c11c93e81a72ec0c28715b1d733ad533aaac67969906192d6` |
| `r2b-s2-c-062` | `3793f8fea47219de140da846940ed9e2dac89adeba9ddf87f4c8cbefccf2e979` | `2eee45735bbfad755f10bd7581ee34aff4c1885d958a3b9861bf5076a2751636` |
| `r2b-s2-c-063` | `9f1a3aae7673eba55bb61f2ee08cb42c46b05921044dc2538265d8619657d165` | `f2468bfd6d8a6e8f3771a4b5f91df3ed3e69344e3dbc4b987f2ede816aa10056` |
| `r2b-s2-c-064` | `2ba23459680277f7e04ee472190a48c46967e203a5203edde3bc70c2d30d3366` | `417f66a9d4961f645533bf1a948cf7757d88d4689a326dccac93bf3ea5ed2e92` |

Ledger rows for the same 8 `sample_id`s were updated only to align `candidate_row_sha`.

## Byte-Scope Proof

Before snapshot:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/_scratch/nvc-repair-before-20260704/`

| file | changed lines | unchanged lines | total |
| --- | --- | ---: | ---: |
| `candidates.jsonl` | `[31, 32, 33, 34, 61, 62, 63, 64]` | 67 | 75 |
| `value_change_ledger.jsonl` | `[31, 32, 33, 34, 61, 62, 63, 64]` | 67 | 75 |

This satisfies repair-lane scope: only target rows changed; non-target rows are byte-identical.

## Gates

Pair ledger:

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/pair_ledger_check.py \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/candidates.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/pair-ledger-nvc-repair.json
```

Result: `exit=0`, `status=pass`, `pair_rows=16`, `pair_group_count=8`, `pair_completeness_percent=100.0`, `failures=[]`.

Supervision scanner:

```bash
python3 /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/tools/supervision_consistency_scanner.py \
  --input /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/candidates.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/supervision-contradictions-nvc-repair.jsonl \
  --summary-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/supervision-summary-nvc-repair.json \
  --mount-order-report-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-c/mount-order-report-nvc-repair.json \
  --fail-on-contradiction
```

Result: `exit=0`, `status=pass_no_contradictions`, `contradiction_group_count=0`, `contradiction_row_count=0`, `mount_order_status=pass`.

`shasum -a 256 -c SHA256SUMS.txt` result:

```text
candidates.jsonl: OK
value_change_ledger.jsonl: OK
batch_manifest.json: OK
batch_self_audit.md: OK
generation_receipt.md: OK
```

## Final SHA

| artifact | sha256 |
| --- | --- |
| `candidates.jsonl` | `0c1c9326aafd80a3770b57b65980175e669984f9b19f44e87e95b0fe9a2572f9` |
| `value_change_ledger.jsonl` | `7f5d4e50b1c035536eb7e3f4aa11c5788a5051400053373616ef7643d34cfc04` |
| `SHA256SUMS.txt` | `5698d0abdcf8f104fcac989c7a9fbbd24a7c164103d4932e79e3231a9424c311` |
| `pair-ledger-nvc-repair.json` | `28a320d71f0557cd9733f697ee9dec8a82545e1b56ab8c62223e8eaf554692ca` |
| `supervision-summary-nvc-repair.json` | `bca85870039a66196b3bf59f9c8d5be0bafd77d366769ce061c22c4dafa2f743` |
| `supervision-contradictions-nvc-repair.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `mount-order-report-nvc-repair.json` | `6e9a1527a5ef69f69553ccd7fd4fabb120243eb28fcead1cf3958f45140fdbf0` |

## Non-Claims

- No scoped judge re-run in this pane.
- No DataGate or full gate rerun.
- No training assembly.
- This receipt is local repair evidence only.
