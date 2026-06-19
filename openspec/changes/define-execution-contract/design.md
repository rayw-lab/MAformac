## Context

本 change 是 C3 执行契约层的 propose rebase。C1/C2 已 archive 为 OpenSpec 事实源:

- `openspec/specs/semantic-function-contract/spec.md`:C1,源行级全集语义契约。当前仓内 JSONL 为 3990 行;实测 `risk` 全空;`clarify_tag` 为 `implicit`/`explicit`;高频 `action_primitive` 包含 `set_mode`、`power_on`、`power_off`、`adjust_to_number`、`by_percent`、`increase_by_exp`、`decrease_by_exp`、`adjust_to_gear` 等。
- `openspec/specs/scenario-state-protocol/spec.md`:C2,场景端态与 execution range 权威。`contracts/state-cells.yaml` 拥有 `execution_range.step` 与 `exp_step`。
- `openspec/specs/vehicle-capabilities/spec.md`:旧扁平能力墓碑指针,不得再作为执行事实源。

旧 parked C3 的好部分可以复用:adopt `mlx-swift-lm` 上游 parser 的薄层、裸 JSON content-fallback 只产候选、两层 decode 边界、错误枚举三态、`enable_thinking=false`、TraceLogger 五段、E3 spike GO 结论。必须 rebase 的部分是:旧 `arguments` 泛型 KV、旧 `capabilities.yaml.demo_guard` 规则源、旧 readback cell、无 slot fan-out、以及 F2/F3 整改前快照。

当前 Swift 骨架只作为 apply 阶段 rebase 对象,本 propose 不修改。实读现状: `ToolCallFrame.arguments` 仍是 `[String:String]`;`DemoFastPathGuard` 仍是单条 fast-path 占位;`DemoActionExecutor` 只接受 `set_vehicle_control` + `state_key/target_state`;`desiredMockValue` 旧 bug 已零命中。C3 apply 会重写这些,但本 change 只定义契约。

## Research Inputs

| source_doc | adopted_rules | deferred_gates |
|---|---|---|
| `docs/research/2026-06-19-home-llm-teardown.md` | single-call runtime、parser repair 候选、normalize in code、constrained decode、prewarm on state change、qwen3 sampling 起点 | 流式提取、ReAct 多步 |
| `docs/srd-three-layer-intent-routing.md §12.1` | single-call runtime contract、gate 链、模型只看代码派生 state features | C4 multi-intent deterministic splitter、C7 voice/runtime 预热落点 |
| `docs/handoffs/2026-06-19-change3-gptpro-audit-closeout.md` | F2/F3 是整改前快照;新契约下保留全字段落地与 allowedValues guard | F1 语义拒识归 C4/C5, C3 只留 hook |
| `contracts/state-cells.yaml` | execution range、step、exp_step、readback cell group | 非 L1 泛覆盖的 generic range policy |

## Goals / Non-Goals

**Goals:**
- 定义模型候选到 mock state readback 的可信执行链。
- 明确 C1 `action_primitive` + value 四件套 + slot 与 C2 execution range 的映射边界。
- 明确 single-call、gate 链、fail-closed fallback、DemoGuard 规则源、readback 成功判据和 trace。
- 把 home-llm 的 runtime 工程模式翻译成 Swift 设计约束。
- 给 apply 阶段留下可 TDD 的任务清单。

**Non-Goals:**
- 不实现 Swift 代码。
- 不修改 `Core/`、`contracts/`、`main`。
- 不写 C4 router、C5 LoRA、C6 bench、C7 voice。
- 不接真车、不承诺量产功能安全。
- 不 import Python、不搬 home-llm 数据/模板/权重。

## Decisions

### E1:事实源改为 C1/C2,旧 capabilities 仅历史参考

C3 执行契约 SHALL 读取 C1/C2 衍生产物:

