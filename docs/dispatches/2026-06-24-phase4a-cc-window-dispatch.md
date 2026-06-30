# 派单 prompt — MAformac UIUE Phase 4a 全自动实装（丢给另一个 CC 窗口，本目录）

> 下方 code block 内即派单 prompt，magnet 复制粘贴到另一个 Claude Code 窗口（cwd=`/Users/wanglei/workspace/MAformac-uiue`）执行。设计 = heavy-work harness 骨架 + ⭐B' 执行策略 + 强视觉 + claim-vs-reality enforce。

```
你是 Claude Code，在 MAformac-uiue worktree（cwd 即本目录）全自动完成 UIUE Phase 4a（10 族车控卡片 scope 呈现摘要层）。计划已经过 grill 收口 + subagent 对抗审计（2 P0/4 P1 已修）。你的活是【高质量、强视觉、harness enforce、实跑非声称】地把它实装出来。

## 起手必读（不读不动手，5 分钟恢复 context）
1. ⭐ 任务 SSOT（逐 task 代码+TDD）：docs/superpowers/plans/2026-06-24-phase4-card-scope-presentation.md —— 这是你的执行手册，每个 Task 有完整代码和 step。
2. 决策源：docs/grill-tournament/uiue-phase4-grill-decisions.md（P4-D1 ⭐C''/D2/D3）。
3. 契约 SSOT：openspec/changes/ui-presentation/specs/ui-presentation/spec.md（value.type :83 / scope 角标 :171）。
4. skill 索引：docs/design/uiue-skill-playbook.md（哪个 task 调哪个 skill + 抄哪段 ref-repos 代码）。
5. 视觉 SSOT：docs/design/INDEX.md（写任何 view 前必读，禁 prompt 即兴配色）。
6. 元认知铁律：~/.claude/rules/claim-vs-reality-gap.md（前任接线丢失 + 本计划 2 个 P0 都是它的活样本）。

## 核心纪律（harness enforce，违即返工）
- 🔴【实跑非声称】每个「完成」必附【实跑日志】：swift test 输出 / pre-commit reject 输出 / 截图路径。禁「我写了/我做了」。claim-vs-reality 铁律2：单测绿≠接线完成（测 displays 纯函数≠ContentView 真调用它，proof 图就这么丢的）。
- 🔴【边界】只改 App/ + Core/Presentation/ + openspec/changes/ui-presentation/ + docs/；禁碰 Core/State/ + contracts/ + generated/（A2 owned，碰即越界）。
- 🔴【vehicle.* 不渲】FamilyCardIDMapper 对 vehicle.*/未知返 nil，familyDisplays 过滤（magnet 已拍，不加第 11 族）。
- 🔴【spec 硬约束】value.type 5 类穷尽 switch 禁 AnyView / 卡片按 10 族 family_card 非 191 device / Grid 固定列非 LazyVGrid / 内容层卡片禁 .glassEffect() / .contentTransition(.numericText()) 必 withAnimation 包裹 / breathe 仅激活态用 .repeatForever 非裸 Timer。
- 🔴【随时记录】遇任何坑/纠错，当场追加 docs/lessons-learned.md（不攒）。

## 执行编排（heavy-work 状态机，每 step = 做+实跑gate+commit）
### 阶段 1 — 机械 TDD（Task 1/2/3，0 spike 0 视觉 0 风险，一气呵成）
- Task 1 文档先行：写 design.md AD-9/10/11 + proposal Files to modify → 跑 `openspec validate ui-presentation --strict` 绿 → commit。同步纠 design.md AD-2/tasks.md 4.1 路径 stale（计划级联清单有）。
- Task 2 FamilyCardIDMapper：先调 Skill(axiom-testing) → 写 failing test（含 vehicle.speed/gear→nil 断言）→ 跑失败 → optional 实现 → 跑通过 → commit。
- Task 3 FamilyPrimaryCellMapper：同 TDD 循环 → commit。
- 返回：3 个 task 各自的 `swift test --filter` 实跑输出。

### 阶段 2 — display 接线（Task 4/5，核心，调 skill）
- Task 4 VehicleCardDisplay family 分组 + BadgeRenderStyle：🔴 复用现有 UIValueTypeMapper.swift:54-129 的 scope 聚合逻辑【不重写】（重写会回归，现有 5 测试覆盖裂缝⑤⑥④）；真新增仅 BadgeRenderStyle 二级 enum + family 维度 + 过滤 vehicle nil → swift test 现有 5 测试不破 + 新测绿 → commit。
- Task 5 ContentView 接线：🔴 写 view 前 Skill(axiom-design) + 读 docs/design/INDEX.md。vehicleCards 改 Grid（删 LazyVGrid）渲 familyDisplays；VehicleStateCard 接 display model + scope 角标(content_glow 非 glass) + numericText(必 withAnimation) + breathe(仅激活态) + ambient 色块炸场。调 Skill(axiom-swiftui) 写 Grid/动画。build 两端：调 Skill(ios-simulator-skill) 跑 xcodebuild macOS+iOS SUCCEEDED；报错调 Skill(axiom-build)。

### 阶段 3 — enforce + 强视觉（Task 6，最关键 anti-claim 门）
- Task 6 enforce gate：写 Tools/checks/check-contentview-uses-display-catalog.sh（strip 注释 + 验真调用 familyDisplays(from:）→ 接 .githooks/pre-commit + 纠 stale 注释。
- 🔴🔴【三场景自验，必返回实跑输出，非声称】：① 注释掉 ContentView 的 familyDisplays 调用 → `git commit` 被 reject（贴 reject 输出）② 加一行纯注释 `// familyDisplays(from:` → 仍 reject（贴输出，证明 strip 生效）③ 恢复 → 通过（贴输出）。这是 P0-2 修复的真实性证明，magnet 要看三段实跑日志。
- 🔴【force-state 14 张强视觉】调 Skill(ios-simulator-skill)：simctl 启动整 app（非 ImageRenderer，它截不出 Liquid Glass=假绿）→ force-state 跑 7 态×关键场景 14 张 → 存 Reports/uiue-phase4a-proof/。过 5-gate（层级/对齐/遮挡/字号/重量）+【还原投屏实查】不看高清导出图（claim-vs-reality 第10坑：你导出的高清图好看≠用户实查看得清）。氛围灯色块要炸场，配色浅色高对比。

