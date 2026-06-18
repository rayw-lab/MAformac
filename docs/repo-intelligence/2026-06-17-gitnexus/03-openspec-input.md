# 下一阶段 OpenSpec 输入

> ⚠️ **capability schema 部分已 SUPERSEDED** by `contracts/capabilities.yaml`(2026-06-18 change2 定稿,8 条 `cabin.*` 能力)。本文其余(change 拆法等)仍作历史输入参考。

状态: `candidate`  
目的: 把 GitNexus 分析沉淀成 `define-demo-mvp-contract` 或后续 capability change 的可执行输入。

## 推荐 change 拆法

不要直接开“大而全 Agent”实现。建议第一组 change 顺序:

1. `define-demo-mvp-contract`: 锁 demo 成功标准、non-goals、行为边界。
2. `define-capability-contract`: 建 `contracts/capabilities.yaml` 和 8 条能力样板。
3. `define-toolcall-frame-and-validation`: 建 `ToolCallFrame`, decoder, validator, error enum。
4. `define-demo-guard-and-mock-state`: 建 `DemoGuard`, `DemoVehicleStateStore`, readback trace。
5. `define-voice-and-llm-backend-boundaries`: 建 ASR/TTS/LLMBackend/MCP Swift 边界。
6. `define-vehicle-tool-bench`: 建 eval fixture 和 scoring schema。

## 行为契约候选

### Requirement: Capability Contract Source

The system SHALL treat `contracts/capabilities.yaml` as the single manually maintained source for vehicle demo capabilities.

Scenario:

- GIVEN a capability such as seat heating or cabin light
- WHEN tool schemas, UI cards, eval fixtures, LoRA samples, or mock state bindings are generated
- THEN they SHALL derive from the same capability contract
- AND generated files SHALL NOT become independent authority

### Requirement: Tool Call Frame Validation

The system SHALL validate every model-produced tool call before execution.

Scenario:

- GIVEN a model output containing a candidate tool call
- WHEN `ToolCallDecoder` parses it
- THEN unknown tools, extra fields, invalid enum values, unsafe arguments, and missing required fields SHALL return typed errors
- AND no mock state SHALL be mutated

### Requirement: Demo Guard Before Execution

The system SHALL run code-based `DemoGuard` checks before every mock vehicle action.

Scenario:

- GIVEN a decoded tool call for a writable capability
- WHEN the capability requires confirmation, has range limits, or conflicts with another active action
- THEN `DemoGuard` SHALL return `needs_confirmation`, `invalid_argument`, or `unsafe_action`
- AND the assistant SHALL NOT claim completion

### Requirement: Mock Readback

The system SHALL verify execution by reading mock state after mutation.

Scenario:

- GIVEN a safe tool call
- WHEN `DemoActionExecutor` applies the mock transition
- THEN the system SHALL read `DemoVehicleStateStore`
- AND the final spoken/UI result SHALL reflect the readback value, not the requested value alone

### Requirement: Voice Boundary

The system SHALL keep ASR, intent resolution, execution, and TTS as separate stages.

Scenario:

- GIVEN user speech input
- WHEN ASR returns text and confidence
- THEN ASR SHALL NOT execute tools
- AND the intent/tool stages SHALL run through the same decoder, guard, executor, and readback pipeline as typed text

## `contracts/capabilities.yaml` schema draft

```yaml
capabilities:
  - id: cabin.seat_heat.driver
    status: candidate
    display:
      zh_name: 主驾座椅加热
      aliases: ["主驾加热", "座椅热一点"]
      examples:
        positive: ["把主驾座椅加热打开", "我有点冷，座椅热一点"]
        negative: ["座椅按摩", "方向盘加热"]
    tool:
      name: set_seat_heat
      parameters:
        zone:
          type: enum
          values: ["driver", "passenger"]
        level:
          type: enum
          values: ["off", "low", "medium", "high"]
    reference_binding:
      vss_path: Vehicle.Cabin.Seat.Row1.DriverSide.Heating
      extension_path: null
      readable: true
      writable: true
      value_type: enum
      unit: null
    execution:
      mock_behavior: set_state
      state_key: seat_heat.driver.level
      idempotent: true
      exclusive_bus: comfort
    demo_guard:
      risk_level: low
      confirm_policy: none
      preconditions: ["demo_mode_enabled"]
      block_rules: ["unknown_zone", "invalid_level"]
    response:
      success: "主驾座椅加热已调到{level_zh}。"
      failure: "座椅加热没有完成，原因是{error_zh}。"
    eval:
      tags: ["comfort", "seat", "rule-fast-path"]
      expected_tool: set_seat_heat
    source_refs:
      - repo: COVESA__vehicle_signal_specification
        kind: semantic-binding
      - repo: eclipse-kuksa__kuksa-databroker
        kind: state-model-reference
```

## `ToolCallFrame` draft

```json
{
  "route": "fast|slow",
  "input_text": "把主驾座椅加热打开",
  "candidate_tools": ["set_seat_heat"],
  "tool_call": {
    "name": "set_seat_heat",
    "arguments": {
      "zone": "driver",
      "level": "medium"
    }
  },
  "decode_status": "ok|decode_failed|unknown_tool|invalid_argument|needs_clarification",
  "guard_status": "ok|needs_confirmation|unsafe_action|blocked_by_state",
  "execution_status": "pending|applied|failed|noop",
  "readback": {
    "state_key": "seat_heat.driver.level",
    "actual_value": "medium",
    "revision": 42
  }
}
```

## `vehicle-tool-bench` fixture draft

```json
{
  "id": "comfort-seatheat-001",
  "input": "我有点冷，主驾座椅热一点",
  "context": {
    "current_state": {
      "seat_heat.driver.level": "off",
      "cabin.temperature": 21
    }
  },
  "tools": ["set_seat_heat", "set_temperature", "get_cabin_state"],
  "expected": {
    "route": "slow",
    "tool": "set_seat_heat",
    "arguments": {
      "zone": "driver",
      "level": "medium"
    }
  },
  "error_tag": null,
  "tags": ["fuzzy", "comfort", "cross-domain"]
}
```

## 验收指标

| Metric | Gate |
|---|---|
| Parse rate | `T-PASS >= 95%` on curated set |
| Tool accuracy | `T-PASS >= 90%` |
| Slot F1 | `T-PASS >= 90%` |
| Full-frame accuracy | `T-PASS >= 85%` |
| Unsafe action false pass | `T-PASS = 0` |
| Mock readback mismatch claim | `T-PASS = 0` |
| Candidate tools per turn | `<= 10` |
| Tool parameters | `<= 5` |

