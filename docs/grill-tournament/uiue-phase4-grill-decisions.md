---
type: uiue-phase4-grill-decisions
status: ACTIVE（Phase 4 卡片 scope 呈现 实装 grill 一手；CC 接手从 0 重做）
date: 2026-06-24
owner: UIUE 链路 A（worktree MAformac-uiue, 分支 uiue/phase4-default-scope-presentation）
方法: grill-with-docs engineering-contract mode + codex-answer-grill 辩证（two-layer check + frame-break）
关联:
  - docs/grill-tournament/grill-decisions-master.md §3（UIUE 决策晶体 SSOT，本档挂为 Phase 4 实装细化）
  - openspec/changes/ui-presentation/（Phase 4 契约 spec.md:83-94 value.type + 171-191 scope 角标，tasks 4.x/7.A）
  - docs/uiue-roadmap-2026-06-23.md §二（Phase 4）+ docs/design/uiue-skill-playbook.md
背景: 前任（codex）做过 Phase 4 接线（proof 图 Reports/uiue-phase4-proof/ 为证），但工作树未提交 + 被 reset 冲回 HEAD 丢失（git 不可恢复：无 commit/stash/dangling）→ CC 接手从 0 重做（codex 不适合前端）。孤立 display model 模块幸存（Core/Presentation/UIValueTypeMapper.swift 405 行 + Tests 3706 bytes，untracked）可当起点。
---

# Phase 4 grill 决策晶体

## P4-D1 — Phase 4 边界 = ⭐C'' 三阶段 incremental apply（2026-06-24 磊哥拍「认」）

**决策**：Phase 4 卡片 scope 呈现分三阶段，走 **ui-presentation change 的 incremental apply**（每阶段一个小 PR 并 main），**不新建 change**。

| 阶段 | 内容 | physical landing | 风险/enforce |
|---|---|---|---|
| **4a** | 接线（display model→ContentView）+ scope 角标（裂缝⑤淡显/⑥聚合 badge/④升级聚合）+ 7态(已 D7) + **低风险炸场两件** | `openspec apply ui-presentation` tasks 7.A1-A4 + 4.2 接线 | pre-commit `displays(from:)` gate + 14 张 force-state artifact |
| **4b** | value.type 异构控件（dial=`Gauge(.accessoryCircular)` / stepper=`DSSegmentedControl` / percent=`Gauge(.accessoryCircularCapacity)` / toggle / badge）| ui-presentation apply tasks 4.1；控件选型 ADR 进 ui-presentation design.md | Gauge `.accessoryCircular`(非 watchOS `.circular`) + Grid 内 mge spike 先验 |
| **4c** | 触发聚焦展开（D2 族内下钻 / D5 聚焦过渡 mge vs opacity）| 暂缓，4b spike 收口再起 | — |

**4a 低风险炸场两件**（不要纯文本值，违北极星「看着惊艳」）：
1. `ShipSwift SWKPICard:135` `.contentTransition(.numericText())` 数字滚动 —— 🔴 **必 `withAnimation` 包裹否则静默不动**（pre-mortem F-LB2 silent-failure tiger，3 lens 命中），不是「0 风险」
2. `Orb RotatingGlowView:42-61` 单卡 breathe glow —— 🔴 **仅激活态 breathe**（10 张同屏=10 offscreen pass，pre-mortem T1）+ `.repeatForever` 非裸 Timer（F-LB3 CPU 100%）

### pre-mortem triage（P4-D1）
- 🐯 **tiger**：4b 的 Gauge `.accessoryCircular`（watchOS `.circular` 用错=编译错）+ Grid 内 matchedGeometry 运行时冲突（pre-mortem HIGH，未验）→ 留 4b spike，不进 4a
- 🐘 **elephant（最值）**：从 0 重做的真风险不是「做不做得出」，是「**做完没提交又丢一次**」——proof 图丢失根因 = 接线只在工作树+单测绿+以为做完。故 4a 第一优先 = **pre-commit enforce 闸**（机械堵死「接线没接但测试绿」），不是先堆控件
- 📄 **paper-tiger**：「分阶段=慢」伪——4a 半天可 demo，4b value.type 控件并行 spike；且 spec 已锁（agree-before-build 满足），无需重新 propose

