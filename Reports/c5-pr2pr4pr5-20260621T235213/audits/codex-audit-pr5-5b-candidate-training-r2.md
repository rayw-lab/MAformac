# PR5 5b Candidate Training Audit R2
Verdict: PASS_WITH_NOTES

## Findings
- P1/P2: none.
- P3: r1 P1 is fixed for the canonical PR5 5b artifacts. The regenerated clean prepare receipt records `openspec/specs/lora-training/spec.md`, `openspec/changes/archive/2026-06-21-define-lora-training`, and the archived spec digest `16073248326acfa3011f610b4a8a7f81044f8e56f6220b5f2e864ffd273f2a34` at `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean/c5-training-receipt.json:620-648`. The run receipt records the same method authority at `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-training/c5-training-run-receipt.json:166-174`, and records `receipt_amendment.training_artifacts_unchanged=true` at lines 175-194. `rg` found no `openspec/changes/define-lora-training/specs/lora-training/spec.md` dependency in the canonical clean prepare/training receipt directories.
- P3: fail-closed behavior is implemented, but the focused test coverage is mostly positive-path for the new authority gate. `Core/Training/C5LoRATraining.swift:492-514` emits `active_training_method_spec_missing`, `archived_define_lora_training_change_missing`, and `archived_training_method_spec_missing`; `Core/Training/C5LoRATraining.swift:2038-2040` adds those failures to formal hard failures; and `Core/Training/C5LoRATraining.swift:2113` writes them into `failure_receipt`. The new test at `Tests/MAformacCoreTests/C5LoRATrainingTests.swift:361-405` verifies the archived authority happy path and stale active-change source ref removal, but it does not simulate missing active/archive authority. This is not a 2.7 blocker because the code path is direct and conservative, but a future negative unit test would reduce regression risk.

## Checks Run
- `swift test --filter C5LoRATrainingTests` -> passed, 23 tests, 0 failures.
- `openspec validate run-lora-candidate-training --strict && openspec validate --all --strict` -> passed; all-strict reported 9 passed, 0 failed.
- `openspec list --json` -> active `run-lora-candidate-training` has 9/23 tasks complete; `define-lora-training` is not active; `define-lora-data-gate` remains complete.
- `rg -n "openspec/changes/define-lora-training/specs/lora-training/spec.md" Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-prepare-clean Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-training || true` -> no matches.
- `shasum -a 256 openspec/specs/lora-training/spec.md openspec/changes/archive/2026-06-21-define-lora-training/specs/lora-training/spec.md` -> `018ce75047ef16647179d781525dcfe837e4f0c5576542a202b59c6fb63b4639` and `16073248326acfa3011f610b4a8a7f81044f8e56f6220b5f2e864ffd273f2a34`, matching both receipts.
- Artifact digest spot check against the run receipt:
  - `train.jsonl` -> `8fdffb150c56be2a80fa23716d2e723042d09e23402bec9c50456b9e969159c0`
  - `valid.jsonl` -> `f54c8e4080846c0b038b3b3f360aafa3119ac871e7bb39903a91e94722f50daf`
  - `test.jsonl` -> `bdaf1ec7ab32b1f595edfd76db6ec9a83129d3e12367a92b5af86cf82dff3ad3`
  - `mlx-lora-config.yaml` -> `6ec089a0c5a2d9dd0de26b3da1019749c0949a4d9fd4f333e2ba9e0ed5dc459e`
  - `metrics.jsonl` -> `bb15bafdd63da29a7b9d4ca97e1ab9ddd99cee96100ac41a8f1c4ca4cafecd5e`
  - `train.log` -> `49130fab704299524217654e3dc3a3e2ead064983b4bde682630b705b4939131`
  - final adapter -> `a8b5a50ca08bd3f96b37411f40718568625606985935d09d18eedd88e45b86fc`
  - `adapter_config.json` -> `f025da20d5b9338356271183dfbf25e628274a68bf85bcd5a9e4bed520f8d592`
- Evidence summary check: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5b-candidate-training/evidence-summary.md:3-5` correctly limits the claim to `TRAIN_HEALTH_PASS_ONLY`; lines 46-52 keep C6 eval, heldout/OOD, parity, endpoint tokenizer byte parity, physical endpoint V-PASS, and GPT Pro final audit pending.

## Notes
- 2.1-2.6 training-health evidence still holds after the clean prepare regeneration. The run receipt records `status=train_health_pass`, `train_iterations=600`, `optimizer_updates=150`, `clip_enabled_updates=150`, `clip_applied_updates=131`, `nonfinite_count=0`, and `candidate_signing_status=not_signed_c6_parity_vpass_gptpro_pending`.
- The clean prepare receipt remains `trainable_v0_ready` with empty top-level `failure_receipt`, scale 20, data-quality pass, and training-loop source SHA `5400641044144746f8d4ddc424b8b49f66e650e6511d94843ccd64f12895e0f7`.
- The main executor can add the audit INDEX row and mark task 2.7 complete after accepting this report. I did not update INDEX or tasks per the write boundary.
