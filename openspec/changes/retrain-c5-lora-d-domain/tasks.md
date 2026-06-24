<!--
DRAFT SKELETON (2026-06-23) — tasks 占位待细化，人审定 propose 时展开为可验收逐项。
依赖序：本 change = A2 [4] C5 surface/正样本/用户文本，依赖 migrate-d-domain-tool-surface([1] codegen)。
incremental，禁大爆炸；守 rank16Mainline scale=20 / LR 1e-4（不重开配方）。
-->

> Phase 0 boundary: unchecked future tasks are not apply authorization. This draft remains non-executable until `docs/project/phase0/phase0-d1-d10-user-decision-record.md` has non-pending user verdicts where required and OpenSpec propose acceptance is recorded. It does not authorize data generation, training, model-quality evaluation, endpoint-ready claims, demo-golden-run, voice, or UIUE merge.

## 1. 前置依赖

- [ ] 1.1 确认 `migrate-d-domain-tool-surface` 已 archive（D-domain codegen surface 就绪 + 工具数 value-form 实算）。验证：上游 surface digest 可引用。
- [ ] 1.2 确认 archived `lora-training` spec 是活方法契约。验证：`openspec list --json` + `openspec validate --all --strict` pass。

## 2. D-domain 训练数据（[4]）

- [ ] 2.1 训练样本 surface 翻案：expected_tool_calls → D-domain 具名工具（DRAFT 待细化）。验证：grep 无 `tool_call_frame` 残留。
- [ ] 2.2 四类数据生成（正样本/unsupported/safety/followup），10 族 562 intent scope（云 generator + 异源 judge + contract 标签 + 原文 oracle 非训练集）。
- [ ] 2.3 训练面 = 推理面 parity：surface 从上游 A2 codegen 单源派生。验证：train/eval surface digest 一致（fail-closed）。
- [ ] 2.4 数据质量门（per-seed variant cap / 近重 / ambiguous duplicate / lineage overlap / epoch exposure / masking 覆盖）。
- [ ] 2.5.G1 R-L09 sample observability gate：从样本实际 `tools` 计算 `no_call_target_present`，计算 `label_conflict_flag`，输出 per-class receipt 分布；任一 target-present no-call 或 label conflict fail-closed。AD：`AD-C5-002`。
- [ ] 2.5.G2 R-L02 surface-source gate：train/eval/runtime D-domain surface digest 必须来自同一 A2 source；`tool_call_frame` 残留阻断 retrain。AD：`AD-C5-001`。
- [ ] 2.5.G3 R-L03 byte-parity gate：记录 training render bytes、endpoint render bytes、think signature、mask offset start token；nil endpoint render = blocked，不是 pass。AD：`AD-C5-003`。
- [ ] 2.5.G4 R-L05 mid-training behavior gate：定义 iter50/100/150 行为生成抽样，解析 tool calls，调用 C6 第一/第二层 sample runner，记录 `continue | human_pause | early_stop | blocked`。AD：`AD-C5-004`。
- [ ] 2.5.G5 R-L07 data recipe gate：保留 positive/unsupported/safety/followup 四类，比例为 hypothesis，IrrelAcc 不得低于 active base anchor。AD：`AD-C5-005`。
- [ ] 2.5.G6 R-L11 gate-integrity gate：所有 pass claim 必须来自 first-hand artifacts；grader failure 保持 `UNSIGNED/BLOCKED`。AD：`AD-C5-006`。
- [ ] 2.5.G7 R-L17 human review gate：first-50 sample、loss-mask print、train-eval template diff、refusal samples、top failing C6 cases、utterance drift、final route deframing review 均需证据。Codex subagent 仅为 same-vendor pre-check，不替代异源/反框终审。AD：`AD-C5-007`。

## 3. 训练（守配方）

- [ ] 3.1 rank16 candidate 训练：scale=20 / LR 1e-4 / adamw / 梯度裁剪 repo loop / PR2 verified loop（不重开配方）。
- [ ] 3.2 训练 receipt replayable（data/model/tokenizer/loop SHA/env/seed/optimizer/clip/nonfinite/checkpoint policy/adapter digest）。
- [ ] 3.3 训练状态边界：`train_health`、loss health、training receipt 不得推出 `model_quality`、`lora_candidate`、`endpoint_candidate`、V-PASS 或 demo readiness。AD：`AD-C5-008`。

## 4. C6 候选评测（同 harness，→ 详见 rebuild-c6 change）

- [ ] 4.1 base-vs-LoRA C6 diff 同 harness（base action hard_pass 10/23 锚）。验证：candidate 相对 base 不退化（最低门）。
- [ ] 4.2 7 demo-critical case（安全拒识/ASR 澄清/工具映射）通过训练改善（非放宽判等）。
- [ ] 4.3 heldout/OOD 诊断（lineage/near-neighbor 防 leakage）。

## 5. 验证与收口

- [ ] 5.1 `openspec validate retrain-c5-lora-d-domain --strict` + `--all --strict` pass。
- [ ] 5.2 异源审计（非同 Claude/Codex 家族）+ GPT Pro 终审，candidate 签名门。
- [ ] 5.3 红线检查：无原文/PII/密钥/真实 bug 训练集入仓；仅 LoRA 权重产物可入仓；V-PASS 两层分开（model-quality vs endpoint）。
