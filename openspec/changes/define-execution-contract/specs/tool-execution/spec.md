## ADDED Requirements

### Requirement: 模型输出只能作为不可信候选
系统 SHALL 将模型输出的工具调用视为候选,在完成严格解码、gate 链、DemoGuard、mock 执行和 C2 readback 之前,SHALL NOT 视为已执行动作。模型 SHALL NOT 直接写入 mock state。

#### Scenario: 候选未经 gate 不执行
- **WHEN** 模型产出一个工具调用候选
- **THEN** 系统先执行严格解码与 gate 链
- **AND** 任一 gate 失败时不进入 mock state 写入

#### Scenario: 错误不冒充成功
- **WHEN** 候选状态为 pending、failed、unknown 或 readback mismatch
- **THEN** 系统 SHALL NOT 播报「已完成」

### Requirement: 运行时只接受单发工具调用或非动作帧
控制路径 SHALL 只接受 exactly 1 个工具调用帧,或 exactly 1 个 NoAction/Clarify 帧。多工具调用、额外 assistant 文本、缺必填、unknown enum、stale state revision、finish reason 为 length 时,系统 SHALL reject 或 clarify,SHALL NOT repair-to-action。

#### Scenario: 多工具调用被拒绝
- **WHEN** 一轮模型输出包含两个或更多工具调用
- **THEN** 系统拒绝该轮动作并转澄清或错误态
- **AND** 不选择其中任意一个工具调用执行

#### Scenario: length 截断不修成动作
- **WHEN** 模型输出因长度截断导致候选不完整
- **THEN** 系统标记 decode failed
- **AND** 不用 parser repair 生成可执行动作

#### Scenario: stale state revision 被拒绝
- **GIVEN** 工具调用帧携带的 state revision 早于当前 mock state revision
- **WHEN** 系统进入 stale-state gate
- **THEN** 系统拒绝执行并要求重新规划或澄清

### Requirement: 工具调用帧必须表达 action primitive 与 value 四件套两维
工具调用帧 SHALL 同时表达 `device × action_primitive × slot` 三元身份与 `value{ref,direct,offset,type}` 四件套。`action_primitive` 与 value 四件套 SHALL 被视为正交维度,不得互相替代或混写。

#### Scenario: 经验值调节保留两维
- **WHEN** 用户语义为「调高一点」
- **THEN** 工具调用帧包含 `action_primitive=increase_by_exp`
- **AND** value 四件套表达相对经验值,如 `ref=CUR`、`direct=+`、`offset=LITTLE`、`type=EXP`

#### Scenario: 绝对点值保留两维
- **WHEN** 用户语义为「调到 24 度」
- **THEN** 工具调用帧包含对应绝对点值动作原语
- **AND** value 四件套表达从零参考的点值,如 `ref=ZERO`、`offset=<具体值>`、`type=SPOT`

### Requirement: 执行范围与步长只来自 C2
执行层 SHALL 从 C2 场景端态协议读取 execution range、step 与 exp step。C1 的语义 range SHALL NOT 被用作执行边界;系统 SHALL NOT 引入独立 `step_table` 权威。

#### Scenario: 经验步长按 C2 exp step 归一
- **WHEN** 候选 value 为 `type=EXP` 且 offset 为经验 token
- **THEN** 系统按 C2 对应 cell 的 `exp_step` 计算机器值
- **AND** 不从 C1 语义 range 或 hard-coded step table 推导步长

#### Scenario: 超出 C2 execution range 被 gate 处理
- **WHEN** 候选归一后的机器值超出 C2 对应 cell 的 execution range
- **THEN** 系统按契约拒绝、钳制或澄清
- **AND** 不写入非法 mock state

### Requirement: slot fan-out 必须保留 position 与 direction
工具调用帧 SHALL 支持 C1 slot 中的 `position` 与 `direction` 等槽位。执行层 SHALL 将槽位解析为 C2 cell scope 内的目标集合;未解析或超出 scope 时 SHALL clarify 或 reject。

#### Scenario: 单座位窗口动作落到指定 position
- **WHEN** 用户请求「打开主驾车窗」
- **THEN** 工具调用帧保留 `position=主驾`
- **AND** 执行层只更新主驾对应 mock cell,不误更新全车

#### Scenario: 全车动作 fan-out
- **WHEN** 用户请求「把全车车窗打开到 30%」
- **THEN** 执行层将 `position=全车` fan-out 到 C2 scope 中支持的窗口 cell
- **AND** 每个被写入 cell 都经过同一 execution range gate

### Requirement: gate 链必须 fail closed
系统 SHALL 按 schema、semantic、precondition、stale-state、parser-repair、DemoGuard、execute、readback 的顺序处理候选。parser repair 只允许修格式;repair 后仍 SHALL 通过 semantic gate 与 DemoGuard。repair rate 超过阈值时 SHALL 标记模型失败,不得掩盖为成功率。

#### Scenario: repair 后仍需过 semantic gate
- **WHEN** content fallback 或 parser repair 产出候选
- **THEN** 候选必须重新进入 schema 与 semantic gate
- **AND** 未通过时不执行

#### Scenario: 前置条件由代码补齐
- **GIVEN** 当前空调 power 为 off
- **WHEN** 用户请求「温度调高一点」
- **THEN** precondition gate SHALL 由代码规划打开空调再设置温度的确定性动作
- **AND** 模型 SHALL NOT 自由决定下一步工具循环

