---
type: pre-mortem-report
version: 1
topic: U 系列任务推进前的基建复盘 + Pre-Mortem + design.md 辨析 + 补齐方案
depth: standard
date: 2026-06-23 13:30
methods:
  - Klein-HBR-Pre-Mortem
  - Scout-Oracle
  - Tiger-PaperTiger-Elephant
  - Honnibal-10-Class-Code-Fragility
  - OpenSpec-Cascade-Audit
  - Source-Grounded-Inventory
hypotheses:
  - 现有 OpenSpec define-demo-golden-run-and-voice 是 DRAFT skeleton,不足以承载 U 系列
  - 视觉 SSOT 三件套不建则 U2/U7/U11/U14 翻车
  - design.md 与 SRD/spec.md 不同——OpenSpec change 内 design.md 是实现侧 ARCH,项目根 DESIGN.md 是视觉 SSOT,两者都需建
  - U 系列 30+ 任务里 80% 卡在 state-cells-10族 / demo-golden-run-spec / 视觉SSOT / ContentView-7态 / snapshot-loop 五条断带
upstream_artifacts:
  - docs/research/2026-06-23-probe-uiue-agent-paradigm.md (probe report v3)
  - docs/grill-tournament/grill-decisions-master.md §3 (U1-U31 SSOT)
  - openspec/changes/define-demo-golden-run-and-voice/ (DRAFT skeleton 实证)
verdict_summary: 当前基建在 L0/L1jsonl/L2archived-specs 已通,但 L1.state-cells-10族 / L2.demo-golden-run-spec / L3.视觉SSOT / L5.ContentView-7态 / L6.snapshot-loop / L7.DESIGN.md 六条断带阻死 U 系列 80% 任务。补齐方案 = 4 批可并行动作 (批次 0 磊哥答 One Question + 清场 → 批次 1 视觉 SSOT 三件套 + 批次 2 OpenSpec 4 件套补齐 + 批次 3 工程前置硬门 → 批次 4 U 系列正式起跑)。磊哥需先拍 3 个 fork:视觉锚点是否现在答 / ui-presentation 是否拆出独立 capability / UIUE 是否走 git worktree 隔离。
confidence_range: 75-95
---

# Pre-Mortem Report: U 系列任务推进前的基建复盘 + 补齐方案

> **源会话**:磊哥追问"结合 probe 报告,回顾复盘现有的 OpenSpec 和基础建设,继续联网搜索 /pre-mortem,看看要补齐哪些文件、做哪些动作才能开展 U 系列任务,给意见和方案;磊哥自己提到 design.md 不同于 SRD,要全盘思考。"
> 上游 = `docs/research/2026-06-23-probe-uiue-agent-paradigm.md`(Probe Report v3 verdict_summary:"MAformac 推范式 C,但必须建 SSOT 三件套")。
> 本档为 Pre-Mortem(Klein/HBR)全 oracle 路 + 现状基建实查 + design.md 辨析 + 4 批补齐方案一字不落归档,**不做任何裁剪**。

---

# 一、基建现状复盘:四个层的真假账

把 MAformac 的"基建"按层平铺,**红色 = 撑不住 U 系列**:

