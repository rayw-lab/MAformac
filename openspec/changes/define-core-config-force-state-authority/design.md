## Context

This is a W9 amend of the existing `define-core-config-force-state-authority` carrier. The live change is structurally valid but its current five requirements and historical tasks do not contain the D-152 M16-011/M16-012 delta.

The authority inputs are pinned by the W9/V2 plan `CARRIER-PLAN-W9-V2-v2-by-w5g.md` at SHA `30397a2c6625cca815b2b8664eab4983ce92a8b08b0944b7b226e7f4dd1a11b8`, conventions SHA `244bd3adda8481a2531b41e9cb6ad9dcc9ba77b176c2aff89e9fb870f731121c`, and the W9 recheck verdict `APPROVE_P2_CLOSED`. The ballot anchors are INDEX v3.1 `:82-83`, INDEX v2 `:72-73`, and `TRACKING-WAVE2-17UNITS.md:50-51`.

The live blast map records `DemoVehicleStateStore.replaceCells` as a CRITICAL write surface and `DemoForceStateBoundary.accept` as LOW with production `CALLS=0`; the App force path currently bypasses the boundary. The W9 ammo therefore requires a later risk-ack and W8 typed lifecycle/fence acknowledgement before P3/P4 can claim a clean authority receipt. The two official W9 gates are currently planned and absent from Makefile wiring.

This carrier writeback is authoritative OpenSpec contract text plus a local receipt. It is not Swift implementation, runtime evidence, or production authority proof.

## Goals / Non-Goals

**Goals:**

- Preserve the existing D16 C018/C052 and D17 boundaries while adding the M16-011/M16-012 contract delta.
- Make one physical Core catalog, two explicit `debug`/`demo` kind-and-namespace values, digest metadata, and exact migration behavior observable and fail closed.
- Make the force-state owner graph explicit: boundary validation → Core applier → projection-only, with App/customer direct-write negatives.
- Keep W8 lifecycle/fence ownership and the W9 planned-gate/W8-ack stopline visible.
- Keep proof capped at local/OpenSpec structure until the future gates and implementation exist.

**Non-Goals:**

- No Swift code, catalog file, migration implementation, Core applier, App cutover, checker, Makefile target, UIUE write, apply, coding, merge, package-state transition, or runtime test.
- No W8 lifecycle/cancel/recovery state-machine definition and no V2 ceremony carrier.
- No production, mobile, true-device, live API, operator-pass, V-PASS, or W9 DONE claim.

## Decisions

### D16-AD-001: Main owns stable config vocabulary

Core config / scene macro names SHALL be defined in main before UIUE consumes them. UIUE may display or map those names only after they appear in main-owned OpenSpec/docs/code authority. This vocabulary is not the M16-011 physical catalog by itself.

Alternative considered: let UIUE define the first config names and reconcile later. Rejected because it recreates the C018 second-SSOT risk.

### D16-AD-002: Unknown config and macro names fail closed

Unknown Core config keys, scene macro names, force-context dimensions, and proof-class labels SHALL fail closed. Gate 2/3 code must prove this locally before D17 uses the names.

Alternative considered: allow UIUE to render unknown values as generic labels. Rejected because it turns unknown shared semantics into implied authority.

### D16-AD-003: Force-state is a demo/debug input path, not product runtime proof

Force-state MAY exist only under explicit demo/debug isolation. It SHALL produce bridge event provenance and SHALL NOT directly mutate state-cell contract definitions or customer-facing production paths.

Alternative considered: reuse the debug gallery force-state scaffold as production force-state proof. Rejected because current evidence classifies that scaffold as debug-only/local or simulator-mock proof.

### D16-AD-004: D17 consumes only stable main-owned categories

D17 may consume stable D15 payload categories and D16 names/categories created by main authority. D17 must not consume adapter-private fields, raw runtime/model stores, training receipts, or ledger internals.

Alternative considered: expose adapter-local fields for richer UI debugging. Rejected because adapter internals are not presentation-safe shared vocabulary.

### D16-AD-005: One physical catalog with two explicit kind/namespace values

The W9 authority SHALL describe one physical catalog for the force/config vocabulary. Each catalog entry SHALL carry explicit stable identity, `kind`, `namespace`, version, and owner metadata. The only allowed kind/namespace values in this carrier are `debug` and `demo`; a consumer SHALL NOT infer either value from a label, array position, or UI route, and a second same-meaning catalog is prohibited.

Alternative considered: keep separate debug and demo registries and reconcile them in the presentation layer. Rejected because that creates duplicate authority and makes source completeness unverifiable.

