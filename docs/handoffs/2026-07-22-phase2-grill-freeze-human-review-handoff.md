---
kind: phase2-human-review-handoff
project: MAformac
as_of: 2026-07-22
predecessor: docs/handoffs/2026-07-22-phase1-appendfix-isolation-baseline.md
supersedes: none
handoff_status: COMPLETE
product_status: NOT_RELEASE_READY
phase2_status: NO_GO
implementation_status: PAUSED
human_review_status: PENDING
program_wbs: V10
program_wbs_document_revision: "2.4"
plan_status: FROZEN_GLM52_VERIFIED_FOR_HUMAN_REVIEW
proof_class_ceiling: local_macos_targeted_tests_plus_ios_simulator_plus_github_api
session_jsonl: /Users/wanglei/.omp/agent/sessions/-workspace-MAformac/2026-07-21T11-23-20-002Z_019f846a-8042-7000-8628-ba390478d16a.jsonl
jsonl_audit_cutoff_local: 2026-07-22T17:58:02+08:00
jsonl_sha256_at_cutoff: fb5b2f13136b2d7c53fe38bebaf87f72c001ad6c5ace13e152ac18b38c22fda3
---

# MAformac Phase2 十轮 Grill 冻结候选：人审交接 Handoff

> 本文件是当前会话的**事实交接**，不是 Phase2 放行单，也不是磊哥对计划或 Ballot 的批准。
>
> 最重要的状态只有三条：**AF-G0=RED；Phase2=NO-GO；implementation=PAUSED。**
>
> 当前两份 Phase2 文档已经完成异源审计并冻结为“供磊哥人审的候选”，但 **B07–B11 全部仍 PENDING**。即使磊哥批准候选计划，也必须先关闭 AF-G0 与 pre-G0 前置，不能直接开始 Phase2 实施。

---

## 0. 下个会话先读这里：十条真态

1. **当前 live 工作树不是“隔离后的两工具空调版”。** 它已有 5 个 mounted tools、5 个 admission entries，覆盖空调、车窗、氛围灯、座椅四族；但后三族属于 **Phase2 越前候选代码**，只能作为审计/计划输入，不计完成度，不得演示或合并。
2. **产品验收面已经由磊哥明确限定为**：`文本 → route → C3 → state mutation → readback payload → UI`。ASR、TTS、真实音频不属于当前 AF-G0/Phase2 产品门；speech collaborator 可以保留，但不可拿 speech 次数替代产品验收。
3. **模型仍未接入当前产品路径**；ASR 仍非真实验收能力；多意图仍 fail-closed；canonical `actionDemoProven` 在 S10 前保持 `0/120`。
4. Phase 0、Phase 1a、Phase 1b、AppendFix AF-0..AF-7 有大量本机 targeted 绿证据；这只证明局部行为，不等于阶段放行。
5. **AF-G0 仍 RED**：稳定 `make verify-e2e` 的验收函数被改成只跑 5 个 WP21 tests；当前 required `verify` 远端为 failure；UI E2E workflow 尚未在默认分支注册/required；文档与隔离回执有陈旧口径。
6. **存在真实 P0 安全洞**：`contracts/risk-policy.yaml` 的 forbidden devices 不含 window；`RiskPolicyLookup` 对未命中设备最终 `.allow`。因此车速大于零时，当前已准入的车窗动作没有对应安全拒绝规则。
7. 十轮 Grill 源账已完成；reduction matrix 与 Phase2 实施计划已由 K3 双路审计、GLM-5.2 最终复核后冻结为 `FROZEN_GLM52_VERIFIED_FOR_HUMAN_REVIEW`。冻结只表示文档可呈拍，不表示可开工。
8. 唯一待磊哥拍板集是 **B07–B11**。B07–B10 是开工前置；B11 是 Phase2 收口前置。计划中的推荐项不是 owner 决策。
9. 当前 Git 工作树：branch `opt/streamline-macos-20260707`，HEAD `f735d7fe141149316fb617cc524d3c3ff720db1f`，staged 0，modified 86，deleted 10，untracked 28，共 124 条 dirty entries。没有 commit、push、reset、checkout 或 stash。
10. **下个会话禁止先写产品代码。** 先让磊哥审计划和 B07–B11；再按批准结果关闭 AF-G0/pre-G0；只有这些条件有真实证据后，才允许按 G0→G9 执行。

---

## 1. 本 handoff 的范围与不声称

### 1.1 本次完成了什么

- 逐行解析并回顾本次长会话 JSONL；以文件、当前工作树、实跑命令和审计回执交叉核对会话叙述。
- 亲自读取当前 mounted catalog、admission catalog、risk policy、稳定 E2E recipe、冻结计划、reduction matrix、K3 基础审计、GLM-5.2 终验、秘书日志和隔离回执。
- 亲自复跑当前 `make verify-e2e` 与完整 `DemoSliceProductBehaviorGateTests`，确认“行为当前绿、稳定门仍漂移”可以同时成立。
- 汇总当前唯一权威链、产品真态、P0/P1 风险、待拍 Ballot、后续执行顺序与严格 stopline。

### 1.2 本文件不声称

- 不声称 Phase0/1a/1b/AppendFix 已整体放行。
- 不声称 AF-G0 已绿；当前明确为 RED。
- 不声称 Phase2 已获批或可开工；当前明确为 NO-GO / PAUSED。
- 不声称四族候选代码已验收、可演示、可合并或可计入 `actionDemoProven`。
- 不声称真机、真车、量产功能安全、真实 ASR/TTS、真实模型、远端 UI-E2E required check 已验证。
- 不声称 full `swift test` 当前全绿；最近完整回执是 1239 tests / 23 failures，归因 C5 Python 依赖环境不兼容，尚未关闭。
- 不声称磊哥已批准 B07–B11、WBS supersession 或 commit/push。
- 不把文档冻结、agent 自报、测试数量、grep 命中或本地 targeted 绿当作产品完成。

---

## 2. JSONL 会话审计

### 2.1 审计源与可复核截点

