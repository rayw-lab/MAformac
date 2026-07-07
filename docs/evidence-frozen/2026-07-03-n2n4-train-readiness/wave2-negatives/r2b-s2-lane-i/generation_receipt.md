# R2B S2 Lane-I Generation Receipt

status: LANE_I_GENERATED_SELF_AUDIT_PASS
proof_class: local/generated_data_static_self_audit

## Inputs

- SSOT: batch-package/lane-prompt-package.md S2 Batch4 lane-i block
- Order: batch-package/r2b-s2-batch4-order.json lane r2b-s2-lane-i
- Query/no-call cap provenance: D-087 / R2B-QUERY-RECLASS-01
- Tool schemas: PASS lane-h door + PASS lane-b sunroof/sunshade mounted tool schemas

## Output

- candidates: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-i/candidates.jsonl`
- value ledger: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-i/value_change_ledger.jsonl`
- manifest: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-i/batch_manifest.json`
- segments: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/r2b-s2-lane-i/_segments`

## Verdict Account

- rows: `75`
- class_counts: `{'unsupported': 6, 'positive': 52, 'refusal': 4, 'already_state': 7, 'followup': 6}`
- focus_pair_groups: `{'door_lock_open_confusion_negative': 3, 'door_query_style_unsupported': 2, 'sunroof_sunshade_open_close_separation': 8, 'sunroof_sunshade_unsupported_edge': 2}`
- query rows: `0`
- conditional AC backfill: `false`
- no training / no model run
