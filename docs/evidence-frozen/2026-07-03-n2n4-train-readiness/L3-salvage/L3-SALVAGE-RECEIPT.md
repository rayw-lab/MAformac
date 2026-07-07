# L3 salvage adapter receipt

- status: DONE_PROJECTION_PASS_DATAGATE_BLOCKED_EXPECTED
- proof_class: local
- repo: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge`
- branch: `codex/l3-salvage-adapter-20260703`
- source: `/Users/wanglei/workspace/MAformac/Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl`
- source_sha256: `46a3601856bacd975076817b988835ea9d5bd1f90d021246c1b4de0617dda604`
- basis_id: `l3-salvage:pr3:46a3601856ba:semantic:a242ba0c62fe:catalog:22613d496198:manifest:f3a9c49109ff`

## Artifacts

- projected_candidates: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/projected-candidates.jsonl`
- projected_candidates_sha256: `783692ea37271b4595dcb1f25cc401b4a285b5a98c89ad1385b499051310e02c`
- projection_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/l3-salvage-projection-receipt.json`
- projection_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/l3-salvage-projection-receipt.md`
- datagate_cli_receipt_json: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/datagate-cli/c5-data-gate-receipt.json`
- datagate_cli_receipt_md: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/datagate-cli/c5-data-gate-receipt.md`

## Gate Counts

| Gate | Status | Evidence |
| --- | --- | --- |
| source_freeze | pass | source sha256 matches frozen `46a36018...`, rows=4500 |
| projection_gate | pass | raw_direct_pass=0, legacy_flag_used=false, projected_rows=4500 |
| contract_row_id_join_10_family_allowlist | pass | mapped_10_family=3804, unsupported_drop=696 |
| DataGate validator | blocked_expected | status=blocked, row_count=4500, quarantine_count=4500, surface_field_pass=3804, missing_surface_count=696 |
| DataGate CLI | exit65_expected | status=blocked, must_not_train_violations=0, train_parent_semantic_overlap=0 |
| training_boundary | pass | no training input paths written; all projected rows split=`quarantine`, must_not_train=true |

## DataGate Failure Shape

- `missing_candidate_surface_fields`: 696
- `hash_failure_count`: 0
- `allow_legacy_missing_surface`: false
- `legacy_missing_surface_allowed_count`: 0
- `redaction_status`: pass

## Sample Rows

- mapped sample: `salvage-pr3-00001`, `case_id=c1_airControl_000002`, `bucket=recovery_projection`, `tool_name=open_ac_set_interface`, `reuse_origin=pr3_generated_utterances_final`, `quota_source=recovery`, `hash_recomputed_by_pipeline=true`
- unsupported sample: `salvage-pr3-02564`, `case_id=c1_carControl_000702`, `bucket=unsupported_drop`, `recovery_reason=intent_not_in_10_family_catalog`, `tools_count=0`, `hash_recomputed_by_pipeline=true`

## Resource Envelope

- source_bytes: 1849198
- source_line_count: 4500
- projected_bytes: 55749484
- projected_line_count: 4500
- semantic_contract_sha256: `a242ba0c62fecda08f860e583176b99e13ca4c6708e0313f1d76cb98f77d0814`
- d_domain_catalog_sha256: `22613d496198940bf774ddcaa921c1efa2d92038b85afe18e1c5081e0e9ce012`
- subset_manifest_sha256: `f3a9c49109ffb33b06d233038787ca1fdad8a750d7f7d9f917738c4a83878f61`
- max_mounted_tool_count: 48

## Commands

```bash
swift run C5SalvageProjectionCLI --source /Users/wanglei/workspace/MAformac/Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl --expected-source-sha256 46a3601856bacd975076817b988835ea9d5bd1f90d021246c1b4de0617dda604 --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage
# exit 0; status=projection_pass_data_gate_blocked rows=4500 mapped=3804 unsupported_drop=696 data_gate=blocked

swift run C5DataGateCLI --candidates /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/projected-candidates.jsonl --source-digest-path /Users/wanglei/workspace/MAformac/Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl --source-authorization authorized_pr3_salvage_projection --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/L3-salvage/datagate-cli
# exit 65 expected; status=blocked rows=4500 must_not_train_violations=0 train_parent_semantic_overlap=0 quarantine=4500

swift test --filter C5SalvageProjectionTests
# 1/1 passed

swift test --filter C5DataGateTests
# 26/26 passed

swift test --filter Gate7GeneratorPipelineTests
# 13/13 passed

swift test --filter C5LoRATrainingTests
# 68/68 passed
```
