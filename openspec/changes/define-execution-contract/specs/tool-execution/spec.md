## ADDED Requirements

### Requirement: 模型输出视为不可信候选
系统 SHALL 将模型产生的工具调用视为**候选**;在经解析、严格校验、安全门、mock 执行与读回之前,SHALL NOT 视为已执行动作。

#### Scenario: 候选未经校验不执行
- **WHEN** 模型产出一个工具调用候选
- **THEN** 系统先解析 + 严格校验,未通过则不进入执行

### Requirement: 解码错误三态可区分
系统 SHALL 区分「无工具调用 / 格式错误 / 契约不符」三类并据此分流;契约不符 SHALL 进一步区分未知工具 / 缺必填 / 类型错 / 越界。

#### Scenario: 格式错误转澄清而非静默
- **GIVEN** 模型产出格式错误的工具调用
- **WHEN** 系统解码
- **THEN** 标记 decode 失败并转澄清(可重试 ≤1 次),**不静默当作「无工具调用」**

#### Scenario: 契约不符被拒
- **WHEN** 工具调用含未知工具 / 缺必填参数 / 类型错 / 参数越出能力声明的范围
- **THEN** 系统拒绝执行,不修正不猜测,转澄清或拒识

### Requirement: 控制路径禁用思考模式
系统在工具调用控制路径 SHALL 禁用模型思考模式;若输出夹带思考内容,SHALL 记录于 trace 并判失败或降级澄清,SHALL NOT 让思考内容污染工具解析。

#### Scenario: 思考内容泄漏被捕获
- **WHEN** 模型输出夹带思考标记
- **THEN** trace 记录思考泄漏,该轮判失败 / 降级澄清,不进入执行

### Requirement: 安全门为代码且危险动作不误执行
系统 SHALL 以代码门(非 prompt)对每个候选检查未知工具 / 范围枚举 / 可写性 / 风险等级 / 确认策略 / 互斥 / 前置条件;危险动作误执行数 SHALL 等于 0;模型 SHALL NOT 直接执行动作。

#### Scenario: 越界被门拒
- **WHEN** 候选参数越出能力声明的范围
- **THEN** 代码门拒绝,不进入执行

### Requirement: 执行后读回才算成功
系统 SHALL 在 mock 执行后读回实际状态;readback 与实际状态不一致数 SHALL 等于 0;`pending / failed / unknown` SHALL NOT 播报「已完成」。

#### Scenario: 读回一致才据实播报
- **WHEN** 一个动作执行
- **THEN** 系统读回实际状态并据此播报(非请求值)

### Requirement: 工具调用全程留痕五段
系统 SHALL 记录每个工具调用的 decode / plan / guard / execute / readback 五段轨迹。

#### Scenario: 五段可追溯
- **WHEN** 一个工具调用走完链路
- **THEN** trace 含 decode / plan / guard / execute / readback 五段

### Requirement: 工具参数接受多种 JSON 形态
系统解析工具参数 SHALL 接受对象 / 字符串化 JSON / 数组 / 标量,不因参数形态而丢弃整个调用。

#### Scenario: 字符串化数组参数不被丢弃
- **WHEN** 工具参数是字符串化的数组或标量
- **THEN** 系统正确归一,不静默丢弃整个调用
