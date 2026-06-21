## ADDED Requirements

### Requirement: Candidate training SHALL depend on the archived training-method contract
PR5 candidate training SHALL use the archived `lora-training` capability as its method and readiness contract. A PR5 receipt SHALL record the archived spec digest or path, the archived change path, the data pack digest, and the verified training-loop source SHA before any candidate training run is authorized.

#### Scenario: Archived dependency is recorded
- **GIVEN** PR5 prepares a LoRA candidate run
- **WHEN** it writes the candidate training receipt
- **THEN** the receipt records `openspec/specs/lora-training/spec.md` as the active training-method spec
- **AND** it records the archived `define-lora-training` change path
- **AND** it records the verified repo training-loop source SHA and verification reference

#### Scenario: Active change directory is not used as authority
- **WHEN** PR5 checks training-method authority
- **THEN** it does not depend on `openspec/changes/define-lora-training` as an active change
- **AND** missing archive/spec authority blocks candidate training

### Requirement: First candidate SHALL use MLX scale 20
The first formal PR5 rank16 candidate SHALL render MLX LoRA `scale=20`. The receipt SHALL record `scale_authority_resolution`, cite the P1-C grill source, and classify `scale=32` or other values as later A/B experiments rather than first-candidate authority.

#### Scenario: First candidate scale is explicit
- **WHEN** PR5 renders the rank16 candidate MLX config
- **THEN** the config records `scale=20`
- **AND** the receipt records `scale_authority_resolution.first_candidate_scale=20`
- **AND** the receipt records that `scale=32` is deferred to A/B rather than silently inherited from code defaults

#### Scenario: Wrong first-candidate scale blocks signing
- **GIVEN** a formal PR5 candidate receipt with `scale` not equal to `20`
- **WHEN** candidate status is computed
- **THEN** the candidate does not receive model-quality V-PASS
- **AND** the failure receipt includes `scale_authority_mismatch`

### Requirement: Offset artifact SHALL be a hard pre-training gate
PR5 formal training SHALL require `offset_fixture.status=pass` and an approved token artifact digest for the exact data pack being trained. The approved final-v3 digest for the inherited PR3 data pack is `c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9`. If the PR5 data pack is regenerated or merged, PR5 SHALL rerun the same-path offset fixture and record the new artifact path and digest.

#### Scenario: Approved final-v3 offset digest authorizes training
- **GIVEN** PR5 uses the PR3 final-v3 data pack without regeneration
- **WHEN** formal training preflight runs
- **THEN** it verifies `offset_fixture.status=pass`
- **AND** it verifies token artifact digest `c71ffb059610b337cd22350f9883eadb699c2d0d825bcd38b8cdf2752420a1a9`
- **AND** candidate training may proceed only if the other hard gates also pass

#### Scenario: Offset mismatch blocks training
- **GIVEN** the data pack digest or token artifact digest does not match the approved PR3 final-v3 evidence
- **WHEN** PR5 preflight evaluates train eligibility
- **THEN** formal training is blocked
- **AND** the failure receipt includes `offset_artifact_mismatch`

### Requirement: Candidate data-quality gates SHALL block memorization-prone data
PR5 SHALL enforce candidate data-quality gates before training. The gates SHALL include per-seed variant cap enforcement, near-duplicate or diversity checks, ambiguous duplicate blocking, lineage/parent-overlap checks, and epoch-exposure reporting. Distribution summaries SHALL NOT be sufficient by themselves.

#### Scenario: Variant cap and diversity are enforced
- **WHEN** PR5 validates the candidate data pack
- **THEN** it records per-seed variant counts and cap status
- **AND** it records diversity or near-neighbor check results
- **AND** cap or diversity failure blocks formal candidate training

#### Scenario: Ambiguous duplicates block candidate training
- **GIVEN** two candidate rows are ambiguous duplicates with conflicting expected ToolCalls or refusal labels
- **WHEN** PR5 computes data-quality status
- **THEN** candidate training is blocked
- **AND** the failure receipt includes `ambiguous_duplicate`

### Requirement: Candidate training receipt SHALL be replayable
Every PR5 formal training run SHALL produce a replayable receipt with data digests, model/tokenizer references, training-loop source snapshot and SHA, environment versions, seed values, optimizer settings, clip/nonfinite metrics, training-curve pointers, checkpoint-selection policy, and final adapter/checkpoint digest.

#### Scenario: Training receipt records replay fields
- **WHEN** a PR5 formal training run completes
- **THEN** the receipt records data, model, tokenizer, loop source, environment, seed, optimizer, scale, rank, sequence length, and checkpoint-selection fields
- **AND** it records metrics/log paths and final adapter or checkpoint digest

