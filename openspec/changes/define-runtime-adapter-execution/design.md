# Runtime Adapter Execution Design

## AD-RAE-001: Runtime Adapter V0 owns local mock writes

Runtime Adapter V0 is the execution boundary that receives a `ToolCallFrame`, a stable command identity, and a `DemoVehicleStateStore`, then applies allowed mock state transitions through `DemoVehicleStateStore.applyMockTransition`.

`C005` is covered only when the adapter, not UIUE and not ad hoc call sites, owns the write path under local/unit proof.

## AD-RAE-002: Stable command identity is explicit at adapter boundary

The adapter input SHALL carry a stable command identity supplied by the caller. The adapter MAY derive a fallback identity from deterministic frame fields only for local/unit demo scope, but tests should prefer explicit identity.

The identity is not a UIUE field and not a model output claim. It is a mainline execution contract.

## AD-RAE-003: Request fingerprint prevents unsafe replay

The ledger SHALL bind command identity to a request fingerprint derived from the normalized tool/frame content that affects the write. Reusing an identity with different parameters SHALL fail closed and SHALL NOT replay or overwrite the previous result.

This follows common idempotency-key practice: same key plus same request can replay; same key plus different request is an error.

## AD-RAE-004: In-memory ledger is local/unit only

Runtime Adapter V0 uses an in-memory idempotency ledger. It is intentionally not persistent across process restarts, devices, app launches, or distributed workers.

This is sufficient for D12 local/unit proof and insufficient for production runtime readiness.

## AD-RAE-005: First success records success after side effect

On first successful execution, the adapter writes through the mock store, obtains verified readback from the store path, and records the successful outcome in the ledger after the write/readback succeeds.

Failed, unsupported, stale, parameter-mismatch, or thrown execution attempts SHALL NOT create a fake successful ledger entry.

## AD-RAE-006: Retry replay does not mutate state

A retry with the same command identity and matching request fingerprint SHALL return the recorded or verified current readback without applying a second write. The retry SHALL NOT change the cell revision or timestamp.

## AD-RAE-007: Already-state remains a no-op

If the desired state is already satisfied, the adapter SHALL return readback without mutation and SHALL record provenance as an already-state no-op rather than reporting unsupported, failure, or hidden success.

## AD-RAE-008: Provenance is machine-readable

The adapter result SHALL distinguish at least:

- `first_execution`;
- `retry_replay`;
- `already_state_noop`.

This provenance is local/unit execution metadata. It is not a UIUE proof label and not a readiness claim.

## AD-RAE-009: Presentation bridge remains separate

Runtime Adapter V0 may feed future presentation snapshots, but it does not modify `runtime-presentation-bridge` vocabulary in Gate 1. UIUE consumes only mainline-owned names and must not invent runtime adapter fields.

## Pre-Mortem And Cross-Search Findings

Local search found current write behavior split between `C3ExecutionPipeline`, `DemoActionExecutor`, and `DemoVehicleStateStore`, while D11 receipts say retry/full adapter idempotency is future work. Web references reinforce three design constraints:

- Stripe documents idempotency keys as preserving the first result for retried requests and rejecting parameter mismatch for reused keys: `https://docs.stripe.com/api/idempotent_requests`.
- AWS Builders Library recommends caller-provided client request identifiers for safe retries and warns about late-arriving duplicate requests: `https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/`.
- The IETF Idempotency-Key draft defines a request-header approach and highlights request fingerprint use for idempotent retries: `https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header`.

## Iceberg Teardown

Visible symptom: D9/D11 could prove already-state no-double-write but not retry idempotency.

Likely iceberg class: execution ownership was implicit; the store had no-op behavior, but no adapter boundary owned command identity, retry replay, or failure ledger semantics.

Same-class risk map:

- local store no-op mistaken for retry safety;
- presentation snapshot adapter mistaken for execution adapter;
- duplicate command id with changed payload silently replays stale result;
- failed execution accidentally recorded as successful;
- UIUE consumes a field not owned by mainline.

Immediate fix: define OpenSpec authority before Swift.

Class-level fix: tests must cover first write, retry replay, parameter mismatch, failed command, and already-state no-op.

Governance fix: receipts must keep local/unit proof cap and preserve production/runtime/mobile/merge non-claims.
