# MAformac 领域语言

MAformac 是本地座舱语音控制 demo 助手。本文只记录领域术语边界，避免后续 OpenSpec 重构时混淆范围、契约、运行时和演示精修。

## 术语

**生成式全集（甲档）**:
语义契约覆盖核心座舱控制一手源，但覆盖方式是从源表机械派生，不是人工手写每个能力。第一阶段范围锁定 `airControl / carControl / cmd`。
_Avoid_: 手写全集, 只做设备骨架, 全 workbook 一次性同等执行

**展开语义行**:
一条由源表语义行生成的契约记录，包含 DS 协议、槽位、范围、示例说法、功能类型编码，以及存在时的路由标记。它是 C1 的覆盖率单位。
_Avoid_: 设备数, intent 口径, 能力条目

**规范语义 ID**:
多个展开语义行去重后的语义身份，用于 YAML 聚合、bench 分组和运行时查表。它不能反向定义 C1 覆盖率，覆盖率仍以源行级 JSONL 为准。
_Avoid_: 用 canonical 数替代 source row 数

**分流账本**:
源行进入 C1 生成链路后的归宿记录。它要求每行都有明确归类，允许 quarantine，但不允许黑洞行。
_Avoid_: dropped_rows=0 洗白脏行

**语义契约 JSONL**:
C1 的主物理产物，一行表示一个可校验的语义契约记录，并保留源 sheet、源行号、源行 hash 和脱敏状态。它优先服务逐行覆盖率、diff 和本地生成校验。
_Avoid_: 只用巨型 YAML 承载逐行全集

**冻结源快照**:
生成器读取的不可变源表副本，由 manifest、文件字节 hash 和内容摘要共同锁定。源 xlsx 本体仍按项目红线放在外部只读位置，不作为仓内公开契约内容。
_Avoid_: 直接读 live Downloads 文件, 把源 xlsx 提交进仓

**内容摘要**:
从源表解析后的规范化行集生成的语义 hash，用来判断源内容是否漂移。它不同于文件字节 hash，避免 xlsx 被重新保存但语义未变时误报漂移。
_Avoid_: 只用 file_sha256 判断语义变化

**源快照清单**:
仓内记录冻结源快照身份的 manifest。它必须区分 C1 语义源、C2 端态源和源不可达时的降级语义。
_Avoid_: 只列一部分源表, 把二手转写当一手源

**源不可达降级**:
外部冻结快照暂时不可访问时，仓内 JSONL 镜像成为 fallback 权威，只能验证仓内自洽、引用和覆盖率，不能声称完成从一手源重新生成。
_Avoid_: 源不在也说 regen-from-source 通过

**外部证据引用**:
指向本机只读源表、raw digest 或人工复核记录的证据句柄，用来证明某条契约来自哪里。它不是可公开语料，不能被当作仓内文本来源。
_Avoid_: 把源表原始中文说法复制进仓, 把 evidence ref 当公开引用

**二次交互关系**:
首轮语义到次轮语义的关系边，包含可继承槽位和改写策略。它属于 C1 的关系契约 sidecar，由 C4 路由消费，不并入 C1 主覆盖行。
_Avoid_: 把关系边算进 source_rows, 在 C4 重新发明关系事实

**语义范围**:
源协议里描述槽位可表达空间的范围，如 `<摄氏度>`、枚举候选或协议占位。它解释用户语义，不决定 demo 是否允许执行。
_Avoid_: 把 semantic_range 当执行 guard

**执行范围**:
端态协议拥有的可执行边界，用于 DemoGuard、状态更新和 readback。C1 只能引用它，不能覆盖它。
_Avoid_: 用协议表或旧 capabilities.yaml 反向决定执行范围

**范围引用分级**:
C1 语义行到 C2 执行范围的引用强度随执行层级变化。L1 必须引用具体场景端态 cell，L2/L3 可以使用通用兜底或无执行范围引用，且不进入 DemoGuard range guard。
_Avoid_: 要求全集 L2 行都引用具体 C2 cell

**场景端态协议**:
MAformac demo 自己拥有的 mock state 与场景案例协议。它服务演示中的状态读写、参数规划和 readback，不承诺等同量产车端状态上传协议。
_Avoid_: 把量产端态清单当 C2 权威

**L1 端态完整性**:
L1 精做设备需要具备完整 mock 态来支撑卡片展示、readback、参数规划和安全判断。它不只来自场景脚本里出现过的字段。
_Avoid_: 只按 5 幕场景反推 cell

**量产端态参考**:
真实量产端状态或上传信息材料，只作为 C2 设计的参考输入，用来提醒字段、范围、频率和安全语义，不直接决定 demo 场景端态。
_Avoid_: 为了追量产完整性拖住场景协议

**脱敏参考映射**:
量产参考字段到 demo cell 的抽象映射，只保留字段语义与 demo cell 关系，不保留供应商、车型、人名、责任方或上传频率等源表敏感信息。
_Avoid_: 把 reference_only 当作可进仓原文

**范围冲突**:
语义范围与执行范围不一致的显式差异。它必须进入覆盖报告，不能被生成器静默修正。
_Avoid_: 静默覆盖, 三份 range 都像权威

**源行级分类**:
`exec_tier` 与 `risk` 属于展开语义行的分类，而不是设备聚合视图的权威字段。同一设备的不同动作可能有不同风险和不同演示层级。
_Avoid_: device 级 risk 标量, device 级 exec_tier 权威

