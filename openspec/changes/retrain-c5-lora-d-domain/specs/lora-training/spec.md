<!--
DRAFT SKELETON (2026-06-23) — delta 占位待补，人审定 propose 时细化 Requirement/Scenario。
本 delta MODIFY 现有 archived capability `lora-training`（openspec/specs/lora-training/spec.md）。
方向锚（cascade-inventory T1 `lora-training/spec.md` verdict + paradigm 四类数据 + C5 recovery）：
  - samples 中 expected_tool_calls 映射到 D-domain 具名工具(非 tool_call_frame)；
    sample_shape「tool_call_frame」改「D-domain 工具集」。
  - 10 族 562 intent scope；scope_tier 拆 候选562 / compact positive [TBD-待 A1 scope_tier 拆后重算] / 四类数据。
    （注：compact positive 418 是 codex 口径不同【待重算】，paradigm §14:232 + master §0 列 418 为废口径禁引；DRAFT 占位，propose 按 A1 重算填实，cite 挂 §13 A3 / §14:232 非 §13 G4——§13 G4 正文只含 562/2159 不含 418。）
  - 四类数据 = 正样本(D-domain) / unsupported(族外) / safety(L4 拒识) / followup(多意图+短时记忆)。
  - 训练面 = 推理面 parity（surface 从上游 A2 codegen 单源派生，防 0/34 异源根因）。
  - 守配方 rank16Mainline scale=20 / LR 1e-4（不重开，21 议题已收口）。
注：lora-training spec Purpose 已填(非 TBD)。
-->

## MODIFIED Requirements

### Requirement: training samples SHALL use D-domain named tools
C5 训练样本 expected_tool_calls SHALL 映射 D-domain 具名工具，sample_shape SHALL 为「D-domain 工具集」，SHALL NOT 用 generic `tool_call_frame`；训练 surface SHALL 从上游 A2 codegen 单源派生（与 eval/runtime parity）。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 cascade-inventory T1 `lora-training/spec.md` verdict + paradigm 四类数据填实。

#### Scenario: D-domain samples derive from single codegen source (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（D-domain 样本生成、train/eval surface digest parity、tool_call_frame 拒绝）

### Requirement: candidate data SHALL cover four sample classes over 10-family scope
训练数据 SHALL 覆盖 10 族 562 intent scope 的四类样本（正样本/unsupported/safety/followup），来源 SHALL 为云 generator 生成 + 异源 judge 把关 + contract 定标签 + 原文 oracle（非训练集）。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 paradigm §13 G4 scope_tier + C1 四类数据填实。

#### Scenario: Four-class coverage over scope_tier (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（四类数据计数对齐 G4、judge/oracle 把关、原文不进训练集）
