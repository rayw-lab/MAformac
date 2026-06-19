## 0. Apply 前置验证

- [ ] 0.1 运行 `openspec validate define-execution-contract --strict`,确认 propose artifact 仍绿。(verification)
- [ ] 0.2 运行 `make verify`,确认 C1/C2 contracts 当前事实源无漂移。(verification)
- [ ] 0.3 写一页 apply 前置 note:本 change 不改 `contracts/`,只消费 C1/C2;若需新增生成物,另开 change。

## 1. C1/C2 Contract Lookup

- [ ] 1.1 建只读 semantic contract lookup,可按 `device + action_primitive + slot` 查 C1 行与 `clarify_tag`。验收:fixture 覆盖 `ac_temperature`、`window`、`screen_brightness`、`atmosphere_lamp_brightness`。(TDD)
- [ ] 1.2 建只读 C2 state-cell lookup,可按 execution range cell 查 `execution_range.step`、`exp_step`、scope、readback template。验收:fixture 覆盖 `ac.temp_setpoint`、`window.position`、`screen.brightness`、`ambient.brightness`。(TDD)
- [ ] 1.3 建 risk-policy lookup,确认 C1 行 `risk` 不参与风险判断。验收:JSONL `risk` 全空时 forbidden rule 仍能通过 `risk-policy.yaml` 命中。(TDD)
- [ ] 1.4 建 l1-allowlist lookup,确认 L1 device/primitive 与 C2 range cell 闭合。验收:allowlist 中 ac/window primitives 均能查到 range cell。

## 2. ToolCallFrame Rebase

- [ ] 2.1 将内部工具调用帧从 `[String:String]` 升级为强类型 frame:device、action_primitive、slot、value 四件套、state_revision、candidate_source、raw payload。验收:Codable fixture 往返不丢字段。(TDD)
- [ ] 2.2 明确 NoAction/Clarify frame,并让 runtime union 只接受 exactly one frame。验收:多 frame fixture reject。
- [ ] 2.3 保留上游 parser thin adapter,不自建 parser fork。验收:代码中 parser adapter 只消费上游 tool event 或 content candidate。
- [ ] 2.4 content fallback 默认 off;开启也只产 candidate。验收:裸 JSON 普通文本默认不执行,trace 标记 fallback disabled。(TDD)

## 3. Strict Decode 与 Error Enum

- [ ] 3.1 实现错误枚举:no_tool_call / malformed / schema_invalid(unknown_tool,missing_field,type_mismatch,out_of_range,unknown_enum) / semantic_invalid / stale_state / guard_denied / readback_mismatch。验收:每类一个 fixture。(TDD)
- [ ] 3.2 面向模型输出的 enum 手写 decode,unknown 值进 error enum。验收:unknown action primitive、unknown value type、unknown slot 都不崩。
- [ ] 3.3 parser repair 只修格式,repair 后重新走 strict decode + semantic gate。验收:repair 后 schema 合法但语义非法仍 reject。
- [ ] 3.4 控制路径禁 thinking。验收:含 `<think>` 或 thinking text 的 fixture 记录 think_leak 且不执行。

## 4. Gate 链与 DemoGuard

- [ ] 4.1 实现 gate pipeline:schema -> semantic -> precondition -> stale-state -> repair fail-closed -> DemoGuard -> execute -> readback。验收:trace 中可看到每段状态。(TDD)
- [ ] 4.2 semantic gate 校验 device/action_primitive/slot/value 是否能在 C1/C2 解释。验收:不存在 primitive 或 scope 外 slot reject。
- [ ] 4.3 precondition gate 实现 AC off 时升温的代码补前置动作。验收:不让模型二次决定 next tool。
- [ ] 4.4 stale-state gate 基于 state_revision 拒绝旧帧。验收:过期 revision fixture reject。
- [ ] 4.5 DemoGuard 读取 risk-policy forbidden,支持 vehicle.speed>0 开门拒识。验收:unsafe false pass=0。
- [ ] 4.6 DemoGuard 接入 `intentConfirmed` hook,但不实现 C4 语义拒识。验收:implicit 且未确认的候选不直接执行;注释标归 C4。

## 5. Value Normalization 与 Mock Transition

- [ ] 5.1 实现 value 四件套归一:`EXP` 走 C2 `exp_step`,`SPOT` 走点值,`PERCENT` 走百分比 range,`MAX/MIN` 走 extreme。验收:空调温度、车窗开度、屏幕亮度、氛围灯亮度 fixture 全过。(TDD)
- [ ] 5.2 实现 slot fan-out:position/direction 单点、全车集合、scope 外 reject。验收:主驾车窗只写主驾;全车 fan-out 写 C2 支持 scope。
- [ ] 5.3 实现多 cell transition,不得只取第一个 scalar。验收:`power_on + temp_setpoint` 同轮写入时 power 和 temp 均读回正确。
- [ ] 5.4 实现 allowed values / enum guard。验收:ambient color 非 8 色、power unknown 均 reject。

## 6. Readback 与 Trace

- [ ] 6.1 readback 只读 C2 mock state actual value,播报不使用模型文本。验收:请求值与实际值不一致时返回 readback_mismatch。
- [ ] 6.2 已处于目标状态时据实播报。验收:空调已 off 再关,播报「已经关闭」类状态,不冒充新执行成功。
- [ ] 6.3 TraceLogger 五段落地:decode/plan/guard/execute/readback,并记录 candidate_source/toolCalls.count/stopReason/repair_used/guard_reason/readback_result。验收:成功与拒绝 fixture 均有完整 trace。
- [ ] 6.4 pending/failed/unknown 不播「已完成」。验收:错误态 TTS fixture 不含完成承诺。

## 7. home-llm Adopt Spike

- [ ] 7.1 非流式 parser 采用 Swift 等效策略,对照 home-llm `_async_parse_completion`。验收:fenced JSON + thinking strip fixture 通过。(spike + TDD)
- [ ] 7.2 受限解码方案 spike:MLX JSON schema / outlines-swift / xgrammar 至少二选一实测,结论写入 docs。验收:格式合法率与延迟记录。(spike)
- [ ] 7.3 Qwen3 sampling 起点用 home-llm `temp=0.6/top_k=20/top_p=0.95` 做对照,再与低温确定性配置比较。验收:触发率、格式合法率、latency 表格。
- [ ] 7.4 KV prewarm 仅留 runtime hook 或实现最小 app-start prewarm。验收:明确归 C3 或 C7 的边界说明。

## 8. Verification

- [ ] 8.1 单测覆盖 no_tool_call / malformed / schema_invalid / semantic_invalid / stale_state / guard_denied / readback_mismatch。
- [ ] 8.2 E3 regression fixture 复跑,确认 content fallback 默认 off 后 negative 不新增执行。
- [ ] 8.3 `swift test` 通过;失败时保留 stdout 和 failure receipt。(verification)
- [ ] 8.4 `openspec validate define-execution-contract --strict` 通过。
- [ ] 8.5 `git diff -- Core contracts` 为空,确认 apply 前 propose 未触碰禁区;apply 阶段不得改 contracts,除非另开 change。
