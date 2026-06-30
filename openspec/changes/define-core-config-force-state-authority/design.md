## Context

Live repo evidence before Gate 1 shows `C018` and `C052` are intentionally deferred:

- `openspec/changes/define-runtime-presentation-bridge/tasks.md` keeps `C018` deferred until mainline owns a future OpenSpec/Core authority.
- The same task list keeps `C052` deferred until a future owner proves demo-mode gating, trace provenance, and no production path.
- `docs/project/phase0/r5-d11-step3-c018-core-config-authority-2026-06-29.md` classifies `C018` as `openspec_contract_owner_proposal_first`.
- `docs/project/phase0/r5-mainline-deferred-gates-c005-c018-c061-2026-06-29.md` keeps `C018` without a Swift/Core implementation.
- UIUE has an existing `RuntimePresentationConsumerMapping`, but it marks `C018` and `C052` as deferred mainline owner rows; it is not the authority for shared names.

Gate 1 therefore creates authority, not implementation. It is an `authoritative OpenSpec change` and a `docs/local` receipt. It is not runtime evidence.

## Goals / Non-Goals

**Goals:**

- Establish main-owned `C018` authority for stable Core config and scene macro names.
- Establish main-owned `C052` authority for demo force-state boundary semantics.
- Give D17 a finite set of consumable categories and hard forbidden categories.
- Preserve D15 payload proof cap and prevent UIUE field invention.

**Non-Goals:**

- No Swift code in Gate 1.
- No UIUE writes in Gate 1.
- No production vehicle control, production runtime, mobile, true-device, live API, voice, model, golden-run, endpoint, UIUE merge, V/S/U-PASS, or A-2 claim.
- No second SSOT inside UIUE.
- No consumption of private adapter fields or debug-only internals.

## Decisions

### D16-AD-001: Main owns stable config vocabulary

Core config / scene macro names SHALL be defined in main before UIUE consumes them. UIUE may display or map those names only after they appear in main-owned OpenSpec/docs/code authority.

Alternative considered: let UIUE define the first config names and reconcile later. Rejected because it recreates the exact `C018` risk: hidden UI planner/config truth outside main.

### D16-AD-002: Unknown config and macro names fail closed

Unknown Core config keys, scene macro names, force-context dimensions, and proof-class labels SHALL fail closed. Gate 2/3 code must prove this locally before D17 uses the names.

Alternative considered: allow UIUE to render unknown values as generic labels. Rejected because it turns unknown shared semantics into user-visible implied authority.

### D16-AD-003: Force-state is a demo/debug input path, not product runtime proof

Force-state MAY exist only under explicit demo/debug isolation. It SHALL produce bridge event provenance and SHALL NOT directly mutate state-cell contract definitions or customer-facing production paths.

Alternative considered: reuse the debug gallery force-state scaffold as production force-state proof. Rejected because previous receipts classify that scaffold as debug-only/simulator_mock proof.

### D16-AD-004: D17 consumes only stable main-owned categories

D17 may consume stable D15 payload categories and the D16 names/categories created by main authority. D17 must not consume `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, request fingerprints, parent request fingerprints, ledger internals, settled parent plan internals, raw runtime store, raw model output, training receipt, or adapter-local private names.

Alternative considered: expose adapter-local fields for richer UI debugging. Rejected because adapter internals are not presentation-safe shared vocabulary.

## Risks / Trade-offs

- [Risk] A docs-only Gate 1 can be mistaken for runtime proof. -> Mitigation: receipt and spec keep proof class at `docs/local + OpenSpec`.
- [Risk] Existing UIUE mapping creates pressure to treat UIUE names as authority. -> Mitigation: spec states UIUE non-authority and main-owned vocabulary first.
- [Risk] Force-state can leak into customer-facing builds. -> Mitigation: spec requires demo/debug isolation, bridge event provenance, and no production path before implementation.
- [Risk] Future D17 may broaden proof class from local/unit/simulator to mobile/true-device. -> Mitigation: proof-class display caps remain finite and no promotion is allowed without a separate true-device gate.

## Migration Plan

1. Gate 1 creates this authority and validates OpenSpec.
2. Gate 2 implements finite Core config / scene macro registry code and local/unit tests.
3. Gate 3 implements force-state boundary code and local/unit tests, if the build configuration can prove demo/debug isolation.
4. Gate 4 verifies committed D16 diff and explicitly opens or closes D17.
5. D17 starts only if Gate 4 writes `d17_release_gate: open`.

## Open Questions

- Gate 2 decides the exact Swift module/file shape for Core config after GitNexus impact/context on the target symbols.
- Gate 3 decides the concrete `DEMO_MODE` / `DEBUG` compile-time switch based on existing project build settings.
