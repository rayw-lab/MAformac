# Dispatch — P0-2 C6 model artifact fingerprint

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> 派 Codex(long-runner + TDD)。磊哥手动粘贴。
> 形态 = 在未 archive 的 C6 `define-vehicle-tool-bench` change 内补 delta + Swift 实装。P0-1 readback gate 已完成；本次只做 P0-2，不 archive C6。

---

## 0. 你是谁 / 这是什么 / 红线

你是 MAformac 的 C6 vehicle-tool-bench 收尾实装者。MAformac = 纯端侧 macOS/iOS 离线、Qwen3 小模型 + LoRA 为脑、mock 车控、给方案经理现场演示的内部 demo，非量产、非真车控。

起手先读 `AGENTS.md`、`CLAUDE.md`、`docs/README.md`、`docs/roadmap-2026-06-20-from-c6-done.md`。当前 roadmap 事实源：P0 C6 收尾必须先修准评测尺子，补完 P0-1/P0-2/P0-3/P0-4 后才 archive C6，C6 archive 后才进入 C5 LoRA 数据门/训练。

**本次任务一句话**：让每条 C6 `eval_run` 和 summary 记录真实模型 artifact 指纹：`model_artifact_digest`、`tokenizer_digest`、`lora_adapter_digest`。禁止只用 `model_id` 字符串冒充权重指纹；base 无 LoRA 时 `lora_adapter_digest` 可为空，但一旦 `lora_adapter_id` 或 `lora_checkpoint_id` 非空，adapter digest 必须非空。

**红线**：
- 不 archive C6；不 archive C3；不做 P0-3/P0-4；不启动 C5 LoRA train。
- 不改 `contracts/semantic-function-contract.jsonl`、`contracts/state-cells.yaml`、`contracts/c6-bench-cases.jsonl` 等契约输入。
- 不下载大模型、不改 Hugging Face cache、不把模型权重复制进仓。只读本地 artifact 并计算 digest；若本机找不到 artifact，代码和测试照做，summary 重算标 `blocked`，不得假填。
- 若工作树存在非本任务文件，例如 `.playwright-mcp/`，保持不动，不清理、不纳入 commit。

---

## 1. 起手读

必读事实源：
- `/Users/wanglei/workspace/MAformac/docs/roadmap-2026-06-20-from-c6-done.md`，重点 §4 P0-2。
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-vehicle-tool-bench/specs/vehicle-tool-bench/spec.md`，重点 Replay fingerprint Requirement。
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-vehicle-tool-bench/tasks.md`，P0-1 已追加为 group 10，本次继续追加 P0-2 group。
- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`，重点 `C6EvalRun`、`C6Summary`、`C6BenchRunner`、`C6Hash.fileHash`。
- `/Users/wanglei/workspace/MAformac/Tools/C6BenchCLI/main.swift` 和 `/Users/wanglei/workspace/MAformac/dev/spike-e3/Sources/SpikeE3/main.swift`，看当前 summary 如何从 spike result envelope 读 `modelID`。

---

## 2. Prerequisite Check（起手必跑，真态优先）

```bash
cd /Users/wanglei/workspace/MAformac
pwd
git status --short --branch
git rev-parse HEAD
git rev-parse origin/main
openspec list
openspec validate define-vehicle-tool-bench --strict
rg -n "model_artifact_digest|tokenizer_digest|lora_adapter_digest|hasRequiredFingerprintFields|C6EvalRun|C6Summary|fileHash" Core/Bench/C6VehicleToolBench.swift Tools/C6BenchCLI/main.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift openspec/changes/define-vehicle-tool-bench -S
```

若要重算当前 C6 summary，再先找本地 artifact，禁止下载：

```bash
find "$HOME/.cache/huggingface" "$HOME/.cache/mlx" -maxdepth 8 \( -name "*.safetensors" -o -name "tokenizer.json" -o -name "tokenizer.model" \) 2>/dev/null | head -40
```

下文所有状态数字都是写作时 snapshot，真实值以上方命令为准。

---

## 3. 任务

### 3.1 OpenSpec delta

在 `openspec/changes/define-vehicle-tool-bench/specs/vehicle-tool-bench/spec.md` 修改 Replay fingerprint Requirement：
- `eval_run` SHALL 记录新增字段：
  - `model_artifact_digest`
  - `tokenizer_digest`
  - `lora_adapter_digest`
- 明确 `model_id` 只是人类可读标识，不是权重指纹。
- base 无 LoRA 时 `lora_adapter_digest` 可为空；LoRA run 一旦有 `lora_adapter_id` 或 `lora_checkpoint_id`，`lora_adapter_digest` SHALL 非空。
- fingerprint 缺失 SHALL 产生 infra failure，不得产出看似完整的 eval_run。

在 `openspec/changes/define-vehicle-tool-bench/tasks.md` 追加 `## 11. P0-2 Model Artifact Fingerprint`，至少包含：
- C6EvalRun/C6Summary 增字段。
- CLI 或 envelope 读取真实 artifact digest。
- 单测覆盖缺 digest fail、base 空 LoRA digest pass、LoRA 非空 id 但 digest 空 fail。
- `openspec validate`、`swift test`、`make verify`。

### 3.2 Swift model

