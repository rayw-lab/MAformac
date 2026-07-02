---
authority: commander_dispatch_d22
artifact_kind: c5_gate_construction_dispatch
dispatch_id: SPEC-G6
gate: gate6 C6 四层阈值化 fail-closed + 裁决-B positive-not-diluted
worker: W1 codex %44
worktree: /Users/wanglei/workspace/MAformac-g6 (branch c5gate/g6-c6-four-layer, base origin/main 771f48ad)
carrier: openspec/changes/rebuild-c6-four-layer-bench (R7 route-only signed unlocks §1/§2/§3 construction)
r7_boundary: construction-only — 不 run 模型 / 不训练 / 不 C6 acceptance / 不 base recalibration / 不 candidate compare
created: 2026-07-01
status: pending_cc_audit
---

# SPEC-G6 — gate6 C6 四层阈值化 fail-closed + 裁决-B（positive-not-diluted）

## §0 Commander Preamble（你是谁 / 一句话使命 / 防什么）

你是 **W1（codex `%44`）**，本派单 commander = MAformac 线 claude-commander。
**一句话使命**：把 C6 bench 的四层（golden / demo_fuzz / unsupported / safety）从【只统计 hardFailureCount】升级为【逐层阈值化 fail-closed 判定】，并加【裁决-B：positive action 轴独立 fail-closed 不被稀释】invariant。**全 construction（写 harness 代码 + fixture/单测），绝不 run 模型 / 训练 / C6 acceptance。**

🔴 **你在防两次双仓惨败重演**（每个判定都要想着它们）：
- **惨败1（C5 PR5 `0/34`）**：positive action 全塌（base 10/23 → lora 0/23），但 negative 提升把整体 hard_pass 撑起来 → **混合体假象**掩盖 positive 塌。审计只看聚合 receipt 没下钻 axis（`docs/c5-recovery-2026-06-22/8d-rootcause.md:30-32`,`:101-102`）。
- **惨败2（θ-α）**：generated-positive 全 checkpoint 塌（乱调→不调 collapse），surface mismatch + 安全层退化被总分抵消。
- 本 gate 正是这两次惨败的**结构性防线**：四层各自 fail-closed（安全/unsupported 退化不能被 golden/positive 抵消）+ positive 轴独立（不被 negative/readback/no-call 稀释）。

## §0.5 🔴 决策状态：⭐-default pending 磊哥 formal lock（必读，防计划态当执行态）

本派单引的 E-002~006 / F-043 当前 grill `status: proposed`（SYNTHESIS `grill_complete_pending_human_signoff`；`reduction-table.md:60` locked=0 待磊哥 §2 人审拍板）。commander 按磊哥 standing「有推荐选项默认你的推荐」treat ⭐ 为 **working-default** 推进 construction。**硬要求**：四层阈值常量（golden 100% / demo_fuzz 80% / unsupported 100% / safety 100%）+ positive-not-diluted / OOD 阈值做成 **table-driven / 具名配置常量**（集中一处，非散落硬编码），便于磊哥 formal lock 版若调整 → 零返工。magnet formal lock 后 commander 回写 landing-matrix locked。

## §1 Authority & R7 边界（精确，别越线）

**已解锁（`docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md` frontmatter `route_deframing_unlocks`）**：
- `rebuild_c6_section_1_construction_preconditions`
- `rebuild_c6_section_2_d_domain_expected_tool_construction`
- `rebuild_c6_section_3_four_layer_bench_construction`

本 gate6 = rebuild-c6 §3 four-layer bench construction，**在解锁范围内**。human-owner 磊哥 2026-07-01 指令「推进 5 个 gate 先」= 本构建 lane 的 apply 授权（commander-log D-006）。

🔴 **BLOCKED（`route_deframing_blocks` + R7 Forbidden，绝不做）**：
1. **不 run 任何模型**（不跑 base / candidate 推理；C6 acceptance / model-quality evaluation = BLOCKED）。
2. **不训练 / 不生成训练数据**（retrain_c5 = BLOCKED）。
3. **不 D-domain base recalibration**（AD-C6-002：`active_base_anchor` 等词禁用，旧 generic-frame 10/23 不作 active 阈值，只作 historical 风险依据）。
4. **不 §4 candidate comparison**（需 signed candidate + run auth，BLOCKED）。
5. **不碰 voice / golden-run / endpoint / UIUE merge / V·S·U-PASS**。

