<!--
DRAFT SKELETON (2026-06-23) — delta 占位待补，人审定 propose 时细化 Requirement/Scenario。
本 delta MODIFY 现有 archived capability `semantic-function-contract`（openspec/specs/semantic-function-contract/spec.md）。
方向锚（cascade-inventory T1 + paradigm §17/§18）：
  - §Purpose 填实：C1 契约源行级全集(3990)，device×action-primitive×slot 三元 + value 四件套，
    device/primitive 是 D-domain 具名工具生成的源，非 generic frame。
  - surface 形态翻案：model-visible surface = D-domain 具名工具(value 形态编码进名)，停用 tool_call_frame 映射。
  - exec_tier=L1 仅从 reviewed l1-demo-allowlist 派生 + 对齐 D-domain 集合。
  - canonical IR (device×action×value) 不变；jsonl 源行级全集不改。
-->

## MODIFIED Requirements

### Requirement: model-visible surface SHALL be D-domain named tools
契约 SHALL 将 model-visible surface 定为 D-domain 具名工具（value 形态编码进工具名），canonical IR 仍 device×action×value（codegen 派生 surface 与 IR 双层），SHALL 停用 generic `tool_call_frame` 作 model-visible 形态。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 paradigm §1-§2/§17 + cascade-inventory T1 `semantic-function-contract/spec.md` verdict 填实。

#### Scenario: D-domain surface derives from frozen snapshot codegen (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（surface 工具名生成、IR 双层映射、tool_call_frame 显式移除验证）
