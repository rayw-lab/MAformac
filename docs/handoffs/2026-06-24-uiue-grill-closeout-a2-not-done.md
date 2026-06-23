# Handoff 2026-06-24 — UIUE D1-D7 grill 收口 + ⭐A 三处级联 + A2 未结束纠正

> worktree `MAformac-uiue`（分支 `uiue/visual-ssot-state-consume`），链路 A（UIUE 前端）。与主工作树 A2/训练（链路 B）两 worktree 并行。

## 一、本次完成（已审计 CLEAR）

1. **⭐A 三处级联**（grill 决策物理化进基线，subagent CC 审计 CLEAR 无 P0/P1）：
   - ① `grill-decisions-master.md §3` 加「D1-D7 决策晶体表」+ D7 新增「7 态逐态视觉消费」+ 30 grill 的 A2 影响列 + **11 复议确认**（全溯源盲评 final-list §A-E）+ U11 同步 #121212。
   - ② `docs/design/tokens.md` base `#0a0b12`→**`#121212`** 软黑（D2#2，halation 降饱和 `.10-.14`）。
   - ③ `docs/uiue-roadmap-2026-06-23.md` 去 DRAFT（git mv）+ §〇.0 进度快照 + 3 fork 标已拍 + §六 合并策略；**`openspec/changes/ui-presentation/` change skeleton**（5 文件含 design.md，标**非 DEFERRED**=活跃前端轨）。
2. **loop-competition 技能二次升级**（结合 `workflow.output.json` 执行步骤）：5 条 Execution-Step Pitfalls + Judge schema 加「Divergent Candidates / dispute-type」列。
3. **claim-vs-reality 纠正**：A2「已结束」是文档声称，实况「旁边分支还在审计 A2 修复循环」→ A2 **未结束**；roadmap §六 + §〇.0 已改（A2 审计绿后才并 main + 训练线三步非直接训）。

## 二、🔴 本次 grill 的精髓（方法论，磊哥点名要写清）

> 这是「UIUE 决策怎么 grill 出来 + 怎么验」的可复用范式，比结论更值得带走。

1. **二次深 grill（D1-D7）= 在 U1-U31 一轮之上聚焦深挖**。每个 D 的配方 = **CC 5×⭐概念**（先给 5 个候选 + ⭐默认）→ **Codex 5Q×2 物理化**（同源 entry / 派生表 / enum / 契约，把概念落成 file:line 可验的物理形态）→ **主线程辩证 check**（anti-confirmation：不盲吸收 Codex，谨慎迎合，catch 出 codex 的 claim-vs-reality 错——D6 就 catch 了我自己 3 处幻引用）。**grill-first：想清楚才落，不跳 explore 直奔 propose**。
2. **loop-competition 盲测盲评 = anti-confirmation 的机械化**。30 决策抽成中性盲版（删 ⭐/理由/物理化）→ 4 split 视角（可行性/事实核/风险/更优）× 3 轮 × judge 非多数 → **假装没 grill 过从零审**。真盲核验 = transcript 有无 Read grill 工具调用（非 grep 文件名）。**盲评的最大价值 = catch grill 锚定漏的盲点**：本次 catch 出 2 个 gap（投屏 banding / 7 态消费）+ 冗余（C19/C20 并 C4）+ halation 锁死（base 上抬）+ 断网哑火（voice 离线坐实）——这些 3 轮 grill 全漏了。
3. **dispute-triage 在 loop-comp 里涌现**：judge 自发给 divergence 打「事实型/口径型/混合」标签 → 事实型 cite-verify（或需外部数据则 escalate-to-spike，别空转轮次）/ 口径型上抛拍板别再核。已升进 SKILL.md。
4. **claim-vs-reality 贯穿**：文档声称 ≠ 实况。「A2 已结束」（文档）vs「审计修复循环中」（实况）；voice「延迟很低」（记忆）vs「immediate-ack 掩盖术，端侧难达 300ms」（决策原文）。**写每个数字/状态前问：这是声称层还是事实层**。
5. **D4 磊哥纠正推翻镜像**：我主张「iPhone 极简只读」，磊哥纠「iPhone 要脱机独立演示」→ 重构为 **Mac+iPhone 两独立纯端侧 demo 实例**（删 sharedFile 镜像，TransportKind{none,bonjour}）。教训：demo 取巧不能砍到「核心演示能力」。

## 三、后续做啥（UIUE 新文件夹并行任务）

> 按 `docs/uiue-roadmap-2026-06-23.md` 7 Phase。**Phase 0/1a/D1-D7 grill 已 done**。下一步两条不依赖 A2 的硬骨头：

**严格序（agree-before-build + 不依赖 A2 优先）**：

| 优先 | 任务 | 依赖 | 说明 |
|---|---|---|---|
| **A（可立即起，无需 propose）** | Phase 1b 工程前置脚手架 | ❌不依赖 A2 / 不算 capability 实现 | `App/Info.plist`(NSMicrophoneUsageDescription)+`entitlements`(memory)+`Availability.swift`(#available)+snapshot baseline。U6 demo-blocker，接麦克风/模型不崩的前置。 |
| **B（需先 propose ui-presentation）** | Phase 3 D7 头号刀 | 需 ui-presentation propose 通过（agree-before-build）| `ContentView:122/:126` 绿灰二值 → DemoVisualState 7 态穷尽 switch + 四态分开。❌不依赖 A2（消费端态枚举非 D-domain 工具名）。 |
| **C（部分依赖 A2 并 main）** | Phase 4 卡片网格 | 需 rebase main 拿 A2 的 D-domain 产物 | ui_value_type 派生 + Grid 改 + family-device-allowlist row_count 排序。 |

**下次第一步建议**：
1. 🔴 **先拍：是否 propose `ui-presentation` change**（现是 DRAFT skeleton，spec.md 是 placeholder Scenario）。文档先行铁律——propose 填实 spec 后才 apply 写代码（Phase 3/4）。
2. **同时 Phase 1b 工程前置可并行起**（脚手架不算 capability 实现，不卡 propose）。
3. UIUE 起手 **不必等 A2 审计绿**（只 Phase 4 要 A2 产物时才 rebase main）。

## 四、当前状态

- **git**：`uiue/visual-ssot-state-consume @ 未 commit`（本次 ⭐A 三处级联 + roadmap 修正待 commit；审计 CLEAR 可 commit）。
- **A2（链路 B）**：主工作树 `a2/migrate-d-domain-tool-surface`，**审计修复循环中（未结束）**——磊哥旁边窗口在跑。A2 绿 + 并 main 后才起训练线。
- **训练线（A2 之后，DEFERRED）**：C5 数据生成 → C5 重训 → C6 四层评测（三步，非 A2 完直接训）。
- **测试**：本次纯文档 + skill 升级，无代码改动；UIUE 代码（Phase 1b 起）尚未开工。

## 五、关键文件（≤5）

1. `docs/uiue-roadmap-2026-06-23.md` — UIUE 推进 SSOT（7 Phase + 依赖图 + §六 合并策略）。
2. `docs/grill-tournament/grill-decisions-master.md §3` — D1-D7 决策晶体 + 11 复议（决策 SSOT）。
3. `docs/grill-tournament/uiue-d1-d6-grill.md` — D1-D6 grill 一手（每 D 的 5×⭐+物理化+辩证）。
4. `docs/loop-competition/uiue-grill-scoring/final-list.md` — 30 决策盲评 + 复议清单。
5. `openspec/changes/ui-presentation/` — change skeleton（待 propose）。
