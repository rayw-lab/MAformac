## S0 — Carrier structure and canonical contract

- [x] Create the W8 carrier files and keep the capability id as session-lifecycle.
  - Output: proposal, design, spec, tasks, and carrier metadata.
  - Acceptance: all files exist; W8 is greenfield; no W5c DONE dependency is introduced.
- [x] Expand the canonical seed into the complete ADDED Requirements and GIVEN/WHEN/THEN scenarios.
  - Output: full session-lifecycle spec.
  - Acceptance: M16-007/008/009, 010a, 010b, owner boundaries, offline mock boundary, and error non-success semantics are represented.
- [x] Run openspec validate --strict for the change and keep structure incomplete if it is not rc0.
  - Output: command receipt.
  - Acceptance: rc0 is required before pair closeout; a red result is HOLD.

## S1 — Identity, generations, states, and terminal causes

- [x] Define the observable session and generation identity contract.
  - Output: design decisions and behavior scenarios.
  - Acceptance: unknown identity rejects; generation is monotonic; first terminal cause is immutable.
- [x] Freeze the legal transition and terminal disposition semantics.
  - Output: transition and terminal tables in design/spec.
  - Acceptance: illegal transitions and duplicate terminal events fail closed.

## S2 — Single coordinator and immutable publication

- [x] Define the single-owner publication boundary.
  - Output: owner decision and consumer/event boundary.
  - Acceptance: non-owner mutation is rejected; no second lifecycle truth is permitted.
- [x] Define compound request deterministic ordering.
  - Output: scenario and planned test shape.
  - Acceptance: concurrent requests yield one immutable outcome.

## S3 — Child registry, cancellation, and timedOutFenced

- [x] Define the closed child disposition roster and cancel fan-out.
  - Output: behavior contract and cancellation matrix.
  - Acceptance: cancelled, terminal, unsupported, and timedOutFenced are covered.
- [x] Define ack or timeout plus fence before recoveryReady/new generation.
  - Output: negative scenarios.
  - Acceptance: no-ack cancellation cannot enter recoveryReady.

## S4 — Generation fence

- [x] Define old-generation event rejection and stale accounting.
  - Output: fence scenarios and deliberate-red test plan.
  - Acceptance: late old-generation events are observed/rejected, never applied; applied-stale count is honest.

## S5 — Checkpoint and W9 force/reset sequence boundary

- [x] Define last reconciled stable checkpoint as the only recovery source.
  - Output: checkpoint and recovery contract.
  - Acceptance: pending-plan resume is denied; W8 does not own W9 force/reset write store.
- [x] Define terminal/checkpoint/child-fence join.
  - Output: join matrix.
  - Acceptance: recoveryReady requires all join members.

## S6 — RecoveryReady and new generation

- [x] Define recoveryReady and new-generation publication.
  - Output: design sequence and scenarios.
  - Acceptance: new generation is allocated only after the required join and is strictly newer.
- [x] Define old-generation fence after recovery.
  - Output: negative cases.
  - Acceptance: old callbacks cannot mutate the new generation.

## S7 — Commit versus sibling presentation/TTS boundary

- [x] Preserve the W10 TTS and presentation boundary.
  - Output: owner-boundary note.
  - Acceptance: W8 publishes lifecycle facts and terminal outcomes without becoming TTS quality authority.
- [x] Keep accepted, refused, cancelled, unsupported, timeout, and error outcomes distinct.
  - Output: behavior scenarios.
  - Acceptance: errors do not render as successful actions.

## S8 — Receipt schema and proof-class separation

- [x] Define 010a deterministic interleaving profile receipt.
  - Output: seed, schedule, terminal hash, generation result, stale result, and profile claim fields.
  - Acceptance: repeated seed is reproducible; profile_only/stress_profile_only is preserved.
- [x] Define 010b recipe provenance and claim ceiling.
  - Output: recipe reference and recipe_only boundary.
  - Acceptance: RECIPE-REAL-PROCESS-HARNESS provenance is retained; fake/unit/mock cannot satisfy proof_runtime.
- [x] Keep planned gate fields complete.
  - Output: blocked predicate, unlock condition, tracking slot, evidence path, owner, SLA, max claim, forbidden claim.
  - Acceptance: source and exit gates remain PLANNED_GATE_NOT_YET_EXECUTABLE until materialized.

## S9 — Future seam and gate materialization

- [x] Keep future App seam, checker, negative suite, Makefile wiring, materialization writer, and real-process runner as future coding work.
  - Output: implementation-ready task slices only.
  - Acceptance: no Swift/Python implementation is added by this carrier writeback.
- [x] Define source gate wiring as future verify and verify-ci work, and exit gate wiring as future verify-wave2-runtime-only work.
  - Output: planned gate recipe.
  - Acceptance: exit gate is not placed in source-free verify-ci.
- [x] Record GitNexus impact/risk-ack and later coding key as separate future authorization.
  - Output: stopline note.
  - Acceptance: this carrier does not authorize apply/coding/merge/push.

## Writeback and closeout gates

- [x] Run openspec validate --all --strict.
  - Acceptance: rc0; otherwise HOLD and do not invent a repair.
- [x] Write the current-day pair receipt with plan path/SHA, carrier path, every change file/SHA, repo HEAD, paired_at, paired_by, conventions SHA, and strict rc.
  - Acceptance: receipt is complete and independently hashable.
- [x] Flip the W8 plan frontmatter to SUPERSEDED_BY_CARRIER only after pair receipt is complete.
  - Acceptance: carrier_change_id, carrier_path, pair_receipt_path, plan_sha256_at_pair, superseded_at, and authority_after_k1 are filled.
- [x] Create one local commit whose message references KEY-RECEIPT-2.
  - Acceptance: commit exists locally; no push is performed.
