# INDEX — MAformac 10 族车控前端展示/呈现 7-lens ultracode 调研（2026-06-23）

> 解决 scheme1 只 4 卡片撑不住 10 族的信息架构。7 lens（5 路 workflow + 2 路主线程亲补 rate-limited）+ 综合官。三层一手性全存。

## 文件清单（仓内）
| 文件 | 层 | 来源 |
|---|---|---|
| `README.md` | 二手综合 | 综合官 full_report |
| `lens1-local-hardware.md` | 一手 | workflow finder（本机 scout 坐实：主屏 1920×1080 非 Retina / 投屏 banding / Polestar4 印证） |
| `lens2-car-hmi.md` | 一手 | workflow finder（车机 HMI 多域范式 MBUX/Polestar/小米/理想） |
| `lens3-cross-domain.md` | 一手 | workflow finder（Apple Home/HA/Control Center/bento） |
| `lens4-swift-components.md` | 一手 | 🔴 **主线程亲补**（workflow 本路 rate-limited）+ 本机 ref-repos scout |
| `lens5-code-clone.md` | 一手 | workflow finder（IceCubes/ShipSwift/DaVinci 代码链路） |
| `lens6-pitfalls.md` | 一手 | workflow finder（matchedGeometry/大网格/banding 坑） |
| `lens7-recipe-boundary.md` | 一手 | 🔴 **主线程亲补**（workflow 本路 rate-limited）+ WebSearch |
| `synth.output.json` | workflow return | 完整结构（lens_count/lenses/synth），防 /tmp 清已 cp |

## transcript（最一手，🔴 仓外 — 命中敏感按 ultracode 纪律不入仓）
- 路径：`~/workspace/raw/05-Projects/MAformac/research/2026-06-23-uiue-10family-presentation-transcripts/`（9 jsonl / 2.1M）
- 移仓外原因：transcript 含 finder 搜证引用的 raw 路径/外部敏感词（grep 命中），按 §6 红线 + ultracode 存档纪律「命中敏感归仓外 + INDEX 指针」。

## lens ↔ agent 映射
- lens1=local-hardware / lens2=car-hmi / lens3=cross-domain / lens5=code-clone / lens6=pitfalls（5 路 workflow agent）
- lens4=swift-components / lens7=recipe-boundary（2 路主线程亲补，workflow 内 rate-limited 失败）
- 综合官=synthesize（基于 5 路 workflow + 主线程已知 2 路收敛）

## 🔴 主线程 cite-verify 坐实（横切纪律：finder 高发编精确数字，逐条亲核）
**✅ gh 核通过（star/pushedAt 与 finder 声称一致）**：
- IceCubesApp 7005★/2026-06-09（活跃）· Inferno 2879★/2026-05-17（活跃<60天）· lovelace-mushroom 5033★/2026-06-12 · lovelace-layout-card 1244★/2026-05-09
- Orb 422★/2024-11（~19月 stale，只抄纯代码子件）· CompactSlider 550★/2025-11（stale，改自写原生）· exyte/Grid 2086★/2025-02（淘汰，原生 LazyVGrid 够）
- lens4/lens7 repo（主线程亲核）：swiftui-hero-animations 249★/2020 · Inxel 73★/2025-04 · hendriku 77★/2022 · Priva28 84★/2020 · konifer44 ⭐3 淘汰 → **全>半年 stale：借鉴代码不依赖**

**✅ 本机 Read/grep 坐实**：ContentView.swift:40（`LazyVGrid(.adaptive(minimum:160))` 喂 cells 平铺=粒度错）· :122/126（visualState 二值翻车点）· U10/U13/U14/U26/U30（grill §3 grep）

**⚠️ 未独立核（范式层非数字，不阻塞决策，A2 实装时验证）**：
- macOS `navigationTransition(.zoom)`/`ZoomNavigationTransition` unavailable（G2 决策 load-bearing）→ A2 `swift build` 时 #available/平台守卫报错即坐实
- bento cap 8-12 tile / Single-Item-Template 假说 = 设计经验/认知科学论点，非工程硬数字

## 6 决策摘要（综合官，⭐ 待磊哥拍；详见 README）
1. **主视图形态** ⭐ A 全景常驻+触发聚焦（5 路收敛，否决 B/C）
2. **族内下钻** ⭐ 二级模型（族卡摘要→matchedGeometry 展开，191 device 绝不平铺）
3. **异构值** ⭐ enum+switch(value.type)：连续值 Gauge / 离散档 DSSegmentedControl / RGB 色环+Inferno / 开关 卡亮暗 / 座椅多维 展开面板自建
4. **双屏** ⭐ 非镜像协同（Mac 全景常驻网格 / iPhone 活跃置顶滚动）
5. **聚焦过渡** 🔴 **事实型分歧上抛磊哥（G2）**：lens4/code-clone 主张 matchedGeometryEffect hero vs lens6/pitfalls 主张禁用改 opacity/scale（macOS zoom 无退路+ReduceMotion 坑）；综合官倾向 ⭐ pitfalls（坑密度最低）
6. **炸场特效** ⭐ Inferno 水波高潮触发（U5 一期）+ 多意图序列化高亮（非同时闪）+ ReduceMotion 双通道
