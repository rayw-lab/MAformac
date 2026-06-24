# Rebuild C6 Four-Layer Bench Design

> DRAFT. This design records Architecture Decisions for the post-A2 C6 bench proposal. It is not permission to run D-domain base recalibration, evaluate model quality, claim endpoint readiness, execute demo-golden-run, run voice, or merge UIUE.

## Scope

This change carries the C6 model-quality bench contract after A2 D-domain surface migration. It depends on `migrate-d-domain-tool-surface` for D-domain surface and on `retrain-c5-lora-d-domain` only when a signed candidate is available for base-vs-LoRA comparison.

## Architecture Decisions

### AD-C6-001: Four-layer denominators derive from case schema fields

R-L04 and D1 are accepted architecture decisions. C6 denominators derive from case schema fields. C6 must not use aggregate pass rate as a substitute for golden, demo_fuzz, unsupported, safety, action, clarify, or readback denominators.

### AD-C6-002: D-domain base anchor is comparison evidence, not permission to run during Phase 0

The historical 10/23 anchor remains failure evidence until D-domain base recalibration is separately authorized and executed. It must be marked historical, not reused as an active D-domain candidate gate. This design records future D-domain base anchor semantics only.

### AD-C6-003: C6 exposes sampling support for C5 mid-training behavior gates

R-L05 and D2 create a dependency from retrain-c5 to C6 sample runners. This support exists for iter50/100/150 behavior-generation samples and does not make C6 release cases a checkpoint-selection oracle.

### AD-C6-004: C6 gate integrity is sign-or-block

R-L11 is an architecture decision. pass^k and hardPassVariance must be enforced when claimed, and grader failure keeps the candidate unsigned.

### AD-C6-005: Human deframing review is required before closeout

R-L17 is an architecture decision. Top failing cases and denominator construction require deliberate deframing review, not same-vendor consensus. A four-model "consistent pass" is only a no-obvious-objection signal; it does not certify C6.

R-L17 C6 evidence must include human-owner participation, at least one heterogeneous judge outside the Claude-family, and a record of the R5 top-failing C6 drilldown plus R7 final route signoff under `docs/project/phase0/r-l17-human-review-evidence/`. If any judge disagrees, the route is escalated to human review rather than resolved by majority vote.

### AD-C6-006: C6 model quality does not imply endpoint or demo readiness

C6 evidence does not imply endpoint readiness, demo-golden readiness, V-PASS, S-PASS, or U-PASS. Readback renderer evidence remains separate from model hard-pass evidence.

## User Decision Gate

D1-D10 are accepted in `docs/project/phase0/phase0-d1-d10-user-decision-record.md`. This removes the pending user-decision gate, but this change remains non-executable until OpenSpec propose acceptance, R-L17 handling, and physical evidence gates are satisfied.

## Non-Goals

- No D-domain base recalibration run in Phase 0.
- No LoRA candidate comparison without a signed candidate.
- No endpoint-ready claim.
- No demo-golden-run execution.
- No voice work.
- No UIUE merge.
