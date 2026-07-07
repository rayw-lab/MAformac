# RECEIPT-P5W — wave-1 pre-credential readiness

Generated at: 2026-07-03 00:46 Asia/Shanghai

Status: DONE for requested docs/code/test/local receipts. Not live cloud generation, not training, not C6 acceptance, not V-PASS.

## Scope

- Worktree: `/Users/wanglei/workspace/MAformac-p5w-wave1-bridge`
- Branch: `codex/p5w-wave1-bridge-20260703`
- Base: `origin/main=f4af8ccfc7d5f9249db53491d64648948aea03ca`
- Run dir: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A`

## Changed files

| Path | Change |
| --- | --- |
| `Core/Generation/Gate7GeneratorPipeline.swift` | Added C1 seed + D-domain tool catalog fields to `Gate7PipelineRequest`; added `Gate7C1ToolCallBridge`; labeler now emits concrete D-domain `C6ToolCall.arguments` when seed+tool entry are present. |
| `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift` | Added regression coverage for C1 value/slot mapping: `adjustment_mode`, `direction`, `mode`, `temperature`, `modeValue`, EXP `value`. |
| `Package.swift` | Added `Gate7DryRunCLI` executable product/target. |
| `Tools/Gate7DryRunCLI/main.swift` | Added construction-only mock wave-1 dry-run command that writes JSON/MD receipt. |

## Evidence table

| Gate | Command / artifact | Result | Proof class |
| --- | --- | --- | --- |
| G7 C1→D-domain bridge tests | `swift test --filter Gate7GeneratorPipelineTests` | PASS: 10 tests, 0 failures | unit/local |
| C5DataGate tests | `swift test --filter C5DataGate` | PASS: 14 tests, 0 failures | unit/local |
| Whitespace gate | `git diff --check` | PASS: no output | local |
| Gate7 mock wave-1 dry-run | `swift run Gate7DryRunCLI --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge --output-dir .../P5W-gate7-dry-run --limit 20` | PASS: `pipeline_status=PASS`, `sample_count=20`, `data_gate_status=data_gate_ready`, `data_gate_row_count=21`, `quarantine_count=1`, first call args include `adjustment_mode=摄氏度`, `direction=主驾`, `mode=制冷`, `temperature=22` | local_mock |
| P12-v6 data gate | `swift run C5DataGateCLI --repo-root /Users/wanglei/workspace/MAformac-p5w-wave1-bridge --candidates .../P12-v6-build/samples/c5-training-samples.jsonl --source-authorization authorized_p12_v6_build --output-dir .../P5W-p12-v6-data-gate` | PASS: `status=data_gate_ready`, `row_count=44`, `must_not_train_violations=0`, `train_parent_semantic_overlap=0`, `train_held_out_axis_overlap_count=0`, `train_held_out_axis_overlap_row_count=0`, `tool_call_format_failures=[]`, `redaction_status=pass` | local |
| GitNexus pre/post guard | `impact` and `detect_changes(scope=all, worktree=...)` | Index is stale: pre-edit symbol lookup returned not found/unknown; post-change returned low risk but only saw Package symbols. Treated as advisory only; live tests and receipts above are controlling evidence. | local_static_advisory |

## Output artifacts

| Artifact | Key result |
| --- | --- |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-dry-run/gate7-wave1-dry-run-receipt.json` | Mock G7 pipeline PASS, C5DataGate ready, 20 samples + 1 quarantine. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-gate7-dry-run/gate7-wave1-dry-run-receipt.md` | Human-readable dry-run receipt. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-p12-v6-data-gate/c5-data-gate-receipt.json` | P12-v6 candidate C5DataGate ready for 44 rows. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/P5W-p12-v6-data-gate/c5-data-gate-receipt.md` | Human-readable C5DataGate receipt. |

## File:line anchors

| Claim | Anchor |
| --- | --- |
| G7 request can carry C1 seed + D-domain tool entry | `Core/Generation/Gate7GeneratorPipeline.swift:230-270` |
| Bridge reuses C5TrainingRenderer slot/value and D-domain argument derivation | `Core/Generation/Gate7GeneratorPipeline.swift:412-450` |
| Labeler now uses bridge output instead of unconditional empty args when bridge inputs exist | `Core/Generation/Gate7GeneratorPipeline.swift:453-489` |
| JSONValue→C6 string argument conversion is local and lossy-object-safe | `Core/Generation/Gate7GeneratorPipeline.swift:492-505` |
| Regression test for direction/mode/temperature bridge | `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:65-97` |
| Regression test for `modeValue` and EXP `value` slots | `Tests/MAformacCoreTests/Gate7GeneratorPipelineTests.swift:99-113` |
| Dry-run CLI loads C1, D-domain catalog, subset manifest and runs mock generator/judge | `Tools/Gate7DryRunCLI/main.swift:26-118` |
| Dry-run CLI deliberately includes quarantine candidate | `Tools/Gate7DryRunCLI/main.swift:48-69` |

## Residual risks

- Live cloud generator/judge credentials, quotas, model IDs, batching, and rate limits remain the true blocker for overnight real generation.
- `Gate7DryRunCLI` is a mock provider proof only; it does not call Anthropic/OpenAI/Volc and does not prove live JSON parse stability.
- `Gate7PipelineRequest` keeps legacy fallback behavior: if caller omits `targetSemanticSeed` or `targetToolEntry`, labeler still emits empty arguments for backward compatibility. The real wave-1 runner must pass both bridge inputs.
- P12-v6 C5DataGate PASS proves the existing 44 candidate rows pass the data gate; it does not change the older overall training receipt status, does not authorize training, and does not imply C6/model V-PASS.
- SwiftPM still reports pre-existing unhandled-file warnings for UI test files, `UBIQUITOUS_LANGUAGE.md`, and copied `runs/.../RECEIPT-STEP0.md`; they did not block targeted builds/tests.
