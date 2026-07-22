---
kind: independent-remediation-audit
project: MAformac
as_of: 2026-07-21
authority_order:
  - REMEDIATION-WBS-IMPLEMENTATION-PLAN.md v2.1 FROZEN
  - live production code and active tests
  - local runtime and CI probes
  - remediation handoff
status: AUDIT_EXECUTION_VERIFIED__REMEDIATION_NO_GO
proof_ceiling: local-source+swift-tests+ios26-simulator-xcresult+github-config
---

# Phase 0/1a/1b 整改独立审计

> 完成度分诊：本文仅证明“独立审计动作已执行并有实跑证据”，不证明整改通过。整改 Release Gate = **NO-GO**。

## 1. Executive Verdict

`docs/handoffs/2026-07-21-phase0-1a-1b-remediation-complete.md` 的“Phase 0+1a+1b 闭环 / 双路异源审 PASS”与 WBS v2.1、活跃代码、测试、CI 和 iOS 前台实跑不一致。禁止据此进入 Phase 2、合并主线或安排客户演示。

确实落地的部分：

- COR-1 fail-closed 三重 guard 已在 `Core/Contracts/ContractLookups.swift:311-326` 生效，并被 `Core/Execution/C3ExecutionPipeline.swift:337-346` 调用。
- `make verify-e2e` 真跑 12 tests / 0 failures，且测试经 `DemoSliceRoute.route(text:)`。
- ROB-1 的 `speechDidEnqueue → orbState → payload → ContentView` 生产链存在。
- runtime no-mutation checker 已移除自报 `proofClass` oracle。
- 模型未接、ASR stub、多意图 fail-closed、其他设备族零准入的主体口径属实。

但上述局部实现不能推出阶段闭环。Evolving Rescue 在收到主线程动态证据后，将初判 `PASS_WITH_RISK` 修订为 `FAIL`。

## 2. Baseline Matrix

| 范围 | 当前真态 | 裁决 |
|---|---|---|
| Phase 0 | M0 证据不足；WP0-7 未执行；WP0-8 仅 skip；WP0-9 实跑失败 | FAIL |
| Phase 1a | 12 条 core route 测试绿，但 test07 缩窄 runner/TTS 硬门；ROB-1 行为门不足；WP1a-7 仅 TODO | FAIL |
| Phase 1b | COR-1 真修；COR-2 仅 legacy/pipeline 层；COR-4 不符合 frozen contract；UI E2E 红；COR-7/8 未闭合 | FAIL |
| 客户可见 iOS 路径 | 正向“打开空调”仍为 idle，runner=0 | FAIL |
| CI | verify-e2e 已进 verify-ci；anti-placebo 红；UI workflow 未注册/required；UI Make 门损坏 | FAIL |
| 文档 | 闭环/PASS 与本文件证据冲突 | FAIL |

## 3. P0 Register

### P0-1 客户前台路径失败

直接运行 `FrontstageCustomerIngressUITests/testDemoSliceP1OpenACExecutesWithAppVisibleProof`：

- `xcodebuild` exit 65；
- 1 test / 7 assertion failures；
- xcresult：`result=Failed`、`failedTests=1`、`passedTests=0`；
- 页面仍显示“等待输入”；proof 为 `status=idle;runner=0;mutation=0;readbacks=0`；
- 日志显示发送按钮 tap 命中点 `{-1,-1}`。

因此 core literal route 可执行，不等于 WBS 指定的 iOS 客户入口可执行。

### P0-2 UI E2E 门损坏并可吞失败

`Makefile:65-91`：

1. `IOS26_UDID` 在前一 recipe shell 中赋值，xcodebuild 所在 recipe 读到空值；`make verify-ui-e2e` 因而 exit 2，未有效执行 UI test。
2. `xcodebuild ... | tail -30` 后的 `$?` 是 `tail` 的退出码。
3. xcresult 只检查 `testsCount > 0`，没有检查 `failedTests == 0`。

修掉 UDID 后，测试执行且失败仍可能返回绿。远端 `gh workflow list` 只有 `Verify`；main required check 只有 `verify`，UI E2E 尚未注册或 required。