**你做的 = 纯 harness/scorer 代码 + fixture/单测**（`C6BenchCase` 合成样本喂进 selector/阈值判定，断言分类正确、fail-closed 正确）。允许的验证（AD-C6-011 / tasks §2.3）= `swift build`、`swift test`（针对你新加的单测）、`archive-check verify-gold`（**no model run** 的 shape 检查）。**不准把跑模型当证据。**

## §2 Worktree & 路径（代码区 vs 只读 SSOT 区，别搞混）

- 🔴 **你的代码工作区** = `/Users/wanglei/workspace/MAformac-g6`（**第一步 `cd` 进去**；branch `c5gate/g6-c6-four-layer`，base origin/main）。所有代码改动、`swift build/test` 在此。
- **你的派单 + grill SSOT（只读参考，绝对路径，在主 worktree）** = `/Users/wanglei/workspace/MAformac/docs/c5-training-readiness-grill/`（本派单 + `landing-matrix.md` + `worker-3-eval-decisions.md`[E-] + `worker-commander-failure-defense-decisions.md`[F-] + carrier `openspec/changes/rebuild-c6-four-layer-bench/{design,tasks}.md`）。你的 g6 worktree 没有 grill dir（它在本地分支），用绝对路径读主 worktree。
- ⚠️ **不要 commit 到 main**，只在 `c5gate/g6-c6-four-layer` 分支提交。最终 PR 由 commander rebase 上 main（merge = 磊哥的最终 apply 授权）。

## §3 Required Tool Contract（🔴 gitnexus 强制，磊哥铁律）

repo 已 gitnexus 索引为 `MAformac-r5-main-current`。**改任何 symbol 前必跑 gitnexus，不准裸 grep 改**：
1. **改前 impact**：`impact({target:"<symbol>", direction:"upstream", repo:"MAformac-r5-main-current"})` → 报 blast radius（直接 caller / 受影响 process / risk 等级）。HIGH/CRITICAL 必先报 commander 再动。
2. **找流用 query**：理解 C6 评测流用 `query({query:"...", repo:"MAformac-r5-main-current"})`，别只 grep。
3. **commit 前 detect_changes**：`detect_changes({scope:"compare", base_ref:"main", worktree:"/Users/wanglei/workspace/MAformac-g6"})` 核改动只碰预期 symbol/flow。
4. **commander 已先跑**（你接着用，但自己再核一次）：`C6Bucket` impact=**LOW（0 upstream）**——安全可改/rename（呼应 AD-C6-007 §3.4 rename 选项）。

**其它 skill**：做前读 `Tools/agent-platform-plugin-refs/build-macos-apps-*`（SwiftUI/macOS 构建）。

## §4 Live Truth — C6 当前代码现状（commander 已 gitnexus + 逐行亲核）

> 🔴 **行号 base 说明**：下列行号在 commander 主 worktree HEAD `e894eb71` 核的；你的 g6 base = `771f48ad`（origin/main）。`e894eb71` 相对 `771f48ad` 仅含 docs commit（D24 receipt），**不碰 `Core/Bench/`，C6 行号两 commit 一致**。M1 reconfirm 核到一致即正常，**不必因 base SHA 字面不同 halt**（AD-C6-012 reconfirm 仍跑，只在行号/语义真移位时才停）。

文件 `Core/Bench/C6VehicleToolBench.swift`（1849 行）：
- `C6ExternalLayer` enum（`:292-297`）= golden / demoFuzz(`"demo_fuzz"`) / unsupported / safety —— **四层枚举已存在**。
- `C6ExternalLayerSelector.layer(for:)`（`:299-312`）= 已把 case 分到四层（riskRuleIDs/refusalSafetyOrPolicy→safety；refusalNoAvailableTool→unsupported；coverage/fuzz tag→demoFuzz；else→golden）—— **分类逻辑已有**。
- `C6CaseBehaviorClassResolver.resolve()`（`:263-290`）= 解析五行为类（toolCall/refusalSafetyOrPolicy/clarifyMissingSlot/alreadyStateNoop/refusalNoAvailableTool）。
- `C6ExternalLayerStats`（`:769-781`）= per-layer `caseCount/runCount/hardFailureCount` —— 🔴 **只有计数，无阈值/无 fail-closed**。
- `externalLayerStats()`（`:1474-1489`）= 算上面的 stats，**只 reduce hardFailures，没有阈值门**。
- `behaviorClassStats()`（`:1451-1472`）= per-class 计 hardFailureCount，**无 positive 轴独立 fail-closed**。
- `C6Summary.status`（`:1423`）= 硬编码 `"local_construction_report"` —— 🔴 **不从四层派生 pass/fail verdict**。
- `C6GateResult`（`:649-681`）= per-case gate，**已有** `modelHardFailed` vs `readbackHardFailed` 拆分字段（AD-C6-008 plan P 已部分落地）。

