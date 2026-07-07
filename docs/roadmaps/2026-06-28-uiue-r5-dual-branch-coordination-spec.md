---
date: 2026-06-28
artifact_class: r5_dual_branch_coordination_spec
authority: planning_and_coordination_basis
status: draft_for_user_review
proof_class: docs/local
canonical_for:
  - UIUE R5 coordination
  - package ordering
  - proof caps
  - branch ownership
not_canonical_for:
  - mainline runtime-presentation field names
  - result enum definitions
  - typed snapshot schema
  - proof-class implementation
  - implementation completion
  - runtime/mobile/voice/model/golden readiness
  - UIUE merge readiness
shared_authority_order:
  1: /Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/
  2: /Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift
  3: /Users/wanglei/workspace/MAformac tests and receipts
  4: this UIUE coordination spec as consumer coordination
dispatch_status: not_dispatch_ready_until_live_probe_plus_package_calibration
---

# UIUE R5 Dual-Branch Coordination Spec

This document is the UIUE R5 coordination roadmap for the current dual-branch state. It constrains branch ownership, package ordering, proof caps, calibration vocabulary, and stop conditions. It is not a dispatch plan, not an implementation plan, and not a completion receipt.

This document is canonical only for UIUE R5 coordination. It cannot override, extend, or reinterpret mainline shared runtime fields. Shared field names, result enums, typed snapshot schema, proof-class implementation, and runtime authority remain owned by mainline OpenSpec, mainline typed carrier code, and mainline tests/receipts.

If a future mainline window needs to cite this file, it may add a short pointer or receipt. That pointer must not copy this file wholesale and must not promote this UIUE coordination spec into shared runtime authority.

## Current Live Truth

Live probe at writing time:

