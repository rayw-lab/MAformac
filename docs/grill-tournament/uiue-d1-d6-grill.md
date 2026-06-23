# UIUE D1-D6 决策 grill 工作档（grill-first 一手料）

> 🔴 **grill-first**：D1-D6 每个 ≥5 问深挖（CC 5×⭐ 概念 + Codex 物理化加强 = 物理契约/跨链路协议）。grill 全完 → 落 **① grill-master §3 决策晶体 + ② roadmap 升级 + ③ ui-presentation change skeleton（含 design.md）**。本档 = grill 过程一手（CC↔Codex 双向），决策 SSOT 仍是 grill-master §3。
> 上游：7 路调研 `docs/research/2026-06-23-uiue-10family-presentation/` + 3 报告（probe/premortem/roadmap-draft）。
> 数值说明：下方 tokens 数值 = CC0/Codex **设计值**（非引用一手），待 A2 实装时落 tokens.md + 真机/投屏验收（claim-vs-reality 红线）。

---

## D1 主视图形态 = A 全景常驻 + 触发聚焦 ✅ grill 完成（2026-06-23）

> CC 5×⭐ 主张全部成立 + Codex 10 点物理化补强（5Q×2）。落档 = 5 件套进 ui-presentation capability，喂 fork2 skeleton，不另建载体。

### Q1.1 开场第一帧（⭐ orb 呼吸 1-2s → 全族 reveal 扫一遍 → idle dim）
1. 🔴 **reveal 落 happens-before 时序字段进 DemoVisualState**：现状 DemoVisualState 仅 4 态（normal/clarify/safety-blocked/exec），premortem L1 实查 state-cells 才 4 族未扩 10。物理化 = `boot_phase: enum {cold_boot, revealing, idle_dim, focused, exec, clarify, safety_blocked}` + `boot_reveal_complete_at: TimeInterval`；scenario「first_voice **happens-after** boot_reveal_complete_at **OR** queue until idle_dim」（防客户在 reveal 中途喊"打开空调"→ family card 未渲染完被语音抢焦 → matchedGeometryEffect **source-not-yet-mounted**，lens6 Tiger#3 同病）。**复用 U10 4态扩7态同 PR，不新建载体**。
2. **orb 开场 SOP 落 `demo-experience-script-placeholders.md §0 Cold Boot`**（非口头）：`orb_duration_ms:1500` + `reveal_stagger_ms:100`（10 族×100ms=1s 扫完）+ `welcome_tts:null`（默认无，环境噪音敏感）；3 token 同步 `docs/design/tokens.md` 让 UI import 不写 magic number。

### Q1.2 多意图序列化高亮（⭐ 序列化非同时闪 + 多卡不展开）
1. 🔴 **MultiCallSequencer 单点入口**（禁 N timer 并发）：LLM 多 toolCall 来自 `contracts/semantic-function-contract.jsonl` 解析 array，顺序 LLM 定但 UI 可控。物理化 = `class MultiCallSequencer.replay(toolCalls:[ToolCall], stagger:ms)` 串行 schedule + tokens `stagger_delay_ms:220`（人眼"看清切换"下限，lens6 Tiger#3 SwiftUI lazy 性能阈值同档）；禁多 Task/Timer 并发。**golden-run 回放走同 sequencer = 三向同源**（Pattern 5）。
2. **`MAX_CONCURRENT_HIGHLIGHTS:1` 硬上限 enum**（非口头）：物理化 = 写 tokens + sequencer 内 `assert(activeHighlights.count <= 1)`；溢出 toolCall 进 "queued" 视觉态（family card 边缘弱光小角标 `queue_indicator_alpha:0.4`，让客户看见"还在排队"非丢动作）；回灌 `spec.md scenario「multi-intent voice → highlight serialized, queue surfaces」`。

### Q1.3 未触发 dim 族「显空」（⭐ 微光呼吸非死灰 + 开场 reveal + 语音"全部展示"彩蛋）
1. 🔴 **dim 微光呼吸落 banding 安全阈值**（非抽象"极弱"）：lens1 F1 头号约束=1080p 投屏 8bit banding，`#0a0b12` 暗底上 alpha 跳变 >8/255 触发可见 banding（8bit step≈1/256）。物理化 = tokens `idle_breathe_alpha_min:0.04, max:0.10, period_s:3.2`（差 0.06≈15/255 跨多个 8bit step 平滑）+ dither shader（复用 lens1 base dither，0 新依赖）；**anchor PNG 抽 1px 列做 banding 验收**（claim-vs-reality 红线）。
2. **"全部展示"彩蛋落 `demo-scenarios.yaml`**（否则现场会忘）：`showcase_all_families: {trigger:["全部展示","秀一遍","展示能力"], action:replay_boot_reveal, expected_visual:all_10_families_pulse_once}`；复用开场 reveal 同函数 `revealAllFamilies(stagger:100ms)`（DRY，0 新代码路径）；同步 demo-experience-script SOP §"语音彩蛋表"。

### Q1.4 双屏 Mac 主 / iPhone 加分（⭐ Mac 全景常驻 + iPhone 跨屏高亮联动）
> 🔴 **SUPERSEDED-BY D4（2026-06-23 磊哥纠正「iPhone 脱机独立演示」+ Codex iOS sandbox 反据）**：下方「iPhone only-read 镜像 Mac / LocalDeviceLinkBridge 共享文件 / no_voice_intake」**已推翻**。iPhone = 独立全功能端侧 demo（接语音脱机可演），transport 改 `TransportKind{none 默认独立, bonjour 可选联动}`（删 sharedFile 镜像，iOS sandbox 物理不成立）。本段保留供 grill 溯源，落档以 **D4** 为准。
1. 🔴 **跨屏联动 transport 契约**（非 hand-wave）：iPhone 跨屏读 Mac 状态需 transport。物理化 = `LocalDeviceLinkBridge` 走端状态共享文件 `~/Library/Containers/<bundle>/Data/demo-visual-state.json`（DemoVisualState 同源序列化），**iPhone only-reads / Mac only-writes**（派生表范式 Pattern 2，同 W19/W20 边界隔离形）；`protocol VisualStateTransport { func read()->DemoVisualState; func write(_:) }`，iPhone 实现 write 报错（只读契约）；pre-commit check `iphone-visual-state-readonly` grep iPhone 目录禁出现 `.write(`（防 iPhone 独立改态两边漂移，lens3 cross-domain E2 同坑）。
2. **iPhone 加分进 ui-presentation spec.md scenario**（非次要 anchor PNG）：openspec 实查只 6 active change，ui-presentation 不存在。物理化 = 待建 ui-presentation change spec.md 两 scenario「`mac_main: full 10-family grid permanent`」/「`iphone_bonus: mirror_highlight_only, no_independent_voice_intake`」，后者明确 **iPhone 不接语音输入**（避免两屏 ASR 抢话筒）。否则 anchor PNG 出图无依据。

