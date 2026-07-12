## Context

V2 owns the T07 operator ceremony contract. The pinned W9/V2 plan is `CARRIER-PLAN-W9-V2-v2-by-w5g.md` with SHA `30397a2c6625cca815b2b8664eab4983ce92a8b08b0944b7b226e7f4dd1a11b8`; its M16-013/014/015 contract is expanded by `AMMO-V2-CEREMONY-PLAN-v2-by-w3.md` and the six-ballot recall in `AMMO-V2-CEREMONY-PLAN-by-w3.md`.

The ceremony must join a real subject, environment, build/artifact identity, launch attempt, three O1 axes, expiry state, and evidence references. The current official source and final gates are phantom/planned surfaces: `verify-operator-ceremony-source` and `verify-operator-ceremony` are not yet executable. T07a schema and local mismatch shape may be prepared now; T07b and P8 remain blocked until the real current T06 same-subject receipt, all registry prerequisites, and a separate ignition key exist.

V2 is downstream of W7 and W8 at the fact boundary. It may consume W7/W8 receipts and typed current session/generation/terminal facts, but it does not own DialogueState window/focus/readback semantics or session/cancel/recovery lifecycle semantics.

## Goals / Non-Goals

**Goals:**

- Define one sectioned, versioned ceremony envelope for M16-013.
- Define exact identity joins and per-axis fail-closed predicates without copying a second O1 vocabulary.
- Define immutable launch attempts for M16-014, preserving every failure and forcing a new attempt on mode/artifact/environment changes.
- Define expiry and versioned retest requirements for M16-015.
- Make synthetic/local evidence visibly incapable of satisfying T07b.
- Keep source/final gate materialization and T07b/P8 blocking conditions explicit.

**Non-Goals:**

- No implementation, schema file, checker, fixture runner, Makefile wiring, registry mutation, operator UI, launch, or evidence collection.
- No operator-pass, V2 DONE, V-PASS, package transition, merge, or final ceremony claim.
- No redefinition of O1 decision/execution/proof enums, W7 DialogueState, W8 lifecycle, W9 force-state authority, W5c composition, W10 voice, V3 performance, or V4 packaging.

## Decisions

### D-T07-001: One sectioned ceremony envelope

The carrier defines six required sections: `subject`, `environment`, `attempt`, `axes`, `expiry`, and `evidence`. A ceremony result is not complete merely because one section is present; missing, unknown, or version-drifted required fields fail closed.

The `subject` section identifies the scenario/contract subject. The `environment` section records the exact repo SHA, dirty verdict, branch, scheme/config, app bundle/version/hash, machine/OS/target, scenario version, and contract version. The `attempt` section records immutable attempt identity, finite launch mode, status, failure reason, and timestamps. The `axes` section records `decision`, `execution`, and `proof` with the canonical O1 state, predicate version, current flag, pass result, and typed reason. The `expiry` section records current/expired state, trigger, and versioned retest requirements. The `evidence` section contains immutable references and their exact artifact/build hashes.

Alternative considered: use a flat verdict and a filename/version reference. Rejected because it cannot distinguish axis-local failure, stale artifacts, or a changed environment.

### D-T07-002: Exact subject and artifact identity join

The ceremony may establish a same-subject join only when all required identity fields are exact equal: repo SHA, dirty verdict, scheme/config, bundle/version/hash, T06 subject identity, machine/OS/target, scenario version, and contract version. Branch is recorded but SHALL NOT replace the repo SHA. Artifact bytes/digests are join inputs; filename or version alone is insufficient.

Alternative considered: permit branch plus bundle/version as a practical join. Rejected because a branch can point to different commits and a same-version artifact can have different bytes.

### D-T07-003: Reuse canonical O1 vocabulary and block downstream only

The three axes SHALL reuse the canonical O1 decision/execution/proof state vocabulary. V2 may add typed ceremony fields such as predicate version, current flag, claim cap, and reason, but SHALL NOT copy or fork O1 enums. A missing or invalid field SHALL block that axis and its downstream joins while preserving the raw facts and results of unrelated axes.

Alternative considered: normalize all axis failures into one global failure or define V2-local enum copies. Rejected because global failure hides independent evidence and duplicated enums drift.

### D-T07-004: Immutable append-only attempt ledger

