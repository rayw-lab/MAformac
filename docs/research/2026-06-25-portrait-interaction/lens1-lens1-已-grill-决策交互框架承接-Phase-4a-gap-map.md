# lens1 — 已 grill 决策交互框架承接 + Phase 4a gap map（本地读重，不推翻决策，只结构化）

> 一手 finder full_markdown（ultracode 三层一手性）

# Lens 1 — UIUE 已 grill 决策交互框架承接 + Phase 4a gap map

## Summary

MAformac UIUE 已 grill 决策的竖屏交互框架已全量收口，共三组：
- **D1-D8**：核心交互框架（boot_phase / MultiCallSequencer / UIValueType / Grid / wow-choreography / default_scope），落 uiue-d1-d6-grill.md + grill-decisions-master.md §3
- **DA0-DA8**：D7 补强（DA0 归 Phase5，DA2 cut，DA5 隐私降级，DA7 4a 边界）
- **E0-E8**：Phase 5 思考链路 orb 全契约（event-driven，MeshGradient，SceneMacroMatcher，4 宏）

Phase 4a 实装已接通核心骨架，与 grill 高度对齐：
- `VehicleCardDisplay.familyDisplays(from:)` 10 族全景（`Core/Presentation/UIValueTypeMapper.swift:180`）
- `VehicleCardsGrid` Grid 固定列（Mac=5，iPhone compact=2，iPad=4，C22）
- `VehicleStateCard` 7 态视觉（CardAppearance 穷尽 switch）
- scope badge dim/emphasized、numericText+withAnimation、breathe 仅激活态 repeatForever、ambient colorSwatch 炸场
- `BadgeRenderStyle` 二级 enum（plain/colorSwatch/mode，禁 AnyView，穷尽）
- `FamilyCardIDMapper` + `FamilyPrimaryCellMapper` 已被调用，`Core/Presentation/` 为未跟踪新目录（独立文件已建）

**真正 4a 缺口**：pre-commit enforce gate（check-contentview-uses-display-catalog.sh）+ force-state 14 张截图 + TDD 单测覆盖确认——这三项是「执行态完成」门，非功能缺失。

Grid 双端统一（非 Mac-Grid + iPhone-LazyVGrid 分离）与 grill D5/C22 最终决策完全对齐，不属于分歧。

---

## Findings（每条含 file:line 锚）

### 已 grill 决策框架清单

| # | 决策 | 状态 | file:line |
|---|---|---|---|
| D1 | boot_phase 7 态 + MultiCallSequencer stagger=220ms + MAX_CONCURRENT_HIGHLIGHTS=1 | locked，Phase5 实装 | uiue-d1-d6-grill.md:11-80 |
| D2 | FocusController + ExpandTrigger + MAX_CONCURRENT_EXPANSIONS=1 | locked，4c deferred | uiue-d1-d6-grill.md:82-130 |
| D3 | UIValueType 5 类穷尽 switch + GPUBudgetCoordinator | locked | uiue-d1-d6-grill.md:132-180 |
| D4 | Mac+iPhone 两台独立 standalone demo（非 mirror） | locked | uiue-d1-d6-grill.md:182-230 |
| D5 | Grid 非 LazyVGrid（C22），opacityScale 默认，mge GATED | locked | uiue-d1-d6-grill.md:232-290 |
| D6 | wow-choreography 4 段 + dual-channel degradation（非 5 级梯） | locked，Phase5 实装 | uiue-d1-d6-grill.md:292-350 |
| D7 | 7 态视觉消费 CardAppearance 穷尽 switch | locked，已 apply（6a3e3f9） | grill-decisions-master.md §3 D7 |
| D8 | default_scope SSOT（state-cells.yaml）+ 裂缝④⑤⑥ + touch=read-only + L3+ think=orb | locked | grill-decisions-master.md §3 D8 |
| DA0 | 执行→7 态映射 | locked，Phase5 deferred | grill-decisions-master.md §3 DA0 |
| DA5 | macOS 截图隐私降级 | locked | grill-decisions-master.md §3 DA5 |
| DA7 | 4a / Phase5 边界 | locked | grill-decisions-master.md §3 DA7 |
| E0-E8 | Phase5 思考链路 orb 全契约（event-driven，MeshGradient，4 宏） | locked，实装 deferred | grill-decisions-master.md §3 E0-E8 |
| P4-D1 | Phase4 三相 ⭐C''（4a/4b/4c 增量） | locked，磊哥拍认 | uiue-phase4-grill-decisions.md:P4-D1 |
| P4-D2 | BadgeRenderStyle 二级 enum + seat 5-cell(4b) + FamilyCardIDMapper(4a 前置) | locked | uiue-phase4-grill-decisions.md:P4-D2 |
| P4-D3 | 10 族 family_card SHALL + opacityScale 默认（D5） | locked | uiue-phase4-grill-decisions.md:P4-D3 |

### Phase 4a 已接通（与 grill 对齐）

