# Teardown: 真实座舱 TOP 技能表 FC 契约 + 交付手册（某车厂一手源）

> 2026-06-22 blueprint-teardown 深拆。**目的 = ground-truth 验证 MAformac「B-frame vs D-domain」范式决策**：真实座舱到底用 per-device 具名工具，还是统一 `tool_call_frame{device,action,value}`？
>
> 🔴 **脱敏铁律**：源料 = 真实座舱（某车厂）FC 工程一手料，**只读不入仓**。本档只抽象语义/结构/范式/工程决策，**不复制原文话术语料**；车型代号/客户公司名/APP ID/平台名一律脱敏。源文件路径仅作锚点，文件本身不入仓。
>
> 源文件（本机只读）：
> - `~/Downloads/【规整】TOP技能表FC&测试集.xlsx`（2.8M，21 sheet，FC 契约 + 测试集）
> - `~/Downloads/复杂车控 function call 交付手册.docx`（578k，FC 交付/链路/指标手册）

---

## 0. 一句话结论（ground-truth）

**真实座舱用的是「D-domain 的极致密集版」——不是 6 个，也不是统一 frame，而是 2045 个具名 FC 工具（intent），按 `domain(16) → service-group(236) → FC-tool(2045)` 三级组织。每个 FC 工具的 value 语义（max/min/number/exp/相对增减/query）直接编码进工具名，不靠统一 frame 的 action_primitive 参数枚举。**

→ 对 MAformac 的直接 implication：**MAformac 当前硬编码 6 个 D-domain 工具是「假派生」（数量错 2 个量级），但 D-domain 的【组织形态】方向是对的**；真正的纠正不是「换成 B-frame」，而是「从契约 SSOT codegen 出全量 D-domain 工具目录 + 用 service-group 分层把工具数压到端侧可控」。详见 §7。

---

## 1. xlsx 全景（21 sheet，逐 sheet 已读）

| sheet | 行数 | 角色 | FC 工具数(col E 去重) |
|---|---|---|---|
| carControl | 3242 | 车身控制（最大域） | 940 |
| cmd | 3240 | 系统/设置控制 | 509 |
| mapU | 869 | 导航 | 209 |
| musicX | 1603 | 音乐 | 88 |
| airControl | 3240 | 空调 | 51 |
| app【部分待补充】 | — | 应用启动 | 46 |
| telephone【部分待补充】 | — | 电话 | 44 |
| carControl-VLA | 161 | ADAS/智驾（NOA/泊车，含 `FC还是舱泊` 路由列 X） | 32 |
| video | — | 视频 | 30 |
| radio | — | 收音机 | 29 |
| cmdControl | — | 命令控制 | 26 |
| internetRadio | — | 网络电台 | 13 |
| scheduleX / dateTimeX / weather / vehicleInfo / stock | — | 日程/时间/天气/车辆信息/股票 | 10/7/6/2/3 |
| carmaster&help【取消】/ news【取消】 | — | 已取消（计 12 工具，不计入 active） | — |
| mapU热门POI类型泛化-二次交互 | 54 | **特殊**：POI 类型泛化的多轮二次交互（不同列结构） | — |
| mapU(充电地图) | 261 | **特殊**：充电地图，模糊「续航不足」→`navigate_nearby_poi`（不同列结构） | — |

**合计 active FC 工具 = 2045 个**（含取消 = 2057）。19 个 sheet 共用同一套列结构；2 个 mapU 特殊 sheet 列结构不同（二次交互 / 充电地图）。

### 标准列结构（col A–AA，19 个主 sheet 一致）