### evidence（cite-verify 坐实，完整可核路径）
- `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:83`（`ui_value_type` 5类 dial=环形仪表 + 穷尽 switch + 禁 AnyView）+ 同文件 `:171`（`Requirement: card SHALL consume per-cell default_scope`，淡显/聚合/同源 SHALL）
- `openspec/changes/define-demo-default-scope/specs/tool-execution/spec.md`（仅 tool-execution capability，后端 scope_origin defaulted/explicit/fanout，无 UIUE 渲染）→ 4a 接线落 ui-presentation 非 define-demo-default-scope
- `openspec/changes/ui-presentation/tasks.md:4`（apply 状态「Phase 4 代码 apply 待」）+ 同文件任务行 `:39`（ui_value_type 派生）、`:40`（穷尽 switch 渲染）、`:62`–`:65`（scope 呈现 7.A 段）= Phase 4 全任务已拆好
- `contracts/state-cells.yaml` default_scope 11 处 ready（grep -c 核实，不用 rebase）
- `Core/Presentation/UIValueTypeMapper.swift` 405 行（wc -l）+ `Tests/MAformacCoreTests/VehicleCardDisplayTests.swift` 3706 bytes（wc -c）核实

### two-layer check（codex-answer-grill 3 点辩证，2026-06-24）
codex 补强 3 点方向对，但 verify+discovery catch 3 处：
1. **点1 change 归属 catch（最大）**：codex 说「4b 必须新建 change / 4a 落 define-demo-default-scope」→ **错**，ui-presentation spec 已锁 value.type(83-94)+scope角标(171-191)，**不新建 change**，三阶段=ui-presentation incremental apply；define-demo-default-scope 是后端非 UIUE 接线落点。**frame-break**：Phase 4 是 apply 问题非 grill 问题（文档先行早做完）
2. **点2 enforce 认同（最强补强）**：pre-commit `grep ContentView 必 call displays(from:)` + force-state artifact = 防 proof 图丢失重演，零增量（配已有 pre-commit）。codex 引「F-LB7」编号是编的（playbook 无 F-LB 编号），内容/行号对
3. **点3 风险措辞修正**：codex 标「0-spike/0 风险」乐观 → numericText silent-fail tiger(必 withAnimation) + breathe 仅激活态；方向对（4a 加低风险炸场），lineage 保留 ⭐C'（不另起 ⭐D）

---

## P4-D2 — ui_value_type 映射 + 3 边界（2026-06-24，codex-answer-grill 辩证，codex 3 点全 cite-verify 通过）

device→UIValueType 照前任 `Core/Presentation/UIValueTypeMapper.swift:168`–`:181`（temp→dial / 开度类→percent / 档位类→stepper / 开关类→toggle / 只读→badge）。3 个边界特化：

