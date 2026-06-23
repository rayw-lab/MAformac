# MVP 10 族 device 边界归属（G4，2026-06-22）

> 🔴 **口径终拍（磊哥 2026-06-23 亲自决策，全仓唯一权威）**：本文 §1 per-family 表 / §2 族外 / §4 G2 的 **intent=562 / 行=2159 / 54.1%**（及族外 976 intent / 1831 行）= **磊哥 2026-06-23 亲拍权威口径**（取 A1-A9 边界歧义裁决【前】的 explicit-allowlist 全集；§3 九歧义点为推导溯源）。**534 系列（534 intent / 2086 行 / 52.3% / 族外 1004 intent / 1904 行）全作废**——534 vs 562 仁者见仁（534=A1-A9 后 GLM `execute_code` 移出若干边界 intent；562=A1-A9 前 explicit allowlist 全集），磊哥不纠结、亲自拍 **562** 终结纠结（source: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:222-235` §14 口径终拍）。device 数 191 不变（A4 方向盘加热并座椅为展示层，技术 device 不变，paradigm §13）。**正文 562/2159/976/1831 = 权威，旧 534 系列引用作废。**

> **任务**：解决「10 族 device 前缀归属未定义」——CC jq 得 422 intent vs GLM 得 397 不一致，根因 = 各拍各的正则（substring/prefix），device 归属没严格定义。本文按**语义归属**逐个定 device 边界，作 A1 SSOT 对账前置 + G2 工具数 tradeoff 的输入。
>
> **一手源**：`contracts/semantic-function-contract.jsonl`（3990 行 / **671 unique device** / **1538 unique intent**；字段 device/intent/service/action_primitive/range）+ raw `~/workspace/raw/01-Wiki/座舱/多阶车控端状态能力打点矩阵.md`（P0/P0-1/P0-2 分级 + Part VI「能力分组」line 159-175）。
> **脱敏**：只抽象 device 归属结构，不复制原文话术语料；客户公司统一「某车厂」。
> **claim-vs-reality**：每族 device 清单从 3990 实际 grep（python，非凭印象）；归属用 explicit allowlist（非 substring 正则），无 device 双归属、无 false positive。

---

## 0. 根因：为什么 422 ≠ 397

naive prefix/substring 正则会吸入 false positive：
- `^ac` → 误吸 `accelerator_anti_false_step` / `account_list` / `acoustics_mode`（非空调）
- `door`（substring）→ 误吸 `vehicle_refrigerator_door` / `outdoor*` 类
- `^light` / `interior` / `backlight` → `interior_heat`（=扶手/扶手箱加热，**非灯光**）、`backlight_brightness`（屏幕背光）归属摇摆
- `sunshade` vs `sunroof` 是否同族、`volume_mute/current_volume` 是否计入音量族——正则口径差异

实测：naive 正则 dev=126 / intent=439；本文 explicit 语义归属 dev=191 / intent=562（磊哥 2026-06-23 亲拍权威，见文档头）。**差异全在边界 device 的归属判定，不是数据本身**。

---

## 1. 10 族 device 归属表（语义归属，每族带规则）

| 族 | device 数 | intent 数 | 行数 | 归属规则（语义逻辑，非正则） |
|---|---|---|---|---|
| **空调 ac** | 25 | 68 | 212 | HVAC 主舒适链：`ac*`（温度/风量/风向/制冷制热/模式/界面）+ 风口 airoutlet + 除雾除霜除湿 defog/defrost/dehumidification + 循环 loop + 分区同步 zone_sync + 个性化 + 通风加湿净化消毒 ventilation/humidifier/air_clean/cabin_disinfect + 延时关闭/减风量。**排除** accelerator/account/acoustics（`^ac` 假阳性） |
| **座椅 seat** | 36 | 126 | 696 | `seat*` 全集（位置/靠背/坐垫/腰托/腿托/肩托/脚托/加热/通风/按摩/记忆/折叠/安全带）+ 头枕总成 headrest*（音响/方向/耳片，属座椅头枕硬件）。**排除** console_*（中控扶手非座椅，见歧义点） |
| **车窗 window** | 11 | 27 | 82 | `window*` + 后窗 back_window + 远程控制 remote_control_window + 自动升降 automatic_window_* + 风挡加热 windshield_heating（玻璃面，含前后挡风） |
| **车门 door** | 21 | 48 | 129 | 开闭/锁体：door/car_door/门高/门速 + 儿童锁/中控锁 child/central_lock + 锁模式 lock/unlock_mode + 前舱盖 engine_hood + 油箱盖 fuel_tank_cap + 手套箱 glove_compartment + **尾门 tailgate***（电动尾门/高度/感应/开启上限）+ 舒适进出 comfortable_entry_exit |
| **灯光氛围 light** | 29 | 113 | 468 | 氛围灯 atmosphere_lamp*（亮度/速度/颜色/模式）+ 指定车内外灯 designative_in/out_car_lamp*（亮度/色温/角度/时段）+ 调光天幕玻璃 dimming_glass_top*（亮度/颜色/透明度）+ 光效 light_show/game/expression/theme/sensor + 行李架灯 illuminated/luminous_luggage_rack + 顶棚 headliner + 照明启动开关。**排除** interior_heat（扶手加热非灯，见歧义点） |
| **屏幕 screen** | 33 | 75 | 205 | `screen*`（亮度/旋转/清洁/色彩/分屏/缩放/录屏/护屏）+ 分屏 split_screen* + 横屏 landscape + 旋转 rotate_screen* + 显示亮度界面 + 仪表屏 instrument_screen + 壁纸/主题/桌面 wallpaper/theme*/desktop_mode/auto_theme（**screen_type 槽=屏幕皮肤**）+ 防蓝光 blue_ray_filtering + 触摸屏 touch_screen |
| **音量 volume** | 11 | 32 | 153 | `volume*`（主音量/平衡/外放/渐入渐出/模式）+ 静音 volume_mute/unmute + 查询 current_volume + 响度 loundness + 噪声音量补偿 noise_volume_compensation*。**排除** driving_sound_wave_volume（行车声浪，归语音/媒体，见歧义点） |
| **雨刮 wiper** | 8 | 27 | 80 | `wiper*`（速度/灵敏度/模式/维护/喷水/界面）+ 雨量传感器 the_rain_sensor |
| **天窗遮阳帘 sunroof+sunshade** | 10 | 30 | 102 | 天窗 sunroof*（滑动/倾斜/呼吸/加热/通风模式）+ 遮阳帘 sunshade*（滑动）+ 遮光玻璃 blocking_glass + 车膜透明度 car_film_transparency（同属顶部/玻璃遮阳光学件） |
| **香氛 fragrance** | 7 | 16 | 32 | `fragrance*`（强度/模式/时段/界面）+ amount_of_fragrance + mode_of_fragrance（同义异名 device） |
| **10 族合计（去重 UNION）** | **191** | **562** | **2159** | 671 device 中 191 进 10 族（28.5%），2159/3990 行（**54.1%**，磊哥 2026-06-23 亲拍权威）|

> intent 计数说明：表内各族 intent 为该族 device 的 intent 并集；10 族 UNION intent=562（族间 intent 不重叠，naive 加和 562=UNION 562）。🔴 **562/2159/54.1% = 磊哥 2026-06-23 亲拍权威口径**（取 A1-A9 前 explicit allowlist 全集；旧 534/2086/52.3% 系列作废，见文档头 + paradigm §14:222-235）。下方 per-family 各族 intent/行数为族归属推导溯源，合计以权威口径 562 为准。

---

## 2. 族外 device（demo 不挂，归 unsupported tier）

**族外 = 480 device / 1831 行 / 976 intent**（671-191=480；= 全集 1538-562 intent / 3990-2159 行，磊哥 2026-06-23 亲拍权威，paradigm §14:231）。🔴 旧 1904 行 / 1004 intent 系列（A1-A9 后 534 口径）作废。大类（按 device 数）：

| 大类 | device 数 | 说明 |
|---|---|---|
| 智驾/巡航/泊车 | 112 | autopilot*（变道/记忆领航/靠边/超车）、NOA、cruise、park_in/out、lane_keep、ALC/TLC/CTA/AEB/TSR/LDWS、盲区/碰撞/疲劳/分神监测、360环视、流媒体后视镜 |
| 未分类其他 | 90 | 杂项小功能（祈祷提醒/优惠券/积分/保险/车色车型/字符等长尾） |
| 能量/充电/电池 | 49 | charging*、energy*、soc_target、电池预热、外放电、定时充电、能耗单位 |
| 系统/账户/网络 | 49 | system_update、login、wifi/hotspot/bluetooth、人脸/声纹、网络设置、恢复出厂 |
| 语音/交互/智能体 | 43 | voice_*、wakeup、llm、虚拟形象、声场/音源、EQ/ANC、对话风格、方言切换 |
| 底盘/驱动/转向 | 41 | suspension*、steering_wheel*（含加热/通风）、EPS/ESC、差速锁、电动尾翼、驾驶模式、**console_*** |
| 通话/媒体/录像 | 29 | call/calls、拍照/录像/截图、行车记录仪、相册、手势拍照 |
| 安全/监测/提醒 | 25 | monitor*、安全带振动/预紧、安全气囊、烟雾/生物遗忘检测、紧急呼叫、胎压 |
| 设置面板/通用 | 20 | *_set_interface（设置入口）、用户手册、反馈 |
| HUD/仪表 | 13 | hud*（亮度/高度/倾角/内容/位置）、仪表显示内容、里程显示 |
| 香味/冰箱/其他舒适 | 7 | vehicle_refrigerator*、interior_heat、steering_wheel_heating/ventilation、seat_belt_heat、nozzle_heat、humidifier(已入空调) |

> demo 取舍：10 族 = MVP 精做 + 泛化承接（L1+L2）；族外 480 device → L3 越界兜底/unsupported tier（mock 通用「该功能演示版未覆盖」+ 安全拒识），**不挂精做**。

---

## 3. 边界歧义点（A1-A9 已磊哥拍，下列为推导溯源历史态）

> 🔴 **状态更新（finding round-01）**：A1-A9 九个歧义点**已磊哥拍板**（见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` §13「A1-A9 device 边界裁决」）。下列各条是**推导溯源历史态**（拍板前的「当前归属 + 备选 + ⭐建议」），**勿据此推进**；以 paradigm §13 终裁为准。
> 每条给「当前归属 + 备选 + ⭐建议 + 量化」（拍板前态）。这些 device 的归属直接影响 A1 SSOT 工具数 / 各族 intent 数。