| 列 | 含义 | MAformac 对应 |
|---|---|---|
| A 一级功能 | domain（=DS service） | domain |
| B/C 二级功能(中/英) | **service-group**（236 个，如 `window_control`/`adjust_ac_temperature`） | （MAformac 当前缺这一层） |
| **D/E 三级功能-Function Call-(中/英)** | 🔴 **FC 工具名 = intent**（2045 个，如 `open_window`/`adjust_ac_temperature_to_number`） | = MAformac 的「具名工具」 |
| F 四级功能-带协议赋值 | 带参说法模板 | — |
| G 功能描述 | 功能描述 + 功能别名（用于 prompt/系统提示） | tool description |
| **H NLU协议** | FC/NLU 输出 JSON（intent + slots，见 §3） | ToolCall schema |
| I NLU协议字段取值范围 | slot 枚举（如 direction 40 座舱区、mode=制冷\|制热） | arg enum |
| J 槽取值映射四级功能说法 | offset/value 的人话↔机器值映射（如 HIGH:高、摄氏度:度） | value 归一化映射 |
| K 无限槽取值示例 | 开放槽示例 | — |
| **M DS协议** | 协议转换后的下游 DS 协议（service+intent+semantic.slots） | mock 执行协议 |
| N DS协议字段取值范围 | DS slot 枚举 | — |
| O 功能优先级（线上数据排名） | 高/中/低 | （可作 L1 精做选取依据） |
| **P/Q/R FC 是否支持 基础说法泛化/模糊说/自由说** | 🔴 三档泛化能力开关（per-tool） | 路由/训练分流 |
| **S 数据类型** | 标准说法 / 模糊说法 / 自由说法 / 模糊意图 | LoRA 数据分层（与 home-llm 配比同源） |
| **T/U 单轮/多轮测试集** | 测试话术（input → 期望 intent，`=》`箭头） | C6 bench case |
| V 上线日期 / W 语义是否支持 / X 备注 / Y-Z/AA 示例来源 | 元数据 | — |

---

## 2. 🔴 工具组织范式（最高优先，坐实证据）

### 结论：D-domain 极致密集版，value-form 编码进工具名

**证据 1 — 工具名 = intent，2045 个具名工具**（不是统一 frame）：
- col E 实际工具名样本（airControl 的空调温度族，sheet=airControl）：
  ```
  adjust_ac_temperature_no_value   （无值）
  adjust_ac_temperature_to_exp     （调到高/中/低，type=EXP）
  adjust_ac_temperature_to_max     （调到最高）
  adjust_ac_temperature_to_min     （调到最低）
  adjust_ac_temperature_to_number  （调到具体数值，type=SPOT）
  raise_ac_temperature_by_exp      （升高一点，direct=+, offset=LITTLE|MORE）
  raise_ac_temperature_by_number   （升高 N 度）
  lower_ac_temperature_by_exp / lower_ac_temperature_by_number
  query_ac_temperature             （查询）
  ```
- `intent` 字段 == col E 工具名：7787/7793 行精确相等（6 处 mismatch 是合并单元格跨行伪影）。**工具名就是 intent。**

**证据 2 — value 语义编码进工具名，NOT 统一 action_primitive 参数**：
对比 MAformac 的 B-frame 设想 `tool_call_frame{device, action_primitive:"adjust_value", value:{ref,direct,offset,type}}` —— 真实座舱**把 value 的形态拆成多个独立具名工具**：`_to_max` / `_to_min` / `_to_number`(SPOT) / `_to_exp`(EXP) / `raise_..._by_*`(相对+) / `lower_..._by_*`(相对−) / `query_*`。value 四件套 `{ref,direct,offset,type}` 仍在 slot 里出现（见 §3），但**工具名已经把「绝对/相对/最值/查询 × SPOT/EXP」这个 value-form 维度固化掉了**——模型选对工具名 = 已选对 value 形态，只需填具体数值/方位 slot。

**证据 3 — 三级树状组织（domain → service-group → tool）**：
- L1 domain（col A，= DS `service`）= **16 个**：carControl(2544 行) / video(1235) / musicX(1128) / cmd(1118) / mapU(497) / cmdControl / radio / internetRadio / airControl / scheduleX / app / telephone / weather / datetimeX / vehicleInfo / stock。
- L2 service-group（col C 二级功能英文）= **236 个**（如 `window_control` 含 29 个 tool、`adjust_ac_temperature` 含 10 个 tool）。
- L3 FC tool（col E）= **2045 个**。
- service-group → tool 扇出分布（value-form fanout）：1 tool/group 17 个，2 tool/group 49 个，… 最大 `window_control` 64 个工具（open/close × 各种窗类型/模式/by_number/to_number/curtain/lock…）。

