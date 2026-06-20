## Why

C1/C2 已 archive 后,旧 `define-execution-contract` 仍基于被 supersede 的扁平 8 能力和泛型 `arguments`。C3 必须重提 propose,把执行链改到 C1 源行级语义契约 + C2 场景端态协议之上,否则后续 apply 会继续把模型候选当旧能力 KV 来执行。

本 change 锁定「模型候选 -> 严格解码 -> gate 链 -> DemoGuard -> mock state -> readback -> trace」的行为契约。它保证模型只产候选,执行边界和安全判断由代码读取 C1/C2/risk-policy/l1-allowlist 后裁决;错误不得冒充成功。

## What Changes

- Rebase 旧 C3 执行契约:事实源从 `capabilities.yaml` 改为 `semantic-function-contract`(C1) + `scenario-state-protocol`(C2) + `state-cells.yaml` + `l1-demo-allowlist.yaml` + `risk-policy.yaml`。
- 明确输入模型:工具调用候选必须同时携带两个正交维度:
  - `action_primitive`(动作原语,如 `power_on` / `adjust_to_number` / `increase_by_exp` / `query`)
  - `value{ref,direct,offset,type}` 四件套(绝对/相对/百分比/经验值语义)
- 明确步长和执行边界:步长只来自 C2 `execution_range.step` 与 `exp_step`,不得引入独立 `step_table`。
- 新增 single-call runtime contract:运行时只接受 exactly 1 个工具调用帧,或 1 个 NoAction/Clarify 帧;多工具调用、额外文本、unknown enum、stale state、length 截断一律 reject/clarify。
- 新增 gate 链:shape/schema -> semantic -> precondition -> stale-state -> fail-closed parser repair -> DemoGuard -> execute -> readback。
- 新增 slot fan-out:工具调用帧可携带 `position` / `direction` 等槽位;执行层按 C1 slot 与 C2 cell scope fan-out,不得把「主驾/副驾/全车」写死成全部可能性。
- 保留旧 C3 的成熟设计:adopt 上游 tool-call parser 薄层、content-fallback 只产候选、两层 decode 边界、错误枚举三态、`enable_thinking=false`、五段 trace、E3 spike GO 结论。
- 吸收 home-llm runtime 蓝本:单发、三层防御解析、值归一化在 code、受限解码、KV 预热、Qwen3 采样起点;全部翻译成 Swift/MAformac 设计,不 import Python。
- 明确 F2/F3 定性:`46340f1` 已在 main 修过旧实现缺陷;本 change 只要求新 value 四件套契约下继续防退化,不是修现存 main bug。

## Capabilities

### New Capabilities
- `tool-execution`:从模型工具调用候选到 mock state 读回的执行契约,覆盖严格解码、gate 链、风险门、C2 执行范围、readback 和 trace。

### Modified Capabilities
- (无)

## Non-goals

- 不写 Swift 实现代码;本 change 仅 propose。
- 不修改 `Core/`、`contracts/`、`main` 或任何 C1/C2 事实源。
- 不自建独立 tool-call parser 替代 `mlx-swift-lm` 上游 parser;只定义内部薄层和 fail-closed fallback 候选策略。
- 不做 C4 三层路由/意图收缩/multi-intent splitter 的实现;C3 只保留 `intentConfirmed`/splitter hook。
- 不做 C5 LoRA 数据、不做 C6 bench、不做 C7 ASR/TTS。
- 不接真车、不承诺 ISO 26262/ASIL 量产功能安全;安全门仅服务内部 demo 的优雅拒识。
- 不引入 Python runtime、home-llm 数据集、home-llm 权重或模板文本。

## Success Criteria

- `openspec validate define-execution-contract --strict` 通过。
- proposal/spec/design/tasks 均明确 C1 value 四件套与 `action_primitive` 是正交维度,且步长来自 C2 `execution_range.step` / `exp_step`。
- spec 中有 single-call、gate 链、value 四件套归一、slot fan-out、DemoGuard 规则源、C2 readback、content-fallback fail-closed、trace 的 SHALL + Scenario。
- design 中有 Research Inputs 段,并把 home-llm file:line 映射为 copy/adapt/drop + Swift 落点。
- design 中明确 C1 行 `risk` 仍全空,DemoGuard 读独立 `risk-policy.yaml`,不从 C1 行读取 risk。
- tasks 拆成 apply 阶段 TDD 清单,标出 spike/verification/magnet reviewed 点。
- `git status` 证明只改 `openspec/changes/define-execution-contract/` 下的 propose artifact。

## Impact

- Apply 阶段会重写 `ToolCallFrame`、解码器、DemoGuard、DemoActionExecutor、DemoVehicleStateStore/readback、TraceLogger 的契约实现,但本 propose 不动这些文件。
- 下游 C4/C5/C6/C7 以后消费本 change 的执行帧格式、错误枚举、trace 字段和 readback 口径。
- 旧 `capabilities.yaml` 只作为历史参考,不再作为执行规则事实源。
