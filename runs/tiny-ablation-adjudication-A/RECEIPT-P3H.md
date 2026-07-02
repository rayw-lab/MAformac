# RECEIPT-P3H

status: DONE_LOCAL_CONSTRUCTION_AND_BASE_SMOKE
proof_class: local + local_runtime_smoke
artifact_kind: experimental_receipt_not_c6_acceptance
worktree: /Users/wanglei/workspace/MAformac-p3h-probe
base: origin/main @ f4af8ccfc7d5f9249db53491d64648948aea03ca
pr: https://github.com/rayw-lab/MAformac/pull/26
spec: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/SPEC-P3H-probe-harness.md
authority_source: /Users/wanglei/workspace/MAformac/docs/c5-training-readiness-grill/p3h-harness-v2-grill-2026-07-03.md

## Scope

- Added warehouse-local probe harness under `Tools/ProbeHarness/`.
- Added source-free Python unit tests under `Tests/ProbeHarnessTests/`.
- Added explicit greedy decode contract at `Tools/ProbeHarness/decode-contract.greedy.json`.
- Ran only a base-only two-case runtime smoke with explicit `--base-only-smoke`.
- Did not edit `Core/` or `Training/`.
- Did not run adapter/paired formal probe, training, C6 acceptance, or candidate comparison.

## Decode Contract

```json
{
  "temperature": 0,
  "max_tokens": 160,
  "stop_tokens": [
    "</tool_call>",
    "\n",
    "\n\n",
    "\r\n"
  ],
  "tokenizer_wrapper": "mlx_lm_tokenizer_wrapper",
  "prompt_skeleton_id": "qwen3_patched_no_think_chat_template",
  "thinking": "no_think_block",
  "parser_id": "p3h_tool_call_json_ordered_v2",
  "tool_call_cardinality": "ordered_multi_call",
  "output_boundary": "raw_generation_and_truncated_output"
}
```

## GF-141~148 Absorbed

- GF-141: prompt rendering now goes through `tokenizer.apply_chat_template`; the handwritten fallback prompt is removed.
- GF-142: rendered prompts must contain `<think>\n\n</think>` and the assistant skeleton, or the harness exits `2` as `invalid_probe`.
- GF-143: paired mode requires `--adapter`; base-only execution requires explicit `--base-only-smoke` and reports `proof_class=base_smoke_not_paired`.
- GF-144: decode contract now includes tokenizer wrapper, prompt skeleton, thinking mode, parser id, tool-call cardinality, and output boundary fields; missing/invalid fields fail closed.
- GF-145: per-case records store `raw_generation`, `truncated_output`, `parse_errors`, tail marker, and compatibility `raw_output`.
- GF-146: parser extracts ordered multi-call evidence from raw generation; test fixture covers C6-MP-028 two-call order.
- GF-147: `max_tokens` is now 160.
- GF-148: local smoke artifacts were removed from PR #26; this receipt keeps only a scrubbed summary plus the local absolute artifact pointer below.

## Validation

```bash
python3 -m unittest discover -s Tests/ProbeHarnessTests -p 'test_*.py' -v
# Ran 11 tests OK

/opt/homebrew/opt/python@3.13/bin/python3.13 -m py_compile Tools/ProbeHarness/probe_harness.py Tests/ProbeHarnessTests/test_probe_harness.py
# exit 0

/opt/homebrew/opt/python@3.13/bin/python3.13 - <<'PY'
import inspect
import mlx_lm
from mlx_lm import generate
print('python', __import__('sys').executable)
print('mlx_lm_version', getattr(mlx_lm, '__version__', 'unknown'))
print('generate_signature', inspect.signature(generate))
print('import_status', 'ok')
PY
# python /opt/homebrew/opt/python@3.13/bin/python3.13
# mlx_lm_version 0.31.1
# import_status ok
```

## Smoke Evidence — Base Only

Purpose: Phase D preflight only. This proves `load -> apply_chat_template -> prompt assertion -> generate -> raw/truncated persistence -> extract` can execute with the v5 Python/model environment on two D-axis cases. It is not a formal probe and does not make a behavior-quality claim.

Local artifact root, intentionally outside PR:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/p3h-v2-base-smoke-20260703T001813+0800
```

Smoke command:

```bash
RUN_ROOT="/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/p3h-v2-base-smoke-20260703T001813+0800"
MODEL="/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/build/qwen3-1_7b-training-tokenizer-patched"
/opt/homebrew/opt/python@3.13/bin/python3.13 Tools/ProbeHarness/probe_harness.py \
  --base-only-smoke \
  --cases "$RUN_ROOT/cases-d-axis-2.jsonl" \
  --base-model "$MODEL" \
  --decode-contract Tools/ProbeHarness/decode-contract.greedy.json \
  --output-dir "$RUN_ROOT/output"
