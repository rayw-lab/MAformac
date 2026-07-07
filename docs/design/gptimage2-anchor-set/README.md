# MAformac UIUE 作品锚点集（gptimage2 冷启动提示词）

> 磊哥 2026-06-25 定。**用途**：每次 UIUE 推进/实装时**回顾对比的视觉基准**——这套图 = 我们 grill 决策（连续舞台/orb 主角/hero/7 态色/间距字体/制冷蓝制热红/边缘氛围）的视觉化，实装截图对它逐张比，治「太 low」。
> **操作方式**：磊哥**人工在网页版 ChatGPT「创建图片」(gpt-image-2)** 逐张生成，**上传 `anchor-01` iOS 基线图**保持风格一致。每个锚点 = 一个独立的**冷启动提示词 md 文件**（厚实详细，编码该锚点的 grill 决策 spec）。
> **灵感来源**：gptPRO 2 图（#19 iPhone / #20 Mac，仅参考）+ 深读补全细节（SD21）。

---

## 📁 11 个冷启动提示词文件（每个图片一个）

| # | 文件 | 锚点 | 类型 | 主题/平台 | 上传基线 | 比例 |
|---|---|---|---|---|---|---|
| A01 | [`anchor-01-idle-baseline.md`](anchor-01-idle-baseline.md) | 主页 idle 全景基准 | 页面·**基线母版** | 米白日·iPhone | 不需（本张定基线）| 9:16 |
| A02 | [`anchor-02-heat-red-hero.md`](anchor-02-heat-red-hero.md) | 单意图制热红 hero | 场景 | 米白日·iPhone | A01 | 9:16 |
| A03 | [`anchor-03-multi-intent.md`](anchor-03-multi-intent.md) | 多意图错峰 | 场景 | 米白日·iPhone | A01 | 9:16 |
| A04 | [`anchor-04-tired-macro.md`](anchor-04-tired-macro.md) | 困了宏多族提神 | 场景 | 米白日·iPhone | A01 | 9:16 |
| A05 | [`anchor-05-r2-refuse.md`](anchor-05-r2-refuse.md) | R2 安全拒识 unsafe | 场景 | 米白日·iPhone | A01 | 9:16 |
| A06 | [`anchor-06-ambient-burst.md`](anchor-06-ambient-burst.md) | 氛围灯边缘爆发炸场 | 场景 | 米白→紫·iPhone | A01 | 9:16 |
| A07 | [`anchor-07-night-deepspace.md`](anchor-07-night-deepspace.md) | 夜晚深空主题 | 主题 | **深空夜**·iPhone | A01（布局参考）| 9:16 |
| A08 | [`anchor-08-mac-split.md`](anchor-08-mac-split.md) | Mac 左右分栏全景 | 平台 | 米白日·**Mac** | A01（风格参考）| 16:10 |
| A09 | [`anchor-09-demo-console.md`](anchor-09-demo-console.md) | 演绎控制台 | 页面 | 米白日·iPhone | A01 | 9:16 |
| A10 | [`anchor-10-settings.md`](anchor-10-settings.md) | 设置面板 | 页面 | 米白日·iPhone | A01 | 9:16 |
| A11 | [`anchor-11-control-center.md`](anchor-11-control-center.md) | 控制中心弹窗（33 base）| 页面 | 米白日·iPhone | A01 | 9:16 |

**覆盖**：主要页面（主页/演绎控制台/设置/控制中心弹窗/Mac）+ 典型场景（idle/单意图/多意图/困了宏/R2/氛围爆发）+ 主题（米白/深空）+ 平台（iPhone/Mac）。

## 📁 A00 — context capsule「活体迷你窗」diorama（顶部 context 映射，SD24 + diorama 加强）

> 顶部玻璃 capsule = context 映射（车辆状态 + 环境），中间是**会动的分层迷你世界**（非文字）：昼夜天空 + 车（行驶/静止+尾气）+ 雨 + 视差景深 + 玻璃折射，极简优雅非卡通、满帧 premium。4 张 close-up 看 diorama 细节 + 1 张整屏 in-situ。

