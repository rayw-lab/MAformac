# MAformac 技术架构基座 v0.1

> ⚠️ **HISTORICAL（2026-06-30 A 文档收敛）**：早期基座 v0.1，部分已被 v2 + 范式翻案 supersede；仅作溯源，当前以 `contracts/` + 范式权威（`grill-decisions-amend-paradigm-tool-surface.md`）+ `CLAUDE.md §9` 为准。

> 综合自 7 路并行提炼（真实座舱项目资料 + 38 个参考 repo）。
> 边界声明：全文不出现真实客户公司名（一律「某车厂」）、报价/商业条款、密钥/PII、对内禁外传原文；仅保留架构 / 语义 / 协议 / 字段结构。
> 文档定位：可直接作为开发蓝图。密度优先，工程精确。
> 生成日期：2026-06-17

---

## 1. 项目定义与北极星

MAformac 是一个**纯端侧（iOS / macOS）、完全离线、以 Qwen3-0.6B + LoRA 为大脑、mock 车控、可插拔多技能（Phase 1 车控 → 后续导航 / 音乐 / 外卖 via MCP）的方案演示助手**——目标不是量产座舱，而是替方案经理把"开样车到客户现场"这件事浓缩成一台 Mac/iPhone 上的离线 demo。**北极星 = 客户现场 5 分钟内：听懂中文、反应快、不崩、看着惊艳、断网也能跑。** 一切技术选型与裁剪都服从这五个词；凡是不能在断网 Mac 上 5 分钟内炸场的复杂度，一律延后或砍掉。

---

## 2. 端云 → 纯端侧 降维映射表

真车是「端 + 云大模型 + 真实 CAN/VSS 车控 + 实时三方 API」；MAformac 把每一层降维到「可在断网 Mac 上跑」的等价物。降维原则：**语义层（理解 / 路由 / 抽槽 / 改写 / 多轮）保真，连接层（车控 / 联网 / 云仲裁 / 鉴权）全 mock**。

| 维度 | 真车端云 | MAformac 演示（纯端侧/离线） | 降维手法 |
|---|---|---|---|
| 大模型 | 云端大模型（慢思考 CoT）+ 端侧小模型（快思考） | Qwen3-0.6B + LoRA，快=规则+向量召回+0.6B 直出，慢=0.6B+LoRA ReAct ≤3 轮 | 慢思考从"云推理"降为"本地 LoRA 推理"，弱网兜底升为常态主路 |
| 落域仲裁 | 云端中枢 `cbm_tool_pk` 多 agent 竞价 | 本地 `Registry.route()`，同构 `cbm_*` envelope | 去 SSE / 去签名，本地路由表打分 |
| 车控执行 | 真实 CAN / VSS path 下发，读回车端状态验收 | `execute_vehicle_control` mock + `query_vehicle_state` 返回固定 JSON | 执行=改 mock 状态机；验收=读回 mock 态 |
| 端状态 | 实时车辆信号（空调/座椅/季节/PM2.5…） | mock 一份不可变 state JSON，三态判定纯函数 | immutable state，三态引擎是离线核心可演示资产 |
| 联网域 | 导航 POI / 曲库 / 外卖 / 新闻 / 赛事 实时 API | mock connector 喂结构化卡片（POI/歌曲/比分列表） | LoRA 只负责语义层，网络层全 mock |
| 鉴权/传输 | HMAC-SHA256 签名 + SSE 流式 | 去掉，本地直调 | 演示无需链路安全 |
| 多模指代 | 摄像头解析衣着/手势/座位 | mock 视觉结果（"穿红衣的=副驾"）注入 | 指代消解逻辑保真，视觉输入 mock |
| ASR/TTS | 云/端混合 | 端侧 WhisperKit ASR + 端侧 TTS（首版可文本输入兜底） | 全端侧，断网可跑 |
| 延迟口径 | 端 ≤3s / 识人车控 ≤1400ms | 同口径（离线延迟是卖点，0.6B 在 Apple Silicon 可达） | 把量产 KPI 当 demo 验收门 |

---

## 3. 多 domain 基座 7 层架构

理解 → 路由 → 规划 → 安全 → 执行五个主层，外裹 **barge-in 包裹层**，**DialogueState 贯穿全程**。文字架构图：

