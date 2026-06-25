# GPT Pro Audit Request - Rebuild-C6 Identity Shape - 2026-06-25

## Requested Verdict

Return exactly one:
- `PASS`
- `PASS_WITH_FIXES`
- `FAIL`

Required findings format:
- P0 / P1 / P2
- each finding must include file:line anchors
- do not restate generic repository background without a concrete branch diff tie

## Branch Under Audit

- repo: `rayw-lab/MAformac`
- branch: `codex/rebuild-c6-doc-absorption-20260624`
- head: `a56aa83`
- implementation range: `ebc7933..229e9b3`
- closeout-doc range: `229e9b3..a56aa83`

## Audit Scope

This audit is only for Long-run 2 construction-lane local closeout:
- Phase 4: contract bundle identity
- Phase 5: explicit D-domain `behavior_class` shape migration
- Phase 6: local closeout / lessons / evidence excerpt

Primary review targets:
- `Core/Bench/C6ContractBundleFingerprint.swift`
- `Core/Bench/C6VehicleToolBench.swift`
- `contracts/c6-bench-cases.jsonl`
- `scripts/check_c6_case_shape.py`
- `Makefile`
- `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`
- `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md`
- `docs/project/phase0/rebuild-c6-identity-shape-lessons-2026-06-25.md`
- `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md`

## Local Evidence Bundle

Tracked docs to audit first:
- `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md`
- `docs/project/phase0/rebuild-c6-identity-shape-lessons-2026-06-25.md`
- `docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md`

High-signal local gates already passed on this branch head:
- `swift test --filter C6VehicleToolBenchTests`
- `swift test --filter ToolContractCompilerTests`
- `python3 scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json`
- `make verify-surface`
- `openspec validate rebuild-c6-four-layer-bench --strict`
- `openspec validate --all --strict`
- `git diff --check`

Proof boundary:
- local only
- source-free + unit + static contract + receipt consistency only
- not live model quality

## Phase 4 Diff Focus

Commit: `728137a`

Questions:
- Is `contract_bundle_fingerprint` now a manifest-visible receipt (`schema_version / bundle_hash / component_digests`) rather than an opaque hash?
- Are required per-run identity fields still preserved independently:
  - `prompt_hash`
  - `tool_output_digest`
  - `contract_digest`
  - `model_artifact_digest`
  - `tokenizer_digest`
  - `lora_adapter_digest`
- Do public manifest / receipt / fingerprint entry points all fail closed on missing required components?

## Phase 5 Diff Focus

Commit: `229e9b3`

Questions:
- Do all 57 tracked C6 rows now carry explicit `behavior_class` from the five-class taxonomy?
- Is the source-free checker strong enough against fake-green:
  - `already_state_noop` must be mechanically proven from `pre_state` + `expected_state_delta`
  - `expect_no_call` cannot be the only success signal
  - `expected_tool_calls == []` cannot collapse into legal direct success
  - no `direct_no_call`
  - coverage/demo-fuzz cannot silently re-enter golden hard-pass
- Is `behavior_class` now explicit in tracked JSONL, decode path, generator path, and validation path?
- Is `verify-c6-shape` part of the local `verify` gate, not only `verify-ci`?

## Phase 6 Diff Focus

Commit: `a56aa83`

Questions:
- Do closeout / lessons / evidence excerpt stay honest about proof class and status?
- Is the status capped at `local-pass-pending-gptpro`?
- Can an external auditor verify the local work from tracked docs alone, without ignored `Reports/`?

## Explicit No-Goals

Do not treat this branch as evidence for:
- retrain-C5
- C6 acceptance
- D-domain base recalibration
- §4 candidate comparison
- model-quality evaluation
- training / LoRA artifacts
- golden-run
- voice
- endpoint readiness
- UIUE merge
- R-L17 candidate signoff
- V-PASS / S-PASS / U-PASS

## Top 3 Fake-Green Paths To Attack

1. `contract_bundle_fingerprint` looks structured in tests/docs but one public entry point still permits opaque or partial receipt semantics.
2. `behavior_class` exists on tracked JSONL but checker/generator/validator/runtime consumers still silently collapse no-call rows or drift from each other.
3. tracked evidence excerpt is sufficient for local gates, but closeout wording accidentally overstates the result as external pass, acceptance, or candidate-comparison readiness.

## Decision Constraint

Even if this local closeout passes, the next route still may not move to candidate comparison unless:
- a retrain-C5 candidate is actually produced,
- candidate signoff is completed,
- and explicit run authorization is granted.

If your verdict is `PASS` or `PASS_WITH_FIXES`, keep that boundary explicit.