### D16-AD-006: Digest is declared and canonical

The catalog authority SHALL declare a digest algorithm identifier, canonicalization version, and catalog digest over the complete ordered set of load-bearing catalog entries. Equivalent input ordering after canonicalization SHALL produce the same digest; any load-bearing entry, kind/namespace, version, owner, or algorithm-version change SHALL change the digest. Missing metadata or a digest mismatch SHALL fail closed.

Alternative considered: compare only entry names or rely on a consumer-local digest. Rejected because names omit ownership/version and a local digest would reintroduce a second source of truth.

### D16-AD-007: Exact migration ledger; no 4↔5 fuzzy mapping

Any supported legacy migration SHALL be represented by an explicit versioned ledger row containing source identity, target identity, direction, reason, and evidence. The ledger SHALL reject missing, duplicate, ambiguous, inferred, positional, or similarity-based mappings. A `4↔5` mapping SHALL never be synthesized or accepted; unsupported or ambiguous migration input SHALL fail closed.

Alternative considered: infer a legacy mapping from names, array positions, or nearest similarity. Rejected because it can silently join incompatible catalog identities.

### D16-AD-008: Single force-state write owner and projection-only presentation

An accepted force-state request SHALL follow the owner graph `boundary validator → Core applier → projection-only`. Only the Core applier may commit the resulting mock state; App/UI consumers SHALL read the projection and SHALL NOT directly mutate the store or state-cell contract. A missing applier, direct-write path, missing provenance, or customer-facing reachability is a negative condition, not a degraded success.

Alternative considered: retain existing App `replaceCells` calls and document the boundary as the owner. Rejected because the live blast map records that path as a CRITICAL bypass and `Boundary.accept` production CALLS=0.

### D16-AD-009: W8 owns lifecycle and W9 gates remain planned

W9 may consume a later W8 typed terminal/fence acknowledgement, but it SHALL NOT define W8 session/cancel/recovery state transitions. `verify-force-state-source` and `verify-force-state-authority` remain `PLANNED_GATE_NOT_YET_EXECUTABLE` until target, wiring, independent checker, behavior suite, and deliberate-red negative surfaces all materialize.

Alternative considered: treat current OpenSpec strict validation or local boundary tests as executable W9 gates. Rejected because they do not prove Makefile materialization or production write ownership.

## Risks / Trade-offs

- [Risk] The historical Gate1–4R `[x]` tasks can be mistaken for M16-011/M16-012 closure. → Mitigation: retain them but label them `HISTORICAL_CHECKBOX_ONLY`; add a separate unchecked Wave2 task group.
- [Risk] A catalog digest can become a second implementation-specific truth. → Mitigation: require algorithm identifier, canonicalization version, complete entry coverage, and mismatch fail-closed behavior in the contract before code.
- [Risk] A boundary-only test can be mistaken for a production single owner. → Mitigation: make the Core applier and App direct-write deletion negatives part of M16-012; preserve the live `CALLS=0` non-claim.
- [Risk] The W9 gates are phantom surfaces. → Mitigation: keep both gates planned until Makefile wiring, independent checker/test, and deliberate-red negatives are present.
- [Risk] W9 could absorb lifecycle semantics that belong to W8. → Mitigation: require typed terminal/fence acknowledgement as a later stopline and keep W8 lifecycle ownership explicit.

## Migration Plan

1. This transaction amends only the four W9 carrier artifacts and runs OpenSpec strict validation.
2. The W9 pair receipt records exact artifact SHAs, plan SHA, current HEAD, validation, and the unchanged shared-plan status.
3. A later independent apply key may implement the catalog/migration/owner graph; before P3/P4 it must obtain the prescribed W8 acknowledgement and `RISK-ACK-W9`.
4. The V2 carrier must be written and paired separately. Only the later atomic transaction with both W9 and V2 pair receipts may flip the shared W9/V2 plan.
5. Rollback for this carrier-only transaction is a new reviewed amendment or a pinned rollback dispatch; do not silently delete the existing change or alter the shared plan.

## Open Questions

- The future implementation phase must select and freeze the concrete digest algorithm/canonical serialization fixture under the declared contract; this carrier requires the declaration and fail-closed join, not implementation.
- The future implementation phase must run fresh GitNexus impact/context for the Core applier and every App direct-write call site; `replaceCells` remains CRITICAL and requires the separate risk acknowledgement.
- The future W8 ack fixture must expose the typed terminal/fence facts W9 consumes; W9 does not define that fixture here.
