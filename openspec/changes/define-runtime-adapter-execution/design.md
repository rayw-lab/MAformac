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

## AD-RAE-010: C3 routes planned transitions through Runtime Adapter V0

D13 SHALL move supported mock writes in `C3ExecutionPipeline` from direct `DemoVehicleStateStore.applyMockTransition` calls to Runtime Adapter V0 execution calls. C3 still owns semantic validation, stale-state checks, risk checks, allowlist checks, transition planning, readback verification, and trace logging.

The adapter owns the write side effect for each supported planned `DemoMockTransition`.

## AD-RAE-011: C3 parent identity is not the adapter ledger identity

`ToolCallFrame.id` is the C3 parent command identity. It SHALL NOT be reused directly as the adapter ledger identity for every planned transition, because C3 can fan one frame into multiple transitions such as `ac.power` plus `ac.temperature` or several window keys.

C3 SHALL derive a deterministic per-transition adapter command identity from the parent frame and planned transition, for example:

`<ToolCallFrame.id>#<transition.key>`

If a deterministic fallback is needed for local/unit proof, it SHALL include stable request-shaping fields and the planned transition key. Tests SHOULD pass an explicit `ToolCallFrame.id`.

## AD-RAE-012: C3 constructs adapter-local frames without editing ToolCallFrame

D13 SHALL NOT edit the shared `ToolCallFrame` schema. C3 may construct an adapter-local frame using the existing `ToolCallFrame(arguments:)` initializer with:

- `toolName = "set_vehicle_control"`;
- `state_key = <planned transition key>`;
- `target_state = <planned desired value>`;
- `id = <per-transition adapter command identity>`;
- `traceID` and agent/capability context copied from the parent frame.

This adapter-local frame is an internal main execution detail, not a UIUE-facing payload.

## AD-RAE-013: C3 retry replay is bounded by existing C3 safety gates

A C3 retry replay can be proven only when the retry attempt reaches the adapter boundary after satisfying existing C3 semantic, risk, allowlist, and stale-state checks. The D13 local/unit test may reuse the parent `ToolCallFrame.id` with an updated `stateRevision` when the current C3 stale-state guard would otherwise block an exact stale retry before adapter execution.

This is a local/unit C3 integration proof, not production retry readiness. Persistent ledger, cross-launch replay, exact stale retry handling, and failure ledger durability remain future work.

## AD-RAE-014: Adapter provenance remains internal

C3 may use adapter provenance for internal trace or unit assertions, but `C3ExecutionResult` and UIUE receipts SHALL NOT promote `first_execution`, `retry_replay`, or `already_state_noop` into a new UIUE payload contract in D13.

## AD-RAE-015: D14 ledger boundary is session-scoped, not persistent

D14 SHALL make the Runtime Adapter ledger boundary explicit as session-scoped local/unit state owned by a `DemoRuntimeAdapter` instance or the `RuntimeAdapterBox` that owns that instance.

A new adapter or a new box starts with an empty session ledger. This is intentional for D14 and SHALL NOT be described as persistent, durable, cross-launch, cross-process, cross-device, or production-ready idempotency.

Durable ledger storage, cross-launch replay, and external storage format are future work.

## AD-RAE-016: Exact stale retry replay is ordered before stale-state failure only for matching settled requests

D14 SHALL define the C3 stale retry ordering as:

1. C3 may attempt a pre-stale replay lookup only for a request that can be mapped to already-settled adapter command identities in the current session ledger.
2. The replay lookup SHALL verify the current request fingerprint matches the settled ledger entry.
3. If every planned transition has a matching settled entry and readback reconciliation passes, C3 may return replay readbacks without mutating state even when the parent frame `stateRevision` is older than the current store revision.
4. If no settled entry exists, if any fingerprint differs, or if the request cannot be reconstructed safely, the normal C3 stale-state guard remains authoritative and the stale attempt SHALL fail before any new write.

This proves local/session exact stale replay ordering only for reconstructable settled requests. Current-relative requests that cannot safely reconstruct the original desired state remain stale-guarded.