### Q1.5 anti-confirmation 重审否决 B（⭐ 守 A，但聚焦动效 = 决策成败）
1. 🔴 **"聚焦动效=成败"落 D1 决策晶体 `validation_gate` 字段**（grill 间依赖锚，最关键）：Codex/CC 自承"A 的聚焦动效强度=成败 → 引出 D5"是隐性条件依赖，必须显式锁档，否则 D5 若 grill 出"matchedGeometry macOS unavailable + opacity/scale 也不够炸场"时 D1 已落档无人回扫。物理化 = grill-master §3 D1 决策晶体增 `validation_gate: D5 通过 + A2 编译验证 macOS matchedGeometry 可用性`，`gate_status: enum {pending, passed, failed}`；**failed → D1 自动回退 "C 静态全网格 + 边框 glow 切态"**（2nd-best，无聚焦但不翻车）。
2. **B 的"魔法感"借鉴为一次性 ripple**（非二选一）：物理化 = `RippleOverlay(once:true, source:focusedFamCard.frame)` 仅族卡**首次被触发瞬间**放一次水波（lens1 Inferno U5 一期，metal shader 单帧≈3ms M5/Metal 4，不抢 GPU 不持续）；tokens `ripple_on_first_focus:{enabled:true, max_per_demo_session:10}`（每族最多一次防滥用），ReduceMotion 通道 disable。A 兼得"全景广度 + 单点魔法感"，不输纯 B。
   - 🔴 **D5.Q5.3 打破循环依赖回写（2026-06-23）**：ripple gate 改「**仅 gated_by A2 编译验证 metal shader 可用**」，**不 gated_by D5 matchedGeometry**（ripple=Metal layerEffect 独立，不依赖 mge）——否则 D1.Q1.5 ripple ↔ D5 validation_gate 互相 gated 成循环。ripple 与 mge 升级解耦：即使 mge gate 仍 pending，ripple 可独立上。

### D1 落档清单（grill 全完 → 落 grill-master §3 + ui-presentation skeleton；5 件套属 ui-presentation capability）
1. **DemoVisualState 扩**：`boot_phase` 7 态 enum + `boot_reveal_complete_at`（扩 U10 4→7 态同 PR）
2. **MultiCallSequencer**：`replay(toolCalls,stagger)` 单点 + `stagger_delay_ms:220` + `MAX_CONCURRENT_HIGHLIGHTS:1` + queued 态
3. **VisualStateTransport 跨屏契约**：`LocalDeviceLinkBridge` 共享文件 + iPhone only-reads + pre-commit `iphone-visual-state-readonly`
4. **tokens 数值**（设计值待实装验收）：`orb_duration_ms:1500 / reveal_stagger_ms:100 / stagger_delay_ms:220 / idle_breathe_alpha_min:0.04 max:0.10 period_s:3.2 / queue_indicator_alpha:0.4 / ripple_on_first_focus{enabled,max_per_demo_session:10}`
5. **scenario 回灌 spec.md**：multi-intent serialized / mac_main / iphone_bonus / showcase_all_families
6. 🔴 **`validation_gate: D5 通过 + A2 编译验证 = pending`**（grill 间依赖锚，防 D5 漂走 D1 静默失效；failed → 回退 C）

### 🔴 grill 间依赖锚（跨 D 锚定，防静默失效）
- **D1 → D5**：D1 validation_gate 依赖 D5（聚焦过渡）通过。D5 grill 必须解决 matchedGeometry macOS 可用性（lens6 主张禁用 vs lens4 主张用）；D5 failed → D1 回退 C 静态网格。
- D1 拍完进 D2 前，此 gate 标 **pending**。

---

## D2 族内多 device 下钻 = 二级模型（族卡摘要 → 触发展开，191 不平铺）✅ grill 完成（2026-06-23）

> CC 5×⭐ 字面全成立 + Codex 10 点物理化。🔴 **落档前置 `prerequisite_artifacts`：`family_priority.json`（与 A2 G2 同 PR）+ `voice_device_coverage.json`（与 lora-data-gate 同 PR）——无此两文件 D2 ⭐ 悬空，不允许落档**。

### Q2.1 展开触发 voice 主 / tap 辅（⭐ 语音为主 + tap 备份）
1. 🔴 **voice/tap/golden-run 走同一 `ExpandIntent`**（禁两条独立路径）：voice 走 LLMRouter、tap 走 onTapGesture 独立 → `focusedFamily` setter 漂移 + golden-run 只覆盖 voice 路径 + tap 成 dead code（lens6 Tiger#3）。物理化 = `enum ExpandTrigger {voice(toolCallId), tap(operatorOverride), goldenRun(scenarioId)}` + 单点 `FocusController.expand(family, trigger:)` 三向同源（Pattern 5，同 D1.Q1.2 sequencer）；pre-commit `check:focus-single-entry` grep 禁 `focusedFamily =` 直接赋值。
2. **tap affordance 落 tokens + accessibility**（否则等于没 tap）：macOS 默认 button hint 在 Liquid Glass dim 卡上几乎看不见（1080p 投屏更糊）。物理化 = tokens `tap_affordance_alpha_on_hover:0.18` + `cursor:.pointingHand` + `accessibilityHint("双击展开 \(familyName) 细控")`；"哪些卡可 tap"写进 demo-experience-script §"现场失败回退 SOP"（非 tribal knowledge）。

