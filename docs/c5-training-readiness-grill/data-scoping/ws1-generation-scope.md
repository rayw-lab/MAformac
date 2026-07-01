---
artifact_kind: c5_training_readiness_ws1_generation_scope
status: design_only_analysis
created: 2026-07-01
repo_head: e894eb716692e78d8eaafc75b40bdb6d6a5bfc09
r7_boundary: no_generation_no_training_no_model_run
---

# WS1 10 族数据生成 scope 分析

## 结论摘要

- **当前权威 scope 不是 422/397 未定，而是 10 族 562 intent / 191 device / 2159 row**。422 vs 397 是旧正则边界分叉的历史问题；当前 G4/A1 后 explicit allowlist 已收口，562 是全仓唯一权威口径。证据：`docs/research/2026-06-22-mvp-10family-device-boundary.md:3`, `docs/research/2026-06-22-mvp-10family-device-boundary.md:5`, `docs/research/2026-06-22-mvp-10family-device-boundary.md:21`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:188`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:224`。
- **WS1 生成规划下限：约 5994 条候选**，拆为 positive 2248 / followup 2208 / unsupported_refusal 976 / safety_refusal 562。这个是 generator scope 估算，不是训练集 lock，也不是已生成数据。依据：10 族不训全集、按 scope_tier 四类拆；C1 四类数据；per_seed<=8 且总量级待实算。证据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:126`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:134`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:211`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:392`。
- **旧 PR3 生成物不能直接复用为新训练集**：4500 条里 3804 条能按 contract_row_id 映射到当前 10 族，但旧文件没有新四类 scope_tier、多轴 held-out、diversity gate、redaction/gate receipt 字段；最多作为候选池重新过 judge/gate。证据：旧文件字段见 `Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl:1`；新 gate 要求见 `docs/c5-training-readiness-grill/worker-1-data-decisions.md:31`, `docs/c5-training-readiness-grill/worker-1-data-decisions.md:53`, `docs/c5-training-readiness-grill/worker-1-data-decisions.md:55`。

## 一手源与口径

| 源 | 本次用途 | file:line |
|---|---|---|
| `contracts/semantic-function-contract.jsonl` | 3990 canonical IR/value-form 源；字段含 `contract_row_id/device/intent/value/fc_flags/second_turn_refs` | `contracts/semantic-function-contract.jsonl:1` |
| `contracts/semantic-followup-transitions.jsonl` | 二次交互转移源；字段含 first/second canonical semantic id 与 intent | `contracts/semantic-followup-transitions.jsonl:1` |
| `docs/research/2026-06-22-mvp-10family-device-boundary.md` | 10 族 device/intent/row 权威表，解决 422 vs 397 分叉 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:25` |
| `generated/family-device-allowlist.json` | explicit allowlist 派生产物；meta 记 demo/oos 口径与 verify 命令 | `generated/family-device-allowlist.json:285` |
| `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` | 10 族 scope_tier、四类数据、旧口径作废 | `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:124` |
| `docs/c5-training-readiness-grill/worker-1-data-decisions.md` | 数据 gate / generator / judge / held-out proposed 决策 | `docs/c5-training-readiness-grill/worker-1-data-decisions.md:14` |

本轮只跑本地静态解析和 JSONL join；没有生成 utterance、没有训练、没有模型调用。

## 10 族 intent 回顾

当前权威 per-family 口径：

| 族 | device | intent | contract rows | 证据 |
|---|---:|---:|---:|---|
| 空调 | 25 | 68 | 212 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:29` |
| 座椅 | 36 | 126 | 696 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:30` |
| 车窗 | 11 | 27 | 82 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:31` |
| 车门 | 21 | 48 | 129 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:32` |
| 灯光氛围 | 29 | 113 | 468 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:33` |
| 屏幕 | 33 | 75 | 205 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:34` |
| 音量 | 11 | 32 | 153 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:35` |
| 雨刮 | 8 | 27 | 80 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:36` |
| 天窗遮阳帘 | 10 | 30 | 102 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:37` |
| 香氛 | 7 | 16 | 32 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:38` |
| **合计** | **191** | **562** | **2159** | `docs/research/2026-06-22-mvp-10family-device-boundary.md:39` |

边界依赖：

- 派单里的 **422CC vs 397GLM 未定**应标为历史分叉，不应继续当 WS1 当前 blocker。文档说明该分叉根因是 substring/prefix 正则边界未定义，explicit allowlist 后 intent=562。证据：`docs/research/2026-06-22-mvp-10family-device-boundary.md:5`, `docs/research/2026-06-22-mvp-10family-device-boundary.md:21`。
- 旧 534/2086/52.3% 也作废；当前族外为 480 device / 976 intent / 1831 rows。证据：`docs/research/2026-06-22-mvp-10family-device-boundary.md:47`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:224`, `generated/family-device-allowlist.json:286`。
- `562` 是 intent 数，**不是工具数**；工具数仍待 value-form 实算。证据：`docs/research/2026-06-22-mvp-10family-device-boundary.md:114`, `generated/family-device-allowlist.json:302`, `docs/c5-training-readiness-grill/worker-1-data-decisions.md:21`。

