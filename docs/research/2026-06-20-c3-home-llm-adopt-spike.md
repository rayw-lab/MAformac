# C3 home-llm adopt spike — non-stream parser / constrained decode / sampling / prewarm

## Scope

This note is an apply-stage receipt for `define-execution-contract` group 7. It does not lock a runtime library and does not import Python or home-llm code. It records what C3 implemented now and what needs a separate runtime/model spike.

## 7.1 Non-stream parser

Implemented in Swift:

- `ToolCallCandidateDecoder.decodeContentFallback(_:)`: content fallback is disabled by default and only creates a candidate when explicitly enabled.
- `ToolCallCandidateDecoder.decodeNonStreamingCompletion(_:)`: strips `<think>...</think>`, extracts fenced JSON, then re-enters the same strict decode path.
- Candidate source is marked `parser_repair`; semantic gate and DemoGuard still run later.

Verification:

- `swift test --filter C3ToolCallFrameAndDecodeTests`
- Result: 7 tests passed, including fenced JSON + thinking strip.

## 7.2 Constrained decode options

Local package check:

- `swift package dump-package | rg -n "mlx|MLX|outlines|xgrammar|gbnf|grammar|json"` returned no current runtime dependency.
- `rg` only found prior research references under `docs/research/`, not linked Swift dependencies.

Decision receipt:

- Do not add `outlines-swift`, `xgrammar`, or MLX JSON schema support inside this C3 apply.
- C3 keeps strict decode and fail-closed semantic/DemoGuard gates as the safety boundary.
- Library choice remains a separate spike once the actual `mlx-swift-lm` runtime is wired.

## 7.3 Qwen3 sampling

Current C3 package has no model runtime path to measure Qwen3 sampling. The home-llm-derived starting point remains:

- Qwen3 reference start: `temperature=0.6`, `top_k=20`, `top_p=0.95`.
- Deterministic comparison candidate: low temperature around `0.1`.

Decision receipt:

- C3 does not hard-code sampling values.
- Measure trigger rate, format legality, semantic accuracy, and latency when C7/runtime has the model backend active.

## 7.4 KV prewarm

Current package has no loaded LLM backend or prompt cache lifecycle. C3 therefore does not implement eager prewarm.

Boundary:

- C3 owns the execution contract and can expose state revision/readback features.
- Runtime/C7 should own model cache warmup timing after ASR/model backend loading order is known.

Recommended next spike:

1. Wire `mlx-swift-lm` backend behind `LLMBackend`.
2. Compare no-grammar vs constrained decode candidate.
3. Compare Qwen3 sampling start vs low-temperature deterministic start.
4. Measure cold/warm first-token latency with and without prewarm.
