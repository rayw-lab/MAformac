# 座舱语义协议基座 — 深度消化 + MAformac 内化方案

> **状态**:基座消化记录 + 内化方案(待磊哥拍方向)。2026-06-19。
> **红线**:4 张源表是某车厂一手料(`~/Downloads/`),**只读参考,不进仓、不入训练集**。本文档只抽象**通用语义工程协议范式**(value 四件套 / 归一化动作编码 / 二次交互矩阵等),不复制任何客户标识/车型/具体语料原文。
> **来源**:① `公版语义四级功能协议表-编辑版`(基座,25 sheet)② `多语种公版语义四级展开V1`(多语种同构)③ `车控功能打点表`(优先级+DS)④ `上下文二次交互功能清单`(多轮)。

## 0. 先认错(根因)
我此前 4 次被要求"仔细看",每次都在二手简化的 `contracts/capabilities.yaml` 上接着推(change2/3/must-pass),**从没逐 sheet 读这 4 张一手基座**。结果把一个被我自己简化坏的契约当事实源,还把"我有点冷→设26度""+2度"这种**拍脑袋值**当设计。根因 = happy-path + 凭二手料拍脑袋 + 进舒适圈。本文档是把基座真正吃透后的重做基础。

## 1. 四基座是什么(各自的金钥匙)

| 基座 | 规模 | 核心维度(列) | 金钥匙 |
|---|---|---|---|
| **① 编辑版**(语义协议事实源) | 25 sheet;carControl 2655 / cmd 1088 / airControl 174 四级功能 | 四级功能 / **DS协议(含value四件套)** / **取值范围** / **示例说法** / **功能类型编码** / 泛化句式槽映射 / **FC模糊说·FC自由说(是/否)** / 属性 / 生效场景 | **动作归一化**:3900 intent 只用 ~114 种功能类型编码 |
| **② 多语种展开V1** | 同①结构 + 多语种 | 同① + 多语种语料 | 多语种泛化(MAformac 一期中文,二期参照) |
| **③ 打点表** | airControl/carControl/cmd | 四级功能 / **功能优先级** / DS协议 / intent | **优先级**(demo 选型依据) |
| **④ 上下文二次交互** | carControl 2983 行 | 首轮功能 / **可继承内容** / 次轮支持功能 / **次轮示例说法** / 脑图是否构建 | **首轮→次轮二次交互矩阵**(多轮/指代/query rewrite) |

## 2. 统一语义协议范式(7 要素 —— 这是要内化的"骨架")

**① 四级语义结构**
`service(一级,如 airControl/carControl)→ 二级功能(大类)→ 三级功能(设备+动作中文)→ 四级功能(intent + slots,含 position 变体)`。
DS 协议形态:`{"service":..,"intent":..,"semantic":{"slots":{...}}}`。

**② value 四件套(参数规划核心)** — `{ref, direct, offset, type}`
- `ref`:`CUR`(相对当前)/ `ZERO`(绝对调到)/ `MAX`(基于极值)
- `direct`:`+`/`-`(ref=ZERO 固定+,ref=MAX 固定-)
- `offset`:具体数字 *或* `LITTLE`(一点/有点冷)/ `MORE`(太/多一点)/ `MAX`/`MIN`/ 经验枚举(HIGH/HIGHER/MIDDLE/LOW/LOWER)
- `type`:`SPOT`(具体值/挡)/ `PERCENT`(百分比)/ `EXP`(经验值,无具体数)

**③ 同一设备按说法裂成多 intent(范式,非穷举)** — 以"调温度"为例:
| 说法 | intent | value |
|---|---|---|
| 调高**3度** | `raise_*_by_number` | `{CUR,+,3,SPOT}` |
| **调高一点 / 有点冷** | `raise_*_by_exp` | `{CUR,+,LITTLE,EXP}` |
| **太冷了** | `raise_*_by_exp` | `{CUR,+,MORE,EXP}` |
| 调到**28度** | `adjust_*_to_number` | `{ZERO,+,28,SPOT}` |
| 调到高/中/低 | `adjust_*_to_exp` | `{ZERO,+,HIGH/MIDDLE/LOW,EXP}` |
| 调到最高/最低 | `adjust_*_to_max/min` | `{ZERO,+,MAX/MIN,EXP}` |
> ⚠️ **有点冷 = raise(升温)by_exp,offset=LITTLE 是经验值,语义层不带"+几度"**;具体步长(磊哥:默认+1)由**执行层**映射。我此前把"有点冷"错成"开机+设26度"是双重错。