| # | 文件 | context 状态 | 视角 | 比例 | 看什么 |
|---|---|---|---|---|---|
| D1 | [`anchor-00-diorama-1-normal-day.md`](anchor-00-diorama-1-normal-day.md) | 常态（晴·白天·静止）| close-up | 3:2 | 车怠速+尾气+暖天+玻璃折射（静态也活）|
| D2 | [`anchor-00-diorama-2-driving-day.md`](anchor-00-diorama-2-driving-day.md) | 行驶（晴·白天·城市）| close-up | 3:2 | 视差前快后慢=速度感+轮转 |
| D3 | [`anchor-00-diorama-3-static-night.md`](anchor-00-diorama-3-static-night.md) | 夜晚静止 | close-up | 3:2 | 头灯光锥+尾灯辉+星空月+冷暖对比 |
| D4 | [`anchor-00-diorama-4-rain-night-driving.md`](anchor-00-diorama-4-rain-night-driving.md) | 雨夜行驶（最 rich）| close-up | 3:2 | 雨+湿身+雨刮+头灯穿雨+路面倒影+玻璃雨珠（9.5 代表作）|
| D5 | [`anchor-00-diorama-5-fullscreen-insitu.md`](anchor-00-diorama-5-fullscreen-insitu.md) | 常态 in-situ | 整屏 | 9:16 | diorama 胶囊坐整屏顶部+连续舞台，验比例协调 |

**状态**：design 探索（grill 未锁）。生图对比旧 `anchor-00-A/B`（文字版）验证是否更高级。锁后 → 修 A-1 `AD-RPB-014`（context 四维 vehicle{speed,gear}+environment{weather,time}）+ 记 SD24 amend。

---

## 🖱️ 人工操作流程（每张通用）

1. **先生成 A01 基线母版**（[`anchor-01`](anchor-01-idle-baseline.md)）：网页版 ChatGPT → 新会话 → **「进阶专业」模型** → **「创建图片」** → 粘贴 A01 提示词 → 比例 9:16 → 出图存 `anchor-01-idle-baseline.png`。
2. **生成 A02-A11**：新会话 → 「进阶专业」→「创建图片」→ **上传 `anchor-01-idle-baseline.png`** 作视觉基线 → 粘贴对应文件的【完整提示词】整段 → 按文件标注的比例 → 出图存 `anchor-NN-<slug>.png`（落本目录）。
3. **每个文件结构**（厚实详细）：① 操作说明 ② 角色与任务设定（可 prepend 强化质量）③ **完整提示词（粘贴这一整段）** ④ 精确规格表（色值/字号/间距）⑤ 关键编码点 + 5-gate 验收。

> **为什么上传基线图**：保持 11 张米白连续舞台/orb/玻璃质感/SF Pro 字体**风格一致**，仅改场景/态/页面。A01 是风格母版，其余是它的派生。

---

## 🎯 每张编码的 grill 决策（提示词 = grill 清单的视觉化）

| 锚点 | 编码的 grill 核心 |
|---|---|
| A01 | 连续舞台三屏(SD18) + orb 主角粒子(SD16/21) + hero range bar 制冷蓝(SD20) + 次要族 fade(SD21) + 边缘氛围(V7) |
| A02 | 制热红 热浪图标+红渐变条(SD20) + mode 图标 + 对话 inline 染色(SD21) + satisfied 青辉光(D7) |
| A03 | sequencer 220ms 错峰(AD-4) + changing 脉冲 vs satisfied 呼吸(D7) + 多 active 不单 hero(D2) |
| A04 | 困了宏提神非助眠(E4) + CC1 座椅主值切换 + 氛围灯不亮 + 多族错峰 |
| A05 | R2 unsafe 红克制(D7) + CC-B1 后备箱主值切 + CC-B2 行驶态纯话术守红线 |
| A06 | 氛围灯整屏边缘爆发(SD4/V7) + 粒子飞溅(SD17) + vivo 对标(磊哥重点) |
| A07 | 深空软黑底 #121212(U11 halation) + 暗底辉光更炫 + 高对比文字 |
| A08 | V12 Mac 左右分栏(守 SD21#9) + 5×2 全景不滚动 + 双端一套设计 |
| A09 | 演绎控制台竖排模块卡(SD14) + segmented 互斥(SD15) + 三大块(SD13) |
| A10 | 设置幕后工具(SD8) + 主题切换 segmented(V6) + 场景宏 force |
| A11 | 控制中心弹窗 AllStateSheet(SD14) + 33 base 分组网格 + 信息密度 |

---

## 🔧 维护

- 每次 UIUE 推进/实装后，对应锚点重生图（或实装截图）→ 逐张比 **5-gate**（层级/对齐/遮挡/字体/重量）+ 制冷蓝制热红 + 边缘氛围 + 连续舞台无黑线。
- 新增态/场景/页面 → 加锚点文件（如 clarify 琥珀澄清、boot reveal 开机演出、座椅展开 composite）。
- prompt 随 grill 决策演进同步改（锚点集是 grill 决策的视觉镜像，见 `../../uiue-storyboard-grill-decisions.md` SD18-SD21 + `../../UIUE-checklist.md`）。
