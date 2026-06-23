---
type: uiue-roadmap-draft
status: DRAFT（3 fork 未拍，磊哥思考中；非 progress SSOT，待 fork 拍板后收口级联）
date: 2026-06-23
author: Claude (CC0)
upstream:
  - docs/research/2026-06-23-probe-uiue-agent-paradigm.md
  - docs/research/2026-06-23-premortem-uiue-baseline-gap-and-design-md.md
  - docs/grill-tournament/grill-decisions-master.md §3 (U1-U31)
  - docs/grill-tournament/cascade-inventory.md
  - raw/.../2026-06-22-uiue-ultracode/{README,GRILL-MASTER}.md
note: 本档 = CC0 综合全盘思考后的 UIUE 不降级大路线图草案，一字不差归档（磊哥指令）。3 fork（视觉锚点/ui-presentation 拆分/worktree）未拍前不级联 CLAUDE/grill-decisions-master，不写实现代码（agree before build）。
---

磊哥，全部料吃透了——两个指定文件逐行读完，UIUE 的决策 SSOT（grill-decisions-master §3 的 U1-U31）、级联账本 cascade-inventory、UIUE ultracode 综合报告（8 lens/79 findings/README）全过了一遍。下面是综合全盘思考后的**不降级大路线图**。

先点破一个你深读后会关心的关键事实，再给路线图。

---

# 〇、先对齐两件事（路线图的地基）

## 1. 你"另一个窗口"和"这条 UIUE"是**两条链路**，必须分清才不撞车

| | 链路 B（你另一窗口） | 链路 A（本路线图 = UIUE 前端） |
|---|---|---|
| 干什么 | **文档级联**（cascade-inventory）+ 后续 **A2 代码重构**（generic frame `tool_call_frame` → D-domain 具名工具，C1→C3→C5→C6 全契约/模型链路） | demo 的**看得见摸得着**那一层：视觉 SSOT / 状态可视化 / 卡片 / 语音 UI / 炸场剧本 / 现场 SOP |
| 改的文件域 | `contracts/` `generated/` `Core/` `openspec/specs/` + 全仓文档 banner | `App/` + 新建 `docs/design/` + 新建 `Sources/MAformacApp/UI/` |
| 当前态 | A2 派单地基在 grill（Q04/Q15/Q12 等还没拍） | 调研做完（probe+pre-mortem），**还没动一行 UI** |

**核心洞察（这是不降级路线图的命脉）**：UIUE **80% 的工作不依赖链路 B**，可以**立刻并行起跑**——只有少数几个交汇点必须等链路 B。下面第三节会把交汇点钉死。**不降级 ≠ 等 A2 跑完再开始**，而是**先把所有不依赖 A2 的硬骨头啃掉**。

## 2. probe 那个"One Question"（视觉锚点是什么）—— 你其实**已经答过了**

probe 报告反复说"磊哥没答视觉锚点 = 整套 SSOT 是空架子"（probe §4e/§3a #4）。但 probe 没读 UIUE ultracode README——那里 **scheme1「深空辉光暗底 + 三屏分层」已被 lens3/lens7/lens8 三路独立认证「对路」**（对标车机标杆 Polestar4 / 奔驰 EQS + 2025 车控多模态共识 + iOS HIG），README §三 steelman 结论就是 ⭐**守这个方向 + native SwiftUI 落地**。

> **所以视觉方向不是空白**：不是从 sci-fi / Apple Landmarks / Linear / Rauno 四选一从零定，而是**「深空辉光暗底科幻车机风」已收敛**，Phase 0 只需你**确认 + 冻结成 2-3 张 anchor PNG**（防 agent 重新漂移）。这把 probe 标的"最脆弱前提"从 HIGH 降到 LOW。

## 3. "不降级"的精确定义（防两个反向冲动）

| 维度 | 不降级（必做，不省） | 可砍（demo 轻治理，砍了不算降级） |
|---|---|---|
| **视觉 SSOT** | 三件套必建（tokens/hig-rules/anchor PNG）—— probe 结论3：不建≈整套范式失败 | Figma 订阅 / 多人评审 / 设计史 / DTCG 工具链（markdown+PNG 功能等价） |
| **可靠性内核** | 状态四态分开（U10）/ snapshot 视觉回归门 / 工程前置硬门 / Metal 水波（U5 你改的一期做）/ star>1000 adopt 资产**全量吸收** | App Store 上架 / 全设备适配（demo 只跑一台 Mac）/ 全 102 格卡片（10 族子集） |
| **架构形态** | DemoVisualState 7 态消费 / golden-run 合同回放 / value.type 三分动效 | 量产全链路（FC→NLU→DS→DM）/ 真车控 / 跨 session 视觉一致性纪律（demo 是「同一台 Mac 同一个 build」） |

