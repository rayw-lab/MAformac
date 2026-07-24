status: `carrier_writeback_only`
status_source: `D-152 M16-013/014/015 + KEY-RECEIPT-2-CARRIER`
status_updated: `2026-07-12`
package_id: `V2`
change_id: `define-t07-operator-ceremony-carrier-20260712`
plan_sha256: `30397a2c6625cca815b2b8664eab4983ce92a8b08b0944b7b226e7f4dd1a11b8`
proof_cap: `local_static_contract_only`

## Why

The V2/T07 operator ceremony needs a single, typed contract for subject and environment identity, launch attempts, per-axis evidence, expiry, and retest before any implementation or operator run can be considered. Without this carrier, a later ceremony could mistake synthetic fixtures, stale receipts, or a failed attempt overwritten by a later success for real operator evidence.

This is the greenfield V2 carrier paired with the already amended W9 carrier. It deliberately prepares T07a contract shape while keeping T07b and the final ceremony blocked on a real current T06 receipt, all registry prerequisites, and a separate ignition key.

## What Changes

- Introduce the `operator-ceremony` capability as a self-contained V2/T07a contract.
- Define exact ceremony sections for `subject`, `environment`, `attempt`, `axes`, `expiry`, and `evidence`, including the identity tuple and join predicates.
- Define finite launch modes and an immutable append-only attempt ledger; switching launch mode starts a new attempt and cannot overwrite a prior failure with success.
- Define O1 axis enums, per-axis reason/version/current validity, downstream-only fail-closed behavior, and exact artifact/build/session joins.
- Define expiry and retest semantics: an expired or invalidated result cannot remain current and a retest creates a new attempt with fresh evidence.
- Define the synthetic T06 cap: synthetic fixtures may test local shape/mismatch only and MUST carry `synthetic=true`, `proof_class=local`, and `satisfies_t07b_prerequisite=false`.
- Record `verify-operator-ceremony-source` as `PLANNED_GATE_NOT_YET_EXECUTABLE` and keep T07b/P8 `PHASED_BLOCKED_UNTIL_REAL_T06`.

## Non-goals

- Do not implement the ceremony schema, checker, Makefile targets, registry wiring, runtime runner, operator UI, or evidence writer.
- Do not run or authorize T07b, operator-pass, V2 DONE, V-PASS, merge, package state transition, or production acceptance.
- Do not define DialogueState window/focus/readback semantics owned by W7.
- Do not define session, cancel, recovery, or lifecycle state transitions owned by W8.
- Do not modify the W9 carrier, the W9/V2 shared plan, or any application/runtime source file in this greenfield change.

## Capabilities

### New Capabilities

- `operator-ceremony`: T07a typed ceremony contract, immutable attempt ledger, expiry/retest rules, synthetic evidence cap, and T07b/P8 blocking conditions.

### Modified Capabilities

- None. W7, W8, and W9 remain separate owner carriers.

## Success Criteria

- The carrier contains observable SHALL requirements and GIVEN/WHEN/THEN scenarios for M16-013, M16-014, and M16-015.
- The contract distinguishes local schema/join evidence from real operator evidence and makes synthetic fixtures unable to satisfy T07b.
- The source gate and final ceremony gate remain explicitly planned/blocked rather than being described as executable or green.
- `openspec validate define-t07-operator-ceremony-carrier-20260712 --strict` and `openspec validate --all --strict` pass after the four carrier artifacts are written.
- A V2 pair receipt binds this change, the pinned W9/V2 plan, the key receipt, exact file SHAs, and the pre-atomic-flip HEAD; the later shared-plan flip is performed only after the six all-of conditions are independently tested.

## Impact

- OpenSpec only: a new `operator-ceremony` contract tree under `openspec/changes/`.
- Future implementation may add a versioned ceremony schema, source checker, behavior fixtures, and materialized gates under a separate apply key.
- V2 consumers must preserve W7/W8 ownership boundaries and must not promote local/mock/synthetic evidence to operator proof.
