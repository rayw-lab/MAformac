---
type: uiue-visual-gate-harden-grill-decisions
status: ✅ 视觉门 grill 收口（C0/C1 校准 + Q1 范围 + U32 框架 + U33/U34/U35/U36/U37 全拍，2026-06-26）；apply 进度 = 8.G1-G8 已落并经 local/unit 门，8.G9 未落，8.C2/L3 仍 open；设备：仿真 iPhone 17 Pro/Pro Max（主验收），真机 iPhone 15 Pro Max（延后不急）
date: 2026-06-26
owner: UIUE 链路 A（worktree MAformac-uiue, 分支 uiue/phase4-default-scope-presentation）
方法: grill-with-docs engineering-contract mode + pre-mortem oracle 核证 + frame-break
编号: U32-U37（续 UIUE U 系列，挂锦标赛 Q38「组件 adoption gate + 真实查看环境验收」）
change-target: 单个 OpenSpec change（ABC 揉一起：A 视觉门契约 + B 流程机制 + C 代码，磊哥 2026-06-26 拍，不降级）
trigger: codex ~15h UIUE A-2 长跑结束复盘 → 优化整个流程/机制/方法（先 UIUE 大方向→范围→再下钻 codex 代码）
关联:
  - docs/grill-tournament/GRILL-SYSTEM.md（编号/目录/索引规范）
  - docs/grill-tournament/grill-decisions-master.md §3（U 系列决策 SSOT，本档挂 Q38 下 U32-U37）
  - docs/grill-checklist/uiue-a2-grill-coverage-index.md（coverage 索引登记）
---

# UIUE 视觉验收门 hardening + 长跑流程机制优化 — grill decisions（U32-U37）

> engineering-contract grill mode：每条决策带 physical landing（可 enforce 字段/脚本/spec）+ pre-mortem triage + evidence。决策 SSOT 挂 `grill-decisions-master.md` §3（U32-U37）。
> ⚠️ **设计态 ≠ 验收态（completion-claim 总边注）**：本档最初拍的是【设计决策】；截至 2026-06-26 晚间，8.G1-G8 已落，8.G9 未落，A-2 仍 **PARTIAL**，**8.A/8.C2/6.4 未关**。不得因 grill 拍板或 8.G 局部落地写成视觉验收闭合 / V-PASS。

## 背景（一手核证摘要，2026-06-26）

### A 选项 — codex ~15h 长跑审计结论（CC 主线程亲核，非信 verdict）
- 规模：~15h wall / 2895 exec_command / 35 compaction；**33× `swift test` + 151× `xcodebuild` + 3× `make verify-all`**（jsonl 实证，真跑非声称）。
- **无 `git reset/checkout/clean/revert`** — "23 M 文件"committed 成 `98f7c57`（+4290 行），未丢/未 revert。
- verdict 诚实坐实：A-2 PARTIAL，8.A/8.C2 open，**danger grep 空**（无 Phase2/visual 偷标 done/V-PASS）。
- **CC 独立重跑**：`swift test` 245/3skip/0fail + `make verify` exit0 ✓（@e784c4e，2026-06-26 亲跑）。
- 🔴 病灶：**55× `phase2_zone_compare.py` + 241× `magick` + 截图 v1→v72**，Phase 2 像素死循环不收敛 → 磊哥叫停。= 像素 RMSE 反模式实证现场。

### proposal oracle 核证（协同 agent「UIUE视觉验收门联网增强建议」+ CC 联网核）
- 8 技术断言**全核实**（Applitools exact 不推荐 / SSIM perception-based / LPIPS PyTorch 依赖+对UI小元素不准 / swift-snapshot-testing 同模拟器约束 / ImageRenderer 不捕捉 glass+material / WCAG 4.5:1·3:1 / HIG Reduce Motion）；仅 ODiff「抗锯齿略友好」表述要修。
- **主线程亲核精确引用**：ISO 15008:2017 真实（2025 复审 current）+ 7mm 中文字高研究真实（MDPI Applied Sciences 2025），**无编造**。
- tiger：T1 simulator 漂移→L1 flaky / T2 glass/material off-screen 渲染失真 / **T3 iOS26 idb drag 破**（= codex 实际卡点）/ E2 感知 metric ≠ 高级感（L2 绿禁当 L3 替代）。

---

## 范围校准（meta 决策，磊哥 2026-06-26，不占 U 号）