⚠️ 警惕**反向过度工程化**：别因为"不降级"三个字，把量产的全覆盖/全治理搬进 demo（blueprint-teardown 双向冲动）。

---

# 一、当前真实态：六条断带 + producer/consumer 错位

pre-mortem §一 的实查结果，我归到一张「能不能起跑」的表：

| 断带 | 现状（file:line 实证） | 阻塞谁 | 依赖链路 B 吗 |
|---|---|---|---|
| **L3 视觉 SSOT** | `docs/design/` 整个目录**不存在** | U2/U5/U7/U11/U14 全部 | ❌ **不依赖**，可立即建 |
| **L4 工程前置** | 无 `Info.plist`、无 XcodeGen `project.yml`、`Package.swift:18` 把 `App/` exclude | U6（demo-blocker P0）接麦克风/模型即崩 | ❌ **不依赖** |
| **L5 状态消费** | producer ✅（`DemoVehicleStateStore.swift:17-25` 已有 7 态枚举）/ consumer ❌（`ContentView.swift:121-127` 还是绿/灰二值） | U10（头号刀） | ❌ **不依赖**（消费端态枚举，非 D-domain 工具名） |
| **L6 snapshot 回归门** | 0 snapshot 测试，agent 改 UI = 盲飞 | 所有 view 改动 | ❌ **不依赖** |
| **L1 state-cells 10 族** | `contracts/state-cells.yaml` 只 4 族；`tool-card-map.demo10.json` 不存在 | U13/U26/U3 卡片网格 | ✅ **依赖链路 B**（codex 基线扩 4→10 族 / B2） |
| **L2 demo-golden-run spec** | `define-demo-golden-run-and-voice` 是 DRAFT skeleton（spec.md 全 placeholder，**缺 design.md**） | U8/U9 golden-run 回放 | 🟡 **部分**（契约 schema 可先写，挂 D-domain 工具数等 A2） |

**一句话**：L3/L4/L5/L6 四条断带（视觉 SSOT + 工程前置 + 状态消费 + snapshot）**完全不依赖链路 B**，是 UIUE 立即能啃、且 ROI 最高的硬骨头。只有 L1（卡片网格）真正卡在 codex 的 state-cells 10 族上。

---

# 二、不降级大路线图（7 Phase + 依赖图）

```
[Phase 0 · 磊哥 30min · 拍板+清场]  ← 唯一阻塞全局的门
   │
   ├──→ [Phase 1 · 视觉SSOT + 工程前置]  ❌不依赖A2，立即起跑，最高ROI
   │       ├ 轨1a 视觉SSOT三件套 (tokens/hig-rules/anchor PNG/INDEX)
   │       └ 轨1b 工程前置硬门 (Info.plist/entitlements/XcodeGen/snapshot baseline/Availability守卫)
   │            │
   │            ├──→ [Phase 3 · 状态消费弥合 + 三屏native]  ❌不依赖A2 ★核心刀
   │            │       U10 ContentView:121-127 绿灰二值→DemoVisualState 7态
   │            │       状态四态分开(clarify/unsupported/safety/crash) + 三屏分层 + 每view snapshot
   │            │
   │            └──→ [Phase 5 · 语音UI + 炸场剧本 + adopt全量]
   │                    语音态机/barge-in PTT/orb MeshGradient/中文TTS + 氛围灯/座椅/Metal水波/断网高潮
   │
   ├──→ [Phase 2 · OpenSpec ui-presentation 契约]  (依赖0.1视觉锚点+0.3 fork2)
   │       design.md(补缺) + spec.md填实 + ui-presentation capability + tasks拆U系列
   │
   └──→ ⏳[Phase 4 · 卡片网格]  ✅等链路B: state-cells扩10族 + D-domain工具数
           U13/U26/U3 卡片按10族family_card_id + enum+switch(value.type) + 环形仪表 + tool-card-map.demo10.json
                    │
                    └──→ ⏳[Phase 5 的 golden-run 回放部分]  ✅等 demo-golden-run.v1.yaml(F3/A2)
                              │
                              └──→ [Phase 6 · 现场SOP + 真机彩排]  收口
                                      Mac主+三关一充+Release真机彩排+USB-C投屏+暗底切提亮⌃P+watchdog
```

## Phase 0 — 拍板 + 清场（磊哥本人，~30min，唯一全局门）

