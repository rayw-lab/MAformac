<!--
DRAFT SKELETON (2026-06-23) — delta 占位待补，人审定 propose 时细化 Requirement/Scenario。
本 delta MODIFY 现有 archived capability `tool-execution`（openspec/specs/tool-execution/spec.md）。
方向锚（cascade-inventory T1 `tool-execution/spec.md` verdict + paradigm §17）：
  - 工具调用帧形态 = D-domain 具名工具 [device+primitive 枚举]×slot×value[四件套]，
    不再 generic `tool_call_frame{device,action,value}`；场景示例改真实工具名。
  - DemoGuard 读 D-domain 白名单(非 generic frame)，过期 tool_call_frame 从 scope 删。
  - 补 Purpose TBD（现 spec Purpose = "TBD - created by archiving change define-execution-contract"）。
-->

## MODIFIED Requirements

### Requirement: tool-call frame SHALL be a D-domain named tool
运行时单发工具调用帧 SHALL 为 D-domain 具名工具（device+primitive 枚举）×slot×value 四件套，SHALL NOT 为 generic `tool_call_frame{device,action,value}`；DemoGuard SHALL 读 D-domain 白名单。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 cascade-inventory T1 `tool-execution/spec.md` verdict 填实。

#### Scenario: DemoGuard reads D-domain allowlist (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（D-domain 白名单匹配、过期 tool_call_frame 拒绝、真实工具名示例）
