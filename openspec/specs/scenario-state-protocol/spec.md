# scenario-state-protocol Specification

## Purpose
TBD - created by archiving change define-c1c2-contract. Update Purpose after archive.
## Requirements
### Requirement: 场景端态为 demo 自有 mock 且读回一致才算成功
场景端态 SHALL 是 demo 自有的 mock state(非量产车端状态上传协议的复刻)。demo 动作执行后 SHALL 更新对应 mock state cell,并 SHALL 可读回;**读回 mock 态与预期一致才算执行成功**,错误不冒充成功。全流程 SHALL 断网可演。

#### Scenario: 动作后读回一致
- **WHEN** 在 demo 中对某 L1 设备执行一个动作
- **THEN** 对应 mock cell 更新,读回值与预期一致,且断网下行为不变

### Requirement: execution_range 为执行边界唯一权威
C2 SHALL 拥有 execution_range;语义契约(C1)只能引用不得覆盖。引用 SHALL 分级:精做层为 concrete(落具体 cell),通用兜底/越界层可为 generic 或 none。

#### Scenario: 超范围处置
- **WHEN** 候选值超出某 cell 的 execution_range
- **THEN** 按契约处置(钳到默认值或拒绝),不写入非法值

### Requirement: state cell 覆盖为三源并集
state cell SHALL 覆盖「精做设备端态 ∪ 场景所需端态 ∪ 安全门所需端态」。每个精做设备 SHALL 拥有其读回所需的完整 cell 组(不只单 cell)。

#### Scenario: 精做设备读回完整
- **WHEN** 某精做设备的读回需要多个 cell(如温度/风量/模式/开关)
- **THEN** 这些 cell 都在场景端态协议中存在(L1 名单的端态需求被 C2 满足)

### Requirement: 安全门为 demo 优雅兜底而非量产功能安全
安全门拦截类输入(违禁内容)与克制类输入 SHALL 被优雅拒识、不乱执行;当前范围外领域 SHALL 优雅延后。此为**演示炸场效果,显式豁免量产功能安全(ISO 26262)责任**,不承诺真实安全链。

#### Scenario: 越界优雅兜底
- **WHEN** 输入为安全门拦截类、克制类或当前范围外领域
- **THEN** 优雅拒识或延后播报,不冒充执行成功

### Requirement: 量产端态清单仅作脱敏参考池
量产端态上传清单 SHALL 只作外部只读参考池;仓内若保留参考映射,SHALL 只存脱敏的「字段语义 → demo cell」,SHALL NOT 存来源方 / 车型代号 / 责任方 / 上传频率等量产标识。

#### Scenario: 参考映射脱敏
- **WHEN** 仓内存在参考映射文件
- **THEN** 仅含脱敏字段语义映射,无任何客户/量产标识

