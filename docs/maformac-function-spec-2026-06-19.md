# MAformac 功能清单 + 语义协议表 v0(草案)

> **定位**:MAformac demo 自己的**功能清单 + 语义协议事实源**,维度参考 4 份金钥匙(`baseline-semantic-protocol-2026-06-19.md`),叠加 MAformac 特有(mock 态/readback/R级)。**后续 = E2E 测试基线**(每个四级功能 → 一组 E2E case)+ `contracts/capabilities.yaml` 升级蓝本。
> **状态**:v0 草案。**设备选型 / 取值范围 / 步长 / 收敛粒度待磊哥校准**(基座 3900 intent,demo 必须收敛)。
> **红线**:协议范式抽象自某车厂基座(只读),本清单是 MAformac 自有重写,不含客户标识/原文语料。

## 1. 维度设计(参考金钥匙列 → MAformac 功能清单列)

| MAformac 列 | 来源金钥匙列 | 说明 |
|---|---|---|
| `capability_id` | (MAformac 新增) | 如 `cabin.ac` |
| `service` / `二级` / `三级` | 编辑版 col1/2/4 | 四级语义结构 |
| `四级功能(intent_zh)` | 编辑版 col15 | 中文功能名 |
| `intent` | DS协议内 | 英文 intent |
| `action_code` | 编辑版 col21 功能类型编码 | **归一化动作**(demo 子集见 §3) |
| `ds_slots`(含 `value` 四件套) | 编辑版 col16 DS协议 | `{ref,direct,offset,type}` |
| `range` | 编辑版 col17 取值范围 | 枚举 + 数值范围 + **demo 步长** |
| `position` | 编辑版取值范围 | demo 收敛:主驾/副驾/全车 |
| `示例说法` | 编辑版 col20 | 首轮语料 |
| `FC模糊/自由` | 编辑版 col30/31 | **路由分流标记** |
| `二次交互` | 二次交互清单 col4-7 | 可继承 + 次轮说法 |
| `优先级` | 打点表 col6 | demo 选型 |
| **`mock_state_cell`** | MAformac 新增 | 落哪个端态 cell |
| **`readback_zh`** | MAformac 新增 | 读回播报话术 |
| **`risk(R0-R3)`** | MAformac(承接 D-决策) | 安全门 |
| **`e2e_baseline`** | MAformac 新增 | 输入→期望DS→期望态→期望readback |

## 2. MAformac 语义协议范式(收敛自基座 7 要素)

- **四级结构**:`service → 二级 → 三级(设备+动作) → 四级(intent+slots)`。
- **value 四件套**:`{ref:CUR|ZERO|MAX, direct:+|-, offset:数值|LITTLE|MORE|MAX|MIN|HIGH..LOW, type:SPOT|PERCENT|EXP}`。
- **参数规划三态**:绝对(`to_number`,ZERO,直接赋值)/ 相对(`by_number`,CUR,读端态±offset)/ 经验(`by_exp`,LITTLE·MORE,读端态±**步长表**)/ 极值(`to_max·min`,置 range 边界)。
- **安全门两类**:① `forbidden` 内容拦截(脏话/色情/涉政 → 统一拒识,**不下发业务**)② `restraint` 意图克制(「不要开空调」→ 拒识,归 intent-routing)。
- **多轮**:`last_frame` + 二次交互矩阵 → 槽继承 + query rewrite。

## 3. 收敛动作集(MAformac demo 子集:基座 ~114 编码 → 12 个)