```
┌──────────────────────────────────────────────────────────────────────────┐
│  L0  barge-in 包裹层（全双工 / 可取消管线）                                  │
│      VAD/KWS 端点检测 → 任意层产出帧可被中断 → 取消令牌穿透 L1..L5          │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                         语音输入（WhisperKit ASR）                    │  │
│  │                              │ text                                  │  │
│  │  L1 理解层  ──────────────────▼───────────────────────────────────   │  │
│  │     三层漏斗落域(句式→垂域→干预包标签)                                │  │
│  │     快/慢路由器(route: fast|slow + 命中理由)                          │  │
│  │     产出统一中间语义: sub_intents[]                                   │  │
│  │                              │                                       │  │
│  │  L2 路由层  ──────────────────▼───────────────────────────────────   │  │
│  │     Registry.route() → cbm_tool_pk 落域仲裁(pk_score)                │  │
│  │     Capability 匹配 / OOD 拒识 / 锁域 / 降级                          │  │
│  │                              │                                       │  │
│  │  L3 规划层  ──────────────────▼───────────────────────────────────   │  │
│  │     感受→状态(三态引擎)→参数规划(增量,只改不满足项)                    │  │
│  │     多意图仲裁(冲突矩阵+四原则)  /  二级推荐(极值换关联能力)           │  │
│  │                              │                                       │  │
│  │  L4 安全层  ──────────────────▼───────────────────────────────────   │  │
│  │     代码硬护栏(非 prompt): 取值范围/反向护栏/ADAS拒识/确认门          │  │
│  │     错误枚举: decode_failed|unknown_tool|invalid_argument|           │  │
│  │               unsafe_action|needs_clarification                     │  │
│  │                              │                                       │  │
│  │  L5 执行层  ──────────────────▼───────────────────────────────────   │  │
│  │     Tool(FC母版) assemble→DS协议→mock车控/mock connector            │  │
│  │     读回 mock 端状态验收 → 回复分层(GUI=事实/VUI=操作对象)            │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                  ▲                                          ▲              │
│        DialogueState（焦点栈/最近2轮/last_exec/person_registry）贯穿 L1-L5  │
└──────────────────────────────────────────────────────────────────────────┘
```

层间约束：
- **L1→L5 全程产出统一 `sub_intents[]` 中间语义**，解耦理解与执行；mock 车控只消费该结构。
- **安全层(L4)是代码不是 prompt**——速度/车门/取值范围/确认策略由 executor 判定，模型只提候选动作，不得越权执行。
- **DialogueState 只读不臆造**：改写只还原意图，绝不补历史中不存在的实体/音区/设备。

---

## 4. 核心接口：Capability 协议 + 统一 Tool schema

**设计要点：本地工具与 MCP 工具同构。** 端侧大脑（路由+抽槽+改写）不变，只换 `connector`（mock / local / MCP）。

### 4.1 统一 Tool schema（FC 母版）

> ⚠️ 本节(§4.1)已 **SUPERSEDED** by `contracts/capabilities.yaml`(2026-06-18 change2 定稿)。下方为历史设计,实际 tool schema 以 `capabilities.yaml` 为准;§4.2 起其余章节仍有效。

```jsonc
// 一条 Tool 定义（本地车控 mock 工具与 MCP 导航工具结构完全一致）
{
  "service": "carControl",          // 一级域: carControl|airControl|cmd|mapU|musicAssistant|...
  "category": "window_control",     // 二级功能簇
  "intent": "open_window_to_number",// 四级意图(英文动词_对象), 带协议赋值
  "operation": "SET",               // INSTRUCTION | SET | QUERY
  "slotSpec": [
    {"name":"position","semanticName":"车窗位置","required":false,
     "valueRange":["主驾","副驾","左前","右前","左后","右后","前排","后排","全车"]},
    {"name":"value","type":"ValueStruct","required":true}
  ],
  "valueStruct": {                  // 连续量调节核心结构体(可复用为通用数值参数类型)
    "ref":  "ZERO|CUR|MAX",         // 基线: ZERO绝对 / CUR相对 / MAX从最大倒推
    "direct":"+|-",                 // ZERO恒+, MAX恒-
    "offset":"<数值>|LITTLE|MORE",  // 数值 / 一点 / 幅度大
    "type": "SPOT|PERCENT|EXP"      // 具体挡位 / 百分比 / 无具体值经验值
  },
  "priority":"高|中|低",
  "requires_confirm": false,
  "depends_on_state": false,
  "end_state_field": "window.pos.front_left", // VSS 风格 path, 防"一个车窗三个名"
  "safety_block_rule": null,        // 反向护栏(可空)
  "executable": true,               // ADAS/行驶安全类标 false (演示拒识)
  "connector": "mock",              // mock | local | MCP  ← 唯一区别本地/MCP 的字段
  "descriptor": {                   // 供 Qwen3-0.6B+LoRA 训练/few-shot
    "功能描述":"将指定车窗开到指定百分比",
    "示例说法":["把主驾车窗开一半","副驾窗开到50%"],
    "泛化句式编码":"adjust_device_to_percent"
  }
}
```

DS 外抛协议（端侧 LLM 产 NLU 平铺 → `assemble()` → DS 嵌套 → mock 消费）：

```json
{"service":"carControl","operation":"SET","intent":"open_window_to_number",
 "semantic":{"slots":{"name":"主驾车窗","action":"OPEN",
   "value":{"ref":"ZERO","direct":"+","offset":"50","type":"PERCENT"}}}}
```

### 4.2 Capability 协议（可插拔，对齐落域+注册）

