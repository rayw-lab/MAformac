> **SUPERSEDED 2026-06-21**: 本 parked change 已由 active C5 proposal `openspec/changes/define-lora-training/` 取代。旧扁平契约、PEFT `alpha` 口径、旧 target-module defaults 不再作为执行依据;仅保留 train/eval separation、fail-closed redaction、bucket thinking、base-vs-LoRA comparison 等设计资产供新 change 复用。

## Why

LoRA 是 MVP 必交付项,也是**护城河**:真实座舱 bug → 真实分布(非造),AWS PPT 未体现。LoRA 只练「模糊说 → 跨域工具映射」(规则吃 80% 高频明确,LLM/LoRA 只碰 20% 模糊/跨域)。数据三源(bug-skill-dev 1 万+ bug / 协议清单说法 / raw 语料)→ 脱敏五件套 → MLX-LM LoRA。pre-mortem(`qwen3-notes §6` + Codex `03-lora`)已搜透:约束行为非补知识 / think 不算 loss / 负样本必进 / redaction fail-closed。

## What Changes

- **LoRA 数据 5 态状态机**:`source_inventory_abstract_only → redacted_five_tuple → training_jsonl_candidate → eval_jsonl_locked → base_vs_lora_eval`。
- **redaction validator(fail-closed)**:命中真实项目值 / 人名 / 路径 / 长唯一串 / raw JSON / receipt 前缀 → 拒绝。
- **数据分桶**:positive / ambiguity(模糊说)/ unsafe(拒识边界)/ readback(不一致不播成功)/ no_think_formatting。
- **训练 JSONL**:OpenAI-compatible `messages + tools`;eval / training **分离**,`demo_must_pass` 样本标 `must_not_train: true`。
- **MLX-LM LoRA**(本地 Mac,非 iOS):rank 8/16、alpha 16/32、dropout 0.05、target `q_proj/v_proj` 起步;**think traces 不算 loss**。
- **base vs LoRA** 同测试集对比(同 tool schema / temperature / parser / mock state)。

## Capabilities

### New Capabilities
- `lora-data-pipeline`:bug 数据 → 本地脱敏五件套 → 训练 JSONL → base vs LoRA eval 的行为契约(只练模糊/跨域、约束行为非补知识、数据不入仓)。

### Modified Capabilities
(无)

## Non-goals

- ❌ 不练泛聊天(只「模糊说 → 工具映射」+ 拒识 / 边界 / readback 修正)。
- ❌ 不导出真实文本(本地脱敏抽象;**训练集不入仓,仅 LoRA 权重产物可入仓**)。
- ❌ 不做 GRPO / RL(MVP;奖励设计思想借给 change6 eval)。
- ❌ 不在 `capabilities.yaml` 工具名定稿前批量生成训练样本(Codex 03:capabilities 必先于 LoRA 数据)。

## Success Criteria(可验收)

- **redaction validator fail-closed**:真实项目 / 人名 / 路径 / raw JSON / receipt 命中即拒(测试覆盖 5+ 敏感类型)。
- **五件套 safe shape**:全 `[REDACTED]` / `[ABSTRACT]` 占位,无真实文本 / 车型 / 客户值。
- **eval/training 分离**:`demo_must_pass` 标 `must_not_train: true`,不漏进训练。
- **base vs LoRA** 在同 tool schema / temperature / parser / mock state 下比较。
- LoRA **只改善 fuzzy/cross-domain 映射**,不替代规则 / schema / DemoGuard / readback。
- **数据 / 训练集不入仓**(`git status` 验);仅 LoRA 权重产物可入仓。

## Impact

- 依赖 change2 `capabilities.yaml`(工具名 / slot / error_tag enum 的事实源;capabilities 必先于 LoRA 数据)。
- 依赖 change3 `execution-contract`(训练数据 `expected_tool_call` 引 ToolCallFrame schema)。
- 数据源:`~/.bug-skill/data.db`(真实运行态;表名 `ki_evidence_links` / `ki_evidence_annotations`,**非旧单数 `ki_evidence`** — Codex DB 核实)。
- `mlx-lm[train]` 需本地安装(Mac 开发期;零进 iOS)。
- 下游:change6 `vehicle-tool-bench`(base vs LoRA eval 的评测集)。