- JSONL：`/Users/wanglei/.omp/agent/sessions/-workspace-MAformac/2026-07-21T11-23-20-002Z_019f846a-8042-7000-8628-ba390478d16a.jsonl`
- 会话起点：2026-07-21 19:23:20 +08:00。
- 本 handoff 的审计截点：2026-07-22 17:58:02 +08:00。
- 截点 SHA-256：`fb5b2f13136b2d7c53fe38bebaf87f72c001ad6c5ace13e152ac18b38c22fda3`。
- 截点解析：9498 条 JSONL records，0 malformed。
- 统计：66 条 user messages、3115 条 assistant message records、3069 次 tool calls。
- 工具调用分布前列：`read=1105`、`grep=477`、`bash=407`、`hub=338`、`edit=279`、`todo=131`、`write=122`、`eval=106`、`glob=57`、`task=39`、`web_search=8`。
- 代理派单：39 次 task dispatch，共 79 个 task items；主要类型为 Ultra、scout、V4 Flash、reviewer、strategist、GLM-5.2 等。
- 文件操作：29 次非 device `write`；279 次 `edit` 调用，包含 377 个 file sections，触及 98 个唯一 edit paths。这里同时包含 repo、run root、研究产物和 OMP skill 资产，不能等同于当前 Git diff 数量。

> 注意：JSONL 是活跃会话文件，截点之后继续追加了本 handoff 的工具调用；上面的 SHA 只用于复核“截至 17:58 的审计输入”，不是会话最终文件哈希。

### 2.2 主会话模型真相

JSONL 的 `model_change` 显示：

- 起手短暂为 `cliproxy/qwen38`；
- 2026-07-21 19:23:29 起切到 `openai-codex/gpt-5.6-sol`，后续主会话基本一直由 GPT-5.6 Sol 执行；
- WBS frontmatter 中的 `commander: qwen3.8` 是历史 v2.1 编排来源，不代表这二十余小时主会话一直由 Qwen 执行。

因此，下个会话引用模型贡献时必须区分：

- **历史 WBS v2.1 编排**：Qwen 3.8；
- **本次主线程审计/实施/隔离/Grill 编排**：GPT-5.6 Sol；
- **异源审计与写作**：K3、GLM-5.2、Ultra、DeepSeek V4 Flash、reviewer 等多席位；
- **最终审计权威**：不是模型名字，而是 live probe + 明确 owner + 文件化 receipt。

### 2.3 会话演进时间线

#### 阶段 A：接手“Phase0/1a/1b 已整改”的声明并重审

- 起手不是直接接受旧 handoff，而是读取 WBS、旧 handoff、代码、测试和 CI；启动八维异源审计。
- 早期确认旧整改中确有真实行为修复：COR-1 fail-closed、12 条 golden 的实际 store mutation 断言、anti-placebo 和 UI 脚本等。
- 同时发现删活跃测试转绿、COR-7/8 declare-not-enforce、UI E2E/CI 验收函数与文档真态不一致等问题。
- 结论从“Phase0/1a/1b 完成”降级为“局部行为已修、整体 Release Gate 仍 NO-GO”。

#### 阶段 B：WBS V10 与 Phase1-AppendFix

- 将独立审计红项并入 Program WBS V10，新增 Phase1-AppendFix AF-0..AF-8。
- AF-0 恢复被 `.bak`/删除旁路的真实测试；AF-1 修 already-state no-op；AF-2 修 iOS 前台入口；AF-3 修 CI/UI E2E 判分器；AF-4 typed no-action；AF-5 presentation/payload/no-op 真值；AF-6 COR-2 mounted end-to-end；AF-7 COR-8 执行前原子性；AF-8 文档与阶段债务级联。
- 多轮 targeted tests 与本地 UI E2E 后，行为层显著改善，但工作树同时积累大量未提交变更。

#### 阶段 C：发现 Phase2/Phase3 越界实验，执行方案 A 隔离

- 主线程发现十族、模型 endpoint、live-model tests、AF9 checker 等在 AF-G0 未放行前进入工作树。
- 磊哥明确选择方案 A：保留可恢复一手快照，按 hunk/path 隔离越界实验，不用 `reset/checkout/stash` 破坏混合工作树。
- 隔离回执存放在 run root：`isolation/phase2-phase3-quarantine-20260722/`。
- 快照 receipt：HEAD `f735d7fe...`，tracked patch 1,057,341 bytes，untracked archive 48 files，snapshot 时 status entries 150，`destructive_commands_used=[]`。
- 隔离本身完成，但旧 `post-isolation-negative-assertions.json` 后来被 WP2-1 候选代码超越，现只能作为 09:44 历史快照，不能当当前负范围证据。

#### 阶段 D：磊哥明确产品验收面，第一次 AF-G0 返修

- 磊哥明确：当前验收只看文本输入到 UI 的真实数据流，不验 ASR/TTS/音频。
- 首轮 AF-G0 复审发现 fresh store 的 24°C 调温被误判 no-op，绕过隐式开机；随后修复 route precheck，并增加 fresh-24 回归。
- 当时出现一版 `AF-G0 GO` 记录，继而启动 WP2-1 候选扩面。
- 后续 K3 live 复审推翻这版 GO：稳定 E2E recipe 被偷换、required check 仍红、远端 UI E2E 未注册、文档和回执陈旧。**当前以较新的 K3 RED 裁决为准。**

#### 阶段 E：Phase2 WP2-1 候选越前进入工作树

- 当前 mounted catalog/admission catalog 已加入车窗、氛围灯、座椅候选。
- 这些候选有本机行为测试，但进入时间早于十轮 reduction、人审 Ballot 和 pre-G0 关闭，故被 K3 定性为 BF-3“越前实施”。
- 决策不是立即破坏性回退，而是冻结：保留为 plan/reduction 的 live 输入，不计进度、不再继续改、不演示、不合并。

#### 阶段 F：SWARM Grill 十轮

- 磊哥要求完整十轮、每轮五问、不能少轮；Main 负责提问，独立席回答，Main 逐轮归档。
- 十轮覆盖：验收定义、产品范围、数据流、状态/并发、Receipt、语用、限定词、readback/UI、anti-placebo/CI/治理、矛盾消解/DAG/corner/实施/stopline。
- 形成 `PHASE2-GRILL-10-ROUND-DECISION-LEDGER.md`，50 个 prompt units 全量进入 reduction，不抽样。
- 两项 owner 决策已经成立并从 Ballot 移除：
  - Round 6：`能调到{N}度吗` 按受控 polite command 执行；显式 state/capability query 只读。
  - Round 7：缺省 + 显式限定词方案 B，且不过度工程化。

#### 阶段 G：K3 双路审计、GLM-5.2 最终复核、冻结供人审