- **①ambient.color RGB → ⭐B' BadgeRenderStyle 二级 enum**（codex 点2 对）：`UIValueTypeMapper.swift:11`（ScopeBadgeStyle 旁）加 `enum BadgeRenderStyle { plain / colorSwatch(palette) / mode(name) }`；view `switch(ui_value_type){ case .badge: BadgeView(style:) }` **单分支**内对 BadgeRenderStyle 二级穷尽 switch（无 if 链无 AnyView，守 spec.md:83）；不加第 6 枚举。氛围灯卡边光/背景染当前色 = 炸场保留（只读符 D8.4），4a 做。注：demo 仅 2 特化（colorSwatch+mode），二级 enum 是清晰度 + 守穷尽 switch 精神。
- **②座椅 = 5 cell（非 4）composite → ⭐B' 行分 3 类**（codex 点1 catch）：🔴 cite `contracts/state-cells.yaml:217` `seat.massage_mode type: enum` 6 模式（波浪/蛇形/蝶形/舒缓/松弛/全身伸展模式）≠ stepper 档位。composite 行 = stepper(heat/vent/massage_force) + **enum chip 横滑(massage_mode 无序 6 模式)** + percent 横条(backrest)，归 4b spike；4a badge 摘要「座椅: 加热2档/按摩波浪」(`UIValueTypeMapper.swift:131` valueText badge 分支 return rawValue=模式名已支持)。🔴 元认知：⭐B 表「4 cell」= 凭前任 mapper case 推算漏 massage_mode（claim-vs-reality：该 sed 核一手 yaml 非凭派生物 case 数）。
- **③family_card_id 派生缺位 = 4a 接线前置硬门**（codex 点3 真 gap + CC frame 深化）：🔴 cite `grep -c family_card_id contracts/state-cells.yaml = 0` + `Core/Presentation/` 无 FamilyCardIDMapper（0 文件 0 函数 0 测试），但 `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:83` + tasks.md:40 锁「10 族 family_card_id 布局」= 悬空契约。physical landing：4a 前置加 `Core/Presentation/FamilyCardIDMapper.swift`（同 UIValueTypeMapper 体例：`enum FamilyCardID { ac/seat/window/screen/ambient/door/volume/wiper/sunroofShade/fragrance }` + `familyCardID(forBase:)->FamilyCardID` 穷尽 switch + 接 `generated/family-device-allowlist.json` row_count 排序 + 单测 device base→10 族满射）。🔴 **CC frame 深化（surface magnet）**：proof 图是 **device 级**（每 device 一卡 + scope 未聚合，4 张空调温度未合 1 全车卡）≠ spec 锁的 **10 族 family_card**（族卡 composite）→ `VehicleCardDisplay.displays()` 按 `ScopedStateKey.base` 分组 = device 级 → **4a 不是「恢复 proof 图 device 级态」而是「按 spec 10 族 family_card 重做」**（更大工作量）。**device 级 vs 10 族 family_card = 待 magnet 拍（见 P4-D3）**。

→ **P4-D1 4a 前置更新**：`FamilyCardIDMapper`（family_card_id 派生）跟 `default_scope`（已 11 处 ready）平级，4a 第一刀做，非归 4b。

## P4-D3 — 撤回伪 frame + 真分歧 = 聚焦过渡（2026-06-24，codex 反 grill，CC 认错）

🔴 **CC 自纠**：P4-D3 原抛「A device级/B 10族/C 折中」= **伪 frame**（codex 点1/2 catch，全 cite-verify 通过）。A device 级是 worktree 残留（前任没做 family_card 重构），非设计选项；10 族已 SHALL 锁（`spec.md:83` + U13 `grill-master:144` + 5 路 lens `README:64` 否决 device 平铺 + `lens2:97`「无车机平铺上百控件」）→ 让 magnet 拍 A/B/C = 推翻已锁事实型（违 dispute-triage：事实型已锁 SHALL_NOT 当口径型重拍）。CC「anti-confirm 如果要 device 级」= 对已坐实事实型用错工具。

✅ **真 P4-D3 = 聚焦过渡 matchedGeometryEffect vs opacity/scale**（4b 层，codex 捞回调研唯一真分歧）：cite `docs/research/2026-06-23-uiue-10family-presentation/README.md:23` + `:64` + synth §8「唯一待磊哥拍分歧 = 聚焦过渡是否用 matchedGeometryEffect」。code-clone 派用（hero 最炫，纯 iOS OK）vs pitfalls 派禁用（macOS zoom unavailable 无退路 + LazyVGrid 冲突 + Reduce Motion 不 fallback）。🔴 CC discovery：① 文档口径不一致（:23「口径型」/:64「事实型」）→ 精确分诊：macOS zoom unavailable=事实(坐实) / mge-vs-opacity 选哪个=口径(magnet 偏好)；② D5 已锁「Grid 非 LazyVGrid」→「LazyVGrid 冲突」论据可能不适用 Grid，**Grid 里 mge 冲不冲突待验**。归 4b，magnet 拍。