- **C0 投屏全删**：supersede `docs/uiue-storyboard-grill-decisions.md:326` V10 的「1080p 投屏截图 / 还原投屏环境」；保留 V10「最小字号 / 中文最长文案 / 44pt touch / Reduce Motion / 低电量」。理由：demo master agent 演示助手，方案经理手持演示**不投屏**。
- **C1 定位 = demo 演示助手非车载工程**：ISO 15008 / 7mm / WCAG 车载标准 = **内部参考下限，不进硬门**。
- **Q1 ABC 揉一个 OpenSpec change**：A 视觉门契约 + B 流程机制 + C 代码，**不拆三个 change，每块做足不降级**。
- **不降级原则（贯穿）**：demo 也要高级感；drag proof 的「降级」只能是**取证手段**（force-state 截图代真 drag，因 iOS26 idb 破），**绝不连累视觉/体验降级**（见 U36）。
- **脏区 ignore**：`.gitignore` 加 `shots/` + `zone-compare-v*/` + `app-state-phase5-ambient/` + 顶层 `*-sidebyside.png`（v1→v72 死循环产物 687M 不入仓）。

---

## U 系列决策（U32-U37，挂 Q38）

### U32 — 视觉验收门分层架构 L0-L3（🟡 框架拍定 2026-06-26，U32-Q1；≠验收闭合）
- **✅ 门 vs 证据定位（核心 frame，磊哥 2026-06-26 精确化）**：
  - **L0 runtime-truth = 🚪真门**：截图绑 device / launchArg / theme / UItree 证据 / screenshot-path / proof_class，**必 on-screen `simctl io screenshot`，禁 off-screen ImageRenderer**（防 T2 glass/material 失真）；缺 L0 不进评分。
  - **L1 sentinel（U33）= 🚪有限机械门（只挡塌陷）**：PASS/WARN/FAIL，不追 RMSE 小数、不拍审美。
  - **L2（U34）= 有限机械门 + 证据层**：OCR + contrast = 🚪可读性硬门（文字看不清 FAIL）；SSIM = 📋仅退化证据（**非审美门**）。
  - **L3 人工 5-gate = 🚪唯一审美终裁**：复用 aesthetic-first 5-gate（层级/对齐/遮挡/字体/重量）+ V10 非投屏可读性；verdict enum = V-PASS / V-PASS_WITH_NOTES / PARTIAL / FAIL；**V-PASS 只能磊哥给，机器不能给**（demo 一人看，不需排期）。
  - 🔴 **核心 frame**：**L0/L3 = 真门**（L0 真实性 + L3 人工审美）/ **L1/L2 = 有限机械门 + 证据层**——不建自动审美评委，防「L2 绿当 L3 pass」E2 + 防再陷 v1→v72 追分死循环。**不降级点** = L0 真实性 / 文字可读 / 人工审美都保留硬门；**不过度工程化点** = L1/L2 只当廉价哨兵 + 证据生成器。
- ⚠️ **代码态 / 闭合态边注**：U32 是【设计决策】；A-2 仍 PARTIAL，8.A/8.C2 未关。
- **physical landing**：落 spec Requirement「visual-acceptance-gate L0-L3」+ coverage 8.C2 验收口径；L0 字段表细化随 U37（PresentationSnapshot）+ spec。

### U33 — L1 zone_compare 语义降级 + long-run stop-rule（✅ 设计拍定，✅ 8.G4 已落）
- **physical landing**：`Tools/checks/phase2_zone_compare.py` 输出改 **PASS/WARN/FAIL**（下限塌陷报警，禁输出逼近分）+ **long-run stop-rule**（2 轮无新 proof-class 强制收口）。
- ✅ **代码态更新（2026-06-26）**：8.G4 已将 `Tools/checks/phase2_zone_compare.py` 主输出改为 **PASS/WARN/FAIL**，RMSE 保留为诊断列，并加入 stop-rule/self-check；后续仍只算 L1 sentinel，不签审美。
- 🔴 **nuance（grill-recall）**：现有决策（plan v3 `## heavy-work harness 管控` 段，磊哥 2026-06-25）原意**已是**「anchor = 视觉质量下限基准，非 1:1 复刻，crop/mask 动态区，看视觉重量/层级/质感/留白」≈ L1 sentinel。病不在磊哥决策，在脚本实现成 RMSE score + 无 stop-rule。本条 = 修脚本语义 + 加刹车，**非推翻像素门**。

