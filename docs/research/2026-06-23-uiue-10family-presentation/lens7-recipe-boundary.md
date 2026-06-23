# Lens 7 — 配方 best-practice + 边界特殊性

> 主线程亲调（workflow w3q9qdisd 本路 rate-limited，磊哥令亲自补 + 按 workflow 存档纪律落档）。focus = 10 族×语音驱动×5min 炸场的展示配方 + 异构值可视化 + 现场边界。

## summary

10 族的**异构值形态**（温度连续/档位/RGB/开度%/多维座椅/开关）各有对口 SwiftUI 控件，**无一需新造**：连续值→`Gauge` 环形（lens4），RGB→`ColorPicker`/色环，多维座椅→7 级分段（对齐真实 OEM）。炸场配方 = **全景 dim 网格 → 语音触发 matchedGeometry morph 聚焦 + 多族卡 stagger reveal + breathe**。边界（现场只说 10 族）= 族外 unsupported 走 tokens `blocked_hard` 灰锁优雅拒识（**非崩**），与 clarify(琥珀)/safety(红) 四态分开（U10）。

## findings（逐条带 source）

### F1. 🔴 10 族异构值 → 控件映射表（recipe 核心，解 fork3 值形态）
| 族 | 值形态 | 控件配方 | source |
|---|---|---|---|
| 空调 | 温度 18-32℃(连续) + 风量 1-10(档) | `Gauge(.accessoryCircular)` 温度环(中心℃+gradient tint) + 风量小分段/弧 | lens4 Gauge |
| 座椅 | 加热×通风×按摩(多维) | **7 级分段(3通风+off+3加热)** `Inxel/CustomizableSegmentedControl`(图标+voiceover) + 按摩独立 toggle | [Inxel repo](https://github.com/Inxel/CustomizableSegmentedControl) + 真实 OEM 7 级([heatseatswitch](https://heatseatswitch.com/ventilation-and-heating-control-system/)) |
| 车窗 | 开度 0-100% × 4 门 | `Gauge(.accessoryCircularCapacity)` 开度环 ×4(主驾/副驾/左后/右后) | lens4 Gauge |
| 车门 | 开/关/锁 | SF Symbol 态切 + tokens 色(满足 cyan/未激活 dim) | tokens.md |
| 灯光氛围 | RGB 颜色 + 亮度 | **色环** native `ColorPicker(supportsOpacity:false)` 或 `hendriku/ColorPicker` ColorPickerRing(纯SwiftUI) / `Priva28/SwiftUIColourWheel`(AngularGradient 360hue) + 亮度 Gauge；真实先例 `konifer44/SmartLED_App-SwiftUI`(RGB LED 控制) | [hendriku/ColorPicker](https://github.com/hendriku/ColorPicker) / [SmartLED_App](https://github.com/konifer44/SmartLED_App-SwiftUI) |
| 屏幕/音量/天窗遮阳 | 0-100%(连续) | `Gauge(.accessoryCircularCapacity)` 闭环填充 + 中心% | lens4 Gauge |
| 雨刮 | 档位(离散) | 分段控件(自动/低/高) | Inxel/Picker |
| 香氛 | 开关 + 浓度 | toggle + 小 Gauge(浓度) | 组合 |

👉 **device 粒度（fork2）**：族卡(10)聚合显示；点击/语音触发 → matchedGeometry 展开族内 device 细节(如空调展开=温度环+风量+模式；车窗展开=4 门开度环)。191 device 不平铺，按"族卡折叠 → 触发展开"下钻。

### F2. 炸场展示配方（10 族×语音×5min）
1. **开场全景**：10 族 dim 网格(LazyVGrid lens4) 一眼证明能力广度("我能控这么多")。
2. **语音触发聚焦**：方案经理说话 → 命中族卡 matchedGeometry morph 放大 + breathe(tokens) + 背景 blur(ZStack L2)。
3. **多意图连动(关键 wow)**："放首歌、空调调低" → 多族卡 **stagger reveal**(`.animation(.spring.delay(idx*0.05))` 或 iOS17 `PhaseAnimator`) 依次点亮联动。
4. **开场氛围灯 golden step**(U4)：氛围灯调色铺满屏(color/brightness 全维)——投屏冲击碾压文本卡(GRILL-MASTER R1-G4)。
5. **断网高潮**：在线→离线 morph + 离线琥珀徽章 `100%端侧·0网络`(tokens state.offline)。
6. **值动效按 value.type 三分**(U13/lens7)：SPOT(抠槽)直接跳值 / EXP(逆规整)渐变 / PERCENT 环填充。

### F3. 🔴 边界特殊性（现场只说 10 族 + 族外兜底）
- **族外 unsupported**：现场只说 10 族(范式约定收窄输入)；万一说族外 → tokens `blocked_hard` 灰锁卡"暂不支持 X"(**优雅拒识非崩**，demo 卖点=知道边界)。
- **clarify 澄清**(卖点)：模糊意图("我有点冷")→ tokens `blocked_with_alternative` 琥珀提示卡(升温+座椅，**非红**)。
- **safety 拒识**：危险指令 → tokens `unsafe` 红描边(安全门，唯一用红)。
- 🔴 **U10 四态分开铁律**：琥珀clarify ≠ 灰unsupported ≠ 红safety ≠ 灰crash——现万能红字混=翻车(ContentView:122 二值)。这是 demo 智能感的核心展示。

## presentation_options
1. **族卡折叠→触发展开**(fork2)：10 族卡聚合 + matchedGeometry 展开族内 device 值(不平铺 191)。
2. **异构值各对口控件**(F1 表)：温度/开度/音量→Gauge环；RGB→色环；座椅→7级分段；档位→分段；开关→toggle。
3. **炸场=全景→语音聚焦→多卡 stagger 联动→断网高潮**(F2)。
4. **边界四态色分开**(F3)：unsupported灰/clarify琥珀/safety红/crash灰，绝不混红字。

## pre-mortem
- **tiger**：座椅多维/RGB 色环若用 native Picker.segmented → 样式全局污染(覆盖所有 Picker)+ 单行限制 → 用 Inxel 自定义库或自绘。验证：多控件页 Picker 样式是否串。
- **tiger**：多意图 stagger reveal 在低电量/ReduceMotion 静默禁 → 联动 wow 归零 → 双通道(颜色/值兜底，hig-rules)。
- **paper_tiger**：RGB 色环复杂 → native `ColorPicker` 两行够(supportsOpacity:false)；要 wheel 美感才用 hendriku 库(纯 SwiftUI 轻量)。
- **elephant**：族外 unsupported 的"优雅拒识"是 demo 卖点但最易被做成红字 crash 样 → 必须 tokens 灰锁(非红)，且要专门 golden case 演示"知道边界"。
- **elephant**：191 device 全平铺是陷阱 → 族卡折叠+触发展开才是 10 族的解(否则一屏崩)。

## adopt 候选（star/日期待主线程核）
- `Inxel/CustomizableSegmentedControl`(座椅 7 级多维，per-segment 图标+voiceover) [待核 star/日期]
- `hendriku/ColorPicker`(RGB 色环 ColorPickerRing 纯 SwiftUI) / `Priva28/SwiftUIColourWheel`(AngularGradient) [待核 star/日期]
- `konifer44/SmartLED_App-SwiftUI`(RGB 氛围灯真实先例，代码参考) [待核 star/日期]
- 原生 `ColorPicker`(iOS14+) + `Gauge`(iOS16+) + `PhaseAnimator`(iOS17)——零依赖优先

## external_claims（供主线程 cite-verify）
- Inxel/CustomizableSegmentedControl / hendriku/ColorPicker / Priva28/SwiftUIColourWheel / konifer44/SmartLED_App star+pushedAt [全待 gh 核，未凭印象给数]
- 真实 OEM 座椅 7 级(3 通风+off+3 加热)——[heatseatswitch](https://heatseatswitch.com) 行业惯例（非单一权威，多源辅证）
- ColorPicker iOS14 / Gauge iOS16 / PhaseAnimator iOS17（Apple 文档，[待二次核]）

## sources
- [Inxel/CustomizableSegmentedControl](https://github.com/Inxel/CustomizableSegmentedControl) / [hendriku/ColorPicker](https://github.com/hendriku/ColorPicker) / [Priva28/SwiftUIColourWheel](https://github.com/Priva28/SwiftUIColourWheel) / [konifer44/SmartLED_App](https://github.com/konifer44/SmartLED_App-SwiftUI)
- [Apple ColorPicker](https://developer.apple.com/documentation/swiftui/colorpicker) / [hackingwithswift segmented control](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-segmented-control-and-read-values-from-it)
- 真实 OEM 7 级座椅：[heatseatswitch](https://heatseatswitch.com/ventilation-and-heating-control-system/) / [sensirion-automotive](https://sensirion-automotive.com/company/news/press-releases-and-news/article/taking-seat-ventilation-to-the-next-level)
- 值形态/四态/炸场：tokens.md + hig-liquid-glass-rules.md + grill-decisions-master §3(U4/U10/U13)
