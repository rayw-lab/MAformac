# L3 salvage projection receipt

- status: projection_pass_data_gate_blocked
- proof_class: local
- generated_at: 2026-07-03T04:55:08Z
- basis_id: l3-salvage:pr3:46a3601856ba:semantic:a242ba0c62fe:catalog:22613d496198:manifest:f3a9c49109ff
- source_path: /Users/wanglei/workspace/MAformac/Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl
- expected_source_sha256: 46a3601856bacd975076817b988835ea9d5bd1f90d021246c1b4de0617dda604
- observed_source_sha256: 46a3601856bacd975076817b988835ea9d5bd1f90d021246c1b4de0617dda604
- projected_candidates_path: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/projected-candidates.jsonl
- reuse_origin: pr3_generated_utterances_final
- quota_source: recovery

## Gate counts
| Gate | Status | Evidence |
| --- | --- | --- |
| source_freeze | pass | sha256=46a3601856bacd975076817b988835ea9d5bd1f90d021246c1b4de0617dda604, rows=4500 |
| projection_gate | pass | raw_direct_pass=0, mapped_10_family=3804, unsupported_drop=696, legacy_flag_used=false |
| data_gate | blocked | row_count=4500, surface_pass=3804, missing_surface=696, hash_failures=0 |
| training_boundary | pass | no_training_input_written=true, training_input_paths_written=[] |

## Projection counts
- row_count: 4500
- mapped_10_family_count: 3804
- unsupported_drop_count: 696
- unsupported_reason_counts: ["intent_not_in_10_family_catalog": 696]
- source_prompt_hash_matches_recomputed: 4500

## DataGate
- data_gate_receipt_json: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/c5-data-gate-receipt.json
- data_gate_receipt_md: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/c5-data-gate-receipt.md
- status: blocked
- allow_legacy_missing_surface: false
- legacy_missing_surface_allowed_count: 0
- failure_reason_counts: ["missing_candidate_surface_fields": 696]

## Resource envelope
- source_bytes: 1849198
- source_line_count: 4500
- projected_bytes: 55749484
- projected_line_count: 4500
- projected_sha256: 783692ea37271b4595dcb1f25cc401b4a285b5a98c89ad1385b499051310e02c
- semantic_contract_sha256: a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814
- d_domain_catalog_sha256: 22613d496198940bf774ddcaa921c1efa2d92038b85afe18e1c5081e0e9ce012
- subset_manifest_sha256: f3a9c49109ffb33b06d233038787ca1fdad8a750d7f7d9f917738c4a83878f61
- max_mounted_tool_count: 48

Boundary: projection + gates only; no rows were written to training input paths.