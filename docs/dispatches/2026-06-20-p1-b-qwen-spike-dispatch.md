# Dispatch - P1-B Qwen3.5-2B S1/S2 Spike

## 0. 路由元信息

- **TO**: Codex spike runner
- **FROM**: Codex commander
- **PRIORITY**: P1-B, blocks P1-C LoRA train
- **SCOPE**: Qwen3.5-2B S1/S2 feasibility spike only
- **BRANCH**: create or reuse `codex/p1-b-qwen35-2b-spike`
- **REPO**: `/Users/wanglei/workspace/MAformac`
- **DATE**: 2026-06-20
- **STATE SNAPSHOT**: historical reference only. Start from `883f1af Archive C3 and C6 OpenSpec changes` if still current, but trust the Prerequisite Check output over this line.

## 1. 冷启动背景

MAformac 已经把 C1/C2、C3、C6 归档。P1-C LoRA train 之前还有两个并行门：

- P1-A C5 data gate: 保证训练数据不污染评测。
- P1-B Qwen3.5-2B spike: 判断是否值得切换到 Qwen3.5-2B。

本派单只做 P1-B。目标不是“升级模型”，而是用最小真实证据给出决策：继续 Qwen3-1.7B，还是进入 Qwen3.5-2B 后续适配。不要改产品默认模型，不要训练 LoRA，不要把静态文档结论写成 runtime 通过。

现有研究结论：

- Qwen3.5-2B 值得 spike，但不是默认升级。
- 主要风险在 `mlx-swift-lm` tool-call parser、chat template、thinking-loop、GDN 端侧性能和 Qwen3.5 text/VL 权重混淆。
- S1 先验证 tool-call parser 和格式兼容。
- S2 再验证 iPhone 真机 GDN 性能。没有真机或 runtime 缺失时，要给 blocked receipt，不要用 simulator 代替真机结论。

## 2. 任务

### 2.1 产物

交付一个 spike closeout，而不是 OpenSpec change。推荐产物：

- `Reports/qwen35-2b-spike-<timestamp>/spike-result.json`
- `Reports/qwen35-2b-spike-<timestamp>/parser-transcript.jsonl`
- `Reports/qwen35-2b-spike-<timestamp>/device-metrics.json`，如果 S2 可跑
- `docs/research/<date>-p1-b-qwen35-2b-s1-s2-spike.md`
- `docs/handoffs/<date>-p1-b-qwen35-2b-spike-closeout.md`

### 2.2 S1: tool-call parser spike

必须验证：

- 当前项目实际用的 `mlx-swift-lm` 版本、parser path、chat template path。
- Qwen3.5-2B text 模型是否有可用的 MLX/GDN 本地 artifact。
- 是否误用了 Qwen3-VL、非 instruct、非 tool-call capable 权重。
- 固定 10 条以上中文车控 prompts 的输出事件形态。
- `.toolCall`、`.chunk`、纯文本 JSON、thinking leak、parser error 的计数。
- 与 Qwen3-1.7B 当前 baseline 的差异。若无法重跑 1.7B baseline，必须标注为 `baseline_not_rerun`，不能写“无回归”。

S1 通过条件：

- Qwen3.5-2B 能在当前或最小补丁后的 `mlx-swift-lm` 路径中产生结构化 tool call。
- tool-call parse rate 不低于当前 Qwen3-1.7B 可用 baseline；若 baseline 不能重跑，则至少不能低于研究文档中的历史门槛，并标注证据来源。
- 没有无法抑制的 thinking-loop 或 tool-call template 错位。

### 2.3 S2: iPhone true-device GDN spike

必须验证：

- 运行设备是真 iPhone，不是 simulator。
- 权重是 Qwen3.5-2B text 路线，不是 Qwen3-VL。
- TTFT、decode tok/s、peak RAM、crash/timeout。
- 与 Qwen3-1.7B 的同类指标对比。若 1.7B 无法同机复测，标注 `baseline_not_rerun`。

S2 通过条件：

- TTFT 与 1.7B 同数量级。
- decode >= 40 tok/s。
- peak RAM < 2GB。
- 无稳定复现 crash。

如果没有真机、Xcode runtime、GDN artifact 或签名环境，S2 只能给 `blocked_env`，不能用 Mac 或 simulator 指标替代。

