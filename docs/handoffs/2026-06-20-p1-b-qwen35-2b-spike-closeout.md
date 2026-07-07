# P1-B Qwen3.5-2B Spike Closeout

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

status: BLOCKED
decision: blocked_waiting_for_device_or_artifact
s1_only_candidate: true
run_dir: `Reports/qwen35-2b-spike-20260620-192146`

## What Changed

- Patched isolated spike harness `dev/spike-e3/Sources/SpikeE3/main.swift` to accept `--model-id` and `--tool-call-format`.
- Default behavior remains `mlx-community/Qwen3-1.7B-4bit` with explicit `.json`.
- Qwen3.5 S1 was run only through explicit args: `--model-id mlx-community/Qwen3.5-2B-4bit --tool-call-format auto`.
- No app default model, LoRA, OpenSpec change, or repo-tracked model artifact was added.

## Evidence

- machine summary: `Reports/qwen35-2b-spike-20260620-192146/spike-result.json`
- Qwen3.5 transcript: `Reports/qwen35-2b-spike-20260620-192146/parser-transcript.jsonl`
- 1.7B baseline transcript: `Reports/qwen35-2b-spike-20260620-192146/baseline-parser-transcript.jsonl`
- true-device gate: `Reports/qwen35-2b-spike-20260620-192146/device-metrics.json`
- parser source evidence: `Reports/qwen35-2b-spike-20260620-192146/mlx-swift-lm-parser-evidence.txt`
- audit evidence appendix: `Reports/qwen35-2b-spike-20260620-192146/audit-evidence-appendix.md`
- Hermes audit: `Reports/qwen35-2b-spike-20260620-192146/hermes-audit.md`
- Hermes rerun: `Reports/qwen35-2b-spike-20260620-192146/hermes-audit-rerun.md`
- research writeup: `docs/research/2026-06-20-p1-b-qwen35-2b-s1-s2-spike.md`

## Result

S1:

- Qwen3.5 artifact is present and resolves to `model_type=qwen3_5`, `text_config.model_type=qwen3_5_text`.
- **VL disclosure (CC 2nd-layer audit correction)**: `mlx-community/Qwen3.5-2B-4bit` is an image-text-to-text **VL** weight (`architectures: Qwen3_5ForConditionalGeneration` + `vision_config`, converted with mlx-vlm). This spike loads only its **text tower** for text-only FC; S1 text results hold for the text tower, not a pure-text 2B. Hermes "no VL confusion" was a mis-read of `text_config` alone. Switching to 2B must account for VL weight size/RAM vs a pure-text 2B.
- Qwen3.5 chat template path is recorded in `spike-result.json` and `artifact-inventory.txt`.
- `mlx-swift-lm 3.31.3` resolves Qwen3.5 `toolCallFormat=auto` to `xmlFunction`.
- Qwen3.5 S1 fixed set: 8/11 positive structured `.toolCall` trigger, 63.6% expected-tool-hit, 0 thinking leaks, 0 negative false calls.
- Rerun 1.7B baseline fixed set: 9/11 positive structured `.toolCall` trigger, 72.7% expected-tool-hit.

S2:

- `xcrun xctrace list devices` shows only Mac under `== Devices ==`.
- iPhones are only listed under `== Simulators ==`.
- S2 is blocked; no Mac or simulator metrics are counted as iPhone/GDN evidence.

## Residual

- Qwen3.5 is a real S1 candidate, but not yet a default-upgrade candidate.
- P1-C LoRA train remains blocked until P1-A data gate and P1-B true-device decision are both resolved.
- Next valid step is a true iPhone/GDN run with the same fixed set and a same-device 1.7B baseline.

## Verification

- `swift build -c release` in `dev/spike-e3`: pass
- `openspec validate --all --strict`: pass
- `swift test`: pass, 85 tests, 3 skipped
- `make verify`: pass
- Hermes full audit: P1/Important found and fixed
- Hermes rerun: `verdict=clear_for_closeout`
