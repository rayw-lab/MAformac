## ADDED Requirements

### Requirement: 演示必过集 100% 通过
系统 SHALL 维护精选演示必过集(覆盖 5 幕);该集在断网下 SHALL 100% 通过;未达 100% SHALL NOT 放行。

#### Scenario: 必过集全过才放行
- **WHEN** 跑演示必过集
- **THEN** 100% 通过才放行,否则阻断

### Requirement: 四个零死门
评测 SHALL 守:危险动作误执行 = 0 / 读回不一致 = 0 / 无工具误触发 = 0 / 必过集 < 100% = 不放行。

#### Scenario: 危险误执行即失败
- **WHEN** 评测中出现危险动作被误执行
- **THEN** 该轮判失败,不放行

### Requirement: restraint(该忍住时忍住)
评测 SHALL 含反用例(状态已满足 / 信息已提供 / 不应动作时),系统 SHALL NOT 误触发工具调用。

#### Scenario: 状态已满足不重复执行
- **GIVEN** 状态已满足(如已 26 度)
- **WHEN** 用户说「调到 26 度」
- **THEN** 系统识别已满足,不重复执行

### Requirement: 每条用例多次评测
系统 SHALL 对每条用例多次评测(非单跑)以判稳定性。

#### Scenario: 多跑判稳
- **WHEN** 评测一条边界用例
- **THEN** 多次运行,稳定性达标才算通过

### Requirement: 评分以正确性为主
评分 SHALL 以正确性(工具名 + 参数)为主体,格式可解析仅占次要权重。

#### Scenario: 格式对但工具错不算过
- **WHEN** 输出格式可解析但工具名 / 参数错
- **THEN** 不算通过(正确性未达)

### Requirement: 泛化分层评测
系统 SHALL 分层评测泛化:模糊说 / 自由说 / 多轮上下文,各层有阈值;整体泛化 SHALL 达标。

#### Scenario: 泛化分层达标
- **WHEN** 跑泛化集
- **THEN** 模糊说 / 自由说 / 上下文各层分别达标

### Requirement: base 与 LoRA 同条件对比
评测 SHALL 在相同条件下对比 base 与 LoRA。

#### Scenario: 同条件对比
- **WHEN** 对比 base vs LoRA
- **THEN** 相同 schema / 温度 / parser / mock,差异仅模型本身

### Requirement: 延迟按路径分别评判
评测 SHALL 按快 / 慢路径分别判延迟(快路径与慢路径不同预算)。

#### Scenario: 快慢路径分别判
- **WHEN** 一条用例标快路径
- **THEN** 按快路径预算判延迟,慢路径按慢路径预算
