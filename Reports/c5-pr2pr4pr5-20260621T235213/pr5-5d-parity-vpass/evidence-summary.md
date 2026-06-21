# PR5 5d Parity And V-PASS Evidence Summary

Verdict: PARITY_VPASS_BLOCKED_BY_C6_HARD_FAIL

The PR5 candidate is not signed. Dynamic/fused/quantized parity and endpoint tokenizer byte parity were not run because the upstream C6 candidate gate already failed with positive action collapse and a training/eval tool-surface mismatch.

## Upstream Blocker

- c6_receipt: `Reports/c5-pr2pr4pr5-20260621T235213/pr5-5c-c6-eval/c6-eval-receipt.json`
- c6_receipt_sha256: `2167fa80f9839bc55da226df4f723f3e319f2ae7aeb7b757c025c1a65bcefd4e`
- c6_verdict: `C6_HARD_FAIL_BLOCKED`
- LoRA positive expected tool hits: `0/34`
- LoRA observed tool names: `tool_call`
- Training outer tool names: `tool_call_frame`
- C6 expected tool names: `query_cabin_comfort`, `set_cabin_ac`, `set_cabin_ambient_light`, `set_cabin_fan`, `set_cabin_screen_brightness`, `set_cabin_window`

## Parity Status

- dynamic/fused/quantized parity: `blocked_not_run`
- reason: C6 failed before parity. Running parity now would not restore ToolCallExact or candidate readiness and could create a misleading secondary signal.
- task status: 4.1 remains open-blocked.

## Endpoint Byte Parity Status

- endpoint tokenizer byte parity: `blocked_not_run`
- reason: no model-quality candidate and no target physical iOS device receipt.
- device probe: `xcrun xctrace list devices` observed only the Mac as a physical device; iPhone/iPad entries are simulator-only.
- task status: 4.2 remains open-blocked.

## V-PASS Split

- model-quality V-PASS: `blocked`
- physical endpoint V-PASS: `blocked`
- Mac/simulator evidence is not accepted as physical endpoint evidence.
- task status: 4.3 recorded the split as blocked.

## Residual Gates

- Fix the training/eval tool-surface mismatch.
- Rerun C6 after the tool-surface fix.
- Complete semantic near-neighbor proof for heldout/OOD diagnostics.
- Run dynamic/fused/quantized parity only after C6 passes.
- Run endpoint tokenizer byte parity on target only after model-quality gates pass.
- Run GPT Pro final audit before any candidate signing.