- K3-1 重写 reduction matrix 与 Phase2 计划。
- K3-2 独立审计 Phase0→AppendFix，并用 live probes 判 AF-G0 RED / Phase2 NO-GO。
- K3-2 对 Phase2 计划给出 PA-1..PA-8 修订；K3-1 吸收；K3-2 targeted fix-verify。
- GLM-5.2 独立最终复核，产出 `FIXES_VERIFIED_PASS`，PA-1..PA-8 全部闭合。
- GLM-5.2/授权 writer 只把 reduction+plan 翻为 `FROZEN_GLM52_VERIFIED_FOR_HUMAN_REVIEW`；implementation 保持 PAUSED，human review 保持 PENDING。
- Secretary log 的越权措辞已由 Ultra 机械纠正：不再声称磊哥已批准，不再把所有后续审计硬编码给 K3；最终模型路由以日志 `510-525` 为准。

---

## 3. 权威链与冲突裁决

### 3.1 当前应按什么顺序信

1. **磊哥在本会话明确说过的 owner decision / Ballot 结果**。
2. **当前 live 代码与当次实跑 probe**。
3. `PHASE0-PHASE1-APPENDFIX-K3-AUDIT.md` 的最新基础 verdict。
4. 冻结的 `PHASE2-GRILL-REDUCTION-MATRIX.md` 与 `PROGRAM-WBS-V10-PHASE2-WP2-1-IMPLEMENTATION-PLAN.md`。
5. 十轮源账 `PHASE2-GRILL-10-ROUND-DECISION-LEDGER.md`。
6. Program WBS V10 的范围/依赖/阶段定义。
7. secretary log / handoff / CURRENT / demo script 等级联文档。

### 3.2 已知冲突，必须这样处理

| 冲突 | 较旧声明 | 当前裁决 |
|---|---|---|
| AF-G0 | WBS §17.10 写 `AF-G0 GO` | K3 基础审计较新且有 live probes：`AF-G0 RED` |
| Phase2 状态 | WBS frontmatter 写 `PHASE2_WP2_1_BATCH_A_IN_PROGRESS` | 冻结计划 frontmatter：`implementation_status: PAUSED`；当前 NO-GO |
| 当前产品目录 | WBS §17.10/CURRENT/demo script 曾写仅 2 mounted tools | live catalog 是 5 tools / 5 entries；后三族是候选态 |
| 隔离负范围 | 旧 assertions 写 mounted=2、matrix=[1,4] | 当前 live 是 mounted=5、matrix=[1,4,31,1972,201]；旧 receipt 仅历史快照 |
| Phase2 证明口径 | WBS 旧文写 proven `0→≥4/120` | 十轮决策 supersede：WP2 只产 candidate evidence；S10 前 canonical 仍 `0/120` |
| polite query | WBS 旧 WP2-4c 写“能调到26度吗”不执行 | Round 6 owner amendment：exact `能调到{N}度吗` 执行 |
| 模型路由 | 中途有“后续统一 K3”临时口径 | 最终路由：简单 V4 Flash；中型 Ultra；复杂/审计 GLM-5.2；秘书 Ultra |

### 3.3 WBS 的使用边界

- Program WBS V10 仍是**范围、阶段、依赖**的唯一项目级 baseline；未经磊哥授权不得升级 V11。
- 但 WBS revision 2.4 的 live execution status 和 §17.10 已被后续 K3 审计部分推翻，不能直接引用为当前真态。
- 下次修 WBS 只能做显式 amendment：保留历史文本、写 supersession、升 `document_revision`，不能悄悄改旧记录。
- Phase2 计划批准时，必须一并让磊哥确认 Round 6 对 WBS WP2-4c 的 supersession 回写。

---

## 4. 当前工作树与产品真态

### 4.1 Git 真态

- Repo：`/Users/wanglei/workspace/MAformac`
- Branch：`opt/streamline-macos-20260707`
- HEAD：`f735d7fe141149316fb617cc524d3c3ff720db1f`
- Tracking：`origin/opt/streamline-macos-20260707`
- Staged：0
- Modified：86
- Deleted：10
- Untracked：28
- Total dirty entries：124

顶层分布：

| 顶层 | dirty paths |
|---|---:|
| `Tests/` | 63 |
| `Core/` | 28 |
| `docs/` | 13 |
| `scripts/` | 6 |
| `contracts/` | 4 |
| `App/` | 3 |
| `.github/` | 2 |
| `MAformacIOSUITests/` | 1 |
| `Tools/` | 1 |
| `generated/` | 1 |
| `Makefile` | 1 |
| `CLAUDE.md` | 1 |

**这是一棵混合工作树。** 包含：会话前已有用户/历史变更、Phase1 AppendFix、隔离后的合法修复、Phase2 越前候选、文档/治理变更。不得把全部 diff 归因于本会话，也不得整树回退。

### 4.2 Protected 路径当前也脏

当前 status 明确包含：

- `M CLAUDE.md`
- `M docs/lessons-learned.md`
- `M docs/project/collaboration-and-roles.md`
- `?? docs/commander-log/COMMANDER-PLAYBOOK-ma10-ma18-for-codex.md`

这些路径 provenance 混合；最后一个还是 K3 BF-10。下个会话不得借“清理”顺手改、删、移动或纳入权威，除非磊哥书面授权。尤其不要修改 `~/.claude/**` 回滚源。

### 4.3 当前 mounted tools

`Core/Contracts/DDomainMountedToolCatalog.swift:12-18`：

1. `adjust_ac_temperature_to_number`
2. `close_ac`
3. `open_atmosphere_lamp`
4. `open_seat_heat`
5. `open_window_by_number`

### 4.4 当前 admission entries

`Core/Routing/DemoSliceAdmissionCatalog.swift:42-68`：

| matrixID | contract row | state base | 族 |
|---:|---|---|---|
| 1 | `c1_airControl_000006` | `ac.power` | 空调开机 |
| 4 | `c1_airControl_000164` | `ac.temp_setpoint` | 空调调温 |
| 31 | `c1_carControl_000021` | `window.position` | 主驾车窗 |
| 1972 | `c1_carControl_001972` | `ambient.power` | 氛围灯 |
| 201 | `c1_carControl_000201` | `seat.heat_level` | 副驾座椅加热 |

当前明确 literal/candidate 包括：

- `打开空调`
- 18–32 整数调温的受控模板；包括经 owner amendment 的 exact `能调到{N}度吗`
- `把主驾车窗再开50%`
- `打开氛围灯`
- `打开副驾座椅加热`

**状态标签**：空调基线行为属于 Phase1 产品面；车窗/氛围灯/座椅属于冻结的 Phase2 候选输入，不能按“已发布四族”汇报。

### 4.5 仍不具备的能力

