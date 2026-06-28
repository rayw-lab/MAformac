# Runtime-Presentation Bridge Design

## AD-RPB-001: Mainline carrier is the authority mapping

Mainline accepts this thin carrier as the mainline-visible authority mapping for Runtime -> Presentation bridge semantics. UIUE documents remain candidate/provenance inputs unless this carrier or a later archived mainline spec references them.

This avoids both failure modes:

- no fake acceptance based only on UIUE documents;
- no second same-meaning bridge SSOT in mainline.

## AD-RPB-002: Contract-first, implementation-later

The bridge defines event/result/snapshot vocabulary before runtime backend or UIUE merge work. This is allowed before model/C6 gates because it does not execute a model, train data, run C6 acceptance, or claim readiness.

## AD-RPB-003: UIUE consumes mapped snapshots, not raw runtime stores

UIUE SHALL consume the mapped presentation semantics from the mainline bridge. It SHALL NOT treat UIUE-local bridge notes as standalone mainline SSOT, and it SHALL NOT depend directly on raw runtime stores, raw trace arrays, model output, or training receipts as acceptance proof.

## AD-RPB-004: ScopeOrigin remains Core-owned

Core `ScopeOrigin` remains exactly `defaulted`, `explicit`, and `fanout` in the current mainline. Missing or unresolved scope SHALL be represented as result metadata, presentation metadata, or an explicit failure reason. A UI-local presentation-only label MAY be used for display if needed, but it SHALL NOT be treated as a locked Core enum case.

## AD-RPB-005: Runtime result vocabulary preserves refusal and missing-slot classes

The bridge SHALL preserve at least:

- accepted tool call;
- clarify/missing-slot result;
- no available tool / unsupported refusal;
- safety or policy refusal;
- already-state no-op;
- runtime error;
- cancelled/interrupted result.

A display-layer aggregate such as `rejected` is allowed only if machine-readable `result_class`, `rejection_class`, or equivalent source metadata remains available.

## AD-RPB-006: Presentation proof classes are finite and display-capped

`PresentationSnapshot.proof_class` SHALL use finite project vocabulary. Unknown values fail closed. Local/static/docs proof MUST NOT be displayed as runtime-ready, endpoint-ready, voice-ready, model-ready, golden-ready, mobile-ready, true-device-ready, C6-ready, V-PASS, S-PASS, or U-PASS.

## AD-RPB-007: Minimal runtime boundary wording

Future runtime work that feeds the bridge SHOULD avoid blocking the main thread, emit a terminal snapshot on cancel/interruption/timeout, and avoid persistence, cloud sync, real vehicle control, or long-lived user memory. This design records the boundary only; it does not implement it.

## Accepted C-dispositions

| ID | Disposition |
|---|---|
| C01 | Closed for mainline dispatch readiness by this carrier: mainline accepts a thin runtime-presentation bridge carrier as the mainline-visible authority mapping; UIUE docs remain candidate/provenance, not standalone mainline SSOT. |
| C03 | Closed for mainline dispatch readiness by this carrier: the carrier references/maps UIUE bridge semantics without creating a second same-meaning bridge SSOT. |
| C06 | Closed for mainline dispatch readiness by this carrier: Core `ScopeOrigin` remains `defaulted/explicit/fanout`; missing/unresolved scope is represented in presentation/result metadata or explicit failure reason, not as a locked Core enum case. |
| C18 | Closed for mainline dispatch readiness by this carrier: mainline route moves from `not_proposed` to active proposed/accepted bridge-carrier state; R5 may start only as dispatch readiness, not runtime/mobile proof. |