### Q2.2 原地放大中卡 + 全景 blur（⭐ matchedGeometry + blur，D5 待定）
1. 🔴 **blur 分级 token**（Liquid Glass 单层≈3 offscreen texture，blur 9 卡=27 texture，投屏 8bit banding 被 blur 放大，lens1/lens6 红线）：物理化 = tokens `blur_radius_background_when_focused:12`（过大暴露 banding）+ `material:.ultraThinMaterial`（系统内置 dither）；🔴 **macOS Reduce Transparency 开 → `solid_overlay_alpha:0.65`（纯色 0 blur）**。**Reduce Transparency ≠ ReduceMotion 两开关，不复用 D1.Q1.5 fallback gate**。
2. **expansion enum + D5 gate 联动**（非"D5 待定"挂空）：`enum ExpansionAnimation {matchedGeometry, opacityScale, crossDissolve, immediate}` 默认 `opacityScale`（坑密度最低）；D5 A2 编译验证 macOS matchedGeometry 在 LazyVGrid 不冲突后升级。**复用 D1.Q1.5 同一 `validation_gate`（不新建）**；D2 晶体 `expansion_animation_initial:opacityScale; upgrade_to_matchedGeometry:gated_by D5.validation_gate`（grill 间依赖锚显式化）。

### Q2.3 3-4 高频子 device col O 派生（⭐ col O 优先级，⚠️ 物理层 0 数据源）
1. 🔴 **col O 抽取落 `contracts/family_priority.json`（与 A2 G2 同 PR 不能再延）**：col O 在 xlsx 第 15 列不在 jsonl = 当前 0 数据源，D2 落档=实现期编 hardcode → 跟 191 device 真优先级漂移（现场客户问"为啥不显模式"答不上，claim-vs-reality 红线）。物理化 = schema `{family_id:{primary:[device_id], secondary:[device_id], col_o_rank:int}}`，**强制并入 A2 G2 同 PR**；pre-commit `check:family-priority-coverage` 10 族每族 ≥3 primary。**无此文件 D2 不允许落档**。
2. **3-4 上限 + 二级阈值 tokens enum**（非口头）：tokens `family_expand_primary_max:4` + `family_expand_secondary_threshold:6`（超过显"+n"折叠角标）+ `family_expand_secondary_visible_on_demo:false`（现场 5min 不挖深，留扩展位）。同 D1 tokens 址，0 新载体。

### Q2.4 展开时全景其他 9 族 blur+dim（⭐ 同时只 1 族展开）
1. 🔴 **`MAX_CONCURRENT_EXPANSIONS:1` 与 D1 `MAX_CONCURRENT_HIGHLIGHTS:1` 两个独立 token（不复用）**：highlight=边框辉光+数值脉动（轻可瞬切）vs expansion=中卡（重，动画≈320ms）；混用出竞态（族 A 展开 87% 时族 B highlight 把 sequencer queue 清掉）。物理化 = 双 token + `FocusController.canExpand: Bool { activeExpansions.count < MAX_CONCURRENT_EXPANSIONS && !isExpanding }`（展开期 isExpanding=true 锁死，完成 callback 释放）；pre-commit `check:concurrent-focus-distinct` 两常量独立定义。
2. **多意图多族走 D1 sequencer 排队**（明确禁展开）：`MultiCallSequencer`（D1 已建）加 `expansionPolicy:{single->expand; multi->highlight_serialize, no_expand}`；spec scenario「voice '空调降温+座椅加热' → no expansion, highlight serialized (空调→座椅, 220ms stagger), execute both via toolCall sequencer」（220ms 复用 D1.Q1.2 `stagger_delay_ms`，0 新数）。

### Q2.5 anti-confirmation 折叠 vs 平铺（⭐ 守折叠 + 子能力角标 + 语音直达）
1. 🔴 **子能力数角标从 `family_priority.json` 派生（禁写死）**：hardcode "6 项" → col O 更新角标不同步（claim-vs-reality，同 Q2.3 坑）。物理化 = `FamilyCard.subCapabilityCount = familyPriority[familyId].primary.count + secondary.count`（从 Q2.3 contract 派生，DRY）；pre-commit `check:badge-derived` 禁 `FamilyCard` 出现 `Text("\d+ 项")` 字面。
2. 🔴 **"语音直达任意 device"落 `contracts/voice_device_coverage.json`（与 lora-data-gate 同 PR）**：191 device 中"开主驾门后窗"深层 intent 可能 LoRA 没训过 → 直达是空话。物理化 = 列 191 中**必须现场可直达**高频集（~30，与 demo-scenarios 高频取交集）；demo-scenarios 加 `voice_direct_to_deep_device:{trigger:"打开主驾门后窗", expected:{family_highlight:"车窗", device_executed:"rear_left_window", no_expansion_needed:true}}`；lora-data-gate 加 `direct_device_coverage_rate >= 0.95`。否则角标"暗示深度"=虚假承诺（Pattern 12 凭空）。

### D2 落档清单 + 🔴 prerequisite_artifacts（无则悬空）
- 🔴 `prerequisite_artifacts: [family_priority.json (与 A2 G2 同 PR), voice_device_coverage.json (与 lora-data-gate 同 PR)]` — **无此两文件 D2 ⭐ 悬空承诺，不允许落档**
- 归 ui-presentation capability（8 点）：ExpandTrigger/FocusController 单点 + tap affordance + blur 分级 token + ExpansionAnimation enum + 双独立 MAX token + sequencer expansionPolicy + 角标派生 + scenario gate
- `expansion_animation` 复用 D1 validation_gate（D5 联动 gated upgrade）