## skill 必用清单（能用就用）
axiom-testing(每个 TDD) / axiom-swiftui(Grid/animation/containers) / axiom-design(HIG/scope角标/SF Symbols) / ios-simulator-skill(视觉验收+force-state ⭐⭐每阶段) / axiom-build(build诊断) / axiom-performance+ios-ettrace(breathe/炸场帧率)。依赖缺了直接装（已授权），simctl/截图/xcrun 一切权限已授。macOS 截图留干净屏幕防隐私。

## 收口 + 异源验收（指定流程，别同源自审蒙混）
- Phase 4a 验收门：swift test 全绿(含3新测+前任5测不破，实跑 `swift test --filter VehicleCardDisplayTests`=5 passed) + xcodebuild 两端 SUCCEEDED + make verify exit 0 + pre-commit 三场景自验实跑 + force-state 14 张 5-gate + 文档级联(tasks勾/design AD-9/10/11/lessons回写)。
- 🔴【验收门全绿后，执行【指定】异源验收，不是自己宣布完成】：
  1. push 分支到 github：`git push -u origin uiue/phase4-default-scope-presentation` → `gh pr create`（title「UIUE Phase 4a 卡片 scope 呈现摘要层」，body 含：变更摘要 + 全部实跑日志(swift test/三场景reject) + force-state 14 张截图说明 + 4a 验收门勾选）。拿到 PR url。
  2. 🔴【云端 GPT Pro 异源审】调 gptpro 技能 audit：`/gptpro audit PR <PR-url>`（后台开 chatgpt-bridge，自动启用 GitHub connector + 8 维度深度审计）。等 GPT Pro 审计报告 watch + download 回来。这是异源(OpenAI 系，规避你 Claude 同源盲区)最终验收。
  3. 收 GPT Pro findings 走辩证 4-step：真 finding 亲核坐实再修 / DEFERRED 给 rationale / 别盲信全修也别懒 defer / 撞项目已锁决策 steelman。把【GPT Pro 审计报告 + 你的辩证收 + 修复】返回 magnet。
- 🔴 阶段 1-3 + push + gh pr create + gptpro audit PR 跑完才【停】返回，**别自己宣布「4a 完成」**——以云端 GPT Pro 异源审 + magnet 拍为准。

## 返回格式（每阶段）
做了什么 + 实跑日志(命令+输出) + 遇坑 lessons + git log。无实跑证据的「完成」不接受。
```

## 派单设计元认知（给 magnet，非派单内容）
- **heavy-work 骨架**：分 3 阶段状态机，每 step 做+实跑 gate+commit；阶段 1（机械 TDD 0 风险）可一气呵成，阶段 3 enforce 三场景自验是 anti-claim 核心。
- **⭐B' 落地**：Task 1-3 机械（fresh subagent 友好）/ Task 6 三场景返回实跑输出（堵 P0-2 同构假绿）/ Task 5+6 异源最终验收（规避同源盲区，呼应 cross-vendor-final-audit）。
- **claim-vs-reality enforce**：全程「实跑非声称」+「单测绿≠接线」+「异源审」三道，正是这次审计抓的两个 P0 的结构答案。
- **skill 强制点名**：每 task 绑 skill，ios-simulator-skill 作强视觉主门（非 ImageRenderer 假绿）。
