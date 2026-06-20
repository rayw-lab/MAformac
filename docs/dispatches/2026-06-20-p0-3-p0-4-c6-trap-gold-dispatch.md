# Dispatch - P0-3a -> P0-4a -> P0-3b -> P0-4b C6 trap gold closeout

> 派 Codex(long-runner + TDD)。磊哥手动粘贴。
> 形态 = 在未 archive 的 C6 `define-vehicle-tool-bench` change 内继续补 delta + Swift 实装 + gold 自验。P0-1 已进 `main`；P0-2 已在 `codex/p0-2-c6-model-fingerprint` 完成。本单必须带上 P0-1/P0-2 审计 NIT 修复，然后按 `P0-3a schema/matcher -> P0-4a verify_gold skeleton -> P0-3b trap cases -> P0-4b final verify_gold` 顺序收口。

---

## 0. 你是谁 / 这是什么 / 红线

你是 MAformac 的 C6 vehicle-tool-bench 收尾实装者。MAformac = 纯端侧 macOS/iOS 离线、Qwen3 小模型 + LoRA 为脑、mock 车控、给方案经理现场演示的内部 demo，非量产、非真车控。

起手先读：
- `/Users/wanglei/workspace/MAformac/AGENTS.md`
- `/Users/wanglei/workspace/MAformac/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac/docs/README.md`
- `/Users/wanglei/workspace/MAformac/docs/roadmap-2026-06-20-from-c6-done.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-eval-memory-deepdive-synthesis.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-teardown-agent-tester.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-teardown-iot-agent-bench.md`

当前 roadmap 事实源：P0 C6 收尾必须在未 archive 的 C6 change 内补完 P0-1/P0-2/P0-3/P0-4，C6 archive 后才进入 C5 LoRA 数据门/训练。P0-1 和 P0-2 已完成，但审计留下两个小防呆要在本单起手修掉。

**本次任务一句话**：先修 P0-1/P0-2 的审计尾巴，再做 P0-3a alternatives schema/matcher，然后做 P0-4a `verify_gold` 骨架并先回放当前 45 条 gold；确认 verifier 能跑后，再做 P0-3b 新增 12-18 条判断陷阱样本，最后做 P0-4b 全量 `verify_gold` 自洽守护。不要把这单拆成只做 P0-3 或只做 P0-4。

**红线**：
- 不启动 C5 LoRA train。
- 不下载大模型，不改 Hugging Face cache，不把权重复制进仓。
- 不复制真实客户原文、报价、密钥、PII、对内禁外传内容；raw 资料只读、脱敏抽象。
- 不改 `contracts/semantic-function-contract.jsonl`、`contracts/state-cells.yaml`、`contracts/risk-policy.yaml` 的事实内容；P0-3 允许改 `contracts/c6-bench-cases.jsonl`。
- 不让 LLM judge 洗白硬门。tool call、state delta、readback、no-call、verify_gold 都必须是确定性代码门。
- 本单不直接 archive C6，除非派单执行期间磊哥另行明确要求。默认产出 `ready_for_archive=true|false` 证据。

---

## 1. 为什么不是简单 P0-3 再 P0-4

状态机：

```text
S0 audited_p0_1_p0_2
  gate: P0-1 PASS; P0-2 T-PASS; audit NITs known
  -> S1 repair_audit_nits

S1 repair_audit_nits
  gate: readback display helper cannot be mistaken for hard gate; CLI rejects base run with --lora-adapter
  -> S2 p0_3a_gold_schema_and_matcher

S2 p0_3a_gold_schema_and_matcher
  gate: alternatives schema decodes; superset matcher works; old 45 cases still load
  -> S3 p0_4a_verify_gold_skeleton_old_cases

S3 p0_4a_verify_gold_skeleton_old_cases
  gate: deterministic perfect-agent replay can verify the current 45 gold cases
  -> S4 p0_3b_trap_cases

S4 p0_3b_trap_cases
  gate: 12-18 trap cases; alternatives where needed; source_refs resolved; no raw source leakage
  -> S5 p0_4b_final_verify_gold

S5 p0_4b_final_verify_gold
  gate: perfect-agent replay passes every primary or acceptable alternative gold
  -> S6 archive_ready_receipt

S6 archive_ready_receipt
  gate: swift test + openspec validate + make verify + status report
  -> separate archive decision
```