### 🔴 grill 间依赖锚（D2 新增）
- **D2 → D5**：`expansion_animation` upgrade matchedGeometry `gated_by D5.validation_gate`（复用 D1 同 gate，D5 failed → D2 留 opacityScale 不升级）
- **D2 → A2（链路 B）**：`family_priority.json` 与 A2 G2 col O 实算同 PR
- **D2 → C5（链路 B/DEFERRED）**：`voice_device_coverage.json` 与 `define-lora-data-gate` 同 PR，`direct_device_coverage_rate >= 0.95`

---
## D3 异构值形态可视化 = U26 enum+switch(value.type) ✅ grill 完成（2026-06-23）

> CC 5×⭐ 方向全成立 + Codex 10 点物理化（9 纯加强 + 🔴1 事实型局部中立 Q3.5#1）。🔴 **起跑前置：state-cells.yaml 10 族扩齐 + 新增 `ui_value_type` 派生字段（数据 type ≠ UI value.type）**。

### Q3.1 value.type 分发枚举（⭐ 统一 enum+switch 5 类）
1. 🔴 **`ui_value_type` 落 state-cells.yaml 新字段从现有 type+unit+execution_range codegen 派生**（关键纠正：state-cells:60+ 的 `type:int/enum/string` 是**数据 type 非 UI value.type**）。派生规则进 `gen_c1.py`（同 A2 D-domain codegen 管线）：int+celsius/percent+range→continuous / int+gear+step1→discrete_segment / enum[on,off]→switch / 多 cell 同 device(ac.temp×fan×mode)→composite(座椅多维) / ambient_light+RGB(待C2补)→rgb_wheel。`enum UIValueType` 从 generated/ 反序列化**不硬编码**（Pattern1+5 三向同源）。validation_gate = state-cells 10 族扩齐 + ui_value_type 派生过 verify_refs。
2. **switch 用 `@ViewBuilder` + 编译时穷尽（禁 default）**：`FamilyValueRenderer.render(state)` switch uiValueType，enum 不许 default case（漏 case 编译报错=守"懂一张懂全部"骨架契约）；pre-commit `check:ui-value-type-exhaustive` 禁 default。

### Q3.2 控件适配缺口（⭐ 座椅多维 + RGB 色环）
1. **缺口落 `docs/design/component-adoption-matrix.md` 11 行表 + `adoption_status` enum{native,vendor_borrow,vendor_dep,self_build}**：🔴 hendriku star **未实测**(answer-grill 禁臆造 URL)→ `self_build`+"仅 readonly 参考"安全默认，延后组件落地 gh 一手核（star>500+近60天才升 vendor_borrow）；pre-commit `check:no-vendor-dep-in-package` 禁 Package.swift 出现 hendriku/Inxel 包名（借鉴非依赖）。
2. **自建前跑 spike 0.5h**：`spike/rgb-wheel-banding-1080p`（AngularGradient 在 #0a0b12+1080p 投屏 banding?）+ `spike/seat-composite-7-tier`（7 级分段在 230pt 卡字号够? lens1 F1 ≥24pt）；verdict enum{pass, fail_replace(降 native Picker), fail_redesign(回 D3 加 case)}。

### Q3.3 Inferno 性能预算（⭐ 氛围层非常驻 + 错峰 mlx）
1. 🔴 **"错峰 mlx"落 `actor GPUBudgetCoordinator` + 互斥锁**（mlx Qwen3-1.7B+LoRA 与 Metal shader 共抢 GPU，无协调 LLM toolCall 渲染期 mlx 掉 30-50%）：`actor GPUBudgetCoordinator{ Lease:{mlxInference,shaderEffect,idle}; acquire/release }` 互斥（mlx 期 shader deferred 入队<16ms / shader 期新 LLM await）；与 MultiCallSequencer(D1) 共享 lease；pre-commit `check:gpu-lease-no-concurrent` 禁 Task.detached 包 shader。
2. **GPU 预算落 `docs/design/gpu-budget.md`**（target 16.6ms/mlx 8/shader 3/breathing 2/slack 3.6）+ Instruments Metal Frame Capture 3 场景（idle 10 卡呼吸/单 ripple/氛围色带）写 `demo-must-pass` P0（**实测非声称**，扩"验收以读回 mock 态为准"到视觉）。

### Q3.4 骨架统一 vs 值区变（⭐ FamilyCard 骨架固定 slot）
1. **骨架 slot 落 `FamilyCardLayout` struct + tokens 钉位**：`struct FamilyCardLayout{titleFrame/valueSlotFrame/statusDotsFrame; static standard}` 所有 10 族 import standard，valueSlotFrame 唯一可 type-switch slot；tokens 钉 title_frame/value_slot_frame/status_dots_frame（投屏 1080p **实测**字号 body≥24/标题≥44 lens1 F1，非抽象≥28）；pre-commit `check:family-card-no-custom-frame` 禁 `.frame(width:`/`.padding(.top`。
2. **"懂一张懂全部"落 snapshot 视觉回归门（L6 断带首刀）**：`Tests/SnapshotTests/FamilyCardConsistencyTests` 10 族×{idle/focused/queued}3 态=30 snapshot；`swift-snapshot-testing`（star>3k 未实测标 cite-verify）；CI diff 标题/dots 偏移>1pt fail；与 demo-must-pass P0 同链路。

### Q3.5 anti-confirmation enum+switch vs 完全自定义（⭐ 守 enum+switch + 🔴1 事实型局部中立）
1. 🔴 **事实型局部中立（唯一一处，按 answer-grill 新格式）**：U26"AnyView 性能/diff 慢"在 10 族小规模未必触发，需 spike 实证再锁。
   - cite 对方：Codex Q3.5 + U26 R3-G6（`grill-master:144` enum+switch 非 AnyView 因破类型 diff 渲染慢）
   - 一手冲突：AnyView cost 主在**大列表+高频 diff**（WWDC21 Demystify SwiftUI，🔴 session URL 未核标待 cite-verify）；本项目 10 张固定+低频改（语音一次改一卡），AnyView 单次微秒级，10 张 idle **未必掉帧**
   - 不推翻 enum+switch（仍首选：架构清晰+编译穷尽+禁 default）；但**别拿"AnyView 性能"当唯一论据**——真理由是**架构论（破穷尽性+case 漂移）**
   - 验证：`spike/anyview-vs-enum-switch-10cards-perf` 0.5h，Instruments 10 卡 idle 60fps×10s 测 GPU/CPU 差，verdict 进 D3 档「性能论据=pass / fail-replace-with-architecture-arg」；A2 编译前可跑零成本
   - 🔴 **留磊哥拍是否要这条 spike**