## 估算规则

WS1 只给 gate7 generator 的 batch scope 下限，避免把“可生成候选数”误写成“训练集已定量”。

| 数据类 | 估算规则 | 本轮量级 | 依据 |
|---|---|---:|---|
| `positive` | 每个 10 族 intent 先 4 条候选；低于 `per_seed<=8` 上限，给多源 generator + 多模板留空间 | 562 × 4 = 2248 | 四类数据已拍：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:134`；per_seed 上限：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:392` |
| `followup` | 10 族内/指向 10 族的 transition 每条先 1 条候选；本轮从 3123 transitions join explicit allowlist 得 2208 | 2208 | followup 源字段：`contracts/semantic-followup-transitions.jsonl:1`；短时记忆数据基座：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:173` |
| `unsupported_refusal` | 族外 976 intent 每 intent 1 条拒识候选；表内按 10 族 intent 占比分摊到相邻 distractor 任务 | 976 | 族外 unsupported：`docs/research/2026-06-22-mvp-10family-device-boundary.md:47`；族外兜底非泛化：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:216` |
| `safety_refusal` | 先按每个 10 族 intent 1 条安全/澄清拒识候选作为下限；risk policy 独立，不挂 C1 行 | 562 | safety_refusal 属四类数据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:213`；risk 不挂 C1 行：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:401` |

## 10 族生成 scope 表

| 族 | 10族 intent | positive | followup | unsupported_refusal | safety_refusal | 合计估算 | 一手依据 |
|---|---:|---:|---:|---:|---:|---:|---|
| 空调 | 68 | 272 | 354 | 118 | 68 | 812 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:29`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 座椅 | 126 | 504 | 906 | 219 | 126 | 1755 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:30`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 车窗 | 27 | 108 | 122 | 47 | 27 | 304 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:31`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 车门 | 48 | 192 | 129 | 83 | 48 | 452 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:32`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 灯光氛围 | 113 | 452 | 194 | 196 | 113 | 955 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:33`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 屏幕 | 75 | 300 | 0 | 130 | 75 | 505 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:34`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 音量 | 32 | 128 | 0 | 56 | 32 | 216 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:35`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 雨刮 | 27 | 108 | 137 | 47 | 27 | 319 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:36`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 天窗遮阳帘 | 30 | 120 | 196 | 52 | 30 | 398 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:37`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| 香氛 | 16 | 64 | 170 | 28 | 16 | 278 | 族 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:38`；followup join 源：`contracts/semantic-followup-transitions.jsonl:1` |
| **合计** | **562** | **2248** | **2208** | **976** | **562** | **5994** | 合计 scope：`docs/research/2026-06-22-mvp-10family-device-boundary.md:39`; 四类与总量待实算：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:392` |

解释：

- `positive` 以 intent 为 seed，不以 2159 rows 全量乘 4；否则会把 value-form row 当独立语义 seed，第一刀过大。
- `followup` 是本轮从 3123 transition 按 first/second canonical semantic id join 到 explicit allowlist 的计算值；屏幕、音量为 0，是当前 transition 源内未命中，不代表永远不需要补 followup。
- `unsupported_refusal` 是族外 976 intent 的总池，表内按 10 族 intent 占比分摊，是给 prompt/distractor 编排的 batch quota；真正 label 仍应标为族外 unsupported，不应伪装成对应 10 族 positive。
- `safety_refusal` 先按 562 下限规划；安全规则权威应来自 `contracts/risk-policy.yaml`，不是 C1 `risk` 字段。证据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:401`。

