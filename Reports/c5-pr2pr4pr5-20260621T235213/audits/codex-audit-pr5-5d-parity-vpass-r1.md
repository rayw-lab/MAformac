# Codex Audit PR5 5d Parity V-PASS R1
Verdict: PASS

## Scope

Independent read-only audit of PR5 5d parity, endpoint byte parity, V-PASS split, and final-audit readiness evidence. This audit did not modify code, `tasks.md`, `docs/research/INDEX.md`, or the audit `INDEX.md`; it only writes this report.

Questions checked:
- Whether 5d correctly keeps dynamic/fused/quantized parity and endpoint tokenizer byte parity open-blocked after the C6 hard fail.
- Whether model-quality V-PASS and physical endpoint V-PASS are separated, with no Mac/simulator evidence substituted for a target physical endpoint.
- Whether the 5d receipt accurately references the C6 blocker, candidate training receipts, device probe, failure receipts, JSON paths, and hashes.
- Whether any candidate/V-PASS overclaim or same-source-audit-as-GPT-Pro overclaim remains.
- Whether main can proceed to GPT Pro final audit/closeout, while preserving all remaining blockers before candidate signing.

## Evidence Checked

- `/Users/wanglei/workspace/MAformac/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac/docs/lessons-learned.md` recent B45-B47
- `/Users/wanglei/workspace/MAformac/openspec/changes/run-lora-candidate-training/tasks.md` section 4
- `/Users/wanglei/workspace/MAformac/openspec/changes/run-lora-candidate-training/specs/lora-training/spec.md` Candidate parity, V-PASS, and GPT Pro audit requirements
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5d-parity-vpass/parity-vpass-receipt.json`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5d-parity-vpass/evidence-summary.md`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/c6-eval-receipt.json`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr5-5c-c6-eval-r2.md`

Validation performed:
- `jq -e` passed for the 5d parity/V-PASS receipt, 5c C6 eval receipt, 5b candidate training receipt, and 5b candidate prepare receipt.
- `shasum -a 256` matched the 5d receipt for the upstream C6 receipt (`2167fa80f9839bc55da226df4f723f3e319f2ae7aeb7b757c025c1a65bcefd4e`), 5b training receipt (`6ef33358a48ee060be4abf726d585bb4a5865995f8d3da55f68f4b8854fa3f56`), and 5b prepare receipt (`4b9221774e983a93888f9ab054cc866875b63d2014f4e8b35ac89cd15d90df8e`).
- `xcrun xctrace list devices` was rerun during this audit and observed only `王磊的MacBook Pro` as a physical device.
- `xcrun simctl list devices available` was rerun during this audit and showed available iPhone/iPad entries are simulators only.

## Findings（P0/P1/P2/P3；没有就 None）

None.

## Task Checkbox Verdict（4.1-4.4）

- 4.1: OK_OPEN_BLOCKED. Correctly unchecked. The receipt records `dynamic_fused_quantized_parity.status=blocked_not_run`, null deltas, and `blocking_gate=c6_eval_verdict=C6_HARD_FAIL_BLOCKED`; it does not claim parity completion.
- 4.2: OK_OPEN_BLOCKED. Correctly unchecked. The receipt records `endpoint_tokenizer_byte_parity.status=blocked_not_run`, null training/endpoint render digests, `exact_match_status=not_evaluated`, and both C6 hard fail plus missing target physical device as blockers.
- 4.3: OK. Correctly checked for recording the split, not for passing V-PASS. `model_quality_vpass.status=blocked` is separated from `physical_endpoint_vpass.status=blocked`; the latter cites no target physical iOS device and marks simulator evidence insufficient. Current live device probes match that record.
- 4.4: OK_TO_MARK_COMPLETE_AFTER_THIS_REPORT_AND_INDEX_ROW. This R1 audit found no required fixes in the 5d evidence. Main may update the audit INDEX and task state for 4.4, but must not mark 4.1, 4.2, 4.5, candidate signing, or endpoint readiness complete.

## Required Fixes Before Main Proceeds

None for 5d. Main can proceed to GPT Pro final audit/closeout from the 5d audit perspective.

Required before any candidate signing remains unchanged:
- Fix the training/eval tool-surface mismatch and rerun C6.
- Complete semantic near-neighbor proof before claiming heldout/OOD generalization.
- Run dynamic/fused/quantized parity only after C6 model-quality gates pass.
- Run endpoint tokenizer byte parity on a target physical device only after model-quality gates pass.
- Obtain a GPT Pro heterogeneous final audit PASS; same-source Codex audits alone remain insufficient for signing.

Subagent audit complete.
