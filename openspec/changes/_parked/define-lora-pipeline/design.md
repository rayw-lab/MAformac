> **SUPERSEDED 2026-06-21**: 本 parked change 已由 active C5 proposal `openspec/changes/define-lora-training/` 取代。旧扁平契约、PEFT `alpha` 口径、旧 target-module defaults 不再作为执行依据;仅保留 train/eval separation、fail-closed redaction、bucket thinking、base-vs-LoRA comparison 等设计资产供新 change 复用。

## Context

LoRA 是护城河(真实座舱 bug → 真实分布)。pre-mortem 料 `qwen3-engineering-notes §6`(lora 硬约束)+ Codex `referencerepo/reports/.../03-lora-bug-data-pipeline`(5 态 + safe shape + must_not_train)。数据源 `~/.bug-skill/data.db`(真实运行态)。依赖 change2 `capabilities.yaml`(工具名/slot 定稿后才能批量生成样本)。

## Goals / Non-Goals

**Goals:** 5 态数据 pipeline + 脱敏 fail-closed + 数据分桶 + base vs LoRA 对比。spike E3 审计后,LoRA 首要目标从"教会意图"修正为**稳定输出 `<tool_call>` 包裹**:base 已有 35/40=87.5% 工具意图正确率,主要缺的是格式通道稳定性。
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
`positive`(标准映射)/ `ambiguity`(模糊说→工具)/ `unsafe`(拒识边界)/ `readback`(不一致不播成功)/ `no_think_formatting`(无 think 污染)/ `tool_call_wrapper_format`(必须包 `<tool_call>`)/ `restraint_bare_json_negative`(防 fallback 放大误执行)。

### spike E3 审计回流:LoRA 先修格式包裹,不是重教意图
E3 raw `.toolCall` 触发率 31/40=77.5%,但 9 条 content 伪工具全是裸 JSON,7/9 语义可恢复;真实工具意图正确率是 35/40=87.5%。因此 Day1 LoRA 样本优先级调整:
1. **格式对齐正样本**:同一意图必须输出 `<tool_call>{"name":...,"arguments":...}</tool_call>`,不能输出裸 JSON 文本。重点覆盖 `screen_brightness`:本次 P027/P028/P029 均为正确裸 JSON 但未进 `.toolCall`,P030 则错到 ambient_light。
2. **restraint 裸 JSON 负样本**:把 `不要开空调`→裸 `set_cabin_ac off`、`已经26度了,不要再调`→裸 `query_cabin_comfort` 这类风险纳入 `unsafe/restraint_bare_json_negative`;目标是即使 change3 有 content-fallback,LoRA 也不把 restraint 输出成可执行候选。
3. **意图补强为次级**:继续保留模糊说/拒识/readback 样本,但不再把"教模型理解车控意图"作为 Day1 主假设;主假设是"意图大体够用,格式包裹不稳"。

### 训练 JSONL + eval 分离
OpenAI-compatible `messages + tools`;`tool_calls[].function.arguments` 序列化 JSON string,eval metadata 保留 object 便精确比对;`demo_must_pass` 标 `must_not_train: true`。

### 待解冻 adopt:#39 Qwen tool-call 格式单一源
C5 数据生成 SHALL 引用 `contracts/qwen-tool-call-format.yaml`,不得在生成脚本里另写 chat template / wrapper / arguments 形态。当前 C3 runtime 锁定 `model_family=qwen3`, `runtime_parser=json`, `thinking=false`, `wrapper=tool_call`, `arguments_shape=json_object`;训练样本的正例与负例都必须按该契约渲染,防 C5 学到 runtime 不识别的格式。

### 待解冻 adopt:Q6 数据质量门
每批生成 SHALL 输出 `verification_receipt.json`,至少含 `row_count / bucket_counts / format_contract_version / tool_call_format_pass_rate / split_whitelist / parent_semantic_overlap / must_not_train_violations`。硬门:`parent_overlap=0`, `must_not_train_violations=0`, 且 #39 格式合规。Hammer/GOAT masking 拆成三类覆盖:function 名 masking、参数名 masking、默认值/常见值 masking,避免只死记结构名和值。

### MLX-LM LoRA 配置(本地 Mac,非 iOS)
rank 8/16、alpha 16/32、dropout 0.05、target `q_proj/v_proj` 起步(必要扩 `q/k/v/o/gate/up/down`);**think traces 不算 loss**;输出 Q4。

### 决策表
| 决策 | 选 | 不选 |
|---|---|---|
| LoRA 目标 | 稳定 `<tool_call>` 包裹 + screen_brightness 格式崩塌修复 + 拒识/边界/readback | 泛聊天/补知识/把 87.5% 已会的意图当主训练目标 |
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
- [change3 content-fallback 放大误执行] → LoRA Day1 必加 restraint 裸 JSON 负样本,防模型在"不要/别再/已经够了"语境输出裸工具候选。源:spike E3 cross-vendor 审计。

### 🆕 oracle 深挖增量(2026-06-19;repo 新鲜度核过,详见 memory `maformac-lora-train-eval-stack`)

**🐯 HIGH-1 防死记(arg/intent 名值死记非泛化,1.5B unseen 60-70% vs seen 95%)**:训练侧用 **arg-token loss masking**(arg 值 token loss 置 0,只训结构)+ **function masking**(mask 函数/参数名逼读 description)。**adopt**:[Hammer](https://github.com/MadeAgents/Hammer)(function masking)+ [GOAT arxiv 2510.12218](https://arxiv.org/pdf/2510.12218)(arg-token masking)。验收门见 C6 held-out(换说法+没见过 arg 值+bug_id 分层切)。
**🐯 HIGH-3 防手痒(Hammer 实证 FC 越准 irrelevance ↓)**:训练集**必掺 ≥20% 负样本/无关工具**(xlam-irrelevance 思路);IrrelAcc 进 C6 eval。
**🐯📄 paper-tiger(demo 砍,fresheveryday 反过度治理)**:① LoRA 灾难性遗忘 → rank≤16/epoch1-3/alpha≤2×rank 安全区,**不上 EWC/OPLoRA** ② 1:1 混通用数据 sweep → solo 单域**不做**(LoRA 已抗遗忘)。
**🐘 elephant 标注成本黑洞**:1 万 bug 是"问题描述"非"FC 训练对",bug→`(模糊说→ToolCall)` gold 标注是成本+注入标注者偏见 → 先小规模(几百条)+ 两人 agreement 验证再放量;**gold arg 值多样化(别都 26 度,否则必死记)**。
**adopt 训练栈**:MLX-LM LoRA(本地 Mac)+ Hammer/GOAT masking + unsloth 超参参考。**数据三源全用**:3990 协议 + 12000 bug + raw intake。

## Migration Plan

本地 Mac 装 `mlx-lm[train]`;数据/五件套/训练集 **不入仓**,仅 LoRA 权重产物可入仓。回滚 git revert(权重)。

## Open Questions

- 从 50 条候选起 + 人工审核流程(磊哥拍)。
- Day1 格式对齐集的最小规模:先覆盖 screen_brightness / off / query / restraint 裸 JSON,再扩模糊说。