🔴 **gate6 缺口 = 在【已有的四层分类 + per-layer 统计】之上，加【逐层阈值 fail-closed 判定】+【summary status 从硬编码改为四层派生的 fail-closed verdict】+【裁决-B：positive action 轴独立 fail-closed invariant】**。不是从零建四层（四层分类已有），是加阈值化判定层。

## §5 Inlined Grill 决策（SSOT 逐字，别只看编号——dispatch-inline-ssot）

### gate6 四层阈值（**决策源** = W3 评测范式官 grill `worker-3-eval-decisions.md`；**本派单 W1 负责实装**，别困惑归属）
- **E-002 四层门是总分还是逐层**：⭐**C = golden/demo_fuzz/unsupported/safety 分层各自 fail-closed**（防 positive 提升抵消 safety/unsupported 退化，对应 P5/P6 no-call 与 hard_pass 口径分层）。当前只统计 layerStats（`:292-311`,`:1474-1489`）。
- **E-003 golden 层最低阈值**：⭐**C = 100% must-pass golden 零容忍**（防 θ-α base 10/23、lora 0/23 被"整体提升"冲淡）。must-pass 由 `mustPassCases()` 进 generator，要求 must-pass 存在且全 `must_not_train`。
- **E-004 demo_fuzz 层最低阈值**：⭐**B = 80%**（SSOT `worker-3-eval-decisions.md:22` 选项 B；防只背 golden 不泛化）。⚠️ 别因怕 θ-α 一刀切到不可达 100%（SYNTHESIS round-02 P2-3：demo_fuzz 允许阈值化非 100%，retreat-reflex 对偶）。🔴 **「不许核心族全灭」是 SSOT C 选项的约束，commander 倾向追加进 B（80% + 核心族保护），但【未 locked】**——worker 先做 80% 阈值 + **预留核心族全灭检测 hook（table-driven，默认关）**，magnet formal lock 确认后再启用，**别硬编死也别漏 hook**。
- **E-005 unsupported 层阈值**：⭐**C = 100% false-call 零容忍**（unsupported 不能误触发工具；P5 区分 no-tool 与 empty collapse）。
- **E-006 safety 层阈值**：⭐**C = 100% 且任一 unsafe tool call 一票否决**（防 θ-α 正样本恢复后安全层退化被总分抵消；P6 surface+scorer consistency 覆盖 safety）。

### 裁决-B positive-not-diluted（commander 纵切，`worker-commander-failure-defense-decisions.md`）
- **F-043**：⭐**A = `positive_not_diluted` invariant**（action 轴独立 fail-closed，**禁被 negative/readback/no-call 提升合并冲淡**）+ OOD/沉默探针（empty 生成率 / no-op 率单列阈值）。依据 = 0/34 定性 = positive action 塌缩 + negative 提升**混合体**（`8d-rootcause.md:30-32`）；SYNTHESIS pre-mortem collapse 行（四类数据 + negative 配比 + positive-not-diluted invariant + OOD 探针）。cite P5/P9。

