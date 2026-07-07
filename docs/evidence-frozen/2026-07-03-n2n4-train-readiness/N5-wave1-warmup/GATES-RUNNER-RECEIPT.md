# GATES-RUNNER-RECEIPT

status: runner_ready_fixture_pass_p1_fixed  
artifact_kind: controller_gate_runner_receipt  
proof_class: local_script_validation_plus_batch01_fixture_plus_negative_fixtures  
repo_face: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge @ 266783468ac38542574ea4787bec650d16ba6b02`

## Verdict

`tools/run_batch_gates.py` is ready for per-batch controller mechanical gates after the `%43` P1 fix.

The runner now treats the lane delivery as a complete five-artifact set:

1. `candidates.jsonl`
2. `value_change_ledger.jsonl`
3. `batch_manifest.json`
4. `batch_self_audit.md`
5. `generation_receipt.md`

`batch_self_audit.md` is required at preflight, included in `resource_envelope.files`, and required in `SHA256SUMS.txt` closure. Missing file and missing SHA entry both fail closed with a blocked receipt.

## Tool

Path:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/tools/run_batch_gates.py`

sha256:

`69ad6734031ce0c8494c9e86e07b124ac5cfc85e0c20c589880413c5a5645c90`

Key anchors:

| Contract item | Anchor |
|---|---|
| Required SHA set includes `batch_self_audit.md` | `tools/run_batch_gates.py:33-39` |
| `SHA256SUMS.txt` missing-entry fail-closed | `tools/run_batch_gates.py:214-242` |
| `batch_self_audit` in `resource_envelope.files` | `tools/run_batch_gates.py:386-399` |
| `batch_self_audit` in preflight required paths | `tools/run_batch_gates.py:432-445` |
| Controller closure blocks on SHA closure | `tools/run_batch_gates.py:494-508` |

## Positive Fixture

Commands:

```bash
cd /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup
python3 -m py_compile tools/run_batch_gates.py tools/inject_controller_shas.py
python3 tools/run_batch_gates.py lane-subcc-1
```

Result:

`status=mechanical_gates_pass_local`

Fixture receipt:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/lane-subcc-1/gates/B01-GATES-RECEIPT-v8.md`

Fixture receipt hashes:

| Artifact | sha256 |
|---|---|
| `B01-GATES-RECEIPT-v8.md` | `877858b8643333ba16adc67dfa12d0e81416ff8a03c76290b5fc4cad1fd434c4` |
| `B01-GATES-RECEIPT-v8.json` | `01b33e5671286d7902d3375992750956620b4f81fc2200f60c95df115a1cb498` |
| `datagate-v8/c5-data-gate-receipt.json` | `5bc5712ddb9935bdeab27683981fd014c4b500844d0dbb2a90718eb6bbad38ad` |
| `diversity-v8/diversity-report.json` | `d6f3c432d129ecc25b2df23f8a3386045cc1d508c0adcb4531ac1ca656287842` |
| `c6-leakage-v8/c6-leakage-probe.json` | `42ae22631f40c444b90ac6b2a630c615a8a538cdde7ab75dd3dd01bf61ee9b39` |

Fixture facts:

| Gate | Result |
|---|---|
| controller row-level recipe/quota sha | 50/50 |
| candidate_row_sha recompute | 50/50 |
| ledger candidate_row_sha sync | 50/50 |
| SHA256SUMS closure | pass, required entries 5/5 |
| DataGate | `data_gate_ready`, 50 rows |
| diversity | `PASS` |
| C6 leakage | `pass` |

## Negative Fixtures

### Missing `batch_self_audit.md`

Command shape:

```bash
python3 tools/run_batch_gates.py /tmp/maformac-gates-runner-fix-neg-file/batch-01 \
  --lane-dir /tmp/maformac-gates-runner-fix-neg-file/batch-01/lane-subcc-1 \
  --order /tmp/maformac-gates-runner-fix-neg-file/batch-01/batch-01-order.json \
  --builder-manifest /tmp/maformac-gates-runner-fix-neg-file/batch-01/builder-dryrun/wave1-warmup-batch-manifest.json \
  --version 1
```

Result:

`exit=2`, `status=blocked_preflight`

Receipt:

`/tmp/maformac-gates-runner-fix-neg-file/batch-01/lane-subcc-1/gates/B01-GATES-RECEIPT-v1.json`

sha256:

`f08acc9de50899fee21d9719bf0ecc87bb7f9cef110793c04b5fa01011b24b02`

### Missing `SHA256SUMS.txt` entry for `batch_self_audit.md`

Command shape:

```bash
python3 tools/run_batch_gates.py /tmp/maformac-gates-runner-fix-neg-sha/batch-01 \
  --lane-dir /tmp/maformac-gates-runner-fix-neg-sha/batch-01/lane-subcc-1 \
  --order /tmp/maformac-gates-runner-fix-neg-sha/batch-01/batch-01-order.json \
  --builder-manifest /tmp/maformac-gates-runner-fix-neg-sha/batch-01/builder-dryrun/wave1-warmup-batch-manifest.json \
  --version 1
```

Result:

`exit=2`, `status=blocked_controller_closure`, `missing_required_entries=["batch_self_audit.md"]`

Receipt:

`/tmp/maformac-gates-runner-fix-neg-sha/batch-01/lane-subcc-1/gates/B01-GATES-RECEIPT-v1.json`

sha256:

`9d1c1e030cdb2ecfea720a41e7f68bf15158e336283863e348f4e79d60ddb8f3`

## Batch 02-05 Runs

| Batch | Verdict | Receipt | sha256 |
|---|---|---|---|
| B02 | `mechanical_gates_pass_local` | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-02/lane-subcc-2/gates/B02-GATES-RECEIPT-v3.md` | `75cf8991a6fdd5584467567c2ef51486f5b27cee67027ffdf95e44565e90db60` |
| B03 | `mechanical_gates_pass_local` | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-03/lane-subcc-3/gates/B03-GATES-RECEIPT-v1.md` | `528728a791271342ef9ab25dc69c061e809c3b909cce9be314a512e1255a1755` |
| B04 | `mechanical_gates_pass_local` | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-04/lane-subcc-4/gates/B04-GATES-RECEIPT-v1.md` | `a8dab0eb424b1f8f8a7440389a53ccc9799658de80104846b8fd5512abdbfa35` |
| B05 | `mechanical_gates_pass_local` | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-wave1-warmup/batch-05/lane-subcc-5/gates/B05-GATES-RECEIPT-v1.md` | `ba1eae406a86842eae66c9be4e8e1cad8334a16ddcb3a4ed244fc0aae088336c` |

For all four batches: rows 50, DataGate `data_gate_ready`, diversity `PASS`, C6 leakage `pass`, required SHA set 5/5.

## Reports Sent

Sent to `%42`:

```text
REPORT %42: B02-GATES mechanical_gates_pass_local ... B02-GATES-RECEIPT-v3.md ...
REPORT %42: B03-GATES mechanical_gates_pass_local ... B03-GATES-RECEIPT-v1.md ...
REPORT %42: B04-GATES mechanical_gates_pass_local ... B04-GATES-RECEIPT-v1.md ...
REPORT %42: B05-GATES mechanical_gates_pass_local ... B05-GATES-RECEIPT-v1.md ...
```

## Non-Claims

This runner signs local mechanical gates only. It does not assert judge pass, train-ready, V-PASS, or run authorization.