| Repo | Branch | HEAD | Dirty state relevant to this spec |
|---|---|---:|---|
| `/Users/wanglei/workspace/MAformac-uiue` | `uiue/phase4-default-scope-presentation` | `70128d8c845d5c5348f56120de3a25740e73deb7` | untracked R5 grill pack, R5 loop-competition folder, R5 commander handoff, and this roadmap path |
| `/Users/wanglei/workspace/MAformac` | `codex/rebuild-c6-doc-absorption-20260624` | `0a2ff0f7d30d6caf2d48f018f6b874828fb70c03` | pre-existing dirty residual in `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, and `Tools/agent-platform-plugin-refs/` |

Mainline `0a2ff0f` adds typed Runtime-Presentation bridge contracts. That is candidate coverage for some R5 rows, not a blanket `covered` verdict. Any row still needs live-probe plus test/receipt calibration before dispatch.

## Source Artifacts

- `docs/grill-tournament/uiue-r5-runtime-presentation-grill-pack-2026-06-28.md`
- `docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md`
- `docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`
- `docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/ledger.md`
- `docs/handoffs/2026-06-28-uiue-r5-commander-handoff-from-grill-loop.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md`

## Coordination Principles

1. `needs-validation` means evidence gap, not implementation gap.
2. No implementation work may be created until calibration proves a row is `remaining`.
3. `remaining` means a live-probe plus test/receipt comparison confirmed missing carrier, missing evidence, or conflicting authority. It cannot be assigned from memory or expectation.
4. P0/P1 rows do not become `covered` from roadmap prose. They need current mainline/UIUE evidence.
5. `merge-only` preserves provenance under canonical artifacts. It does not silently delete rows and does not automatically create standalone implementation work.
6. `non-claim-only` is reserved for voice, model, golden, mobile, true-device, C6, runtime, endpoint, and V/S/U-PASS non-claim boundaries. It is stricter than ordinary `deferred`.
7. UIUE may record accepted customer-facing affordance policy, but it may not invent shared Runtime-Presentation fields.

## Calibration Vocabulary

| Calibration | Meaning | Dispatch implication |
|---|---|---|
| `needs-validation` | Evidence has not yet been calibrated against live repo, mainline carrier, tests, or receipts. | Validate first. Do not implement from this state. |
| `remaining` | Live-probe plus test/receipt comparison confirmed the row is not covered or has conflicting evidence. | Eligible for a later dispatch document after user/commander approval. |
| `human-policy-accepted` | User accepted the product policy; no further human decision is needed for that baseline. | May be reflected in UIUE policy docs/specs, still not runtime proof. |
| `merge-only` | Row folds into a canonical artifact while preserving row provenance. | Do not delete provenance. Do not open standalone work unless later promoted. |
| `spike-required` | A bounded falsification experiment is required before implementation. | Spike receipt only; no implementation claim. |
| `non-claim-only` | Row exists to prevent false readiness claims for future lanes. | Preserve as guard. Do not treat as R5 blocker or R5 completion proof. |
| `deferred` | Later product/human review or later lane. | Keep visible, but do not open code work from this spec. |
| `drop-after-target` | Drop only after replacement or merge target is explicit. | No deletion until target is recorded. |

## Thirteen-Package Coordination Table

| Package | Authority owner | Depends on | Allowed action class | Current calibration | Candidate coverage note | Dispatch implication | Validation gate | Proof cap |
|---|---|---|---|---|---|---|---|---|
| `HR-ACCEPTED-AFFORDANCE-POLICY` | UIUE product/presentation | User acceptance of C155/C172/C194 | Record accepted product policy | `human-policy-accepted` | User accepted: no customer-facing `operatorReview` / `acceptance`; summary only expands; gear display-only; mock controls only in expanded controls with readback. | May be written into UIUE docs/specs; no runtime claim. | Forbidden-term grep and a11y/display-only wording check. | docs/local only |
| `M1-mainline-P0-bridge-contract` | mainline Runtime-Presentation owner | Mainline carrier and typed contract | Authority calibration | `needs-validation` | Mainline `0a2ff0f` may cover part of C012/C060/C105; verify row-by-row before dispatch. | Validate first; do not create implementation work unless a row becomes `remaining`. | Mainline OpenSpec strict, typed carrier, focused tests/receipts. | not runtime/mobile/true-device/V-PASS |
| `S1-shared-P0-proof-governance` | commander plus both branches | M1 candidate authority | Proof-governance calibration | `needs-validation` | Mainline finite proof classes and display caps are candidate coverage, not a package verdict. | Validate proof caps before UIUE consumer work. | Proof-class checker, forbidden-claim grep, stale-claim grep, receipt wording. | docs/local/unit/simulator caps only |
| `M2-mainline-P1-contract-test` | mainline Runtime-Presentation owner | M1/S1 calibration | Contract/test calibration | `needs-validation` | Mainline typed bridge contracts may cover some rows; current spec does not assign `covered`. | Validate first; later dispatch needs user/commander approval. | Targeted tests or receipts for each promoted row. | not model/C6/voice/golden readiness |
| `U2-uiue-consumer-mapping-test` | UIUE consumer owner | Mainline names/result/snapshot/proof class stable | UIUE consumer calibration | `needs-validation` | Existing UIUE Reduce Motion and local proof are local presentation evidence only. | UIUE may not invent shared fields. Consumer mapping waits on mainline stability. | UIUE matrix/checker against mainline contract names. | UIUE local/simulator only |
| `S2-shared-contract-proof-reconcile` | commander plus both branches | M2 and U2 calibrated | Cross-branch reconcile | `needs-validation` | No shared reconcile verdict exists in this spec. | Reconcile wording, names, dirty state, and proof caps before cleanup. | Commander reads both repos and records row-level disposition. | coordination proof only |
| `M3-mainline-merge-only-fixture-or-doc` | mainline owner | M1/M2 calibrated | Merge-only provenance preservation | `merge-only` | 52 rows fold into canonical mainline fixtures/docs if target exists. | Preserve row IDs. No standalone work unless promoted after calibration. | Merge target list and provenance check. | local/docs/unit only |
| `U3-uiue-merge-only-local-proof` | UIUE owner | U2 calibrated | Merge-only local proof preservation | `merge-only` | 21 rows fold into canonical UIUE local proof artifacts if target exists. | Preserve row IDs. Do not claim runtime/mobile proof. | UIUE proof matrix/checker references row IDs. | UIUE local/simulator only |
| `S3-shared-merge-only-receipt-hygiene` | commander plus both branches | S2/M3/U3 calibrated | Merge-only receipt hygiene | `merge-only` | 38 rows should become receipt/checklist hygiene, not standalone tasks. | Keep non-claims and dirty discipline visible. | Receipt includes repo/branch/HEAD/dirty/proof/residual. | coordination proof only |
| `H1-human-review-product-policy` | product/human review | Later user review | Human/product review backlog | `deferred` | Not covered by the accepted HR trio. | No code truth until wording/interaction is accepted. | Human checklist with accepted/rejected wording. | human review only |
| `K1-spike-before-implementation` | spike owner decided later | Package-specific uncertainty | Minimal falsification spike | `spike-required` | No row in this package is implementation-ready from roadmap text. | Spike receipt only; no build-out. | Pass/partial/blocked spike receipt with proof class. | spike/local proof only |
| `F1-future-lane-nonclaim-guard` | future lane owners | Later C5/C6/voice/golden/mobile gates | Non-claim guard | `non-claim-only` | P1 rows inside this package are claim-sensitive but not R5 implementation authorization. | Preserve future boundaries. Do not make R5 blockers or completion claims. | Non-claim grep and future-lane ledger. | no runtime/model/voice/golden/mobile/true-device/V-PASS |
| `D1-drop-after-merge-target` | commander cleanup | Explicit replacement target | Drop only after target | `drop-after-target` | Single duplicate row may be dropped only after linked target exists. | Do not delete without replacement evidence. | Replacement/merge target recorded. | docs/local only |

## Coordination Gates

### Gate 0: Baseline Freeze

Before dispatching any window, freeze or commit the current UIUE R5 docs baseline with exact pathspecs. Do not use `git add .`. Do not mix mainline dirty residual into UIUE commits.

This coordination spec may be included in the same UIUE docs commit as the R5 grill/loop/handoff package, but downstream windows must not consume an unstable uncommitted baseline.

### Gate 1: Package Calibration

Calibration only produces state labels. It does not produce dispatch docs and does not authorize implementation.

Dispatch documents require later user/commander approval. M1/S1/M2 must be calibrated against current mainline before UIUE consumes shared field names, result enums, snapshot schema, or proof-class implementation.

### Gate 2: Mainline Authority

Shared Runtime-Presentation authority flows from mainline OpenSpec, mainline typed carrier, and mainline tests/receipts. This UIUE roadmap/spec cannot override, extend, or reinterpret mainline shared runtime fields.

### Gate 3: UIUE Consumer

UIUE may record accepted customer-facing affordance policy immediately as UIUE policy. U2 consumer mapping waits for stable mainline names and proof-class vocabulary. UIUE local/simulator proof demonstrates presentation consumption only.

### Gate 4: Reconcile And Cleanup

S2/S3 are commander-owned cross-branch checks. They verify wording, proof caps, non-claims, row provenance, dirty-tree separation, and stale-claim hygiene. Merge rows fold into canonical artifacts with row provenance retained.

## Hard Stop Conditions

Stop immediately if any of the following occurs:

- UIUE needs to add a shared field but mainline has no authority for it.
- Any window tries to write screenshot, simulator, docs, local, or mock proof as runtime, mobile, true-device, voice, model, golden, endpoint, V-PASS, S-PASS, or U-PASS proof.
- Mainline dirty residual is mixed into a UIUE docs commit.
- M1/S1/M2 starts implementation before row-level calibration.
- Any window turns `needs-validation` directly into implementation work without first proving `remaining`.
- Merge rows lose provenance or are silently deleted.
- FutureLane rows become R5 blockers or R5 completion claims.
- HR policy is implemented or described as customer-facing `operatorReview` / `acceptance` status.
- UIUE roadmap wording overrides, extends, or reinterprets mainline shared runtime fields.

## Grill Reduction / Traceability Index

This index maps all 215 R5 grill rows into the 13 packages. It is lossless by row ID but intentionally does not copy row text. Source text remains in `final-grill-matrix.md` and `burndown-dispatch-plan.md`.

| Package | Row count | Row IDs | Action mix | Initial calibration | Source artifact | Proof cap note |
|---|---:|---|---|---|---|---|
| `HR-ACCEPTED-AFFORDANCE-POLICY` | 3 | C155, C172, C194 | DeferHuman=3 | `human-policy-accepted` | `burndown-dispatch-plan.md` | docs/local policy only |
| `M1-mainline-P0-bridge-contract` | 3 | C012, C060, C105 | Keep=3 | `needs-validation` | `burndown-dispatch-plan.md` | mainline contract proof, not runtime readiness |
| `S1-shared-P0-proof-governance` | 7 | C001, C008, C025, C036, C050, C106, C189 | Keep=7 | `needs-validation` | `burndown-dispatch-plan.md` | no proof-class promotion |
| `M2-mainline-P1-contract-test` | 22 | C003, C005, C006, C007, C009, C010, C014, C017, C018, C022, C023, C024, C029, C030, C038, C052, C061, C062, C097, C138, C143, C150 | Keep=16, Rewrite=6 | `needs-validation` | `burndown-dispatch-plan.md` | mainline tests/receipts required |
| `U2-uiue-consumer-mapping-test` | 1 | C034 | Rewrite=1 | `needs-validation` | `burndown-dispatch-plan.md` | UIUE local/simulator only |
| `S2-shared-contract-proof-reconcile` | 22 | C002, C004, C013, C016, C031, C035, C046, C047, C048, C049, C104, C107, C108, C110, C111, C179, C185, C186, C187, C193, C195, C196 | Keep=15, Rewrite=7 | `needs-validation` | `burndown-dispatch-plan.md` | coordination proof only |
| `M3-mainline-merge-only-fixture-or-doc` | 52 | C015, C027, C028, C032, C033, C039, C041, C051, C054, C055, C056, C057, C058, C059, C063, C064, C065, C066, C067, C068, C069, C070, C071, C072, C073, C074, C075, C078, C079, C084, C085, C089, C099, C101, C114, C115, C116, C136, C137, C139, C140, C141, C142, C144, C145, C146, C147, C148, C149, C151, C152, C153 | Merge=52 | `merge-only` | `burndown-dispatch-plan.md` | provenance retained under canonical artifact |
| `U3-uiue-merge-only-local-proof` | 21 | C044, C045, C080, C081, C086, C087, C088, C154, C156, C157, C158, C159, C165, C166, C167, C168, C169, C170, C171, C174, C175 | Merge=21 | `merge-only` | `burndown-dispatch-plan.md` | UIUE local/simulator only |
| `S3-shared-merge-only-receipt-hygiene` | 38 | C011, C019, C020, C021, C037, C040, C053, C076, C077, C090, C091, C092, C093, C094, C095, C098, C100, C102, C103, C109, C113, C118, C119, C126, C128, C129, C130, C131, C132, C176, C177, C178, C180, C181, C183, C184, C188, C192 | Merge=38 | `merge-only` | `burndown-dispatch-plan.md` | receipt/proof-cap hygiene only |
| `H1-human-review-product-policy` | 8 | C134, C135, C160, C161, C162, C163, C164, C173 | DeferHuman=8 | `deferred` | `burndown-dispatch-plan.md` | human/product review only |
| `K1-spike-before-implementation` | 8 | C082, C083, C096, C117, C182, C197, C207, C208 | Spike=8 | `spike-required` | `burndown-dispatch-plan.md` | spike receipt only |
| `F1-future-lane-nonclaim-guard` | 29 | C026, C042, C043, C112, C120, C121, C122, C123, C124, C125, C133, C190, C191, C198, C199, C200, C201, C202, C203, C204, C205, C206, C209, C210, C211, C212, C213, C214, C215 | DeferFutureLane=26, Keep=3 | `non-claim-only` | `burndown-dispatch-plan.md` | future-lane non-claims only |
| `D1-drop-after-merge-target` | 1 | C127 | Drop=1 | `drop-after-target` | `burndown-dispatch-plan.md` | drop only after target |

Row count check: 3 + 3 + 7 + 22 + 1 + 22 + 52 + 21 + 38 + 8 + 8 + 29 + 1 = 215.

## High-Risk Calibration Subset

This subset is for calibration attention only. It is not a task list.

| Risk group | Rows | Why high-risk | Initial calibration | Evidence required before dispatch |
|---|---|---|---|---|
| P0 mainline standalone | C012, C060, C105 | False green skips mainline bridge proof. | `needs-validation` | Mainline carrier, typed contract, and tests/receipts mapped row-by-row. |
| P0 shared proof governance | C001, C008, C025, C036, C050, C106, C189 | False promotion can turn local/simulator proof into runtime/mobile claims. | `needs-validation` | Proof cap checker or receipt wording plus forbidden-claim grep. |
| P1 mainline Keep/Rewrite | C003, C005, C006, C007, C009, C010, C014, C017, C018, C022, C023, C024, C030, C062, C097, C138, C143, C150 | Contract/test rows may be partially candidate-covered by mainline `0a2ff0f`, but not proven here. | `needs-validation` | Row-level comparison against mainline OpenSpec, typed carrier, and tests. |
| P1 UIUE consumer | C034 | UIUE can accidentally invent shared field or overclaim Reduce Motion proof. | `needs-validation` | UIUE consumer checker against stable mainline names. |
| P1 shared reconcile | C002, C004, C013, C035, C046, C047, C048, C049, C104, C107, C108, C110, C111, C179, C185, C186, C187, C193, C195, C196 | Cross-branch wording/proof rows can drift if split between windows. | `needs-validation` | Commander reconcile receipt across both repos. |
| Accepted HR policy | C155, C172, C194 | Policy is accepted, but wrong UI wording can expose internal proof terms. | `human-policy-accepted` | UIUE grep shows no customer-facing `operatorReview` / `acceptance`; display-only has visual/a11y wording. |
| Spike rows | C082, C083, C096, C117, C182, C197, C207, C208 | These require minimal falsification before implementation. | `spike-required` | Spike receipt with proof class and pass/partial/blocked verdict. |
| FutureLane claim-sensitive rows | C120, C121, C122, C123, C133, C190, C191, C198, C199, C200, C201, C205, C206, C211, C212, C213, C214, C215 | Easy to misread as golden, C6, voice, mobile, or true-device readiness. | `non-claim-only` | Non-claim ledger and forbidden-claim grep. |
| Claim-sensitive Merge rows | C041, C051, C067, C068, C071, C095, C098, C102, C103, C109, C130, C131, C132, C171, C175, C177, C178, C188 | Merge rows can be silently deleted or upgraded into runtime/golden/voice proof. | `merge-only` | Canonical merge target plus retained row provenance. |

## Docs/Local Validation For This Spec

Before treating this spec as a review candidate, run docs/local checks only:

1. Record `git status --short --branch` for both repos.
2. Check the 13-package row counts sum to 215.
3. Check row IDs in the traceability index are unique and total 215.
4. Run `git diff --check`.
5. Run forbidden-claim / non-claim hygiene grep. Positive references to runtime, mobile, true-device, voice, model, golden, endpoint, V-PASS, S-PASS, or U-PASS must be scoped as non-claims, proof caps, or stop conditions.

This spec intentionally does not run runtime, mobile, model, voice, golden, endpoint, C6, true-device, or V/S/U-PASS validation.

## User Review Gate

This file stops at user review. It does not invoke `writing-plans`, does not dispatch windows, and does not authorize implementation. A later implementation plan or dispatch document requires explicit user/commander approval after live-probe and package calibration.