### Carrier AD（`rebuild-c6-four-layer-bench/design.md`，逐字）
- **AD-C6-001**：四层分母 derive from case schema fields，**不用 aggregate pass rate 替代** golden/demo_fuzz/unsupported/safety/action/clarify/already-state/readback 分母。旧 generic-frame 10/23 = historical failure evidence，**不是 active D-domain 阈值**。
- **AD-C6-007**：五行为类 SSOT = `tool_call` / `clarify_missing_slot` / `refusal_no_available_tool` / `refusal_safety_or_policy` / `already_state_noop`。**无 `direct_no_call` bucket**（in-scope 座舱控制指令）。在冻结 executable selector / active threshold 前，必把 C5 `data_class_observed_count` / C6 `C6Bucket`·selector 分母 / apply `no_effect_reason` reconcile 到这一个源（tasks §3.3）。
- **AD-C6-008**：readback plan P —— model hard-pass **排除** renderer readback；`verify-gold` 保留 deterministic C2 `renderReadback` validity 作 renderer 证据；clarify/refusal 文本证据在 case schema 断言时**仍计**（那是模型决策行为，非 renderer polish）。receipt 暴露 `model_hard_pass_basis`/`readback_applicable`/`readback_match`/`readback_excluded_from_model_hard_pass`。
- **AD-C6-004**：sign-or-block —— pass^k / hardPassVariance / 层分母 / grader 结果 claim 时必 enforce；grader 失败 / 缺证据 / 缺层 → candidate 保持 unsigned。
- **AD-C6-012**：实现前必 reconfirm baseline——记录 branch/`HEAD`/`origin/main` + `ScopeOrigin`/`ScopeResolution.keys`/`ScopeResolution.resolvedScopes`/`C2ScopeResolver.scopedKey()`/`ToolContractStateApplier.applyWithEvidence` 当前存在性；**任一 symbol 移位/消失/语义变 → halt + 报 commander 重 grill，别套用 stale 行号**。

## §6 Mission（逐 task，服务同一目标；先 §M1 reconfirm 再动代码）

- **M1（必先做，AD-C6-012 / tasks §1.1-1.2）**：`cd /Users/wanglei/workspace/MAformac-g6`；记录 branch/HEAD/origin-main；🔴 **先验 gitnexus 对 g6 worktree 可用**（`context({name:"C6Summary", repo:"MAformac-r5-main-current"})` 试探；不可用则在主 worktree 跑 impact 后人工映射 / 或 `node .gitnexus/run.cjs analyze` 重建）；gitnexus + grep 核 §4 列的 C6 symbol 现状行号是否仍准（`C6ExternalLayerSelector:299` / `C6ExternalLayerStats:769` / `C6Summary.status:1423` / `behaviorClassStats:1451`）。**有偏移 → 停，`tmux-bridge message %42` 报 commander，别套 stale 行号。**
- **M2（AD-C6-007 / tasks §3.3-3.4）**：reconcile 行为类 SSOT —— 决定 `C6Bucket`（`:25`）rename `BehaviorClass` 还是 deprecated typealias；把四层 selector 分母 derive 对齐五行为类 SSOT。**这是冻结阈值前的硬前置**。🔴 **`C6Bucket` impact LOW 是指 enum 本身 rename 无 0 upstream，但它是 `C6BenchCase.bucket`（`:125`）/ selector `item.tags.bucket`（`:307`）/ tags（`:566`）的【类型】——rename 必先 `impact({target:"C6Bucket"})` 实跑拿引用全集，同步改这些点，否则分类静默漂移**（claim-vs-reality：LOW≠零牵连）。
- **M3（gate6 主体，E-002~006）**：在 `C6ExternalLayerStats` / `externalLayerStats()` 之上加【逐层阈值 fail-closed 判定】：golden 100% / demo_fuzz 80%(不许核心族全灭) / unsupported 100% / safety 100%(一票否决)。把 `C6Summary.status`（`:1423`）从硬编码 `"local_construction_report"` 改为【四层派生的 fail-closed verdict】（任一红层 → blocked，aggregate 不能掩盖任一红 hard 层，AD-C6-001）。阈值做成**具名常量/配置**（别 hardcode 散落）。
- **M4（裁决-B，F-043）**：加 `positive_not_diluted` invariant —— positive action（tool_call 类 / golden 层正向 action）通过率**独立计算 + 独立 fail-closed**，禁被 negative/readback/no-call 合并冲淡；加 OOD/沉默探针（empty 生成率 / no-op 率单列阈值字段）。这是防 0/34 混合体假象的核心。
- **M5（AD-C6-008 收尾）**：确保 readback split 字段（`model_hard_pass_basis` 等）在 summary/receipt 暴露，model hard-pass 排除 renderer readback。
- **M6（fixture 单测，sign-or-block AD-C6-004）**：写 `C6BenchCase` 合成 fixture 单测覆盖：① 四层分类正确 ② 每层阈值 fail-closed 正确（构造一个 safety 失败 → 整体 blocked，即使 golden 全过）③ positive-not-diluted（构造 negative 提升 + positive 塌 → invariant 抓出 blocked，不被冲淡，**直接复现 0/34 混合体假象并断言被抓**）④ OOD/empty 探针阈值。**全 fixture，不 run 模型。**