**反证 B-frame**：表里**没有**统一的 `tool_call_frame` 工具 + device 枚举参数。device（车窗/天窗/座椅…）和 action（开/关/调）**都被吸收进 intent 工具名**，只有 value 的具体数值、座舱区位（direction）、模式（制冷/制热）等留在 slot。

---

## 3. NLU / DS 协议 schema（FC 输出 → 协议转换 → 下游）

### NLU 协议（col H，FC 模型输出的语义协议，含 value 四件套）

`adjust_ac_temperature_to_number`（调到具体数值，sheet=airControl）：
```json
{
  "intent": "adjust_ac_temperature_to_number",
  "adjustment_mode": "$adjustment_mode",         // 摄氏度|华氏度|挡位
  "temperature.ref": "ZERO",
  "temperature.direct": "+",
  "temperature.offset": "$",                       // <具体数值>
  "temperature.type": "SPOT",
  "optional": { "direction": "$direction", "mode": "$mode" }
}
```
`raise_ac_temperature_by_exp`（升高一点，相对增减）：
```json
{
  "intent": "raise_ac_temperature_by_exp",
  "temperature.ref": "CUR", "temperature.direct": "+",
  "temperature.offset": "LITTLE|MORE", "temperature.type": "EXP",
  "optional": { "direction": "$direction", "mode": "$mode" }
}
```
`adjust_ac_temperature_to_exp`（调到高中低，绝对档位）：
```json
{ "intent": "...to_exp", "temperature.ref": "ZERO", "temperature.direct": "+",
  "temperature.offset": "HIGH|HIGHER|MIDDLE|LOW|LOWER", "temperature.type": "EXP", ... }
```

🔴 **MAformac value 四件套 `{ref, direct, offset, type}` = 此 vendor 的 `<slot>.{ref, direct, offset, type}` 一字不差**（ref=CUR/ZERO、direct=+/−、offset=具体值|LITTLE|MORE|HIGH|LOW…、type=SPOT|EXP）。MAformac 的 SPOT(抠槽)/EXP(逆规整) 范式 100% 对齐源料。

### DS 协议（col M，协议转换后下游执行协议）
```json
{ "service": "airControl", "intent": "adjust_ac_temperature_to_number",
  "semantic": { "slots": { "adjustment_mode": "$adjustment_mode",
    "temperature": { "ref":"ZERO", "direct":"+", "offset":"<具体数值>", "type":"SPOT" } } } }
```
- `service` = 16 个域之一；`intent` = 工具名；`semantic.slots` = 嵌套 slot。
- **NLU 协议与 DS 协议是两套**：FC 输出 NLU 风格（flat `temperature.ref`），经「协议转换」变成 DS 风格（nested `temperature:{ref}`）下游。

### optional slot 枚举规模（col I）
- `direction`（座舱区位）= **~40 个枚举**：主驾/副驾/左前/右后/前排/后排/第一排…第三排/前两排/后两排/全车/单区/双区/三区/四区/左温区/右温区。
- `mode` = 制冷|制热；`adjustment_mode` = 摄氏度|华氏度|挡位。
- → 座舱区位是 slot 枚举（B-frame 风），而 device+action+value-form 是 intent 名（D-domain 风）。**混合：粗粒度=D-domain 具名，细粒度参数(区位/模式/数值)=slot 枚举。**

---

## 4. 测试集设计（对照 MAformac C6）

| 维度 | 真实座舱 | MAformac C6 现状 |
|---|---|---|
| 覆盖工具 | 2045 个 FC 工具全覆盖（每 tool 有 T/U 测试行） | 仅 6 工具 |
| 单轮 case | ~10,532 行（col T） | 57 case |
| 多轮 case | 932 行（col U，`Q1…Q2=》期望intent` 格式） | — |
| 数据分层（col S 数据类型） | 标准说法 ~7800 / 模糊说法 ~2580 / 自由说法 ~226 / 模糊意图 | — |
| 评测口径 | **期望 intent（=工具名）匹配**为主（T 列 `输入话术 →期望intent`），slot 值匹配为辅 | ToolCall 集合精确匹配 + 拒识空匹配 |
| per-tool 泛化档位 | col P/Q/R = 基础泛化/模糊说/自由说 三档（每工具独立标支持与否） | — |

