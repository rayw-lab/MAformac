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