修改 `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`：
- 给 `C6EvalRun` 增加 `modelArtifactDigest`、`tokenizerDigest`、`loraAdapterDigest` 及 snake_case `CodingKeys`。
- 给 `C6Summary` 增加同名字段，summary 顶层可直接展示当前 run 的模型指纹。
- 给 `C6BenchRunner` 增加初始化参数：
  - `modelArtifactDigest`
  - `tokenizerDigest`
  - `loraAdapterDigest = ""`
- 更新 `hasRequiredFingerprintFields`：
  - `modelArtifactDigest` 非空。
  - `tokenizerDigest` 非空。
  - `loraAdapterDigest` 在 base run 可空。
  - 若 `loraAdapterID` 或 `loraCheckpointID` 非空，则 `loraAdapterDigest` 必须非空。
- 不要把 `modelID`、`loraAdapterID` 或 checkpoint 字符串 hash 后当 artifact digest。

### 3.3 CLI / artifact source

修改 `/Users/wanglei/workspace/MAformac/Tools/C6BenchCLI/main.swift`：
- `summarize` 增加必填参数：
  - `--model-artifact PATH`
  - `--tokenizer-artifact PATH`
- 增加可选参数：
  - `--lora-adapter PATH`
- 使用 `C6Hash.fileHash(url:)` 计算 digest。若未来要支持目录 digest，可另加小 helper，但本次先保持小范围；如果传入目录而代码不支持，必须报清楚 usage error，不要静默跳过。
- 输出 markdown summary 时展示三项 digest。
- 输出 JSON summary 的 `eval_runs` 每条都带三项 digest。

可选但推荐：修改 `/Users/wanglei/workspace/MAformac/dev/spike-e3/Sources/SpikeE3/main.swift`，让 `spike-e3-results.json` envelope 也可带 artifact source/digest。若这会引入模型加载路径不确定性，可先不做，但 CLI summary 必须能通过显式参数补齐真实 digest。

### 3.4 Tests

修改 `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`：
- 更新旧测试 `testReplayFingerprintRecordsTenRequiredFields`，不要继续写“ten required fields”；改成覆盖新增 digest 字段。
- 新增或扩展测试：
  - base run：`model_artifact_digest` + `tokenizer_digest` 非空，`lora_adapter_digest=""` 合法。
  - LoRA run：`lora_adapter_id` 或 `lora_checkpoint_id` 非空但 `lora_adapter_digest=""` 时 `hasRequiredFingerprintFields == false`，runner 应抛 `missingEvalRunField` 或等价 infra error。
  - `C6Hash.fileHash` 对两个不同临时文件输出不同 digest。
  - summary 顶层与 eval_run 内的 digest 一致。

### 3.5 重算 summary（若本机 artifact 可定位）

如果 Prerequisite Check 找到本地权重文件和 tokenizer 文件，重跑：

```bash
swift run C6BenchCLI summarize \
  --repo-root /Users/wanglei/workspace/MAformac \
  --model-results /Users/wanglei/workspace/MAformac/dev/spike-e3/Reports/c6-base-qwen3-1_7b-readback-ssot-20260620-1620/spike-e3-results.json \
  --model-artifact <真实权重文件路径> \
  --tokenizer-artifact <真实 tokenizer 文件路径> \
  --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-base-qwen3-1_7b-fingerprint-<timestamp>
```

若找不到 artifact：不要下载，不要生成假 summary。回报里写：

```text
summary_rerun=blocked
reason=local model/tokenizer artifact path not found
code_tests=T-PASS
```

---

## 4. 验收门

必须全过：

```bash
cd /Users/wanglei/workspace/MAformac
swift test
openspec validate define-vehicle-tool-bench --strict
make verify
git diff -- contracts/semantic-function-contract.jsonl contracts/state-cells.yaml contracts/c6-bench-cases.jsonl contracts/qwen-tool-call-format.yaml
git status --short --branch
```

验收标准：
- `C6EvalRun` JSON 每条含 `model_artifact_digest`、`tokenizer_digest`、`lora_adapter_digest`。
- `C6Summary` JSON/markdown 顶层展示三项 digest。
- 缺 `model_artifact_digest` 或 `tokenizer_digest` 不允许通过 `hasRequiredFingerprintFields`。
- LoRA id/checkpoint 非空但 adapter digest 空时不允许通过。
- base 无 LoRA 时 adapter digest 空不算失败。
- OpenSpec Replay fingerprint Requirement 已同步。
- `contracts/` 输入无 diff。

---

## 5. Out of Scope

- P0-3 判断陷阱样本、alternatives、superset matcher。
- P0-4 verify_gold 完美 agent。
- C6 archive / C3 archive。
- C5 数据门、LoRA train、Qwen3.5-2B spike。
- 大模型下载、模型格式转换、缓存清理。

---

## 6. 完成回报格式

回报必须带状态字段：

```text
status: done | partial | blocked
changed_files:
  - <path>: <what changed>
verification:
  - swift test: <result>
  - openspec validate define-vehicle-tool-bench --strict: <result>
  - make verify: <result>
artifact_digest_sources:
  - model_artifact: <path or blocked>
  - tokenizer: <path or blocked>
  - lora_adapter: <path or empty_base>
summary_rerun: done | blocked | skipped
introduced:
  - <本次新增行为>
exposed:
  - <旧债/环境缺口>
next:
  - 推荐进入 P0-4 或 P0-3 的具体理由
```

不要写泛泛的“完成”。只能写 `T-PASS` / `blocked` / `partial` 这类带范围状态，并附命令 stdout 摘要。