**④ 功能类型编码归一化(灵魂)**：3900 个四级功能 = **~114 种设备无关编码 × 设备对象 × value × position 变体**。高频编码:`activate/deactivate_instant_device_or_function`(开关)、`open_mode/close_mode`、`increase/decrease_value_little`、`adjust_value_to_max/min/gear/specific_value`、`*_by_percent`、`device_move_to_direction_little/by_number/to_extreme`、`pause_function`、`open/close_process_device`，每个都有 `_position_` 变体。**这才是契约的正确抽象层 — 不是每设备一个独立平铺 tool。**

**⑤ position/direction**:几十种位置枚举(主驾/副驾/各排/温区:左温区/右温区/单双三四区…);空调用 `direction`,座椅/车窗用 `position`。

**⑥ FC 分流标记(col30/31 = 是/否)**:基座给每个四级功能标注是否需要 `FC模糊说` / `FC自由说` 泛化 → **直接是 intent-routing 三层分流的分类依据**(FC说=否→规则快路径;=是→FC 泛化层)。airControl 50 个需模糊说/9 个需自由说;carControl 184/16。

**⑦ 二次交互矩阵(多轮金钥匙)**:`首轮 intent → 可继承内容(继承哪些槽:设备/direction/modeValue)→ 次轮可达 intent + 省略说法`。如 `open_ac`(继承空调+direction)→ 次轮「副驾也打开」(继承动作换 direction)/「再高点」(继承上下文给增量)/「关了吧」(反向)。= query rewrite + 槽继承 + 指代消解的协议源。

## 3. 我的 `capabilities.yaml` 错在哪(逐项对照基座)

| 基座维度 | 我之前做的 | 错 |
|---|---|---|
| value 四件套 | `power/level/percent` 平铺标量 | **整套 ref/direct/offset/type 丢失** → 无法区分相对/绝对/经验/极值 |
| 归一化动作编码 | 8 个设备各做 1 个独立 tool | **错失"动作归一化"本质**;扩展=每设备重写 |
| intent 分型 | 一个 `set_cabin_ac` 吃所有 | by_number/by_exp/to_number/to_max… **全压成一个** |
| 取值范围 | 拍 `16-30 / 0-5` | 没核任何表(基座:温度下限见 18;摄氏/华氏/挡三 adjustment_mode) |
| position | 无 | 基座几十种位置 + 温区 |
| FC 分流标记 | 无 | 基座每功能自带泛化需求标签 |
| 二次交互 | 无 | 基座有完整首轮→次轮矩阵 |
| 语料 | LLM 自造 keyword | 基座 col20 示例说法 + col30/31 FC 说法是现成语料 |

## 4. MAformac 内化方案(待磊哥拍,不自己拍死)

**A. capability/tool 契约重构** — 从"每设备一个平铺 tool"→"**归一化动作编码 + value 四件套 + 设备绑定**":
- 一个 `adjust_value` 族 tool 携带 `{action_code, device, value:{ref,direct,offset,type}, position}`,而非 8 个 `set_cabin_*`。
- 或保留按设备分 tool,但每个 tool 的参数升级为 value 四件套 + 区分 by_number/by_exp/to_number/to_max 的 intent 子类。
- `contracts/capabilities.yaml` 升级:每能力补 `value_schema`(ref/direct/offset/type 取值)+ `range`(从基座 col17 取真值)+ `action_codes`(该设备支持的归一化编码集)+ `positions`。