### U34 — L2 指标选型：SSIM 纳入，LPIPS 不上（✅ 已拍）
- **physical landing**：L2 = **SSIM**（退化证据，非审美门）+ **OCR**（文字可读/截断硬门）+ **WCAG contrast sampler**（4.5:1 normal / 3:1 large per WCAG 2.2 SC 1.4.3，硬门）；**LPIPS 不进**（PyTorch 依赖、对 UI 小元素权重不准、设计系统 regression 过宽）。
- **evidence**：oracle 核 LPIPS 局限（torchmetrics 文档 / richzhang/PerceptualSimilarity）。**frame（E2）**：L2 只防退化，**禁当 L3 审美 pass 替代**。

### U37 — 一进两出 contract（✅ 拍定 2026-06-26，U37-Q1）
- 🔴 **grill-recall 铁证**：`PresentationSnapshot`（`Core/Presentation/PresentationSnapshot.swift:59`）已是一进容器（视觉侧 storeCells/activeCells/orbState/voiceState + 话术侧 dialogText/readbacks 同源）；`DemoRuntimeResultKind`（`:3-11`）已 8 态 CaseIterable；proposal 要建的 Visual/Verbal Model + Adapter 三类**全不存在**。
- **✅ physical landing（不新建三类 Model）**：
  1. **PresentationSnapshot 继续是唯一「一进」容器**，不新建 VisualPresentationModel/VerbalPresentationModel/PresentationAdapter（proposal 量产形态 = 过度工程化）。
  2. **视觉输出 + 话术输出都只能从 snapshot 字段派生**（视觉 ← cells/orb/voice；话术 ← dialogText/readbacks）。
  3. 🔴 **精确措辞（磊哥 2026-06-26 纠正，防 claim-vs-reality 过度声称）**：是「**presentation derivation 只读 snapshot**」，**不是**「ContentView 全程只读 snapshot」——**mutation / provider 层可写 store**（如 `App/ContentView.swift:271-283` mock transition：`store.replaceCells` / `store.applyMockTransition` 后 `:283 snapshot = PresentationSnapshot.from(store:)` 回灌），mock 前台合理；**契约 = 写完必回灌成下一帧 snapshot，渲染层不绕过 snapshot 重算展示事实**（抗未来接真 TTS/NLU 分叉）。
  4. **DemoRuntimeResultKind.allCases 8 态 VUI 矩阵测试**：每态有 视觉态 + 话术 + 动效 + 是否 TTS + proof class，**禁 default 吞态**（derivation 铁律1）；矩阵落 spec。
- **pre-mortem**：🐯tiger = 接真 TTS/NLU 时话术绕过 snapshot 自读 store 分叉 fake-green（验证：契约测试 + 话术唯一源=snapshot）；🐱paper-tiger = 「不拆三类会分叉」（实际单容器 + 回灌契约已防，拆类徒增 demo 轻治理）；🐘elephant = demo 不演的态（runtimeError/cancelled）穷尽测试仍要覆盖（防漏态翻车，mock 给占位话术）。

### U35 — negative-space 进门维度（✅ 拍定 2026-06-26）
- ✅ **进门只加 Reduce Motion**（独立硬维）：炸场粒子/氛围灯/orb 动效必须有降级路径（HIG）；🔴 **Reduce Motion 态也跑 L3 5gate**（禁降级成白板）+ **静态「在思考」反馈**（禁动效后客户不能以为卡死，配 U37 voiceState 视觉态）。
- **已被其他门覆盖（不重复）**：Contrast → L2（U34）/ 最小字号·44pt·字体 → L3 5gate + L2 OCR / 低电量 → V10 保留。
- **DEFERRED（demo 固定设备 + 控话术）**：Dynamic Type（仿真 iPhone 17 Pro/Pro Max + 真机 15 Pro Max 固定字号，手持演示不调系统字号）/ Color-blind（V9 SF Symbols 图标 + 文案冗余兜底）/ 中文截断 / 多语言 / RTL / Motion sickness。
- **pre-mortem**：🐯tiger = Reduce Motion 全禁后界面塌成白板（验证：禁动效态跑 5gate）+ 思考反馈丢失（静态替代）。