**风险策略**:
R0-R3 到 demo 行为、确认策略和安全来源的映射。它收口项目里的 R0-R3、ASIL/QM、forbidden 和 restraint 说法，但只表达 demo 护栏，不表达真实功能安全责任。
_Avoid_: R0-R3 分散定义, 把 demo 二次确认写成 ISO 安全承诺

**L1 精做名单**:
由人工复核确定的 L1 demo 设备/语义名单。优先级可以作为候选依据，但不能自动把语义行提升为 L1。
_Avoid_: 高优先级自动等于 L1

**L1 多轮完整性**:
L1 精做名单必须声明要演示的二次交互关系，让多轮指代、槽位继承和 query rewrite 成为 L1 完整性的一部分。
_Avoid_: L1 只覆盖单轮动作

**L1 唯一真源**:
`l1-demo-allowlist` 是 L1 判定的唯一 reviewed 来源。C1 行上的 `exec_tier=L1` 只能从它派生，不能手写第二份 L1 判断。
_Avoid_: allowlist 和 C1 exec_tier 各写各的

**本地验证门**:
在本机运行的生成与校验命令，至少覆盖重新生成、diff 检查、引用完整性、分流账本和 coverage report。它不等于 CI、hook 或 PR 流程，但没有它就没有真正的单一事实源。
_Avoid_: 没有 CI 所以不做验证门

**设备参考清单**:
从早期 P0 机械产物得到的设备和动作聚合材料。它可以辅助人工理解和对照，但不能作为 C1 主源或 coverage 证明。
_Avoid_: 把 `function-spec-full.yaml` 当 C1 起点

**设备聚合视图**:
展开语义行之上的分组视图，通常按 service、device 或 state cell 聚合。它方便人读，但不能单独证明语义全集覆盖。
_Avoid_: 全集完成证明

**语义契约单一事实源**:
由源表生成、供运行时 schema、规则、LoRA 数据和 bench 共用的契约来源。它可以派生多个视图，但视图必须来自同一批展开语义行。
_Avoid_: capabilities.yaml 手工二次维护, 多份人工事实源

**semantic-function-contract**:
C1 的新 OpenSpec capability spec，承载生成式全集、展开语义行、DS 协议、value 四件套、FC 标记和二轮继承索引。它替代旧 `vehicle-capabilities`，不是在旧 8 能力口径上追加字段。
_Avoid_: vehicle-capabilities 大改, C1/C2 巨型合并 spec

**甲-混节奏**:
先完成 C1 生成式全集语义契约和 C2 端态协议，再用一到两个 L1 纵切验证全栈，之后横向铺开实现。它保留“全集契约先行”，但不等待后续每一层全部完成才验证。
_Avoid_: 纯横切全层做完才验, 未完成 C1 就纵切

**执行分层**:
运行时 demo 表现分层：L1 精做可改态设备，L2 对已听懂的座舱控制语义做通用 mock 兜底，L3 对当前范围外领域优雅延后，L4 做安全拒识。
_Avoid_: 全集都精做 UI, 听不懂就失败

**value 四件套**:
value 的语义编码范式 `{ref, direct, offset, type}`，把"调多少/调到哪"分解成可执行语义。type 枚举 `EXP`(模糊经验)/`SPOT`(具体值)/`PERCENT`(百分比)，是 C1 协议表 + 12 归一化动作原语对参数值的统一表达。LoRA 慢路要学的是「自然说法 → value 四件套」的语义映射，不是抽字面数字。
_Avoid_: 把 argument_value 当抽字面数字, 脱离 value.type 谈参数处理

**抠槽**:
从用户自然说法里抽取具体参数值填进 value 的 offset（`SPOT`/`PERCENT` 类），如"调到26度"→`offset=26 type=SPOT`、"车窗开到50%"→`offset=50 type=PERCENT`。是语义处理动作之一。
_Avoid_: 把抠槽等同于正则抽数字, 忽略 type 分流

**逆规整**:
把模糊感受词逆向映射回规整的 value 四件套（`EXP` 类），如"有点冷/凉飕飕"→`increase_by_exp(offset_enum=LITTLE)`、"有点热"→`decrease_by_exp`。是 demo 不丢脸的泛化核心——模糊说→规整动作，靠 LoRA + 协议表 `trigger_zh` 学，不靠堆规则穷举感受词。
_Avoid_: 把逆规整当字面匹配, 用规则穷举感受词

## 已标记歧义

**全集**:
在本项目里，“全集”可能指源 workbook、三大核心座舱控制域、展开语义行、设备聚合视图或 LoRA 采样数据。C1 语境统一说“生成式全集”，并按 `airControl / carControl / cmd` 的展开语义行计覆盖。

**全量 LoRA**:
指 pipeline 能通过加权采样和留出评测覆盖完整语义契约，不指把每个 device、position、value 组合做笛卡尔展开。

## 示例对话

Dev: "C1 已经有 671 个 device，是不是全集过了？"

Domain expert: "不是。那只是设备聚合视图。C1 要看展开语义行是否从三张核心表逐行生成并覆盖 DS、slot、range、例句和二轮继承。"

Dev: "那甲档会不会要求所有设备都做精美 UI？"

Domain expert: "不会。甲档说的是语义契约全量精确；执行仍按 L1/L2/L3/L4 分层。"