**Q-A1 `interior_heat`（40 行/10 intent，range=扶手|扶手箱）**
- 实际语义=**扶手/扶手箱加热**（与方向盘加热、安全带加热同类「其他内饰加热」），非灯光。
- 当前归属：**族外**（已从 light 移出）。备选：归座椅族（扶手属座椅周边）。
- ⭐ **族外**（扶手加热不是 MVP 10 族任一核心；归座椅会污染座椅族语义）。

**Q-A2 `volume_mute`/`volume_unmute`/`current_volume`（各 6 行）**
- 当前归属：**音量族**（静音/取消静音/查询当前音量=音量直接操作）。
- ⭐ **归音量族**（语义就是音量；demo「静音」「现在音量多少」是高频）。

**Q-A3 `driving_sound_wave_volume`（4 行）+ driving_sound_wave/mode（行车声浪）**
- 当前归属：**族外**（声浪=电动车模拟引擎声，属语音/媒体声效，非主音量）。
- ⭐ **族外**（声浪是边缘特性，不进音量精做；若磊哥要可单独 L2 承接）。

**Q-A4 `steering_wheel_heating`（18 行/10 intent）/ steering_wheel_ventilation（2 行）**
- 🔴 **已拍（paradigm §13 A4，磊哥单挑）**：**demo 展示层归座椅「舒适」子域联动**（客户「我冷了」感知接触面不分座椅/方向盘），**技术层仍独立 device + 工具名（不脏）** → **device 数 191 不变**（展示层并入非技术 device 合并）。
- ~~（拍板前历史态）当前归属：族外；备选归座椅族；⭐族外~~ → 已被 §13 A4 终裁 supersede。