## ⭐C''（最终，锚定调研 5 路锁的「二级摘要+展开模型」README:41,64）
- **4a 摘要层**：10 张 family_card 全景常驻 Grid + 每族显 1 主状态 cell at-a-glance + scope 角标 + 7态 + 低风险炸场（numericText/ambient 色块/breathe）。🔴 **前置硬门**（跟 default_scope 平级）= `FamilyCardIDMapper`（device base→10族）+ `FamilyPrimaryCellMapper`（族→1 主 cell），同 UIValueTypeMapper 体例 + 单测满射
- **4b 展开层**：触发聚焦展开 device composite（座椅 5 cell 行分3类 P4-D2②）+ value.type 异构控件（Gauge/DSSegmentedControl）+ 真 P4-D3 聚焦过渡（mge vs opacity）
- **4c 错峰**：跨族多意图错峰浮现编排（lens3 时序）
- 🔴 物化纪律：二级模型两层 = Architecture 决策进 ui-presentation **design.md AD-N**（非 tasks checkbox，OpenSpec 三件套完整性）

## 后续 grill 一次性清单（2026-06-24，CC 核 tasks + D5 后盘点）

🔴 **核 D5 后更正真 P4-D3**：codex 捞回的「真分歧聚焦过渡」**也过时**——`docs/grill-tournament/uiue-d1-d6-grill.md:167`「D5 聚焦过渡 ✅ grill 完成」+ `:59` / tasks.md `:11`(5.1) 已锁「`ExpansionAnimation` 默认 `opacityScale`（坑密度最低）+ `matchedGeometry` gated upgrade（A2 编译验证 macOS mge 可用后升）」。codex 引 2026-06-23 调研 synth §8「待磊哥拍」= 当时态，**同日 D5 grill 已拍** → 聚焦过渡不用 magnet 重拍，已锁。

🟢 **盘点结论：Phase 4 几乎全锁**（tasks.md 4.1-4.5/5.1-5.3/6.1-6.5/7.A1-A4 + D2/D5/D7/D8 全 grill 收口）= 印证「Phase 4 是 apply 问题非 grill 问题」，真剩开放仅 3 小点。

### 待 magnet 拍/确认（仅 3 点）
- **G1 族卡 primary cell 表**（FamilyPrimaryCellMapper：每族摘要显哪个主 cell）。基础 = state-cells `readback_cell_group`。⭐ CC 推荐显「最有信息量」cell 非 readback[0]：ac→temp_setpoint / seat→heat_level / window→position / ambient→color(色块) / screen→brightness / volume→level / wiper→power / door→central_lock / sunroofShade→position / fragrance→power
- **G2 命名清债归属**（tasks 4.5：`App/ContentView.swift:107`–`:119` title switch 旧 `hvac.*` key）：A2 收还是 UIUE 收？⭐ UIUE 4a 顺手收（接线本就重写 title→FamilyCardID）
- **G3 物化纪律确认**：FamilyCardIDMapper + FamilyPrimaryCellMapper + 二级模型(摘要/展开) = Architecture 决策进 ui-presentation `design.md AD-N`（非 tasks checkbox，OpenSpec 三件套）。⭐ 认同 codex

### 已锁/已定（CC 标注，不用拍，列出防遗漏）
| 点 | 状态 | 出处 |
|---|---|---|
| 聚焦过渡 mge vs opacity | ✅ D5 锁 opacity 默认+mge gated | uiue-d1-d6-grill.md:167,59 / tasks 5.1 |
| value.type 5类+穷尽switch+禁AnyView | ✅ spec R2 + P4-D2 边界①② | tasks 4.1-4.2 |
| Grid 固定列非 LazyVGrid | ✅ C22 | tasks 4.3 |
| row_count 排序 | ✅ C8 | tasks 4.4 |
| 多意图错峰 stagger220+MAX_HIGHLIGHTS=1 | ✅ D8.5 | tasks 5.2 |
| scope 淡角标/聚合/升级 | ✅ 裂缝⑤⑥④ | tasks 7.A |
| 验收门 5-gate simctl 14张满屏单态 | ✅ | tasks 6.4 |
| 座椅 composite 字号 | 🔬 4b spike 实装验 | P4-D2② |
| hex 冻结/投屏 banding/gpu 数字 | ⏳ 后置不阻塞 4a | tasks 6.3 / GAP-1 |
| pre-commit gate + force-state artifact | ✅ P4-D1 定，实装落 | P4-D1 |

