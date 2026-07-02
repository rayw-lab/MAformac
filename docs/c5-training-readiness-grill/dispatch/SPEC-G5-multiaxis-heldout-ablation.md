---
authority: commander_dispatch_d22
artifact_kind: c5_gate_construction_dispatch
dispatch_id: SPEC-G5
gate: gate5 六轴 held-out splitter + 裁决-A G6-C/D-fix tiny-ablation harness
worker: W2 codex %45
worktree: /Users/wanglei/workspace/MAformac-g5 (branch c5gate/g5-multiaxis-heldout, base origin/main 771f48ad = 当前 origin/main HEAD，已核)
r7_boundary: tooling-construction-only — 不 run 训练 / 不生成数据 / 不真跑 ablation（只 build splitter+harness + fixture/dry-run 单测）
decision_status: ⭐-default pending 磊哥 formal lock（见 §0.5）
created: 2026-07-01
status: pending_cc_audit_round2
---

# SPEC-G5 — gate5 六轴 held-out splitter + 裁决-A（tiny-ablation harness）

## §0 Commander Preamble（你是谁 / 一句话使命 / 防什么）

你是 **W2（codex `%45`）**，本派单 commander = MAformac 线 claude-commander。
**一句话使命**：① 把 C5 数据 gate 的 held-out overlap 检查从【parent_semantic 单轴】升级为【六轴硬切 + fail-closed】；② build【裁决-A tiny-overfit ablation harness】（rig + 验收判据常量 + dry-run），**不真跑训练**。**全 tooling construction（splitter 代码 + harness 骨架 + fixture/dry-run 单测），绝不 run 训练 / 生成数据 / 真跑 ablation。**

🔴 **你在防两次双仓惨败重演**：
- **惨败1（C5 PR5 `0/34`）**：根因之一 = 训练/eval surface 不同源 + held-out 泄漏致死记。审计只看 receipt 没下钻一手（`docs/c5-recovery-2026-06-22/8d-rootcause.md:103-104`）。
- **惨败2（θ-α）**：generated-positive 全 checkpoint 塌，但**没先做判别实验就训了 2h28m 白跑**——裁决-A 正是堵这个：**正式训练前必过 tiny-ablation 先证"数据契约修复是主因"，未过不得声称范式修复成功**。

## §0.5 🔴 决策状态：⭐-default pending 磊哥 formal lock（必读，防计划态当执行态）

本派单引的 D-016 / F-044 当前 grill `status: proposed`（SYNTHESIS `grill_complete_pending_human_signoff`；`reduction-table.md:60` locked=0 待磊哥 §2 人审拍板）。commander 按磊哥 standing 指令「有推荐选项默认你的推荐」treat ⭐ 为 **working-default** 推进 construction。**硬要求**：worker 把【六轴轴集合 / ablation 阈值常量 / failure reason 枚举】做成 **table-driven / 具名配置常量**（集中一处，非散落硬编码），便于磊哥 formal lock 版若调整 → 零返工。magnet formal lock 后 commander 回写 landing-matrix locked。

## §1 Authority & R7 边界（🔴 retrain-c5 邻接，比 gate6 更紧，逐项对齐 R7 blocks）

🔴 **本 gate5 + 裁决-A 是 retrain-c5 邻接工作**（C5DataGate = 训练数据 gate 工具；tiny-ablation 需训练才能 run）。R7（`docs/project/phase0/r-l17-human-review-evidence/R7-final-route-deframing-signoff.md`）`route_deframing_blocks` 明列 `retrain_c5`。所以 scope **严格收窄到【建工具/harness + fixture/dry-run 单测】，绝不触及 run**：

**你做（construction / tooling）**：
- 写六轴 held-out splitter 逻辑（`C5DataGateValidator` 扩展）+ **fixture 单测**（合成 `C5DataGateCandidate` 喂进，断言六轴 overlap 抓得对）。
- build tiny-ablation **harness 骨架**（rig 接口 + 验收判据常量 + dry-run 单测），**不接真训练后端、不真跑**。

🔴 **你绝不做（= R7 `route_deframing_blocks` 全 9 项，逐项对齐 `R7-final-route-deframing-signoff.md:20-29`）**：
1. `retrain_c5` —— 不 run 训练（mlx-lm / 任何训练命令）、不生成训练数据、不调云 generator、**不真跑 ablation**（20-50 样本 overfit 也是训练 = BLOCKED）。
2. `rebuild_c6_acceptance` —— 不 run C6 acceptance。
3. `d_domain_base_recalibration` —— 不 base recalibration。
4. `candidate_comparison` —— 不 base-vs-candidate 对比。
5. `demo_golden_run` / 6. `voice` / 7. `endpoint_readiness`（**不声称"数据 gate 就绪可进训练/端点就绪"**）/ 8. `uiue_merge_to_mainline` / 9. `v_pass_s_pass_u_pass`。

