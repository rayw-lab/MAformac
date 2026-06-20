## Context

C1/C2/C3/C6 are archived. C6 now preserves case identity and marks demo must-pass / gold cases as `must_not_train`; C3 owns runtime tool execution and readback; C5 must only decide whether candidate LoRA data can enter the training lane. The old `_parked/define-lora-pipeline` included useful concepts, but also included training and adapter work that is out of scope for this change.

Pre-mortem inputs:
- Local scout: `openspec/specs/vehicle-tool-bench/spec.md` requires C5 to exclude C6 `must_not_train` cases and report violations; `_parked/define-lora-pipeline/design.md` already identified receipt, masking, split hygiene, and `must_not_train` gates.
- Local scout: `docs/research/2026-06-20-eval-memory-deepdive-synthesis.md` locks C5 as receipt/split/masking before training.
- Oracle check: tau2-bench documents train/test/base split discipline for evaluation versus training; Hammer documents function masking for on-device function calling. These support the split hygiene and masking gates without importing their runtime.

## Goals / Non-Goals

**Goals:**
- Create a C5-only data gate that produces repeatable receipt evidence before P1-C LoRA train.
- Fail closed on C6 must-pass/gold leakage, parent semantic overlap into train, format drift, redaction issues, and unclear source authorization.
- Keep raw source read-only and store only hashes, counts, and violation metadata in repo reports.

**Non-Goals:**
- No LoRA training, adapter generation, model download, or MLX/unsloth training entry.
- No data auto-repair or auto-augmentation.
- No C3/C6 runtime changes and no edits to archived specs.
- No real car control, ASR, TTS, iOS runtime, or network dependency.

## Decisions

### Decision 1: Receipt-first validator, not generator

The implementation validates candidate JSONL and emits receipt JSON/Markdown. It does not synthesize training data. This keeps P1-A focused on the gate and prevents an empty or toy generator from being mistaken for real training readiness.

Alternative considered: resurrect `_parked/define-lora-pipeline` as a full data pipeline. Rejected because it includes training tasks and predates current C3/C6 archived contracts.

### Decision 2: Candidate schema is minimal but explicit

Each candidate row carries stable data-gate fields:

```json
{
  "sample_id": "C5-SAMPLE-001",
  "split": "train",
  "bucket": "tool_call_wrapper_format",
  "source_id": "abstract-source",
  "source_authorization": "authorized",
  "case_id": "optional-c6-case",
  "parent_semantic_id": "c1_airControl_000006",
  "must_not_train": false,
  "input_zh": "打开空调",
  "tool_call": {"wrapper": "tool_call", "name": "set_cabin_ac", "arguments": {"power": "on"}},
  "masking": {"function_name": true, "argument_name": true, "argument_value": true, "train_on_turn": true}
}
```

Rows missing required gate metadata are quarantined or fail the run. This is intentionally stricter than raw data shape because the validator is the border before training.

### Decision 3: C6 protected identity set is the hard train ban

The protected set is loaded from `contracts/c6-bench-cases.jsonl`. A case is protected if `tags.must_pass=true`, `tags.must_not_train=true`, or it has deterministic gold expectations. A train row matching `case_id` or `parent_semantic_id` from this set fails `must_not_train_violations`.

### Decision 4: Parent semantic overlap uses parent IDs, not string dedupe

The gate compares `parent_semantic_id` across train and protected buckets. String-level utterance dedupe is insufficient because paraphrases can leak the same semantic family into train and eval.

### Decision 5: Format version is the hash of the shared contract

`format_contract_version` is derived from `contracts/qwen-tool-call-format.yaml`; the validator does not copy the runtime wrapper contract. This aligns C5 with C3/C6 and prevents train/runtime/bench format drift.

### Decision 6: Status vocabulary stays scoped

Receipt status uses `data_gate_ready`, `t_pass`, or `blocked`. Closeout may map these to `V-PASS`, `T-PASS`, or `BLOCKED`, but no C5 artifact may claim `train_ready`.

## Risks / Trade-offs

- [C6 gold leaks into train] -> Mitigation: protected case IDs and protected parent semantics are train-blocking hard gates.
- [Overlap check becomes naive string dedupe] -> Mitigation: `parent_semantic_id` is required for train and protected rows; missing train parent metadata is a failure.
- [Raw source leaks into repo] -> Mitigation: reports store only digest/counts/violation IDs; candidate JSONL stays external or fixture-only.
- [Receipt counts but does not block] -> Mitigation: validator exits non-zero when train-blocking counts are non-zero.
- [C5 gets mislabeled as LoRA ready] -> Mitigation: spec/proposal/closeout use data gate wording and keep P1-C blocked until P1-A plus P1-B pass.
- [Hermes audit unavailable] -> Mitigation: final state is capped at `T-PASS` with exact CLI error.

## Migration Plan

1. Add `lora-data-gate` OpenSpec artifacts.
2. Add the local validator and tests.
3. Generate fixture receipt and, if an authorized raw candidate path exists, an external-source receipt.
4. Run OpenSpec and Swift tests.
5. Run Hermes Ark Code audit, fix P0/P1/Important, and rerun gates.

Rollback is a normal git revert of this change; no model, adapter, or raw source is mutated.

## Open Questions

- The authorized production C5 candidate JSONL path is not yet a committed repo artifact. Until that path is explicit and non-empty, downstream LoRA train remains blocked even if the validator itself passes on fixtures.
