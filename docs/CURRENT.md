---
status: active_router_only_not_ssot
artifact_kind: current_route_board
authority: router_only_not_contract
updated: 2026-06-28
last_verified_base_commit: 6763e8a
branch: main
expires_when: "default-scope apply closeout lands or this route board is superseded by a newer route board."
---

# CURRENT — MAformac Current Route Board

> This file is a traffic board, not a source of truth.
> If this file conflicts with `CLAUDE.md`, archived OpenSpec specs, accepted grill decision packs, or active OpenSpec changes, this file loses and must be updated.

## Current Phase

Post-A2 / default-scope apply authorized: Phase -1 carrier materialization is accepted for apply, but physical implementation has not started.

Current audited state:

- Main repo branch: `main`.
- Main repo base at audit: `6763e8a`.
- Active draft carrier: `openspec/changes/define-demo-default-scope/`.
- OpenSpec validation at audit: `openspec validate define-demo-default-scope --strict` pass; `openspec validate --all --strict` pass with 14 passed, 0 failed.
- Phase -1 carrier scope is documentation/OpenSpec-only and is accepted for apply. The next implementation must follow `docs/superpowers/plans/2026-06-24-default-scope-apply.md`. Same-vendor plan pre-check returned `CLEAR_WITH_FIXES`, and fixes are absorbed in the plan. This still does not authorize training, C6 acceptance, endpoint claims, demo-golden-run, voice, or UIUE merge.

## Read First

1. `CLAUDE.md` — project constitution and highest routing rule.
2. `docs/CURRENT.md` — this route board; expire and update it at phase transition.
3. `docs/README.md` — document map.
4. `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md` — UIUE 当前 post-8.C2 路线图基线；仅路线图，不是 OpenSpec SSOT。
5. `docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md` — UIUE R0-R2 formal grill amendment authority；70 项人审通过后的 canonical groups / gates / blocker map，不是实现授权。
6. `Tools/agent-platform-plugin-refs/README.md` — local iOS/macOS build plugin references for SwiftUI, Liquid Glass, simulator, performance, and packaging work.
7. `.xcodebuildmcp/README.md` — this worktree's persisted Codex `build-ios-apps` default profile and simulator assignment.
8. `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md` — accepted G01-G28 default-scope decision pack.
9. `docs/project/phase0/README.md` — Phase 0 route-control index, D1-D10 state, R-L17 blockers.
10. `openspec/changes/define-demo-default-scope/` — current Phase -1 OpenSpec carrier.

Local iOS build truth:

- This worktree's persisted Codex `build-ios-apps` profile is `ios`.
- Default iOS scheme is `MAformacIOS`.
- Dedicated simulator is `iPhone 17 Pro Max`.
- Main worktree must keep a different simulator because both worktrees share `lab.rayw.MAformac.ios`.

## Do Now

1. Commit the Phase -1 closeout, route-board update, carrier D2 route-matrix fix, same-vendor apply-plan audit record, and apply plan together.
2. Execute `docs/superpowers/plans/2026-06-24-default-scope-apply.md` in order: C2 -> C3 -> state applier -> readback -> C5 -> C6 -> tests/gates.
3. Keep C5, C6, golden-run, and UIUE as downstream consumers of `define-demo-default-scope`. They must depend on it, not redefine default-scope semantics.
5. If `define-demo-default-scope` is accepted, execute `docs/superpowers/plans/2026-06-24-default-scope-apply.md`; keep this route board router-only and put evidence in receipts, tests, and OpenSpec closeout files.

## Do Not Do

- Do not start LoRA data generation or training.
- Do not run D-domain base recalibration or real model-quality evaluation.
- Do not claim endpoint-ready, C6-ready, demo-golden-ready, voice-ready, V-PASS, S-PASS, or U-PASS.
- Do not execute demo-golden-run or freeze golden IDs/readback/UIUE scene tags.
- Do not merge UIUE into mainline or cite UIUE file:line evidence as current mainline proof.
- Do not edit archived OpenSpec specs for default-scope behavior; add active deltas and archive later.

## Open Blockers

