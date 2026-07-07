# C5 Remediation PR1/PR3 Closeout (2026-06-21)

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

Scope: PR1 offset gate true verification + PR3 cloud-generated natural Chinese augmentation. PR2 clip training loop and PR4 broader doc reconciliation remain out of this closeout.

## PR1 Evidence

- Final prepare artifact: `Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3/c5-training-receipt.json`
- `offset_fixture.status`: `pass`
- Token artifact SHA-256: `c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9`
- Token artifact class coverage: `tool_call`, `no_call`
- Fixture path uses MLX tokenizer path and records trained spans that start with `<tool_call>` / `NO_TOOL` without user/system/think markers.

## PR3 Evidence

- Generated utterance artifact: `Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl`
- Generated utterance SHA-256: `46a3601856bacd975076817b988835ea9d5bd1f90d021246c1b4de0617dda604`
- Records: `4500`; unique keys: `4500`; protocol redline failures: `0`
- Generator sources: `hermes_glm=2249`, `hermes_ark_standard=2251`
- Judge sources: `hermes_glm=2251`, `hermes_ark_standard=2249`
- Final merge summary: `remaining_to_fix=0`, `wrong_source=0`, `retry3_rejected=0`
- Final prepare status: `trainable_v0_ready`
- Final prepare counts: `row_count=4956`, `train_eligible_count=4556`, `dev_selection_count=400`, `test.jsonl=128`
- Final prepare gates: `generator_orchestration.status=pass`, `validator_summary.layer2_semantic_status=pass`, `lineage_summary.candidate_semantic_reassignment_status=pass`, `failure_receipt=[]`
- Candidate semantic parent recomputation: action rows `4500`, unique candidate parents `4382`, multi-record candidate parent groups `86`, maximum group size `6`; generated-record parent IDs are not trusted as gate authority.
- Train/valid/test user protocol leakage check: `0` in all splits.

## Hermes Operating Note

Hermes batch calls were reliable only when treated as a parallel long-tail system. Short 240s timeouts produced false missing judge gaps; the same missing items completed with 1500s timeout and per-job retry. Missing/parse gaps were retried as judge gaps, while true semantic rejects were regenerated and judged again. This distinction is required for future C5 data work.

## Verification Commands

```bash
swift run C5TrainingCLI prepare --output-dir Reports/c5-remediation-wave-20260621T2013-pr3-full/prepare-final-v3 --target-positive 4500 --dev-selection 400 --masking-stage trainable_v0 --generated-utterances Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl
swift test --filter C5LoRATrainingTests
swift test --filter C5DataGateTests
swift test
openspec validate define-lora-training --strict
openspec validate --all --strict
```

Verification result: all commands above passed on 2026-06-21.