```swift
// 伪代码 — 本地 Capability 与 MCP Capability 实现同一协议
protocol Capability {
    var id: String { get }              // canonical domain id
    var domains: [String] { get }
    var intents: [String] { get }       // 正样例: 域内意图枚举
    var oodRule: String { get }         // 负样例: "OOD/<id>"
    var disambiguation: [Rule] { get }  // 易混淆硬规则(打开蓝牙≠连接蓝牙)
    var scene: Scene { get }            // voice | card | app
    var connector: Connector { get }    // mock | local | MCP

    // 模拟 cbm_tool_pk 落域仲裁
    func match(_ query: Query, _ state: DialogueState) -> Decision  // {landed, pkScore}
    // 模拟 cbm_* envelope 回复流
    func handle(_ slots: Slots, _ history: History) -> ReplyStream   // {status, text, toolData?, source}
}

// 本地中枢(去 SSE/签名/云仲裁)
Registry.register(cap: Capability)
Registry.route(query) -> pk -> dispatch  // 本地路由打分 → 派发
```

同构关键：`NavCapability`(connector=MCP) 与 `WindowControlCapability`(connector=mock) 对外暴露完全相同的 `match/handle`，路由层无差别对待。首版不必起真 MCP server，但协议预留升级通道（Mac+iPhone 拆分时切 connector 即可）。

---

## 5. 功能清单蓝图：八大车控垂域 + 多 domain

### 5.1 八大车控感受垂域（B 层 MasterAgent，差异化核心）

| 垂域 | 优先级 | 端状态依赖 | 落域准确率/误吸目标 |
|---|---|---|---|
| 温度（热舒适，三垂域母本） | P0 | 部分 | ≥95% / ≤2% |
| 声音（听觉） | P0 | **全程不依赖** | ≥93% / ≤3% |
| 气味（空气质量，安全门最重） | P0 | 部分 | ≥93% / ≤3% |
| 空间（座椅/姿态，复杂度最高） | P0 | 部分 | ≥90% / ≤4% |
| 车辆清洁 | P1 | — | — |
| 车内休闲娱乐 | P0-2(Demo) | — | — |
| 视线调节（遮阳帘/HUD 亮度） | P1 | 依赖视觉 | — |
| 轻度不适+车控（头疼/晕车） | P1 | — | — |

**演示建议：P0 四垂域全做，温度做主线 Demo。**

A 层 FC 原子域（service 枚举）：`carControl`（车身控制，~70 个二级功能，最大）、`airControl`（空调）、`cmd/cmdControl`（通用控制层，按上传状态动态转 service）、`app`，其余多媒体域演示可略。**ADAS（lcc/lka/aeb/noa/tsr/盲区/碰撞预警）属安全域，演示助手默认拒识不执行（`executable:false`）。**

### 5.2 多 domain（导航/音乐/外卖/新闻/体育/旅行/美食）

| Domain | 规范 ID | intent 枚举 | 核心 slot | connector |
|---|---|---|---|---|
| 导航 | `mapU` | NAV / QUERY / MODIFY | poi_keyword, poi_type, distance, rating, 经纬度, 起点 | MCP/mock |
| 音乐 | `musicAssistant` | SEARCH / LIST / PLAY / SCENE | singer, song, genre, mood, scene, play_action | 端侧播放器+曲库MCP/mock |
| 美食 | `foodie` | RECOMMEND / SEARCH / RESERVE | 区域, cuisine, price_avg, 榜单, 营业时间 | MCP/mock |
| 餐厅订座 | `reserve`(锁域) | RESERVE / QUEUE | restaurant_name, time, party_size(可缺→二次交互) | MCP/mock |
| 旅行规划 | `traveler` | QUERY | 目的地, 天数, 预算, 偏好, 行程范围 | LoRA骨架+POI MCP |
| 新闻 | `news` | QUERY | 大类+细分, 地点, 关键词, 来源, 条数 | MCP/mock |
| 体育 | `sports` | SEARCH / PLAY | 项目, 赛事, 球星, 球队, 赛程, 状态 | 实时MCP/mock |

### 5.3 tools.json 样例（可直接填）

两个车控核心 mock 工具：

```jsonc
{
  "query_vehicle_state": {
    "params": {"query_domains":["temperature","seat","steering","window","ambient","weather","season"]},
    "mock_return": {
      "ac_temp": 24,            // 17-32 硬上限
      "seat_heat_L": "OFF", "seat_heat_R": "LOW",   // OFF|LOW|MID|HIGH
      "steering_heat": "OFF", "steering_vent": "OFF",
      "season": "winter", "outdoor_temp": 8
    }
  },
  "execute_vehicle_control": {
    "params": {
      "commands": [{"control_object":"ac_temp","action":"SET","target_value":26}],
      "confirm_required": true   // 推荐模式=true, 执行模式=false
    }
  }
}
```