| Blocker | Status | Required Next Evidence |
|---|---|---|
| `define-demo-default-scope` acceptance | accepted for apply | Carrier remains active until implementation is applied and archived. |
| Physical default-scope implementation | not started | C2 `default_scope` schema/validation, C3 target resolution, state applier, readback metadata, C5/C6/golden dependencies, tests. |
| `scope.first` / `?? "全车"` / `?? "all"` debt | pre-implementation evidence only | Record grep evidence, then prove removal or explicit bridging in apply closeout. |
| Legacy UI state keys | pre-implementation evidence only | Prove scoped-key read path or one-way compatibility adapter before default-scope apply closeout. |
| C5/C2 scope candidate parity | open apply gate | C5 fallback/rendered scope candidates must derive from C2 `scope/default_scope`; no hardcoded second vocabulary. |
| Scope-origin single source | open apply gate | A typed `ScopeOrigin` or equivalent closed source must feed readback/TTS/verifier/UIUE metadata; no per-channel recomputation. |
| Apply plan audit | same-vendor pre-check absorbed | `docs/project/phase0/default-scope-apply-plan-audit-codex-2026-06-24.md`; this does not close R-L17. |
| R-L17 heterogeneous deframing | open G2-G5 | Evidence files under `docs/project/phase0/r-l17-human-review-evidence/`; same-vendor reviews remain pre-check only. |
| UIUE reconfirm | external dirty reference | Reconfirm UIUE HEAD and file evidence after mainline `default_scope` contract stabilizes. |

## UIUE Isolation Tree

UIUE remains outside mainline blockers unless state, C3-C6, readback, golden-run IDs, or default-scope presentation contracts conflict.

Current UIUE-lane state (2026-06-26, updated):