裁决：**下一步不是 P0-3/P0-4 二选一，而是交错顺序：P0-3a -> P0-4a -> P0-3b -> P0-4b。**

理由：
- `verify_gold` 不能在 alternatives schema/matcher 之前做，否则它验证不了 P0-3 的目标 gold 形态。
- 12-18 条 trap cases 不应在 verifier 骨架之前大量加入，否则失败时分不清是模型问题、金标问题还是 verifier 缺口。
- 所以先补 gold 表达力，再让 verifier 跑通旧 45 条；随后加 trap cases，最后全量自验。

---

## 2. Pre-mortem（坑点先行）

### 2.1 Tiger：必须处理

| 风险 | 失败形态 | 本单防护 |
|---|---|---|
| P0-4 在 alternatives schema 前做 | verifier 只会验证旧 gold 形态，P0-3 一加 alternatives 又返工 | 固定先做 P0-3a schema/matcher |
| 大量 trap cases 在 verifier 骨架前加入 | 失败分不清是模型蠢、金标坏，还是 verifier 没能力 | 固定先做 P0-4a skeleton 跑旧 45 条 |
| P0-3b 不做最终 verify_gold | 新增 gold 自己有错，却被当成模型错 | P0-4b 同单完成，失败不得写 C6 ready |
| P0-1 `C6ReadbackRenderer.render` 仍 public 且可 fallback | 未来有人误用 display helper 当 hard gate，重开 assertion-only 后门 | 起手修：优先改 private；若有外部调用，必须加 doc comment + grep 证明 hard gate 只用 `matches` |
| P0-2 base run 可误传 `--lora-adapter` | summary 出现 `lora_adapter_digest` 但 `lora_adapter_id=""`、`lora_checkpoint_id=""`，污染 base/LoRA diff | 起手修：CLI 反向防呆，base envelope 带 adapter path 必须 usage error |
| alternatives 过宽 | 模型乱调也被任何 alternative 洗白 | alternatives 只能列 `quality="acceptable"` 的确定性等价或可接受解；不得用自由文本 judge 放行 |
| trap case 源料泄漏 | raw bug / 协议原文进入仓或训练集 | 只写脱敏抽象样本；source_refs 指向合同 ID，不复制客户原文 |
| `verify_gold` 只检查 tool call，不检查状态和读回 | 完美 agent 看似过，实际 mock state/readback 仍坏 | 每个 candidate 必查 `tool_call_pass`、`state_delta_pass`、`readback_pass` |

### 2.2 Paper-tiger：看似风险，实际可控

| 看似问题 | 为什么不是 blocker | 边界 |
|---|---|---|
| P0-3 会改变 case 数，导致 summary 指标波动 | P0 的目标是修尺子，不是让 base 变好 | summary 变差也可以 T-PASS，只要 gold 自洽 |
| alternatives 会让判分变松 | 只接收明确等价/可接受 gold，不接收 degraded 或 judge-only | full `quality` 四档评分留 C6.1，本单只做最小可接受集合 |
| LoRA adapter 目录 digest 未支持 | P0-2 已明确单文件 hash；本单只拍清 convention | 目录 digest 留 C6.1/C5，不在本单扩大 |

### 2.3 Elephant：没人想谈但必须写清

真正难点不是 runner 代码，而是 dataset 作者纪律：trap case 必须能解释为什么它是车控 demo 的真实风险，source_refs 必须可审，alternatives 必须收敛，不得用“感觉也行”扩散 gold。

---

## 3. Prerequisite Check（起手必跑，真态优先）

```bash
cd /Users/wanglei/workspace/MAformac
pwd
git status --short --branch
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
openspec list
openspec validate define-vehicle-tool-bench --strict
rg -n "C6ReadbackRenderer|artifactDigest|loraAdapterDigest|alternatives|verify_gold|verify-gold|C6BenchCase|C6ToolCallMatcher" Core/Bench/C6VehicleToolBench.swift Tools/C6BenchCLI/main.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift openspec/changes/define-vehicle-tool-bench contracts/c6-bench-cases.jsonl -S
```

