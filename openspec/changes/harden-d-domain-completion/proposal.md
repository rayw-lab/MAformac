# Harden D-domain completion decoding

## Why

The current D-domain decoder accepts a bare completion string and selects the first
`<tool_call>` body it finds. That loses completion metadata and can silently ignore
extra text or additional calls.

## What Changes

- Introduce a typed completion envelope carrying content, finish reason, stop reason,
  declared tool-call count, and source.
- Require the production D-domain parser to validate metadata and the complete output
  shape before producing calls.
- Apply an explicit cardinality policy: exactly one call, or a reviewed bounded plan
  of at most two calls.
- Keep stale-turn rejection in the runtime state gate; this change does not reinterpret
  stale state as a decode failure.

## Scope

In scope: completion decode, typed rejection, bounded cardinality, and a static guard
against the customer route using the legacy bare-string parser.

Out of scope: `LLMBackend` protocol signature changes, production backend composition,
T09 lifecycle/cancellation, W5c, action execution, and runtime/operator acceptance.

## Proof cap

The strongest claim from this change is `local/unit/integration-pass`. It does not prove
customer action success, runtime acceptance, operator acceptance, or V-PASS.