| MAformac action_code | 基座编码 | value 模板 | 触发说法 |
|---|---|---|---|
| `power_on` / `power_off` | activate/deactivate_instant_device | — | 打开X / 关闭X |
| `increase_by_exp` / `decrease_by_exp` | increase/decrease_value_little | `{CUR,±,LITTLE,EXP}` | X调高/低一点·有点冷·太冷了(MORE) |
| `increase_by_number` / `decrease_by_number` | increase/decrease_value_by_specific_value | `{CUR,±,N,SPOT}` | X调高/低N度·N挡 |
| `adjust_to_number` | adjust_value_to_specific_value | `{ZERO,+,N,SPOT}` | X调到N度·N挡 |
| `adjust_to_max` / `adjust_to_min` | adjust_value_to_max/min | `{ZERO,+,MAX/MIN,EXP}` | X调到最高/最低 |
| `adjust_to_gear` | adjust_value_to_gear | `{ZERO,+,HIGH/MIDDLE/LOW,EXP}` | X调到高/中/低挡 |
| `set_color` / `set_mode` | switch_color / open_mode | `{color/mode}` | 换X颜色·X模式 |
| `query` | check_status_or_information | — | X多少·查X |

> 每个设备 × 适用动作 = 该设备的 intent 集。**这取代我之前"每设备一个平铺 set_X tool"的错**。

## 4. demo 设备清单(选型草案:8 设备 + 安全门)

| capability_id | 设备 | service | mock_state_cell | 适用动作 | range(待校准) | R级 | 优先级 | 炸点 |
|---|---|---|---|---|---|---|---|---|
| `cabin.ac.power` | 空调开关 | airControl | `hvac.ac` | on/off | on/off | R0 | 高 | 听懂直说 |
| `cabin.ac.temperature` | 空调温度 | airControl | `hvac.temperature` | by_exp/by_number/to_number/to_max/min/to_gear/query | **18–30℃**·步长1 | R0 | 高 | **有点冷→升温·调高一点 vs 调到26** |
| `cabin.ac.fan` | 空调风速 | airControl | `hvac.fan` | by_exp/by_number/to_number/to_max/min/to_gear | **1–7 挡**·步长1 | R0 | 高 | 风太大了 |
| `cabin.ac.mode` | 空调模式 | airControl | `hvac.mode` | set_mode | 制冷/制热/自动/除雾 | R0 | 中 | 制冷 |
| `cabin.seat_heat` | 座椅加热 | carControl | `seat.{pos}.heat` | on/off/by_exp/to_number/to_max/min/to_gear | **0–3 挡** | R0 | 高 | 座椅加热调高一点 |
| `cabin.seat_vent` | 座椅通风 | carControl | `seat.{pos}.vent` | on/off/by_exp/to_number/to_max/min | **0–3 挡** | R0 | 中 | 夏天闷·通风 |
| `cabin.seat_massage` | 座椅按摩 | carControl | `seat.{pos}.massage` | on/off/set_mode/force_by_exp | 模式集·强度0–3 | R0 | 中 | 按摩·波浪模式 |
| `cabin.window` | 车窗 | carControl | `window.{pos}` | on/off/to_number(percent)/by_exp/开条缝 | **0–100%** | **R1** | 高 | 副驾开窗·开一半 |
| `cabin.ambient` | 氛围灯 | carControl | `lighting.ambient` | on/off/set_color/set_mode | **color 开放词**(蓝色/星辰大海…)/模式 | R0 | 高 | **大海颜色→星辰大海** |
| `cabin.screen` | 屏幕亮度 | cmd | `screen.brightness` | by_exp/by_number/to_number/to_max/min/to_gear | **0–100%** | R0 | 中 | 太亮了头疼 |
| `cabin.comfort_query` | 舒适查询 | airControl | (read-only) | query | — | R0 | 中 | 现在几度 |
| `safety.forbidden` | 内容拦截 | forbidden | — | 拒识 | 脏话/色情/涉政 | — | 高 | 安全感 |
| `safety.restraint` | 意图克制 | (intent-routing) | — | 拒识 | 不要开/已经够了 | — | 高 | 该忍住时忍住 |

