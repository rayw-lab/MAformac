<!--
DRAFT SKELETON (2026-06-23) — tasks 占位待细化，人审定 propose 时展开为可验收逐项。
依赖序：本 change = A2 [4] C5 surface/正样本/用户文本，依赖 migrate-d-domain-tool-surface([1] codegen)。
incremental，禁大爆炸；守 rank16Mainline scale=20 / LR 1e-4（不重开配方）。
-->

## 1. 前置依赖

- [ ] 1.1 确认 `migrate-d-domain-tool-surface` 已 archive（D-domain codegen surface 就绪 + 工具数 value-form 实算）。验证：上游 surface digest 可引用。
- [ ] 1.2 确认 archived `lora-training` spec 是活方法契约。验证：`openspec list --json` + `openspec validate --all --strict` pass。

## 2. D-domain 训练数据（[4]）

- [ ] 2.1 训练样本 surface 翻案：expected_tool_calls → D-domain 具名工具（DRAFT 待细化）。验证：grep 无 `tool_call_frame` 残留。
- [ ] 2.2 四类数据生成（正样本/unsupported/safety/followup），10 族 562 intent scope（云 generator + 异源 judge + contract 标签 + 原文 oracle 非训练集）。
- [ ] 2.3 训练面 = 推理面 parity：surface 从上游 A2 codegen 单源派生。验证：train/eval surface digest 一致（fail-closed）。
- [ ] 2.4 数据质量门（per-seed variant cap / 近重 / ambiguous duplicate / lineage overlap / epoch exposure / masking 覆盖）。

## 3. 训练（守配方）

- [ ] 3.1 rank16 candidate 训练：scale=20 / LR 1e-4 / adamw / 梯度裁剪 repo loop / PR2 verified loop（不重开配方）。
- [ ] 3.2 训练 receipt replayable（data/model/tokenizer/loop SHA/env/seed/optimizer/clip/nonfinite/checkpoint policy/adapter digest）。

## 4. C6 候选评测（同 harness，→ 详见 rebuild-c6 change）

- [ ] 4.1 base-vs-LoRA C6 diff 同 harness（base action hard_pass 10/23 锚）。验证：candidate 相对 base 不退化（最低门）。
- [ ] 4.2 7 demo-critical case（安全拒识/ASR 澄清/工具映射）通过训练改善（非放宽判等）。
- [ ] 4.3 heldout/OOD 诊断（lineage/near-neighbor 防 leakage）。

## 5. 验证与收口

- [ ] 5.1 `openspec validate retrain-c5-lora-d-domain --strict` + `--all --strict` pass。
- [ ] 5.2 异源审计（非同 Claude/Codex 家族）+ GPT Pro 终审，candidate 签名门。
- [ ] 5.3 红线检查：无原文/PII/密钥/真实 bug 训练集入仓；仅 LoRA 权重产物可入仓；V-PASS 两层分开（model-quality vs endpoint）。
