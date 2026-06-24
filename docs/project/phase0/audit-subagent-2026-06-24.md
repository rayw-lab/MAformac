---
status: absorbed_precheck
artifact_kind: same_vendor_phase0_skeleton_audit
authority: audit_record_not_ssot
retire_trigger: "Retire after phase0-d1-d10-closeout.md records final Phase 0 gate materialization and follow-up audit disposition."
expires: "2026-07-15"
---

# Phase 0 Manifest Skeleton Audit - 2026-06-24

## Verdict

CLEAR_WITH_FIXES_RECOMMENDED

The seven schema skeletons, README, and next-seven sequence are aligned with the accepted Phase 0 order: C02+C01, C03, C04, C05, C07, C06, C24. They stay in `docs/project/phase0`, remain manifest skeletons, and do not authorize retrain, model evaluation, endpoint-ready claims, demo-golden-run, voice, UIUE merge, direct archived-spec edits, or concrete enum/value lock.

## Findings

### P0

None.

### P1

None.

### P2

1. `docs/project/phase0/c02-authority-matrix.schema.yaml:74` and `docs/project/phase0/c05-pocock-stage-matrix.schema.yaml:70` use `uiue/visual-ssot-state-consume` as if it were a filesystem path, but that path is not present in the current worktree. This is not a blocker because the intended meaning is "UIUE branch/consumer," not mainline source truth. Recommended patch: add a `reference_kind` field or split current docs from future branch/worktree references, e.g. `docs/uiue-roadmap-2026-06-23-draft.md` as current doc evidence and `uiue/visual-ssot-state-consume` as `future_branch_ref`.

2. `docs/project/phase0/c03-full-demo-artifact-matrix.schema.yaml:29-45` and `:48-59` cover the right concepts (`demo_subset_of_full`, same source contract, generated proof, full training fail-fast), but the proof can still become prose-only unless the later manifest records a concrete proof artifact. Recommended patch: add required fields such as `subset_key`, `proof_artifact_path`, `source_snapshot_id`, and `verification_exit_code`. This keeps "demo subset of full" and "same source contract" reproducible instead of asserted.

3. `docs/project/phase0/c04-archived-spec-disposition.schema.yaml:41-48` correctly lists all seven current `openspec/specs/*/spec.md` files, including `lora-training`. To further prevent `retrain-c5-lora-d-domain` from drifting against old `lora-training` semantics, the schema should explicitly record legacy collision targets beyond the archived spec file. Recommended patch: add a field such as `legacy_collision_targets` or `supersedes_or_conflicts_with_change_paths`, seeded with `openspec/specs/lora-training/spec.md`, `openspec/changes/archive/2026-06-21-define-lora-training`, and any active stale LoRA carriers that must not be mistaken for the new retrain contract.

## Coverage Notes

- Order is faithful: `README.md:20-26` and `next-seven-sequence.md:7-13` match the accepted first-seven sequence.
- Boundary language is explicit: `README.md:7`, `README.md:30-33`, and `next-seven-sequence.md:17-23` deny implementation, OpenSpec archive, training, evaluation, endpoint, golden-run, UIUE merge, and `contracts/` promotion.
- C06/C24 remain skeleton-only: C06 sets empty value lists and downstream placeholders at `c06-runtime-outcome-enum-skeleton.schema.yaml:14-22`, `:23-48`, `:59-68`; C24 limits future verification scope and directed implications at `c24-status-vocabulary-graph.schema.yaml:13-23`, `:51-64`.
- C04 covers all seven archived specs observed under `openspec/specs`: demo-experience, lora-training, scenario-state-protocol, semantic-function-contract, tool-execution, vehicle-capabilities, vehicle-tool-bench.
- C05/C07 guard the C5 LoRA false-start pattern: C05 denies implementation permission and lists forbidden next actions at `c05-pocock-stage-matrix.schema.yaml:14-21`, `:36-45`; C07 narrows decision lifecycle work to touched decisions and blocks silent mutation at `c07-decision-lifecycle-manifest.schema.yaml:13-18`, `:52-56`.

## Missing Fields

- C02/C05: add `reference_kind` for filesystem path vs current doc vs branch/worktree placeholder.
- C03: add `subset_key`, `proof_artifact_path`, `source_snapshot_id`, and `verification_exit_code`.
- C04: add `legacy_collision_targets` / `supersedes_or_conflicts_with_change_paths`.

## Boundary Risks

- A nonexistent UIUE branch-like path could create false verifier failures or accidentally promote a consumer branch into source authority.
- C03's generated-proof checks are directionally correct but should not become narrative-only receipts.
- C04 is safe for archived specs, but legacy LoRA change-path aliases should be named explicitly to avoid old/new retrain language collisions.

## Recommended Patches

Apply the three P2 patches before or during the next fill step. They are not required to repair the skeletons before proceeding, but they will reduce route-control ambiguity for later agents.

## One-Sentence Conclusion

The Phase 0 skeleton can proceed to the next step, "fill OpenSpec-ready proposal/tasks delta"; it does not need blocking skeleton repair first, though the P2 patches should be absorbed before relying on the manifests as filled artifacts.

## Main-Thread Absorption

Status: all three P2 recommendations absorbed after this audit.

- P2-1 absorbed in `c02-authority-matrix.schema.yaml` and `c05-pocock-stage-matrix.schema.yaml`: added `reference_kind` / `carrier_kind`, added `docs/uiue-roadmap-2026-06-23-draft.md` as current doc evidence, and kept `uiue/visual-ssot-state-consume` as `future_branch_ref`.
- P2-2 absorbed in `c03-full-demo-artifact-matrix.schema.yaml`: added `source_snapshot_id`, `subset_key`, `proof_artifact_path`, `verification_exit_code`, and required proof fields for the generated checks.
- P2-3 absorbed in `c04-archived-spec-disposition.schema.yaml`: added `legacy_collision_targets`, `supersedes_or_conflicts_with_change_paths`, and seeded current LoRA collision targets including archived, active, and parked carriers.

Verification after absorption:

- `ruby -e 'require "yaml"; Dir["docs/project/phase0/*.yaml"].sort.each { |f| YAML.load_file(f); puts "OK #{f}" }'`
- `reference check OK` for current-file, current-directory, active-OpenSpec-change, and LoRA collision target paths; `future_branch_ref` and `not_yet_assigned` are intentionally exempt from current worktree existence.