关键约束落 tools.json：空调温度 `target_value` 限 **17-32**；座椅/方向盘加热通风档位 OFF/LOW/MID/HIGH；ADAS/行驶安全 intent 标 `executable:false`；GUI=事实（只显示成功执行项，>3 项显前 3+"等"）；VUI 只播操作对象不播位置/参数；多轮传当前+历史 2 轮；端侧回复拼接模板「帮您%s了%s」。

---

## 6. FC 语义四级协议（Tool schema 母版）

源自「公版语义四级功能协议表」，是嵌套树而非扁平结构。**四级直接映射到 §4.1 Tool schema 的字段层级。**

| 级 | 字段映射 | 含义 | 例 | 在 Tool schema 中 |
|---|---|---|---|---|
| **一级 domain** | `service` | 业务域 / 技能落点 | `carControl` `mapU` `musicAssistant` | Tool.service / Capability.domains |
| **二级 category** | `category` | 域内功能簇 | `connection_setting` | Tool.category |
| **三级 sub** | (中/英双名) | 具体功能 | `open_bluetooth` | descriptor 内功能描述 |
| **四级 intent+赋值** | `intent` + 槽位赋值 | 带协议赋值的最终意图 | `打开蓝牙` vs `打开<蓝牙模式>` | Tool.intent + slotSpec |

四级映射规则：
- 一个三级功能按"说法变体"展开成多条四级，每条绑定一组固定/可变槽值。
- 取值（槽位 slots）是四级下的叶子：`<position#车窗位置>`（变量槽，`#`后为中文语义名）、`<value.ref:%ZERO>`（`%`=固定赋值）、`[...]`=可选包裹。
- 槽分必选/可选：可选槽落 `optional{}`，无值时不出现在最终 semantic（"打开车窗"→`{"slots":{}}`；"打开主驾车窗"→`{"slots":{"position":"主驾"}}`）。
- `operation` 枚举：`INSTRUCTION`(命令) / `SET`(设置) / `QUERY`(查询)。
- `value` 四件套结构体（连续量调节核心）：`ref`(CUR/ZERO/MAX) + `direct`(+/-) + `offset`(数值/LITTLE/MORE) + `type`(SPOT/PERCENT/EXP)。
- 易混淆硬规则消歧（disambiguation）：车窗开条缝(ref=ZERO)≠打开一点(ref=CUR)；音量调到 0≠静音；打开蓝牙≠连接蓝牙；"有点冷"与"空调调高一点"同 intent 但拆两个四级。

**端侧适配**：每个三级功能含泛化句式编码（~150 个，如 `activate_instant_device_or_function`）+ L1/L2/L3 句式层级，直接喂 Qwen3-0.6B+LoRA 做训练/few-shot；`生效场景` 字段从"云加端"改为端侧"本地"。

---

## 7. 快/慢思考路由 + 模糊说端状态三态推荐策略

### 7.1 快慢路由判据（按优先级短路）

| 信号 | 走快（规则/向量/0.6B 直出/端侧） | 走慢（0.6B+LoRA 多阶推理） |
|---|---|---|
| 句式 | 明确控制对象+动作+参数（"空调26度"） | 负向感受/比喻/场景+意图/反问/否定（"好冷""晒了一整天"） |
| 槽位完整度 | 实体+动作+值齐全 | 缺位置/缺值/需消歧 |
| 端状态依赖 | 不需要（声音垂域全程不依赖；断网兜底规则） | 需读端状态判三态再决策 |
| 意图数 | 单意图、简单"和"拼接 | 多意图夹噪/否定/上下文继承 |
| 网络 | 弱网/断网（MAformac 常态主路） | — |

工程铁律：能用"极值/枚举/数值直接比较"判定的端状态走快；"仅感知项（季节/天气/PM2.5）需推理出调节项"必走慢。延迟铁律 ≤2500ms → 慢思考 ReAct 循环 ≤3 轮。每条 Query 输出 `route: fast|slow` + 命中理由（演示讲解用）。

### 7.2 模糊说 → 端状态三态 → 推荐 策略链

端状态分三类判定：
1. **开关/名称类**（座椅通风 OFF/LOW/MID/HIGH）→ 名称匹配=满足，不匹配=不满足，直接执行目标态。
2. **数值类**（空调 17-32℃）→ 到极值=满足（无法再调），未到=调至目标。
3. **仅感知项**（季节/天气/车外温度，无法调）→ 永远不满足，从感知**反推**执行项。

完整链：模糊 Query → 落域 → 垂域识别 → 位置/部位/环境推理 → 读端状态 → 逐执行项判三态 →
- **全部已满足**：不执行，情感化兜底（"已经是舒服状态啦"）。
- **部分满足**：满足项不动，未满足项执行/推荐（自然回复）。
- **全部未满足**：生成完整推荐列表 → 用户确认 → 执行。
- **无法满足（已到极值/感知项无解）**：触发**二级推荐**（座椅加热已最低→座椅通风+空调+风量；车窗已关→空调循环；遮阳帘已关→温度+风量+吹风模式）。

