## 1. OpenSpec artifacts

- [x] 1.1 Create `lora-data-gate` spec with receipt, split, format, redaction, overlap, and training禁入 requirements.
- [x] 1.2 Create design that reuses only safe concepts from `_parked/define-lora-pipeline` and explicitly excludes training/adapter work.

## 2. Data gate implementation

- [x] 2.1 Add a minimal validator that reads candidate JSONL, C6 protected cases, and `contracts/qwen-tool-call-format.yaml`.
- [x] 2.2 Emit receipt JSON and Markdown with source snapshot digest, authorization, row counts, bucket counts, split whitelist, format result, masking coverage, redaction status, quarantine count, failure receipt, and `proposed_fix.auto_apply=false`.
- [x] 2.3 Fail closed when C6 must-pass/gold/must-not-train enters train, train/protected parent semantic overlap remains in train, train format fails, redaction fails, or source metadata is missing.
- [x] 2.4 Add fixture candidates for a clean batch and deliberate failure cases.

## 3. Verification

- [x] 3.1 Add tests for clean receipt, C6 must-pass in train failure, parent semantic overlap failure, and bare JSON format failure.
- [x] 3.2 Run `openspec validate define-lora-data-gate --strict`.
- [x] 3.3 Run `openspec validate --all --strict`.
- [x] 3.4 Run `swift test`.
- [x] 3.5 Run `make verify` if scripts/contracts/build files are changed.

## 4. Evidence, audit, and closeout

- [x] 4.1 Save prerequisite check, receipt outputs, and command logs under `Reports/c5-data-gate-<timestamp>/`.
- [x] 4.2 Run Hermes Ark Code audit with `--model code --provider custom:ark-code` and save the result.
- [x] 4.3 Fix every Hermes P0/P1/Important issue or document evidence for non-adoption.
- [x] 4.4 Rerun acceptance gates after fixes.
- [x] 4.5 Write `docs/handoffs/<date>-p1-a-c5-data-gate-closeout.md` with honest `state=V-PASS`, `state=T-PASS`, or `state=BLOCKED`.