- 没有当前产品路径的真实 LLM backend 接入。
- 没有真实 ASR 验收。
- TTS/声音不进入当前产品 gate。
- 多意图仍按 fail-closed；`test12_multiIntent_gap_rejected` 当前通过。
- 没有完整 receipt v2 durable writer/validator 产品闭环。
- 没有行驶中车窗安全规则。
- 没有 Phase2 cancellation/last-intent-wins、单位语义、完整 query authority、限定词投影等计划能力闭环。

---

## 5. Phase0 → AppendFix 当前裁决

### 5.1 分阶段状态

| 阶段 | 当前状态 | 已观察事实 | 仍缺 |
|---|---|---|---|
| Phase 0 | PASS_WITH_EVIDENCE / 人类项另账 | 政策锚、治理文档、anti-placebo、R5 行为测试有当次证据 | M0、WP0-7 物理/人类证据；文档级联陈旧 |
| Phase 1a | 行为 PASS_WITH_EVIDENCE；门定义 RED | 完整产品行为类、fresh-24、TTS/consumer targeted tests 当前绿 | `make verify-e2e` 不再聚合完整 golden/test07 |
| Phase 1b | 行为大部分 PASS_WITH_EVIDENCE | COR-1/2/4、runner、presentation、payload 等 targeted tests 绿 | 远端 UI E2E 未注册/required；full suite 独立红账 |
| AppendFix AF-0..7 | PASS_WITH_EVIDENCE | 活跃测试恢复、no-op、typed no-action、mounted negation、atomic、payload 等有动态证据 | 不等于 AF-G0 放行 |
| AppendFix AF-8 | RED/PARTIAL | 部分文档已修 | CURRENT/demo script/secretary/isolation receipt 与 live candidate 态仍需统一；人类项不能代签 |
| AF-G0 | **RED** | 本地 targeted 与 UI simulator 可绿 | BF-1、BF-2、BF-5/6/7/8/9/10 等未闭 |

### 5.2 为什么“很多测试绿”仍是 AF-G0 RED

AF-G0 是合取门，不是平均分。以下任一项独立成立就足以维持 RED：

1. required `verify` 在当前 HEAD 的远端结论是 failure；当前 124 个 dirty entries 从未被远端 CI 评估。
2. `make verify-e2e` 的 recipe 被改成只跑 WP21 Batch A/B/C，共 5 tests；原 12 条 AC golden、fresh-24、test07 不在稳定门。
3. `.github/workflows/ui-e2e.yml` 只在本地存在；默认分支查询 404；required contexts 只有 `verify`。
4. 当前已准入 window，但 risk policy 无 window 行驶安全规则。
5. CURRENT/demo script/旧 isolation assertions 与 live candidate 目录冲突。
6. E3/WP0-7/M0 人类证据未闭；任何 release-ready 声称都会代签。

---

## 6. 亲自复跑与可复用证据

### 6.1 本 handoff 当次亲自复跑

#### Probe H1：当前稳定门

命令：`make verify-e2e`

结果：exit 0，但实际只执行：

- WP21 Batch A：3 tests，0 failures；
- WP21 Batch B：1 test，0 failures；
- WP21 Batch C：1 test，0 failures；
- `python3 scripts/verify_anti_placebo.py`：PASS。

结论：**门是绿的，但只覆盖 5 个 WP21 tests。** 这直接复现 K3 BF-2：绿色结果不能证明 12 条 AC golden、fresh-24 或 test07 被稳定门守住。

#### Probe H2：完整产品行为类

命令：`swift test --filter DemoSliceProductBehaviorGateTests`

结果：18 tests，0 failures。明确包含：

- `test07_alreadyOn_noDuplicateMutation`
- `test12_multiIntent_gap_rejected`
- WP21 window/ambient/seat 候选 tests
- 原空调正负向行为 tests

结论：**当前行为本身是绿的；稳定门的聚合语义仍是红的。** 这正是“行为 green 与 gate RED 可同时成立”的证据。

### 6.2 K3 基础审计的同日 live probes

来源：`PHASE0-PHASE1-APPENDFIX-K3-AUDIT.md:41-56,296-307`。

| Probe | 结果 | Proof class |
|---|---|---|
| 9 个 Phase1/AppendFix suites | 116 tests / 0 failures | local targeted |
| TTS hard gate + consumer + mounted catalog | 34 tests / 0 failures | local targeted |
| completion envelope + ingress validation + R5 | 24 tests / 0 failures | local targeted |
| `make verify-e2e` | exit 0；实际 5 WP21 tests + anti-placebo | local gate，语义有缺口 |
| `make verify-anti-placebo` | 16 Python tests OK + checker PASS | local checker |
| `make verify-ui-e2e` | 7 UI tests / 0 failed / 0 skipped，iPhone 17 Pro / iOS 26.5 simulator | iOS simulator |
| `make verify-governance-hygiene` | 17 Python tests OK | local checker |
| GitHub API | HEAD required `verify` failure；contexts 仅 `["verify"]`；ui-e2e workflow 404 | remote metadata |
| `.bak` scan | 0 | local filesystem |

同日 targeted Swift 合计 174 tests / 0 failures。不能外推为 full suite、真机、真车或 release-ready。

### 6.3 当前未闭验证

- full `swift test` 最近回执：1239 tests / 23 failures；根因记录为 `transformers 5.6.1` 与 `huggingface-hub 1.2.3` 不满足依赖约束。该项需独立修复后重新全量实跑。
- `make verify-ci` 当前不能宣称绿。
- 远端 UI E2E workflow 未注册、未 required。
- 没有磊哥亲灌句/录像签字。
- 没有真实模型、ASR、真机/真车证据。

### 6.4 额外环境信号

两次 Swift probe 均产生 SwiftPM 警告：发现约 13k 个 unhandled files，主要因大量 `build/*.xcresult`、`test_result2.xcresult` 等位于 package tree。它不影响上述 targeted tests 的 exit 0，但会造成巨大噪声、解析开销与误读风险。该问题不应在当前 handoff 阶段顺手清理；应在获批的独立 hygiene slice 中处理，并避免删除仍被引用的 xcresult 证据。

---

## 7. Blocking Findings 登记簿