推荐原则：符合人类认知、最快解决、不输出争议项；程度类只说"调大/调小"不报具体值；位置未指定→按说话人位置，无法判定→模糊回复+GUI 提示问位置。三态引擎实现为**纯函数（immutable，返回新决策对象）**，是离线核心可演示资产。

---

## 8. 记忆/指代/多轮 DialogueState 设计

**短时指代与长期记忆分开存。**

### 8.1 DialogueState 字段结构

```jsonc
DialogueState {
  context_id, anchor_id,
  anchor_type: "entity|intent|zone|list|device",
  locale: "zh-CN",                       // 端侧演示固定中文简化
  speaker_zone: "driver|passenger|rear_left|rear_right",
  topic_state: "active|suspended|replaced|expired",

  // —— 短时（滑动窗口 + 焦点栈）——
  last_exec: {device, action, value, mode, zone},   // 相对增量来源("再开30%""调高一点")
  list_ctx:  {result_version, candidates[]},         // 序数回指绑定结果版本
  recent_turns: [≤2 × {query, rewrite, intent}],     // 滑动窗口=2轮(超则 context rot 衰减>30%)
  topic_stack: {active_anchor, suspended_stack[]},   // 技能插入挂起主线, 强指代恢复

  // —— 长期（识人/关系网，与短时分离）——
  person_registry: [{account, zone?, relation?, anchor:"nickname|position"}],

  confidence: {rewrite, entity},
  safety_gate: "pass|clarify|block",
  provenance:  {turn, response_version}              // 只允许从历史锚点复制
}
```

短时 vs 长期分离理由：短时焦点栈 5min / 5 轮超时即清空（防 context rot）；长期 person_registry 跨会话保留（识人记人/关系网，由"小芳是我老婆"类强关键词触发）。**消除条件**：5min 动态超时 / 超 5 轮 / 歧义过高 → 回 S0 空状态。

### 8.2 指代消解 prompt 思路（先门控、再语义、最后回填）

1. **expire 检查**：超时/超轮 → 直接 NEW_TASK。
2. **话题关系判定**：`{same_topic, insertion, strong_backref, new_topic, ambiguous}`。insertion 时**不改写**（防"打开空调"被误改成"在银泰打开空调"）。
3. **候选锚点**：same→最近 active；strong_backref→搜 suspended stack；new→换锚点；ambiguous→澄清。
4. **指代→实体/音区回填**：代词、序数、多模指代（关系/衣着/座位）、椭圆恢复、实体 canonical 化。
5. **hard gate**：主题连贯 / 强指代 / 技能安全 / **音区安全（多用户"我也要"不继承相对音区）** / 置信度。
6. **红线**：改写只还原意图，绝不补历史中不存在的实体/音区/设备（否则进澄清）；只允许从 anchor 复制。

经典样例（演示锚）：「副驾通风打开 → 关了吧 → 给我开到三档」——Q2 继承副驾，Q3「给我」回主驾（指代切换）。

---

## 9. barge-in 状态机 + 可取消管线约束

barge-in = 全双工，是当前 38 repo 的**盲区**（无对口仓库，最接近 sherpa-onnx 的 VAD/KWS）。需自建。

### 9.1 状态机

```
        ┌─────────┐  唤醒词/VAD检测到语音  ┌──────────┐
        │ IDLE    │ ─────────────────────▶ │ LISTENING│
        └─────────┘                        └──────────┘
            ▲                                    │ ASR endpoint
            │ 完成播报/超时                        ▼
        ┌─────────┐  cancel(用户插话)      ┌──────────┐
        │ SPEAKING│ ◀──────────────────── │ THINKING │
        └─────────┘                        └──────────┘
            │  用户插话(VAD)                     │ cancel(用户插话)
            └────────────► CANCELLING ◀──────────┘
                              │ 取消令牌穿透 L1..L5, 丢弃在途帧
                              ▼
                          LISTENING (重新接管)
```

### 9.2 对各层的硬要求（可取消管线约束）

- **取消令牌（CancellationToken）必须穿透 L1..L5**：任意层（理解/路由/规划/安全/执行）产出帧时检查 token，被取消则立即丢弃在途帧、回滚未提交的 mock 状态。
- **L0 端点检测**：VAD/KWS 在 SPEAKING/THINKING 态持续监听，检测到用户插话立刻进 CANCELLING。
- **执行层(L5)幂等 + 可回滚**：CANCELLING 时已下发的 mock 命令需可撤销（immutable state 天然支持——丢弃新决策对象即可）。
- **TTS 分块可中断**：回复播报分块输出，插话即停，不等整句播完。
- **不卡 UI**：模型结构修复最多重试 1 次（车内交互不能卡），失败转 needs_clarification。

---

## 10. repo 采用映射（每能力 → 主选 ⭐ + 备选）

