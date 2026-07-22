---
kind: remediation-secretary-log
project: MAformac
as_of: 2026-07-21
role: 观测+经验教训+进度跟踪
authority: 秘书观测，非产品/执行授权
---

# MAformac 整改实施 — 秘书观测日志

> 本文件由秘书维护，记录实施进度、经验教训、异常观测。指挥官和 worker 不改本文件。
> 事实锚：产品当前仅 2 条 literal / 模型未接 / COR-1..6 未修 / actionDemoProven=0/120

## Update 1 (2026-07-21, Phase 0 启动)

### 进度快照

| WP | 状态 | worker | 备注 |
|---|---|---|---|
| WP0-1 CURRENT.md 锚定 | DISPATCHED | ultra-leaf | 改第一条为产品行为 KPI |
| WP0-3 checker 冻结 | DISPATCHED | bulk-worker | 新建冻结通知 |
| WP0-4 停百分比汇报 | DONE | 指挥官声明 | 口头生效，无文件变更 |
| WP0-5 口径清洗 | DISPATCHED | long-judge | 新建 demo-messaging-guidelines.md |
| WP0-6 安全披露 | DISPATCHED | long-judge | 新建 safety-disclosure-and-qa.md |
| WP0-7 演示机准备 | PENDING | 磊哥/演示者 | 需物理操作 |
| WP0-8 GOV-5/6 清理 | DISPATCHED | lane-parent+孙子 | 改测试+改DONE标记 |
| WP0-9 anti-placebo CI | DISPATCHED | gpt55-parent+孙子 | 新建脚本+Makefile+CI |
| M0 磊哥确认 KPI | PENDING | 磊哥 | 待确认 |

### 经验教训

- L1 (from 审计): 验收函数被偷换——治理自洽替代产品行为作为验收标准。85% 绿标测治理非产品。
- L2 (from 审计): 演示能跑 ≠ 模型能演。当前只 2 条 literal 可演。
- L3 (from 审计): 元断言（必经真实解析路径）是唯一不可逆进步，优先级高于条数。
- L4 (from opus): WBS 体积本身制造"整改在推进"幻觉。唯一真进度 = verify-e2e 从不存在到 12 条绿。
- L5 (本次): Phase 0 压缩到半天，不让政策锚定变新仪式。

### 异常观测

- 无（待 worker 回稿后更新）

### 下一步

- 等 5 路 worker 回稿
- 指挥官亲核产物
- grok 异源审 Phase 0 产出
- M0 磊哥确认

## Update 2 (2026-07-21, Phase 0 收口 + Phase 1a 启动)

### 进度快照

| WP | 状态 | worker | 备注 |
|---|---|---|---|
| WP0-1 CURRENT.md 锚定 | ✅ DONE | ultra-leaf + 指挥官补第0条 | grok 核 PASS |
| WP0-3 checker 冻结 | ✅ DONE | bulk-worker | CHECKER-FREEZE-NOTICE.md |
| WP0-4 停百分比汇报 | ✅ DONE | 指挥官声明 | 口头生效 |
| WP0-5 口径清洗 | ✅ DONE | long-judge | demo-messaging-guidelines.md 14禁说词 |
| WP0-6 安全披露 | ✅ DONE | long-judge | safety-disclosure-and-qa.md 口播+追问 |
| WP0-7 演示机准备 | PENDING | 磊哥/演示者 | 需物理操作 |
| WP0-8 GOV-5/6 清理 | ✅ DONE | lane-parent+孙子 | XCTSkip + IDENTITY_REPAIR_ONLY |
| WP0-9 anti-placebo CI | ✅ DONE | gpt55-parent+孙子+指挥官修 | make verify-anti-placebo: PASS |
| M0 磊哥确认 | ✅ DONE | 磊哥 | 启动即确认 |
| WP1a-6 catalog变体 | ✅ DONE | lane-parent+孙子 | 6前缀+疑问语气剥离 |
| WP1a-1 12条golden测试 | DISPATCHED | gpt55-parent+孙子 | 等回稿 |
| WP1a-3 砍自指oracle | DISPATCHED | bulk-worker | 等回稿 |

### grok 收口审结果

总判：PASS WITH CARRY-FORWARD
- P1: WP0-1-policy-anchor.md 多余仪式 → 已删除
- P2: 秘书账状态对齐 → 本 Update 已对齐

### 经验教训

- L6 (本次): anti-placebo 脚本范围要用包含制（只查进度汇报）非排除制（扫全仓历史），否则历史文档触发假阳。
- L7 (本次): worker 产出的 Makefile target 可能只 echo 不调真脚本，指挥官必亲核命令输出。
- L8 (grok审): 政策锚定只放 CURRENT.md 一处，不制造第二政策 SSOT（双锚=新仪式）。
- L9 (磊哥定): grok 少用，opus xhigh / claude-native-rescue 多用。

### 产品真态（未变）

产品当前仅 2 条 literal / 模型未接 / COR-1..6 未修 / actionDemoProven=0/120。
Phase 1a 绿后预期：可演 6 句（含变体）+ 4 条 fail-closed 诚实拒绝。