→ **G1/G2/G3 拍完即进 4a 实装**（接线 + FamilyCardIDMapper/FamilyPrimaryCellMapper + scope 角标 + 低风险炸场 + pre-commit gate）。
- P4-D3 座椅多维 + RGB 色环控件实现方式（4b spike，self_build 默认）
- P4-D4 聚焦过渡 mge vs opacity/scale（4c，事实型分歧 G2，综合官倾向 opacity）
- P4-D5 AnyView 性能 spike 跑不跑（小决策）
- P4-D6 hex 冻结时机（5-gate 后）/ 投屏 banding 现场 checklist（GAP-1 elephant）

---

## Phase 4a 实装收口（2026-06-25，CC ultracode 自驱 + 6-lens 调研 + 体验审计）

**4a 执行态完成**（commit `b197e0b`→`f5402b6`，13 commits ahead）：
- ✅ **数据/渲染层**（P4-D1/D2/D3 + G1/G2/G3 全落代码）：`FamilyCardIDMapper`(10族 optional 禁 vehicle 错归) + `FamilyPrimaryCellMapper`(G1 主cell表逐字匹配) + `familyDisplays`(10族常驻+occupancy+复用 scope 聚合不重写) + `BadgeRenderStyle`(ambient colorSwatch) + Grid 固定列(C22) + numericText(F-LB2 withAnimation) + breathe(仅激活态) + ambient 色块。187 tests + 3 新 mapper/display test，前任 5 测试不破。
- ✅ **enforce gate**：`check-contentview-uses-display-catalog.sh`(strip注释+验真调用 familyDisplays，三场景自验①②reject③pass) 接 pre-commit 三门。
- ✅ **5-gate proof**：`Reports/uiue-phase4a-proof/` 8 iOS(7态+真实冷启动) simctl 启整app（mac 锁屏 pending）。
- 🔴 **2 厂商审计 + 体验审计**：① adversarial-auditor ×2（Task1-4 / Task5）= V-PASS（P1-1/P1-2/P2 收口）② **subagent CC 用户演绎体验审计 = CONDITIONAL-PASS**（P0-1 占位「未激活」→「待命」/ P0-2 补真实冷启动截图 / P1-2 scope角标提对比 已 4a 修；P1-3 blocked_hard 灰锁上抛磊哥；P1-4/P2-2 defer 4b）。
- 🔴 **6-lens 竖屏交互调研收口**（承接 D1-D6+8-lens 零推翻）：Phase 4 全体竖屏交互设计 → `design.md AD-12`；4a 与 grill 全对齐（Grid 双端统一**非分歧**）；竖屏 = 固定全景 idle + 活跃族 hero 放大 + ScrollViewReader 自动滚（修正 CC 自拍「动态分配」）；三 zone/活跃置顶/触发聚焦 = Phase 5。归档 `docs/research/2026-06-25-portrait-interaction/`。

**4b 前向**（spike-first）：value.type 异构控件（Gauge.accessoryCircular/座椅 5-cell composite/DSSegmentedControl）+ 触发聚焦展开（ZStack overlay 非 sheet + opacityScale 默认 mge gated）+ breathe→TimelineView 硬化 + changing 视觉强度 + P1-3 blocked_hard 视觉（待磊哥）。**4c**：MultiCallSequencer 错峰。**Phase 5**：三 zone + 活跃置顶 ScrollViewReader + orb 四态 + 事件驱动联动（E0-E8）。

🔴 **merge 状态**：4a 分支 push + PR = review/异源审，**非 merge**（CURRENT.md main 线「Do not merge UIUE into mainline」+ default-scope reconfirm gated；合并粒度 4a 小 PR vs 攒 4b = 待磊哥拍，synth ⭐A 现 push 小 PR）。

## Phase 4a 收口 hardening（2026-06-25，gptpro 产品架构意见吸收，磊哥定「沉淀+好好收口再执行目标」）

gptpro（GPT Pro 网页）对 PR #6 出**产品架构意见**（8 点，`/Users/wanglei/Downloads/gptpro意见.md`），点破「4a 已从 UI 展示进入【语义呈现层】，UIUE 正确抽象是 Presentation Contract 三层非 View」。磊哥拍：能沉淀的沉淀，**第 5 点不采纳**（skills/vendor 拆 PR——仓 private 非外部供应链）。逐点吸收落地 = **`design.md AD-13`**（SSOT，含三层 contract + 8 点处置表 + phase matrix + 元洞察），元认知沉淀 = `~/.claude/rules/derivation-layer-discipline.md`（派生层/语义呈现层纪律）+ `docs/lessons-learned.md #9`。

