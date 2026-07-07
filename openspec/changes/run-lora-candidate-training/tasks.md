> **Historical status note 2026-07-05**: checked PR5 work below is prior evidence, not current formal-1800 launch proof. Current formal-1800 run-auth was accepted, but launch did not start: host gate HOLD, no trainer pid, no watchdog arm, and candidate remains unsigned.

## 1. 5a Change Chain And Preconditions

- [x] 1.1 Verify `define-lora-training` is archived and `openspec/specs/lora-training/spec.md` is the active method contract. Verification: `openspec list --json` no longer lists `define-lora-training`, archive path exists, and `openspec validate --all --strict` passes.
- [x] 1.2 Validate `run-lora-candidate-training` artifacts. Verification: `openspec validate run-lora-candidate-training --strict` and `openspec validate --all --strict` pass.
- [x] 1.3 Add PR5 5a subagent audit report and INDEX row. Verification: `Reports/c5-pr2pr4pr5-20260621T235213/audits/codex-audit-pr5-5a-change-chain-r1.md` exists and `audits/INDEX.md` references it.

## 2. 5b Candidate Training Preconditions And Code Gates

- [x] 2.1 Resolve scale authority in code. Verification: first-candidate rank16 MLX config renders `scale=20`, focused tests assert 20, and `scale=32` is documented only as deferred A/B.
- [x] 2.2 Implement PR5 preflight gate for the PR3 final-v3 offset artifact. Verification: formal training blocks unless `offset_fixture.status=pass` and token artifact digest equals `c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9`, unless a regenerated same-path artifact is explicitly recorded.
- [x] 2.3 Implement verified repo-loop source gate for PR5 formal training. Verification: preflight records source state, script SHA, verification refs, and blocks on missing/mismatched marker.
- [x] 2.4 Implement candidate data-quality gate fields. Verification: receipt records per-seed variant cap status, diversity/near-neighbor status, ambiguous duplicate count, lineage/parent overlap, and epoch-exposure summary; blocking cases fail closed.
- [x] 2.5 Run focused tests for scale, offset gate, source-state gate, and data-quality gate failures. Verification: tests fail closed for scale mismatch, digest mismatch, missing marker, cap/diversity failure, and ambiguous duplicate.
- [x] 2.6 Run formal candidate training with PR3 final-v3 data and PR2 verified repo loop. Verification: training receipt records `scale=20`, verified loop SHA, clip metrics, nonfinite checks, environment, source snapshot, metrics/log paths, checkpoint policy, and adapter/checkpoint digest.
- [x] 2.7 Add PR5 5b subagent audit report and INDEX row. Verification: `codex-audit-pr5-5b-candidate-training-r1.md` found stale method-contract authority and remained FAIL; fixes were applied, `codex-audit-pr5-5b-candidate-training-r2.md` returned PASS_WITH_NOTES, the P3 negative-test gap was fixed, and INDEX references both rounds.

## 3. 5c C6 Evaluation And Diagnostics

- [x] 3.1 Build or invoke C6 base-vs-LoRA evaluation under the same harness. Verification: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/c6-eval-receipt.json` links base and LoRA run IDs, the shared C6 cases digest, the C6/SpikeE3 result digests, the tool-call-format digest, and the active contract digest.
- [x] 3.2 Record replay fingerprints. Verification: the 5c receipt records model, tokenizer, adapter, adapter-config normalization, SpikeE3 runner source, base/LoRA results, summary digests, and contract/tool-format digests; the candidate remains blocked because the replay produced a LoRA action-collapse hard fail.
- [ ] 3.3 Implement heldout/OOD diagnostic axes with leakage and near-neighbor checks. Verification: the 5c receipt records all-C6, heldout, vehicle-action-positive, OOD no-call, trap, and coverage-ambiguous axes plus exact input overlap and lineage overlap, but semantic near-neighbor proof remains a residual gate (`exact_input_no_overlap_only_not_semantic_near_neighbor_proof`) and is not complete.
- [x] 3.4 Keep checkpoint selection separate from C6 release. Verification: candidate training selected the final checkpoint from training/dev evidence only, while C6 was run once as final release evaluation and recorded `C6_HARD_FAIL_BLOCKED`, so no checkpoint was promoted from C6 results.
- [x] 3.5 Add PR5 5c subagent audit report and INDEX row. Verification: `codex-audit-pr5-5c-c6-eval-r1.md` found the 3.3 over-check and replay-fingerprint gap, fixes were applied, `codex-audit-pr5-5c-c6-eval-r2.md` passed, and INDEX references both rounds.

## 4. 5d Parity, V-PASS Split, And Final Audit

- [ ] 4.1 Run dynamic adapter vs fused bf16 vs fused quantized/endpoint parity. Verification: receipt records ToolCallExact delta, IrrelAcc delta, must-pass regression count, parse failures, and negative false-call delta for the same sample sets.
- [ ] 4.2 Run endpoint tokenizer byte-parity check. Verification: receipt records training render bytes digest, endpoint render bytes digest, render source (`patched_tokenizer` or `explicit_enable_thinking_false`), and exact-match status.
- [x] 4.3 Record two-layer V-PASS status. Verification: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5d-parity-vpass/parity-vpass-receipt.json` records model-quality V-PASS and physical endpoint V-PASS as separate blocked fields; `xcrun xctrace list devices` observed no target physical iOS device, and simulator evidence is explicitly insufficient.
- [x] 4.4 Run PR5 5d subagent audit and fix findings. Verification: `codex-audit-pr5-5d-parity-vpass-r1.md` passed with no findings, confirmed 4.1/4.2 remain open-blocked and 4.3 is correctly recorded-blocked, and INDEX references it.
- [x] 4.5 Run GPT Pro heterogeneous final audit before candidate signing. Verification: `Reports/c5-pr2pr4pr5-20260621T235213/audits/gptpro-final-audit.md` exists with `PASS_FOR_BLOCKED_CLOSEOUT`, explicitly keeps candidate signing `UNSIGNED / BLOCKED`, and does not sign model-quality or endpoint V-PASS.

## 5. Verification And Closeout

- [x] 5.1 Run full local verification. Verification: final run passed `openspec validate run-lora-candidate-training --strict`, `openspec validate --all --strict` (9 passed, 0 failed), `git diff --check`, `swift build --product spike-e3 -c release`, and `swift test` (112 passed, 3 skipped, 0 failures).
- [x] 5.2 Produce PR5 closeout. Verification: `Reports/c5-pr2pr4pr5-20260621T235213/final-closeout.md` cites candidate training receipt, C6 eval, diagnostics, parity/V-PASS split, audit INDEX, GPT Pro audit, failure receipts, and required next gates; `docs/handoffs/2026-06-22-c5-pr2-pr4-pr5-superdispatch-closeout.md` points future agents to the same evidence.
- [x] 5.3 Run redline and git hygiene checks. Verification: staged-only checks found no `*.safetensors`/model weights, no `mlx-data/` or `samples/` training JSONL, and no >1MB staged files; keyword hits were limited to audit path references and existing boundary-policy notes, not raw customer source text, PII, secrets, or pricing/cost material. `Tools/C5TrainingCLI/c5_mlx_train_loop.py` and `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json` are staged for durability.
