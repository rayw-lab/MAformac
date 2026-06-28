## Why

Mainline currently has UIUE bridge semantics, runtime vocabulary, and route-board expectations split across separate documents, while `docs/CURRENT.md` still records the Runtime -> Presentation bridge as `not_proposed`. This change creates the mainline-visible, contract-only carrier accepted by human review so C01/C03/C06/C18 can move out of vague owner-trigger blocker state without claiming runtime readiness.

## What Changes

- Add a thin Runtime -> Presentation bridge carrier that maps UIUE candidate/provenance semantics into mainline authority.
- Define observable bridge vocabulary for runtime results, presentation snapshots, trace envelopes, proof-class display caps, and scope-origin handling.
- Record that UIUE documents remain candidate/provenance inputs until mainline references them through this carrier.
- Record the human-review decisions:
  - HR-01: use `create_mainline_visible_carrier_with_mapping`.
  - HR-02: do not extend Core `ScopeOrigin` with `missing`; missing/unresolved scope is expressed through result/presentation metadata or explicit failure reason, with UI-local display treatment allowed only as presentation concern.
  - HR-03: R5 may start only after this mainline owner receipt/carrier lands.
- Keep this as docs-local + OpenSpec proof only.

## Capabilities

### New Capabilities

- `runtime-presentation-bridge`: Runtime-to-presentation mapping contract for bridge authority, result vocabulary, snapshot fields, scope-origin disposition, proof-class display caps, and UIUE provenance boundaries.

### Modified Capabilities

- None.

## Impact

- Affected docs/OpenSpec:
  - `openspec/changes/define-runtime-presentation-bridge/`
  - `docs/CURRENT.md`
  - `docs/README.md`
  - `docs/project/phase0/uiue-r4-mainline-coauthor-receipt-2026-06-28.md`
  - `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md`
- No Swift implementation.
- No Core enum expansion.
- No C5 retrain, C6 acceptance/comparison, runtime backend, voice, golden-run, endpoint readiness, mobile/true-device proof, UIUE merge, V-PASS, S-PASS, or U-PASS.

## Non-goals

- Do not implement runtime backend, ASR/TTS, golden-run, model evaluation, candidate comparison, or UIUE R5 behavior.
- Do not claim mainline runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, mobile-ready, true-device-ready, or V-PASS.
- Do not copy UIUE docs wholesale into a second same-meaning bridge SSOT.
- Do not add `missing` to Core `ScopeOrigin`.

## Success Criteria

- `openspec validate define-runtime-presentation-bridge --strict` passes.
- `openspec validate --all --strict` passes.
- `git diff --check` passes.
- `docs/CURRENT.md` and `docs/README.md` no longer conflict with the bridge carrier state.
- C01/C03/C06/C18 are documented as closed by this contract-only carrier for dispatch readiness, while downstream runtime/mobile/model gates remain locked.
