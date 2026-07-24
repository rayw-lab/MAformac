## MODIFIED Requirements

### Requirement: 运行时只接受单发工具调用或非动作帧

控制路径 SHALL 只接受 exactly 1 个工具调用帧、exactly 1 个 NoAction/Clarify 帧，或一个有明确上限且每个子动作可独立审查的多意图计划。每个子动作 SHALL 独立通过严格解码、schema、semantic、precondition、stale-state、DemoGuard、execution 与 readback gate。额外 assistant 文本、缺必填、unknown enum、stale state revision、finish reason 为 length、无界批次或未审查额外动作时，系统 SHALL reject 或 clarify，SHALL NOT repair-to-action。

#### Scenario: 受界多意图逐项过门

- **GIVEN** 一轮包含多个可独立识别的受界子动作
- **WHEN** 运行时审查该计划
- **THEN** 每个子动作 SHALL 独立通过全部适用 gate
- **AND** 任一子动作 SHALL NOT 借兄弟动作的通过结果绕过自己的 gate。

#### Scenario: 一个可执行一个未挂载

- **GIVEN** 一个子动作通过全部执行 gate
- **AND** 另一个子动作对应语义存在但未挂载的 action
- **WHEN** 受界计划执行
- **THEN** 可执行子动作 SHALL 执行并读回
- **AND** 未挂载子动作 SHALL NOT 执行或修改 state
- **AND** 执行层 SHALL 保留 accepted/refused identity 与内部有限原因供现有 bridge 消费。

#### Scenario: length 截断不修成动作

- **WHEN** 模型输出因长度截断导致候选或多意图计划不完整
- **THEN** 系统标记 decode failed
- **AND** 不用 parser repair 生成可执行动作。

#### Scenario: stale state revision 被拒绝

- **GIVEN** 任一工具调用帧携带的 state revision 早于当前 mock state revision
- **WHEN** 系统进入 stale-state gate
- **THEN** 该子动作被拒绝并要求重新规划或澄清
- **AND** 其它子动作仍 SHALL 独立通过自己的 gate。

#### Scenario: 无界或未审查批次被拒绝

- **GIVEN** 一轮包含超出受界上限的调用或未审查的额外 action
- **WHEN** 运行时验证计划形状
- **THEN** 系统 SHALL reject 或 clarify
- **AND** SHALL NOT 任取其中一个 action 执行。

### Requirement: 工具调用全程留痕五段

系统 SHALL 为每轮候选记录 decode、plan、guard、execute、readback 五段 trace，并记录 tool call count、stop reason、candidate source、repair used、guard reason、readback result。受界多意图计划 SHALL 额外记录每个 accepted/refused 子动作 identity、observed tool-call facts、canonical before/after state comparison、accepted readback 与 refused internal finite reason。拒绝子动作 SHALL NOT 修改 state。

这些是执行事实；本 requirement SHALL NOT 定义 public payload schema、public result enum、customer-facing reason text、readback rendering 或 presentation-safe trace envelope。

#### Scenario: 成功动作 trace 可追溯

- **WHEN** 一个动作成功执行并读回
- **THEN** trace 包含 decode、plan、guard、execute、readback 五段
- **AND** 每段包含该段的输入、输出或拒绝原因。

#### Scenario: 拒绝动作 trace 可追溯

- **WHEN** 候选或子动作被任一 gate 拒绝
- **THEN** trace 记录拒绝 gate 与内部有限原因
- **AND** execute/readback 不伪造成功段。

#### Scenario: Partial receipt 区分 accepted 与 refused

- **GIVEN** 同一受界计划同时包含 accepted 与 refused 子动作
- **WHEN** 执行 receipt 生成
- **THEN** accepted 子动作 SHALL 有 observed execution 与 readback evidence
- **AND** refused 子动作 SHALL 有 no-write fact 与 internal finite reason
- **AND** 两者 SHALL 关联到同一 turn/trace identity。

#### Scenario: Refused-only receipt 证明无动作

- **GIVEN** 所有子动作均被拒绝或澄清
- **WHEN** 执行完成
- **THEN** canonical after-state SHALL 等于 before-state
- **AND** observed tool-call count SHALL 为零
- **AND** receipt SHALL NOT 声称 public presentation 字段或成功 readback。

### Requirement: Classified ToolExecutionError SHALL preserve typed non-runtime outcomes

When C3 exposes a classifiable `ToolExecutionError`, execution SHALL classify it as typed fallback, clarify or safety using the closed internal `finiteReason` contract before bridge projection. A classifiable error SHALL preserve its accepted/refused identity and no-write fact where refused; it SHALL NOT crash, disappear, or be collapsed into generic `runtime_error`. Only a genuinely unclassifiable adapter/runtime throw remains the bridge-owned terminal runtime-error path.

Coverage: CG-074.

#### Scenario: C3 ToolExecutionError remains typed before bridge projection

- **GIVEN** C3 reports a `ToolExecutionError` classified as fallback, clarify, or safety
- **WHEN** execution records the refused subaction
- **THEN** it SHALL retain the matching closed `finiteReason` and execution trace fact
- **AND** it SHALL emit no mutation or tool call for the refused subaction
- **AND** it SHALL NOT be collapsed into generic `runtime_error` before the existing bridge projects its safe result.
