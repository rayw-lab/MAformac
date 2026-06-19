## ADDED Requirements

### Requirement: 生成式全集覆盖且派生自冻结快照
语义契约 SHALL 从冻结源快照 codegen 机械派生,覆盖 `airControl/carControl/cmd` 的全集源行,不得手写源行。每条契约记录 SHALL 保留 provenance(source_sheet / source_row_no / 内容 hash)。冻结快照 SHALL 由 manifest 锚定;manifest **SHALL 同时含 `content_digest`(语义内容指纹,xlsx 字节级重存不破坏锚定,作语义漂移判据)与 `file_sha256`(文件字节,防换文件)双 hash**。

#### Scenario: 从冻结快照生成
- **WHEN** 对锁定 content_digest 的冻结快照运行 codegen
- **THEN** 每个源语义行产出一条契约记录并带 provenance,manifest content_digest 校验通过

#### Scenario: 生成物无漂移
- **WHEN** 重跑 codegen 后比对已提交生成物
- **THEN** 无差异(手改生成物视为违约)

### Requirement: 覆盖采用分流账本而非零丢弃
覆盖 SHALL 满足 `source_rows == valid_contract + quarantined + legacy_mapping` 且 `unclassified_rows == 0`。脏行(合并单元格残留 / 空语义 / 重复表头)SHALL 进 quarantine 并带 reason,既不得洗白成契约,也不得静默丢弃。

#### Scenario: 脏行分流
- **WHEN** 源表存在合并单元格残留或空语义行
- **THEN** 该行进 quarantine 带 reason、在覆盖报告显式列账,不计入 valid contract

### Requirement: 每条契约携带 value 四件套与三元身份
每条契约行 SHALL 携带 `value{ref, direct, offset, type}` 与 `device × action-primitive × slot` 三元身份。经验值与绝对值 SHALL 在协议层区分,具体步长数值不写死在契约(由执行层承担)。

#### Scenario: 经验值与绝对值区分
- **WHEN** 语义为「调高一点」
- **THEN** value 为经验值(ref=CUR, offset=LITTLE, type=EXP)
- **WHEN** 语义为「调到某具体值」
- **THEN** value 为绝对(ref=ZERO, offset=具体占位, type=SPOT)

### Requirement: 跨行引用完整性可校验
`canonical_semantic_id / dedupe_group_id / followup_refs / execution_range_ref` 引用 SHALL 全部可解析;unresolved 比例 SHALL ≤ 2%。

#### Scenario: 引用校验
- **WHEN** 运行引用完整性校验
- **THEN** 引用要么解析成功,要么显式标 unresolved 且总占比 ≤ 2%

### Requirement: 分级执行标注派生自唯一真源
`exec_tier` / `risk` SHALL 挂在源行级(非 device 聚合)。`risk` SHALL 取自单一 risk 策略来源。`exec_tier=L1` SHALL 仅从 reviewed 的 L1 名单派生,不得机器自动 promote,也不得在契约行手写。

#### Scenario: L1 仅从 reviewed 名单派生
- **WHEN** 生成器为某行标注 exec_tier
- **THEN** 仅当其 (device, primitive) 命中 reviewed L1 名单时为 L1,否则默认为通用兜底层

### Requirement: 脱敏边界
契约与仓内任何派生物 SHALL NOT 含客户公司名 / 车型代号 / 供应商名 / 人名 / 禁外传原文。源料 SHALL NOT 进仓(冻结快照在外部只读)。

#### Scenario: 脱敏校验
- **WHEN** 检查仓内契约文件
- **THEN** 无客户标识命中,且源 xlsx 不在版本控制内

### Requirement: 本地校验门成立才算契约有效
契约 SHALL 提供本地校验门,覆盖 regen+diff / 引用完整性 / 分流账本守恒 / range 冲突分类 / coverage,全绿才视为契约成立(不依赖 CI 或 git hook)。

#### Scenario: 校验门
- **WHEN** 运行本地校验门
- **THEN** 五项全过为绿,任一失败为红