Launch mode is a finite explicit choice: `xcode_run`, `signed_app`, or `archive`. Every mode change, artifact change, or environment change creates a new immutable attempt ID. A failed attempt records artifact, mode, typed reason, timestamp, and evidence; a later success appends a new attempt and SHALL NOT update or delete the failed row. Hidden retry and automatic fallback within one attempt are forbidden.

Alternative considered: keep one current attempt and update it after retry. Rejected because it erases the failure evidence that the ceremony is required to expose.

### D-T07-005: Expiry invalidates current joins and requires retest

Build, environment, scenario, or contract changes, waiver expiry, and a recovery incident transition a current result to `EXPIRED`. Expiry derives versioned `RETEST_REQUIRED` requirements. Only a new immutable attempt satisfying all required predicates may become current; an expired result remains historical evidence and cannot satisfy a final join.

Alternative considered: keep a previous pass current until a new run finishes. Rejected because stale proof would survive the exact condition that invalidated it.

### D-T07-006: Synthetic evidence is shape-only

Synthetic T06 fixtures may test schema shape, exact mismatch, missing/duplicate fields, and stale joins. Every such fixture SHALL carry `synthetic=true`, `proof_class=local`, and `satisfies_t07b_prerequisite=false`. Synthetic or local green SHALL NOT unlock T07b, operator-pass, or V2 DONE.

Alternative considered: treat a complete synthetic receipt as an operator rehearsal pass. Rejected because it has no real current T06 subject or operator evidence.

### D-T07-007: Source and final gates remain phased

`verify-operator-ceremony-source` remains `PLANNED_GATE_NOT_YET_EXECUTABLE` until its target, official wiring, independent checker/behavior suite, and deliberate-red negatives materialize. T07b and `verify-operator-ceremony` remain `PHASED_BLOCKED_UNTIL_REAL_T06` until the real current T06 same-subject receipt, all registry prerequisites, and explicit K3 ignition are present. P8 and the shared plan flip require a later K4 transaction.

Alternative considered: describe the planned Makefile commands as current gates. Rejected because the live Makefile has no such targets and the registry marks them planned.

## Risks / Trade-offs

- [Risk] Same bundle/version or same branch is mistaken for same subject. → Mitigation: require exact repo SHA, dirty verdict, artifact bytes/digest, environment fields, and T06 subject identity.
- [Risk] A later success overwrites an earlier launch failure. → Mitigation: append-only attempt IDs and a deliberate-red for attempt mutation/deletion.
- [Risk] A stale waiver or environment change leaves an old pass current. → Mitigation: explicit expiry triggers, versioned retest requirements, and old-pass exclusion from current joins.
- [Risk] Synthetic fixtures masquerade as T07b prerequisites. → Mitigation: require the three synthetic cap fields and make `satisfies_t07b_prerequisite=false` normative.
- [Risk] Phantom gate names are treated as executable. → Mitigation: retain planned labels until target, wiring, checker, behavior suite, and deletion/mutation negatives are present.
- [Risk] V2 forks O1 or absorbs W7/W8 semantics. → Mitigation: reuse canonical O1 states and state explicit ownership boundaries in the contract.

## Migration Plan

1. This transaction writes only the greenfield V2 carrier artifacts and validates them locally.
2. A later K2 may materialize the versioned schema, source checker, behavior fixtures, and planned source gate.
3. A later K3 may attempt T07b only after real current T06, all registry prerequisites, and explicit ignition are fresh and exact-joined.
4. A later K4 may materialize the final ceremony gate, write the V2 runtime receipt, and perform any package/state transition; this carrier does not do so.
5. The W9/V2 shared plan is flipped only after W9 and V2 each exist, each strict validates, and both pair receipts are present; the flip is one atomic local commit in this round.

Rollback for this carrier-only artifact is a new reviewed amendment or a pinned rollback dispatch; do not delete the change or weaken the synthetic/T06 boundary silently.

## Open Questions

- The implementation phase must freeze the concrete versioned schema and checker input format while reusing the canonical O1 vocabulary.
- The real T06 receipt path and registry prerequisite set must be resolved fresh at K3; this carrier records the join requirement but does not invent the receipt.
- The exact K4 package transition and final registry write remain separate authorization and proof work.