**多轮 case 格式**（脱敏示意）：
```
Q1：副驾这边要调整下空调的使用参数
Q2：主驾这边也操作一下  =》 打开主驾空调设置页面
```
→ 多轮 = 上文 intent 继承 + 本轮 slot 改写（落域锁定 + slot 替换），≤3 轮，与 MAformac second_turn_refs / query rewrite 同源。

**模糊/自由说法的免责声明**（col S 原文标注）：「模糊说法（是否支持以 R 列为准，数据只做参考，不保证效果）」——**vendor 自己承认泛化数据是参考、不保证效果**，与 MAformac「模糊靠泛化不靠堆规则」「自由说不支持→兜底播报」一致。

**对 MAformac C6 的 implication**：
1. C6 测 6 工具是 demo 子集（合理），但**评测口径应锚定「intent/工具名匹配」**，与真实座舱一致；slot 值匹配次之。
2. 数据分层（标准/模糊/自由 = ~75%/24%/2%）可直接抄进 C5 LoRA 配比 + C6 bench 分轴。
3. 多轮口径 `Q1/Q2=》期望intent` 可直接作 MAformac 多轮 bench 的 case schema。

---

## 5. 交付手册（docx）关键工程决策

### 5.1 技术链路（image1.jpeg，canonical 架构图）
```
文本 ─┬─→ NLU(传统语义) ─→ DS(信源搜索) ─→ DM(对话管理) ─→ 语义结果
      └─→ 大模型FC ──FC协议──→ 协议转换 ──NLU协议──→ DS(汇入同一下游)
            ↑(喂)                                    ↑
       Function name + params                    应用状态/车身状态(虚线)
```
🔴 **核心工程决策**：FC 模型只输出 `(function_name, params)`；一个**确定性「协议转换」适配器**把 FC 协议翻成 legacy NLU/DS 协议，汇入既有 DS/DM 管线。**FC 不直接驱动执行，而是产出结构化意图 → 适配器 → 复用既有确定性下游**。→ MAformac 的 `ToolCall → DemoGuard → mock state` 链路就是这个「协议转换 + 确定性下游」的端侧化。

### 5.2 模式（P4-P5）：大模型为主 + 传统语义&规则DM为辅
- 传统语义负责**基础标准说法 + 项目定制**；大模型 FC 负责**模糊/复杂意图 + 部分 DM**。
- 车控车设类 DM 简单 → FC 直接闭环；导航/媒体类业务逻辑复杂 → FC 理解后调用传统 DS/DM 闭环。
- → 与 MAformac「L1 规则吃 80% 高频明确 / L2-5 模糊走 Qwen+LoRA」**完全同构**（这里 vendor 反过来以模型为主，因为它有云端大模型；MAformac 端侧小模型则规则吃更多）。

### 5.3 端侧交互策略（P24-P27 表）
| 泛化类型 | 下发技能数 | 车型支持 | 最终表现 |
|---|---|---|---|
| 模糊说 | 单个 | 支持 | 执行动作 + 技能执行播报 |
| 模糊说 | 单个 | 不支持 | 端侧通用兜底逻辑 |
| 自由说 | 单个 | 支持 | 执行动作 + 技能执行播报 |
| 自由说 | 单个 | 不支持 | FC 兜底播报「我暂时还帮不了你，请换个说法试试吧」 |
- 🔴 **云端不做任何处理，把 FC 结果原样下发；端侧按「模糊说/自由说」标签做差异化交互**（标签驱动端侧策略）。
- 🔴 **FC 暂不支持一句话多意图、暂未结合端状态**（P85「为一句指令对应到最合适最稳妥的技能」「后续 master agent 实现多意图」）。→ 与 MAformac 当前 single-call 取向一致；多意图是二期。