**fixture/dry-run 单测用合成 `C5DataGateCandidate`，绝不用真语料、绝不生成。** 允许验证 = `swift build` + `swift test`（你的新单测）。

## §2 Worktree & 路径

- 🔴 **代码工作区** = `/Users/wanglei/workspace/MAformac-g5`（**第一步 `cd` 进去**；branch `c5gate/g5-multiaxis-heldout`，base origin/main 771f48ad）。
- **派单 + grill SSOT（只读，绝对路径主 worktree）** = `/Users/wanglei/workspace/MAformac/docs/c5-training-readiness-grill/`（本派单 + `landing-matrix.md` + `worker-1-data-decisions.md`[D-] + `worker-commander-failure-defense-decisions.md`[F-] + `SYNTHESIS.md`）+ `/Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/8d-rootcause.md`。g5 worktree 没 grill dir，绝对路径读主 worktree。
- ⚠️ **不 commit 到 main**，只在 `c5gate/g5-multiaxis-heldout` 分支。

## §3 Required Tool Contract（🔴 gitnexus 强制，且本 gate blast radius = HIGH）

🔴 **commander 已先跑 gitnexus impact（你必自己再核 + 改前必跑）**：
- `impact({target:"C5DataGateValidator", direction:"upstream", repo:"MAformac-r5-main-current"})` = **risk HIGH，14 upstream**。
- 🔴 **直接调 `C5DataGateValidator()` 的只有 2 处（direct，commander grep 亲核）**：
  - `Tools/C5DataGateCLI/main.swift:35`
  - `Core/Training/C5LoRATraining.swift:2220`（在 `struct C5TrainingDatasetBuilder`@`:2205` 的 `build` 里；🔴 `C5LoRATraining` 是**文件名不是 symbol**，gitnexus 查 symbol 用 `C5TrainingDatasetBuilder`）。
- **间接 caller（经 `C5TrainingDatasetBuilder.build`）**：`Tools/C5TrainingCLI/main.swift:main`（它只引 `C5DataGateRunContext:59`，不直接引 validator）。
- **既有单测**：`Tests/MAformacCoreTests/C5DataGateTests.swift` = **8 个 `func test` 方法**（不是 9；gitnexus 的"9 hits"是 relationship 计数非测试数）。
- 🔴 **含义**：改 `C5DataGateValidator.receipt(...)` 签名 / `C5DataGateReceipt` 旧字段会**直接破 2 处 + 间接波及 C5TrainingCLI + 8 测**。**向后兼容硬要求**：加新字段而非改旧；既有 8 测必不退化。
- **改任何 symbol 前** `impact` upstream；**找流** `query`；**commit 前** `detect_changes({scope:"compare", base_ref:"main", worktree:"/Users/wanglei/workspace/MAformac-g5"})`。repo 索引名 `MAformac-r5-main-current`。

## §4 Live Truth — C5DataGate 当前代码现状（commander gitnexus + 逐行亲核，e894eb71==origin/main 同行号）

文件 `Core/Bench/C5DataGate.swift`（554 行）：
- `C5DataGateValidator`（`:251`）+ `static let splitWhitelist`（`:252`）= `["train","heldout","must_pass","c6_base","dev_selection","quarantine"]` —— **split 桶已有**。
- `C5DataGateCandidate`（`:3`）= 候选结构（六轴新字段需核哪些已在、哪些要 optional 加）。
- overlap 检查（`:262-267`）= `nonTrainParents`（非 train split 的 `overlapParentSemanticID`）∩ `trainOverlapParents`（train split 的 parent）—— 🔴 **只 parent_semantic 单轴**。
- per-item 判定（`:282-284`）= train 里 parent 撞 nonTrain → `train_parent_semantic_overlap` P1 —— 🔴 **只 parent，无 device/tool/value/template/source 轴**。
- `:285-287` train 缺 parent → `missing_candidate_parent_semantic_id_for_train` P1。
- `:319-321` `hardTrainOverlap` = train 里 parent 撞 trainOverlapParents 计数 → `:324` 进 `status = "blocked"`。
- 🔴 `C5DataGateReceipt.hasHardFailure`（`:199-204`）= 只看 `mustNotTrainViolations / trainParentSemanticOverlap / toolCallFormatFailures / redactionStatus`；`status="blocked"` 判定（`:323-324`）同源。**新五轴 overlap 必须接进这两处才 fail-closed**（见 M2）。

