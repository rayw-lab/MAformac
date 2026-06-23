# MAformac 10 族车控前端【展示/呈现】综合官报告

> 综合官收敛 7 lens（local-hardware / car-hmi / cross-domain / swift-components(空) / code-clone / pitfalls / recipe-boundary(空)）。focus = **10 族怎么在前端展示/呈现**（信息架构 + 形态 + 值可视化 + 双屏），非配色（配色已锁 tokens.md）。
> 一手核验：所有 star/pushedAt + ContentView/tokens file:line 已主线程 gh + Read 亲核（见 external_claims_to_verify 全 ✅）。
> 日期 2026-06-23。落点 `docs/design/`（视觉 SSOT）+ 喂回 grill master §3（U13/U26/U14 续批）。

---

## 1. 鸟瞰：7 路收敛出的唯一共识

**5 路有效 lens（local-hardware / car-hmi / cross-domain / code-clone / pitfalls）独立收敛到同一个主视图形态**——不是 A/B/C 三选一，而是 **A+B 合体 = 全景常驻骨架 + 语音触发聚焦**（业界称谓不同但同构）：

| lens | 给它的名字 | 核心机制 |
|---|---|---|
| local-hardware | A 全景常驻 + 触发聚焦 | Grid 5×2 常驻 + matchedGeometry hero 放大 |
| car-hmi | MBUX「Zero Layer」+ AI 浮现 | 常驻骨架 + 语音点名族高亮浮现 |
| cross-domain | **B' = 全景 bento + spotlight 聚焦** | 常驻全 10 族 + scrim dim 其余 + 聚焦被控 |
| code-clone | A「全景常驻 + 触发聚焦」 | ZStack overlay + @Namespace + Color.clear 占位 |
| pitfalls | A，但**聚焦过渡禁用 matchedGeometry** | 全景常驻消 reflow + opacity/scale 聚焦 |

**5 路一致否决 B 纯动态浮现作主形态**（冷启动空屏不惊艳 + reflow 跳 + 懒渲染源不存在 + Reduce Motion 剥离瞬切，pitfalls 实证坑密度最高）；**5 路一致否决 C 静态全网格**（=scheme1 现状退化网格，10 族同时喊话抢走语音反馈注意力，违 Miller 7±2）。

**唯一真分歧（口径型，必上抛磊哥）= 聚焦过渡用不用 matchedGeometryEffect**：code-clone 主张用（hero 动画最炫）vs pitfalls 主张禁用（LazyVGrid multiple-source 运行时冲突 + macOS `navigationTransition(.zoom)` unavailable 无退路 + Reduce Motion 不自动 fallback）。这是事实型可坐实——见 grill 弹药 G2。

---

## 2. 对比矩阵（见 comparison_matrix 字段）

---

## 3. steelman 守 scheme1：保留什么 / 为 10 族重构什么

**三路认证保留（视觉语言层，已锁 tokens.md，不动）**：
- ✅ **三屏分层**（语音 orb 顶 / 对话流中 / 车控卡下）——UIUE lens3/7/8 + car-hmi NOMI 三屏天然同构 + iPhone 759pt 可用高的合理分配（local F5）。保留。
- ✅ **深空辉光卡片语言**（cyan/violet glow breathe）——保留，但**只激活态 breathe**（local F8 + pitfalls T1：10 张同屏 breathe = 10 offscreen pass，省 9/10 动画）。
- ✅ **base #0a0b12 非纯黑 + glow 30-60% 不铺满**（U11 + pitfalls T4 halation + local F3 投屏 banding，三路同源）。

**必须为 10 族重构（信息架构层，scheme1 撑不住）**：
- 🔴 **4-6 卡 2×2 固定网格 → 10 族 family_card 自适应网格**（U13）。scheme1 `grid-template-columns:1fr 1fr` 固定 2 列撑不住 10 族；ContentView.swift:40 现喂 22 个 device 平铺 = **信息架构粒度错（device 级非族级）**，不是布局技术缺（5 路共识）。
- 🔴 **7 态压绿/灰二值 → 7 态色 1:1 映射**。ContentView.swift:122,126 现 `visualState==.satisfied ? .green : .gray`（主线程实读坐实）= tokens.md:64 + U10 头号翻车点。clarify(琥珀)/unsupported(灰锁)/unsafe(红)/crash(中性灰) 四态必分开（demo 卖点）。
- 🔴 **族卡只显当前态摘要，细控件进聚焦展开态**（car-hmi MBUX「常驻少数 + 细控展开」+ Apple Home 分组卡 + Mi Home 三尺寸）。族卡空间放不下完整 slider+color picker（local F10）。
- 🔴 **字号按 1080p @1x 投屏放大**：scheme1 `font.card.val 15px` 远低于投屏下限（local F4 body ≥24pt / 标题 ≥44pt 8H 规则）。

---

## 4. 决策 + ⭐默认（见 decisions 字段，逐条带量化 + 证据）

---

## 5. pre-mortem 三分类汇总（7 路去重，见 pre_mortem_summary）

---

## 6. grill 弹药（见 grill_ammo 字段，喂回主线程 grill 磊哥）

---

## 7. adopt 清单（见 adopt_list 字段，star>1000 不降级，带 file:line/star/日期）

---

## 8. 结论一句话

scheme1 的视觉语言（深空辉光三屏）三路认证保留，但**信息架构必须从「4 卡 2×2 平铺 device」重构为「10 族 family_card 全景常驻网格 + 语音触发聚焦展开 + 7 态色 1:1 + value.type 异构控件」**。主形态 = **A+B 合体（全景常驻 + 触发聚焦）**，5 路独立收敛；唯一待磊哥拍的事实型分歧 = 聚焦过渡是否用 matchedGeometryEffect（macOS 无 zoom 退路 + LazyVGrid 冲突 = 倾向禁用、改 opacity/scale）。