### 下一步

- 等 WP1a-1 / WP1a-3 回稿
- 跑 swift test --filter DemoSliceProductBehaviorGateTests
- make verify-e2e 全绿 = Phase 1a 验收门

## Update 3 (2026-07-21, Phase 1a 收口 + Phase 1b 全闭环)

### Phase 1a 收口

| WP | 状态 | worker | 备注 |
|---|---|---|---|
| WP1a-2 ROB-1 orb | ✅ DONE | lane-parent+孙子 | 4文件：runner/payload/ContentView/test |
| WP1a-4+5 脚本+口径 | ✅ DONE | long-judge | demo-script-v1.md 定稿 |
| WP1a-7 测试质量 | ✅ DONE | gpt55-parent+孙子 | 14文件标注 + probe TODO |
| Phase 1a 收口审 | ✅ PASS 8/8 | deepseek-pro | 零 carry-forward |

### Phase 1b 全过程

| WP | 状态 | worker | 备注 |
|---|---|---|---|
| WP1b-1 COR-1 fail-open | ✅ DONE | deepseek-pro | 12测试绿，fail-closed |
| WP1b-2 COR-2 否定 | ✅ DONE | deepseek-pro(被砍)+gpt55确认 | 3测试绿，doNotAutoPowerOn |
| WP1b-3 COR-4 NO_TOOL | ✅ DONE | deepseek-pro(被砍)+gpt55重做 | 9测试绿，isLegitimateNoAction |
| WP1b-4 XCUITest CI | ✅ DONE | ultra-leaf | Makefile+workflow+xcresult解析 |
| WP1b-6 COR-7/8 | ✅ DONE | ultra(失败)+lane-parent重做 | 非雷核实落盘 |
| WP1b-7 ROB-3 | ✅ DONE | ultra-leaf | 非雷（let语义） |
| Phase 1b 双路审 | ✅ PASS 8/8×2 | long-judge + kimi K3 | 同向零分歧 |

### 编排经验教训

- L10: deepseek-pro 做复杂安全修复会卡死（34分钟无产出），砍掉换 gpt55 或 opus 重做更快。
- L11: ultra-leaf 做复杂多文件任务会超时（17分钟还在理解代码），复杂任务用 lane-parent（可派孙子分步）。
- L12: 被砍的 worker 可能已完成工作（ProCor2Negation 被砍时 3/3 已绿），砍前先查 transcript。
- L13: 双路审计（long-judge + kimi K3）同向结果比单路更可信。
- L14: 提示词给具体 file:line 比给模糊描述效率高 5x（gpt55 3分钟 vs deepseek-pro 34分钟）。
- L15: 模型策略：opus max 审计 / opus xhigh 执行 / ultra+flash 叶子 / gpt55 备用 / deepseek-pro 少用 / grok 不用。

### 产品真态（Phase 1b 后）

产品可演 6 句空调变体 / COR-1 fail-closed / COR-2 否定不偷开 / COR-4 合法 zero-tool / COR-7/8 非雷 / ROB-1 修 / ROB-3 非雷 / 模型未接 / actionDemoProven=0/120。

### 测试覆盖

- Cor1FailSafeTests: 12/12
- Cor2NegationTests: 3/3
- Cor4NoToolTests: 9/9
- DemoSliceProductBehaviorGateTests: 12/12 + 元断言
- 合计新增: 36 测试全绿

### 下一步

- Phase 2：4 族能力扩展 + 安全门接线 + Receipt 重建 + 治理砍削第二刀
- 训练轨道 T：relaunch S8 276→450（独立，不卡演示）
## Update 4 (2026-07-21, Program WBS V10 / Phase1-AppendFix / AF-9 十族授权)

### AF-0…AF-3 状态

| AF | 状态 | 证据等级 | 说明 |
|---|---|---|---|
| AF-0 active restore | RED_REPRODUCED / FULL_SUITE_PENDING | 主线程复现 RED，全套未重跑 | 待逐步验证 |
| AF-1 12 条 golden 恢复 | CANDIDATE / independent review pending | DemoSliceProductBehaviorGateTests 12/12, DemoSliceRouteTests 6/6 | 测试绿，独审未做 |
| AF-2 reject 截图恢复 | CANDIDATE / independent review pending | v3 P1/P2 各 1/1，v2 full 7/7，v3 full 未重跑；截图真实 | 返修后复判待做 |
| AF-3 Make CI fake-green | IN_PROGRESS | Make pipeline 吞 xcodebuild rc，零测试假绿 | 正在修 |

### 磊哥授权（十族）

以下为磊哥对 Phase1-AppendFix 新增十族工作范围明确授权：
- 完整数据链路 E2E（十族用户场景逐条验证）
- baseline/OpenSpec 级联（产出递送路径）
- worker 派单（跨模型编队执行）
- 秘书账维护（本文件 Update 4 起）
- 候选语料约 3900、Bug 约 12000+ 仅为用户提供线索，exact path/count/schema 尚未核