🔴 **gate5 缺口 = 在【现有 parent_semantic 单轴 overlap】之上，加另外五轴硬切 + 接进 fail-closed**。不是只加计数字段（那是 derivation-layer 铁律1「default 吞错」= 惨败1「removed_X=true 却没真删」同构）。

## §5 Inlined Grill 决策（SSOT 逐字；⭐-default pending lock 见 §0.5）

### gate5 六轴 held-out（W1 数据官 grill，`worker-1-data-decisions.md:31`）
- **D-016 held-out 轴集合**：⭐**A = `parent_semantic_id` + `device` + `tool_name` + `value_type` + `template_family` + `generator_source`** 六轴（B 只 parent / C 随机 split 均否）。依据：当前 gate split whitelist 只有 split 桶、parent 级 overlap，无六轴（`Core/Bench/C5DataGate.swift:252`,`:282`）。防 C6/heldout 泄漏和死记；cite **P7 实跑复算、P8 同源但隔离**（`docs/c5-recovery-2026-06-22/8d-rootcause.md:103`,`:104`）。

### 裁决-A tiny-ablation 裁决门（commander 纵切，`worker-commander-failure-defense-decisions.md:62`）
- **F-044**：⭐**A = 正式训练前必过 D-fix tiny-overfit ablation**（20-50 样本，验 `empty 28/34 → <5/34`）裁决「数据契约修复是否主因」+ **stepwise ablation 裁决范式独立贡献**，**未过不得声称范式修复成功**。依据 = 8d D6 硬门3「先 D-fix tiny-overfit ablation 先证数据契约是主因再谈范式」（`docs/c5-recovery-2026-06-22/8d-rootcause.md:112-114`）；verdict 五（`SYNTHESIS.md:58`）。cite 惨败1（凭"路径改对"当成功未证）+ 惨败2（θ-α confounded 没先判别实验就训 2h28m 白跑）。

🔴 **裁决-A 在本 gate 的形态 = 建 harness 不 run**：
- build ablation rig 接口（**接收外部传入的 mock/真实指标**，与判据比较）+ 验收判据**占位常量**。
- 🔴🔴 **`28/34`、`<5/34` 是【写死的历史 baseline 占位常量 + 目标阈值】，不是 harness 要算出来的输出**。harness 只把【外部传入的 empty 率指标】与这俩常量比较。**worker 绝不实测、不校准、不验证这两个数字的真实性**（真实测 = D-fix 前 base 模型 tiny 集实跑 = 训练 = BLOCKED，留 candidate signoff + run auth 后）。
- **stepwise ablation = 只 build【轴定义 + 接口占位】**，实际 stepwise 多次对比执行属真跑、留 run auth 后。

## §6 Mission（先 §M1 reconfirm + impact 再动代码）

- **M1（必先做）**：`cd /Users/wanglei/workspace/MAformac-g5`；记录 branch/HEAD/origin-main；🔴 **先验 gitnexus 对 g5 worktree 可用**（`context({name:"C5DataGateValidator", repo:"MAformac-r5-main-current"})` 试探；不可用则在主 worktree 跑 impact 再人工映射 / 或 `node .gitnexus/run.cjs analyze` 重建）；`impact({target:"C5DataGateValidator", direction:"upstream"})` 自核 blast；核 §4 行号（`splitWhitelist:252` / overlap `:262-267`,`:282-284` / `hasHardFailure:199` / `status blocked:324`）+ `C5DataGateCandidate:3` 字段。**行号/字段移位 → 停报 commander。**
- **M2（gate5 六轴 splitter，D-016）**：扩展 overlap 到六轴。`C5DataGateCandidate` 缺的轴字段（device/tool_name/value_type/template_family/generator_source）**向后兼容**加（optional 新字段，别破现解析）；轴集合做成 **table-driven 具名常量**（§0.5）。每轴 train∩非train overlap 检查 → 新 failure reason（`train_device_overlap`/`train_tool_overlap`/...，枚举集中）。🔴 **新五轴 overlap 命中必接进 `hasHardFailure`（`:199`）+ `status="blocked"`（`:324`）**（与 parent 轴同级 hard fail，否则 fail-closed 失守）。`C5DataGateReceipt` **加新字段**记六轴 overlap 计数，**不改旧字段**（保 2 direct caller + 8 测兼容；旧 receipt 反序列化时新字段默认值不能误触发 block）。
- **M3（裁决-A harness，F-044）**：新建 ablation harness 文件（如 `Core/Training/C5TinyAblationHarness.swift`）：rig 接口（输入 20-50 fixture 样本 + **接收外部 mock 指标的协议**）+ 验收判据**占位常量**（`emptyBaselinePlaceholder = 28/34` / `emptyTargetThreshold = <5/34` + stepwise 轴定义占位）+ **明确标 `// R7: harness only, real run BLOCKED until candidate signoff + run auth`**。🔴 **harness 不 import / 不调用任何 mlx-lm / 训练后端 symbol**（纯接口 + 常量 + mock，物理保证 build≠run）。
- **M4（fixture/dry-run 单测）**：① 六轴 splitter：构造每轴泄漏的合成 candidate → 断言对应 failure 抓出 + 🔴 **断言「parent 不撞但 device 撞 → `status="blocked"`」**（新轴真 fail-closed）+「干净数据全过」+「旧 receipt 兼容（新字段默认不误 block）」。② ablation harness：mock 指标 dry-run 走通 + 验收判据常量正确（喂 mock empty 率与 28/34→<5/34 比较的逻辑对）。**全 fixture/mock，不 run 训练。**