### 5.4 标签 / clarifyTag / 意图收缩（P31-P33, P44）
- FC 命中时输出 `"label"` 字段，取值 **`自由`/`指令`**（P44：有 label = 进了 FC，否则未召回或语义已召回）。
- `"clarifyTag": "implicit"`（P31）：后处理脚本对**涉及感受/场景的描述**（冷/热/闷/干/臭/吵/挤等）标记为模糊意图，**语义层拒识**，把流量引导到 FC 模型。
- **意图收缩模型**（P32）：语义小模型/片段文法的感受场景描述，训一个「意图收缩模型」识别为模糊意图 → 拒识 → 引流给 FC。
- → MAformac 的 `clarifyTag` + 「意图收缩（NLU 主动弃权模糊说法→慢路）」**直接源自此 vendor 的 clarifyTag:implicit + 意图收缩模型**，是一字不差的范式继承。

### 5.5 安全策略（P28-P29 + image3.png 安全功能架构）
- 「FC 泛化能力大幅提升 → 误吸率可能增加 → 语音控车比手动需更高安全定义 → 对部分设备加二次确认/安全策略」。
- **驾驶安全强相关**（需二次确认）：车窗/天窗/主驾座椅/方向盘位置/引擎盖/车外侧电动踏板/油箱盖/HUD/充电口/后备箱/车外灯（近光/示廓/自动大灯/雾灯/远光/灯光秀）/雨刮器/后视镜/驾驶模式/能量回收/仪表亮度。
- **乘车安全相关**：车窗锁/儿童锁/车门锁/安全带/车窗/车门/天窗。
- → 与 MAformac「安全门是代码不是 prompt / risk-policy 单源 R0-R3 / clarifyTag」对齐；可直接作 MAformac 的 forbidden/二次确认设备清单 seed（脱敏后是通用车控安全语义，非专有语料）。

### 5.6 指标要求（P49-P62）
- 模糊说意图准确率 ≥ 90% / 自由说 ≥ 80% / 整体泛化 ≥ 85% / 上下文（≤3 轮）≥ 85%。
- 整体误吸率 ≤ 5%（对外）。响应时间 ≤ 2400ms。
- → MAformac C6 可直接 adopt 这套阈值作分轴 gate（模糊/自由/上下文分轴 + IrrelAcc 对应「误吸率」）。

### 5.7 配置粒度（image5，脱敏）
- FunctionCall 是**按 domain 独立开关**（carControl/airControl/cmd/mapU/musicX/…/vehicleInfo 逐个勾选）。
- 有「车控转拒识」开关（= clarifyTag 拒识引流）。
- → domain 级可插拔 = MAformac「可插拔多技能」的真实工程印证。

---

## 6. 跨文件 cross-cutting 范式（提炼）

1. **D-domain 极致密集 + value-form 编码进工具名**：2045 具名 intent，value 形态（max/min/number/exp/相对/query）固化到工具名，slot 只留具体数值/区位/模式。**不是 B-frame 统一 frame。**
2. **三级组织 domain→service-group→tool**：236 个 service-group 是关键中间层（端侧可按 group 分批加载，把 2045 压到可控）。
3. **FC 只产 (name, params)，确定性适配器转协议汇入既有下游**：模型不碰执行/安全/DM 闭环的确定性部分。
4. **标签驱动端侧策略**：label=自由/指令、clarifyTag=implicit、模糊/自由说 → 端侧差异化交互 + 兜底播报。
5. **意图收缩模型**：感受/场景描述主动拒识引流给 FC（不硬塞规则）。
6. **value 四件套 `{ref,direct,offset,type}` + SPOT/EXP** 与 MAformac 完全同源（同一 vendor 协议族）。

---

## 7. 🔴 对 MAformac「B-frame vs D-domain」决策的直接 implication

### 真实座舱怎么做
**D-domain（2045 具名工具）+ 三级组织 + value-form 编码进工具名 + 确定性协议转换适配器。明确不用统一 B-frame。**

### MAformac 该选哪个 + 理由

**选 D-domain（具名工具目录），但分层 + codegen + 端侧裁剪**，理由：