# rc=0
# elapsed_wall_seconds=1
```

Smoke cases:

```text
C6-MP-004 打开空调 -> expected open_ac
C6-MP-005 关闭空调 -> expected close_ac
```

Prompt and raw output evidence:

```text
C6-MP-004 prompt_has_empty_think=true raw_generation_startswith_think=false elapsed_ms=1348 raw_generation_repr='{"action": "open_ac"}' observed_tool_names=[]
C6-MP-005 prompt_has_empty_think=true raw_generation_startswith_think=false elapsed_ms=167 raw_generation_repr='NO_TOOL' observed_tool_names=[]
```

## Residual Risk

- This is base-only smoke, not adapter/paired formal probe.
- Empty `observed_tool_names` in smoke are raw evidence only; no behavior-quality verdict is claimed.
- CI state is checked outside this receipt after each push; this receipt does not claim CI pass unless separately reported.
- No PR merge, no training, no C6/model-quality acceptance, no candidate comparison, and no V/S/U-PASS claimed.

## GF-149~155 Tools-Mount v3 Absorbed

- GF-149: probe prompts now mount tools via `tokenizer.apply_chat_template(messages, tools=...)`; A/B axes resolve `source_sample_id` / `augmentation_parent_id` to the exact P12-v6 training row `tools` field. Missing mounts fail closed with exit 2 `invalid_probe_tools_mount_missing`.
- GF-150: C/D axes mount generated D-domain catalog `_sg` groups for the expected tool(s), using `/Users/wanglei/workspace/MAformac/generated/D_domain.tools.demo.json`; multi-call cases merge multiple `_sg` groups with tool-name de-duplication. This is recorded as policy `e2_sg_full_group`.
- GF-151: decode contract includes `tools_mount_policy=p3h_v3_training_row_or_e2_sg_catalog`; each per-case artifact records `mounted_tool_count`, `mounted_tool_names`, `mount_source`, and `mount_policy`.
- GF-152: prompt assertions now require a non-empty tools mount, `<tools>...</tools>` markers, empty no-think block, assistant skeleton, and a token-count floor. Real tokenizer dry-run over 68 cases passed; token range was 364..3847.
- GF-153: repeated identical tool calls are collapsed to the first call for this probe generation surface; ordered multi-call parsing remains covered for distinct calls.
- GF-155: v6 training was not rerun; paired probe was rerun to local artifact root `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6-probe2/`.

## Validation — Tools-Mount v3

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 -m py_compile Tools/ProbeHarness/probe_harness.py Tests/ProbeHarnessTests/test_probe_harness.py
# exit 0

/opt/homebrew/opt/python@3.13/bin/python3.13 -m unittest discover -s Tests/ProbeHarnessTests -p 'test_*.py' -v
# Ran 16 tests OK
```

Real tokenizer prompt validation:

```text
rendered 68 min (364, 'P3D-B-009', 2, 'train_row:c5-train-00009') max (3847, 'C6-MP-028', 10, 'catalog_sg:atmosphere_lamp_color,atmosphere_lamp_brightness')
```

Mount resolver dry-run:

```text
cases 68 mounts 68
A n=15 mounted_tool_count unique=[2,4]
B n=15 mounted_tool_count unique=[2,4]
C n=4 mounted_tool_count unique=[1,2]
D n=34 mounted_tool_count unique=[1,4,8,9,10]
```

## v6-probe2 Paired Runtime Evidence

Command persisted at:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6-probe2/probe2-command.txt
```

Runtime summary:

```text
started_at=2026-07-03T01:21:04+08:00
finished_at=2026-07-03T01:25:25+08:00
elapsed_seconds=261
exit_code=0
base_records=68
adapter_records=68
```

Per-axis expected-match summary, exact/order-sensitive on `observed_tool_names == expected_tool_calls[].name`:

| axis | arm | total | empty | non_empty | expected_match | expected_mismatch | mounted_tool_count_min | mounted_tool_count_max |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| A | base | 15 | 12 | 3 | 3 | 12 | 2 | 4 |
| A | adapter | 15 | 0 | 15 | 15 | 0 | 2 | 4 |
| B | base | 15 | 2 | 13 | 12 | 3 | 2 | 4 |
| B | adapter | 15 | 0 | 15 | 11 | 4 | 2 | 4 |
| C | base | 4 | 0 | 4 | 4 | 0 | 1 | 2 |
| C | adapter | 4 | 0 | 4 | 4 | 0 | 1 | 2 |
| D | base | 34 | 2 | 32 | 18 | 16 | 1 | 10 |
| D | adapter | 34 | 0 | 34 | 8 | 26 | 1 | 10 |

Sample evidence:

```text
adapter P3D-A-001 mounted=2 mount_source=train_row:c5-train-00001 prompt_has_tools=true observed=[open_ac_cooling_mode] expected=[open_ac_cooling_mode]
adapter P3D-B-001 mounted=2 mount_source=train_row:c5-train-00001 prompt_has_tools=true observed=[open_ac_cooling_mode] expected=[open_ac_cooling_mode]
adapter C6-MP-002 mounted=10 mount_source=catalog_sg:ac_temperature prompt_has_tools=true observed=[open_ac_temperature_to_exp] expected=[raise_ac_temperature_by_exp]
```

Machine summaries:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6-probe2/paired-axis-expected-match-summary.json
/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6-probe2/paired-axis-expected-match-summary.md
```

## Residual Risk — Tools-Mount v3

- This run changes only probe input surface; it does not retrain, alter v6 weights, or touch Core/Training.
- D-axis is report-only paired data under catalog `_sg` mount policy; no C6 acceptance, candidate comparison, model-quality verdict, threshold lock, or V/S/U-PASS is claimed.
- Repeated identical tool-call collapse is a v6 probe tolerance for missing EOS supervision; the data-side `<|im_end|>` supervision remains v6.1 work.