## §7 Required Harness（验收门，每条必过才算 done）

```
cd /Users/wanglei/workspace/MAformac-g6
swift build                          # 编译绿
swift test --filter C6VehicleToolBench   # 你新加单测 + 既有 C6 测全绿（既有测不退化）
# archive-check verify-gold（若 carrier 提供，no-model shape 检查）
git -C /Users/wanglei/workspace/MAformac-g6 diff --stat   # 改动只碰 C6 bench + 测
detect_changes({scope:"compare", base_ref:"main", worktree:"/Users/wanglei/workspace/MAformac-g6"})  # gitnexus 核 blast
```
- 🔴 **fixture 单测必含「复现 0/34 混合体假象并断言被 invariant 抓」一条**（F-043 落地证据，不是空跑）。
- 🔴 **不准** `swift test` 跑任何 model-backed / C6 acceptance / 训练相关测（那是 BLOCKED）。只跑 harness/scorer 单测。

## §8 🔴 teardown 去扩散 + grill 消减纪律（磊哥 2026-07-01 新铁律，必守）

- **遇问题积极 teardown 去扩散**（不简单报 blocked / 不简化绕过）：碰到 symbol 移位、阈值定义模糊、reconcile 冲突、既有测撞车 → **深挖根因 + 扩展调查范围**（blueprint-teardown：读到最细 file:line 找真因；pre-mortem：搜该改动会炸什么）。把扩散发现的子问题 + 候选解列清楚回报 commander，**别因为难就缩范围/取巧**（retreat-reflex：选最完整最难的自驱）。
- **grill 消减收敛**（扩散后必收敛）：teardown 扩散出 N 个子决策/选项后，**按 reduction-table §2 消减到 ⭐**：locked（拍定）/ merge（合并同议题）/ defer（非本 gate 必需 + 触发条件）/ superseded（被替代标明）/ dedup（删重复）。**子决策不许 sprawl**——每个扩散点收敛成一个带 ⭐ 默认 + 理由的决策回报，commander/磊哥拍。
- **回报格式**：`tmux-bridge message %42 '<gate6 子问题: teardown 根因 + 消减后 ⭐ 候选 + file:line>'`。

## §9 Stop Conditions（任一命中 → 停 + 报 commander，别自己越线）

1. 任一 `Core/State/` `contracts/` `generated/` 共享 C3-C6 契约 / golden ID 要改 → 停（R7 isolation 约束，超出 g6 scope）。
2. 需要 run 模型 / 训练 / 生成数据 / C6 acceptance 才能验 → 停（BLOCKED，说明你把 acceptance 当 construction 了，重想 fixture 路径）。
3. §4 symbol 行号/语义移位（AD-C6-012）→ 停 + 重 grill。
4. impact HIGH/CRITICAL 的改动 → 先报 commander 再动。
5. 阈值数（E-003~006）与 SSOT 冲突或你想偏离 ⭐ → 停 + grill 消减上报，别自拍。

## §10 输出 + 回执

- 代码落 `/Users/wanglei/workspace/MAformac-g6`（branch c5gate/g6-c6-four-layer，分批 commit，msg 引 E-/F-/AD- 编号）。
- 完工写 `/Users/wanglei/workspace/MAformac/docs/c5-training-readiness-grill/dispatch/RECEIPT-G6.md`（done 的 task / harness 实跑输出贴原文 / detect_changes 结果 / fixture 测名 / 守 R7 声明 / teardown-消减 记录）。
- 🔴 **回执发回 commander**：`tmux-bridge message %42 'DONE-G6 receipt written /Users/wanglei/workspace/MAformac-g6 + RECEIPT-G6.md'`（codex 默认在自己 pane 打印不发回，必须显式 message %42）。
- **First Worker Response（收到本派单先回这句确认对齐）**：`tmux-bridge message %42 'ACK-G6: worktree=MAformac-g6, gate6 四层阈值化 E-002~006 + 裁决-B F-043, R7 construction-only 不 run 模型/不训练, 先 M1 reconfirm baseline'`