| 动作 | ⭐默认 | 为什么 |
|---|---|---|
| 0.1 确认视觉锚点 | ⭐**深空辉光暗底科幻车机风**（scheme1 已三路认证），出 2-3 张 anchor PNG 冻结 | 不是从零定，是确认 + 冻结防漂移 |
| 0.2 git 清场 | ⭐链路 B 那波 commit/stash 干净；**UIUE 走 git worktree 隔离**（`git worktree add ../MAformac-uiue`），与链路 B 文件域天然错开 | 51 staged+29 mod+66 untracked，两窗口同仓硬扛必撞 |
| 0.3 三个 fork（见第四节）| 见下 | 决定 Phase 2 结构 |

## Phase 1 — 视觉 SSOT 三件套 + 工程前置（❌不依赖 A2，立即并行，**最高 ROI**）

> 这是"不降级"的地基。两轨并行，UIUE worktree 内做，**完全不碰链路 B 的文件**。

**轨 1a 视觉 SSOT**（压住 LLM 视觉方差的内核）：
- `docs/design/tokens.md` — base `#0a0b12` + `surface_role=control_glass/content_glow` + DemoVisualState 7 态色（抄 master §3 U2/U10/U11）
- `docs/design/hig-liquid-glass-rules.md` — **functional layer only**（U2/U5：Liquid Glass 只 mic/顶栏，内容卡用自研 glow 非 system glass）+ iOS17 `#available` fallback（U19）+ frame-drop 预警
- `docs/design/visual-anchors/{a,b,c}.png` + 每张配"学什么/不学什么"
- `docs/design/INDEX.md` + `CLAUDE.md` 加一行"UI 生成前必读 docs/design/INDEX.md"

**轨 1b 工程前置硬门**（U6 最高优先 demo-blocker）：
- `App/Info.plist`（NSMicrophoneUsageDescription）+ `App/MAformac.entitlements`（increased-memory-limit）
- `project.yml`（XcodeGen，U12 **降 P1**——仓内已有 xcodeproj+2 target，非缺整个壳）
- `Sources/MAformacApp/Support/Availability.swift`（封装 iOS18 `#available` 守卫，U19）
- `Tests/.../Snapshots/` baseline（pointfreeco swift-snapshot-testing + ImageRenderer，T6 视觉回归门）

## Phase 2 — OpenSpec `ui-presentation` 契约补齐（依赖 0.1 + 0.3-fork2）

把 DRAFT skeleton 变 propose-ready（pre-mortem T1 顶死点）：
- 补 `define-demo-golden-run-and-voice/design.md`（**缺这个 = strict validate 顶死**，承接你说的"design.md ≠ SRD"——这是**实现侧 ARCH**，和项目根 `docs/design/`视觉 SSOT 是两个 design）
- spec.md placeholder → 真 Scenario
- 🆕 拆 `ui-presentation` capability（DemoVisualState 7 态契约 + ContentView 替代 + Liquid Glass surface_role）—— **fork2 拍这个**
- tasks.md 拆 U1-U31

## Phase 3 — 状态消费弥合 + 三屏 native（❌不依赖 A2，★核心第一刀）

> producer 已 ready，这步只补 consumer，**消费的是端态枚举不是 D-domain 工具名，所以不等 A2**。

- **U10 头号刀**：`ContentView.swift:121-127` 绿/灰二值 → 消费 `DemoVisualState` 7 态（`DemoVehicleStateStore.swift:17-25`）+ trace guardReason/readbackResult
- **状态四态分开**（U10/U27）：clarify / unsupported / safety_refusal / crash —— 现万能红字把"拒识（卖点）"和"真崩"渲成一坨 = 翻车
- **三屏 native 落地**（README §六）：语音 orb（MeshGradient 自建）/ 对话流（adopt LocalLLMClient 气泡）/ 卡片网格骨架
- 每个 view 建 snapshot baseline

## Phase 4 — 卡片网格细节（⏳**等链路 B**：state-cells 10 族 + D-domain 工具数）

- U13/U26/U3：卡片按 **10 族 family_card_id**（非 191 格/非旧 102）+ `enum+switch(value.type)`（非 AnyView）+ 环形仪表给连续值
- `tool-card-map.demo10.json`（**依赖 codex 扩 state-cells 4→10 族 = 链路 B / B2**）
- **交汇契约**：你只需让链路 B **先 freeze 一个"读取契约"**（`tool→IR→state_cell→card→patch` 字段），UIUE 端按契约读，不等全部代码跑完

## Phase 5 — 语音 UI + 炸场剧本 + adopt 全量（不降级核心）

