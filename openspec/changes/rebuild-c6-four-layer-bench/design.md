# Rebuild C6 Four-Layer Bench Design

> DRAFT. This design records Architecture Decisions for the post-A2 C6 bench proposal. It is not permission to run D-domain base recalibration, evaluate model quality, claim endpoint readiness, execute demo-golden-run, run voice, or merge UIUE.

## Scope

This change carries the C6 model-quality bench contract after A2 D-domain surface migration. It depends on `migrate-d-domain-tool-surface` for D-domain surface and on `retrain-c5-lora-d-domain` only when a signed candidate is available for base-vs-LoRA comparison.

## Architecture Decisions

### AD-C6-001: Four-layer denominators derive from case schema fields

R-L04 is an architecture decision. C6 must not use aggregate pass rate as a substitute for golden, demo_fuzz, unsupported, safety, action, clarify, or readback denominators.

### AD-C6-002: D-domain base anchor is comparison evidence, not permission to run during Phase 0

The historical 10/23 anchor remains failure evidence until D-domain base recalibration is separately authorized and executed. This design records the future anchor semantics only.

### AD-C6-003: C6 exposes sampling support for C5 mid-training behavior gates

R-L05 creates a dependency from retrain-c5 to C6 sample runners. This support does not make C6 release cases a checkpoint-selection oracle.

### AD-C6-004: C6 gate integrity is sign-or-block

R-L11 is an architecture decision. pass^k and hardPassVariance must be enforced when claimed, and grader failure keeps the candidate unsigned.

### AD-C6-005: Human deframing review is required before closeout

R-L17 is an architecture decision. Top failing cases and denominator construction require deliberate deframing review.

### AD-C6-006: C6 model quality does not imply endpoint or demo readiness

C6 evidence does not imply endpoint readiness, demo-golden readiness, V-PASS, S-PASS, or U-PASS. Readback renderer evidence remains separate from model hard-pass evidence.

## User Decision Gate

D1-D10 must be visible in the Phase 0 decision record before apply. Until every relevant row is accepted, modified, or explicitly deferred by the user, task rewrites in this change remain draft gate language rather than accepted gate policy.

## Non-Goals

- No D-domain base recalibration run in Phase 0.
- No LoRA candidate comparison without a signed candidate.
- No endpoint-ready claim.
- No demo-golden-run execution.
- No voice work.
- No UIUE merge.
