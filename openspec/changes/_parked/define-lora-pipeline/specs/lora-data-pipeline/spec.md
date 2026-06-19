## ADDED Requirements

### Requirement: 训练数据脱敏 fail-closed
系统 SHALL 在生成训练候选前对源数据脱敏;脱敏校验 SHALL 默认拒绝(fail-closed)——命中真实项目值 / 人名 / 路径 / 长唯一串 / 原始 JSON / 凭据前缀即拒,SHALL NOT 进入候选。

#### Scenario: 敏感命中被拒
- **WHEN** 源数据含真实人名 / 车型 / 路径 / 原始 JSON
- **THEN** 脱敏校验拒绝,该样本不进训练候选

### Requirement: 训练集不入仓
真实座舱数据 / 脱敏后五件套 / 训练集 SHALL NOT 入仓或上云;仅 LoRA 权重产物可入仓。

#### Scenario: 数据不入仓
- **WHEN** 检查仓库
- **THEN** 不含真实数据 / 训练集,仅权重产物

### Requirement: 评测与训练分离
系统 SHALL 分离评测集与训练集;评测必过样本 SHALL 标记不可训练,不漏入训练。

#### Scenario: demo 必过集不训练
- **GIVEN** 一个 demo 必过样本
- **WHEN** 构建训练集
- **THEN** 该样本被排除(标不可训练)

### Requirement: LoRA 只改善模糊与跨域映射
LoRA SHALL 只改善「模糊说 / 跨域语义 → 工具调用」;SHALL NOT 替代规则快路径 / schema 校验 / 安全门 / readback。

#### Scenario: LoRA 不越权
- **WHEN** LoRA 介入
- **THEN** 仅作用于模糊 / 跨域意图映射,安全 / 校验 / readback 仍由代码承担

### Requirement: base 与 LoRA 同条件对比
系统 SHALL 在相同工具 schema / 采样温度 / 解析器 / mock 状态下对比 base 与 LoRA。

#### Scenario: 同条件对比
- **WHEN** 评测 base vs LoRA
- **THEN** 两者用相同 schema / 温度 / parser / mock,差异仅模型本身

### Requirement: 思考内容不进训练目标
系统 SHALL NOT 将模型思考内容计入训练损失。

#### Scenario: think 不算 loss
- **WHEN** 构建训练样本
- **THEN** 思考内容不计入损失,避免污染行为
