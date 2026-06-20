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

### Correction 2026-06-20

The first C3 apply pass under-tested this item. It only checked that the root
Swift package had no MLX/outlines/xgrammar dependency, then deferred the runtime
choice. That was too weak for the dispatch requirement:

> 受限解码方案 spike: MLX JSON schema / outlines-swift / xgrammar 至少二选一实测,结论写入 docs。验收:格式合法率与延迟记录。(spike)

Corrected evidence:

- Project `.venv` installed `outlines==1.3.0` and `xgrammar==0.2.2`.
- `dev/constrained-decode-spike/structured_output_smoke.py` wraps the same
  MAformac-style ToolCall JSON schema in Outlines and compiles/checks it with
  XGrammar.
- This is a Python development spike, not an `outlines-swift` runtime
  integration. The two measured concrete options are XGrammar schema
  compilation/acceptance and the isolated MLX Swift harness below.
- The schema includes the C1/C2 value tuple `{ref,direct,offset,type}`.
- Fixture gate: 4/4 pass.
  - valid spot numeric offset accepted.
  - valid exp token offset accepted.
  - missing `value.type` rejected.
  - extra `value.unit` rejected.
- Measured on 2026-06-20:
  - Outlines `JsonSchema` wrap: 0.338 ms.
  - Outlines term conversion: 0.001 ms.
  - XGrammar schema-to-EBNF: 1.525 ms.
  - XGrammar `compile_json_schema`: 1.432 ms.
  - XGrammar matcher setup: 0.005 ms.
  - XGrammar fixture accept/reject: 0.342-1.180 ms per fixture.
  - Synthetic compiled grammar memory: 252,288 bytes.
  - These are single-run local timings; reruns vary slightly, while the 4/4
    fixture gate stayed stable in the follow-up audit.

Command:

```bash
.venv/bin/python dev/constrained-decode-spike/structured_output_smoke.py
```

MLX Swift runtime evidence was also rerun from the existing isolated harness:

```bash
cd /Users/wanglei/workspace/MAformac/dev/spike-e3
swift build -c release
DERIVED_DATA_PATH="$PWD/DerivedData"
xcodebuild -scheme SpikeE3FunctionCall -configuration Release \
  -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -skipMacroValidation -skipPackagePluginValidation build
PRODUCT_DIR="$DERIVED_DATA_PATH/Build/Products/Release"
test -x "$PRODUCT_DIR/spike-e3"
test -f "$PRODUCT_DIR/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
"$PRODUCT_DIR/spike-e3" --output-dir "$PWD/Reports"
```

Rerun result:

- `mlx-swift-lm==3.31.3`, `mlx-community/Qwen3-1.7B-4bit`.
- 55/55 cases completed.
- Positive raw `.toolCall` trigger: 31/40 = 77.5%.
- Expected tool hit rate: 70.0%.
- Content-embedded tool JSON without `.toolCall`: 9/40 = 22.5%.
- Negative false tool calls: 1/15 = 6.7%.
- Average elapsed: 681.20 ms.
- Average first stream event: 584.65 ms.
- Average generation speed: 79.12 tok/s.
- Decision remains `go+LoRA`: C3 can continue with a thin parser layer, but
  LoRA Day1 must collect misses/content-JSON cases; a naive content fallback
  must still pass strict decode and DemoGuard/restraint.

Corrected decision:

- Do not add Python `outlines` or `xgrammar` to the iOS app runtime.
- Keep them as Mac development spike tools and schema/grammar reference.
- Do not add MLX dependencies to the repo root package during pure C3 contract
  work, but do not claim this as a blocker: `dev/spike-e3` proves MLX Swift is
  buildable and runnable on this machine.
- Runtime integration should be a separate `MLXBackend` apply step behind
  `LLMBackend`, not a silent downgrade to static notes.

Local package check:

- `swift package dump-package | rg -n "mlx|MLX|outlines|xgrammar|gbnf|grammar|json"` returned no current runtime dependency.
- `rg` only found prior research references under `docs/research/`, not linked Swift dependencies.

Original weak receipt, superseded by the correction above:

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
