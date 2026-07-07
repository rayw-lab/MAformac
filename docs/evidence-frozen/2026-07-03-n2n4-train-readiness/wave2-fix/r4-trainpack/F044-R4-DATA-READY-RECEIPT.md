# F044 R4 Data Ready Receipt

status: r4_data_ready_static_gates_pass_no_train
proof_class: local_static_preflight_no_train_no_adapter
mode: R2b 5499 byte-preserving base + R4-QNEG-ISO 154 append

## Row Account

- combined rows: 5653
- conservation: 5499 + 154 = 5653 (pass)
- split counts: train=5253, dev_selection=400
- no-call ratio: 164 / 5506 = 2.9786%
- R3 pack used as base: false; R2b replay/protected rows preserved by byte copy.

## Static Gates

- locked floors: GREEN (green=None, advisory_red=None, blocking_red=None)
- render: pass train/valid/test=5253/400/128 mount_diff=0/0
- scanner: pass_no_contradictions contradictions=0 mount_order=pass
- DataGate: data_gate_ready row_count=5653 quarantine=0 must_not_train=0 parent_overlap=0 tool_call_failures=0
- strict preflight: pass records=5781 trainable_tokens=135013 ignored_tokens=18843918 max_token_length=7530 length_violations=0

## Key Artifacts

- `c5-training-samples.jsonl` sha256 `9d4bc2d25ae77325e23fd985a4b556627ac85fb53c53a2e7f2e816b5c96d1782`
- `samples/c5-training-samples.jsonl` sha256 `39a3c278b7a7ea0054d7c1c99899b7b85f19fb378e5911296c27cd68055a8f33`
- `render-data-summary.json` sha256 `2c009e92b24ecc0c547e161b915710c5805027d5d96882e2ef544299ae828222`
- `mlx-data/train.jsonl` sha256 `a9ee9e8536bce74396d307e4f845c549f97191eaf1a628792b7e056745b0a414`
- `mlx-data/valid.jsonl` sha256 `df1e356d210e9658918aceb65a1c8f1c0e813412ac63ce830ed80f9362eab897`
- `mlx-data/test.jsonl` sha256 `ed7a78567156468e7fb951e84073e852cbdfe8f859fe43544a1b8f0a006cdcc2`
- `datagate/c5-data-gate-receipt.json` sha256 `eec97289a76e005d17b6a21ea0e82b5417036ff2b0be29b8cabd8cf659b52eb7`
- `strict-preflight.metrics.jsonl` sha256 `2d961654bd4340391fa31f7a80c3e923637726608098d253f7d7a6f99d99d756`
- `assembly_receipt.json` sha256 `d986f179dda5d2ebdc2319f91892deb75784ee843659040735f6ffde565b37c9`

## Non-Claims

- No model training, optimizer update, adapter save, or eval inference was run in this task.
- This is local static data readiness for the R4 trainpack only.