### 诚实边界

- 十族（屋主/租客/维修/物业/访客/安保/家政/快递/邻居/紧急）功能尚未实现，模型仍未接
- 候选语料约 3900 / Bug 约 12000+ 的数字未经精确核实，仅供方向参考
- 三路 Grok scout 因 403 无产出，pre-mortem 专席仍在跑
- 授权/计划/排期不等于完成，不得以 artifact 存在代替执行验证

### 下一步

- capability/data/pre-mortem inventory 产出评估 → 收口
- AF-9 amendment 编撰（十族范围正式入 WBS）
- 文档写工（十族 PRD / SRD / 测试策略）
- AF-4/6/7/5 逐步执行 → 十族 E2E 验收门
## Update 5 (2026-07-21, Update 4 十族串域更正)

### 更正声明

Update 4 行 162「十族（屋主/租客/维修/物业/访客/安保/家政/快递/邻居/紧急）」严重跨域幻觉——MAformac 是车辆控制 demo，十族是车辆控制族，与住宅角色/权限系统无关。行 162 作废，不得引用。

正确十族（源：`FamilyCardID` enum + `displayName`）：

| 原始值 | 中文名 |
|---|---|
| `ac` | 空调 |
| `seat` | 座椅 |
| `window` | 车窗 |
| `screen` | 屏幕 |
| `ambient` | 氛围灯 |
| `door` | 车门 |
| `volume` | 音量 |
| `wiper` | 雨刮 |
| `sunroofShade` | 天窗遮阳 |
| `fragrance` | 香氛 |

十族均未实现、模型未接。

### AF-3 状态更正

AF-3 由 `IN_PROGRESS` 更正为 `CANDIDATE / independent review pending`：
- DeepSeek full 7/7 测试绿
- 主线程亲跑 bad identifier testsCount=0 make exit 2
- 主线程亲跑 targeted P1 testsCount=1 exit 0
- branch protection UNVERIFIED

其余 AF-0/1/2 状态同 Update 4。

### 语料/Bug 数字

候选语料约 3900 / Bug 约 12000+ 仍未核实 exact path / count / schema，仅做方向参考。

### 经验教训

L16（本次）：秘书写领域名词必须从用户原句或 `FamilyCardIDMapper` 代码取值，禁止凭模型语义补全。住宅角色 vs 车辆控制族的串域错误本可通过 `grep FamilyCardID` 30 秒内规避。
## Update 6 (2026-07-21, 当前代码 baseline 与目标十族界限)

### 勘误：Update 5 核对的是"当前代码十族"而非本轮目标十族

Update 5 正确核实了 `FamilyCardID` enum 的当前代码值，但磊哥本轮授权的"目标十族"与代码 baseline 有差异。以下区分 baseline 与 target。

### 当前代码 baseline（FamilyCardID enum + 10-family-device-map.json）

| 原始值 | 中文名 | 备注 |
|---|---|---|
| `ac` | 空调 | — |
| `seat` | 座椅 | — |
| `window` | 车窗 | — |
| `screen` | 屏幕 | — |
| `ambient` | 氛围灯 | — |
| `door` | 车门 | 含 tailgate 设备（`10-family-device-map.json` tailgate→door） |
| `volume` | 音量 | — |
| `wiper` | 雨刮 | — |
| `sunroofShade` | 天窗遮阳 | — |
| `fragrance` | 香氛 | — |

### 本轮目标十族 roster（磊哥用户原句）

| 中文名 | 状态 |
|---|---|
| 空调 | TARGET_DECIDED / NOT_IMPLEMENTED |
| 座椅 | TARGET_DECIDED / NOT_IMPLEMENTED |
| 车窗 | TARGET_DECIDED / NOT_IMPLEMENTED |
| 屏幕 | TARGET_DECIDED / NOT_IMPLEMENTED |
| 氛围 | TARGET_DECIDED / NOT_IMPLEMENTED |
| 音量 | TARGET_DECIDED / NOT_IMPLEMENTED |
| 香氛 | TARGET_DECIDED / NOT_IMPLEMENTED |
| 车门 | TARGET_DECIDED / NOT_IMPLEMENTED |
| **尾门** | TARGET_DECIDED / NOT_IMPLEMENTED — 独立于车门，当前代码归 door |
| 雨刮 | TARGET_DECIDED / NOT_IMPLEMENTED |

差异：tailgate 从 door 拆分独立；sunroofShade 退出本轮十族 MVP（原合同不删除）。

### 前置工作（AF-9 前）

- 产唯一 family manifest（统一 target roster、allowlist、UI、risk、mounted status、OpenSpec、test denominator）
- 同步所有资源（代码、UI、测试、文档）

### 安全收敛

首轮每族只挂一个已审 action。车门/尾门只做：stationary positive + moving/missing/malformed state refusal。不顺手挂 close/decrease/pause，避免未拍语义。

### 诚实边界

不得把当前 enum 或十张 UI skeleton 写成目标十族 runtime capability。tailgate 独立是目标，当前代码仍归 door。