- Worktree: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/phase4-default-scope-presentation`
- Latest A-2 closeout anchor commit: `ef2435b` (`docs(uiue): add jsonl reviewed a2 closeout report`). Earlier long-form closeout anchor: `0350c8a` (`docs(uiue): add final a2 long-run closeout report`). Live branch head advances with documentation-only reconciliation commits; always re-probe `git rev-parse --short HEAD` before acting.
- Active UIUE work: visual/interaction grill **closed**; **A-2 (step2) implementation plan v3** (`docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md`) executed through Phase 2-6 commit anchors and receipt reconciliation inside this isolated worktree. Current status is **PARTIAL overall**: Phase 3/4/5/6 are DONE only for A-2 simulator/mock scope. Historical pre-R3 state had both Phase 2 continuous-stage visual acceptance `8.A` and `8.C2` open; current R3 truth is that `8.C2` is closed with notes for simulator/mock visual-acceptance scope only, while `8.A` remains independent and is not completed by `8.C2`. Final JSONL-reviewed closeout report: `docs/research/2026-06-25-a2-execution/a2-final-jsonl-reviewed-closeout-report.md` (727 lines); earlier long-form report: `docs/research/2026-06-25-a2-execution/a2-final-500-line-closeout-report.md` (601 lines). Grill SSOT: SD3/SD5/SD18-25 in `docs/uiue-storyboard-grill-decisions.md`; freeze + supersession registry (S1-S10) in `docs/grill-checklist/uiue-grill-定档-2026-06-25.md`; landing matrix in `docs/grill-checklist/uiue-landing-matrix-2026-06-25.md`; runtime bridge decisions (RPB-01~53) in `docs/grill-checklist/uiue-runtime-bridge-decisions-2026-06-25.md`.
- Post-8.C2 路线图基线：`docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`。2026-06-28 R3 closeout 已获得磊哥 L3 `PASS_WITH_NOTES` human review truth，并补齐 Reduce Motion simulator-debug-override screenshot、VPA/orb 四态 simulator proof、recapture r2 evidence sync、burndown delta、双审计和 post-closure validation；`8.C2` 已关闭。R3 closeout receipt: `Reports/uiue-8c2-r3-closeout-20260628/closeout.md`；repo-visible R3 evidence index: `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/r3-closeout-20260628/r3-evidence-index.md`。这只覆盖 `8.C2` simulator/mock visual-acceptance scope，不声明 V-PASS，也不把 UIUE simulator/mock proof 变成 mainline/runtime/mobile/true_device/voice/model proof。
- R4 grill 人审前置包（docs/local only，不是 R4 closeout）：`docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md`。配套分类表：`docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md`；R3 residual 路由表：`docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md`。R4 v2 50 条源矩阵：`docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/final-grill-matrix-v2.md`；C50 是治理总闸，UI 细节必须先分类为 bridge schema / visual policy / evidence checklist / mainline co-author / R5 deferred / user decision，不能直接塞进 bridge schema。R4 人审已通过后进入非代码前置收口：`docs/grill-tournament/uiue-r4-burndown-2026-06-28.md` 和 `docs/grill-tournament/uiue-r4-mainline-coauthor-review-request-2026-06-28.md`；mainline co-author 当前仍 pending/blocked，不得伪造接受。
- R0-R2 formal amendment authority：`docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md`。当前 post-8.C2 顺序固定为 R0 返修收口 -> R1 Interaction Integrity -> R2/R2b L0-L3 + capsule/VPA/Layout Integrity -> R3 closeout/router cascade。R3 closeout 消减见 `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`；R2b white-edge threshold/capsule final-art/mobile/true_device/runtime/voice/model 仍是 residual/non-claims，不再作为 `8.C2` R3 blocker。
- R1/R2b 第一实现切片仍是 **PARTIAL local + unit + checker foundation**，但 `8.C2` R3 visual-acceptance closeout 已在独立证据包中收口。不要把 R3 `8.C2` closeout 反推成完整 R1/R2b readiness，也不要声明 `V-PASS`、`mobile`、`true_device`、`runtime-ready`、`voice-ready` 或 `A-2 complete`。
- New OpenSpec change: `openspec/changes/define-runtime-presentation-bridge/` — **✅ accepted by 磊哥 2026-06-25 (A-2 ui-presentation may consume the contract shape via mock snapshots); `openspec validate --strict` pass; contract-only; no Swift implementation; no runtime/voice/C6/endpoint/V·S·U-PASS readiness claims; AD-RPB-014 context 四维**. Authored in UIUE lane, fulfills parent roadmap Task 2. Mainline co-authorship review still pending for the **runtime-side implementation** (mainline MUST NOT create a second bridge change). Acceptance = contract is stable enough for UIUE visual consumption, NOT a runtime-readiness claim.
- Next: after `8.C2` R3 closeout, keep `8.A` and all runtime/voice/model/mainline bridge work separate. Do not mark A-2 complete from `8.C2` alone. Continue keeping `openspec/changes/ui-presentation/tasks.md`, `docs/grill-checklist/uiue-a2-grill-coverage-index.md`, phase receipts, and closeout reports synchronized. Bridge **AD-RPB-015** remains the single cross-artifact ID authority; a future code-graph harness (GitNexus/roam-code) manifest derives from it, never mints a second ID set.

This is UIUE-lane state, not mainline evidence. Bridge recorded as `proposed_strict_valid_contract_only`; reconfirm at the contract intersection before mainline merge.

## Current Carrier Summary

`define-demo-default-scope` must own:

- C2 `default_scope` authority.
- Missing vs explicit vs fan-out scope split.
- Closed collection alias policy.
- `scope_origin`, `resolved_scope`, and presentation policy metadata.
- Legacy unscoped key disposition.
- Omitted-scope x `clarify_tag` route composition.
- Dependency gates for `retrain-c5-lora-d-domain`, `rebuild-c6-four-layer-bench`, and `define-demo-golden-run-and-voice`.

Known P1 note: older `define-demo-golden-run-and-voice` draft text still contains historical UIUE physical-anchor language. It is acceptable as an existing draft placeholder, but golden-run acceptance must either reconfirm or downgrade that language before any freeze/readiness claim.

## Retired / Historical Inputs

- `docs/roadmap-2026-06-20-from-c6-done.md` is historical provenance, not live roadmap.
- `docs/c5-recovery-2026-06-22/roadmap.md` has historical value but must not act as live roadmap unless split/bannered by Phase 0 disposition.
- `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md` is a high-weight pre-propose checklist and evidence pack, not SSOT.
- UIUE branch documents are external active work, not mainline proof until reconfirmed at the contract intersection.