写作时历史参考，不得直接信：
- P0-1 main commit：`044b7f6 Tighten C6 readback gate`
- P0-2 branch/head：`codex/p0-2-c6-model-fingerprint` / `4a3cc9d Add C6 model artifact fingerprints`
- `origin/main` 写作时为 `044b7f6`

真实值以上方命令为准。如果分支不是 P0-2 完成态，先停下报告，不要在未知分支继续改。

---

## 4. 任务 A：补 P0-1 / P0-2 审计尾巴

### 4.1 P0-1 NIT：readback render helper 防误用

目标文件：
- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`

现状锚点：
- `C6ReadbackRenderer.matches(...)` 是 hard gate。
- `C6ReadbackRenderer.render(delta:stateCells:fallbackText:)` 仍可能在缺 C2 template 时 fallback 到 `fallbackText`。

要求：
- 优先把 `render(...)` 改为 `private` 或移除 public 暴露。
- 如果确有外部调用必须保留 public，则加明确 doc comment：

```swift
/// Non-gating display helper only. Do not use for the C6 readback hard gate.
```

- 增加或更新测试，证明 hard gate 缺 C2 template 仍 fail，且 grep 证明 `evaluate` 只调用 `C6ReadbackRenderer.matches` 做 readback gate。

### 4.2 P0-2 NIT：base run 不允许误传 `--lora-adapter`

目标文件：
- `/Users/wanglei/workspace/MAformac/Tools/C6BenchCLI/main.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift` 或新增 CLI 单测位置

要求：
- 在 `summarize` 读取 envelope 的 `loraAdapterID` / `loraCheckpointID` 后补反向防呆：

```swift
if !loraAdapterDigest.isEmpty && loraAdapterID.isEmpty && loraCheckpointID.isEmpty {
    throw CLIError.usage("--lora-adapter was provided but model results carry no LoRA identifiers")
}
```

- 增加测试或最小 CLI fixture，覆盖 base envelope + `--lora-adapter` 时报 usage error。
- 在 spec/tasks 或 dispatch closeout 中明确当前 convention：`--lora-adapter` 指向单文件 `adapter_model.safetensors`；目录 digest 支持留 C6.1/C5，不在本单实现。

---

## 5. 任务 B：P0-3a alternatives schema + matcher

本节只做 P0-3a：gold schema 与 matcher 能力。**不要在 P0-4a 骨架跑通前批量新增 12-18 条 trap cases。**

### 5.1 OpenSpec delta

目标文件：
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-vehicle-tool-bench/specs/vehicle-tool-bench/spec.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-vehicle-tool-bench/tasks.md`

要求：
- 新增或修改 gold schema Requirement，声明 `C6BenchCase` MAY include `alternatives`。
- 每个 alternative 至少包含：
  - `id`
  - `expected_tool_calls`
  - `expect_no_call`
  - `expected_state_delta`
  - `readback_assertion`
  - `clarify_tag`
  - `failure_class`
  - `quality`
  - `reason`
- 本单只允许 `quality="acceptable"` 进入 pass candidate。`optimal/equivalent/degraded` 四档完整评分留 C6.1；如果实现 full enum，也不得让 `degraded` 过 hard gate。
- Requirement 必须写清：primary gold 和 acceptable alternatives 任一 candidate 全部硬门通过才算 pass；judge 不参与这个放行。

在 `tasks.md` 追加 `## 12. P0-3 Trap Cases + Alternatives`，拆成两个子段：
- `12.A P0-3a Alternatives schema + matcher`
- `12.B P0-3b Trap cases`

`12.B` 不得早于 P0-4a skeleton old-case verification 勾选。

### 5.2 Swift schema