> position demo 收敛:`主驾|副驾|全车`(基座几十种 → demo 3 种);温度/档位数值范围**待磊哥按真实车型校准**(基座用 `<摄氏度>`/`<挡位>` 开放占位,不写死)。
> ⚠️ **§4 这张表不是"demo 全部能力",只是 L1 精做子集 — 见 §5。客户会随意说全集 2655+,语义理解必须覆盖全集,不能只做这 8 个。**

## 5. 客户随意体验 → "不丢脸"架构(核心:LoRA + 广听懂 + 优雅兜底)

**问题(磊哥 2026-06-19 点明)**:客户现场**随意说**,会说 carControl 2655 / cmd 512 / airControl 51 全集里任何一个,**甚至超出**(导航/音乐/闲聊)。只做窄子集 mock → 客户说「打开天窗 / 座椅按摩波浪模式 / 方向盘加热 / 香氛调浓一点」,模型不懂、答非所问、或崩 = **丢脸**。

**解法:语义理解【广覆盖】+ mock 执行【分层】**

- **语义层(广覆盖 = LoRA 的核心价值)**:LoRA + 规则 NLU + FC 泛化层让 Qwen3-1.7B 听懂**全集 2655+** → 正确 `service / intent / value 四件套`。1.7B 默认背不下这套协议,**LoRA 把基座 col20 示例说法 + col30/31 FC模糊说·自由说 + DS协议 fine-tune 进去**,泛化听懂"客户随便说/方言/省略/模糊" → 正确语义。**这就是 CLAUDE.md「LoRA 必做(练模糊说→跨域映射)」的真正原因。**

- **mock 执行分层**:

| 层 | 范围 | demo 表现 | 成本 |
|---|---|---|---|
| **L1 精做炸点** | ~8–12 高优先级设备(空调/座椅/氛围灯/车窗/屏幕,§4) | 精美卡片 + 端态变化 + readback + **多轮 + 参数规划可视化** | 高(精做) |
| **L2 通用 mock 兜底** | 其余 **2600+** 听懂的车控功能 | 听懂 intent → 通用「已为您<动作><设备>」卡片 + readback,**mock 假装支持、不崩** | 低(通用模板) |
| **L3 越界优雅** | 导航/音乐/闲聊(二期 MCP) | 「这个稍后接入,现在能帮您控车」优雅延后 | 低 |
| **L4 安全门** | forbidden(脏话/色情/涉政)+ restraint(不要开/已经够了) | 优雅拒识,不乱执行 | 中 |

- **关键:不丢脸 = 广听懂(LoRA)+ 优雅响应(L2 通用 mock 兜底)**,不是窄实现。**因为是 mock**,L2 成本极低(一个通用卡片模板 + readback),却让"客户随便说都有体面响应"。真正精雕 UI 的只有 L1 炸点。

**功能清单全集定位(重新校准)**:本清单 = MAformac **语义协议全集**(对齐基座可听懂范围),三重用途:
1. **LoRA 训练 + 评测语料源**(示例说法 + FC 说法 + value 协议)。
2. **E2E 测试基线**:测「客户随便说 X → 正确 intent/value + 不崩 + 优雅响应」。
3. **L1/L2/L3/L4 分层标注**(哪些精做、哪些通用兜底)。

**E2E "不丢脸" 测法**:从全集采样客户随意说(L1/L2/L3/L4 + 越界 + 方言/模糊/省略/多轮),断言:① 正确解析 intent/value ② **不崩** ③ L1 改对端态+readback / L2 优雅兜底卡片 / L3 优雅延后 / L4 拒识。**全集覆盖率 = 不丢脸的量化指标**(这是 demo 验收死门,不是只测 8 个)。

**全集工件(已系统解析,待沉淀进仓)**:carControl 398 设备/975 intent + airControl 16/51 + cmd 257/512(`/tmp/digest/_设备全景_*.txt`)。脱敏入仓:只留 intent 协议骨架,原始中文语料 LoRA 训练用、**不入仓**(红线)。
