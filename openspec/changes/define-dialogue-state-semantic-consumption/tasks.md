## P0 — Carrier structure and semantic seed

- [ ] Create proposal, design, dialogue-state-semantic-consumption spec, tasks, and carrier metadata.
  - Output: greenfield W7 change tree.
  - Acceptance: no W8 lifecycle owner or W5c/W9/V2 boundary is absorbed.
- [ ] Expand M16-001/003/004/005/006 into complete Requirement and Scenario trace.
  - Output: R1–R6 behavior contract and 077/078/081/082/083 corner mapping.
  - Acceptance: no orphan ballot or corner; exact spelling remains K1-freeze provisional.
- [ ] Run change strict and all strict validation.
  - Acceptance: rc0; red is HOLD and receives no self-invented repair.

## P1 — Typed bounded window schema

- [ ] Freeze the versioned, finite, bounded, read-only envelope behavior.
  - Output: identity/version/disposition/window contract.
  - Acceptance: missing/unknown identity or version fails closed; retention does not become long-lived memory.
- [ ] Define paired/unpaired reason set and bounded retention behavior.
  - Output: round-trip and bounded-eviction scenarios.
  - Acceptance: array length cannot infer a paired round.

## P2 — Effect adapter and field validity matrix

- [ ] Define W8 fact to W7 field-effect mapping.
  - Output: one versioned effect matrix for focus, last readback, active window, unpaired group, and terminal audit.
  - Acceptance: one fact has one deterministic effect; W7 does not define lifecycle identity/order/fence.
- [ ] Define independent focus/readback validity and clear/retain/audit-only effects.
  - Output: R3/R6 scenarios and negative cases.
  - Acceptance: field validity does not cross-infer; terminal audit cannot re-enter active context.

## P3 — Production consumer boundary and CRITICAL risk gate

- [ ] Before any production consumer coding, obtain RISK-ACK-W7 with exact symbols_allowed_final.
  - Output: signed scope including the production consumer and only actually touched receipt writer surfaces.
  - Acceptance: no Runner.run modification without fresh GitNexus impact, risk review, and detect_changes plan.
- [ ] Define read-only consumer envelope and mutation allowlist.
  - Output: future consumer contract.
  - Acceptance: consumer cannot write lifecycle state or bypass the effect matrix.

## P4 — Source gate materialization plan

- [ ] Define future verify-dialogue-state-source target, independent checker, exact suite, and deliberate negatives.
  - Output: five-piece source gate recipe.
  - Acceptance: checker does not call the reducer as self-proof; missing target/checker/negative remains planned.
- [ ] Define future official wiring and materialization receipt.
  - Output: planned .PHONY/verify/verify-ci and registry-derived receipt contract.
  - Acceptance: no current green claim; availability transition remains a later transaction.

## P5 — Consumption gate materialization plan

- [ ] Define future verify-dialogue-state-consumption integration target, checker, exact suite, and deliberate negatives.
  - Output: five-piece consumption gate recipe.
  - Acceptance: source gate fresh receipt and W8 typed fixtures are prerequisites; no integration green without them.
- [ ] Keep roster/presence single-source rules explicit.
  - Output: registry + Makefile recipe derivation and exemption handling.
  - Acceptance: no hand-written parallel CHECKER_PATHS ledger; missing behavior case is red.

## P6 — Closeout, audit, and separate authority

- [ ] Record proof caps and excluded predecessors.
  - Output: 084/091 excluded; 092/093 named predecessors; no W7 DONE/V-PASS claim.
  - Acceptance: strict carrier green remains documentation proof only.
- [ ] Run producer/independent audit with W8 boundary and Runner CRITICAL stopline.
  - Output: audit receipt.
  - Acceptance: producer and auditor are separate; any scope expansion requires a new risk key.
- [ ] Keep future apply, coding, merge, gate materialization, registry reanchor, and package state flip as separate keys.
  - Output: stopline record.
  - Acceptance: this carrier does not authorize any downstream action.

## Writeback closeout

- [ ] Run openspec validate --all --strict.
  - Acceptance: rc0; otherwise HOLD.
- [ ] Write current-day pair receipt with pre-flip W7 plan SHA, carrier file SHA list, HEAD, strict rc, executor, time, and conventions SHA.
  - Acceptance: receipt is complete and independently hashable.
- [ ] Flip W7 plan frontmatter to SUPERSEDED_BY_CARRIER after the pair receipt exists.
  - Acceptance: carrier_change_id, carrier_path, pair_receipt_path, plan_sha256_at_pair, superseded_at, and authority_after_k1 are filled.
- [ ] Create one local commit whose message references KEY-RECEIPT-2.
  - Acceptance: local commit exists; no push.