| 层 | 文件 | 现状 | 撑不撑 U 系列 |
|---|---|---|---|
| **L0 项目宪法** | `CLAUDE.md` `AGENTS.md` | ✅ 完整 | ✅ |
| **L1 契约 SSOT** | `contracts/semantic-function-contract.jsonl`(7.4M)+ `state-cells.yaml`(10K,4 族) + `capabilities.yaml` + `demo-scenarios.yaml` | ✅ jsonl 健全;⚠️ `state-cells.yaml` **只有 4 族,未扩 10 族**(U13 前置);⚠️ `generated/D_domain.tools.json` 已生成但 `tool-card-map.demo10.json` **不存在** | 🔴 **不撑** |
| **L2 OpenSpec specs/**(行为契约 SSOT)| 7 个 capability(demo-experience / lora-training / scenario-state / semantic-function / tool-execution / vehicle-capabilities / vehicle-tool-bench)| ✅ 都有 spec;⚠️ 没有 `demo-golden-run` `voice-pipeline` `ui-presentation` | 🔴 **不撑** |
| **L2.5 OpenSpec changes/**(变更)| 6 个 active change | 🔴 **`define-demo-golden-run-and-voice` 是 DRAFT skeleton——proposal 写完了,但 spec.md 全 placeholder Scenario,没 design.md,没 tasks 具体化** | 🔴 **不撑** |
| **L3 视觉 SSOT(Probe 结论 3)** | `docs/design/tokens.md` / `docs/design/hig-liquid-glass-rules.md` / `docs/design/visual-anchors/*.png` | 🔴 **全部不存在** | 🔴 **不撑** |
| **L3.5 UIUE 决策档** | `docs/research/2026-06-22-uiue-ultracode/`(raw 里有 GRILL-MASTER + 8 lens)落档到本仓 | 🔴 **未落档**(仍在 raw,audit round-01/02 已点名"new_file 待落档");U1–U10 拍在 `grill-decisions-master §3`,U11–U31 待续批 | 🔴 **不撑** |
| **L4 工程前置** | `Info.plist`(NSMicrophoneUsageDescription)/ memory entitlement / `Project.yml` XcodeGen | 🔴 **没有 Info.plist**;🔴 **没有 XcodeGen**;⚠️ `MAFormac.xcodeproj/project.pbxproj` 只 11K(U6 demo-blocker) | 🔴 **不撑** |
| **L5 实现源码** | `App/ContentView.swift`(136 行,**绿/灰二值** L121-127,未消费 DemoVisualState 7 态);`Core/State/DemoVehicleStateStore.swift` **已含 7 态枚举** L17-25 | ⚠️ producer ✅ / consumer 🔴(U10 翻车点原始活体在 `ContentView.swift:121-127`) | 🔴 **不撑** |
| **L6 测试/视觉回归** | `Tests/MAformacCoreTests` 存在;无 snapshot testing;无 simulator screenshot loop | 🔴 **无视觉回归门**——agent 直出 UI 改动 = 盲飞 | 🔴 **不撑** |
| **L7 设计 / agent 协作** | 无 `DESIGN.md` / 无 `frontend-design` skill 加载约定 / 无设计 ref repo | 🔴 全空 | 🔴 **不撑** |
| **L8 多 agent 并行** | git 干净(**51 staged + 29 modified + 66 untracked** ← 这个有点炸);无 worktree 隔离;无文件域切分约定 | 🟡 现在不开第二 agent 还 ok,开就乱 | 🟡 |

**一句话**:**U 系列三十多条任务里,能立即起跑的只有 U6 / U19 / U12 等"工程前置",剩下 80% 都卡在缺 L1.state-cells-10族 / L2.demo-golden-run-spec / L3.视觉SSOT / L5.ContentView-7态 / L6.snapshot-loop 这五条断带上**。OpenSpec 那条 `define-demo-golden-run-and-voice` 现在是个"propose 写了但实质契约 = 空"的纸老虎。

---

# 二、`/pre-mortem` — 开 U 系列前的失败模式

按 Klein/HBR + honnibal + tiger/paper/elephant 三分类。每个 tiger 配"现在应该检查"。

### 🐯 Tigers(明确威胁,HIGH = 停下让磊哥拍)

| # | 失败 | 为什么必出 | 现在该做 |
|---|---|---|---|
| **T1 · HIGH** | **OpenSpec spec.md 是 placeholder,apply 阶段被 strict validate 顶死** | `define-demo-golden-run-and-voice/specs/{demo-golden-run,voice-pipeline}/spec.md` 全是 "DRAFT 占位 — Requirement/Scenario 待人审 propose 时填实"(实查 spec.md:21-23 / :28-31) + 没有 design.md。OpenSpec 文档明确要四件套 `proposal.md / specs.md / design.md / tasks.md`(intent-driven.dev 2026.4) | 起 U 系列前**先把 propose 填实**——补 design.md + 把 placeholder Scenario 替成真 GIVEN/WHEN/THEN |
| **T2 · HIGH** | **state-cells 4 族 → 10 族扩展前,U13/U26 任何卡片网格代码都是死代码** | `contracts/state-cells.yaml` 只 10K 4 族;`tool-card-map.demo10.json` 不存在;U13 拍板"按 family_card_id"无映射可读 | 把 "扩 state-cells 4→10 族 + 出 tool-card-map.demo10.json" 列为 U13/U26 的硬前置(它已经在 codex 那条基线长跑里——但要给 UIUE 端一个"读取契约"先 freeze) |
| **T3 · HIGH** | **ContentView 万能红字 + 绿/灰二值未替换,U10 翻车点持续活体** | `App/ContentView.swift:121-127` 写死 `cell.visualState == .satisfied ? .green : .gray`;但 `DemoVehicleStateStore.swift:17-25` 已有 7 态枚举(normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown)—— **producer 已 ready 但 consumer 未消费**,U10 起手第一刀就是替换这里 | U10 必须**第一时间**改这段,否则后面所有视觉态都建在沙地上 |
| **T4 · HIGH** | **没有视觉锚点 → U2/U5/U7/U11/U14 出来全是 "ChatGPT 默认蓝" 模板** | Probe 结论 3 + reddit r/PromptEngineering 实例("You ask for a modern dashboard and get the exact same default Tailwind blue every single time",buildmvpfast 2026);frontend-design skill 论坛对比图实证:**没视觉方向,UI 全长一样** | 在跑 U2/U7 前**必须**先答 Probe 那条 "One Question to Sit With"——视觉锚点是哪个风格(sci-fi / Apple Landmarks / Linear / Rauno),并出 2-3 张 anchor PNG |
| **T5 · HIGH** | **Liquid Glass 用在内容层 → 整屏糊掉,HIG 违规,NN/g 公开点名"usability suffers"** | `medium @madebyluddy 2026` 明确:**避免** content layer / 全屏背景 / 滚动内容 / 堆叠多层 glass;blakecrosley + reddit r/swift 都报 "frame drops in previews when layering multiple glass modifiers";NN/g 报道 iOS 26 "icons blend into background images" | U2 不能写成"全局主题开关"——必须按 master §3 U2 拍的 `surface_role=control_glass / content_glow`(mic/顶栏),并把这条作为 hig-liquid-glass-rules.md 第一条规则 |
| **T6 · HIGH** | **没有 snapshot testing → U2/U7/U11/U14 改完一次,下次 prompt 改另一处 view 时视觉漂移无人感知** | pointfreeco `swift-snapshot-testing` 已是 SwiftUI 视觉回归事实标准(github 主源 + codeanatomy 2026 "catch visual regressions before users do");MAformac 现在 0 snapshot 测试 | U2/U7 跑前**先**给 `App/ContentView.swift` + 7 态卡片 + commandBar 三个面建 baseline snapshot(用 `assertSnapshot(of: view, as: .image)`),后续每次 PR 跑 |
| **T7 · MED** | **App/ 不在 Package.swift sources 列表里**(实测 `Package.swift:18` 显式 `exclude: ["App", ...]`),UIUE 改 App/ 编译能过但 SwiftPM target 不包含 | 现在 App/ 靠 `MAFormac.xcodeproj` 走 Xcode,不走 SPM——但 codex 那条基线长跑全靠 SPM。**U 系列改 App/ 后 `swift build` 看不见** | XcodeGen project.yml(U12)就是来解这个的——但 U12 之前,**所有 UIUE 改动得在 Xcode 里编译验证**而不是 `swift build`,要写进 AGENTS.md |
| **T8 · MED** | **git 状态 51 staged + 29 modified + 66 untracked**——基线 codex 长跑还在跑,UIUE 直接动会撞 | 实测 `git status` 已经污染;codex 当前在改 `Core/` / `contracts/` / `generated/`,UIUE 要动的是 `App/` / 新建 `Sources/MAformacApp/UI/`(仓里还不存在) | **强制** UIUE 走 git worktree 隔离(developersdigest 2026 主源)—— `git worktree add ../MAformac-uiue uiue/ui-skeleton` |
| **T9 · MED** | **Info.plist 不存在 → 麦克风权限缺,iOS Release build 启动就崩**(U6 demo-blocker,已拍 P0)| `find . -name "Info.plist" -not -path *referencerepo*` 实测 0 项目级 plist | U6 必须在 U-第二批 之前完成——这是真正的硬门,不是软提示 |
| **T10 · MED** | **`docs/research/2026-06-22-uiue-ultracode/` 未落档**,U11-U31 续批没有物理 SSOT,audit 已反复点名 | round-01 audit-1 finding 6 / round-02 audit-2 finding 2 都说"决策权威源指向不存在文件"。U11-U31 实际 SSOT = `grill-decisions-master §3` | 把 `grill-decisions-master §3` 软链 / 摘录到 `docs/research/2026-06-22-uiue-ultracode/INDEX.md`,proposal 改指向 master §3 为主、ultracode 为辅 |

### 🐅 Paper Tigers(看着危险,实际有 mitigation)

| 议题 | 看着 | 实际 | 证据 |
|---|---|---|---|
| "Figma MCP 不接会落后" | 落后于业界 | **场景分流**(Probe H3 置信 95),MAformac 走范式 C 不需 Figma | Codex iOS 官方用例无 Figma(developers.openai.com) |
| "AI 直出 SwiftUI 不成熟" | 全要手写 | **可分层**:layout/state/卡片让 agent 写,shader/Metal/MeshGradient 磊哥手 spike(U30 拍板对应) | iSwift 2026 / Ray Fernando 2026 "Swift iOS Apps with Claude Code 2026 best practices" |
| "DESIGN.md 是新发明会过度治理" | 文件爆炸 | **是 2026 业界事实标准**(buildmvpfast 2026 / Sunday Swift TOKENS.md / Augment Code AGENTS.md 2026),不发明 | 三个独立源主 |
| "snapshot 测试在 SwiftUI 不稳" | 浮点像素差 | pointfreeco 已成熟到 8 年;用 `ImageRenderer`(reddit 主源)+ percentage tolerance | github primary |

### 🐘 Elephants(没人想谈的)

| # | 真问题 | 后果 |
|---|---|---|
| **E1** | **磊哥到底想要什么样的"看着惊艳"——这个问题没回答前,所有 UIUE 任务都是赌博**(Probe "One Question to Sit With" 原话)| 跑了 U2/U7 出来不喜欢→重做→agent 时间炸 |
| **E2** | **UIUE 是磊哥一个人做,还是会派 codex/claude subagent 并行做?** 答案决定要不要写 git worktree + 文件域切分 + DESIGN.md,还是单人 vibe-coding 直跑 | 单人模式 = 范式 C;多 agent = 范式 C + 增 worktree/owner-table 约束(图里那个并行分诊已暗示要多 agent) |
| **E3** | **OpenSpec 4 件套 `proposal/spec/design/tasks` 在 MAformac 实际只用了 3 件**(design.md 在 archive/ 用过,本次 6 个 active change 里只有 `define-lora-data-gate/design.md` + `run-lora-candidate-training/design.md` 有。**`define-demo-golden-run-and-voice` 没有 design.md** —— 这是磊哥踩到的真坑)| 这就是磊哥那句"design.md 不同于 srd"的直觉来源——他对了 |
| **E4** | **51 staged + 29 modified + 66 untracked** 的脏 workspace,再开新分支并行 = 撞车几乎必然 | 开 U 系列前先把基线长跑那波 commit 完 / stash 干净 |
| **E5** | **OpenSpec change 数量从 1 个膨胀到 6 个 active**,6 步依赖序口头存在但**没有谁是 SSOT 在管理顺序**——magnitude_runner 失败信号 | 需要 progress board 文件(master §4.4 GOV Q22 提过) |

---

# 三、磊哥那个 "design.md 不同于 SRD" 是对的——但比你想的多一层

磊哥这个直觉非常准。把它捅破:

## 在 MAformac 语境里,"design"其实有 **两个不同位置**,都需要建:

### Position A:**OpenSpec change 内的 `design.md`** = 实现侧 ARCH

> 由 OpenSpec 官方 schema 规定([intent-driven.dev 2026.4](https://intent-driven.dev/blog/2026/04/29/spec-driven-development-with-adr)、[Sereno 2026 LinkedIn](https://www.linkedin.com/pulse/openspec-spec-driven-workflow-end-programmer-rise-engineer-sereno-lmq2e)):
> *"design.md is where we describe **how to technically implement** what was defined in the spec.md. This is where the architecture is detailed."*

- **spec.md** = WHAT(行为契约 / Requirement SHALL + Scenario GIVEN/WHEN/THEN)
- **design.md** = HOW(架构决策 / 实现选型 / 风险 / ADR 引用)—— **承接磊哥 CLAUDE.md 里说的 "ARCH ≈ design.md"**

**MAformac 当前缺**:`define-demo-golden-run-and-voice/design.md` —— 这是 T1 顶死的真因。

✅ archived change 里都有用过:`archive/2026-06-19-define-c1c2-contract/design.md`、`archive/2026-06-20-define-execution-contract/design.md` 等。**就是这次 UIUE 这条主线忘了起 design.md**。

### Position B:**项目根 `DESIGN.md`**(或 `docs/design/`)= 视觉 SSOT

> 由 2026 业界事实标准规定([buildmvpfast 2026](https://www.buildmvpfast.com/blog/design-md-file-ai-coding-agents-brand-consistency-2026)、[Sunday Swift TOKENS.md 2026](https://sundayswift.com/posts/preparing-ios-codebase-for-ai-agents)、[Augment Code AGENTS.md 2026](https://www.augmentcode.com/guides/how-to-build-agents-md)):
> *"DESIGN.md is quietly becoming the standard for brand consistency across AI coding agents."*
> *"A `TOKENS.md` file in the Tokens module serves as the agent's design reference."*

- 给 Cursor/Claude Code/Codex 读:**色 / 字 / 间 / Liquid Glass 规则 / 视觉锚点链接**
- 在 `CLAUDE.md` / `AGENTS.md` 里加一行 `"Always read docs/design/tokens.md before generating any UI"`
- 这是 **Probe 结论 3 的"视觉 SSOT 三件套"**

### 两个 design 的对应关系

```
┌─ MAformac 推进 ──────────────────────────────────────────────┐
│                                                                │
│  OpenSpec change `define-demo-golden-run-and-voice/`           │
│    ├── proposal.md      ← PRD:为什么这次变更                 │
│    ├── specs/           ← 行为契约 WHAT(SHALL/Scenario)     │
│    │     ├── demo-golden-run/spec.md                          │
│    │     ├── voice-pipeline/spec.md                           │
│    │     └── ui-presentation/spec.md  ← 🆕 建议新加          │
│    ├── design.md        ← 🔴 缺:实现侧 HOW,引用 docs/design│
│    └── tasks.md         ← 拆 U 系列任务                       │
│                                                                │
│  docs/design/ (视觉 SSOT,全局,跨 change 复用)              │
│    ├── tokens.md          ← 🔴 缺:色/字/间/动效            │
│    ├── hig-liquid-glass-rules.md ← 🔴 缺:HIG 约束剧本     │
│    ├── visual-anchors/    ← 🔴 缺:2-3 张视觉锚点 PNG     │
│    └── INDEX.md           ← 🔴 缺:被 CLAUDE.md 引用        │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

**两者都建是对的**,不重复——design.md 在变更层(一次性,归 archive),docs/design/ 在项目层(长期,跨变更复用)。

---

# 四、补齐方案:四批可并行、可验证的具体动作

按 Probe 结论 + Pre-Mortem tigers 反推,按"做完这批能干啥"分批,每条都带**文件路径 + 验证点**。

### 🔧 批次 0:**回答 One Question + 清场**(半小时,磊哥本人)

| 动作 | 输出 | 验证 |
|---|---|---|
| **0.1** 回答 Probe 那个 "看着惊艳" 视觉锚点是什么 | 一句话 + 3 个参考产品(如 "Linear 暗调 + Apple Landmarks 文艺 + 极少 sci-fi 高光")| 后面 0.2/1.3 可以引用 |
| **0.2** 现在 `git status` 处理 | 51 staged 该不该 commit,66 untracked 该不该 stash | `git status` 显示干净基线 / `git worktree list` 准备好 |

### 🏗 批次 1:**视觉 SSOT 三件套 + DESIGN.md**(不依赖任何东西,UIUE agent 可直接做)

| 动作 | 文件 | 内容来源 | 验证 |
|---|---|---|---|
| **1.1** | `docs/design/tokens.md` | master §3 U2/U10/U11 拍板(base `#0a0b12` + `surface_role=control_glass/content_glow` + DemoVisualState 7 态色) | `grep` 出 7 态色全部出现 |
| **1.2** | `docs/design/hig-liquid-glass-rules.md` | medium @madebyluddy 主源 + Apple WWDC25 #323 + master §3 U2/U5/U7/U19/U30 | 包含 "functional layer only" + iOS18/iOS17 `#available` fallback 模板 + frame drops 预警 |
| **1.3** | `docs/design/visual-anchors/{a,b,c}.png` + `README.md` | 0.1 锚点风格 → Stitch/Visily 出 + 手调(或对 Apple Landmarks demo 改色调)| 3 张图 + 每张配 "学什么 / 不学什么" 注 |
| **1.4** | `docs/design/INDEX.md`(或根 `DESIGN.md` 路由)| 路由到 1.1/1.2/1.3 | 被 `CLAUDE.md` 加一行 "起手前先读 docs/design/INDEX.md" 引用 |
| **1.5** | `CLAUDE.md` 补一段 "UI 生成前必读 docs/design/INDEX.md"(buildmvpfast 2026 业界事实做法)| — | grep `CLAUDE.md` 命中 |

### 🧪 批次 2:**OpenSpec 把 demo-golden-run-and-voice 从 DRAFT 变 propose-ready**(依赖 0.1,可与批次 1 并行)

| 动作 | 文件 | 内容 |
|---|---|---|
| **2.1** | `openspec/changes/define-demo-golden-run-and-voice/specs/demo-golden-run/spec.md` | placeholder Scenario → 真 GIVEN/WHEN/THEN(按 master §3 U4/U8/U9 + F3 拍板) |
| **2.2** | `openspec/changes/define-demo-golden-run-and-voice/specs/voice-pipeline/spec.md` | placeholder → 真 Scenario(按 D14 + ASR amend) |
| **2.3** | `openspec/changes/define-demo-golden-run-and-voice/specs/ui-presentation/spec.md` 🆕 | **新加 capability**:DemoVisualState 7 态契约 + tool-card-map.demo10.json 字段 + Liquid Glass surface_role + ContentView 替代 ContentView:121-127 二值判定 |
| **2.4** | `openspec/changes/define-demo-golden-run-and-voice/design.md` 🔴**缺这个** | ARCH 决策 + 实现路径 + 引用 docs/design/tokens.md + ADR 链 + 风险(HIG 误用 / iOS18 守卫 / shader frame drop / snapshot baseline)|
| **2.5** | tasks.md 拆 U1-U31 为 OpenSpec task 颗粒(不再是 "U10 物理落点" 一行)| — |
| **2.6** | `openspec validate define-demo-golden-run-and-voice --strict` 通过 | exit 0 |

### 🛠 批次 3:**工程前置硬门**(U6/U12/U19,可与批次 1 并行,给 codex/UIUE 共用)

| 动作 | 文件 | 拍板 |
|---|---|---|
| **3.1** | `App/Info.plist`(NSMicrophoneUsageDescription + Bundle*)| U6 |
| **3.2** | `App/MAformac.entitlements`(kernel.increased-memory-limit)| U6 |
| **3.3** | `project.yml`(XcodeGen,可降 P1)+ `make xcodegen` Make target | U12 |
| **3.4** | iOS 17/18 兼容守卫 helper `Sources/MAformacApp/Support/Availability.swift`(封装 `if #available(iOS 18, *)` 模板)| U19 |
| **3.5** | `Tests/MAformacAppTests/Snapshots/`(pointfreeco swift-snapshot-testing 依赖,CommandBar+Card+TracePanel baseline)| T6 mitigation |
| **3.6** | `Package.swift` 把 `App/` 移出 `exclude:` 列入 `MAformacApp` target(or 等 XcodeGen 处理)| T7 mitigation |

### 🎨 批次 4:**真正起跑 U 系列**(依赖 0.1/1.x/2.x/3.x)

按 master §3 + Probe + Pre-Mortem 给的并行分诊:

- **🟢 立刻并行(依赖只到批次 1 + 3)**:U1 / U2 / U6 / U7 / U10 / U11 / U12 / U14 / U19 / U23 / U24 / U27(**U10 这条第一优先——把 ContentView:121-127 替成 7 态消费**)
- **🟡 等批次 2 spec**:U21 / U22 / U28 / U30
- **🔴 等 codex 基线 + state-cells 扩 10 族**:U3 / U13 / U26 / U4 / U8 / U9 / U17 / U29
- **🔴 等三层路由实装**:U15 / U20 / U25

每条都加 snapshot test → 视觉回归门兜底。

---

# 五、推荐推进顺序(一图收口)

```
[今天/明天 · 磊哥本人 30min]
  └─ 批次 0:回答 "看着惊艳" + 清 git 状态
       │
       ├──→ [批次 1 · UIUE 端(agent 或磊哥)半天]
       │      └─ docs/design/{tokens.md, hig-liquid-glass-rules.md, visual-anchors/*.png, INDEX.md}
       │            + CLAUDE.md 引用
       │
       ├──→ [批次 2 · 主线 agent 半天～1 天]
       │      └─ OpenSpec change 4 件套补齐 + ui-presentation capability + design.md
       │            + openspec validate --strict 通过
       │
       └──→ [批次 3 · UIUE 端(agent)半天]
              └─ Info.plist / entitlements / project.yml / snapshot baseline / Package.swift App/ 修正
                    │
                    └──→ [批次 4 · U 系列正式开 · 多 agent worktree 并行]
                            └─ U10 头号刀 → U6/U19/U2/U7/U11/U14/U12/U1/U23/U24/U27 并发
                                  → 等 codex state-cells 10 族落地 → U3/U13/U26/U4/U8/U9
```

---

## 我会建议磊哥现在拍三件事

要不要直接动?我建议先拍这三个 fork(每个都是单选):

1. **批次 0.1 "视觉锚点"现在答还是延后?**——延后则批次 1.3 阻塞,U2/U7 都不开
2. **批次 2 那个 `ui-presentation` 新 capability 拆出来还是继续塞进 demo-golden-run?**——拆出来更符合 OpenSpec 单一职责,但多一份 spec 维护
3. **UIUE 起 git worktree 单独跑(隔离 codex 基线长跑),还是单仓硬扛?**

要么磊哥拍这三个,要么我直接按"默认选项"起一个 `todo` 列表 + 一个 `define-demo-golden-run-and-voice` 的 design.md 草稿(包含上面整套 ARCH 决策 + 风险表),磊哥审完就能 propose → apply。

---

# 六、灵感溯源(Inspiration Trace)

```
## OpenSpec design.md 定位
- [Architectural Decision Records with Spec-Driven Development (intent-driven.dev 2026.4)](https://intent-driven.dev/blog/2026/04/29/spec-driven-development-with-adr) — HIGH | OpenSpec 四件套官方定义
- [OpenSpec: A Spec-Driven Workflow (Sereno LinkedIn 2026)](https://www.linkedin.com/pulse/openspec-spec-driven-workflow-end-programmer-rise-engineer-sereno-lmq2e) — MED | design.md = how to technically implement spec.md
- [Architecture Decision Records with SDD using OpenSpec — YouTube](https://www.youtube.com/watch?v=y5oemaPsmOA) — MED | ADR 与 design 关系
- [A Practical Development Guide Based on OpenSpec + Claude CLI (jxausea Medium 2026)](https://jxausea.medium.com/a-practical-development-guide-based-on-openspec-claude-cli-26da7df71356) — MED | 实战流程

## DESIGN.md / TOKENS.md 业界事实标准
- [DESIGN.md for AI Coding Agents (buildmvpfast 2026)](https://www.buildmvpfast.com/blog/design-md-file-ai-coding-agents-brand-consistency-2026) — HIGH | DESIGN.md 命名 + 业界采用
- [Preparing Your iOS Codebase for AI Agents (Sunday Swift 2026)](https://sundayswift.com/posts/preparing-ios-codebase-for-ai-agents) — HIGH | TOKENS.md 在 iOS 模块化 AGENTS.md 范式
- [How to Build Your AGENTS.md 2026 (Augment Code)](https://www.augmentcode.com/guides/how-to-build-agents-md) — HIGH | AGENTS.md 协议规范

## Liquid Glass / SwiftUI 视觉天花板
- [iOS 26 Liquid Glass: Comprehensive Reference (Medium @madebyluddy)](https://medium.com/@madebyluddy/overview-37b3685227aa) — HIGH | content layer 禁忌 + 堆叠层级 + 全屏背景禁忌
- [Liquid Glass in SwiftUI: Three Patterns From Shipping Return (blakecrosley)](https://blakecrosley.com/blog/liquid-glass-swiftui-patterns) — HIGH | functional layer / mirror pattern / 实战
- [Liquid Glass Is Cracked, Usability Suffers (NN/g)](https://www.nngroup.com/articles/liquid-glass) — HIGH | 第三方权威批评,icons blend
- [iOS 26 Liquid Glass best practices for SwiftUI views (reddit r/swift)](https://www.reddit.com/r/swift/comments/1nw8qp6/ios_26_liquid_glass_best_practices_for_adapting) — MED | frame drops when layering

## Snapshot Testing
- [pointfreeco/swift-snapshot-testing (GitHub)](https://github.com/pointfreeco/swift-snapshot-testing) — HIGH | 事实标准 8 年历史 + ImageRenderer 支持
- [Snapshot Testing in SwiftUI: Catching Visual Regressions (codeanatomy 2026)](https://www.codeanatomybyaher.com/articles/snapshot-testing-swiftui-visual-regressions) — MED | dark/light/accessibility 多场景
- [SwiftUI Snapshot Testing using ImageRenderer (reddit r/SwiftUI)](https://www.reddit.com/r/SwiftUI/comments/1laq1hq/swiftui_snapshot_testing_using_imagerenderer) — MED | 纯 SwiftUI 路径
- [Point-Free Episode #86 SwiftUI Snapshot Testing](https://www.pointfree.co/episodes/ep86-swiftui-snapshot-testing) — HIGH | 官方教学

## Multi-Agent Parallel Workflow
- [Git Worktrees + Claude Code: 2026 Playbook (Developers Digest)](https://www.developersdigest.tech/blog/git-worktrees-claude-code-parallel-agents-guide) — HIGH | 多 agent 并行隔离主源
- [Best Git Worktree Tools for AI Coding 2026 (Nimbalyst)](https://nimbalyst.com/blog/best-git-worktree-tools-ai-coding-2026) — MED | 工具对比
- [Git Worktree Multi-Agent Setup (Termdock)](https://www.termdock.com/en/blog/git-worktree-multi-agent-setup) — MED | 3 agent 3 worktree 实战
- [From 3 Worktrees to N (Laurent Kempé 2026.3)](https://laurentkempe.com/2026/03/31/from-3-worktrees-to-n-ai-powered-parallel-development-on-windows) — MED | 多 worktree 规模化

## frontend-design / 视觉漂移
- [Claude Frontend Design Skill: Install + 3 Worked Examples (FindSkill.ai)](https://findskill.ai/blog/claude-frontend-design-skill) — MED | frontend-design skill 实战
- [Use Claude Code DESIGNER Skill to 10x UI Designs — YouTube (DesignCourse 2026.2)](https://www.youtube.com/watch?v=Em9EzurouOU) — MED | skill 使用对比
- [Rating Claude Code skills: frontend-design (reddit r/ClaudeAI)](https://www.reddit.com/r/ClaudeAI/comments/1rafmpg/im_rating_every_claude_code_skill_i_can_find) — MED | 有无 skill 视觉对比图
- [Swift iOS Apps with Claude Code: 2026 Best Practices (Ray Fernando)](https://www.youtube.com/watch?v=pm4yIrUYhb4) — HIGH | iOS+Claude Code 实战 + Xcode Build MCP + AGENTS.md
```

---

# 七、归档

- 本档为 Pre-Mortem Report v1 全量归档
- 上游 = 同日 Probe Report v3(`docs/research/2026-06-23-probe-uiue-agent-paradigm.md`)
- 触发时间:2026-06-23 13:30
- 深度:standard(含 scout 内部基建实查 + oracle 外部 web search 6 路)
- Klein/HBR 协议:✅ tiger/paper-tiger/elephant 三分类全跑 + HIGH 停下让磊哥拍 3 fork
- 实证基建实查:Sources tree / Package.swift exclude / App/ContentView.swift:121-127 / DemoVehicleStateStore.swift:17-25 / contracts/state-cells.yaml 10K / Info.plist 不存在 / OpenSpec changes 6 active + DRAFT skeleton 实证 / git status 51+29+66 已实测
- 一字不差归档:✅ 与上轮 Pre-Mortem 输出全量一致,无裁剪