### 2.4 最终决策

closeout 必须给单一主结论：

```yaml
decision: stay_on_qwen3_1_7b | proceed_qwen35_2b_adaptation | blocked_waiting_for_device_or_artifact
```

允许附带次级建议，但不能没有主结论。
如果 S1 通过但 S2 因真机、GDN、签名或 artifact 阻塞，主结论仍必须是 `blocked_waiting_for_device_or_artifact`，最多附 `s1_only_candidate=true`，不能写 `proceed_qwen35_2b_adaptation`。

### 2.5 Hermes 全维度审计任务

S1/S2 首轮结论和本地验证完成后，必须调用 Hermes 做全维度审计。审计维度至少覆盖：

- Hermes 模型固定为 Ark Code（arkcode）路线：`--model code --provider custom:ark-code`。不要换成 Hermes 默认模型、Web 模型或其他 provider。
- Qwen3.5-2B text / Qwen3.5-VL / Qwen3-1.7B artifact 是否混淆。
- `mlx-swift-lm` parser、chat template、event transcript 是否真能证明 `.toolCall`。
- baseline 是否真实重跑，或是否诚实标记 `baseline_not_rerun`。
- S2 是否真机 GDN，是否误用 simulator 或 Mac 指标。
- 决策是否由证据支持，是否把 blocked 环境写成模型失败或模型通过。
- 是否引入大模型权重、tokenizer、adapter 或私有 artifact 到 repo。

推荐命令模板：

```bash
cd /Users/wanglei/workspace/MAformac
RUN_DIR="Reports/qwen35-2b-spike-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
/Users/wanglei/.codex/skills/hermes-cli-ark-code/scripts/hermes_ark_code.py run \
  --model code \
  --provider custom:ark-code \
  --prompt "$(cat <<'EOF'
你是 MAformac P1-B Qwen3.5-2B S1/S2 spike 的全维度审计员。请只读审计当前工作树，重点检查模型 artifact 身份、mlx-swift-lm parser 证据、tool-call transcript、baseline 诚实性、iPhone 真机 GDN 指标、repo 大文件泄漏、最终 decision 是否被证据支持。输出按 severity=P0/P1/Important/Nit，必须给 file:line 和修复建议。不要改文件。
EOF
)" | tee "$RUN_DIR/hermes-audit.md"
```

Hermes 审计后必须：

- 修复所有 P0/P1/Important。
- 不采纳任何一条 Important 以上意见时，在 closeout 写明理由和证据。
- 重跑第 5 节验收门。
- 若 Hermes CLI 不可用，状态最多只能写 `T-PASS`，并附 exact error。

## 3. Prerequisite Check

起手必须执行，并把输出写进 closeout。所有硬编码状态只当历史参考。

```bash
cd /Users/wanglei/workspace/MAformac
git status --short --branch
git rev-parse HEAD
git rev-parse --abbrev-ref HEAD
openspec list
openspec validate --all --strict
find . -maxdepth 3 -type d \( -name "spike-e3" -o -name "*qwen*" -o -name "*mlx*" \) | sort
rg -n "Qwen3|Qwen3.5|mlx-swift-lm|GDN|toolCall|tool_call|chat_template|thinking" Package.swift Core Tools dev docs -S
xcrun xctrace list devices 2>/dev/null | sed -n '1,80p'
```

如果需要下载多 GB 权重，先停并回报：

```yaml
blocked_reason: model_artifact_missing
required_artifact:
estimated_size:
download_source:
```

不要擅自下载大模型，不要用小模型或 VL 模型冒充。

## 4. 边界

### 4.1 允许

- 新增 spike report、parser transcript、metrics JSON。
- 添加小型 spike harness 或脚本，但必须隔离在 `dev/`、`Tools/` 或 `Reports/` 合理路径。
- 对 `mlx-swift-lm` parser 兼容问题提出最小补丁建议。
- 如果已有本地 Qwen3.5-2B artifact，可以运行 S1/S2。

### 4.2 禁止