- 语音态机（@Observable VoiceState 五态）+ barge-in **PTT 物理打断**（U21）+ TTFA **掩盖术 immediate ack**（U22）+ 中文 TTS **锁普通话 premium**（U28）+ orb **核心 MeshGradient**（U30，shader 仅氛围层）
- 炸场剧本：氛围灯开场 golden step（U4）/ 座椅多维联动 / **Metal 水波（U5 你改的一期做，非二期）** / 断网高潮 morph + 「100%端侧·0网络」徽章
- **adopt 全量吸收**（star>1000 不降级）：见第三节清单
- golden-run **合同回放**部分 ⏳等 `demo-golden-run.v1.yaml`（F3/链路 B）

## Phase 6 — 现场 SOP + 真机彩排（收口）

- demo SOP（U1）：Mac 主 + iPhone 加分（别写成免检牌）+ 三关一充 + Release 真机彩排全五幕 + 现场前夜重签
- 投屏：**USB-C/HDMI 有线**（U24，AirPlay 仅 fallback）+ 暗底投屏 **⌃P 秒切提亮**（U23，防 8bit 投影 banding）
- 演示安全网（U29）：live 为主 + golden-run 兜底 + watchdog（MLX 60s 掉 50% 吞吐）

---

# 三、不降级 adopt 清单（star>1000 全量吸收，已 clone 在 ref-repos）

> blueprint-teardown 铁律：star>1000 不降级。这些是 UIUE ultracode lens5 实读坐实的可抄代码：

| 资产 | 用途 | heat |
|---|---|---|
| **hanlin-ai** VoiceInputView:202-239 | 实时 RMS 滚动柱波形 + 触觉 | 229★ 活跃 |
| **hanlin-ai** LoadingGradientText:24-67 | TimelineView 流光"思考微光"（改深空青）| 229★ |
| **LocalLLMClient** ChatView:83-113 | 气泡 + optimistic + token 累加 | ~700★ |
| **WhisperKit** WaveformView:39-85 | Canvas 渲染波形（比 N 个 Rect 高一档）| ~4k★ |
| **whisper.cpp** DownloadButton:25-101 | 模型首装下载三态机（README elephant 点名缺失）| ~37k★ |
| **metasidd/Orb** OrbView:16-63 | 分层 mesh 辉光球（fork vendor 配深空青紫）| 421★ |
| **twostraws/Inferno** | Metal 水波 shader（U5 一期）| 2876★ |
| **mlx-swift-examples** LLMEval | @Published output + displayEveryNTokens | 2608★ Apple 官方 |

**drop（明确不引，不算降级）**：RN/Flutter（mlx 冲突）/ Lottie/Rive（无美术产线）/ TCA（单屏 over-engineering）/ 所有老 siri-orb 库（全 stale）。

---

# 四、需磊哥拍的 3 个 fork（⭐默认，可一把过或挑改）

打字回我即可，不弹窗：

**Fork 1 — 视觉锚点现在确认还是延后？**
- ⭐ **现在确认深空辉光暗底科幻车机风**（scheme1 已三路认证，只需出 2-3 张 anchor PNG）→ Phase 1 立即起跑
- 延后 → Phase 1 轨 1a 阻塞，但轨 1b（工程前置）仍可先跑

**Fork 2 — `ui-presentation` 拆独立 capability 还是塞进 demo-golden-run？**
- ⭐ **拆独立**（DemoVisualState 7 态 + 卡片契约自成一个 capability，符合 OpenSpec 单一职责）
- 塞进 demo-golden-run（少一份 spec 维护，但职责混）

**Fork 3 — UIUE 走 git worktree 隔离，还是单仓和链路 B 硬扛？**
- ⭐ **走 worktree**（`../MAformac-uiue`，文件域与链路 B 天然错开，两窗口零撞车）
- 单仓硬扛（51+29+66 脏状态下两窗口同改必撞）

---

# 五、这个路线图相对两份报告的增量（我的综合判断）

1. **probe 的"One Question"已被 UIUE ultracode 答了**——视觉方向不是空白，scheme1 深空辉光三路认证，把最脆弱前提从 HIGH 降 LOW。
2. **pre-mortem 的"4 批方案"我重排成了「依赖链路 B 与否」两类**——揪出 L3/L4/L5/L6 四条断带**完全不依赖 A2**，这是不降级的关键：UIUE 不用等链路 B，先并行啃掉四条硬骨头（probe/pre-mortem 都没明确拆这条依赖线）。
3. **明确两条链路的交汇契约**：UIUE 只在「state-cells 10 族读取契约」「demo-golden-run.v1.yaml」「D-domain 工具数」三个点等链路 B，其余全独立。

---

要不要我**把这个路线图落档**为 `docs/uiue-roadmap-2026-06-23.md`（UIUE 链路的 progress SSOT，对齐 Q22 单源精神）？还是你先拍上面 3 个 fork、我再据拍板收口落档？我建议**先拍 fork → 我落档**（agree before build，避免落了又改）。