### Requirement: DemoGuard 规则源必须来自 C1/C2 衍生契约
DemoGuard SHALL 读取独立 `risk-policy`、L1 allowlist、C1 `clarify_tag`、C2 execution range 与当前 mock state。C1 行级 `risk` 为空时,系统 SHALL NOT 从 C1 行读取风险等级。

#### Scenario: 行驶中开门被拒识
- **GIVEN** mock state 中 vehicle speed 大于 0
- **WHEN** 候选动作命中行驶中开门类 forbidden rule
- **THEN** DemoGuard 返回拒识并给出解释
- **AND** 不写入车门 mock state

#### Scenario: implicit 候选未确认不得越过语义门
- **WHEN** C1 `clarify_tag` 表示候选需要慢路或确认但 C4 尚未确认
- **THEN** DemoGuard 或 semantic gate SHALL 拒绝直接执行
- **AND** 仅保留 hook 给 C4 接入确认信号

### Requirement: 控制路径禁用 thinking
控制路径 SHALL 关闭模型 thinking。若输出含 thinking 标记或思考文本污染工具调用,系统 SHALL 在 trace 中记录 think leak,并判失败或降级澄清。

#### Scenario: thinking 泄漏不进入执行
- **WHEN** 模型输出包含 thinking 标记或思考文本
- **THEN** 系统记录 think leak
- **AND** 该轮不进入 mock state 写入

### Requirement: content fallback 默认关闭且只产候选
裸 JSON 或 fenced JSON content fallback SHALL 默认为关闭。开启时也只能产出候选,候选 SHALL 通过与 tool-call event 相同的严格 decode、semantic gate、DemoGuard 与 readback,不得绕过任何 gate。

#### Scenario: fallback 关闭时裸 JSON 不执行
- **WHEN** 模型在普通文本中输出裸 JSON 工具调用
- **THEN** 系统不执行该 JSON
- **AND** trace 标记为 content fallback disabled 或 decode failed

#### Scenario: fallback 开启时负例仍被 guard 拦截
- **WHEN** fallback 从普通文本恢复出 schema 合法但语义应拒识的候选
- **THEN** semantic gate 或 DemoGuard SHALL 拒绝执行
- **AND** unsafe false pass 仍为 0

### Requirement: mock 执行必须按 value 四件套全字段归一落地
执行层 SHALL 按 `action_primitive`、value 四件套、slot、当前 mock state 与 C2 execution range 计算目标 mock transition。执行层 SHALL NOT 只取第一个 scalar 参数作为目标值。

#### Scenario: power 与温度同时落地
- **WHEN** 候选表达打开空调并设置温度
- **THEN** 执行层分别更新 power 与 temp setpoint 相关 mock cell
- **AND** readback 反映实际写入的完整状态

#### Scenario: 百分比与经验值归一
- **WHEN** 候选表达「车窗开大一点」或「打开到 30%」
- **THEN** 执行层分别按 C2 `exp_step` 或百分比 range 归一成机器值
- **AND** 不丢失 `ref`、`direct`、`offset`、`type` 中任一字段

### Requirement: readback 以 C2 mock state 为唯一成功判据
动作执行后 SHALL 读取 C2 对应 mock state cell。播报 SHALL 基于 actual mock state,而非请求参数或模型文本。readback mismatch SHALL 失败。

#### Scenario: 已关闭状态据实播报
- **GIVEN** 空调 power 已为 off
- **WHEN** 用户请求关闭空调
- **THEN** 系统读回 power=off
- **AND** 播报已经是关闭状态,不冒充新执行成功

#### Scenario: 写入后读实际值
- **WHEN** 候选请求设置某 cell 到目标值
- **THEN** 系统写入后读取 actual value
- **AND** 只有 actual value 与契约预期一致时才播报完成

### Requirement: 模型只看代码派生状态特征
慢路模型 SHALL 只接收代码派生的状态特征,如 comfort state、active zone、available single actions、last action、state revision。模型 SHALL NOT 对全量 mock state 自行推理执行可行性。

#### Scenario: 状态特征替代全量 state
- **WHEN** C3 构建慢路执行上下文
- **THEN** 上下文只暴露代码派生的有限状态特征
- **AND** 语义可行性仍由 semantic gate 和 DemoGuard 裁决

### Requirement: 工具调用全程留痕五段
系统 SHALL 为每轮候选记录 decode、plan、guard、execute、readback 五段 trace,并记录 tool call count、stop reason、candidate source、repair used、guard reason、readback result。

#### Scenario: 成功动作 trace 可追溯
- **WHEN** 一个动作成功执行并读回
- **THEN** trace 包含 decode、plan、guard、execute、readback 五段
- **AND** 每段包含该段的输入、输出或拒绝原因

#### Scenario: 拒绝动作 trace 可追溯
- **WHEN** 候选被任一 gate 拒绝
- **THEN** trace 记录拒绝 gate 与原因
- **AND** execute/readback 不伪造成功段

### Requirement: 工具参数接受多种 JSON 形态但不扩大安全边界
系统 SHALL 能识别对象、字符串化 JSON、数组、标量等参数形态,并归一为内部 JSON value。参数形态归一 SHALL NOT 绕过 required、type、enum、range、slot scope 或 risk gate。

#### Scenario: 字符串化 JSON 参数被归一
- **WHEN** arguments 是字符串化 JSON 对象
- **THEN** 系统解析并归一为内部 JSON value
- **AND** 继续执行 required、type、enum、range 校验

#### Scenario: 数组或标量不被静默丢弃
- **WHEN** 模型输出数组或标量形态参数
- **THEN** 系统要么归一并校验,要么明确 decode failed
- **AND** 不静默当作空参数执行
