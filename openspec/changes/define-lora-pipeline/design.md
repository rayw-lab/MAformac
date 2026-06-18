## Context

LoRA 是护城河(真实座舱 bug → 真实分布)。pre-mortem 料 `qwen3-engineering-notes §6`(lora 硬约束)+ Codex `referencerepo/reports/.../03-lora-bug-data-pipeline`(5 态 + safe shape + must_not_train)。数据源 `~/.bug-skill/data.db`(真实运行态)。依赖 change2 `capabilities.yaml`(工具名/slot 定稿后才能批量生成样本)。

## Goals / Non-Goals

**Goals:** 5 态数据 pipeline + 脱敏 fail-closed + 数据分桶 + base vs LoRA 对比。
**Non-Goals:** 泛聊天 / 导出真实文本 / GRPO / capabilities 未定前批量生成。

## Decisions

### LoRA 数据 5 态状态机
```
source_inventory_abstract_only   (只盘点抽象,不导原文)
 → redacted_five_tuple           (本地脱敏五件套)
 → training_jsonl_candidate      (训练候选)
 → eval_jsonl_locked             (评测锁定,must_not_train)
 → base_vs_lora_eval             (同集对比)
```

### safe output shape(全占位,无真实文本)
```json
{
  "input_utterance_abstract": "[REDACTED_USER_COMPLAINT_ABSTRACT]",
  "context_state": { "vehicle_state": "[MOCK_STATE_ONLY]", "confidence_bucket": "0_5_to_0_8" },
  "expected_tool_call": { "tool": "set_mock_vehicle_state", "slots": { "capability_id": "cabin.ac", "target": "[ABSTRACT]", "value": "[ABSTRACT]" } },
  "guard_expectation": "readback_required",
  "error_tag": "semantic_routing"
}
```

### 数据分桶(qwen3-notes §6)
`positive`(标准映射)/ `ambiguity`(模糊说→工具)/ `unsafe`(拒识边界)/ `readback`(不一致不播成功)/ `no_think_formatting`(无 think 污染)。

### 训练 JSONL + eval 分离
OpenAI-compatible `messages + tools`;`tool_calls[].function.arguments` 序列化 JSON string,eval metadata 保留 object 便精确比对;`demo_must_pass` 标 `must_not_train: true`。

### MLX-LM LoRA 配置(本地 Mac,非 iOS)
rank 8/16、alpha 16/32、dropout 0.05、target `q_proj/v_proj` 起步(必要扩 `q/k/v/o/gate/up/down`);**think traces 不算 loss**;输出 Q4。

### 决策表
| 决策 | 选 | 不选 |
|---|---|---|
| LoRA 目标 | 模糊说→工具 + 拒识/边界/readback | 泛聊天/补知识 |
| 数据出仓 | 本地脱敏,训练集不入仓(仅权重) | 导出真实文本 |
| eval/train | 分离 + must_not_train | 混用(数据泄漏) |
| think | 不算 loss | 算 loss(污染行为) |
| 训练栈 | MLX-LM LoRA(本地) | 云训练 |

## Risks / Trade-offs(pre-mortem,带来源)

- [LoRA 误当「补知识」而非「约束行为」] → 数据主攻约束(模糊说/拒识/边界)。源:[HomeDock fine-tune](https://www.homedock.cloud/blog/self-hosting/how-we-fine-tuned-a-1-7b-llm-to-talk-like-a-ghost/) + qwen3-notes §6。
- [think traces 污染行为] → 不算进 loss。源:[Reddit LoRA findings](https://www.reddit.com/r/LocalLLaMA/comments/1kkl39r/findings_from_lora_finetuning_for_qwen3/)。
- [学习率太高过拟合] → rank/alpha/lr 保守 + 同集 base vs LoRA 对比。源:qwen3-notes §2 LoRA 配置。
- [脱敏漏真实值] → redaction validator **fail-closed**(默认拒)。源:Codex 03-lora。
- [DB 旧表名] → 用 `ki_evidence_links`/`ki_evidence_annotations`,非旧单数 `ki_evidence`。源:Codex DB 核实。
- [capabilities 未定前生成训练样本 → 工具名/slot 漂移] → 先 change2 定稿。源:Codex 03:27。
- [LoRA adapter 可能泄漏敏感表达] → 后续安全评估(adapter 也不放仓)。源:Codex 03。

## Migration Plan

本地 Mac 装 `mlx-lm[train]`;数据/五件套/训练集 **不入仓**,仅 LoRA 权重产物可入仓。回滚 git revert(权重)。

## Open Questions

- 从 50 条候选起 + 人工审核流程(磊哥拍)。
- 若 change3 E3 spike 出 base 1.7B 触发率低 → LoRA Day1 trace 优先采「漏触发」样本。