2. **特殊族走 enum 专属 case + 子 view 文件（禁 case 内塞 100 行）**：`case .rgbWheel: RGBWheelView(state:)` 单行，子 view 拆 `Sources/MAformacApp/UI/ValueRenderers/RGBWheelView.swift`；pre-commit `check:value-renderer-case-one-line` 每 case 后仅一行；D3 档枚举 5 个 ValueRenderer 文件（continuous/discrete/rgb/switch/composite）进 ui-presentation tasks。

### D3 落档清单 + validation_gate
- 🔴 **起跑前置/validation_gate**：state-cells.yaml 10 族扩齐 + `ui_value_type` 派生字段（数据 type≠UI value.type，gen_c1.py 派生过 verify_refs）
- 归 ui-presentation capability（9 点）：UIValueType enum 派生 + @ViewBuilder 穷尽 switch + component-adoption-matrix + spike gate + GPUBudgetCoordinator + gpu-budget.md + FamilyCardLayout + snapshot 门(L6 首刀) + ValueRenderer 5 文件
- 🔴 cite-verify 待核：WWDC21 Demystify SwiftUI URL / swift-snapshot-testing star / hendriku star（answer-grill 禁臆造，标 self_build 安全默认）

### 🔴 grill 间依赖锚（D3 新增）
- **D3 → C2(state-cells)**：`ui_value_type` 派生字段 + 10 族扩齐（与 D2 `family_priority.json` 同 state-cells 扩齐 PR）
- **D3 → demo-must-pass**：GPU 预算 Instruments 3 场景 P0
- **D3 → L6 snapshot 断带**：FamilyCardConsistencyTests = snapshot-loop 首刀
- **D3 待磊哥拍**：Q3.5#1 AnyView 性能 spike（要不要跑）

---
## D4 Mac/iPhone 双屏 = 两独立纯端侧 demo 实例 + 可选 Bonjour 联动 ✅ grill 完成（2026-06-23，🔴 磊哥纠正推翻镜像假设）

> 🔴🔴 **磊哥纠正（D4 grill 中）：iPhone 不能极简，要能脱离电脑独立演示**。推翻 D1.Q1.4「iPhone only-read 镜像 Mac / no_voice_intake」+ 我原 Q4.5「iPhone 极简只读」。
> 🔴 **双重证据同指**：磊哥纠正（iPhone 脱机独立）+ Codex Q4.2 事实型反据（iOS Sandbox 物理读不到 Mac `~/Library/Containers/`，FSEvents macOS only，共享文件 transport 在 iOS 真机不成立）= **Mac 与 iPhone 是两个独立纯端侧 demo 实例**（各自 Qwen3-1.7B+LoRA + ASR + 10 族，= CLAUDE 北极星 macOS+iOS 双端），**非主从镜像**。
> 重构：Mac=主舞台大屏独立 demo / iPhone=手持脱机独立 demo（全功能接语音）/ 双屏联动(Bonjour LAN)=**可选加分**，断了各自独立跑。

### Q4.1 iPhone 内容 = 独立全功能（非镜像 Mac 活跃族）🔄 重构
- iPhone 脱机=完整 demo（自己 orb+10族+对话+语音 ASR），布局走 D1 A 方案竖屏适配（759pt 放不下 10 族常驻 lens1 F5 → 竖屏 2 列滚动+活跃置顶+触发聚焦）。
- Codex Q4.1 iPhoneScreenMode 镜像 → 改 `enum iPhoneMode{idle/active/boundary}`（U10 四态），但**驱动源 = iPhone 自己的 DemoVisualState（非读 Mac）**。
- Codex Q4.1#2 anchor PNG 保留+改：`iphone-vertical-{idle,active-ac,boundary-clarify}.png` = iPhone **独立全功能**截图；`visual-anchors/INDEX.md` 列 5 张最低集（Mac 2 + iPhone 3），premortem L3 锁，出齐前不进首刀编码。

### Q4.2 transport = iPhone 独立不依赖 + 可选 Bonjour 联动（🔴 Codex 事实型反据成立 + 磊哥纠正叠加）
- 🔴 **Codex 事实型反据全成立**：iOS/macOS Sandbox 独立，iOS App 物理读不到 Mac container（Apple App Sandbox Design Guide，🔴 URL 待 cite-verify）；FSEvents macOS only；D1.Q1.4 共享文件镜像 iOS 真机不成立。
- 磊哥纠正叠加 → iPhone 本就独立（不读 Mac），**镜像前提消失**。双屏联动（可选加分）走 **Bonjour + Network framework over LAN**（Codex 选项 A，Mac NWListener 推 delta / iPhone NWBrowser 订阅，iOS12+/macOS10.14+ 共享 API，同 wifi <16ms，需 spike 0.5h 验延迟）。
- `enum TransportKind{none, bonjour}`（**删 sharedFile 镜像**；none=各自独立默认，bonjour=两独立实例联动加分）+ protocol VisualStateTransport 多态 + TransportFactory.make()；pre-commit `check:transport-no-direct-instantiation`。
- 🔴 **留磊哥拍**：双屏 Bonjour 联动做不做（iPhone 独立 baseline 已定，联动=optional 加分 spike）。