**B. 参数规划层**(intent-routing FC 层的核心):
- 绝对(to_number,ZERO)→ 直接赋值;相对(by_number,CUR)→ 读端态 ± offset;经验(by_exp,LITTLE/MORE,EXP)→ 读端态 ± **执行层步长表**(demo 定:温度±1、风速±1挡…);极值(to_max/min)→ 端态置 range 边界。
- **执行层步长是 demo 自定义的确定值,不是 LLM 拍** → 落 `contracts` 的 `step_table`。

**C. intent-routing 三层分流** ← 直接用基座 col30/31:`FC说=否`→规则快路径(查表);`FC模糊说/自由说=是`→FC 泛化层。省掉我们自己拍分流边界。

**D. 多轮/二次交互** ← 用基座④矩阵:维护 `last_frame`(首轮 intent+slots)→ 次轮按"可继承内容"做槽继承 + query rewrite(「副驾也是」=继承 intent 换 position;「再高点」=继承设备给 by_exp 增量)。demo 实现一个**收敛子集**的二次交互矩阵即可炸场。

**E. LoRA 语料** ← 基座 col20 示例说法 + col30/31 FC 说法 + ④次轮说法 = 现成的"模糊说/自由说/省略说"训练对(替掉 LLM 自造 keyword)。

**F. demo 设备选型 + 范围对齐**:按基座③功能优先级(高)选;范围/档位/步长从基座 col17 取准(温度下限 18 已见,完整范围逐设备核)。

## 5. 对已做工作的影响

| 已做 | 影响 | 处置 |
|---|---|---|
| **change2 `capabilities.yaml`(已 archive)** | 缺 value 四件套/归一化编码/范围错 | **要回炉或新起契约升级 change**(这是根) |
| **change3 execution(PR #1)** | 骨架(候选→decode→guard→execute→readback)**仍成立**;但 arguments 结构要随契约升级到 value 四件套 → decoder/guard/executor 要改 | change3 不白做(执行契约层骨架对);契约升级后**跟着改一轮** |
| **intent-routing(第7 change)** | FC 层/参数规划/多轮 = 正好落在基座②③④⑦ | explore 时直接吃基座,不再拍 |
| **must-pass candidate** | 基于扁平契约,全错 | **重做**(用真实 intent 范式 + 基座语料) |
| **GPT Pro 复审(刚回)** | 审的是扁平契约上的实现 | 先收着;契约升级后复审才有意义 |

## 6. 待磊哥拍的关键决策(我先不动代码)
1. **demo 契约纳入 value 四件套 + 归一化动作编码吗?** 我判断**要**(否则砍掉"有点冷自动升温/调高一点 vs 调到26度"= demo 炸点全没)。
2. **demo 设备子集**:空调(温度/风速/开关)+ 座椅(加热/通风/按摩)+ 车窗 + 氛围灯 + 屏幕亮度?还是你定另一组。
3. **范围/档位/步长**从基座逐设备核准(我来核)还是你直接给关键几个?
4. **`capabilities.yaml` 回炉重构** vs **新起一个"契约升级"change**(change2 已 archive)?
5. **多轮二次交互** demo 做到什么程度(一个设备链的省略指代就够炸,还是多设备)?

## 7. 消化进度(诚实标注,不假装全读)
- **已深度消化**:编辑版范式/维度/归一化/功能全景;打点表 airControl 全 + 座椅 + 结构;二次交互 airControl 矩阵 + 结构;多语种"整体说明"(value 四件套定义来源)。
- **结构级 + 抽样**:carControl 2655(全景树 + 座椅 + 编码统计,未逐条 2655);cmd 1088(全景树);媒体类 sheet(结构)。
- **待深挖(下一步可继续)**:carControl 二次交互全矩阵(2983 行)、多语种语料、cmd 屏幕/音量/背光、`forbidden`(禁忌词)sheet、`下拉列表取值范围`全 153 编码逐条。
- dump 工件:`/tmp/xlsx_dump/`(原文)+ `/tmp/digest/`(按四级功能聚合的消化版)。

