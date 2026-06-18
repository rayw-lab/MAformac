# demo-experience Specification

## Purpose
TBD - created by archiving change define-demo-mvp-contract. Update Purpose after archive.
## Requirements
### Requirement: 离线可演
系统 SHALL 在无网络(飞行模式)下完成全部 Phase1 车控演示路径,不依赖任何云服务或联网调用。

#### Scenario: 断网执行车控指令
- **GIVEN** 设备处于飞行模式(无网络)
- **WHEN** 演示者发出车控指令(语音或文本)
- **THEN** 系统完成意图理解、执行、UI 状态变化与 TTS 播报,全程无网络依赖

### Requirement: 车控为 mock 且状态自包含
系统 SHALL 以本地 mock 状态表达车控结果(UI 卡片亮暗 + TTS 模拟),不连接、不依赖任何外部车辆系统(CAN / ECU / 真车)。

#### Scenario: mock 状态变化可见
- **WHEN** 一条车控动作被执行
- **THEN** 对应 UI 卡片状态发生肉眼可见的变化,且变化先于 TTS 播报

### Requirement: 错误不冒充成功
系统 SHALL 在动作执行后读回实际 mock 状态再播报;当动作处于 pending / failed / unknown 状态时,SHALL NOT 播报「已完成」。

#### Scenario: 成功动作读回真实状态
- **WHEN** 一条车控动作执行成功
- **THEN** 系统读回该动作的实际 mock 状态并据此播报(readback 与实际状态一致)

#### Scenario: 失败动作不冒充成功
- **GIVEN** 一条动作因安全门拦截或前置条件不满足而未执行
- **WHEN** 系统播报结果
- **THEN** 系统播报实际状态(未完成 / 无法满足 / 替代建议),不得播报「已完成」

### Requirement: 5 幕演示路径 must-pass
系统 SHALL 支持固定演示集(15–25 条精选指令,覆盖 5 幕:① 痛点钩子 / ② 基础控制 / ③ 懂人话[含模糊意图] / ④ 断网高潮 / ⑤ 场景炫[含多模指代 + 多意图])100% 通过。

#### Scenario: 明确指令直接执行
- **WHEN** 演示者说出明确车控指令(如「打开空调」)
- **THEN** 系统经规则快路径直接执行并读回状态

#### Scenario: 模糊意图经推理执行
- **WHEN** 演示者说出模糊感受(如「我有点冷」)
- **THEN** 系统推理出可执行车控动作(如升温 + 座椅加热)并执行、读回

### Requirement: 端到端延迟分路径
快路径(明确指令或单工具调用)端到端 SHALL ≤ 800ms;慢路径(模糊意图或多意图)SHALL ≤ 2500ms。计时从用户松开录音按钮到 TTS 首响 + UI 状态变化,不含说话时长。

#### Scenario: 快路径延迟达标
- **WHEN** 演示者发出明确指令并松开按钮
- **THEN** 系统在 800ms 内完成 UI 状态变化与 TTS 首响

#### Scenario: 慢路径延迟达标
- **WHEN** 演示者发出模糊或多意图指令并松开按钮
- **THEN** 系统在 2500ms 内完成 UI 状态变化与 TTS 首响

### Requirement: 安全门控为代码且危险动作不误执行
系统 SHALL 以代码(非 prompt)拦截未知工具、越界参数、非法枚举、不可写字段与危险等级动作;危险动作误执行数(Unsafe false pass)SHALL 等于 0;模型 SHALL NOT 直接执行动作,仅产候选。

#### Scenario: 越界参数被拦截
- **WHEN** 解析出的动作参数超出能力声明的范围(具体数值由能力声明提供)
- **THEN** 系统拒绝执行,不修正不猜测,转澄清或拒识

#### Scenario: 高风险动作需确认
- **GIVEN** 一条被标记为高风险的动作
- **WHEN** 系统准备执行
- **THEN** 系统按确认策略处理,未确认不执行

### Requirement: 纯观众演示模式与话术兜底
系统 SHALL 支持演示者单人控场(push-to-talk);当某指令未响应或无兜底时,系统 SHALL NOT 崩溃,允许演示者以话术圆场。

#### Scenario: 边缘指令不崩溃
- **WHEN** 演示者或客户发出超出演示集的指令
- **THEN** 系统优雅降级(澄清 / 无法满足提示),不崩溃、不冒充成功

### Requirement: 二期能力占位不假装可用
系统 SHALL 将二期 agent(导航 / 音乐 / 外卖)显示为不可用(coming soon),不进入真实路由,且文案 SHALL NOT 声称「已支持 MCP」或「已支持导航 / 音乐」。

#### Scenario: 二期 agent 占位不可点
- **WHEN** 演示界面展示 agent dock
- **THEN** 二期 agent 显示为 coming soon / 不可点,选中不触发任何真实调用