| 能力栈 | 主选 ⭐ | 备选 | 关键判断 |
|---|---|---|---|
| ① 端侧 runtime | `tattn/LocalLLMClient`(facade) + `ml-explore/mlx-swift-lm` | llama.cpp / mattt/llama.swift / swift-transformers / SpeziLLM | **runtime 抽象优先于选型**，业务层只依赖 `LLMBackend` 协议，runtime spike 排在 UI 大开发之前 |
| ② ASR/TTS | `argmaxinc/WhisperKit` | sherpa-onnx(ASR+TTS+VAD+KWS) / whisper.cpp / argmax-oss-swift | WhisperKit Swift-native 第一版主候选；离线唤醒/播报靠 sherpa-onnx |
| ③ 规则 NLU(快路径) | `OHF-Voice/hassil` | OHF-Voice/intents / dengky23/nlu-pipeline-vehicle / rhasspy | hassil 是 50ms 快路径蓝本，Swift 复刻迷你版（Python 不进 iOS） |
| ④ FC 评测 | `ShishirPatil/gorilla`(官方 BFCL) | tiny-tool-bench / Hammer / nexa-sdk | BFCL-CN 已弃用改官方；tiny-tool-bench 定"规则 vs 模型"分工边界 |
| ⑤ 结构化输出 | `dottxt-ai/outlines` | lm-format-enforcer / instructor / guidance | **全 Python，吸收概念不进 iOS**，Swift 端同构实现 |
| ⑥ MCP 接入 | `modelcontextprotocol/swift-sdk` | （唯一项） | 启发 ToolRegistry，首版不起 server，留 Mac+iPhone 拆分升级通道 |
| ⑦ 记忆 | **无 repo** | — | 靠 DialogueState + 本地 JSONL event log，非独立技术栈（盲区） |
| ⑧ barge-in/全双工 | **无 repo** | sherpa-onnx(VAD/KWS) / rhasspy(wake/VAD) | **38 repo 盲区，需自建**（见 §9） |
| ⑨ 车端信号协议 | `COVESA/vehicle_signal_specification` + `COVESA/vss-tools` | kuksa-databroker(mock车+验收) / vdm / vehicle-edge / autowrx / Canals / agent-tester | VSS 当内部命名法防"一个车窗三个名"；vss-tools 当开发期生成器，源是 `capabilities.yaml`，首版只生成 20-50 高频能力 |

**Codex 报告 11 条关键判断（必守）**：① runtime 抽象优先；② 规则吃 80%，模型只碰 20%；③ 小模型工具 ≤10 个/参数 ≤5，候选工具集由当前 UI 页面/车辆状态/关键词初筛；④ **安全检查必须是代码不是 prompt**，模型修复最多重试 1 次；⑤ 验收以读回 mock 车端状态为准（"模型说成功"不算）；⑥ 错误必须是枚举不是日志；⑦ few-shot/gold eval/微调三者数据合同同源，先写 100 条黄金样例；⑧ VSS 防一物多名，首版只 20-50 path；⑨ 明确删减 `vehicle-app-python-sdk` / BFCL-CN；⑩ Python 库零进 iOS；⑪ 记忆+barge-in 是盲区需自建。

---

## 11. eval 集 + 演示话术金句 + badcase 避坑 + demo 验收指标

### 11.1 演示高光话术金句（10 条，已通用化改写）

| # | 用户说（口语/模糊） | 演示亮点 |
|---|---|---|
| 1 | 「手好冷啊」 | 控制对象缺失 → 候选排序：方向盘加热/空调制热/座椅加热 |
| 2 | 「车里好闷啊」 | 一句多解：开窗/外循环/调风量，端状态裁决 |
| 3 | 「窗户开个小缝儿」 | 口语量词归一：小缝/一丢丢→10%，一拳头→20%，拉满→100% |
| 4 | 「窗户别全开」 | 否定 scope：不是"别开"，是"开到 50%"，否定方向反转 |
| 5 | 「我想看星星」 | 别名+组合 → 开天窗；「头顶有雨飘进来」→ 关天窗&关窗（复合） |
| 6 | 「这风跟没吃饭似的，开大点」 | 比喻+相对运算：风速 +1 挡 |
| 7 | 「副驾通风开 → 关了吧 → 给我开到三档」 | 三轮指代切换：Q3"给我"回主驾（经典指代消解） |
| 8 | 「打开全部车窗 → 副驾不用」 | 复合+否定排除：全开后关副驾 |
| 9 | 「外面低于10度就调21度」 | 条件型：条件→动作绑定 |
| 10 | 「热死了，快帮我降降温」 | 祈使句槽位缺失 → 快速制冷+关后窗组合 |

（备用：「给穿红衣服的美女开窗」=多模指代消解；「前挡起雾了看不清」=安全强执行除雾；「在哪调风向」vs「给我开空调」=页面查看 vs 真实控制分离防越权。）

### 11.2 eval 测试集组织