### Q4.3 iPhone 竖屏布局 = 独立全功能接语音 🔄 推翻 no_voice_intake
- 🔴 **Codex Q4.3#2 no_voice_intake 推翻**：iPhone 接语音独立演示（自己 ASR+mic 脱机），mic_zone 是真 mic（非只读镜像"主屏聆听中"）。
- Codex Q4.3#1 layout tokens 保留：tokens iphone 段 759pt 分层（orb 120/content 440/mic 80/gap 119），`IPhoneLayout` VStack 三 zone `.frame(height:tokens)`，禁 GeometryReader 自适应；pre-commit `check:iphone-zone-height-from-tokens`。content_zone 440pt = 竖屏 10 族 2 列滚动+活跃置顶。

### Q4.4 断连/降级 = iPhone 独立无断连 + 双实例各自 standalone 🔄 重构
- 🔴 iPhone 独立**无"断连"概念**（自包含全功能）；双屏联动（Bonjour）断 → 两实例各自独立跑（非降级占位）。Codex Q4.4#1"等待连接占位"（依赖 Mac）→ 改：联动断仅撤跨屏高亮，各自照常。
- Codex Q4.4#2 standalone smoke test 保留+强化：`MacStandaloneSmokeTest` + **新增 `iPhoneStandaloneSmokeTest`**（两实例都跑 demo-must-pass P0 全 scenario，TransportKind=.none 独立配置全通）；validation_gate: `both_standalone_smoke_passed`。

### Q4.5 anti-confirmation 🔄 磊哥纠正：iPhone 不极简 = 独立全功能
- 🔴 推翻我原 Q4.5"iPhone 极简只读"。磊哥定：iPhone = 独立全功能端侧 demo（脱机可演），双屏 = 两独立实例（非主从镜像）+ Bonjour 可选联动。理由：北极星 macOS+iOS 双端纯端侧；iPhone 脱机独立 = 销售场景灵活（不必带 Mac，方案经理手机即可演）。

### D4 落档清单 + validation_gate
- 🔴 核心：Mac + iPhone = 两独立纯端侧 demo 实例（各自 Qwen+LoRA+ASR+10族）；iPhone 脱机独立演示=磊哥铁律
- `TransportKind{none,bonjour}`（删 sharedFile 镜像）+ VisualStateTransport 多态 + TransportFactory；双屏 Bonjour 联动=可选加分（留磊哥拍+spike）
- iphone layout tokens（759pt 分层）+ IPhoneLayout 三 zone + iPhone 接语音 mic
- `both_standalone_smoke`（Mac+iPhone 各自独立全 P0 通）+ anchor PNG 5 张
- 🔴 cite-verify 待核：Apple App Sandbox Design Guide URL / Network framework iOS12 版本

### 🔴 grill 间依赖锚（D4 新增 + 回写）
- **D4 → 北极星**：Mac+iPhone 双独立端侧实例（CLAUDE §1 macOS+iOS）
- **D4 → D1.Q1.4 回写**：transport 镜像 → 独立+可选联动（D1.Q1.4 标 SUPERSEDED-BY D4）
- **D4 → A2/C5（链路 B）**：iPhone 独立=iOS target 也要跑 Qwen+LoRA（端侧推理栈 iOS，A2 之后训练/部署阶段）
- **D4 待磊哥拍**：双屏 Bonjour 联动做不做

---
## D5 聚焦过渡技术选型 ✅ grill 完成（2026-06-23，🔴 最高优先 — D1.Q1.5/D2.Q2.2 validation_gate 依赖）

