> 范围:6-change 第 5 个。bug 数据 → 脱敏五件套 → MLX-LM LoRA(只练模糊/跨域映射)。pre-mortem 料 `qwen3-notes §6` + Codex `03-lora`。**依赖 change2 capabilities.yaml 定稿**(工具名/slot/error_tag)。数据源 `~/.bug-skill/data.db`。**真实数据抽取需磊哥显式授权**。

## 0. 前置:redaction validator(fail-closed,起手必做)

- [ ] 0.1 写本地 redaction validator,**默认 fail-closed**:命中真实项目值 / 人名 / 路径 / 长唯一串 / 原始 JSON / receipt 前缀 → 拒绝。验收:5+ 敏感类型测试全拒;干净样本通过。**叠加 Superpowers: verification**。

## 1. 数据盘点 + 脱敏(5 态前 2 态)

- [ ] 1.1 `source_inventory_abstract_only`:盘点 `~/.bug-skill/data.db`(表 `ki_evidence_links` / `ki_evidence_annotations`,**非旧单数 `ki_evidence`**)抽象 taxonomy / eval shape,**不导原文**。验收:产出抽象分类,无原文落地。
- [ ] 1.2 `redacted_five_tuple`:本地脱敏五件套(safe shape 全 `[REDACTED]`/`[ABSTRACT]` 占位)。验收:过 0.1 validator;无真实文本/车型/客户值。

## 2. 训练候选 + 分桶(5 态第 3 态)

- [ ] 2.1 `training_jsonl_candidate`:OpenAI-compatible `messages + tools`;5 分桶(positive / ambiguity / unsafe / readback / no_think_formatting)。验收:JSONL 合法 + 5 桶齐 + tokenizer rendering 通过。
- [ ] 2.2 **从 50 条 redacted candidate 起 + 人工审核**(磊哥)再扩大。**需磊哥显式授权从运行态 DB 生成**。验收:50 条经人工审核。

## 3. eval 锁定(5 态第 4 态)

- [ ] 3.1 `eval_jsonl_locked`:`demo_must_pass` 样本标 `must_not_train: true`(eval/train 分离,防泄漏)。验收:eval 集与 train 集无交集。

## 4. LoRA 训练 + 对比(5 态第 5 态)

- [ ] 4.1 本地装 `mlx-lm[train]`;MLX-LM LoRA(rank 8/16、alpha 16/32、dropout 0.05、target `q_proj/v_proj` 起步;**think traces 不算 loss**;输出 Q4)。验收:LoRA adapter 产出,**adapter 不入仓**。
- [ ] 4.2 `base_vs_lora_eval`:同 tool schema / 温度 / parser / mock state 对比 base vs LoRA。验收:fuzzy/cross-domain 命中率 base→LoRA 提升,且规则/guard/readback 不变。

## 5. 验收门

- [ ] 5.1 redaction validator fail-closed 全测试(5+ 敏感类型)。
- [ ] 5.2 **数据 / 五件套 / 训练集 / adapter 不入仓**(`git status` 验);仅最终 LoRA 权重产物可入仓。
- [ ] 5.3 LoRA 只改善 fuzzy/cross-domain,不替代规则 / schema / DemoGuard / readback;`openspec validate define-lora-pipeline` 通过。