1. **方向对齐真实座舱**：源料 2045 具名工具，value-form 进工具名 = D-domain。MAformac 当前 6 个具名工具是「方向对、数量错 2 个量级（假派生）」。纠正 = **从契约 SSOT（3990 行 / `semantic-function-contract.jsonl`）codegen 出全量具名工具目录**，不是改成 B-frame。

2. **B-frame 的诱惑（统一 frame、671 device × 141 action 参数枚举）真实座舱已否决**：vendor 没用统一 frame，因为 (a) value 形态（SPOT/EXP/相对/最值/query）无法干净塞进单一 action 参数——会逼模型在一个工具里同时决策 action_primitive + value.type + value.offset，**判定面太大、误吸率高**（vendor 明示「泛化↑→误吸↑」是核心痛点）；(b) 具名工具让「选对工具 = 选对 value 形态」，把模型的决策简化为「分类到 2045 类之一」，受限解码/GBNF 更好约束。

3. **端侧 2045 工具不可行 → 用 service-group 分层 + L1 裁剪**：
   - MAformac 端侧 Qwen3-1.7B 不可能把 2045 工具全塞进 prompt。但**真实座舱也是按 domain 独立开关 + service-group 分组**——MAformac demo 只需选 **~10 个 demo-critical service-group**（空调温度/风量/车窗/座椅/氛围灯/导航 POI/音乐…），每 group codegen 出其 value-form 工具族（如 `adjust_ac_temperature` group → 10 个工具）。
   - L1 精做 ~5-10 设备 = runtime 表现层（端侧实际加载的工具子集）；模型训练吃**全集 3990 大范围泛化**（C5 LoRA），但 C6 bench/端侧 surface 只挂 demo 子集工具。

4. **不要手写第二套工具**（claim-vs-reality 铁律 1）：MAformac 6 个硬编码工具 = 手写第二套契约（已被「446 假删工具」灾难证明危险）。**工具目录必须从 `semantic-function-contract.jsonl` 单一 SSOT 用 compiler 派生**（D/E 列工具名 → tool schema，H 列 NLU 协议 → ToolCall schema，I 列枚举 → arg enum）。源料的 col D-N 给出了完整的 codegen 输入。

5. **value 四件套照搬**：MAformac 已对齐，无需改。SPOT=抠槽（`_to_number`/`_by_number`）、EXP=逆规整（`_to_exp`/`_by_exp`），与源料 type=SPOT/EXP 一字不差。

### 一句话裁决（喂回主线程 grill）
> **守 D-domain（具名工具），从契约 SSOT codegen 全量目录，端侧只挂 demo 子集（~10 service-group 的 value-form 工具族），用 service-group 分层把工具数压到端侧可控。B-frame 统一 frame 被真实座舱否决（value 形态塞不进单一 action 参数 + 误吸率高），不采。** MAformac 当前 6 个硬编码工具的问题不是「该换 B-frame」，而是「该停止手写、改 codegen 派生 + 补 service-group 中间层」。

---

## 8. pre-mortem / 待核

- 🐯 **tiger**：codegen 全量 2045 工具后，端侧加载哪个子集是 demo 成败关键——子集选错（漏掉客户现场会说的高频设备）= 不丢脸目标失守。验证清单：用 col O「功能优先级（线上数据排名=高）」筛 demo 子集，对齐客户现场高频。
- 🐯 **tiger**：value-form 工具族扇出大（window_control 64 个工具）——若 demo 选了 window_control 但只 codegen 部分 value-form，模型可能选到未挂载的工具。验证：选定 service-group 后**整组 value-form 工具一起 codegen**，不残缺。
- 🐘 **elephant（没人提）**：源料的「协议转换适配器」（FC 协议→DS 协议）是 vendor 云端的确定性层；MAformac 端侧需要等价的 `ToolCall → mock 执行协议` 适配器，且这层**必须确定性（code）不靠模型**——否则把 vendor 的「FC 只产 name+params、不碰执行」工程纪律丢了。
- ⚠️ **paper-tiger**：「2045 工具太多端侧跑不动」——不是 blocker，因为端侧只挂 demo 子集（vendor 本身也是 domain 级开关 + 分组加载），全集 2045 只进训练不进端侧 prompt。