## §7 Required Harness（验收门）

```
cd /Users/wanglei/workspace/MAformac-g5
swift build                              # 编译绿
swift test --filter C5DataGate           # 你的六轴新测 + 既有 8 测全绿（向后兼容不退化）
swift test --filter TinyAblation         # ablation harness dry-run 单测绿（若按此命名）
git -C /Users/wanglei/workspace/MAformac-g5 diff --stat   # 改动只碰 C5DataGate + ablation harness + 测
detect_changes({scope:"compare", base_ref:"main", worktree:"/Users/wanglei/workspace/MAformac-g5"})
```
- 🔴 **既有 8 个 C5DataGate 测必全绿**（HIGH blast，向后兼容硬要求）。
- 🔴 **不准** run 任何训练/数据生成/真 ablation。只 fixture/dry-run 单测。

## §8 🔴 teardown 去扩散 + grill 消减纪律（磊哥 2026-07-01 新铁律）

- **遇问题积极 teardown 去扩散**（不简单报 blocked / 不简化绕过）：碰到 candidate 缺轴字段、六轴语义边界（generator_source 怎么定义）、HIGH blast 破 caller、ablation 指标接口怎么抽象 → **深挖根因 + 扩展调查**（blueprint-teardown 读到最细 file:line；pre-mortem 搜会炸什么）。列子问题 + 候选回报，**别因难缩范围/取巧硬编码**（retreat-reflex：选最完整最难自驱）。
- **grill 消减收敛**（扩散后必收敛）：扩散出 N 子决策 → 按 `reduction-table.md §2` 消减到 ⭐：**locked**（拍定）/**merge**（合并同议题）/**defer**（非本 gate 必需 + 触发条件）/**superseded**（被替代标明）/**dedup**（删重复）。每点收敛成一个带 ⭐ 默认 + 理由的决策回报，**子决策不 sprawl**。
- **回报**：`tmux-bridge message %42 '<gate5 子问题: teardown 根因 + 消减 ⭐ 候选 + file:line>'`。

## §9 Stop Conditions（任一命中 → 停 + 报 commander）

1. 要 run 训练 / 生成数据 / 真跑 ablation 才能验 → 停（BLOCKED，重想 fixture/dry-run 路径）。
2. 改动要破 `C5DataGateValidator.receipt(...)` 现签名 / 现 `C5DataGateReceipt` 旧字段 → 停（HIGH blast 破 2 direct caller + 8 测，先报 commander 议向后兼容方案）。
3. §4 行号/字段移位 → 停 + 重 grill。
4. 六轴某轴定义模糊（如 generator_source 在 candidate 无来源）→ 停 + grill 消减上报，别自拍语义。
5. 要碰 `Core/State/` `contracts/` `generated/` 共享契约 → 停（超 scope）。

## §10 输出 + 回执

- 代码落 `/Users/wanglei/workspace/MAformac-g5`（分批 commit，msg 引 D-016/F-044）。
- 完工写 `/Users/wanglei/workspace/MAformac/docs/c5-training-readiness-grill/dispatch/RECEIPT-G5.md`（done task / harness 实跑输出原文 / impact+detect_changes 结果 / 既有 8 测绿证据 / 守 R7 声明 / teardown-消减 记录）。
- 🔴 **回执发回 commander**：`tmux-bridge message %42 'DONE-G5 receipt written /Users/wanglei/workspace/MAformac-g5 + RECEIPT-G5.md'`。
- **First Worker Response（收到先回确认对齐）**：`tmux-bridge message %42 'ACK-G5: worktree=MAformac-g5, gate5 六轴 held-out D-016 + 裁决-A F-044 harness-only, R7 不 run 训练/不生成数据/不真跑 ablation, 28/34 是占位常量不实测, 先 M1 reconfirm+impact'`
