# Handoff 2026-06-20 — P1-A C5 data gate closeout

state=V-PASS
branch=codex/p1-a-c5-data-gate
head_before=883f1af4e34635f0c058ede45febe8b5b8cebe30
head_after=883f1af4e34635f0c058ede45febe8b5b8cebe30
change_id=define-lora-data-gate

## Scope

Only C5 data gate was implemented: OpenSpec change, validator, receipt, report, Hermes audit, and closeout. No LoRA training, no adapter generation, no model download, no train-ready claim.

## Prerequisite Check

Full exact output is saved at `Reports/c5-data-gate-20260620-192100/prerequisite-check.txt`.

Key lines:

```text
git status --short --branch -> ## codex/p0-2-c6-model-fingerprint...origin/codex/p0-2-c6-model-fingerprint
git rev-parse HEAD -> 883f1af4e34635f0c058ede45febe8b5b8cebe30
git rev-parse --abbrev-ref HEAD -> codex/p0-2-c6-model-fingerprint
openspec list -> _parked only
openspec validate --all --strict -> 6 passed, 0 failed
required files present -> vehicle-tool-bench spec, tool-execution spec, qwen-tool-call-format.yaml
raw source path present -> /Users/wanglei/workspace/raw/05-Projects/MAformac
```

The first status also showed pre-existing untracked dispatch files. The C5 report directory was created by this run. Later, the active branch was externally switched to `codex/p1-b-qwen35-2b-spike`; C5 work was switched back to `codex/p1-a-c5-data-gate` before closeout. The unrelated `Reports/qwen35-2b-spike-20260620-192146/` directory was not touched.

## Receipt

Receipt files:
- `Reports/c5-data-gate-20260620-192100/c5-data-gate-receipt.json`
- `Reports/c5-data-gate-20260620-192100/c5-data-gate-receipt.md`

Formal raw split inputs only:
- `datasets/train/train.jsonl`
- `datasets/heldout/heldout.jsonl`
- `datasets/negative/negative.jsonl`
- `datasets/acceptance/acceptance.jsonl`
- `datasets/future/future.jsonl`

`datasets/stage_a/migrated-40.jsonl` was intentionally excluded because it is an intermediate migration file, not a formal split. An earlier exploratory run that included it produced `train_parent_semantic_overlap=2`; the final receipt uses only formal split files.

Receipt summary:

```yaml
status: data_gate_ready
row_count: 3670
bucket_counts:
  train: 2320
  heldout: 1200
  must_pass: 30
  quarantine: 120
must_not_train_violations: 0
detected_parent_semantic_overlap_count: 0
train_parent_semantic_overlap: 0
tool_call_format_pass: 2320
tool_call_format_failures: 0
quarantine_count: 120
redaction_status: pass
source_snapshot_digest: 4f364b3f95f321f806f62dbc4699ac6ef9352518a033c29e0cea7a27719df94e
source_authorization_status: authorized_existing_raw_closeout
format_contract_version: 630281ed49f2acb7a04a1823909fd907031b7ba29d606e88f326c1e0bb93d53b
proposed_fix:
  auto_apply: false
```

## Hermes Audit

Hermes command used Ark Code route: `--model code --provider custom:ark-code`.

Audit result saved at `Reports/c5-data-gate-20260620-192100/hermes-audit.md`.

Hermes findings:
- P0: none
- P1: none
- Important: masking coverage is all false in the receipt and must be stated honestly.
- Nit: closeout/tasks were not complete at audit time.

Disposition:
- Important accepted as a truthful residual, not patched into false positives. The data gate records masking coverage; it does not synthesize Hammer/GOAT masking rows. Therefore `masking_coverage=false` is not rewritten to true. P1-C must not treat this C5 receipt as proof that masking data generation is complete.
- Nit resolved by this closeout and task updates.

## Verification

Final rerun after Hermes:

```yaml
openspec validate define-lora-data-gate --strict: pass
openspec validate --all --strict: pass, 7 passed, 0 failed
C5DataGateCLI formal raw splits: pass, status=data_gate_ready
swift test: pass, 85 tests, 3 skipped, 0 failures
make verify: pass
hermes full audit: pass, P0=0, P1=0, Important handled by documented disposition
```

Command logs:
- `Reports/c5-data-gate-20260620-192100/acceptance-before-hermes.txt`
- `Reports/c5-data-gate-20260620-192100/acceptance-after-hermes.txt`
- `Reports/c5-data-gate-20260620-192100/c5-data-gate-cli-formal-splits-v2.txt`

## Boundary Notes

- Raw source remained read-only. Repo report stores digest/counts/violation metadata only.
- C6 must-pass/gold protected set did not enter train.
- `data_gate_ready` is a scoped C5 receipt status. It is not `train_ready`.
- P1-C LoRA train remains blocked until P1-B Qwen spike passes and downstream training data generation explicitly handles missing masking coverage.
