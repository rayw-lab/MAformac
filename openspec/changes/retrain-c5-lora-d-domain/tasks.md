<!--
DRAFT SKELETON (2026-06-23) — tasks 占位待细化，人审定 propose 时展开为可验收逐项。
依赖序：本 change = A2 [4] C5 surface/正样本/用户文本，依赖 migrate-d-domain-tool-surface([1] codegen)。
incremental，禁大爆炸；守 rank16Mainline scale=20 / LR 1e-4（不重开配方）。
-->

> Phase 0 boundary: unchecked future tasks are not apply authorization. D1-D10 user verdicts are accepted in `docs/project/phase0/phase0-d1-d10-user-decision-record.md`, but this draft remains non-executable until OpenSpec propose acceptance, R-L17 handling, and physical evidence gates are recorded. It does not authorize data generation, training, model-quality evaluation, endpoint-ready claims, demo-golden-run, voice, or UIUE merge.

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
- [ ] 2.5.G4 R-L05/D2 mid-training behavior gate：iter50/100/150 各抽样 5 条，跑端到端 D-domain tool-call 判定，记录 `continue | human_pause | early_stop | blocked`；gate 必须在 train() 外层 infra-enforced，failure raise 自动停训；val-loss 不得作为唯一继续依据；`human_pause` 必须人工审 50 条样本输出并附 R-L17 R1/R2 evidence files；iter50 若 >=1 条工具名落 generic frame，直接 `blocked`。AD：`AD-C5-004`。
- [ ] 2.5.G5 R-L07/D3 data-ratio spike gate：起点 positive 20 / unsupported 6 / safety 3 / followup 2；扫描 6.7% 到 24%，用 active base IrrelAcc 0.789 作为过拒识拐点底线；negative 不得为零，safety >=3%，unsupported 包含 D10 already_state 子类但不得混成 unsupported。AD：`AD-C5-005`。
- [ ] 2.5.G5a D6 general-Chinese regression gate：同一 candidate 混 10-15% 通用中文 hypothesis；base 必须是 raw Qwen3-1.7B；C-Eval/CMMLU 或等价中文零样本回归退化 >5% 保持 `UNSIGNED`；至少包含一个非工具调用任务；不加英文 MMLU、知识截止日 fact-checking、医疗/法律等专业中文域。AD：`AD-C5-010`。
- [ ] 2.5.G5b D7 failure minimal-seed gate：砍完整 HA 风格三轮恢复链；只留 factor <= 2、<= 50 行 receipt 的 single-turn parser-failure -> 自然中文澄清样本；failure turn 使用 loss-mask kernel 且 `train_on_turn=false`；不得训练模型主动生成错误调用再恢复。AD：`AD-C5-005`, `AD-C5-006`。
- [ ] 2.5.G6 R-L11 gate-integrity gate：所有 pass claim 必须来自 first-hand artifacts；D2/D3/D6/D7 证据未物理存在时 candidate 保持 `UNSIGNED/BLOCKED`；D3/D6/D7 必须共用同一 candidate id，禁止跨 candidate cherry-pick；grader failure 保持 `UNSIGNED/BLOCKED`。AD：`AD-C5-006`。
- [ ] 2.5.G7 R-L17 human review gate：R-L17 status remains `UNSIGNED` until G1-G5 are all satisfied: D1-D10 verdicts accepted, R1-R7 evidence files exist, at least one heterogeneous deframing audit exists, four-model consistent PASS has not bypassed human review, and any judge disagreement is escalated to human-owner review. Codex/Claude same-vendor checks are pre-check only. AD：`AD-C5-007`。
- [ ] 2.5.G7a R-L17 R1 first-50 sample read：逐条 read first-50 training samples, record row ids, labels, expected tool/no-call, and verdict in `docs/project/phase0/r-l17-human-review-evidence/R1-first-50-sample-read.md`。AD：`AD-C5-007`。
- [ ] 2.5.G7b R-L17 R2 loss-mask print review：人工核 loss-mask print 的 train_on_turn/function/arg-value 三形态物理实装；metadata 声称不算；记录在 `R2-loss-mask-print-review.md`。AD：`AD-C5-007`。
- [ ] 2.5.G7c R-L17 R3 train-eval template byte diff：对 train/eval render template 做 byte diff，不能用 "looks same"；记录 diff command/output/path in `R3-train-eval-template-byte-diff.md`。AD：`AD-C5-007`。
- [ ] 2.5.G7d R-L17 R4 refusal/already_state comparison：refusal and already_state samples must be compared against home-llm refusal/already_state evidence; include at least 30 natural-language already_state/readback rows before D10 model-training ownership can change; record in `R4-refusal-already-state-home-llm-comparison.md`。AD：`AD-C5-007`, `AD-C5-009`。
- [ ] 2.5.G7e R-L17 R5 top-failing C6 drilldown：top failing C6 cases must be drilled down case-by-case to distinguish strict judging from real model failure; record in `R5-top-failing-c6-case-drilldown.md`。AD：`AD-C5-007`。
- [ ] 2.5.G7f R-L17 R6 generated utterance drift：human review generated utterance drift and generator self-preference; record row ids and drift verdict in `R6-generated-utterance-drift-review.md`。AD：`AD-C5-007`。
- [ ] 2.5.G7g R-L17 R7 final route signoff：human owner signs final route decision for candidate signature/paradigm choice/D2-D10 implications; if multiple models all PASS, this step must still read first-hand file:line evidence and cannot cite only derived receipts. Record in `R7-final-route-deframing-signoff.md`。AD：`AD-C5-007`。
- [ ] 2.5.G8 D10 already_state/state-noop gate：`already_state` 作为独立第五状态类；默认由 C3 + readback renderer 判定，训练集只学自然语言回答模板；仅当 C6 evidence 证明自然语言 already_state FN >20% 且 R-L17 R4 evidence exists 才纳入模型决策训练；readback 必须区分 defaulted / explicit / already_state scope origin。AD：`AD-C5-009`。
- [ ] 2.5.G9 Default-scope dependency gate：`define-demo-default-scope` must be proposed and validated before C5 data generation, target rendering, or retrain. Omitted-scope targets must omit scope args or derive them from C2 `default_scope`; hardcoded scope candidates and `position=全车` for missing scope are blocked. This task depends on `define-demo-default-scope` and does not redefine default-scope behavior. AD：`AD-C5-DS-001`。

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