> CC 5×⭐ + Codex 10 点（9 加强 + 1 事实型局部中立 Q5.1）+ 🔴 **主线程辩证 check**：WebSearch 坐实 matchedGeometryEffect=iOS14/**macOS11.0+**（SwiftUI 2.0 同期，非 Codex"晚一两版"），本项目 macOS14+ → **macOS 可用性 criteria 现在 passed（不等 A2 编译）**；剩 criteria=LazyVGrid 冲突(Grid 解)+Reduce Motion(运行时验)。demo 轻治理简化 Codex 部分量产治理（全 transition test→关键竞态/多 pre-commit check→可选）。

### Q5.1 区分状态切换 vs 跨栈（⭐ 化解 lens4/lens6 + 🔴 主线程辩证 check 升级）
1. 🔴 **事实型局部中立 → 主线程 WebSearch 坐实**：matchedGeometryEffect=iOS14.0/macOS11.0+/tvOS14/watchOS7（SwiftUI 2.0 2020 同期，[Apple Developer Docs](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:))+designcode）。**Codex"macOS 晚一两版"对 mge 不成立**（SwiftUI 2.0 核心同期）；本项目 macOS14+ 远超 → **状态切换 mge macOS 可用性现坐实 passed**（不等编译）。真正待验=LazyVGrid 冲突(Q5.2 Grid 解)+Reduce Motion 剥离(Tiger7 运行时)，非 macOS 版本。+ `#available(macOS 14)` 锁底防漂移。
2. lens4/lens6 矛盾化解落 `hig-liquid-glass-rules.md §全景↔聚焦过渡`（用法 A 状态切换 mge macOS 可用 / 用法 B 跨栈 navigationTransition.zoom macOS unavailable [createwithswift+hmlongco#25] 本项目不用）= 视觉 SSOT 硬约束防 agent 误读。

### Q5.2 LazyVGrid 冲突规避（⭐ Grid 非 LazyVGrid）
1. ContentView:40 LazyVGrid→Grid 改造路径（Mac 横屏 Grid 2×5 / iPhone 竖屏保 LazyVGrid 滚动 lens1 F7）+ `grid-policy.md` 单源 + 🟡 pre-commit check:grid-vs-lazy-vgrid-by-platform（demo 可选）
2. lens6 Tiger2 三坑（isSource 显式 / matchedGeometry 必在 .frame **之前** / source-destination 对称渲染）落 hig-rules 代码模板 + snapshot `focus_expand_10_iterations`（来回 10 次 pixel-perfect 验抖闪，D3 snapshot-loop 铺路）

### Q5.3 opacityScale 兜底（⭐ + 🔴 Codex 打破循环依赖关键 catch）
1. 🔴 **打破循环依赖（Codex 全程最隐蔽 catch）**：D1.Q1.5 ripple gated_by D5，Q5.3 兜底又引 ripple = 循环。打破=ripple（Metal layerEffect 独立不依赖 mge）拆 ungate，gate 改「仅 A2 编译验证 metal shader 可用」。**回写 D1.Q1.5 ripple gate 简化**。兜底链=opacityScale+边框辉光+内容淡入+ripple(独立 gated)，无循环。
2. opacityScale token（scale 1.0→1.15 / opacity 0→1 内容淡入 / border_glow_alpha 0.85 / duration 320ms / spring response0.4 damping0.75）+ 投屏 8bit banding 验收（demo-must-pass P0「MOV4-opacity-banding-1080p」逐帧 1px 列，lens1 F1+D1.Q1.3 同坑）

### Q5.4 320ms 协调（⭐ 双独立 token 已锁）
1. 320ms 对齐 D2.Q2.4 `ExpansionAnimation enum`（不新建第二套）：`enum durationMs{expand/collapse:320, fallback:240}` + tokens `expansion.duration_ms:320` 单源，Swift 只引 tokens 不裸写。
2. expansionPolicy 完整状态机（展开 80% 来 multi-intent → 中断 collapse → highlight_queue / 跨族切换 collapse→expand other）落 `docs/design/focus-state-machine.md` + Mermaid；🟡 **demo 轻治理简化**：关键竞态 test（展开中断 / 跨族切换 / multi 中断）非全 8 transition test。

### Q5.5 anti-confirmation gated upgrade（⭐ 不现在拍死 + 默认 opacityScale）
1. promotion_criteria 二值判定（辩证 check 细化）：🔴 **macOS 可用性那条现在 passed**（WebSearch 坐实 mge macOS11+，本项目 macOS14+）；剩 swift_build / snapshot focus_expand_10 抖闪 / manual_smoke / reduce_motion_fallback 待 A2 实装验。全 pass → 升级 matchedGeometry + 回写 D1.Q1.5/D2.Q2.2 gate passed；任一 fail → 保 opacityScale。
2. gated upgrade commit message 标 `[D5-upgrade-mge]` + evidence（轻量保）；🟡 pre-commit check:gated-upgrade-evidence demo 降可选（量产治理，单人靠 review）。

### D5 落档清单 + validation_gate（辩证 check 后细化）
- 🔴 **macOS 可用性 criteria 现在 passed**（mge macOS11+ WebSearch 坐实，本项目 macOS14+）
- 剩 criteria（A2 实装运行时验）：LazyVGrid 冲突(Grid 解设计层) + snapshot focus_expand_10 抖闪 + reduce_motion_fallback
- 默认 opacityScale + mge gated upgrade（promotion_criteria 全 pass）；D1.Q1.5/D2.Q2.2 gate gated_by 此
- 归 ui-presentation：focus-state-machine.md + hig-rules §过渡 + grid-policy + opacityScale token + ExpansionAnimation enum
- 🔴 Codex 打破循环：ripple ungate（回写 D1.Q1.5）
- 🟡 demo 轻治理简化（vs Codex 量产）：全 transition test→关键竞态 / 多 pre-commit check→可选（保 promotion_criteria 5 条 + 状态机图 + Grid 规避 = 可靠性内核）

### 🔴 grill 间依赖锚（D5 + 辩证 check）
- **D5 → D1.Q1.5/D2.Q2.2**：mge gated upgrade（macOS 可用现 passed，剩 LazyVGrid/Reduce Motion 运行时验）
- 🔴 **D5 → D1.Q1.5 回写**：ripple ungate（打破循环依赖，ripple 仅 gated_by metal shader 可用）

---
## D6 炸场高潮特效 ✅ grill 完成（2026-06-23，最后一个 D）

> CC 5×⭐ + Codex 10 点（7 加强 + 🔴3 事实型反据 catch 我 CC 的 claim-vs-reality 错）+ 🔴 主线程辩证 check（接受 Codex 3 catch + 谨慎迎合简化 Codex 过度量产治理）。
> 🔴 **Codex catch 我 CC 3 处 claim-vs-reality 错（诚实接受改正）**：① Q6.2 我引"synth D6 已定"=循环（synth 是 lens 调研非 D6 决策）② Q6.3 我引"TTS DEFERRED"错向（D4 双独立 iPhone 接语音 TTS 端侧实存）③ Q6.4 我引"README:107"幻引用（#ffb13c 实在 tokens.md:45）。

### Q6.1 metal shader 选型 + GPU 预算（⭐ orb/ripple/ambient 三 shader）
1. shader 三件套落 `docs/design/shader-inventory.md` + #available 双平台矩阵：orb MeshGradient(iOS18/macOS15) / ripple layerEffect(iOS17/macOS14) / ambient Sinebow(iOS17/macOS14)；**每 shader 必有 fallback**（orb→AngularGradient 静态 / ripple→边框 glow 脉动 / ambient→单色呼吸，lens1 F8 降级延伸）；pre-commit check:shader-has-fallback。
2. GPUBudgetCoordinator Lease 扩 3 shader（D3.Q3.3 enum 扩 orbBackground/rippleTransient/ambientBand）：mlx 互斥 ALL shader / orb 与 ripple/ambient 可并行(低成本) / ripple 期 ambient pause；priority[ripple,mlx,ambient,orb,idle]；gpu-budget.md 扩 3-shader 同屏场景。

### Q6.2 多 wow 编排（⭐ + 🔴 Codex catch 我引 synth 循环）
1. 🔴 **接受 catch（我 CC 错）**：改正=wow 4 段**本轮 D6 拍板落 `docs/design/wow-choreography.md`**（非引 synth）：S1 ambient_intro(boot_reveal 后 1200ms)/S2 single_focus(first_voice 320ms+ripple once)/S3 multi_highlight(voice≥2, n×220ms sequencer)/S4 offline_morph(network→offline 800ms cyan→amber)；每段 trigger/duration/shader_lease/demo-must-pass P0-W1~4。
2. golden-run 接口现预留 protocol（后端 DEFERRED 也立）：`protocol GoldenRunReplay.replay(scenarioId,callback:(WowSegment))` + `enum WowSegment{ambientIntro/singleFocus/multiHighlight/offlineMorph}` + `MockGoldenRunReplay` 写死 4 段让 D1.Q1.2 sequencer 当下消费；后端落地只换实现 UI 0 改（Pattern 5 三向同源）。

### Q6.3 TTS 时长协调（⭐ 视觉 happens-before + 🔴 Codex catch 我 TTS DEFERRED 错向）
1. 🔴 **接受 catch（我 CC 错向）**：TTS 端侧实存（非永久 DEFERRED，对齐 D4 双独立 iPhone 接语音）。⚠️ **实装时机辨析（主线程 check 补）**：A2 链路 B 阶段 voice DEFERRED（A2 code-only），但 **demo 最终 TTS 端侧实存（D4 要求）**，UIUE D6 现在只预留 `TTSEngine protocol`（实装=demo voice 阶段，非 UIUE 首刀）。物理化=`protocol TTSEngine.speak(text,priority)->AsyncStream<TTSEvent{willStart/didStartAudio/didFinish/didFail}>`；U22 immediate ack=VisualAck 在 speak 同帧/早一帧(tokens tts.immediate_ack.preempt_ms:16)不等 TTS 事件。
2. TTS 端侧选型落 `docs/design/tts-policy.md`：AVSpeechSynthesizer 双端 native zero dep；locale zh-CN（U28 锁普通话）+fallback；warmup dummy speak 预热；pre-commit check:tts-locale-zh-CN-only。

### Q6.4 断网高潮（⭐ cyan→amber morph + 🔴 Codex catch 我 README:107 幻引用）
1. 🔴 **接受 catch（我 CC 幻引用）**：README:107 不存在；#ffb13c 真实在 `tokens.md:45`（scheme1:28,33,83）改正 cite。+ cyan→amber morph 投屏 8bit banding 必加 dither（tokens state.transition.dither_enabled，lens1 F1）。
2. "全族卡保持响应"落 demo-must-pass **P0-OFFLINE-1**（飞行模式跑完整 5min：ASR 端侧 onDevice/LLM mlx/mock 车控本地/TTS AVSpeech 端侧/视觉/morph/徽章全过）+ NWPathMonitor unsatisfied 禁所有出站（pre-commit check:no-http-in-demo-path 禁 URLSession.shared/URLRequest）= 断网照跑可测物理约束。

### Q6.5 anti-confirmation 炸场 vs 不崩（⭐ 稳>炸 + 🟡 主线程辩证 check 简化 Codex degradation ladder）
1. 🟡 **谨慎迎合简化（lens1 F9 M5 算力够，Codex 5 级 ladder 过度量产）**：Codex degradation ladder 5 级 + fps<58/gpu>0.75/thermal 自动降级是量产多设备级；lens1 F9 坐实 M5 算力充裕、瓶颈显示侧非 GPU、demo 单台 → **简化到双通道（ReduceMotion/低电量 2 通道，可能触发）+ thermal watchdog（5min 兜底）**，砍 5 级 fps/gpu 自动 ladder。保 stability>wow（北极星不崩）。
2. 双通道铁律落覆盖（🟡 简化 Codex 35 格 test）：保 dual-channel 原则（7 态 ReduceMotion/低电量都有颜色/数值/图标承载，tokens.md:85）；🟡 snapshot 验关键态×两极（safety/offline/exec/clarify × level_0 full / level_最简）非全 35 格量产。

### D6 落档清单 + 辩证 check 结论
- 🔴 接受 Codex 3 catch（我 CC claim-vs-reality 错改正）：synth D6 循环 / TTS DEFERRED 错向 / README:107 幻引用
- 归 ui-presentation：shader-inventory.md(+fallback 矩阵) + wow-choreography.md(4 段) + tts-policy.md + GoldenRunReplay protocol(Mock) + TTSEngine protocol(接口预留)
- 🟡 谨慎迎合简化 Codex 过度量产（保可靠性内核砍量产治理）：degradation ladder 5 级→双通道+thermal watchdog（lens1 F9 M5 够）/ dual-channel 35 格 test→关键态×两极
- 🔴 TTS 实装时机：demo voice 阶段端侧实存（D4），UIUE 现预留 TTSEngine 接口（A2 链路 B voice DEFERRED）

### 🔴 grill 间依赖锚（D6）
- D6 → D1.Q1.2 sequencer：wow 编排走 sequencer + GoldenRunReplay Mock
- D6 → D3.Q3.3 GPUBudget：Lease 扩 3 shader
- D6 → demo-must-pass：P0-W1~4 wow + P0-OFFLINE-1 断网
- D6 → D4：TTS 端侧实存（双独立 demo），非永久 DEFERRED；voice 实装=demo voice 阶段

---

## 🔴 D1-D6 全 grill 完成（2026-06-23）— 待落 ⭐A 三处级联
| 决策 | 状态 | 关键 validation_gate / 待办 |
|---|---|---|
| D1 主视图形态 | ✅ | Q1.5 ripple 已 Q5.3#1 解循环（ungate）|
| D2 族内下钻 | ✅ | prerequisite: family_priority.json(A2 G2) + voice_device_coverage.json(lora-data-gate) |
| D3 异构值 | ✅ | state-cells 10 族扩齐 + ui_value_type 派生 |
| D4 双屏 | ✅（磊哥重构）| 双独立 demo 锁；Bonjour 联动 0.5h spike 可选 |
| D5 聚焦过渡 | ✅ | macOS 可用性现 passed（mge macOS11+）；剩 LazyVGrid/ReduceMotion 运行时验 |
| D6 炸场 | ✅ | wow-choreography + 双通道（简化版）|

> **下一步（待磊哥）**：落 ⭐A 三处级联（grill-master §3 决策晶体 + roadmap 升级 + ui-presentation change skeleton 含 design.md）。Codex 建议「先 A2 编译 spike 跑 D5 promotion_criteria 5 条再落档」—— 待磊哥拍 spike 先后。磊哥预告「有个大活」。