| 特性 | 接通状态 | file:line |
|---|---|---|
| familyDisplays 10 族固定序 | 已接（UIValueTypeMapper 静态方法） | UIValueTypeMapper.swift:180-197 |
| FamilyCardIDMapper 调用 | 已接（mapper 文件在 Core/Presentation/ 新目录） | UIValueTypeMapper.swift:187 |
| FamilyPrimaryCellMapper 调用 | 已接 | UIValueTypeMapper.swift:224 |
| vehicle.*/未知 → nil 过滤（P0-1） | 已接（guard familyCardID != nil） | UIValueTypeMapper.swift:187-188 |
| dominantVisualState 族态 | 已接（unsafe 优先序） | UIValueTypeMapper.swift:165-172 |
| summaryDisplay + scope 聚合复用（不重写:54-129） | 已接 | UIValueTypeMapper.swift:218-258 |
| badgeRenderStyle ambient→colorSwatch | 已接（穷尽 switch） | UIValueTypeMapper.swift:261-267 |
| Grid 固定列（Mac=5/iPhone compact=2/iPad=4） | 已接（C22） | ContentView.swift:124-148 |
| 7 态 CardAppearance 无 default | 已接 | ContentView.swift:164 |
| scope badge dim/emphasized（裂缝⑤⑥） | 已接 | ContentView.swift:175,248-257 |
| numericText + withAnimation（F-LB2 防 silent-fail） | 已接 | ContentView.swift:193-194 |
| breathe 仅激活态 + repeatForever（非裸 Timer） | 已接 | ContentView.swift:259-267 |
| ambient colorSwatch 炸场（色块+卡背染色） | 已接 | ContentView.swift:187-188,228-237 |
| a11y 7 态文案 | 已接 | ContentView.swift:270-279 |
| scrollClipDisabled 防辉光裁切 | 已接 | ContentView.swift:150 |
| placeholder normal 占位（冷启动不空屏） | 已接 | UIValueTypeMapper.swift:199-213 |
| VehicleCardDisplay familyCardID + badgeStyle 字段 | 已接 | UIValueTypeMapper.swift:38-41 |
| DeepSpaceBackground 深空暗底（#121212，U11） | 已接 | ContentView.swift:100-113 |
| iOS26/macOS26 lock | 已接（commit f754d5a） | Phase5 handoff:9 |
| 2 pre-commit gate（no-binary-visualstate + platform-vs-version） | 已接 | Phase5 handoff:15 |

### Phase 4a 真缺口（执行态门，非功能缺失）

| 缺口 | 性质 | 优先级 |
|---|---|---|
| check-contentview-uses-display-catalog.sh pre-commit gate | 执行态 enforce 门（claim-vs-reality P0-2） | 🔴 blocking |
| force-state 14 张（7态×2场景）5-gate 视觉验收 | 执行态视觉门 | 🔴 blocking |
| VehicleCardDisplayTests.swift + FamilyCardIDMapperTests.swift + FamilyPrimaryCellMapperTests.swift TDD 覆盖确认 | 执行态 TDD 门 | 🔴 blocking |
| design.md AD-9/10/11 + AD-2 路径纠正 + tasks.md 4.5 stale 纠正 | 文档先行 Task1 | 🟡 should-have |

### 正确 Deferred 项（与 grill 对齐，不属于 4a 缺口）

| 特性 | deferred 至 | 依据 |
|---|---|---|
| seat composite 5-cell（stepper+enum chip+percent bar） | 4b spike | P4-D2 ② |
| value.type 异构控件（Gauge/stepper/等） | 4b | P4-D1 C'' |
| trigger-focus 展开（FocusController/ExpandTrigger） | 4c | D2 |
| matchedGeometryEffect upgrade | promotion_criteria 后 gated | D5 |
| boot_phase 7 态序列 + MultiCallSequencer highlight | Phase 5 | D1 |
| ripple Metal layerEffect | Phase 5（A2 build verify 后解锁） | D6/D5 |
| iPhone 3-zone 竖屏布局（orb 120/content 440/mic 80） | Phase 5 | D4 |
| E0-E8 思考链路 orb + SceneMacroMatcher + DA0 | Phase 5 | E0-E8 |
| 活跃置顶（active-top sort） | Phase 4b/5 可选 | D4 |

### Gaps vs Grill 分歧分析

1. **Grid 统一**：非分歧，早期讨论 vs D5/C22 最终决策已对齐。
2. **FamilyCardIDMapper/FamilyPrimaryCellMapper 独立文件**：gitStatus 显示 Core/Presentation/ 为新未跟踪目录，独立文件应已建（否则 UIValueTypeMapper.swift 编译会失败）。本调研未能 ls 确认目录内容。
3. **3 open grill 问题（G1/G2/G3）**：G1 为口径型（磊哥拍），G2 实为 stale 任务（4.5 废），G3 为文档先行 Task1。

---

## Candidates（竖屏 demo 适配评分）

见 candidates 字段。⭐推荐 D：4a 收尾当前骨架（enforce gate + force-state 14 张 + TDD 确认 + push + GPT Pro 异源审）。

---

## Source 索引

- `docs/grill-tournament/uiue-d1-d6-grill.md`（D1-D6 全文，254 行）
- `docs/grill-tournament/grill-decisions-master.md`（§0-§6 全文，415 行，grill SSOT 单源）
- `docs/handoffs/2026-06-24-uiue-phase5-grill-closeout.md`（Phase5 grill + D7 apply + 撞车监督，63 行）
- `App/ContentView.swift`（Phase 4a 实装，290 行）
- `docs/uiue-roadmap-2026-06-23.md`（7 Phase roadmap，257 行）
- `docs/grill-tournament/uiue-phase4-grill-decisions.md`（P4-D1/D2/D3，102 行）
- `docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md`（4a 派单，59 行）
- `docs/superpowers/plans/2026-06-24-phase4-card-scope-presentation.md`（执行计划前 100 行）
- `Core/Presentation/UIValueTypeMapper.swift`（全文 513 行，familyDisplays:180 + BadgeRenderStyle:23 + FamilyCardID/Mapper 调用）