- 语义身份:C1 JSONL 的 `device`、`action_primitive`、`slot`、`slot_keys`、`clarify_tag`。
- 语义值:C1 JSONL 的 value 四件套。
- 执行边界:C2 `state-cells.yaml` 的 `execution_range.step` 与 `exp_step`。
- 精做范围:`l1-demo-allowlist.yaml`。
- 风险策略:`risk-policy.yaml`。

不再读取旧 `capabilities.yaml.demo_guard` 作为事实源。`vehicle-capabilities` spec 已是墓碑指针。

### E2:value 四件套与 action primitive 是正交维度

每条候选必须同时保留:

| 维度 | 角色 | 例 |
|---|---|---|
| `action_primitive` | 动作语义 | `increase_by_exp` / `adjust_to_number` / `power_on` |
| `value{ref,direct,offset,type}` | 数值语义 | `ref=CUR,direct=+,offset=LITTLE,type=EXP` |
| `slot` | 作用对象与位置 | `direction=主驾` / `position=左后` |

这三者不得混为一个 `arguments` 字典里的任意 KV。执行层按 action primitive 选择归一化策略,按 value 四件套计算目标值,按 slot 选择 C2 cell。

### E3:步长只在 C2,无 step_table

C1 只表达语义,不拥有执行边界。经验值或百分比归一必须读取 C2:

- 机器步进:`execution_range.step`
- 经验 offset token 映射:`exp_step`
- 极值或挡位映射:对应 cell 的 `exp_step.gear` / `extreme` 等 C2 决策

禁止新增第三份 `step_table`。这样可以防止协议语义 range、demo execution range、运行时 hard-code 三份漂移。

### E4:single-call runtime contract,不做模型 agent loop

运行时只接受:

1. exactly 1 个 ToolCallFrame;或
2. exactly 1 个 NoAction/Clarify frame。

多 tool call、额外文本、unknown enum、缺必填、stale revision、finish reason length 都 fail closed。C4 可在进入 C3 前做 deterministic splitter,但 C3 不让模型自由决定 next tool。home-llm `conversation.py:156-220` 用 `max_tool_call_iterations=0` 支撑这个设计;SRD §12.1 也把 single-call 作为 C3 tiger gate。

### E5:parser 仍 adopt 上游,content fallback 只产候选

保留旧 E1/E1a:

- 首选消费 `mlx-swift-lm` 上游 tool-call event。
- 内部 `ToolCallFrame` 是薄校验层,不是 parser fork。
- 裸 JSON/fenced JSON content fallback 默认关闭;开启时只产 `ToolCallCandidate`,候选必须过同一 strict decode + semantic gate + DemoGuard。

home-llm `utils.py:495-579` 的防御解析可借鉴,但只用于候选修复,不重建 parser。`utils.py:591-599` 的 repair 思想对应 Swift 的 parser-repair 候选;repair 后仍要过 semantic gate。

### E6:gate 链顺序固定

执行链:

```
candidate
  -> schema gate(字段/类型/enum/range shape)
  -> semantic gate(device/action_primitive/slot/value 是否在 C1/C2 可解释)
  -> precondition gate(如 AC off 时升温由代码补 power_on+set_temp)
  -> stale-state gate(state_revision)
  -> parser-repair fail-closed gate
  -> DemoGuard(risk/l1/clarify/current_state)
  -> execute(mock transition)
  -> readback(C2 actual state)
  -> trace(decode/plan/guard/execute/readback)
```

precondition 是代码确定性规划,不是模型二次循环。repair 只修格式,不修语义。

### E7:DemoGuard 规则源

DemoGuard 读取:

- `risk-policy.yaml`:R0/R1/R2 与 forbidden rules。
- `l1-demo-allowlist.yaml`:L1 精做设备、primitive、required state cell groups、required followup transitions。
- C1 `clarify_tag`:`explicit` 可快路候选;`implicit` 默认需要 C4 慢路确认或 hook 信号。
- C2 state cells:execution range、scope、current mock state、safety cells。

