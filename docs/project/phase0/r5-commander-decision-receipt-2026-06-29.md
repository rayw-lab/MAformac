---
status: DONE
label: UIUE_R5_D8_COMMANDER_DECISION_RECEIPT
artifact_kind: commander_decision_receipt
created_at: 2026-06-29
proof_class_ceiling: human_decision_record + docs/local + local_static
authority: commander_human_decision_record_not_runtime_contract
human_authorization: "磊哥已明确：全部授权同意，人审过了。"
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D8 Commander Decision Receipt

## 0. Scope and non-claims

This receipt freezes five commander-approved human review decisions from D7. It is a routing and governance decision record only. It is not an implementation dispatch, runtime contract, simulator review, product acceptance, UIUE merge approval, push approval, or PR approval.

It does not claim R5 complete, runtime-ready, mobile proof, true_device proof, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete.

## 1. Source evidence

| source | role |
|---|---|
| `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-commander-decision-receipt-dispatch.md` | D8 dispatch authority |
| `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-human-review-gate-2026-06-28.md` | D7 human review packet and defaults |
| `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-dual-repo-integration-train-2026-06-28.md` | D6 capped integration receipt |
| `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` | R5 dispatch/deferred-lane map |

## 2. Live repo truth

| repo | expected | live-probed truth | D8 disposition |
|---|---|---|---|
| UIUE | HEAD `058ac4e63dd34f5980818fd3c6c925fb1389cab1`; only D8 dispatch may be untracked | HEAD matched. Dirty before receipt: untracked `docs/dispatches/2026-06-29-uiue-r5-commander-decision-receipt-dispatch.md`. | exact-path separable; D8 may add dispatch + this receipt only |
| main | HEAD `d332db736a0c47eb3b8dc09c80fb907a0f43e29e`; preserve-unowned only | HEAD matched. Preserve-unowned dirty: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`. | read-only; not edited by D8 |

## 3. Frozen commander decisions

| decision_id | frozen decision | proof class | implementation effect |
|---|---|---|---|
| D8-FROZEN-1 | D6 capped DONE accepted. D6 is accepted only as `docs/local + local_unit + local_static + openspec_contract` integration-train DONE. It is not R5 complete, runtime-ready, mobile, true-device, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, A-2 ready, or A-2 complete. | human_decision_record + docs/local | establishes the capped D6 baseline; does not close product/runtime gates |
| D8-FROZEN-2 | H1 default policy accepted. Customer-facing UI must not display internal proof labels; display-only guard wording is accepted; a11y, final-art, proof wording, and customer-facing proof copy remain policy/human-decision surfaces and do not become mobile/true-device/product acceptance. | human_decision_record | freezes wording policy defaults; does not implement UI or sign visual/a11y proof |
| D8-FROZEN-3 | `C005`, `C018`, `C052`, and `C061` remain deferred. They are not implemented by D8 and not closed by D6/D7/D8. | human_decision_record + docs/local | keeps deferred owner gates open for future bounded lanes |
| D8-FROZEN-4 | K1 rows `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, and `C208` remain spike-before-implementation ledger rows. They are not implementation tasks until a future bounded spike receipt promotes one. | human_decision_record + docs/local | prevents K1 promotion without bounded spike evidence |
| D8-FROZEN-5 | M3 remains provenance-only/merge-only. mobile/true-device, voice/model/golden/endpoint, UIUE merge/push/PR remain future non-claim lanes requiring separate proof plans or human gates. | human_decision_record + docs/local | preserves future-lane separation and non-claim boundaries |

## 4. Affected rows

| row group | rows | D8 disposition | next possible owner |
|---|---|---|---|
| D6 acceptance | D6 capped integration-train DONE | accepted under cap only | commander routing |
| H1 product/proof policy | `C134`, `C135`, `C155`, `C160-C164`, `C172`, `C173`, `C194` | default policy accepted as human decision surface only | future UI/copy/a11y/final-art dispatch if selected |
| deferred owner gates | `C005`, `C018`, `C052`, `C061` | remain deferred; not closed by D6/D7/D8 | mainline spike/implementation for `C005`/`C018`/`C061`; bounded simulator/debug-tool spike for `C052` if later promoted |
| K1 spike ledger | `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208` | remain spike-before-implementation only | future bounded falsification spike receipt |
| M3 / future lanes | M3, mobile/true-device, voice/model/golden/endpoint, UIUE merge/push/PR | provenance-only, merge-only, or future non-claim lanes | separate proof plan, human gate, release gate, or merge gate |

## 5. Next routing recommendation

Default next step is no implementation yet. Commander may choose a later bounded lane after this receipt:

1. If `C052` is later promoted, route it as a bounded simulator/debug-tool spike with `simulator_mock` cap.
2. If `C005`, `C018`, or `C061` is later promoted, route it to mainline spike/implementation, not UIUE docs.
3. If final-art or white-edge is later promoted, route it as a visual simulator review with exact screen/state.
4. If UIUE merge/push/PR is later requested, require a separate release/merge gate with proof class, dirty split, and non-claim wording.

## 6. Changed paths and validation plan

Allowed changed paths for D8:

```text
/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-commander-decision-receipt-dispatch.md
/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-commander-decision-receipt-2026-06-29.md
```

Required validation:

```bash
git diff --check
openspec validate ui-presentation --strict
```

No Swift, OpenSpec, GitNexus, simulator evidence, roadmap/map, or main repo files are touched by this receipt.
