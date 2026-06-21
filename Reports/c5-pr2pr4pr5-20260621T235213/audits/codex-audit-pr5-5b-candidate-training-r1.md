# PR5 5b Candidate Training Audit

Verdict: FAIL

## Findings

- P0: none.

- P1: PR5 5b receipts do not satisfy the archived training-method authority contract. `openspec/changes/run-lora-candidate-training/specs/lora-training/spec.md:3-16` requires every PR5 receipt to record `openspec/specs/lora-training/spec.md` as the active method spec, record the archived `define-lora-training` change path, and not depend on the old active change directory. The clean prepare receipt instead records `openspec/changes/define-lora-training/specs/lora-training/spec.md:3-164` in `source_refs` (`Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/c5-training-receipt.json:619-623`), and the current code hard-codes that stale path at `Core/Training/C5LoRATraining.swift:2023`. `rg` found no `openspec/specs/lora-training` or `archive/2026-06-21-define-lora-training` reference in the PR5 5b prepare/training receipts. This does not invalidate the observed training-health run, but it blocks PR5 5b contract pass until the receipt authority fields are corrected and regenerated or an explicit amended receipt is added before later candidate claims.

- P2: none.

- P3: Task 2.7 is correctly still open. This subagent was explicitly allowed to write only this audit report, so `audits/INDEX.md` remains for the main agent to update.

## Checks Run

- `git status --short --branch`: current branch `main...origin/main`; relevant files are dirty/uncommitted as expected for the candidate (`Core/Training/C5LoRATraining.swift`, `Tools/C5TrainingCLI/main.swift`, `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`, report artifacts, and `openspec/changes/run-lora-candidate-training/`).
- `openspec list --json`: `run-lora-candidate-training` is in progress with 9/23 tasks complete; `define-lora-data-gate` is complete; `define-lora-training` is not active.
- `openspec validate run-lora-candidate-training --strict`: pass.
- `openspec validate --all --strict`: pass, 9 items, 0 failed.
- `swift test --filter C5LoRATrainingTests`: pass, 22 tests, 0 failures.
- Task 2.1 evidence: `C5MLXLoRAConfig.rank16Mainline()` renders `scale=20`; tests assert scale 20 and fail closed for legacy 32; clean prepare and training run receipts record scale 20.
- Task 2.2 evidence: offset authority requires final-v3 digest or regenerated same-path artifact; clean prepare receipt records `status=pass`, `authority_mode=regenerated_same_path`, observed SHA `780e8258...`, and approved final-v3 SHA `c71ffb...`; mismatch test fails closed.
- Task 2.3 evidence: `Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json` marks the loop verified; current script SHA is `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`; unverified-source focused test fails closed.
- Task 2.4 evidence: first PR5 prepare blocked on `ambiguous_duplicate_count=40`; clean prepare records `candidate_data_quality_gate.status=pass`, ambiguous duplicates `0`, cap pass, diversity pass, parent overlap `0`, max observed variants per seed `7`.
- Task 2.5 evidence: focused tests cover scale mismatch, offset digest mismatch, unverified source marker, diversity/cap failure, and ambiguous duplicate failure.
- Task 2.6 evidence: formal training receipt records `status=train_health_pass`, `train_iterations=600`, `optimizer_updates=150`, `clip_enabled_updates=150`, `clip_applied_updates=131`, `nonfinite_count=0`, metrics/log/source snapshot digests, final adapter SHA `a8b5a50c...`, and `candidate_signing_status=not_signed_c6_parity_vpass_gptpro_pending`.
- Data cleaning evidence: PR3 source SHA remains `46a3601856bacd975076817b988835ea9d5bd1f90d021246c1b4de0617dda604`; clean pack SHA is `009d1017740fe266d66485a7d325476de795e522e59c1534e3ec4463a9cac858`; `cleaning-summary.json` records 82 removed records across 40 ambiguous groups, `manual_utterance_edits=0`, and `judge_result_reuse_for_modified_text=false`.
- Generated-data fallback check: clean prepared samples contain 4,418 action samples from `hermes_glm`/`hermes_ark_standard`, 0 `single_turn_seed`, 0 `deterministic_semantic_protocol_v1`, and 0 missing semantic judge IDs.

## Notes

- Training health evidence is strong enough for `TRAIN_HEALTH_PASS_ONLY`: the runner completed, clip was enabled/applied, nonfinite count is zero, and adapter/checkpoint digests are recorded.
- This still cannot sign a candidate. C6 same-harness base-vs-LoRA eval, heldout/OOD diagnostics, dynamic/fused/quantized parity, endpoint tokenizer byte parity, physical endpoint V-PASS, and GPT Pro final audit remain pending by receipt and evidence summary.
