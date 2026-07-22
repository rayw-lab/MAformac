---
kind: current-router
as_of: 2026-07-22
authority: router_only
latest_handoff: docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md
working_tree_postdates_handoff: true
---
<!-- 产品行为是唯一阻塞指标；治理检查只证明治理健康，不替代真实用户路径。 -->

# CURRENT — MAformac 当前路由牌（router_only）

本文件只回答「现在先读什么、下一步是什么、不能自动做什么」。**不构成产品或执行授权**；任何 HEAD、remote、测试或 runtime 状态必须 live 重核。

## Live 真态（2026-07-22）

- **AF-G0=RED**；**Phase2=NO-GO**；**implementation=PAUSED**
- Ballot B07–B11 已于 2026-07-22 磊哥拍板（见 run-root `PHASE2-BALLOT-RATIFICATION-RECEIPT.md`）；**批准≠开工**
- live **mounted=5 / admission=5**；后三族（window / ambient / seat）为 **Phase2 越前 candidate**，不计完成度、**禁演示/合并**
- window 行驶安全门：**FA-4 CLOSED（本机）** — risk-policy + Lookup 已按 B07=B；**仍禁演示/合并**含开窗句的候选树
- **FA-1 CLOSED（本机）**：`make verify-e2e` 已恢复全类 golden + WP21；**≠ AF-G0 GO**，未 commit
- **FA-2 / FA-3 CLOSED（文档）**：CURRENT / demo-script / isolation assertions.**v3** 已对齐 candidate 口径与 FA-1/FA-4 code closed
- **FA-4 CLOSED（本机代码+bundle regen）**：`risk-policy` + Lookup B07=B + `DemoRuntimeContractBundle.generated.swift` 已含 window 规则；**仍禁演示**
- **`actionDemoProven=0/120`**；ASR / TTS 不进当前产品门
- 验收面：`文本 → route → C3 → state mutation → readback payload → UI`

## 起手路由

1. 读 `CLAUDE.md` 的稳定约束。
2. 读本页 frontmatter 指向的最新 handoff。
3. 读 handoff 指向的冻结 WBS 与审计证据；需要当前状态时，从工作树和真实运行入口重新测量。

## 下一步（pre-G0；非 AF-G0 GO）

1. **P0-a（修 CI）**：`5d532b29` 修了 handoff 链；下一跳补 CG-080 baseline + matrix rematerialize（mounted=5 与 D123 32/82/1/5 对齐，`actionDemoProven` 仍 0/120）。禁装入「三族可演示」叙事。
2. release-only：UI-E2E workflow 已随 push 触发（尚未 required）；C5 env、E3 人类证据另账。
3. 阶段收口审计对本波 FA-1..4 判 **PASS_WITH_FIXES**；权威级联已补；仍 **AF-G0=RED / PAUSED** 直至 `verify` 绿 + 明确裁决。
4. 任何阶段切换、发布或范围变更都使用最新 handoff 的 stopline；**不得因 Ballot/FA 闭合而自动解冻 Phase2 实施**。

## 隔离后产品真态（candidate 口径 · 2026-07-22 live 验）

### 全局标签

- 工作树 **不是**「隔离后的两工具空调版」；它是 **5 mounted / 5 admission 的 candidate 树**。
- 空调两族（matrix 1、4）属于 Phase1 产品面；车窗 / 氛围灯 / 座椅三族（matrix 31、1972、201）属于 **Phase2 越前 candidate**——仅作审计与计划输入，**不计完成度、禁演示、禁合并、禁计入 `actionDemoProven`**。

### mounted tools（5）

1. `adjust_ac_temperature_to_number` — 空调调温（Phase1 产品面）
2. `close_ac` — 空调关机（Phase1 产品面）
3. `open_window_by_number` — 主驾车窗（**candidate · 禁演示**）
4. `open_atmosphere_lamp` — 氛围灯（**candidate · 禁演示**）
5. `open_seat_heat` — 副驾座椅加热（**candidate · 禁演示**）

### admission / literal catalog（matrix=[1,4,31,1972,201]）

| matrixID | 族 | 状态 |
|---:|---|---|
| 1 | 空调开机 | Phase1 产品面 |
| 4 | 空调调温（18–32 整数模板；含 exact `能调到{N}度吗`） | Phase1 产品面 |
| 31 | 主驾车窗 | **candidate · 禁演示** |
| 1972 | 氛围灯 | **candidate · 禁演示** |
| 201 | 副驾座椅加热 | **candidate · 禁演示** |

### 仍不具备 / 未闭

- App 客户文本入口走 `DemoSliceRoute` 有限 literal 路径；**模型输出未接入产品执行链**。
- **`actionDemoProven=0/120`**；十族扩张、尾门、多意图均未准入产品完成度。
- ASR 仍为 stub；TTS / 真实音频 **不进当前产品门**。
- **window 行驶安全门：代码已闭（FA-4 / B07=B）**，含 `risk-policy` window 规则 + Lookup gear 闸 + 生成 bundle 已 regen；**仍禁演示/合并开窗句**，不等于产品发布或 AF-G0 GO。
- E3 磊哥亲灌句 / 录像与远端 required UI-E2E context 仍是发布门，不是已完成事实。
- **P0-a 未闭**：required 远端 `verify` 仍红；未授权 commit/push。
## 不能自动做什么

- 禁止 mock、推送远端、发布、改旧 receipt 或自行改写冻结 WBS。
- 禁止把 worker 自报、测试数量或治理绿灯当作产品验收。
- 禁止修改 `CLAUDE.md`、`docs/lessons-learned.md`、`docs/project/collaboration-and-roles.md`、`docs/commander-log/COMMANDER-PLAYBOOK-ma10-ma18-for-codex.md`。
- 禁止从本页、历史 handoff 或 agent 文本恢复会变化的运行状态；必须 live 重核。
- 禁止演示或合并后三族 candidate；禁止把 Ballot 已拍写成 AF-G0 GO 或 Phase2 可开工。

## Non-claims

- 本页不声称 AF-G0 GO、Phase2 可开工、候选已验收、训练完成、模型已接入、真车可用或产品已发布。
- 本页不授予 promotion、阶段跳转或远端写入权限。