- **语料分桶（三档）**：标准说法（端侧直出，基准回归集）/ 模糊意图（功能名/行为/参数/复合 抽象）/ 自由说（人-感受/车-状态/环境-车外 OOS 高风险）。
- **评分三层（从严）**：意图准确率(FC name 选对)≥90% → 槽位 F1(落白名单)96-98% → **整句帧准确率**(意图+全槽全对，亮点演示按此验收)。
- **专项子集 + 数量**：单轮回归 ~40 FC（全量 100+ intent）；体验脚本 50 条（11 场景分类）；多轮金标准 12 条 Q 链（每条扩 20-50 变体）；多语种验证语言一致性。多轮必须双指标：整句帧准确率 + 多轮链路完成率，长程依赖/信息干扰/反悔撤销各自单独算分。
- **数据合同同源**：输入+上下文+工具定义+期望输出+错误标签，五者格式统一，喂 few-shot/gold eval/未来微调。

### 11.3 badcase 避坑

| Badcase | 根因 | 修复入口 |
|---|---|---|
| 端状态误绑定（"太烫了调低"误给空调，实为座椅加热） | 没读上一轮端状态 | 动作前先读对应端字段 |
| 多轮指代错位（"给我开到三档"裸继承副驾） | 缺 slot provenance | 每个继承槽保留来源标记 |
| 自由说硬执行（"车里好闷"直接单解执行） | 缺 OOS 拒识 | 候选排序+不确定路由 |
| 否定 scope 判错（"窗户别全开"当"别开窗"） | 缺 cue+scope 两步解析 | 否定单独算子，反转前判 scope |
| 安全域越权（"我有点分心"→强开 FCW） | 缺安全确认门 | 高风险先解释/确认 |
| 量词归一失败（"一拳头/一丢丢"未归挡） | 缺量词→数值映射表 | 固化映射表，不让模型自由发挥 |
| 页面 vs 真实控制混淆（"在哪调风向"直接改了） | 意图层未区分查看/执行 | "在哪/怎么"走页面，"开/关/调到"走执行 |
| 过度调控/连锁误执行（调音量顺手关灯光） | 一句触发多无关 FC | 限定动作集，无关域不动 |
| 关怀话术代替执行（"腰酸背痛"只回复关心） | 自由说退化成闲聊 | 自由说必须落候选动作或明确拒识 |

**多语种端侧实测 badcase 分布（真实信号，占比序）**：预期有 service 但实际为空(147) > service 误分(cbm_reply↔cbm_denial 80 / carControl↔vehicleInfo 59 / airControl↔vehicleInfo 23) > 接口超时/授权报错 > 语言错误（英文问题得中文回复）。**避坑：落域比意图细分更易错；查询类(vehicleInfo)与控制类(carControl/airControl)边界硬隔离；离线多语种守语言一致性。**

### 11.4 demo 验收指标（从量产 KPI 挑端侧相关）

| 指标 | 量产口径 | demo 保留值 |
|---|---|---|
| 端侧工具调用成功率 | 成功 ≥99% / 参数解析 ≥98% | **核心，FC 路由 demo 主指标** |
| 端侧意图理解准确率 | 本地识别 ≥90% | 落域+意图分别报 |
| 拒识准确率 | 闲聊无效话术拒识 ≥80%（总体 99%） | 自由说 OOS demo 必带 |
| 多轮对话 | 记忆准确率 ≥95% / 连贯性 ≥90% | 多轮指代 demo 锚 |
| 端侧响应速度 | 文本+图像 ≤3s；识人车控 ≤1400ms | 离线延迟卖点 |
| 端侧 Token 速率 | 生成 70 Token/s，Prompt 处理 2300 Token/s | 0.6B 可达，体现端侧可行 |
| 端侧资源占用 | CPU ≤2k DMIPS / 内存 ≤2.5GB / 磁盘 ≤8G | iOS/macOS 离线可行性证明 |
| 端侧稳定性 | 10 万次推理崩溃 ≤1 / 精度损失 ≤1% | 量产级可靠性 |

---

## 12. 锁定 / 待拍板 decisions 清单