C1 行级 `risk` 当前全空,且 verify 仍约束 `risk == ""`;因此 DemoGuard 不得从 C1 行读取 risk。risk 后续若耦合进 C1,必须另开 change 同步 gen/verify。

### E8:slot fan-out 不写死小集合

C1 里 position/direction 范围远大于 demo 精做五个例子。C3 contract 只要求:

- 工具调用帧保留原始 slot。
- C2 scope 决定可执行 fan-out。
- scope 外或未解析 slot 走 clarify/reject。
- `全车` 这类集合值由代码 fan-out 到 C2 支持的 cell 列表,每个 cell 独立过 range gate。

### E9:值归一化在 code

home-llm `utils.py:565-571` 把 brightness 0-1 归一到 0-255、RGB 字符串转数组;这与 MAformac value 四件套同构。C3 的执行层负责把:

- `EXP` + `LITTLE/MORE/...` -> C2 `exp_step`
- `SPOT` -> C2 execution range 内点值
- `PERCENT` -> 百分比 cell
- `MAX/MIN` -> C2 extreme

转为 mock transition。模型只产语义和近似参数,不产最终机器值。F2 的本质防线就是不得只取第一个 scalar;要按 action primitive + value 四件套全字段落地。

### E10:readback 成功判据只看 C2 actual state

执行后播报必须来自 C2 mock state actual value,不是模型输出文案或请求参数。`pending/failed/unknown` 和 readback mismatch 不得播「已完成」。旧已关空调仍回 OK 的真实反例,在 C3 里表现为先读 power state 再据实播报。

### E11:受限解码和预热只定接口,落点留 open question

home-llm `backends/llamacpp.py:219-230` 用 GBNF;`output.gbnf` 强制 NL + fenced JSON;`llamacpp.py:366-448` 用 KV cache 预热;`const.py:318-322` 给 qwen3 sampling 起点。C3 设计吸收它们:

- 受限解码是格式保险,但不替代 semantic gate。
- KV 预热是延迟优化,但可能归 C7 voice/runtime。
- 采样值作为 spike 起点,不写死为最终 runtime 参数。

## home-llm Adopt Mapping

| home-llm source | 模式 | C3 Swift 落点 | 动作 | 原因 |
|---|---|---|---|---|
| `conversation.py:156-220` | `max_tool_call_iterations=0` 单发;无模型多步 loop | single-call runtime contract | adapt | 与 SRD「模型单次只产单跳 ToolCallFrame」一致 |
| `utils.py:495-579` | 多格式 + repair + 双 schema 防御解析 | ToolCall candidate decode 层 | adapt | 只修候选格式,不绕过 gate |
| `utils.py:565-571` | 值归一化在 code | value 四件套 -> C2 机器值 | adapt | 根治 F2 类「只落第一个 scalar」 |
| `entity.py:564-592` | mock/entity state 转人类可读单位 | readback 与 prompt state features | adapt + boundary | readback 属 C3;prompt 构建可能归 C4 |
| `entity.py:382-433` | 非流式 completion 解析 tool block + strip thinking | demo 非流式 decode 路径 | adapt | 首版 demo 不必做流式复杂解析 |
| `llamacpp.py:219-230` | GBNF 挂载 | 受限解码接口 | adapt | MLX 等效方案待 spike,不 import llama.cpp |
| `llamacpp.py:366-448` | prompt KV cache 预热 + state change refresh | runtime prewarm hook | adapt + boundary | 可能归 C7/runtime,本 change 留接口 |
| `const.py:318-322` | qwen3 temp/top_k/top_p 起点 | E3/LoRA spike sampling baseline | copy values as starting point | 仅作起点,后续实测调 |
| `output.gbnf:1-29` | NL + fenced JSON grammar | 中文回复 + 中控块格式设计 | adapt | 只保格式,语义仍走 gate |
| HA services/entities/config flow | Home Assistant 特有体系 | 无 | drop | 与 MAformac cabin mock 无关 |

## Pre-Mortem

### Tigers