目标文件：
- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`

建议结构：

```swift
public struct C6GoldAlternative: Codable, Equatable, Sendable {
    public var id: String
    public var expectedToolCalls: [C6ToolCall]
    public var expectNoCall: Bool
    public var expectedStateDelta: [String: String]
    public var readbackAssertion: C6ReadbackAssertion
    public var clarifyTag: C6ClarifyTag
    public var failureClass: C6FailureClass
    public var quality: String
    public var reason: String
}
```

给 `C6BenchCase` 增加：

```swift
public var alternatives: [C6GoldAlternative]
```

兼容旧 JSONL：没有 `alternatives` 时 decode 为 `[]`。不要破坏现有 45 cases 的读取。

### 5.3 Matcher / runner 行为

现状 `C6BenchRunner.evaluate` 只看 primary:
- `expectedToolCalls`
- `expectNoCall`
- `expectedStateDelta`
- `readbackAssertion`
- `clarifyTag`
- `failureClass`

要求改成 candidate 判定：
- candidates = primary + `alternatives.filter { $0.quality == "acceptable" }`
- 对每个 candidate 独立计算：
  - tool call set match
  - no-call false positive
  - final state
  - expected state delta
  - readback gate
  - clarify/refusal gate
- 任一 candidate 全硬门通过，则该 case hard pass。
- 如果全部失败，保留最有诊断价值的 primary failure classes；可额外记录 `matched_gold_id` / `matched_alternative_id`，但不要为了报表字段大改超出本单。

最小可接受实现：只要 `gate_result` 能正确表达最终 pass/fail，并且测试覆盖 primary fail、acceptable alternative pass 即可。

### 5.4 P0-3b Trap cases 数据（只在 P0-4a 过后执行）

**硬门**：执行本节前，必须已经有 `swift run C6BenchCLI verify-gold ...` 能在当前 45 条 case 上跑通，并产生 `Reports/c6-gold-verify-*/c6-gold-verify.json`。如果旧 45 条都过不了，先修 verifier 或旧 gold，不要继续加 12-18 条新 case。

目标文件：
- `/Users/wanglei/workspace/MAformac/contracts/c6-bench-cases.jsonl`

新增 12-18 条，覆盖 6 类，每类 2-3 条：

| 类别 | 目标 | 示例方向，需脱敏改写 |
|---|---|---|
| 否定 | 防 “别 X” 被当成 X | “别开空调，把主驾车窗打开一点” |
| 诱饵 | 防温度/数值诱饵触发错误查询或设置 | “26 度有点热，别再查温度” |
| 冗余改口 | 防前半句对象误导 | “不是车窗，是屏幕亮度调暗” |
| 模糊 | 测 LoRA/慢路价值，不死扣单一工具 | “有点闷，通通风” |
| 安全继承 | 车速/挡位等 pre_state 应触发拒绝或替代建议 | “高速上把车门打开” |
| 低置信 ASR | 音近/错别字应澄清或保守 no-call | “座椅通分”“空跳开一哈” |

约束：
- 每条必须有 `source_refs`，至少落到可审的 `semantic_contract_ids`、`state_cell_ids`、`risk_rule_ids` 或 `scenario_ids`。
- `must_pass=true` 的 trap case 必须 `must_not_train=true`。
- 不复制 raw bug 原文；只写 MAformac 自有脱敏测试句。
- 模糊 case 才允许 alternatives；明确指令不要滥加 alternatives。
- safety case 不允许通过 “执行危险工具 + 话术解释” 洗白。

### 5.5 P0-3 tests

至少新增：
- `C6DatasetCodec` 能 decode 缺省 `alternatives=[]` 的旧 case。
- 可 decode 带 acceptable alternative 的新 case。
- primary expected tool call fail、acceptable alternative pass 时，case hard pass。
- `quality="degraded"` 或未知 quality 的 alternative 不参与 pass。
- 新增 trap cases 后 dataset validation 仍过，且 source refs unresolved = 0。

---

## 6. 任务 C：P0-4a/P0-4b verify_gold 自洽守护

本节分两次跑：
- **P0-4a skeleton**：在 P0-3a schema/matcher 之后、P0-3b 新样本之前，先回放当前 45 条 gold，证明 verifier 能跑、旧 gold 没烂。
- **P0-4b final**：P0-3b 新增 trap cases 后，再对全量 cases 跑一次，作为 archive readiness 的前置证据。

### 6.1 OpenSpec delta

目标文件：
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-vehicle-tool-bench/specs/vehicle-tool-bench/spec.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-vehicle-tool-bench/tasks.md`

新增 Requirement：
- C6 bench SHALL provide a deterministic `verify_gold` check.
- `verify_gold` SHALL replay each primary gold and each acceptable alternative as a perfect agent against C6 mock state.
- A case is gold-valid only if at least one candidate satisfies tool call, state delta, and readback expectations.
- Failure SHALL report whether the failing axis is tool calls, state delta, readback, source refs, or infra.

