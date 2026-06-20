# Dispatch - P1-A C5 Data Gate

## 0. 路由元信息

- **TO**: Codex long-runner
- **FROM**: Codex commander
- **PRIORITY**: P1-A, blocks P1-C LoRA train
- **SCOPE**: OpenSpec propose/apply for C5 data gate only
- **BRANCH**: create or reuse `codex/p1-a-c5-data-gate`
- **REPO**: `/Users/wanglei/workspace/MAformac`
- **DATE**: 2026-06-20
- **STATE SNAPSHOT**: historical reference only. Start from `883f1af Archive C3 and C6 OpenSpec changes` if still current, but trust the Prerequisite Check output over this line.

## 1. 冷启动背景

MAformac 是纯端侧、离线、Qwen 小模型 + LoRA 的车控方案演示助手。它不是量产车控，也不接真车。当前已完成并归档 C1/C2、C3、C6，`openspec list` 预期只剩 `_parked`。下一阶段并行两条线：

- P1-A: C5 数据门，决定 LoRA 训练数据能不能进入训练。
- P1-B: Qwen3.5-2B S1/S2 spike，决定是否值得从 Qwen3-1.7B 切到 2B 路线。

本派单只做 P1-A。不要训练模型，不要生成 LoRA adapter，不要把 C5 做成“数据集越多越好”。C5 的目标是建立可审计的数据入口：格式、拆分、脱敏、训练禁入、父级语义重叠、来源快照都必须有机器可验的 receipt。

关键事实：

- C6 已归档，`openspec/specs/vehicle-tool-bench/spec.md` 是当前 vehicle tool bench 行为契约。
- C3 已归档，`openspec/specs/tool-execution/spec.md` 是当前 tool execution 行为契约。
- `_parked/define-lora-pipeline` 可作为旧思路参考，但不能整包复活。旧 LoRA pipeline 中的 train 任务不属于 P1-A。

## 2. 任务

### 2.1 产物

交付一个 C5 data gate OpenSpec change，推荐 change id:

```text
define-lora-data-gate
```

目标产物：

- `openspec/changes/define-lora-data-gate/proposal.md`
- `openspec/changes/define-lora-data-gate/design.md`
- `openspec/changes/define-lora-data-gate/tasks.md`
- `openspec/changes/define-lora-data-gate/specs/lora-data-gate/spec.md`
- 最小可运行的数据门验证器和 receipt 生成物，路径按项目现有风格选择，优先少改。
- 一份验证证据目录：`Reports/c5-data-gate-<timestamp>/`
- 一份 closeout handoff：`docs/handoffs/<date>-p1-a-c5-data-gate-closeout.md`

### 2.2 行为要求

C5 data gate 必须能回答这些问题：

- 哪些样本允许训练，哪些只能评测，哪些必须隔离。
- C6 `must_pass` / gold / archived eval cases 是否被训练禁入保护。
- 训练集与 heldout / must-pass / C6 base 是否存在父级语义重叠。
- 是否符合 Qwen tool-call format contract。
- 是否完成 function name、argument value、默认值、危险 token 的脱敏或掩码。
- 是否有来源快照、hash、统计、违规清单和不可自动修复的 failure receipt。

建议 receipt 字段至少包括：

```yaml
receipt_version:
generated_at:
source_snapshot_digest:
source_authorization_status:
format_contract_version:
row_count:
bucket_counts:
split_whitelist:
must_not_train_violations:
detected_parent_semantic_overlap_count:
train_parent_semantic_overlap:
tool_call_format_pass:
tool_call_format_failures:
masking_coverage:
redaction_status:
quarantine_count:
failure_receipt:
proposed_fix:
  auto_apply: false
```

### 2.3 执行顺序

1. 先跑 Prerequisite Check，不通过就停，给 exact output。
2. 读当前 C1/C2/C3/C6 主 specs，不读旧 change 当权威。
3. 读 `_parked/define-lora-pipeline`，只抽取仍然适用的概念：verification receipt、masking、split hygiene、overlap=0、must_not_train=0。
4. 提出 `define-lora-data-gate` OpenSpec change。
5. 实现最小数据门验证器。不要实现训练入口。
6. 生成一份小样本或现有候选数据的 receipt。若真实数据路径或授权不清，生成 blocked receipt，不要伪造通过。
7. 跑首轮验收命令，修复到 gate 通过或明确 blocked。
8. 安排 Hermes 全维度审计，保存审计结果，然后自己修复所有 P0/P1/Important 问题。
9. 修复后重跑验收命令，再写 closeout。

### 2.4 Hermes 全维度审计任务

首轮实现和本地验证完成后，必须调用 Hermes 做全维度审计。审计维度至少覆盖：

- Hermes 模型固定为 Ark Code（arkcode）路线：`--model code --provider custom:ark-code`。不要换成 Hermes 默认模型、Web 模型或其他 provider。
- OpenSpec 契约是否完整、是否与 C3/C6 archived specs 冲突。
- 数据污染风险：C6 gold / must-pass / heldout 是否可能进入 train。
- raw source、PII、客户信息、禁止外传材料是否泄漏到 repo。
- receipt schema 是否可机器复跑，失败是否能阻断。
- 验收命令是否足够证明 C5 data gate，而不是只证明文档可 validate。
- closeout 状态是否诚实，是否把 data gate 写成 train ready。

推荐命令模板：

