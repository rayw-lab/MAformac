# Codex Audit PR5 5c C6 Eval R1
Verdict: PASS_WITH_NOTES

## Scope

Audit only PR5 5c C6 Evaluation And Diagnostics. No code, task, or INDEX changes were made.

Questions checked:
- Same-harness base-vs-LoRA C6 evaluation.
- Replay fingerprint sufficiency.
- Diagnostic honesty for tool-surface mismatch, positive action collapse, and near-neighbor limitation.
- `tasks.md` 3.1-3.4 checkbox support.
- Candidate/V-PASS overclaim risk.
- SpikeE3 LoRA adapter-config normalization evidence chain.

## Evidence Checked

- `/Users/wanglei/workspace/MAformac/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac/docs/lessons-learned.md` section B recent entries, especially B45
- `/Users/wanglei/workspace/MAformac/openspec/changes/run-lora-candidate-training/tasks.md` section 3
- `/Users/wanglei/workspace/MAformac/openspec/changes/run-lora-candidate-training/design.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/run-lora-candidate-training/specs/lora-training/spec.md`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/c6-eval-receipt.json`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/evidence-summary.md`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-base-full-summary/c6-summary.json`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-lora-full-summary/c6-summary.json`
- `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-training/c5-training-run-receipt.json`
- `/Users/wanglei/workspace/MAformac/dev/spike-e3/Sources/SpikeE3/main.swift`

Key digest checks:
- C6 receipt: `35484639cf0eb4c49742ada879ac8f434e7ee1dc81ab38e8769d0d6113584119`
- base SpikeE3 results: `ab9e1a0579db04fe5218aed4adccba2003cb912db7b526ed655c554edd4f8701`
- LoRA SpikeE3 results: `6f5cfd6c3ddfc9589fdfe619db3499adbc25fe938ff0ef4f4c0bb331a1c2e31e`
- base C6 summary: `be480475d4a10d80a953527ec6f4f1df68b1740957119504108ce30dc677528c`
- LoRA C6 summary: `f804015ab1f360874cdfadd8cc902b7041d88c407bb40a48efc08e43b9147a66`
- SpikeE3 source: `ff6a068978a6201a210115c7dba46ade8d5a3e66f4226a36b43e2ecff1afd908`
- C6 cases: `efafb06cbfdfd50656678cd0aa61e22836e4d25ffc73ac70db8ed0a265d52bea`
- Qwen tool-call format: `630281ed49f2acb7a04a1823909fd907031b7ba29d606e88f326c1e0bb93d53b`
- active lora-training spec: `018ce75047ef16647179d781525dcfe837e4f0c5576542a202b59c6fb63b4639`

## Findings

### P0

None.

### P1

1. `tasks.md` 3.3 is over-checked if "near-neighbor checks" means semantic near-neighbor proof.
   - Evidence: the 5c receipt records diagnostic axes, `exact_input_overlap_count=0`, and `train_parent_overlap_from_prepare_receipt=0`, but its own near-neighbor field is `exact_input_no_overlap_only_not_semantic_near_neighbor_proof`.
   - The change spec says heldout/OOD diagnostics must record lineage or near-neighbor evidence that prevents train-neighbor cases from being counted as generalization evidence. The current receipt is honest that semantic near-neighbor proof is still residual.
   - This is not a candidate-signing overclaim because the receipt also records `C6_HARD_FAIL_BLOCKED` and leaves `heldout_near_neighbor_semantic_check_stronger_than_exact_match` in residual gates. It is still not enough to justify 3.3 as fully done.

### P2