在 `tasks.md` 追加 `## 13. P0-4 verify_gold Self-check`，拆成：
- `13.A P0-4a Skeleton verifies current 45 cases`
- `13.B P0-4b Final verifies full trap-gold dataset`

### 6.2 Core verifier

目标文件：
- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`

建议新增：

```swift
public struct C6GoldVerificationResult: Codable, Equatable, Sendable {
    public var caseID: String
    public var candidateID: String
    public var quality: String
    public var toolCallPass: Bool
    public var stateDeltaPass: Bool
    public var readbackPass: Bool
    public var sourceRefsPass: Bool
    public var goldReplayPass: Bool
    public var failureClasses: [C6FailureClass]
}

public struct C6GoldVerifier {
    public func verify(cases: [C6BenchCase], stateCells: StateCellContractLookup, validation: C6DatasetValidation) -> [C6GoldVerificationResult]
}
```

实现口径：
- 对 primary candidate：用 `expected_tool_calls` 当完美 agent output。
- 对 acceptable alternative：用 alternative 的 expected fields 当 candidate。
- `C6MockStateApplier.apply` 应用于 `pre_state`。
- `expected_state_delta` 必须被 final state 满足。
- state-changing candidate 必须能用 C2 `StateCellContractLookup.renderReadback` 生成 readback；缺 C2 template = fail。
- no-call/refusal candidate 不应伪造 readback pass；它应通过 no-call/clarify/refusal 语义，不靠 readback 文本。
- source refs 继续复用 dataset validation 或补 per-case 校验；不得在 source_refs 未解析时写 pass。

### 6.3 CLI

目标文件：
- `/Users/wanglei/workspace/MAformac/Tools/C6BenchCLI/main.swift`

新增命令：

```bash
swift run C6BenchCLI verify-gold \
  --repo-root /Users/wanglei/workspace/MAformac \
  --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-gold-verify-<timestamp>
```

输出：
- `c6-gold-verify.json`
- `c6-gold-verify.md`

JSON/Markdown 至少包含：
- `status: pass | fail`
- `cases`
- `candidate_count`
- `gold_replay_pass_count`
- `gold_replay_fail_count`
- per-case:
  - `case_id`
  - `candidate_id`
  - `quality`
  - `tool_call_pass`
  - `state_delta_pass`
  - `readback_pass`
  - `source_refs_pass`
  - `gold_replay_pass`
  - `failure_classes`

`verify-gold` fail 时 exit code 必须非 0。不要只打印 fail 但 exit 0。

P0-4a 执行点：

```bash
swift run C6BenchCLI verify-gold \
  --repo-root /Users/wanglei/workspace/MAformac \
  --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-gold-verify-baseline-$(date +%Y%m%d-%H%M%S)
```

这一步必须在批量新增 trap cases 前完成。若 fail，先修 verifier 或旧 gold，不进入 P0-3b。

P0-4b 执行点：

```bash
swift run C6BenchCLI verify-gold \
  --repo-root /Users/wanglei/workspace/MAformac \
  --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-gold-verify-final-$(date +%Y%m%d-%H%M%S)
```

这一步必须在 P0-3b 新增 trap cases 后完成，作为 `ready_for_archive=true` 的必要条件。

### 6.4 P0-4 tests

至少新增：
- 一个 happy path gold replay pass。
- 缺 C2 readback template 的 state-changing gold fail。
- expected_state_delta 与 expected_tool_calls 不一致时 fail。
- primary fail 但 acceptable alternative pass 时 case gold-valid。
- 所有 candidates fail 时 `verify-gold` status fail。
- CLI `verify-gold` 对 fail fixture 返回非 0。

---

## 7. 报告与 closeout

### 7.1 可选 summary 重算

如果本机 artifact path 仍可定位，可以在 P0-3/P0-4 后重算 C6 summary；如果找不到 artifact，不下载，不造假。

```bash
find "$HOME/.cache/huggingface" "$HOME/.cache/mlx" -maxdepth 8 \( -name "*.safetensors" -o -name "tokenizer.json" -o -name "tokenizer.model" \) 2>/dev/null | head -40
```

找得到再跑：

```bash
swift run C6BenchCLI summarize \
  --repo-root /Users/wanglei/workspace/MAformac \
  --model-results /Users/wanglei/workspace/MAformac/dev/spike-e3/Reports/c6-base-qwen3-1_7b-readback-ssot-20260620-1620/spike-e3-results.json \
  --model-artifact <真实权重文件路径> \
  --tokenizer-artifact <真实 tokenizer 文件路径> \
  --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-base-qwen3-1_7b-trap-gold-<timestamp>