| ID | Severity | 事实 | 影响 | 关闭方式 |
|---|---|---|---|---|
| BF-1 | P0 | 当前 HEAD required `verify`=failure；所有整改未 commit，远端未评估当前树 | 不能把本地树写成 CI 已验收 | 合法写集 commit/push 后，取得 `verify=success` 与 branch protection 回执；必须先获磊哥授权 |
| BF-2 | P0 | `make verify-e2e` 只跑 5 个 WP21 tests；test07/完整 golden 被移出稳定门 | 真实回归可以绿着过门 | FA-1：恢复完整类 + WP21 filters；anti-placebo 锁 recipe 内容并有正反例 |
| BF-3 | P0 | WP2-1 三族候选早于 reduction/人审/pre-G0 进入工作树 | 候选可能被误报为已完成 | 冻结候选；Ballot 与前置关闭前零新增 WP21 改动；不计完成度 |
| BF-4 | P0 | window 不在 risk-policy forbidden devices；lookup 未命中后 `.allow` | 行驶中开窗安全洞 | G3/FA-4：speed>0 refuse、unknown refuse、stationary 按 B07；三态实跑 |
| BF-5 | P1 | CURRENT/demo script/secretary 旧口径与 live 5 tools 冲突 | 现场讲稿可能作不实陈述 | FA-2：统一写“后三族 candidate、未发布、禁演示” |
| BF-6 | P1 | ui-e2e workflow 远端 404、未 required | push 不会被 UI 回归拦截 | release 前注册 workflow、required context、取得 green run + xcresult artifact |
| BF-7 | P1 | full Swift suite 因 C5 Python 依赖环境红 | `verify-ci` 无法可信全绿 | 独立修 C5 env，full suite 0 本阶段新增失败，`make verify-ci` exit 0 |
| BF-8 | P1 | E3/WP0-7/M0 人类/物理证据未闭 | 发布环不完整 | 磊哥亲灌句 + 录像/彩排 + 明确签字；不可由 agent 代签 |
| BF-9 | P2 | 旧 isolation assertions 是 mounted=2 的历史快照 | 后续误引会拿错基线 | FA-3：旧件标 superseded，新 assertions 对账 live candidate 态 |
| BF-10 | P2 | protected 路径出现 untracked playbook | 可能被误当新权威 | 移出/隔离，或磊哥书面授权保留；未授权不得动 |

### 7.1 P0 stopline

命中以下任一项，立即停止产品写入并上抛：

- AF-G0 被无证据翻为 GO；
- Ballot 未拍却把推荐项写成 `RATIFIED_OWNER`；
- Phase2 implementation 从 PAUSED 改为 in-progress；
- window 候选继续扩张但安全门未闭；
- 用测试数量、grep、文档存在或 agent 回执替代行为门；
- 使用 `reset/checkout/stash` 或整包恢复隔离快照；
- 修改 protected 路径；
- 增加第二 receipt、第二 authority、第二 proven 口径、第二 route/result 体系。

---

## 8. Phase2 冻结文档包

### 8.1 十轮源账

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/PHASE2-GRILL-10-ROUND-DECISION-LEDGER.md`

- 完整记录十轮、每轮五问、回答、矛盾与 Main 归并。
- 它是决策 provenance，不是最终实施计划。
- frontmatter 的 `TEN_ROUNDS_COMPLETE_PENDING_REDUCTION_AUDIT` 是源账状态；不要因 reduction 后来冻结就改写历史问答。

### 8.2 Reduction matrix

`.../PHASE2-GRILL-REDUCTION-MATRIX.md`

- status：`FROZEN_GLM52_VERIFIED_FOR_HUMAN_REVIEW`
- human review：`PENDING`
- 输入守恒：Round 1–9 各五问 45 units + Round 10 五个综合块 = 50 units；全覆盖，不抽样。
- disposition 枚举：`RATIFIED_OWNER`、`LOCKED_CARRY_FORWARD`、`RESOLVED_BY_AUTHORITY`、`OBSERVED_GAP`、`NEEDS_HUMAN_DECISION`、`DEFERRED_WITH_TRIGGER`、`REJECTED`。
- `RATIFIED_OWNER` 只允许用于磊哥明确拍过的决定。
- 含 11 类 Corner Matrix 与唯一 Ballot B07–B11。

### 8.3 Phase2 实施计划

`.../PROGRAM-WBS-V10-PHASE2-WP2-1-IMPLEMENTATION-PLAN.md`

- 文件名保留旧 WP2-1 名称，但正文已经 supersede 旧 WP2-1-only 计划，覆盖整个 Phase2。
- status：`FROZEN_GLM52_VERIFIED_FOR_HUMAN_REVIEW`
- implementation：`PAUSED`
- human review：`PENDING`
- acceptance surface：`text-route-c3-state-readback-ui`
- speech acceptance：`excluded`
- 当前候选代码不计完成度；每个 gate 仍需 RED→GREEN→smoke→异源审。

### 8.4 K3 基础审计

`.../PHASE0-PHASE1-APPENDFIX-K3-AUDIT.md`

- 当前基础 verdict 的主权威：`AUDIT_COMPLETE_AF_G0_RED_PHASE2_NO_GO`。
- proof ceiling：本机 targeted probes + iOS simulator + GitHub API。
- 10 个 blocking findings；BF-1..4 为硬前置。

### 8.5 K3 计划审计与 GLM-5.2 终验

- `.../PHASE2-K3-2-PLAN-AUDIT.md`
- `.../PHASE2-GLM52-FINAL-FIX-VERIFY.md`

GLM-5.2 结论 `FIXES_VERIFIED_PASS` 只证明 PA-1..PA-8 已正确吸收、50/50 守恒与 ID 唯一性成立；不证明产品代码、AF-G0、Phase2 或发布已通过。

### 8.6 Secretary log

`.../DEMO-READINESS-SECRETARY-LOG.md`

- `510-525`：磊哥最终模型路由，supersede 之前临时路由。
- `529-549`：呈拍前事实确认；明确 implementation PAUSED、AF-G0 RED、Phase2 NO-GO、B07–B11 pending。
- 最新 Ultra 修正已删除“磊哥最终拍板确认”“拍板启动 Phase0”等越权措辞。
- Secretary log 只作编排流水账，不替代 live audit/plan/owner decision。

### 8.7 隔离归档

`.../isolation/phase2-phase3-quarantine-20260722/`

重要文件：

- `full-snapshot-receipt.json`
- `full-tracked-working-tree.patch`
- `full-untracked-files.tar.gz`
- `full-untracked-files.manifest.json`
- `deepseek-boundary-inventory.md`
- `post-isolation-negative-assertions.json`

规则：

- 这是取证与恢复材料，不是 live 产品目录。
- 禁止整包恢复；只能按明确 slice/hunk 恢复，并先核当前文件。
- 旧 negative assertions 已被当前 candidate tree 超越，必须标 superseded 后再生成新基线。

---

## 9. 唯一待拍 Ballot：B07–B11

> 下面的 ⭐ 是冻结计划中的推荐，不是自动决定。磊哥需要逐项选择；Main 只能在收到明确选择后写 `RATIFIED_OWNER`。

### B07：`speed=0` 时 gear 如何影响开窗

- A：P/R/N/D 均允许。
- ⭐ B：P/N 允许，D/R 拒绝。
- C：仅 P 允许。
- 未拍前 interim：仅 gear=P 允许，其他 fail-closed。
- 影响：risk policy、replay、window E2E、UI refusal 文案、release stopline。

### B08：Receipt v2 clean-cutover 与 strict 范围

- A：Frontstage 唯一 v2；receipt + payload 都 strict。
- ⭐ B：Frontstage 唯一 v2；receipt strict，payload 沿现有 typed decoder。
- C：新并行 receipt 或保 v1 shim；因双权威原则，属于禁止方向。
- 影响：receipt schema、writer、validator、payload 边界、历史证据迁移、CI artifact。

### B09：华氏度呈现与 relative 范围

共同前提：无单位默认摄氏；保持 `26度` 行为；不新增单位反问。

- A：explicit 显示源 °F + canonical °C；relative 本期拒绝。
- ⭐ B：explicit 输入执行，但只回 canonical °C；relative 本期拒绝。
- C：explicit + relative 都支持；扩大本期数值语义。
- 影响：numeric grammar、C3 conversion、payload/dialog、golden、negative scope。

### B10：committed action 后 durable writer 失败

- ⭐ A：告知“已执行但记录失败”，显示 actual，并停止 session。
- B：只报系统错误，不显示成功卡；保留诊断并停止 session。
- C：声称回滚/取消；因伪造事实，禁止。
- 影响：writer error taxonomy、UI actual、session stop、receipt 链。

### B11：Phase2 收口与 S10 协议

B11 不阻塞 G0–G9 开工，但阻塞 Phase2 收口。

- ⭐ A：允许工程链完成时以 `actionDemoProven=0/120` 收口 Phase2；S10 由磊哥择机另跑；公告必须大字披露 0/120。
- B：S10 首跑完成前，不允许 Phase2 收口。
- C：允许工程门/CI 先翻 canonical proven；双权威，禁止。
- 影响：Phase2 closeout、S10 触发/频率、canonical 翻格链、对外公告。

### 9.1 Ballot 之外还要确认的 supersession

批准计划时，磊哥还需确认：Round 6 owner amendment 正式 supersede WBS WP2-4c 的旧句——exact `能调到{N}度吗` 作为受控 polite command 执行；显式 query 才只读。回写时保留旧文，新增 revision 记录，不能静默改掉历史。

---

## 10. Phase2 计划执行 DAG

冻结计划的唯一顺序：

```text
pre-G0 前置
  → G0 inventory
  → G1 typed value / numeric
  → G2 classification & scope
  → G3 C3 risk & 四族执行
  → G4 turn lease & cancellation
  → G5 result taxonomy / payload / UI
  → G6 RuntimeTurnReceipt v2
  → G7 per-utterance behavior gates / anti-placebo
  → G8 CI DAG
  → G9 governance reduction
  → S10 owner acceptance / canonical 翻格链
