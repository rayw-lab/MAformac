# Codex Audit PR5 5c C6 Eval R2
Verdict: PASS

## Scope

Independent R2 review of whether the PR5 5c R1 findings were fixed. This audit only reviewed evidence and wrote this report. No code, `tasks.md`, or `docs/research/INDEX.md` changes were made.

Questions checked:
- R1 P1: whether `tasks.md` 3.3 is no longer checked as complete while semantic near-neighbor proof remains residual.
- R1 P2: whether the 5c receipt now records adapter normalization byte identity and build/invocation replay fingerprints.
- Whether candidate, model-quality V-PASS, endpoint V-PASS, parity, or signing are still blocked by C6 hard fail.
- Whether `tasks.md` 3.1, 3.2, 3.4 remain supported and 3.3 is correctly open.
- Whether the changed JSON/receipt/summary evidence is syntactically valid and materially consistent.

## Evidence Checked

- `/Users/wanglei/workspace/MAformac/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac/docs/lessons-learned.md` recent B45-B47
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr5-5c-c6-eval-r1.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/run-lora-candidate-training/tasks.md` section 3
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/c6-eval-receipt.json`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/evidence-summary.md`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-base-full-summary/c6-summary.json`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-lora-full-summary/c6-summary.json`
- On-disk adapter normalization files and package fingerprints referenced by the receipt.

Validation performed:
- `jq -e` passed for the 5c receipt and both base/LoRA C6 summary JSON files.
- `shasum -a 256` matched the receipt for normalized adapter config, original adapter config, normalized adapter weights symlink target content, root `Package.swift`, SpikeE3 `Package.swift`, and SpikeE3 `Package.resolved`.
- `readlink` confirmed the normalized `adapters.safetensors` path points to the original 5b adapter weights path recorded in the receipt.

## R1 Fix Verification

R1 P1 is fixed.
- `tasks.md` 3.3 is now unchecked.
- Its verification text explicitly says semantic near-neighbor proof remains a residual gate: `exact_input_no_overlap_only_not_semantic_near_neighbor_proof`.
- The receipt also records `near_neighbor_status=exact_input_no_overlap_only_not_semantic_near_neighbor_proof` and keeps `heldout_near_neighbor_semantic_check_stronger_than_exact_match` in `residual_gates`.
- This satisfies the R1 requirement because the task no longer claims the incomplete semantic near-neighbor proof is done.

R1 P2 is fixed.
- The receipt now includes normalized adapter config path and SHA-256, original adapter config path and SHA-256, effective adapter weights path and SHA-256, and the symlink target.
- On disk, normalized `adapter_config.json` has `num_layers=28`; original `adapter_config.json` has `num_layers=-1`.
- The normalized weights digest and original weights digest both match `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`, and the normalized weights file is a symlink to the recorded original path.
- The receipt now records root and SpikeE3 package digests, root `Package.resolved` absence, SpikeE3 `Package.resolved` digest, build commands, and exact base/LoRA SpikeE3 invocations.

No candidate or V-PASS overclaim remains.
- Receipt top-level verdict is `C6_HARD_FAIL_BLOCKED`.
- `candidate_signing_status` is `not_signed_c6_hard_fail_tool_surface_mismatch`.
- `model_quality_vpass` is `blocked`; `physical_endpoint_vpass` is `blocked_not_evaluated`.
- Residual gates explicitly block parity and endpoint byte-parity because C6 failed.
- Evidence summary states the candidate is blocked before parity or endpoint V-PASS and does not sign candidate readiness.

## Findings (P0/P1/P2/P3; None if empty)

P0: None.

P1: None.

P2: None.

P3: None.

## Task Checkbox Verdict (3.1-3.4)

- 3.1: OK. Same-harness base-vs-LoRA evaluation remains supported by shared C6 cases digest, same model/tokenizer/tool-format/contract identity, and linked base/LoRA run and summary digests.
- 3.2: OK. Replay fingerprints now include the R1-requested adapter normalization byte identity plus build/invocation/package fingerprints.
- 3.3: OK_OPEN. Correctly unchecked. Diagnostic axes and exact/lineage overlap checks are recorded, while semantic near-neighbor proof remains explicitly incomplete and residual.
- 3.4: OK. C6 is recorded as final release evaluation after checkpoint selection, and the hard fail prevents promotion/signing.

## Required Fixes Before Main Proceeds

None for the R1 fix scope. Main can proceed to 5d blocked/V-PASS split recording, while preserving the recorded C6 hard fail and the open semantic near-neighbor residual gate.

Subagent audit complete.