### P0-3 test07 偷换 frozen 验收

WBS `WP1a-1` 要求重复“打开空调”时 runner=0、无新 TTS、全 cells/revision 不变。活跃测试 `DemoSliceProductBehaviorGateTests.swift:89-97` 明写“当前实现仍走 runner（已知 gap）”，只断言 revision 和 cell。`make verify-e2e` 的 12/12 是真实命令结果，但不是 WBS 定义的 12/12。

### P0-4 COR-4 未形成 typed no-action

- `DDomainToolCallParser.swift:13-16` 在 metadata/size 校验前短路。
- `:39-48` 接受非空 ordinary content；测试把 `The answer is 42.` 判为合法 no-action。
- 该分支可绕过 content size 限制。
- `DemoRuntimeSessionRunner.swift:162-164` 把空 frames 映为 unsupported，而非 typed no-action。
- 全量回归新增 oversized content 与 empty-plan 两项失败。

### P0-5 活跃测试覆盖净损失

三个 tracked 文件被删除并退成 `.bak`：

| 文件 | 行数 | 约测试方法 |
|---|---:|---:|
| `DemoRuntimeSessionRunnerPartialExecutionTests.swift` | 601 | 12 |
| `RuntimePresentationBridgeTests.swift` | 757 | 20 |
| `RuntimePresentationPayloadPublicFixtureTests.swift` | 754 | 8 |
| 合计 | 2112 | 40 |

另有 `Cor78MutationTests.swift.bak` 312 行、约 8 个测试未进入活跃 target。丢失覆盖包括 partial fail-closed、projection redaction、TraceEnvelope、fixture/schema/manifest、unknown-field rejection、COR-7/8 行为。本文不推断删测动机，只裁决覆盖退出且未迁移。

## 4. P1/P2 Register

1. ROB-1 生产接线存在，但冻结门主要依赖源码 `String.contains`；没有真实 runner→payload `orbState` 行为断言。
2. `ContentView.swift:621` 仍硬编码 `voiceState: .speaking`；TTS 失败时可能 orb idle、MicDock speaking。
3. COR-2 的 active tests 存在，但绕过真实 mounted D-domain backend；legacy `set_cabin_ac` 不在 mounted catalog。
4. COR-7 store revision 可保持不变，但 runner 仍统一产出 accepted，`ContentView.swift:628` 固定写 `mutation=1`。
5. COR-8 的 `atomicityContract` 在 `DemoRuntimePartialPlan.swift:197-202` 执行后计算，生产路径无 consumer，属于 outcome label，不是执行约束。
6. payload v1 producer 新增 `orbState`，但 strict consumer `CodingKeys` 和 `public_fixture_schema.v1.json:47-60` 未同步。
7. WP1a-7 要求的 probe `XCTAssertEqual` 没有落地，只留下 TODO。
8. WP0-8 以 `XCTSkip` 保留治理自违规测试，不符合“删除或改验产品行为”。
9. M0 只有“启动 Phase 0”，没有 KPI/阈值/频次/缺席机制四项书面确认。
10. WP1b-5 未在 Phase 1b 执行。
11. 当前是 1 条 exact + 6 个温度前缀，共 7 类 surface；handoff 少报一类。
12. “能调到26度吗”当前会执行，与 WBS WP2-4c 的只回答不执行冲突。
13. `docs/CURRENT.md` 的日期、训练状态、latest handoff 和下一步均落后于本轮整改。

## 5. Remediation Report Omission Register

原报告漏掉或弱化：

- iOS 前台正向路径实跑失败；
- UDID 跨 shell 丢失、pipeline exit 丢失、未检查 failedTests；
- UI workflow 未注册、未 required、未运行；
- 三个 tracked 测试删除及 2112 行覆盖净损失；
- test07 明知 runner 仍执行却判绿；
- COR-4 非空 content/no-size-check/unsupported 三重漂移；
- 全量 suite 新增两项非 C5 失败；
- ROB-1 关键验收仍为源码扫描；
- voiceState 硬编码 speaking；
- COR-2 未经 mounted backend；
- COR-7 proof 固定 mutation=1；
- COR-8 无 runtime consumer；
- payload v1 producer/consumer/schema 漂移；
- WP1a-7 只有 TODO；
- M0 证据缩水、WP1b-5 未实施、CURRENT 失效。

