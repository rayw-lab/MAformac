<!--
DRAFT SKELETON (2026-06-23) — delta 占位待补，人审定 propose 时细化 Requirement/Scenario。
本 delta MODIFY 现有 archived capability `vehicle-tool-bench`（openspec/specs/vehicle-tool-bench/spec.md）。
方向锚（cascade-inventory T1 `vehicle-tool-bench/spec.md` verdict + C5 recovery C6 真口径 + Q41）：
  - qwen-tool-call-format.yaml 定义 D-domain 工具名集合与字段映射(非 generic frame)。
  - 四层评测门：golden 100% 硬门 / demo_fuzz / unsupported / safety 各独立门(Q41 禁互相冒充)。
  - expected_tool_calls 从旧 6 工具扩到 10 族炸场子集；c6-bench-cases.jsonl 迁 D-domain 具名工具。
  - action hard_pass 按 case schema 字段拆(base 10/23 硬锚，非整体 7/57)。
  - readback 走方案 P(端 renderer renderReadback SSOT，eval 删不计 hard_pass)；clarify 全保留计 hard_pass。
  - base Qwen3-1.7B hard_fail 0.789 为 LoRA 提升诚实锚点(不洗白)。
注：vehicle-tool-bench spec Purpose = "TBD"，须随本 change 填实。
-->

## MODIFIED Requirements

### Requirement: expected tool calls SHALL be D-domain named tools
C6 bench cases 的 expected_tool_calls SHALL 映射 D-domain 具名工具名，`qwen-tool-call-format.yaml` SHALL 定义 D-domain 工具名集合与字段映射，SHALL NOT 用 generic `tool_call_frame`。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 cascade-inventory T1 `vehicle-tool-bench/spec.md` verdict 填实。

#### Scenario: D-domain expected_tool_calls migration (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（57 行迁 D-domain、P0-3 陷阱样本确认、verify-gold pass）

### Requirement: C6 SHALL grade in four independent layers
C6 SHALL 分四层独立评测门（golden 100% 硬门 / demo_fuzz / unsupported / safety），各门独立 SHALL NOT 互相冒充；action hard_pass SHALL 按 case schema 字段拆（base 10/23 硬锚）；readback SHALL 走方案 P（端 renderer，不计 hard_pass）；clarify SHALL 全保留计 hard_pass。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 Q41 + C5 recovery C6 真口径填实。

#### Scenario: Four-layer gates do not impersonate each other (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（四层独立计分、action hard_pass schema-field 拆、readback 方案 P、clarify 保留）