**4b 前防雷的硬收获（claim-vs-reality 实锤）**：gptpro 第 2 点「`default:.badge` 吞错」→ 核 state-cells 33 base 一手 type，**catch 真 bug `window.lock`（enum locked/unlocked 二值锁）被 `default` 静默吞成 badge，实为 toggle**——4b 做 toggle 图形控件时会「为什么车窗锁没开关控件」追查灾难。修法 = `UIValueTypeMapper.mapping` 33 base 显式字典 SSOT + `default→assertionFailure` + contract-driven 闭合测试（遍历 yaml 全 base 断言 isMapped）。验收：swift test 206/0 · make verify exit0 · gate 三场景自验（升级 grep 真 enforce 数据源）· xcodebuild 两端 SUCCEEDED。

→ **4a 收口完成（计划态+执行态双绿）**，进 4b（value.type 异构控件 + 座椅 composite + 触发聚焦），承接 P4-D1 4b 段 + P4-D2②座椅 + 真 P4-D3 已锁 opacity 默认+mge gated。

## Phase 4b/4c 实装收口（2026-06-25，CC ultracode 自驱 spike-first，承接 grill 零自拍）

**4b/4c 执行态完成**（commit `2a6bfe1`→`322e101`，4 task）：
- ✅ **4b Task11 value.type 异构控件**：`ValueControlView` 5 类穷尽 switch 禁 AnyView（dial=`Gauge(.accessoryCircular)` 非 watchOS / percent=`Gauge(.accessoryCircularCapacity)` / stepper=分段条 / toggle / badge 二级 BadgeRenderStyle switch）+ `ValueRangeMapper`（execution_range **委托 A2 `StateCellContractLookup`** 单一 SSOT）。**spike-first 解除 P4-D1 tiger**（`-spikeControls` 截图实查 `.accessoryCircular` iOS 真渲染环形仪表 + Grid 不冲突，非 watchOS 编译错）。
- ✅ **4b Task12+13 触发聚焦展开 + 座椅 composite**：`FocusController`（AD-4 单点聚焦 MAX=1）+ `ExpandedFamilyDisplay`（device composite，按 valueType 分组排序 → 座椅 stepper×3→percent→badge **行分3类 P4-D2②**）+ `ExpandedFamilyCard`（ContentView ZStack overlay 非 sheet + ultraThinMaterial dim + opacityScale 320ms D5默认 mge gated + 族卡 onTapGesture AD-12§三）。`-spikeExpanded` 截图实查座椅展开（环形/分段×3/容量环/模式胶囊 + dim blur + 态图标双通道）。
- ✅ **4c Task14 多意图错峰**：`StaggerSchedule`（220ms 单点串行 schedule 可测）+ `MultiCallSequencer`（@Observable surfacedFamilies 依次 append）—— AD-4/AD-8.5/AD-12§四。`-spikeSequencer` 截 2 帧（中间态前3族亮/后7待命 vs 完成5亮）**实查证序列化错峰非同时炸**（D8.5 + 「稳>炸」北极星）。view 端到端错峰（多意图触发源）依赖 splitter runtime 链路（AD-4 锚，phase matrix）。
- ✅ **验收门**：swift test **221/0** · make verify-all exit0（契约门+gate+diff）· xcodebuild macOS+iOS SUCCEEDED · pre-commit 三门 · 5 spike 截图 Read 实查渲染（claim-vs-reality 非声称截图）。
- 🔴 **§28 教训（lessons #10）**：ValueRangeMapper 先建重复 `ExecutionRange` 被 A2 已有 ambiguous catch → 回退委托。catalog 本身与 A2 `StateCellContractLookup` 重复（4a 遗留）记 design AD-13 phase matrix harden（上抛磊哥重构范围）。

→ **4b/4c 执行态完成**，待整体异源审（codex rescue 非同源）+ push。
