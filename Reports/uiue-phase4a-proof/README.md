# UIUE Phase 4a force-state 视觉验收 proof（5-gate artifact + 体验审计收口）

> 🔴 **PR 硬门**（主 anti-claim 防线，防前任「接线丢失/单测绿/proof 图丢」重演）：本目录 = Phase 4a 摘要层【实跑非声称】证据。
> 生成方式 = `simctl` 启动**整 app**（非 ImageRenderer 假绿）+ `-forceVisualState <态>` launch arg / 真实冷启动无 arg。

## 生成命令（可复现）
- **iOS（竖屏 2 列×5 行）**：`xcrun simctl launch <udid> lab.rayw.MAformac.ios [-forceVisualState <态>]` + `xcrun simctl io <udid> screenshot`（模拟器离屏隔离，干净无隐私，锁屏不影响）。
- **macOS（横屏 5 列×2 行）**：`open -n MAformacMac.app --args -forceVisualState <态>` + `screencapture -l <CGWindowID>`（窗口隔离=只抓 app 窗口不抓下层/飞书，memory `macos-gui-screenshot-privacy`）。🔴 **screencapture 屏幕锁屏期间失败**（"could not create image"）→ mac 截图需屏幕活跃时拍。

## 截图清单（体验fix后，2026-06-25）
| 截图 | 内容 | 态 |
|---|---|---|
| `ios-coldstart-real.png` | 🔴 **P0-2 真实冷启动**（无 force-state，真实 defaultCells） | 10 族待命静默骨架（值全显+「待命」+scope角标，非满屏灰broken） |
| `ios-normal.png` ~ `ios-unknown.png`（7 张） | force-state 7 态 × 满屏丰富场景（验各机制成立） | normal/satisfied/changing/clarify琥珀/unsupported灰锁/safety红/crash灰 |
| ~~`mac-*.png`~~ | macOS 横屏 5 列×2 行 | ⏳ **重拍 pending**（磊哥屏幕锁屏 screencapture 不可用；mac=同 App/Core 代码 build SUCCEEDED 两端 + iOS 视觉验证 + 磊哥已见早期 mac 5 列图；屏幕活跃时重拍） |

## 5-Gate verdict（逐张 Read 检测，还原实查环境，非看导出高清图当通过）
- ✅ **10 族全景常驻**：座椅/氛围灯/空调/屏幕/音量 + 车门/天窗遮阳/雨刮/香氛 + 车窗（10 族齐，冷启动不空屏）。
- ✅ **固定排序 = allowlist row_count 降序**：座椅696→氛围灯468→空调212→屏幕205→音量153→车门129→天窗遮阳102→车窗82→雨刮80→香氛32（不按 revision 跳位）。
- ✅ **scope 角标（裂缝⑤⑥）**：默认 dim 淡显（座椅/空调「主驾」、屏幕「中控屏」，**体验fix P1-2 提对比投屏可读=淡≠隐形**）/ 非默认显式进 title（「副驾车窗」）。
- ✅ **ambient 色块炸场**：氛围灯红色● + 卡背 tint（深空暗底 vivid）。
- ✅ **七态四分（U10 头号翻车点）**：clarify 琥珀 ≠ unsupported 灰锁 ≠ safety 红 ≠ crash 中性灰，两两可区分绝不坍缩。
- ✅ **Gate 1-5**：层级（激活青辉光 vs 待命 dim 一眼分）/对齐（栅格）/无遮挡/字体（值高对比可读 inkPrimary on 深空暗底）/重量（炸场红块不抢内容）。
- ✅ **布局自适应**：iOS 竖屏 2 列×5 行 / iPad 4 列 / macOS 5 列×2 行（离散固定非 adaptive 漂移，C22）。
- ⚠️ **P2-1 注**：iOS `ios-normal` vs `ios-satisfied` 因 force-state 脚手架注入 5 族活跃，ac 单卡差异在大图不突出——**七态可分以 cold-start(全静默) vs force-state(活跃) 对照 + mac 单卡对照为准**，非这两张。

## 体验审计收口（subagent CC 用户演绎体验视角，verdict=CONDITIONAL-PASS）
工程层 SOLID（7态四分/scope SSOT/占位骨架/numericText/breathe/ambient 实跑非假绿）；呈现语义层 catch 真缺口已收：
- ✅ **P0-1 修**：占位卡「未激活」（客户读成 demo 没做完）→「**待命**」（10 系统就绪态）。
- ✅ **P0-2 修**：补真实冷启动截图（`ios-coldstart-real.png`）——验证非满屏灰broken（待命骨架+值全显），惊艳开场=Phase 5 boot reveal。
- ✅ **P1-2 修**：scope dim 角标 caption2 9pt→caption semibold+细边框+提对比（投屏可读）。
- 🔒 **P1-3 steelman 不自改**：blocked_hard 灰锁误读「坏了」撞 D7 FROZEN 色映射（磊哥审签 灰=unsupported），上抛磊哥/AD-1 review（不自改色，icon/文案可议）。
- ⏳ **P1-4/P2-2 defer 4b**：changing 视觉强度 / ambient 增强。

## 边界
- 三屏分层「上方 orb + 中间对话流」= Phase 5（4a 车控层是下层）；竖屏布局承接见 design AD-12。
- value.type 图形控件（dial=Gauge 环形/toggle 图形）= 4b 展开卡；4a 摘要卡是值文本格式化形态（AD-11/AD-12 七）。