## 旧 glm/hermes 生成物复用评估

本轮本地 join 结果：

| 指标 | 数值 | 解释 | 证据 |
|---|---:|---|---|
| 旧生成物总行 | 4500 | 文件为 PR3 旧 scope 生成 utterance | `Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl:1` |
| 可映射当前 10 族 | 3804 | `contract_row_id` 能 join 到当前 explicit allowlist 的 10 族 device | 合同字段源：`contracts/semantic-function-contract.jsonl:1`; allowlist meta：`generated/family-device-allowlist.json:285` |
| 族外/非 10 族 | 696 | 不能直接作为 10 族 positive；只能作为 unsupported 候选或丢弃 | 族外定义：`docs/research/2026-06-22-mvp-10family-device-boundary.md:47` |
| 覆盖 10 族 contract rows | 1420/2159 | 覆盖不完整，且不是新四类 scope_tier | 10 族 rows：`docs/research/2026-06-22-mvp-10family-device-boundary.md:39` |
| generator/judge 形态 | hermes_glm / hermes_ark_standard 互审 | 有异源 judge 雏形，但缺新 gate 字段 | 旧字段：`Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl:1`; 异源 judge 要求：`docs/c5-training-readiness-grill/worker-1-data-decisions.md:51` |

复用 verdict：

- **不可直接复用进训练**：旧文件没有 `scope_tier`、`template_family`、`value_type`、`generator_source` 轴级 gate 结果，也没有新 `positive/followup/unsupported_refusal/safety_refusal` 四类配比。证据：旧字段见 `Reports/c5-remediation-wave-20260621T2013-pr3-full/generated-utterances-final.jsonl:1`；多轴 held-out 要求见 `docs/c5-training-readiness-grill/worker-1-data-decisions.md:31`。
- **可作为候选回收池**：3804 条 10 族样本可按 `contract_row_id` 回挂到 562 scope，重新跑 redaction、label_conflict、diversity gate、异源 judge、多轴 held-out 后，合格者才能转为 `positive` 候选。证据：候选→judge→dedupe/diversity→redaction→heldout→eligible pipeline 见 `docs/c5-training-readiness-grill/worker-1-data-decisions.md:60`。
- **不能喂给新 cloud prompt 当 seed**：W1 决策建议 cloud prompt 只喂语义协议和约束，不喂旧 jsonl 样本。证据：`docs/c5-training-readiness-grill/worker-1-data-decisions.md:55`。

## 不确定项 / 下一步

1. **compact positive 418 未重算**：当前文档明确 418 不直接拍，需 A1 按 scope_tier 拆后重算；WS1 用 562 intent ×4 作为 generator 下限，不等价于 compact positive lock。证据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:232`, `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:264`。
2. **工具数未实算**：562 不能当 D-domain tool count，A2 value-form tool 目录仍要实算。证据：`docs/research/2026-06-22-mvp-10family-device-boundary.md:114`, `generated/family-device-allowlist.json:302`。
3. **safety_refusal 最终量级依赖 risk-policy 派生**：C1 risk 字段不应承载 safety，WS1 只给每 intent 1 条的下限。证据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:401`。
4. **followup 为当前 transition 源 join 值**：2208 是从 `semantic-followup-transitions.jsonl` join explicit allowlist 的结果；若后续补屏幕/音量多轮 seed，scope 表要更新。证据：transition 源见 `contracts/semantic-followup-transitions.jsonl:1`。
