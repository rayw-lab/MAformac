---
artifact_kind: implementation_receipt
status: DONE_WITH_RESIDUAL
proof_class: local_unit_and_local_mock
created: 2026-07-03
scope: gate7_wave1_row_surface_fields
worktree: /Users/wanglei/workspace/MAformac-p5w-wave1-bridge
output_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-surface-dry-run
not_claimed:
  - live cloud generation
  - true training
  - C6 acceptance
  - candidate signoff
  - V/S/U-PASS
---

# RECEIPT-P5W-G7-SURFACE

## 1. 结论

`GAP_FOUND` 已实装修复：Gate7 生成样本、C5DataGate projection、dry-run 候选行落盘现在贯通 `tools` / `mounted_tool_count` / `subset_policy_id` / `subset_group_id` / `subset_policy_digest`。

P5W mock dry-run 重跑产物显示 21/21 行均带 surface 字段，`data_gate_status=data_gate_ready`。

## 2. 代码改动

| file | change | evidence |
|---|---|---|
| `Core/Bench/C5DataGate.swift` | `C5DataGateCandidate` 从 Decodable 扩为 Codable，新增训练面同款 `tools/mounted/subset` 字段，旧 raw schema 仍兼容 decode | `Core/Bench/C5DataGate.swift:24-28`, `:90-124`, `:181-214` |
| `Core/Training/C5LoRATraining.swift` | `C5TrainingSample.dataGateCandidate` 传递 `tools/mounted/subset`，避免训练样本投影进 DataGate 时丢 surface | `Core/Training/C5LoRATraining.swift:404-408` |
| `Core/Generation/Gate7GeneratorPipeline.swift` | `Gate7PipelineRequest` 携带 `mountedTools`，`Gate7GeneratedSample` 带 `tools`，labeler 从 request 传入样本 | `Core/Generation/Gate7GeneratorPipeline.swift:214-222`, `:240-269`, `:483` |
| `Core/Generation/Gate7GeneratorPipeline.swift` | 新增 `Gate7DecontaminationGate.candidates`，projection 输出的 `C5DataGateCandidate` 保留 `tools/mounted/subset` | `Core/Generation/Gate7GeneratorPipeline.swift:611-641` |
| `Tools/Gate7DryRunCLI/main.swift` | dry-run 解析 subset manifest + D-domain catalog 为 mounted tools，写 `gate7-wave1-candidates.jsonl`，receipt 统计字段覆盖 | `Tools/Gate7DryRunCLI/main.swift:48`, `:75-88`, `:129-139`, `:214-224` |
| `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift` | 新增贯通测试：生成样本 -> DataGate projection -> JSON roundtrip 保真 | `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:67-107` |

说明：`Package.swift`、`Tools/Gate7DryRunCLI/` 在本轮开始前已处于 P5W dirty/untracked 状态；本轮只继续编辑 `Tools/Gate7DryRunCLI/main.swift` 的 surface 输出逻辑，不回滚既有 P5W 改动。

## 3. dry-run 产物

| artifact | result |
|---|---|
| `P5W-gate7-surface-dry-run/gate7-wave1-dry-run-receipt.json` | `pipeline_status=PASS`, `data_gate_status=data_gate_ready`, `sample_count=20`, `data_gate_row_count=21`, `quarantine_count=1` |
| `P5W-gate7-surface-dry-run/gate7-wave1-candidates.jsonl` | 21 lines |
| row surface audit | `rows_with_tools=21`, `rows_with_mounted_tool_count=21`, `rows_with_subset_policy_id=21`, `rows_with_subset_group_id=21`, `rows_with_subset_policy_digest=21` |
| mounted surface | unique `mounted_tool_count=[22]`, `subset_policy_id=e2-lite-v1`, `subset_group_id=scene.scene1` |

核验命令摘要：

```bash
jq '{status:.pipeline_status, data_gate_status, sample_count, data_gate_row_count, quarantine_count, candidate_row_count, rows_with_tools, rows_with_mounted_tool_count, rows_with_subset_policy_id, rows_with_subset_group_id, rows_with_subset_policy_digest}' \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-surface-dry-run/gate7-wave1-dry-run-receipt.json
```

结果：

```json
{
  "status": "PASS",
  "data_gate_status": "data_gate_ready",
  "sample_count": 20,
  "data_gate_row_count": 21,
  "quarantine_count": 1,
  "candidate_row_count": 21,
  "rows_with_tools": 21,
  "rows_with_mounted_tool_count": 21,
  "rows_with_subset_policy_id": 21,
  "rows_with_subset_group_id": 21,
  "rows_with_subset_policy_digest": 21
}
```

## 4. 验证

| command | result | proof_class |
|---|---|---|
| `swift test --filter Gate7GeneratorPipelineTests` | PASS, 11 tests / 0 failures | unit |
| `swift run Gate7DryRunCLI --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge --output-dir /Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-surface-dry-run --limit 20` | PASS, `samples=20`, `data_gate=data_gate_ready`, `quarantine=1` | local_mock |
| `jq -s` over `gate7-wave1-candidates.jsonl` | PASS, 21 rows; 21 rows with tools/mounted/subset fields | local_static |
| `swift test --filter 'C5DataGateTests|C5LoRATrainingTests'` | PASS, 67 tests / 0 failures | unit |
| `swift test` | PARTIAL: 521 tests executed, 3 skipped, 5 failures all in `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable` due sibling UIUE fixture hash mismatch | unit_with_unrelated_failure |
| `mcp__gitnexus.detect_changes(scope=unstaged, worktree=P5W)` | risk_level=low, affected_processes=[]; note index stale/incomplete for P5W untracked CLI | local_static |

## 5. residual risk

1. full `swift test` 不全绿：唯一失败测试是 UIUE sibling fixture corpus hash 对比，属于已知 sibling fixture drift 类，不在本轮 Gate7/C5DataGate surface scope 内。
2. 本轮只跑 mock provider dry-run；没有 live 云生成、没有真训练、没有 C6 acceptance。
3. C5DataGate 现在能携带/落盘 surface 字段，但还未新增“缺 surface 字段即 hard fail”的全局门。本轮按派单要求完成贯通与 dry-run 证明；若要 fail-closed，可另起数据门 schema gate。
4. GitNexus 对 P5W worktree 的 Gate7 新符号索引不完整，impact 证据只能作为辅助；载力证明以 unit test + dry-run JSONL 为准。