```

如果 blocked，回报：

```text
summary_rerun=blocked
reason=local model/tokenizer artifact path not found
verify_gold=T-PASS
```

### 7.2 Handoff

新增 append-only handoff：
- `/Users/wanglei/workspace/MAformac/docs/handoffs/2026-06-20-p0-3-p0-4-c6-trap-gold-closeout.md`

内容不超过 60 行，必须写：
- P0-1/P0-2 NIT 是否已补。
- P0-3 新增 trap case 数、类别分布、alternatives 数。
- P0-4 verify_gold report 路径和 status。
- 是否 `ready_for_archive=true|false`。
- 若 false，列 blocking case IDs。

---

## 8. 验收门

必须全跑：

```bash
cd /Users/wanglei/workspace/MAformac
swift test
swift run C6BenchCLI verify-gold --repo-root /Users/wanglei/workspace/MAformac --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-gold-verify-final-$(date +%Y%m%d-%H%M%S)
openspec validate define-vehicle-tool-bench --strict
make verify
git diff -- contracts/semantic-function-contract.jsonl contracts/state-cells.yaml contracts/risk-policy.yaml contracts/qwen-tool-call-format.yaml
git status --short --branch
```

验收标准：
- P0-1 NIT 已处理：`render` 不再是可误用 hard gate 的 public 后门，或已明确标为 non-gating display helper。
- P0-2 NIT 已处理：base envelope + `--lora-adapter` 失败。
- `contracts/c6-bench-cases.jsonl` 新增 12-18 trap cases，类别覆盖完整。
- `alternatives` schema 可 decode 旧 case 和新 case。
- acceptable alternative 可以放行，degraded/未知 quality 不放行。
- P0-4a baseline `verify-gold` 已先在旧 45 条上跑通过。
- P0-4b final `verify-gold` 对全量 primary/acceptable candidate 自验通过，且输出 JSON/Markdown artifact。
- OpenSpec spec/tasks 同步。
- `contracts/semantic-function-contract.jsonl`、`contracts/state-cells.yaml`、`contracts/risk-policy.yaml`、`contracts/qwen-tool-call-format.yaml` 无 diff。
- 工作树只包含本单相关文件。

---

## 9. Out of Scope

- C5 数据门、LoRA train、Qwen3.5-2B spike。
- C4 三层路由、C7 语音写史合同。
- C6.1 的 pass^k、多跑方差、failure receipt 完整脊柱、数值容差 matcher override、quality 四档计分、HTML report。
- LoRA adapter 目录 digest。
- 真车控制、外部车控系统、云端服务。
- C6 archive / C3 archive。除非磊哥明确要求，本单只给 archive readiness receipt。

---

## 10. 完成回报格式

不要写泛泛的“完成”。只能写带范围状态，例如 `T-PASS`、`V-PASS`、`blocked`、`partial`，并附命令 stdout 摘要。

```text
status: T-PASS | V-PASS | partial | blocked
branch:
head:
changed_files:
  - <path>: <what changed>
p0_1_p0_2_audit_repairs:
  - readback_render_helper: fixed | not_needed | blocked
  - base_run_lora_adapter_guard: fixed | blocked
p0_3:
  trap_case_count:
  category_counts:
  alternatives_count:
  source_refs_unresolved:
p0_4:
  baseline_verify_gold_status: pass | fail
  baseline_report_json:
  final_verify_gold_status: pass | fail
  final_report_json:
  final_report_md:
verification:
  - swift test: <result>
  - swift run C6BenchCLI verify-gold: <result>
  - openspec validate define-vehicle-tool-bench --strict: <result>
  - make verify: <result>
  - protected_contract_diff: empty | non_empty
summary_rerun: done | blocked | skipped
ready_for_archive: true | false
introduced:
  - <本次新增行为>
exposed:
  - <旧债/环境缺口>
next:
  - <若 ready_for_archive=true，建议单独 archive C6/C3；否则列 blocker>
```
