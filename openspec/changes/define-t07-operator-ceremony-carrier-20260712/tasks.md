## 1. T07a Ceremony Contract

- [ ] 1.1 Define the versioned six-section ceremony envelope for subject, environment, attempt, axes, expiry, and evidence; verify unknown and missing fields fail closed. (verification)
- [ ] 1.2 Define the exact subject/artifact identity tuple and equality join, including repo SHA, dirty verdict, scheme/config, bundle/version/hash, machine/OS/target, scenario/contract versions, and T06 subject identity. (verification)
- [ ] 1.3 Reuse canonical O1 decision/execution/proof states and define per-axis predicate version, current flag, pass result, reason, claim cap, and downstream-only blocking. (verification)
- [ ] 1.4 Define the finite launch-mode vocabulary `xcode_run|signed_app|archive` and the immutable append-only attempt ledger; add failure-retention and hidden-retry negative cases. (TDD/verification)
- [ ] 1.5 Define expiry triggers, `EXPIRED` → `RETEST_REQUIRED` requirements, and fresh-attempt rules; add waiver-expiry and stale-result negative cases. (TDD/verification)
- [ ] 1.6 Define synthetic T06 fixture fields `synthetic=true`, `proof_class=local`, and `satisfies_t07b_prerequisite=false`; cap all synthetic claims at local schema/join shape. (verification)

## 2. V2 Source Gate Contract

- [ ] 2.1 Keep `verify-operator-ceremony-source` explicitly `PLANNED_GATE_NOT_YET_EXECUTABLE` until target, official wiring, independent checker, behavior suite, and deliberate-red negatives exist.
- [ ] 2.2 Specify source-gate deliberate-red coverage for deleted target/checker/wiring, identity SHA mismatch, artifact hash mismatch, mode-switch overwrite, stale receipt replay, expired waiver, and synthetic T07b masquerade. (TDD)
- [ ] 2.3 Define the local proof cap `local_schema_join_only` and ensure OpenSpec strict validation cannot be reported as source-gate green.
- [ ] 2.4 Preserve W7/W8/W9 ownership boundaries: V2 consumes facts and receipts only; it does not implement DialogueState or lifecycle state machines.

## 3. T07b and P8 Blocked Conditions

- [ ] 3.1 Record T07b as `PHASED_BLOCKED_UNTIL_REAL_T06` until a real current T06 same-subject receipt, all registry prerequisites, and an explicit K3 ignition key are present.
- [ ] 3.2 Record P8 final ceremony and `verify-operator-ceremony` as blocked until T07b evidence is complete; synthetic/local fixtures MUST NOT unlock operator-pass or V2 DONE.
- [ ] 3.3 Preserve the final proof boundary: operator evidence requires exact current axes, immutable attempts, current expiry, all prerequisites, and no override. (verification)
- [ ] 3.4 Keep K1 carrier writeback, K2 apply, K3 ignition, and K4 merge/state flip as independent keys; do not add implementation or launch work to this carrier transaction.

## 4. Carrier Closeout and Future Implementation Handoff

- [ ] 4.1 Run `openspec validate define-t07-operator-ceremony-carrier-20260712 --strict`, `openspec validate --all --strict`, and `git diff --check`; capture each rc separately. (verification)
- [ ] 4.2 Bind the greenfield V2 files, V2 change id, pinned W9/V2 plan SHA, KEY-RECEIPT-2 SHA, current HEAD, and unchanged-before-flip shared-plan state in the V2 pair receipt.
- [ ] 4.3 Test all six W9+V2 atomic-flip conditions: W9 change exists, V2 change exists, W9 strict rc0, V2 strict rc0, W9 pair receipt exists, and V2 pair receipt exists.
- [ ] 4.4 After all six conditions are independently true, flip the shared plan once to `SUPERSEDED_BY_CARRIER` and record the post-flip plan SHA in the atomic receipt; do not flip on partial evidence.
- [ ] 4.5 Commit only the V2 change artifacts and the shared-plan flip, verify a clean worktree, and do not push. (verification)
