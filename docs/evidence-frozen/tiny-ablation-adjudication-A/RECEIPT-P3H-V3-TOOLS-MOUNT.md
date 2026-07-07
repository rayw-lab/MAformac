# RECEIPT-P3H-V3-TOOLS-MOUNT

status: DONE_LOCAL_RUNTIME
proof_class: local_runtime
captured_at: 2026-07-03T01:30:00+08:00
scope: P3H harness v3 tools mount fix + v6-probe2 paired rerun
non_claims: no retraining, no C6 acceptance, no candidate comparison, no model-quality verdict, no V/S/U-PASS

## Changes

- `Tools/ProbeHarness/probe_harness.py`
  - Requires tools mount for every case.
  - Renders prompts with `tokenizer.apply_chat_template(messages, tools=tools, tokenize=False, add_generation_prompt=True)`.
  - A/B axes mount exact P12-v6 training-row `tools` by `source_sample_id` / `augmentation_parent_id`.
  - C/D axes mount generated catalog `_sg` functional group(s) for expected tool(s).
  - Records `mounted_tool_count`, `mounted_tool_names`, `mount_source`, `mount_policy` per case.
  - Collapses repeated identical tool-call outputs to the first call for v6 EOS-gap tolerance.
- `Tools/ProbeHarness/decode-contract.greedy.json`
  - Adds `tools_mount_policy=p3h_v3_training_row_or_e2_sg_catalog`.
- `Tests/ProbeHarnessTests/test_probe_harness.py`
  - Adds contract fail-closed test, mount resolver test, missing tools negative, prompt tools assertions, and repeated-call collapse test.
- `runs/tiny-ablation-adjudication-A/RECEIPT-P3H.md`
  - Adds GF-149~155 evidence and v6-probe2 summary.

## Validation

```bash
/opt/homebrew/opt/python@3.13/bin/python3.13 -m py_compile Tools/ProbeHarness/probe_harness.py Tests/ProbeHarnessTests/test_probe_harness.py
# exit 0

/opt/homebrew/opt/python@3.13/bin/python3.13 -m unittest discover -s Tests/ProbeHarnessTests -p 'test_*.py' -v
# Ran 16 tests OK
```

Real tokenizer render dry-run:

```text
rendered 68 min (364, 'P3D-B-009', 2, 'train_row:c5-train-00009') max (3847, 'C6-MP-028', 10, 'catalog_sg:atmosphere_lamp_color,atmosphere_lamp_brightness')
```

## v6-probe2 Runtime

Command:

```text
/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/v6-probe2/probe2-command.txt
```

Runtime:

```text
started_at=2026-07-03T01:21:04+08:00
finished_at=2026-07-03T01:25:25+08:00
elapsed_seconds=261
exit_code=0
base_records=68
adapter_records=68
```

Per-axis expected-match summary:

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
adapter P3D-A-001 mounted=2 train_row:c5-train-00001 observed=[open_ac_cooling_mode] expected=[open_ac_cooling_mode]
adapter P3D-B-001 mounted=2 train_row:c5-train-00001 observed=[open_ac_cooling_mode] expected=[open_ac_cooling_mode]
adapter C6-MP-002 mounted=10 catalog_sg:ac_temperature observed=[open_ac_temperature_to_exp] expected=[raise_ac_temperature_by_exp]
```

## Residual Risk

- D-axis results are data only; no commander threshold or verdict is inferred here.
- `</tool_call>` repetition is tolerated in parser for v6 probe; proper EOS supervision remains v6.1 data work.
- Runtime proof is local MLX only, not mobile/true-device/demo-golden/live acceptance.