#### Scenario: Nonfinite training blocks candidate readiness
- **GIVEN** the training loop observes nonfinite loss or gradient
- **WHEN** it writes the training receipt
- **THEN** candidate readiness is blocked
- **AND** the receipt records the nonfinite event and fallback recommendation

### Requirement: C6 candidate evaluation SHALL compare base and LoRA under one harness
PR5 SHALL run or reference a base Qwen3-1.7B C6 baseline and compare the LoRA candidate under the same harness, prompt policy, parser, mock-state policy, scoring pipeline, and sample sets. C6 release cases SHALL be final-only for candidate evaluation and SHALL NOT be used for checkpoint selection.

#### Scenario: Base and LoRA share harness identity
- **WHEN** PR5 emits a C6 candidate eval receipt
- **THEN** it records base and LoRA run identifiers
- **AND** it records matching harness, prompt, parser, mock-state, and scoring digests
- **AND** mismatched harness identity blocks improvement claims

#### Scenario: C6 release is not used for checkpoint selection
- **WHEN** PR5 selects a checkpoint
- **THEN** it uses `dev_selection` or other non-release selection evidence
- **AND** final C6 release opens are logged separately from checkpoint selection

### Requirement: Candidate diagnostics SHALL guard against memorization
PR5 SHALL record in-dist, heldout, and OOD diagnostic axes for the candidate. Heldout and OOD construction SHALL include lineage or near-neighbor checks that prevent train-neighbor cases from being counted as generalization evidence.

#### Scenario: Diagnostic axes are recorded
- **WHEN** PR5 writes candidate diagnostic results
- **THEN** it records in-dist, heldout, and OOD metrics
- **AND** it records lineage or near-neighbor check evidence for heldout and OOD cases

#### Scenario: Leakage blocks generalization claims
- **GIVEN** diagnostics detect train-to-heldout or train-to-OOD leakage
- **WHEN** candidate status is computed
- **THEN** generalization claims are blocked
- **AND** the diagnostic verdict records `blocked_leakage`

### Requirement: Candidate parity SHALL compare dynamic, fused, and quantized behavior
PR5 SHALL compare dynamic adapter, fused bf16, and fused quantized or endpoint behavior on the same C6 harness and sample sets. The candidate SHALL fail parity on ToolCallExact delta beyond tolerance, IrrelAcc delta beyond tolerance, must-pass regression, quantized parse failure, or negative false-call delta beyond tolerance.

#### Scenario: Three-way parity records deltas
- **WHEN** PR5 runs candidate parity
- **THEN** it records dynamic adapter, fused bf16, and fused quantized or endpoint run identifiers
- **AND** it records ToolCallExact delta, IrrelAcc delta, must-pass regression count, parse failure count, and negative false-call delta

#### Scenario: Parity failure blocks candidate signing
- **GIVEN** any parity delta or regression exceeds the approved tolerance
- **WHEN** candidate status is computed
- **THEN** model-quality V-PASS is blocked
- **AND** the failure receipt identifies the failing parity axis

### Requirement: V-PASS SHALL be split between model quality and physical endpoint readiness
PR5 SHALL record Mac-side model-quality V-PASS separately from physical endpoint candidate V-PASS. Mac C6 and parity evidence MAY support model-quality status, but physical endpoint V-PASS SHALL require target device evidence and endpoint tokenizer byte parity. Mac-only or simulator-only evidence SHALL NOT sign endpoint candidate readiness.

#### Scenario: Mac model-quality pass does not imply endpoint pass
- **GIVEN** Mac-side C6 and parity gates pass
- **WHEN** no target physical device receipt exists
- **THEN** model-quality status may be recorded separately
- **AND** endpoint candidate V-PASS remains blocked

#### Scenario: Physical endpoint evidence is required
- **WHEN** PR5 computes endpoint candidate V-PASS
- **THEN** it requires endpoint render-byte parity and target physical device receipt
- **AND** it rejects Mac-only and simulator-only substitutes

### Requirement: Candidate signing SHALL require heterogeneous final audit
PR5 candidate signing SHALL require same-source implementation audits plus a GPT Pro heterogeneous final audit. Same-source Codex subagent audits SHALL NOT be sufficient to sign a candidate.

#### Scenario: GPT Pro final audit is required
- **WHEN** PR5 computes final candidate signoff
- **THEN** it requires a GPT Pro final audit report path and PASS verdict
- **AND** missing or failing GPT Pro audit blocks candidate signing

#### Scenario: Same-source audit alone cannot sign
- **GIVEN** all Codex subagent audits pass
- **WHEN** GPT Pro final audit is missing
- **THEN** the candidate remains unsigned
- **AND** the closeout records `final_audit_blocked`