## 6. Runtime Truth

| 能力 | 当前状态 |
|---|---|
| Core literal demo route | 部分可用 |
| iOS 客户前台入口 | 不可用 |
| 空调语句面 | 1 exact + 6 温度前缀，18–32℃ |
| 车窗/座椅/灯光等 | 零准入 |
| LLM | 未接 |
| ASR | stub |
| 多意图 | fail-closed |
| COR-1 | 真修 |
| COR-2 | legacy/pipeline 层部分修 |
| COR-4 | 未满足 frozen contract |
| COR-7 | store no-op 有效，outcome/proof 不诚实 |
| COR-8 | 字段存在，原子执行语义未生效 |
| actionDemoProven | 0/120 |

## 7. Verification Record

| 命令/探针 | 结果 |
|---|---|
| `make verify-e2e` | exit 0；12 tests / 0 failures |
| COR-1/adapter 定向测试 | 25 tests / 0 failures |
| `swift test` | exit 1；1143 tests / 25 failures / 8 skipped |
| `make verify-anti-placebo` | exit 2 |
| `make verify-ui-e2e` | exit 2；未有效执行 UI tests |
| 直接 P1 XCUITest | exit 65；1 test / 7 assertion failures |
| xcresult summary | Failed；passed 0 / failed 1 |
| GitHub workflow/branch protection | 仅 Verify；required 仅 verify |

外援假阳已剔除：UI test class 实际位于仓库根 `MAformacIOSUITests/`；`verify-e2e` 已进入 `verify-ci`；protected 四文件是继承 dirty，SHA baseline 证明本轮未改；COR-2 有 active tests，但测试层级不足。删测动机不作推断。

## 8. Scorecard

以下为审计判断，不是自动指标：

| 维度 | 分数 |
|---|---:|
| 客户可见 E2E | 2/10 |
| 安全语义 | 4/10 |
| 测试完整性 | 2/10 |
| CI 可信度 | 1/10 |
| 架构闭合度 | 4/10 |
| Presentation 真值 | 3/10 |
| 文档一致性 | 2/10 |
| 凭据/敏感信息安全 | 7/10 |
| 综合 | 3/10，NO-GO |

## 9. Release Gate and Closeout Receipt

### Release Gate

Phase1-AppendFix 必须依次完成：恢复活跃测试 → 修 UI 产品路径与判分器 → 恢复 frozen 产品合同 → 修 presentation 真值与 schema → 闭合 COR-2/COR-8 → 最后更新文档。所有门真实运行且异源复核前，Phase 2 不得开始。

### Receipt

- `audit_status`: DONE，仅指本次审计执行与验证。
- `remediation_status`: FAIL / NO-GO。
- `changed_files_by_audit`: none。
- `non_claims`: 不声称 CI 绿、客户设备可演、模型/ASR/多意图接通或 Phase 1 已验收。
- `proof_ceiling`: 本地源码、Swift 测试、iOS 26 模拟器 XCUITest、xcresult、GitHub 配置元数据；未覆盖物理设备、真实车辆、真麦克风和未提交工作树的远端 CI。

本审计的各席位结构化摘要与 transcript 指针见 `INDEX.md`。

## 10. 审计后采纳与 successor baseline

磊哥在本审计完成后授权：将总整改 WBS 命名为 **Program WBS V10**，全量吸收九点 finding，并新增 Phase1-AppendFix 详细实施计划。权威产物：

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/REMEDIATION-WBS-IMPLEMENTATION-PLAN.md`：Program WBS V10 / document revision 2.2 / canonical successor baseline。
- 同目录 `PHASE1-APPENDFIX-IMPLEMENTATION-PLAN.md`：AF-0..AF-8 的执行级展开。

本段只记录 finding 已被计划吸收。代码整改尚未执行，本文 `REMEDIATION_NO_GO` 裁决不变；V10/AppendFix 文档存在不构成 AF-G0 通过。