```bash
cd /Users/wanglei/workspace/MAformac
RUN_DIR="Reports/c5-data-gate-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
/Users/wanglei/.codex/skills/hermes-cli-ark-code/scripts/hermes_ark_code.py run \
  --model code \
  --provider custom:ark-code \
  --prompt "$(cat <<'EOF'
你是 MAformac P1-A C5 data gate 的全维度审计员。请只读审计当前工作树，重点检查 OpenSpec 契约、数据污染、raw/PII 泄漏、receipt 可复跑性、验收门充分性、状态诚实性。输出按 severity=P0/P1/Important/Nit，必须给 file:line 和修复建议。不要改文件。
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
test -f openspec/specs/vehicle-tool-bench/spec.md
test -f openspec/specs/tool-execution/spec.md
test -f contracts/qwen-tool-call-format.yaml
find /Users/wanglei/workspace/raw/05-Projects/MAformac -maxdepth 3 -type f | sort | sed -n '1,80p'
rg -n "verification_receipt|must_not_train|parent_semantic_overlap|masking|split_whitelist|format_contract" openspec docs contracts Tools scripts Tests -S
```

如果 `find /Users/wanglei/workspace/raw/05-Projects/MAformac` 不存在，不要改成 repo 内临时数据当真数据。报告 `blocked_raw_source_missing`，同时仍可完成 OpenSpec 设计和空输入验证器。

raw source 缺失、`source_snapshot_digest` 缺失、或 `row_count=0` 时，最终状态最多只能是 `T-PASS` 或 `BLOCKED`。P1-C LoRA train 继续 blocked。

## 4. 边界

### 4.1 允许

- 新增 C5 data gate OpenSpec change。
- 新增最小验证器、receipt schema、报告输出。
- 使用 raw 目录做只读输入。
- 复用 `_parked/define-lora-pipeline` 的概念，但必须重写到当前 C3/C6 archived truth。

### 4.2 禁止

- 不训练模型。
- 不下载大模型或 adapter。
- 不把 C6 gold / must-pass / archived eval cases 放进 train split。
- 不把真实客户名、报价、密钥、PII、禁止外传文本写进 repo。
- 不自动修复数据后直接宣称通过。自动修复建议必须落在 `proposed_fix.auto_apply=false`。
- 不把 `openspec validate --all --strict` 通过写成 LoRA data ready。C5 ready 只由 data gate receipt 决定。

### 4.3 停止条件

遇到以下情况停并回报：

- raw source 授权或路径不清。
- `must_not_train_violations > 0` 且无法确定违规来源。
- `train_parent_semantic_overlap > 0`。
- format contract 不能定位或版本无法哈希。
- 需要改变 C2/C3/C6 archived specs 才能推进。

## 5. 验收门

### 5.1 必过门

- `openspec validate define-lora-data-gate --strict` pass。
- `openspec validate --all --strict` pass。
- data gate receipt 生成成功。
- V-PASS 必须有授权来源、`source_snapshot_digest`、且 `row_count > 0`。
- receipt 中 `must_not_train_violations=0`。
- receipt 中 `train_parent_semantic_overlap=0`。`detected_parent_semantic_overlap_count` 可非 0，但所有命中样本必须进入 quarantine 且不得进入 train。
- `proposed_fix.auto_apply=false`。
- Hermes 全维度审计已保存，所有 P0/P1/Important 已修复或有证据化不采纳理由。
- 若改 Swift: `swift test` pass。
- 若改 scripts/contracts/build: `make verify` pass。

### 5.2 推荐门

- receipt 同时输出 JSON 和 Markdown。
- 对至少 1 个刻意违规样本有 fail test。
- 对 C6 must-pass 进入 train 的情况有 fail test。
- closeout 明确写 `state=V-PASS`、`state=T-PASS` 或 `state=BLOCKED`，不要写裸 `PASS`。

### 5.3 Pre-Mortem

| 风险 | 类型 | 为什么会失败 | 必须怎么验 |
| --- | --- | --- | --- |
| 把旧 `_parked/define-lora-pipeline` 直接复活 | tiger | 旧任务包含训练，且基于归档前状态 | 先读当前 archived specs，再只抽取 C5 概念 |
| C6 gold 被混入 train | tiger | 会让 LoRA eval 看起来变好但不可解释 | receipt 强制 `must_not_train_violations=0` |
| parent overlap 只做字符串去重 | tiger | 同义改写会泄漏到训练 | 建立 parent id / semantic family 字段；`train_parent_semantic_overlap` 必须为 0 |
| raw source 进入 repo | tiger | 可能带客户名、报价、PII、禁止外传内容 | raw 只读，repo 只存抽象字段和 hash |
| receipt 只统计数量不阻断 | tiger | 失败样本仍可能进入训练 | validator exit code 必须失败，`proposed_fix.auto_apply=false` |
| C5 被误写成 LoRA ready | paper-tiger | 容易误导 P1-C | closeout 用 `data_gate_ready`，不写 `train_ready` |

## 6. 相关文件

最多先读这些，读完再按需扩展：

- `/Users/wanglei/workspace/MAformac/CLAUDE.md`
- `/Users/wanglei/workspace/MAformac/docs/roadmap-2026-06-20-from-c6-done.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-eval-memory-deepdive-synthesis.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-maformac-eval-system-overview.md`
- `/Users/wanglei/workspace/MAformac/openspec/changes/_parked/define-lora-pipeline/design.md`

## 7. 完成回报格式

按这个格式回报，不要只写“完成”：

```yaml
status: V-PASS | T-PASS | BLOCKED
branch:
head_before:
head_after:
change_id: define-lora-data-gate

data_gate:
  receipt:
  row_count:
  bucket_counts:
  must_not_train_violations:
  detected_parent_semantic_overlap_count:
  train_parent_semantic_overlap:
  quarantine_count:
  source_snapshot_digest:
  source_authorization_status:
  format_contract_version:

verification:
  - openspec validate define-lora-data-gate --strict:
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