| # | 决策点 | 状态 | 内容 / 选项 | 推荐 ⭐ |
|---|---|---|---|---|
| D1 | runtime 抽象先行 | 🔒锁定 | 业务层只依赖 `LLMBackend` 协议，runtime spike 排在 UI 大开发之前 | — |
| D2 | 规则/模型分工 | 🔒锁定 | 规则吃 80% 高频车控，模型只碰 20% 模糊表达 | — |
| D3 | 安全检查是代码不是 prompt | 🔒锁定 | 取值范围/速度/确认门由 executor 判定 | — |
| D4 | 验收以 mock 车端状态读回为准 | 🔒锁定 | "模型说成功"不算成功 | — |
| D5 | 错误用枚举 | 🔒锁定 | decode_failed/unknown_tool/invalid_argument/unsafe_action/needs_clarification | — |
| D6 | 工具数上限 | 🔒锁定 | 首版 ≤10 工具 / 参数 ≤5，候选集由 UI+状态+关键词初筛 | — |
| D7 | Python 库零进 iOS | 🔒锁定 | outlines/hassil 等只吸收范式，Swift 同构实现 | — |
| D8 | VSS 当内部命名法 | 🔒锁定 | 首版只生成 20-50 高频 path，源 `capabilities.yaml` | — |
| D9 | DialogueState 短时/长期分离 | 🔒锁定 | 短时 5min/5 轮清；长期 person_registry 跨会话留 | — |
| D10 | 多轮窗口大小 | 🔒锁定 | recent_turns = 2 轮（超则 context rot >30%） | — |
| D11 | barge-in/记忆是盲区需自建 | 🔒锁定 | 38 repo 无对口仓库 | — |
| D12 | 首版垂域范围 | 🟡待拍板 | A) P0 四垂域全做 / B) 只温度主线先跑通 | **A**（差异化叙事完整，温度做主线 Demo） |
| D13 | barge-in 首版是否进 demo | 🟡待拍板 | A) 首版做全双工打断 / B) 首版纯轮替对话，barge-in 二期 | **B**（盲区自建成本高，首版"反应快/不崩"优先于全双工；二期补） |
| D14 | ASR runtime 选型确认 | 🟡待拍板 | A) WhisperKit / B) sherpa-onnx 全家桶 | **A**（Swift-native 贴 Apple Silicon；离线唤醒缺口再引 sherpa-onnx 模块） |
| D15 | 首版语音 vs 文本输入 | 🟡待拍板 | A) 直接上 ASR 语音 / B) 首版文本输入兜底，语音二期 | **B**（先把语义层 5 分钟炸场跑通，ASR 是独立风险项，可后置） |
| D16 | MCP 真接 vs 全 mock | 🟡待拍板 | A) 导航/音乐真接 MCP / B) 全 mock connector 喂结构化卡片 | **B**（北极星=断网也能跑，演示阶段 MCP 真连违背离线，全 mock 同构后续切换） |
| D17 | 多模指代首版是否做 | 🟡待拍板 | A) mock 视觉结果注入做指代 demo / B) 二期 | **A**（"给穿红衣美女开窗"是高光金句，视觉输入 mock 成本低，强烈建议进首版） |
| D18 | 慢思考 ReAct 轮数 | 🟡待拍板 | A) ≤3 轮 / B) ≤2 轮（更激进保延迟） | **A**（≤3 轮契合 ≤2500ms 铁律，留一轮容错） |

### 12.1 磊哥裁决（2026-06-17 锁定）

| # | 最终裁决 | 关键澄清 |
|---|---|---|
| D12 | 🔒 四垂域**全做、全是主线**，温度作 **MVP 切入点** | 不是"只温度先跑"，温度是起步不是唯一；四垂域都要 |
| D13 | 🔒 折中：首版**按钮打断**（按 mic 停 TTS），VAD 免按全双工二期 | 满足"播报时能打断"，避开全双工盲区 |
| D14 | 🔒 WhisperKit | Swift-native 贴 Apple Silicon |
| D15 | 🔒 **文本先行(开发顺序) + ASR 必交付(不砍)** | 文本先把语义层/三态/多轮调通；ASR 结果**必须有**，紧随文本接入，非二期砍掉 |
| D16 | 🔒 全 mock；**端状态/反馈 = UI 按钮亮暗 + TTS 回复 模拟**（无外部系统方喂端状态）；座舱车机固定动画=可选增强(待定) | MAformac 的"端状态"= UI 自己维护的卡片亮/暗/档位，完全自包含 |
| D17 | 🔒 做（mock 视觉指代，"给穿红衣美女开窗"金句） | 视觉输入 mock，成本低 |
| D18 | 🔒 ≤3 轮 | 契合 ≤2500ms，留一轮容错 |

**D16 设计含义（端状态自包含，重要）**：既然没有外部系统方提供端状态，MAformac 的"端状态"= UI 卡片当前态（亮/暗/档位数值），由 app 自己维护。执行闭环：`query_vehicle_state` 直接读 UI store → 三态判定 → `execute_vehicle_control` 直接改卡片亮暗 + 触发 TTS 播报。这反而让"我冷→查端状态→推荐"链路完全可控、断网可演。可选的座舱车机固定俯视图（卡片点亮时对应区域高亮，呼应 Voice Assistant 面板）作为视觉增强，待定不阻塞。

**D15 开发顺序含义**：语义层（理解/三态/多轮/FC）用文本输入快速迭代 → 跑通后接 WhisperKit ASR（必交付）→ 再加 push-to-talk + 按钮打断。ASR 不是"二期可选"，是"开发排序靠后但必做"。

---

> 本蓝图严格守边界：全文「某车厂」，无真实客户名/报价/密钥/PII/对内禁外传原文。
> 源料溯源（仅供内部回查，不外传）：复杂车控FC走查与亮点脚本资产 / 多阶车控Badcase数据分析 / 多语种上下文继承与跨轮逻辑 §6.7-6.8 / 领域分类规范边界定义 / 智能体集成协议清单 / 38-repo Codex 深度研究报告。