1. Replay fingerprints are strong for run identity but incomplete for adapter normalization byte identity.
   - Present: model ID, model digest, tokenizer digest, cases digest, tool-format digest, contract digest, SpikeE3 source digest, base/LoRA result digests, summary digests, adapter digest, and normalization status/path.
   - Missing from the 5c receipt: normalized adapter config path plus sha256, original adapter config path plus sha256, normalized weights symlink target/digest, and preferably the exact SpikeE3 command line plus `Package.swift`/`Package.resolved` digests.
   - Observed values that should be receipt-amended: normalized config path `/Users/wanglei/workspace/MAformac/Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-lora-full/normalized-lora-adapter/adapter_config.json`, normalized config sha256 `d230d0fb1f6c606bd402514bb83e8f1d7c7b660a5be8a5ed75e3cda26a6f503a`; original adapter config sha256 `f025da20d5b9338356271183dfbf25e628274a68bf85bcd5a9e4bed520f8d592`; adapter weights sha256 `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`.

2. SpikeE3 adapter-config normalization has implementation and run evidence, but no focused test evidence in the audited inputs.
   - Evidence: `main.swift` normalizes `num_layers < 0` to `loraModel.loraLayers.count`, writes `normalized-lora-adapter/adapter_config.json`, and symlinks `adapters.safetensors`.
   - Run evidence: the LoRA result envelope and 5c receipt record `originalNumLayers=-1`, `normalizedNumLayers=28`, and `status=normalized`; the normalized config on disk has `num_layers=28`.
   - Recommended follow-up: add a focused fixture/test or a smoke receipt field proving this branch fails closed without normalization and loads through the normalized directory with the expected config digest.

### P3

None.

## Task Checkbox Verdict

- 3.1: OK. Base and LoRA runs share the same C6 case sequence and prompt hashes; both use `model_id=mlx-community/Qwen3-1.7B-4bit`, `requested/resolved_tool_call_format=json`, the same tokenizer digest, tool-format digest, contract digest, and SpikeE3 source digest. LoRA only adds the adapter and normalization path.
- 3.2: OK_WITH_NOTES. The receipt records enough to identify the replay and blocks the candidate, but it should add normalized adapter-config digest/path and exact invocation/build dependency digests.
- 3.3: NOT OK. Diagnostic axes are recorded honestly, but semantic near-neighbor proof is explicitly absent and left as a residual gate. If 3.3 remains checked, it overstates completion of the near-neighbor part.
- 3.4: OK. The training receipt selects checkpoint `iter600` by dev validation loss only (`dev_selection_val_loss_then_C6_final_only; no C6 release cases used for checkpoint selection`), while the 5c receipt records `C6_HARD_FAIL_BLOCKED` and does not promote the candidate.

## Residual Risks

- The LoRA run improves negative no-call behavior and IrrelAcc but collapses positive action matching: `positive_expected_tool_hits=0/34` in the 5c receipt, and LoRA observed tool names are only `tool_call`.
- Tool-surface mismatch is the dominant blocker: training target uses `tool_call_frame`, C6 expects `set_cabin_*` / `query_cabin_comfort`, and the intersection is empty.
- LoRA latency regresses materially: average elapsed moves from about `575 ms` base to about `2033 ms` LoRA.
- Dynamic-vs-fused-vs-quantized parity and endpoint tokenizer byte parity were not run, correctly blocked after C6 hard fail.
- Physical endpoint V-PASS is not evaluated and remains blocked.

## Required Fixes Before Main Proceeds

1. Do not treat `tasks.md` 3.3 as fully complete until either:
   - a semantic near-neighbor or equivalent case-level lineage check is run and receipted with method, threshold, source train digest, heldout/OOD case digest, result path, and result digest; or
   - 3.3 is downgraded/split so the semantic near-neighbor proof remains explicitly pending.
2. Amend the 5c replay receipt with normalized adapter-config path/digest, original adapter-config path/digest, symlink target or normalized adapter weights digest, and exact SpikeE3 invocation/build dependency digests.
3. Keep candidate signing blocked. The current evidence supports only "LoRA loaded and evaluated, then failed C6 due to tool-surface mismatch/action collapse"; it does not support model-quality V-PASS, endpoint V-PASS, or candidate readiness.

Subagent audit complete.
