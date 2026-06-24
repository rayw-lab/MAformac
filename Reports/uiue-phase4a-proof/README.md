# UIUE Phase 4a force-state 视觉验收 proof（5-gate artifact）

> 🔴 **PR 硬门**（主 anti-claim 防线，防前任「接线丢失/单测绿/proof 图丢」重演）：本目录 14 张 force-state 截图 = Phase 4a 摘要层【实跑非声称】证据。
> 生成方式 = `simctl`/window-isolated 启动**整 app**（非 ImageRenderer 假绿）+ `-forceVisualState <态>` launch arg。

## 生成命令（可复现）
- **iOS（竖屏 2 列×5 行）**：`xcrun simctl launch <udid> lab.rayw.MAformac.ios -forceVisualState <态>` + `xcrun simctl io <udid> screenshot`（模拟器隔离，干净无隐私）。
- **macOS（横屏 5 列×2 行）**：`open -n MAformacMac.app --args -forceVisualState <态>` + `screencapture -l <CGWindowID>`（**窗口隔离=只抓 app 窗口，不抓下层/飞书**，隐私安全，memory `macos-gui-screenshot-privacy`）。

## 14 张清单（7 态 × 2 端）
| 态 | iOS 竖屏 | macOS 横屏 | 语义 |
|---|---|---|---|
| normal | `ios-normal.png` | `mac-normal.png` | 灰蓝静默（占位/未激活）|
| satisfied | `ios-satisfied.png` | `mac-satisfied.png` | 青辉光呼吸（已满足）|
| changing | `ios-changing.png` | `mac-changing.png` | cyan 脉冲循环图标（执行中）|
| blocked_with_alternative | `ios-blocked_with_alternative.png` | `mac-blocked_with_alternative.png` | 🟡琥珀 clarify「最低18℃已调到18」|
| blocked_hard | `ios-blocked_hard.png` | `mac-blocked_hard.png` | 灰锁🔒 unsupported「后排无独立温控」**非红** |
| unsafe | `ios-unsafe.png` | `mac-unsafe.png` | 🔴红描边⚠️ safety「行驶中禁止开启」（唯一红）|
| unknown | `ios-unknown.png` | `mac-unknown.png` | 中性灰△ crash「状态读取失败」 |

## 5-Gate verdict（逐张 Read 检测，还原实查环境，非看导出高清图当通过）
- ✅ **10 族全景常驻**：座椅/氛围灯/空调/屏幕/音量（激活）+ 车门/天窗遮阳/雨刮/香氛（normal 占位「未激活」）+ 车窗（10 族齐，冷启动不空屏）。
- ✅ **固定排序 = allowlist row_count 降序**：座椅696→氛围灯468→空调212→屏幕205→音量153→车门129→天窗遮阳102→车窗82→雨刮80→香氛32（实图坐实，不按 revision 跳位）。
- ✅ **scope 角标（裂缝⑤⑥）**：默认 scope 淡显 dim（座椅/空调「主驾」、屏幕「中控屏」低对比）/ 非默认显式进 title（「副驾车窗」）。
- ✅ **ambient 色块炸场**：氛围灯红色● + 卡背 tint（深空暗底 vivid 高对比）。
- ✅ **七态四分（U10 头号翻车点）**：clarify 琥珀 ≠ unsupported 灰锁 ≠ safety 红 ≠ crash 中性灰，两两可区分绝不坍缩。
- ✅ **Gate 1-5**：层级（激活青辉光 vs 占位 dim 一眼分）/对齐（栅格）/无遮挡（顶栏不压卡）/字体（值高对比可读，inkPrimary #EAF0FF on 深空暗底）/重量（炸场红块不抢内容，cyan halation 控 30-60%）。
- ✅ **布局自适应**：iOS 竖屏 2 列×5 行 / iPad 4 列 / macOS 5 列×2 行（离散固定非连续 adaptive 漂移，spec C22）。

## 边界
- 三屏分层「上方 orb + 中间对话流」= Phase 5（4a 车控层是下层，已验证）；竖屏三屏空间动态分配见 design AD-11。
- value.type 图形控件（dial=Gauge 环形/toggle 图形）= 4b 展开卡；4a 摘要卡是值文本格式化形态（design AD-11）。