## AD-RAE-017: Failure ledger records non-success outcomes without blocking corrected retry

D14 SHALL add an adapter-local failure ledger for observability of failed attempts. The ledger SHALL distinguish:

- `retryable_failure`: input reached adapter semantics but may become valid after state or environment repair, such as missing state cell or readback reconciliation mismatch;
- `terminal_failure`: unsupported tool shape or missing required adapter argument;
- `conflict`: reused command identity with a different request fingerprint after a settled success.

Failure records SHALL NOT be treated as successful idempotency entries, SHALL NOT replay fake success, and SHALL NOT prevent a later corrected attempt from executing when no successful entry exists for that command identity.

## AD-RAE-018: Retry replay performs readback reconciliation

D14 retry replay SHALL reconcile the settled ledger readback against the current store path before returning `retry_replay`.

If the current store cell is missing or its actual value differs from the settled successful readback, the adapter SHALL fail closed, record a retryable failure record, and SHALL NOT rewrite state to force reconciliation.

This keeps the store path as the source of truth and prevents stale ledger readback from masquerading as current mock state.

## AD-RAE-019: RuntimeAdapterBox concurrency boundary remains local and bounded

`RuntimeAdapterBox` may keep `C3ExecutionPipeline` construction non-`@MainActor` while resolving the `DemoRuntimeAdapter` only inside `@MainActor` execution.

D14 SHALL keep this as an explicitly bounded local/unit concurrency boundary. `@unchecked Sendable` on the private box is acceptable only if:

- the box stays private to `C3ExecutionPipeline`;
- adapter access remains `@MainActor`;
- tests continue to compile non-main pipeline construction helpers; and
- receipts keep broader runtime concurrency proof as future work.

This does not prove production concurrency safety.

## Pre-Mortem And Cross-Search Findings

Local search found current write behavior split between `C3ExecutionPipeline`, `DemoActionExecutor`, and `DemoVehicleStateStore`, while D11 receipts say retry/full adapter idempotency is future work. Web references reinforce three design constraints:

- Stripe documents idempotency keys as preserving the first result for retried requests and rejecting parameter mismatch for reused keys: `https://docs.stripe.com/api/idempotent_requests`.
- AWS Builders Library recommends caller-provided client request identifiers for safe retries and warns about late-arriving duplicate requests: `https://aws.amazon.com/builders-library/making-retries-safe-with-idempotent-APIs/`.
- The IETF Idempotency-Key draft defines a request-header approach and highlights request fingerprint use for idempotent retries: `https://datatracker.ietf.org/doc/html/draft-ietf-httpapi-idempotency-key-header`.
- Google AIP-180 treats API compatibility as a first-class concern, reinforcing that internal fields should not be treated as externally stable consumer contracts without explicit ownership: `https://google.aip.dev/180`.
- Swift `Sendable` / actor-isolation references show why the private box boundary must be explicit rather than accidentally leaking `@MainActor` construction into C3 callers: `https://github.com/swiftlang/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md` and `https://github.com/apple/swift-evolution/blob/main/proposals/0327-actor-initializers.md`.

## Iceberg Teardown

Visible symptom: D9/D11 could prove already-state no-double-write but not retry idempotency.

Likely iceberg class: execution ownership was implicit; the store had no-op behavior, but no adapter boundary owned command identity, retry replay, or failure ledger semantics.

Same-class risk map:

- local store no-op mistaken for retry safety;
- presentation snapshot adapter mistaken for execution adapter;
- duplicate command id with changed payload silently replays stale result;
- failed execution accidentally recorded as successful;
- UIUE consumes a field not owned by mainline.
- multi-transition C3 plans reuse one raw parent identity and trigger false idempotency conflict;
- adapter-local provenance becomes a presentation payload by accident.

Immediate fix: define OpenSpec authority before Swift.

Class-level fix: tests must cover first write, retry replay, parameter mismatch, failed command, and already-state no-op.

Governance fix: receipts must keep local/unit proof cap and preserve production/runtime/mobile/merge non-claims.
