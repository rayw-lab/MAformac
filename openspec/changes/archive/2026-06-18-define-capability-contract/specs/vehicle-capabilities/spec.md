## ADDED Requirements

### Requirement: 能力定义有唯一权威源
系统 SHALL 以唯一权威源定义所有车控能力;tool schema / UI 卡片数据 / eval fixture / 训练数据 / trace schema 等 SHALL 全部从该权威源派生,不存在第二处人工维护的能力定义。

#### Scenario: 派生物与权威源一致
- **WHEN** 生成 tool schema 或 UI 卡片数据
- **THEN** 其内容与权威源一致,无第二处人工维护源

### Requirement: 每条车控能力声明口语别名
每条车控能力 SHALL 声明中文别名(口语变体);归一化层 SHALL 据此将口语说法回收到规范能力。

#### Scenario: 别名归一
- **WHEN** 用户说出能力的口语变体(如「散热座椅」「空调座椅」)
- **THEN** 系统归一到规范能力(座椅通风)

### Requirement: 每条能力声明 mock 执行与 readback
每条车控能力 SHALL 声明 mock 执行行为(改哪个状态)与 readback 规则;执行后系统 SHALL 读回实际 mock 状态再播报。

#### Scenario: 执行改状态并读回
- **WHEN** 一条能力被执行
- **THEN** 对应状态更新,系统读回该值用于播报

### Requirement: 危险或带范围能力声明 demo_guard
带数值范围、枚举或风险的能力 SHALL 声明 demo_guard(风险等级 / 确认策略 / 范围 / 前置条件);超出该能力声明范围的值 SHALL 被拒绝。

#### Scenario: 越界被 guard 拒绝
- **WHEN** 能力收到超出其声明范围的参数
- **THEN** demo_guard 拒绝执行,不修正不猜测,转澄清或拒识

### Requirement: MVP 车控能力集覆盖 5 幕演示
系统 SHALL 提供覆盖 5 幕演示的 MVP 车控能力集:空调(开关 + 温度 + 升降温)/ 座椅加热 / 座椅通风 / 车窗百分比 / 氛围灯 / 屏幕亮度 / 风量 / 舒适状态查询。降噪由车机底层(ECNR)自动承担,不属车控能力集。

#### Scenario: 5 幕能力可达
- **WHEN** 演示走 5 幕话术(基础控制 / 我有点冷 / 我头疼 / 断网 / 场景炫)
- **THEN** 所涉车控能力(空调 / 座椅加热 / 屏幕亮度 / 氛围灯 / 车窗等)均在能力集内