- 不改 app 默认模型。
- 不训练 LoRA。
- 不创建 OpenSpec change，除非发现当前 archived specs 明显缺失且先回报。
- 不把 docs/source scan 写成 runtime pass。
- 不把 simulator 或 Mac 指标写成 iPhone GDN pass。
- 不把 Qwen3.5-VL 当成 Qwen3.5-2B text。
- 不在 repo 提交大模型权重、tokenizer、adapter 或私有 artifact。

### 4.3 停止条件

遇到以下情况停并回报：

- Qwen3.5-2B artifact 不存在且需要大下载。
- `mlx-swift-lm` 当前版本无法定位 parser 或 template。
- tool-call 输出只能作为自然语言 JSON，无法进入结构化 `.toolCall`。
- 设备不可用，且 S2 被要求真机 pass。
- 需要改变 C2/C3/C6 行为契约才能让 spike 通过。

## 5. 验收门

### 5.1 必过门

- `openspec validate --all --strict` pass，证明 spike 没破坏 specs。
- S1 有 parser transcript 和 machine-readable summary。
- S1 明确列出 parse rate、failure categories、baseline 状态。
- S2 若跑了，必须是真机并有 metrics JSON。
- closeout 给出单一 `decision`。
- Hermes 全维度审计已保存，所有 P0/P1/Important 已修复或有证据化不采纳理由。
- 若改 Swift: `swift test` pass。
- 若改 build/scripts: `make verify` pass。

### 5.2 决策门

- `proceed_qwen35_2b_adaptation`: S1 pass，且 S2 true-device pass。
- `stay_on_qwen3_1_7b`: S1 parser 不达标、thinking-loop 不可控、或 2B 性能明显不满足端侧 demo。
- `blocked_waiting_for_device_or_artifact`: 缺权重、缺真机、缺 GDN runtime，或 S1 通过但 S2 被环境阻塞。此时可写 `s1_only_candidate=true`，但不能写 proceed。

### 5.3 Pre-Mortem

| 风险 | 类型 | 为什么会失败 | 必须怎么验 |
| --- | --- | --- | --- |
| 把 Qwen3.5-VL 当 text 2B | tiger | VL 权重会污染 parser 和性能结论 | artifact 名称、config、tokenizer、模型卡三重核验 |
| 只读文档就宣布 parser pass | tiger | 真实 `mlx-swift-lm` event 可能没有 `.toolCall` | 必须保存 parser transcript |
| 用 simulator 或 Mac 指标替代 iPhone | tiger | 端侧 demo 约束完全不同 | S2 报告必须写 device id 和 runtime |
| 只跑 happy path prompts | tiger | 车控否定句、低置信、no-call 会暴露 parser 问题 | 至少 10 条，覆盖 call/no-call/ambiguous/safety |
| baseline 没重跑却写无回归 | tiger | 决策会被假对比误导 | baseline 不可重跑时写 `baseline_not_rerun` |
| 大模型下载污染 repo | paper-tiger | 权重不应进 git，也可能耗时耗盘 | 缺 artifact 时停，给 required artifact receipt |

## 6. 相关文件

最多先读这些，读完再按需扩展：

- `/Users/wanglei/workspace/MAformac/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac/docs/roadmap-2026-06-20-from-c6-done.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-qwen3.5-2b-vs-1.7b-feasibility.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-c3-home-llm-adopt-spike.md`
- `/Users/wanglei/workspace/MAformac/dev/spike-e3`

## 7. 完成回报格式

按这个格式回报，不要只写“完成”：

```yaml
status: V-PASS | T-PASS | BLOCKED
branch:
head_before:
head_after:

s1_parser:
  qwen35_artifact:
  mlx_swift_lm_version:
  parser_path:
  prompts:
  tool_call_parse_rate:
  baseline_status:
  failure_categories:

s2_device:
  device:
  runtime:
  ttft:
  decode_tok_s:
  peak_ram_mb:
  blocked_reason:

decision: stay_on_qwen3_1_7b | proceed_qwen35_2b_adaptation | blocked_waiting_for_device_or_artifact

verification:
  - openspec validate --all --strict:
  - swift test:
  - make verify:
  - hermes full audit:

changed_files:
  - ...

blocked_or_residual:
  - ...

next:
  - P1-C LoRA train remains blocked until P1-A data gate and P1-B Qwen spike both pass.
```
