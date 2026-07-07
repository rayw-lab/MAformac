status: `active_construction`
status_source: `D-115/N4`
status_updated: `2026-07-07`

## Why

Accepted G01-G28 default-scope decisions establish that omitted scope in demo utterances must resolve through C2 `default_scope`, not `全车`, not `all`, and not YAML order such as `scope.first`.

This must be its own OpenSpec change because the behavior crosses C2 state cells, C3 execution, state application, C5 training targets, C6 gold, readback/TTS, demo scenarios, demo-golden-run freeze points, and UIUE state presentation. Keeping it as a standalone carrier prevents retrain-c5, rebuild-c6, golden-run, or UIUE from each redefining default-scope behavior.

## What Changes

- Add observable behavior for omitted scope, explicit scope, explicit fan-out, unaccepted collection-like wording, and scope-origin presentation.
- Define C2 `default_scope` as the authority for scoped state cells.
- Preserve explicit non-default scopes such as `副驾`, `左后`, `后排`, `中控屏`, and `前排`.
- Preserve explicit `全车` fan-out and accepted collection aliases such as `所有车窗`, `四个车窗`, and `车窗都`.
- Define how omitted scope composes with `clarify_tag` and fast/slow route tiers.
- Define readback/presentation metadata: `scope_origin`, `resolved_scope`, and channel-specific presentation policy.
- Define apply-closeout enforcement gates for default-scope SSOT, C5/C2 scope-candidate parity, and single-source scope-origin propagation.
- Define legacy unscoped demo-key disposition as a future implementation blocker, not a second state source.
- Carry UIUE intersections only as external merge-check dependencies. Current UIUE evidence is downgraded to `external_reference_unverified_current_head=17f2af1`; this proposal does not cite UIUE file:line evidence and does not claim UIUE alignment.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `tool-execution`: add omitted-scope defaulting, explicit-scope preservation, accepted collection-alias fan-out, unaccepted collection-like handling, scope-origin presentation metadata, and omitted-scope x `clarify_tag` route composition.

## Non-Goals

- No runtime implementation in this proposal step.
- No changes to `Core`, `contracts`, training code, archived specs, or UIUE external worktree files.
- No LoRA data generation or training.
- No C6 model-quality run or D-domain base recalibration.
- No demo-golden-run execution, golden ID freeze, readback freeze, or UIUE scene-tag freeze.
- No voice work.
- No endpoint-ready, training-ready, C6-ready, demo-golden-ready, voice-ready, UIUE-ready, V-PASS, S-PASS, or U-PASS claim.

## Success Criteria

- `openspec validate define-demo-default-scope --strict` passes.
- `openspec validate --all --strict` passes.
- `define-demo-default-scope` owns the G01-G28 observable behavior carrier.
- `retrain-c5-lora-d-domain`, `rebuild-c6-four-layer-bench`, and `define-demo-golden-run-and-voice` depend on this carrier instead of redefining default-scope semantics.
- UIUE is recorded as `external_reference_unverified_current_head=17f2af1` with G28 retained as a merge check only.
- A reviewer can see that apply closeout must prove the SSOT mechanically, not only record pre-implementation grep evidence.

## Non-Automated Success Signals

- A reviewer can see that omitted-scope behavior is no longer hidden inside C5/C6/golden/UIUE drafts.
- A reviewer can see that structural OpenSpec validation is not being used as permission to train, evaluate, execute demo-golden-run, run voice, or merge UIUE.

## Impact

- New active change: `openspec/changes/define-demo-default-scope/`.
- Spec delta: `openspec/changes/define-demo-default-scope/specs/tool-execution/spec.md`.
- Dependency-only updates to active draft carriers:
  - `openspec/changes/retrain-c5-lora-d-domain/design.md`
  - `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
  - `openspec/changes/rebuild-c6-four-layer-bench/design.md`
  - `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`
  - `openspec/changes/define-demo-golden-run-and-voice/tasks.md`
