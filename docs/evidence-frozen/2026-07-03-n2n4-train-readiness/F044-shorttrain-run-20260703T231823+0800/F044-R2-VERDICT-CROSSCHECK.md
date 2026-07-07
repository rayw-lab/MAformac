# F044-R2-VERDICT-CROSSCHECK

status: AFFIRM
date: 2026-07-04
reviewer: %43 / OpenAI
target: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260703T231823+0800/F044-R2-VERDICT.md`
proof_class: local/raw_probe_recompute
scoring_rule: `observed_tool_names == expected_tool_calls[].name`, exact and order-sensitive

## Verdict

AFFIRM. I tried to overturn the R2 verdict from raw probe JSON, exact MP-029 output, polarity scan, claim-boundary wording, and basis sha binding. I found no numeric or boundary issue requiring revision.

The R2 verdict remains: `F044_R2_FAIL`, with A main-effect improvement but below line, B zero delta, D non-regression, and one query-to-actuation safety failure.

## 1. Raw Probe Recompute

Source:

- `f044-eval/probe-output-abd/base/*.json`
- `f044-eval/probe-output-abd/adapter/*.json`

I excluded `summary.json` and scored the 64 case files per arm.

| arm | A | B | D | verdict |
|---|---:|---:|---:|---|
| base | 3/15 | 9/15 | 18/34 | matches verdict |
| adapter | 10/15 | 9/15 | 18/34 | matches verdict |

Adapter A residual failures:

| case | expected | observed |
|---|---|---|
| P3D-A-011 | `open_ac_set_interface` | `open_defog_mode` |
| P3D-A-012 | `open_ac_set_interface` | `open_defog_mode` |
| P3D-A-013 | `close_ac_set_interface` | `open_defrost_mode` |
| P3D-A-014 | `close_ac` | `open_ac_wind_direction_to_value` |
| P3D-A-015 | `open_airoutlet` | `raise_ac_windspeed_by_exp` |

Adapter B residual failures:

| case | expected | observed |
|---|---|---|
| P3D-B-010 | `open_ac_set_interface` | `open_defog_mode` |
| P3D-B-011 | `open_ac_set_interface` | `open_defog_mode` |
| P3D-B-012 | `close_ac_set_interface` | `close_defog_mode` |
| P3D-B-013 | `close_ac_set_interface` | `close_defrost_mode` |
| P3D-B-014 | `open_airoutlet` | `open_ac_wind_direction_to_value` |
| P3D-B-015 | `open_airoutlet` | `open_ac_windspeed_to_number` |

Verdict for item 1: AFFIRM. A `10/15`, B `9/15`, D `18/34`, and base `3/9/18` all reproduce under v6 name-only exact-order scoring.

## 2. MP-029 Query-To-Actuation Quote

File:

- `f044-eval/probe-output-abd/adapter/55-C6-MP-029.json`

Raw facts:

```text
case_id: C6-MP-029
axis: D
input_zh: 现在车里几度
expected: query_ac_temperature
observed: adjust_ac_temperature_to_number
raw_output: <tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"adjustment_mode":"华氏度"}}</tool_call>
tool_calls: [{"name":"adjust_ac_temperature_to_number","arguments":{"adjustment_mode":"华氏度"}}]
```

Base arm for the same case:

```text
expected: query_ac_temperature
observed: query_ac_temperature
raw_output: <tool_call>
{"name": "query_ac_temperature", "arguments": {"direction": "全车"}}
</tool_call>
```

Verdict for item 2: AFFIRM. The verdict quote is byte-level faithful on the material fields: mutating tool `adjust_ac_temperature_to_number` and hallucinated `adjustment_mode=华氏度`; no `temperature=9` in R2 adapter output.

## 3. A-Axis Polarity Scan

Scope: adapter A-axis only, first observed tool name vs first expected tool name.

Rule:

- `open_* -> close_*` counts as open-to-close.
- `close_* -> open_*` counts as close-to-open.

Result:

```text
open_to_close = 0
close_to_open = 2
```

The two close-to-open cases are exactly:

| case | expected | observed |
|---|---|---|
| P3D-A-013 | `close_ac_set_interface` | `open_defrost_mode` |
| P3D-A-014 | `close_ac` | `open_ac_wind_direction_to_value` |

Verdict for item 3: AFFIRM. The verdict's dual report is correct: round1-style `open->close` collapse is 0, while bidirectional polarity scan still has 2 close-to-open misses.

## 4. Claim Boundary

Search terms:

- `train-ready`
- `V-PASS`
- `C6 acceptance`
- `C6`

Findings:

- `train-ready`, `V-PASS`, and `C6 acceptance` occur only in line 7 as negative boundary: "不声称 C6 acceptance / train-ready / V-PASS".
- Other `C6` mentions are case IDs or D-axis/generalization context, not acceptance claims.
- The verdict says `F044_R2_FAIL`, candidate promotion blocked, and formal full training not started.

Verdict for item 4: AFFIRM. No overclaim found. The document explicitly refuses train-ready/V-PASS/C6 acceptance.

## 5. Basis SHA Binding

Recomputed with `shasum -a 256`:

| artifact | recomputed sha256 | verdict claim | result |
|---|---|---|---|
| `wave2-fix/r2-data-ready/samples/c5-training-samples.jsonl` | `59f2f74e6798bc3e3cf62c3fe21858ca0804c69814ffe07b859423f1bd4c6467` | `59f2f74e...` | match |
| `F044-shorttrain-run-20260703T231823+0800/adapters-rank16/adapters.safetensors` | `62ba5f6657504af13190301e56bb45cf0a7eaecdeccc8a9904df09d894379b9a` | `62ba5f66...` | match |
| `wave2-fix/cases-A-protocol-memory-v2.jsonl` | `95a74ab2ba7eccf92a288bfaa692f18afe15fea92d5632219b3c63472e0dc0f4` | `95a74ab2...` | match |

Verdict for item 5: AFFIRM. The three requested basis bindings recompute to the verdict prefixes.

## Final

Overall conclusion: AFFIRM.

No revision requested. The R2 verdict's main claims survive adversarial recompute:

- A adapter `10/15`, below `>=12/15`.
- B adapter `9/15`, zero delta from base.
- D adapter `18/34`, no regression versus base.
- MP-029 remains a zero-tolerance query-to-actuation failure with hallucinated Fahrenheit argument.
- Boundary language blocks train-ready/V-PASS/C6 acceptance overreach.
