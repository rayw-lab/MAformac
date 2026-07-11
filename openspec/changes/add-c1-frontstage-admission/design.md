## Context

This is the containment half of int-v5b. The implementation base is `a3160c88ff2cde29a4bf3e319330ee6d463fbc4f`; PR #42 merge `f5ef62705b3e7bf4551bad1b7637f927275d149a` is an ancestor. v5a's generated bundle and v2 action-readback schema are present, while `actionDemoProven=0/120` remains unchanged.

## Decisions

### AD-001 — containment is a typed terminal, not a runner substitute

`FrontstageVoiceSession` owns a stable `sessionID` and monotonic per-session sequence. Its only current operation produces a typed `refusal_no_available_tool`, `stateMutation=false`, and no readback. It SHALL NOT own matrix evaluation, tool planning, execution, or a production runner.

### AD-002 — composition keeps the UI boundary narrow

`FrontstageRuntimeComposition` owns one `FrontstageVoiceSession`. Both customer MicDock callbacks call `composition.session`; no callback may call `MockVoicePresetPlanner` or a legacy mock-intent helper. The App adapter accepts the typed turn and preserves the existing state cells/readbacks while presenting the denial.

### AD-003 — ContentView HIGH-surface risk acknowledgement

The pre-edit index reported `ContentView` HIGH (188 upstream impacts); the fresh implementation-worktree index reports CRITICAL (211 upstream impacts; direct callers: `MAformacApp`, `AmbientBurstHarnessScreen`, file surface). The user-authorized surface remains exactly the two customer MicDock callback expressions plus their new containment handoff. No layout, reset, scrub, force-state, mock planner internals, or runner wiring is changed.

Gate-strength delta: a source-contract test asserts both customer callbacks name `frontstageRuntimeComposition.session`, rejects `onMockVoiceSubmit: applyMockVoiceColdIntent`, and rejects the mock planner name inside the containment submission function. Runtime unit tests prove the typed turn remains refusal/no-write/no-readback across sequences 1/2.

### AD-004 — five-key receipt ABI is latest-turn-only

With `C1_FRONTSTAGE_RECEIPT_EMIT=1`, all five inputs are mandatory: nonempty run ID, 32 lowercase-hex nonce, writable absolute `C1_RUN_DIR`, and 40 lowercase-hex source head in addition to emit. Invalid or missing foreign inputs write nothing and do not fall back. The path is exactly `$C1_RUN_DIR/receipts/c1/frontstage-route-receipt.v1.json`; write is sibling-temp, fsync, then replace. The receipt records the typed containment result and one current turn only.

Without foreign emit, a local standalone containment receipt may use a generated identity under `.build/c1-run`, but it is not multi-turn ABI evidence. Old FRONTSTAGE aliases are forbidden.

### AD-005 — explicit blocked handoff

`DemoRuntimeSessionRunner`, `DemoRuntimePartialPlan`, `ToolCallFrame`, production default composition, positive admission, and the T04-dependent customer façade are `BLOCKED_WAIT_T03_T04_INTERFACE_CUT`. No containment code imports, initializes, or binds them.

## Risks

- A denial UI can be mistaken for a production route. Receipts and tests label the proof `frontstage_route_local_integration` / `local_unit`; no action-success, operator, or V-PASS claim is emitted.
- Receipt freshness is not a history proof. The schema has one current object and makes no monotonic or duplicate-history assertion.