- **T1:正交维度混淆**。验证:JSONL 行同时存在 `action_primitive`、`slot`、`value`,且 value 多数为空但 semantic slots 中有四件套;旧 C3 用泛型 `arguments`。Mitigation:E2 + spec value requirement。
- **T2:三份 range 权威漂移**。验证:C1 spec 明说具体步长不写死;C2 state-cells 拥有 execution range;CONTEXT 明确 semantic range != execution range。Mitigation:E3。
- **T3:content fallback 放大负例**。验证:旧 E3 spike report 已记录 negative bare JSON risk;dispatch 要求默认关。Mitigation:E5 + spec fallback requirement。
- **T4:DemoGuard 读错 risk 来源**。验证:`risk-policy.yaml` 头部注明 C1 risk 全空;JSONL 统计 `risk [('',3990)]`。Mitigation:E7。
- **T5:home-llm 被误 import / 误搬数据**。验证:CLAUDE §6 和 dispatch §0 均要求 Python 库零进 iOS、只 adopt 方法。Mitigation:home-llm mapping 明确 adapt/drop。

### Paper Tigers

- **F2/F3 仍是 main 待修 bug**:已排除。`rg desiredMockValue Core` 零命中,当前 `DemoActionExecutor.swift` 已是 `state_key/target_state` 简化骨架。C3 只在新契约下防退化。
- **旧 `vehicle-capabilities` 还是事实源**:已排除。当前 spec 是墓碑指针,下游 MUST 引用 C1/C2。

### Elephant

C3 契约会把运行时变复杂,但这是把复杂性从模型自由发挥迁回代码。真正风险是 apply 时为了快而只做 `[String:String]` 兼容层,导致 C1/C2 的 SSOT 没真正进入执行链。tasks 必须从 TDD fixture 开始,先让 value 四件套、slot fan-out、risk source、readback mismatch 失败,再实现。

## Risks / Trade-offs

- **受限解码保格式不保语义** -> semantic gate 与 DemoGuard 仍是必经路径。
- **single-call 会拒绝模型产出的多 tool_call** -> C4 负责 splitter;C3 保守拒绝换稳定性。
- **C1 `clarify_tag` 当前大多 implicit** -> C3 不擅自放行 implicit;需 C4 提供 `intentConfirmed` hook。
- **C2 只精做部分 scope** -> C3 对 scope 外 slot 走 L2 generic/clarify,不假装可写全量设备。
- **KV 预热和 GBNF MLX 等效方案未定** -> 本 change 只定义接口和 spike 任务,不提前锁库。

## Migration Plan

1. Apply 阶段先把 `ToolCallFrame` 升级为 C1/C2 对齐的 frame:device、action primitive、slot、value、state revision、candidate source、raw arguments。
2. 建 C1/C2 contract loader 或 generated lookup,只读已提交 contracts。
3. 写 strict decoder 与 error enum,让 malformed / no call / schema invalid / semantic invalid 分开。
4. 实现 gate 链与 DemoGuard sources。
5. 实现 value normalization 与 mock transition writer,以 C2 readback 为成功判据。
6. 接入 trace 五段与 E3 regression fixture。
7. 回滚策略:feature branch revert 本 change apply commits;contracts 不被本 change 修改。

## Open Questions

- Prompt 构建侧的单位归一化与 state feature 生成归 C3 还是 C4 routing?本 design 倾向:C3 只提供 readback/feature helper,C4 负责 prompt 选择。
- KV prewarm 属 C3 runtime contract 还是 C7 voice/runtime?本 design 只留 hook,不锁实现位置。
- MLX 上的 GBNF 等效采用 outlines-swift、xgrammar 还是仅 JSON schema/decoder?需要 spike。
- value 四件套 mock transition 的 Swift 数据结构是强类型 `ContractValue` 还是 JSONValue + typed adapter?apply 前由 Codex 提案并 TDD。
- content fallback 的配置点放 LLM backend、decoder 还是 demo settings?默认必须 off。