**Q-A5 `hud_brightness`/`hud_height`/`hud_display_content` 等 hud*（共 13 device）**
- 当前归属：**族外（HUD 独立类）**。备选：hud_brightness 归屏幕族（都是显示亮度）。
- ⭐ **族外独立 HUD**（HUD 是抬头显示独立子系统，与中控屏物理分离；混入屏幕会让屏幕族语义不纯）。

**Q-A6 `backlight`/`backlight_brightness`/`button_brightness`（共 79 行）**
- 实际语义=**按键/物理背光**（cmd service，非屏幕显示）。当前归属：**族外**。备选：归屏幕族（亮度类）或灯光族（背光=灯）。
- ⭐ **族外**（按键背光既非屏幕显示也非氛围灯，是物理按键照明；归任一族都污染语义。若要可独立「背光」微类）。

**Q-A7 `console_moving`/`console_position`（中控扶手/中控台移动）**
- 当前归属：**族外（底盘/驱动类）**。备选：座椅族（中控扶手与座椅同区）。
- ⭐ **族外**（中控台是独立机械件，非座椅；已从座椅移出）。

**Q-A8 `windshield_heating`（4 行，风挡加热）vs nozzle_heat（4 行，前后喷嘴加热）**
- 当前归属：windshield_heating→**车窗族**（玻璃面加热=除雾视野，靠近雨刮/除霜语义）；nozzle_heat→**族外**。
- ⭐ 保持现状（windshield_heating 归车窗合理；nozzle_heat=喷水嘴加热属雨刮辅助，但量小留族外）。可选：两者都归雨刮/除雾「视野安全」族（但 MVP 10 族无此族）。

