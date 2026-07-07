status: `active_contract_carrier`
status_source: `D-115/N4`
status_updated: `2026-07-07`

## Why

C6 已经归档并把 demo must-pass / gold cases 标成 `must_not_train`，但 P1-C LoRA 训练前还缺一个机器可复跑的数据入口门来证明训练候选没有污染 C6、heldout 或 raw source。C5 data gate 先做，是为了让后续 LoRA train 只消费被 receipt 明确放行的数据，而不是把格式通过或样本非空误写成训练就绪。

## What Changes

- 新增 `lora-data-gate` 能力契约，定义 C5 数据门的输入分类、训练禁入、父级语义重叠、工具调用格式、脱敏掩码、来源快照和 failure receipt 行为。
- 新增最小 data gate 验证器，读取候选 JSONL、C6 bench cases、`contracts/qwen-tool-call-format.yaml` 和 raw 只读来源摘要，输出 JSON 与 Markdown receipt。
- 新增证据报告目录，保存 prerequisite check、receipt、验证输出和 Hermes 审计结果。
- 明确 C5 data gate 的输出是 `data_gate_ready` 或 blocked receipt；它不是 LoRA adapter、不是训练入口，也不得声明 `train_ready`。

## Non-goals

- 不训练 LoRA，不下载模型，不生成 adapter，不写 MLX/unsloth 训练入口。
- 不把真实 raw source、客户名、报价、密钥、PII、禁止外传原文或未脱敏训练集写进 repo。
- 不修改 C1/C2/C3/C6 archived specs；C5 只消费当前 specs 与 contracts。
- 不自动修复候选数据后直接放行；所有修复建议必须落在 `proposed_fix.auto_apply=false`。

## Success Criteria

- `openspec validate define-lora-data-gate --strict` 与 `openspec validate --all --strict` 通过。
- data gate receipt 可生成 JSON 和 Markdown，且包含来源快照 digest、授权状态、格式契约版本、bucket 统计、split whitelist、masking 覆盖、禁入违规、父级语义重叠和 failure receipt。
- 若 `row_count > 0`，receipt 必须满足 `must_not_train_violations=0`、`train_parent_semantic_overlap=0`、`proposed_fix.auto_apply=false`；否则 validator 退出非零。
- C6 `must_pass` / gold / `must_not_train` case 进入 train split 的刻意违规样本必须失败。
- 有 Hermes Ark Code 全维度审计记录；P0/P1/Important 均修复或在 closeout 给证据化不采纳理由。

## Capabilities

### New Capabilities

- `lora-data-gate`: C5 LoRA data gate receipt, split hygiene, format contract, masking, redaction, source snapshot, and training leakage protection.

### Modified Capabilities

- None.

## Impact

- Adds a Mac development-time validation CLI and focused unit tests.
- Adds OpenSpec change artifacts and report/closeout evidence.
- Reads raw inputs only from `/Users/wanglei/workspace/raw/05-Projects/MAformac`; repo outputs store only derived hashes, counts, and violation metadata.
