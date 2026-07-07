# CORPUS-CONSOLIDATION-RECEIPT

status: partial_corpus_staging_ready  
artifact_kind: wave1_corpus_consolidation_receipt  
proof_class: local_script_validation_plus_batch01_judge_pass_dryrun  
repo_face: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge @ 266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

`tools/consolidate_wave1_corpus.py` is ready for Wave-1 corpus staging.

The dry run includes only `warmup-batch-01`, because it is the only batch with a disk-bound judge `PASS` verdict at this checkpoint. Batch-02..05 mechanical gates are green but judge verdicts are still pending, so they are not included in the merged corpus.

This is not a train-ready or V-PASS claim.

## Tool

Path:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/tools/consolidate_wave1_corpus.py`

sha256:

`2f736c75cc0685cd30bd84026d0007ab9e07e640c612dd3e1223b5665159302c`

Usage:

```bash
cd /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup
python3 tools/consolidate_wave1_corpus.py --batches 01 --output-dir wave1-corpus-dryrun-batch-01
```

Full-wave rerun after judge verdicts land:

```bash
python3 tools/consolidate_wave1_corpus.py --batches 01,02,03,04,05 --output-dir wave1-corpus-staging
```

If any judge verdict lands outside the standard lane path, use `--inputs-json` to provide explicit `candidates`, `ledger`, `gates_receipt`, and `judge_verdict` paths.

## Dry-Run Outputs

Manifest:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-dryrun-batch-01/wave1-corpus-manifest.json`

sha256:

`28f342991e5380c3a1d1d2dfaf47f1386a4a0fc1c84dbdda575118ebc5cd18dc`

Merged corpus:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/wave1-corpus-dryrun-batch-01/wave1-corpus.jsonl`

sha256:

`eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c`

Rows:

`50`

## Batch-01 Evidence

| Field | Value |
|---|---|
| batch_id | `warmup-batch-01` |
| lane | `subcc-1` |
| rows | `50` |
| candidate_pool_sha256 | `eee76baf662cb41ae32b2a6f8c49c3d1fcf2b25b850001a5541822d27602016c` |
| ledger_sha256 | `a1ed5e688a15f9a95b04a93ee0f79fa14ced47f3bcd9f455f65a6d2b2965ab81` |
| gates receipt | `lane-subcc-1/gates/B01-GATES-RECEIPT-v8.json` |
| gates receipt sha256 | `01b33e5671286d7902d3375992750956620b4f81fc2200f60c95df115a1cb498` |
| gates status | `mechanical_gates_pass_local` |
| judge verdict | `PASS` |
| judge verdict path | `lane-subcc-1/judge-openai-batch-01-verdict.md` |
| judge verdict sha256 | `99008b0bd46c7f117c6e993c1f7ccba5091f47be2279f2779c9a38affa4a0930` |
| main_pin_sha | `b33d8eba152e5326f69bbe85fc356b73419ee9c3` |

Claim layering:

| Layer | Scope | Coverage |
|---|---|---|
| mechanical/provenance | full_run | `D5/D6/D7/D9/A10/A11/A12 = 50/50` |
| semantic/content | sampled_confidence | `D1/D2/D3/D4/D8 = 20/50`, `sample_size_formula_version=judge_sampling_rev2.1_family_min50_max20_10pct` |

## Count Table

| Metric | Count |
|---|---:|
| expected full-wave batches | 5 |
| expected rows per batch | 50 |
| expected full-wave rows | 250 |
| selected batches in dry run | 1 |
| selected candidate rows | 50 |
| included judge-PASS batches | 1 |
| included corpus rows | 50 |
| remaining unselected batches | 4 |
| expected remaining rows | 200 |

## Pending Sanity

Command:

```bash
python3 tools/consolidate_wave1_corpus.py --batches 01,02,03,04,05 --output-dir /tmp/maformac-wave1-corpus-all-pending
```

Result:

`status=partial_corpus_staging_ready`, `included_rows=50`, `pending_judge_batches=4`.

`B02/B03/B04/B05` are discovered with 50 candidate rows each, but excluded because `judge_verdict=PENDING`. This confirms the consolidator does not promote mechanical-gate green batches into corpus rows without judge PASS.

Temp manifest sha256:

`7cf9915e40a1bae708a659c82a744da4f0569d8e53608630b990c473915f2b4a`

## Validation

```bash
python3 -m py_compile tools/consolidate_wave1_corpus.py
python3 tools/consolidate_wave1_corpus.py --batches 01 --output-dir wave1-corpus-dryrun-batch-01
wc -l wave1-corpus-dryrun-batch-01/wave1-corpus.jsonl
```

Results:

- `py_compile`: pass
- dry run: `status=partial_corpus_staging_ready`, `rows=50`
- corpus row count: `50`

## Non-Claims

- Does not include batch-02..05 until their judge verdicts land as `PASS`.
- Does not assert final 250-row corpus readiness yet.
- Does not mutate source candidates, ledgers, gates receipts, or judge verdicts.
- Does not recompute `candidate_row_sha` for corpus serialization; source `candidate_row_sha` is preserved, and `batch_id` is the provenance field.