**Q-A9 `theme`/`wallpaper`/`desktop_mode`/`automatic_theme_switching`（屏幕皮肤）**
- 当前归属：**屏幕族**（screen_type 槽，作用对象=屏幕）。备选：族外（主题=系统外观非屏幕硬件）。
- ⭐ **归屏幕族**（带 screen_type 槽，语义=指定屏换皮，与 screen_brightness 同对象；demo「把中控屏换成科技主题」自然）。

---

## 4. 对 A1/G2 的输入结论

- **A1 SSOT 对账**：10 族 device 归属已 explicit allowlist 化（本文 §1 各族 device 清单 = 可直接喂 codegen 的 SSOT seed），消除 jq/GLM 正则口径分叉。建议 A1 验证器用本文 device allowlist（非正则）做族归属断言。
- **G2 工具数 tradeoff**：若一族=一工具 → 10 工具覆盖 191 device / 2159 行（**54.1%** 全集行数，磊哥 2026-06-23 亲拍权威）；族外 480 device 走单一 unsupported/L3 工具兜底。10 族 intent=**562**（磊哥 2026-06-23 亲拍权威，旧 534 系列作废），远超 demo 精做 ~10 case，靠 LoRA 泛化承接族内、规则 L1 精做高频。🔴 **工具数本身未拍，待 value-form 实算（562=intent 非工具数）**。
- 🔴 **已拍（finding round-01 更新）**：9 个歧义点已磊哥拍板（paradigm §13 A1-A9）。**device 数 191 不变**——A4 方向盘加热为**展示层**并座椅（技术 device 独立不合并，故不 +1）；A5 HUD 不做（族外）；其余按 §13 终裁。~~（历史推导态）最大波动：steering_wheel_heating 若并入座椅 +1 device/+10 intent~~ 已被 A4「展示层并座椅·技术 device 独立」终裁 supersede，191 不变（见本文头 + §3 Q-A4）。

---

*生成：python 复算 `contracts/semantic-function-contract.jsonl`（3990 行实跑，非凭印象）；归属 explicit allowlist，overlap=0 已验证。*