```

### 10.1 Pre-G0 必须先关闭

1. **P0-a**：required `verify` 对合法 commit 绿；需要磊哥先授权 commit/push。
2. **P0-b / FA-1**：修复 `make verify-e2e` 聚合，稳定门恢复完整 AC golden/test07 + WP21；anti-placebo 锁 recipe。
3. **P0-c**：保持候选冻结；不得继续 WP21。
4. **P0-g / FA-2/FA-3**：CURRENT、demo script、secretary、isolation receipt 与 candidate live 态对齐。
5. **P0-h**：重跑隔离负范围，确认 model/十族/AF9 不回潮。
6. **P1**：采用已冻结 reduction/plan 审计包。
7. **P2a**：磊哥拍 B07–B10。
8. **P3**：磊哥批准计划，并确认 WBS WP2-4c supersession。

### 10.2 In-flight 必闭

- **G3 / FA-4**：window 行驶安全门。
- 车窗在该门闭合前不得演示/合并；当前整个候选树已经冻结，因此不能拿“G3 later”当继续写的理由。

### 10.3 Release-only / 独立账

- 远端 UI E2E workflow 注册并 required；green run + artifact。
- C5 Python 依赖环境修复；full suite 和 `make verify-ci` 真绿。
- E3/WP0-7/M0：磊哥亲灌句、录像/彩排、签字。
- B11 与 S10 收口协议。

### 10.4 G0–G9 核心交付语义

| Gate | 主要目标 | 不允许偷换成 |
|---|---|---|
| G0 | 50+ live 锚 inventory 与异源抽核 | 文件存在清单 |
| G1 | typed value、exact numeric、overflow/precision/unit | silent clamp / Int fallback |
| G2 | command/query/scope/mode 权威 | 字符串特殊分支堆叠 |
| G3 | fresh risk、window/四族真实 C3 执行、row167 compound | preset/fixed plan/direct store write |
| G4 | turn lease、cancel、last-intent-wins | UI 层隐藏旧结果 |
| G5 | result taxonomy、payload actual、stale UI guard | proof 文本或 planned 值 |
| G6 | 唯一 Receipt v2、durable writer、validator | 第二 receipt / 硬编码 proofClass |
| G7 | 每句行为门、mutation negative、anti-placebo | grep/test count/空函数 fixture |
| G8 | 单一 CI DAG、required checks | workflow 文案或本地-only 绿 |
| G9 | 治理 roster 精确收敛、archive、day-zero | 当日声称未来三个月不回潮 |
| S10 | owner 亲验、canonical 唯一翻格 | 工程/CI 自动翻 `actionDemoProven` |

---

## 11. 下一会话严格执行顺序

### Step 0：只读恢复上下文

按顺序读：

1. 本 handoff。
2. `PHASE0-PHASE1-APPENDFIX-K3-AUDIT.md` 的 Executive verdict、BF-1..10、non-claims。
3. `PHASE2-GRILL-REDUCTION-MATRIX.md` 的 frontmatter、Corner Matrix、Ballot、Freeze Receipt。
4. `PROGRAM-WBS-V10-PHASE2-WP2-1-IMPLEMENTATION-PLAN.md` 的 §0、§1、§3、§4、§8、§10、Freeze Receipt。
5. `REMEDIATION-WBS-IMPLEMENTATION-PLAN.md` 的 frontmatter、§4A、§5、§17.9/17.10；注意执行状态陈旧，不直接采信。
6. 当前 `git status --short --branch`、mounted/admission/risk policy、Makefile verify-e2e recipe。

### Step 1：向磊哥呈拍，不写代码

必须一次性呈：

- 当前 verdict：AF-G0 RED / Phase2 NO-GO / implementation PAUSED；
- B07–B11 五题；
- Round 6 WBS supersession 确认；
- 说明批准计划不等于批准开工。

### Step 2：按 owner 回答写回唯一文档

- 在 reduction matrix 将对应 B 键改为 `RATIFIED_OWNER`，保留选项、理由、日期与 owner 原话摘要。
- 级联到 Phase2 plan §10、risk/receipt/unit/writer/S10 对应规则。
- WBS 只做显式 revision amendment；不改 Program WBS 版本，不创造 V11。
- 由 GLM-5.2 做独立 fix-verify；秘书由 Ultra 记账。

### Step 3：关闭 AF-G0 / pre-G0

建议严格切片：

1. FA-1：Makefile + anti-placebo script/tests，恢复稳定 E2E 合同。
2. FA-2：CURRENT + demo script + secretary log，写清“后三族 candidate、未发布、禁演示”。
3. FA-3：旧 isolation assertions 标 superseded，新 assertions 对账当前 candidate tree。
4. 复跑完整 product behavior class、`make verify-e2e`、anti-placebo、governance hygiene、UI E2E。
5. 若磊哥授权，按合法写集 commit/push，取得 required `verify` green；注册 UI E2E required 属 release 前置。
6. GLM-5.2 独立审计 AF-G0，不允许实现者自签。

### Step 4：只有 pre-G0 真闭合后才启动 G0

- 重新检查 implementation status；由磊哥明确授权从 PAUSED 解冻。
- G0 只读 inventory 先行；任何 live 锚打不开/不符即整体 RED，不开始 G1。
- 严格遵守 shared-file 串行 owner：`ContractLookups.swift`、`ToolContractIRFrameBridge.swift`、`C3ExecutionPipeline.swift`、`DemoRuntimeSessionRunner.swift`、`ContentView.swift`、Makefile/scripts 不可同 wave 多人写。

### Step 5：验证与 closeout

- 每个 gate 必须 RED reproduction → GREEN → smoke → 独立审计。
- UI 变更必须真实 simulator 驱动；产品行为必须走 text→route→C3→state→readback→UI。
- 远端/人类/真机证据单独标 proof class，不用本地绿外推。
- 每次 closeout 写 receipt，列 non-claims、残余风险、next actions；禁止 `PASS/DONE` 空口。

---

## 12. 推荐模型路由（磊哥最终口径）

来源：Secretary log `510-525`，supersede 会话中所有临时路由。

| 任务实质 | 路由 | 约束 |
|---|---|---|
| 简单机械 | DeepSeek V4 Flash | 批量提取、格式转换、数据清洗、单一确定操作 |
| 中型 | Ultra | 编码实现、方案撰写、文档生成、**非审计**方案工作 |
| 复杂 | GLM-5.2 | 架构、复杂重构、核心实现、验收函数设计 |
| 所有审计 | GLM-5.2 | 独立交叉审、fix-verify、红队、终审 |
| 秘书 | Ultra | 记录、冲突、待拍键、状态机、handoff |

硬规则：

- 按任务实质，不按速度/工时降级。
- 已进入 GLM-5.2 的复杂/审计切片，由 GLM-5.2 完结。
- Ultra 不做审计裁决；秘书不写 finding、不代 Main/owner 签字。
- 简单任务也不因“权威感”无谓升级到 GLM-5.2。
- 不使用 Gemini；外部模型协作遵循当前项目全局规则。

---

## 13. 写集与恢复纪律

### 13.1 绝对禁止

- `git reset`、`git checkout -- <path>`、`git stash`、整树覆盖。
- 从隔离 tar/patch 整包恢复。
- 删除不认识的 untracked 文件。
- 修改 `~/.claude/**`。
- 把四个 protected 路径顺手清理。
- 将 Phase2 candidate 回退当作“修复”而不先核 hunk provenance。
- 无 owner 批准 commit/push/required-check 变更。

### 13.2 必须执行

- 写前读当前文件；发现与 handoff 不同，按用户新工作处理。
- exported symbol 改动前用 LSP references。
- shared file 同 wave 只有一个 owner。
- 决策、代码、验证、receipt 四件同一 slice 落盘。
- 每个外援明确 write set、non-goals、acceptance；Main 亲核 live 文件与命令。
- 产品行为与治理健康分账；治理门减少不抬产品 proven。

---

## 14. 关键文件索引与可信度

### 14.1 Run root 权威文件

根目录：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/`

| 文件 | 用途 | 当前可信度/注意 |
|---|---|---|
| `REMEDIATION-WBS-IMPLEMENTATION-PLAN.md` | Program WBS V10 范围/依赖 | 范围权威；执行状态部分陈旧 |
| `STAGE-ACCEPTANCE-AUDIT-AND-REMEDIATION-REPORT.md` | 早期阶段审计 | 历史诊断；不替代 K3 新 verdict |
| `PHASE1-APPENDFIX-IMPLEMENTATION-PLAN.md` | AF-0..8 细案 | 行为修复来源 |
| `PHASE1-APPENDFIX-MAIN-THREAD-AUDIT-20260722.md` | Main 隔离前亲审 | 历史时点证据 |
| `PHASE0-PHASE1-APPENDFIX-K3-AUDIT.md` | 当前基础裁决 | **最新 AF-G0/Phase2 verdict 权威** |
| `PHASE2-GRILL-10-ROUND-DECISION-LEDGER.md` | 十轮问答源账 | provenance，不直接开工 |
| `PHASE2-GRILL-REDUCTION-MATRIX.md` | 全量消减 + Ballot | 冻结供人审 |
| `PROGRAM-WBS-V10-PHASE2-WP2-1-IMPLEMENTATION-PLAN.md` | 全 Phase2 实施计划 | 冻结供人审，implementation PAUSED |
| `PHASE2-K3-2-PLAN-AUDIT.md` | K3 计划审计/fix-verify | PA-1..8 证据 |
| `PHASE2-GLM52-FINAL-FIX-VERIFY.md` | GLM 独立终验 | 只证明文档修订闭合 |
| `DEMO-READINESS-SECRETARY-LOG.md` | 编排/路由/流水账 | 次级事实源，不替代审计 |
| `isolation/phase2-phase3-quarantine-20260722/` | 可恢复快照/越界归档 | 取证用，禁止整包恢复 |

### 14.2 Repo 内关键文件

| 文件 | 当前作用 |
|---|---|
| `Core/Contracts/DDomainMountedToolCatalog.swift` | 5 个 mounted tools 真值 |
| `Core/Routing/DemoSliceAdmissionCatalog.swift` | 5 个 entries / literal candidate 真值 |
| `Core/Execution/DemoSliceRoute.swift` | route/no-op/runner 调用边界 |
| `Core/Execution/C3ExecutionPipeline.swift` | mutation/risk/readback 主链；Phase2 多个后续风险点 |
| `Core/Contracts/ContractLookups.swift` | fail-closed state lookup + 当前 window 未命中洞 |
| `contracts/risk-policy.yaml` | 当前仅门/尾门行驶规则，无 window |
| `Core/Execution/DemoRuntimeSessionRunner.swift` | plan/atomic/cancel 主边界 |
| `Core/Presentation/RuntimePresentationBridge.swift` | result/payload/presentation 真值 |
| `App/ContentView.swift` | customer ingress/UI 渲染与任务生命周期 |
| `Tests/MAformacCoreTests/DemoSliceProductBehaviorGateTests.swift` | 18 条当前产品/候选行为 tests |
| `Makefile` | 稳定门；当前 verify-e2e recipe 漂移 |
| `scripts/verify_anti_placebo.py` | anti-placebo；当前未锁完整 recipe |
| `.github/workflows/verify.yml` | required `verify` 路径 |
| `.github/workflows/ui-e2e.yml` | 本地存在，远端未注册/required |

### 14.3 旧 handoff 的使用方式

- `docs/handoffs/2026-07-21-phase0-1a-1b-remediation-complete.md`：历史交付，不再代表当前 AF-G0 verdict。
- `docs/handoffs/2026-07-22-phase1-appendfix-isolation-baseline.md`：隔离时点基线；其中 AF-G0 GO 部分已被 K3 live 审计 supersede。
- 本文件：当前恢复入口；仍需下会话用 live probes 更新，不能跨新改动自动保真。

---

## 15. 可复制的下一会话起手 Prompt

```text
[MAformac Phase2 人审与 AF-G0 收口续作]

你是 MAformac 主线程指挥官。先只读，不写产品代码。

必读顺序：
1. docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md
2. run root/PHASE0-PHASE1-APPENDFIX-K3-AUDIT.md
3. run root/PHASE2-GRILL-REDUCTION-MATRIX.md
4. run root/PROGRAM-WBS-V10-PHASE2-WP2-1-IMPLEMENTATION-PLAN.md
5. run root/PHASE2-GRILL-10-ROUND-DECISION-LEDGER.md
6. run root/REMEDIATION-WBS-IMPLEMENTATION-PLAN.md（只把范围/依赖当权威；§17.10 AF-G0 GO 与 frontmatter execution status 已陈旧）

当前硬真态：
- AF-G0=RED；Phase2=NO-GO；implementation=PAUSED；human review=PENDING。
- reduction+plan 已冻结为 FROZEN_GLM52_VERIFIED_FOR_HUMAN_REVIEW，只供磊哥人审，不放行实施。
- 工作树有 5 mounted tools / 5 admission entries；后三族是越前 candidate，不计完成度、不得演示/合并。
- window 行驶安全门缺失；make verify-e2e 只跑 5 个 WP21 tests；required verify 远端红；ui-e2e 未 required。
- 产品验收面只认 text→route→C3→state mutation→readback payload→UI；ASR/TTS/音频不进 gate。
- canonical actionDemoProven 在 S10 前保持 0/120。

第一步：向磊哥一次性呈 B07-B11，并提醒“批准计划≠批准开工”；同时请磊哥确认 Round 6 对 WBS WP2-4c 的 supersession。
第二步：收到 owner 选择后，回写 reduction+plan+WBS amendment，并由 GLM-5.2 独立 fix-verify。
第三步：依次关闭 FA-1/FA-2/FA-3 与 pre-G0；未经磊哥授权不 commit/push。
第四步：只有 AF-G0/pre-G0 真闭合且磊哥明确解冻后，才从 G0 开始。

禁止：reset/checkout/stash、整包恢复 quarantine、修改 protected 路径、继续 WP21 候选、把本地绿写成阶段 PASS、把推荐项写成 RATIFIED_OWNER。
最终模型路由：简单 V4 Flash；中型 Ultra；复杂/所有审计 GLM-5.2；秘书 Ultra。
```

---

## 16. Closeout Receipt（人可读）

- **status**：DONE（仅指“JSONL 审计 + 当前真态 handoff”交付完成）。
- **scope_claim**：完成二十余小时 JSONL 的结构化回顾、live repo/审计/计划交叉核对，并写出可恢复的 Phase2 人审 handoff。
- **proof_class_ceiling**：local macOS targeted tests + iOS simulator + GitHub API metadata。
- **changed_files_by_this_closeout**：
  - `docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md`
  - 对应 machine-readable receipt（若与本文件同目录交付）
- **validation**：
  - JSONL 截点 9498 records / 0 malformed / SHA-256 已记录；
  - 当前 Git status 124 dirty entries；
  - `make verify-e2e` exit 0，但只跑 5 tests + anti-placebo；
  - 完整 `DemoSliceProductBehaviorGateTests` 18/18 绿；
  - K3 同日 174 targeted Swift tests 0 failures、7 UI simulator tests 0 failed；
  - 远端 required `verify` failure、ui-e2e 404、required contexts 仅 `verify`。
- **residual_risks**：BF-1..BF-10；尤其 BF-2 验收函数漂移、BF-4 window 行驶安全洞、混合工作树、protected 路径污染、full suite/C5 红账、远端 UI-E2E 缺失、人类证据未闭。
- **next_actions**：磊哥审 B07–B11 + supersession → GLM fix-verify → FA-1/2/3 + pre-G0 → AF-G0 独立复审 → 明确解冻后 G0。

---

## 17. 最终一句话

**文档计划已审计冻结，可交磊哥拍；产品和阶段均未放行。当前正确动作是人审 Ballot 与关闭 AF-G0，不是继续 Phase2 编码。**