### U36 — 交互取证策略：按【控件动作】分类，不按族（✅ 拍定 2026-06-26，U36-Q1/Q2）
- 🔴 **grill-recall 实况（CC cite-verify 坐实，全路径）**：`Core/Presentation/UIValueTypeMapper.swift:306` mapping 把 10 族 base 显式映射 5 类（dial/percent/stepper/toggle/badge，已禁 default 吞错 + 契约闭合测试）；展开层 `App/ExpandedFamilyCard.swift:99` 通用动作 = **dial/percent/stepper 全走 ± step（tap）** + toggle 切 + badge 循环；**连续拖仅 AC 温度 hero `ThermalRangeBar`（`App/ContentView.swift:2105`）一处**，非 10 族所有 dial/percent 都有连续拖。
- ✅ **physical landing（取证按交互动作分，标进 receipt `evidence_kind`，enforce 非 declare）**：

  | evidence_kind | 动作 | 取证 | 证明 |
  |---|---|---|---|
  | `tap_step_proof` | stepper ±/选档 · dial/percent ± step | 自动化 tap | state 写入 + snapshot 回灌 + 视觉刷新 |
  | `toggle_proof` | toggle 切 | 自动化 tap | 同上 |
  | `badge_cycle_proof` | badge 循环 | 自动化 tap | 同上（每态穷尽） |
  | `continuous_drag` | **仅 AC hero ThermalRangeBar 拖** | 高级体验动作；过程证 = operator-pass / 真机 / 未来工具 | 拖动**过程**（中间帧/手势连续） |
  | `terminal_visual_only` | force-state 注入 | 仅终态视觉 | 🔴 **禁写成 drag/tap 过程 proof**（防假验收，磊哥 2026-06-26 锁） |

- 🔴 **关键纠偏（claim-vs-reality 防单样本外推）**：codex「AC stepper tap 26→27 已过」只证**策略可行**，**≠ 所有族 tap 已过**。补**代表族自动化样本矩阵**（每代表族取 1 条，落 spec + coverage）：空调风量(stepper) / 座椅 加热·通风·按摩(stepper) / 车窗·天窗开度(percent ± step) / 灯光·香氛·雨刮(toggle/badge) / + AC hero 连续拖(operator-pass)。未补的标 pending，不算已验。
- **reuse**：代表族矩阵 + U37 8 态穷尽测试**复用** `UIValueTypeMapper` 现有契约闭合测试模式（`FamilyDisplaysTests`，参 `:303`），别另造。
- **pre-mortem**：🐯tiger = 单样本外推全族（纠偏：代表族矩阵逐条补）；🐘elephant = badge/toggle 态全覆盖（8 色氛围灯每色、门开/关穷尽 tap，非测一态）。

---

## 收口动作 / change 落点（✅ 定 2026-06-26）
- 🔴 **change 落点 = amend 现有 `ui-presentation` change，不新建**（探测发现它已是 A-2/UIUE carrier + 已有 8.C2 视觉门 + drag 卡点；新建 `harden-uiue-visual-acceptance-gates` 会分叉 → 磊哥拍揉进，防双份）。
- ABC 落地：**A 契约** → `openspec/changes/ui-presentation/design.md AD-15` + `tasks.md 8.C2`（L0-L3）；**B 流程** → `tasks.md 8.G3`（plan/skill 回写，apply 待做）；**C 代码** → `tasks.md 8.G4-8.G9`。

## 级联（grill-baseline-skeleton 预留，逐项勾）
- [x] 归位 grill-tournament/ + 编号 U32-U37 + frontmatter 规范化 + cite 全路径（2026-06-26）。
- [x] master `grill-decisions-master.md` §3 加 U32-U37 + U11-U31 一把过 banner + U23/U24 投屏 DELETE + GRILL-SYSTEM.md §5 登记。
- [x] coverage-index `canonical_inputs` 加「视觉门 U32-37」。
- [x] V10（`docs/uiue-storyboard-grill-decisions.md:326`）+ U23/U24 标 SUPERSEDED-投屏维度。
- [x] **OpenSpec change（amend `ui-presentation`，非新建）**：design `AD-15` + tasks `8.C2`（L0-L3 修投屏 stale）+ tasks `8.G`（ABC 实施清单）已落。
- [x] **apply 已落 8.G1-G8**：L0-L3 spec / 8 态 VUI 矩阵 / heavy-work stop-rule / L1 sentinel / `ui_value_type` 投影与 HVAC 债务 / evidence_kind 矩阵 / Reduce Motion 静态降级。
- [ ] **apply 待做（后续）**：8.G9 U14-U18 剩余补强。
- [x] `openspec validate ui-presentation --strict` + `make verify-all` / `swift test` 已由 8.G 各提交反复跑过；最终 8.C2/L3 仍须另行验收。
