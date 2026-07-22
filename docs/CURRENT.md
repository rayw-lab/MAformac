---
kind: current-router
as_of: 2026-07-23
authority: router_only
latest_handoff: docs/handoffs/2026-07-22-af-g0-go-phase2-g0-entry-handoff.md
go_receipt: docs/handoffs/2026-07-22-af-g0-go-receipt.md
working_tree_postdates_handoff: false
af_g0_verdict: GO_WITH_RESIDUALS
phase2_product_coding: G3_COMPLETE
phase2_coding_gate: PHASE2_CODING_GATED
g0_status: G0_COMPLETE
g1_status: G1_FIRST_KNIFE_GREEN
g2_status: G2_RESIDUAL_GREEN
g3_status: G3_COMPLETE
---
<!-- 产品行为是唯一阻塞指标；治理检查只证明治理健康，不替代真实用户路径。 -->

# CURRENT — MAformac 当前路由牌（router_only）

本文件只回答「现在先读什么、下一步是什么、不能自动做什么」。**不构成产品或执行授权**；任何 HEAD、remote、测试或 runtime 状态必须 live 重核。

## Live 真态（2026-07-23）

- **`af_g0_verdict: GO_WITH_RESIDUALS`**（owner=磊哥口头授权翻门 +「多路开干」；证据 `docs/handoffs/2026-07-22-af-g0-go-receipt.md`）。subject 精确到 tip **`769ce3c3`** + 当日 live probes；**不**外推 protected dirty 清理或未跑 full suite。
- **G0 inventory COMPLETE**；**G1 首刀 GREEN**（`abfe715a`）→ **G2 首刀 + 余量 GREEN**（`f7599b5c` / `745f1c5b`）→ **G2-P3 °F 客户入口 GREEN** → **G3 COMPLETE**（刀1 fresh-risk `4f38ab14` → 刀2 window CUR `15c6476a` → 刀3 row167 compound `f37e0397` → 刀4 四族行为门+smoke；未抬 proven）。仍 **`PHASE2_CODING_GATED`**：非全面解冻；禁演示 / 抬 proven。
- 已知 Verify 绿 SHA：**`769ce3c3`**（https://github.com/rayw-lab/MAformac/actions/runs/29919618354）
- Ballot B07–B11 已拍（run-root `PHASE2-BALLOT-RATIFICATION-RECEIPT.md`）
- FA-1..3 已闭：`make verify-e2e`=全类 golden+WP21；CURRENT/demo-script/isolation.v3 对齐。**FA-4 只证 window 本机安全门**（B07=B）；仍 **禁演示/合并开窗句与后三族**
- live **mounted=5 / admission=6**（+row167 `主驾制热调{N}{unit}`）；后三族（window / ambient / seat）仍为 **Phase2 越前 candidate**——**禁演示/合并/计入 proven**
- **`actionDemoProven=0/120`**；`GO_WITH_RESIDUALS` ≠ 三族可演示
- 验收面：`文本 → route → C3 → state mutation → readback payload → UI`；ASR / TTS 不进当前产品门

## 起手路由

1. 读 `CLAUDE.md` 的稳定约束。
2. 读本页 frontmatter 指向的最新 handoff + GO receipt。
3. 需要状态时 live 重核 Git / remote Verify / Makefile recipe / matrix proven。

## 下一步（Phase2 G4）

1. **G3 工程四子块本地 COMPLETE** 后：下一波 **G4 Turn Lease / cancel / last-intent-wins**（释放 C3 独占写锁；禁与 G3 同 commit 抢做）。
2. 严格遵守 shared-file 串行 owner；candidate 家族零演示、零合并、零翻 `actionDemoProven`。
3. residual 强制账（不因 G3 收口消失）：BF-3 candidate 冻结；BF-6 UI-E2E cancelled+未 required；BF-7 C5/full suite；BF-8 人类亲验；BF-10 protected dirty；`actionDemoProven=0/120`。

## 隔离后产品真态（candidate 口径）

### 全局标签

- 工作树是 **5 mounted / 6 admission**（+row167 `主驾制热调{N}{unit}`；仍含三族 candidate）。
- 空调两族（matrix 1、4）= Phase1 产品面；车窗 / 氛围灯 / 座椅（31、1972、201）= **Phase2 越前 candidate**；row167 为空调 compound 客户入口（G2 余量，禁抬 proven）。

### mounted tools（5）

1. `adjust_ac_temperature_to_number` — 空调调温（Phase1）
2. `close_ac` — 空调关机（Phase1）
3. `open_window_by_number` — 主驾车窗（**candidate · 禁演示**）
4. `open_atmosphere_lamp` — 氛围灯（**candidate · 禁演示**）
5. `open_seat_heat` — 副驾座椅加热（**candidate · 禁演示**）

> 注：admission（6）= 上述 5 个 mounted tools + 1 个准入入口 row167（空调制热/微调复合入口 `主驾制热调{N}{unit}`，底层挂载至 `adjust_ac_temperature_to_number` 帧，禁抬 proven）。

### 仍不具备 / 未闭

- App 客户文本入口仍走有限 literal；**模型输出未接入产品执行链**。
- **`actionDemoProven=0/120`**
- ASR=stub；TTS/真实音频 **不进当前产品门**
- window 安全门代码已闭（FA-4 本机门），**仍禁演示/合并开窗句与后三族**
- UI-E2E 未 required（同 SHA cancelled）；E3 人类证据未闭；C5/full suite 另账
- protected dirty 仍在：**勿 commit** 四路径；未授权不得清理

## 不能自动做什么

- 禁止 mock 成功、擅自 push、发布、改旧 receipt 或改写冻结 WBS 而不做显式 supersession。
- 禁止把 worker 自报、测试数量或治理绿灯当作产品验收。
- 禁止修改 / commit protected：`CLAUDE.md`、`docs/lessons-learned.md`、`docs/project/collaboration-and-roles.md`、`docs/commander-log/COMMANDER-PLAYBOOK-ma10-ma18-for-codex.md`。
- 禁止演示或合并后三族 candidate；禁止把 candidate 计入 `actionDemoProven`。
- 禁止把 `AF-G0_GO_WITH_RESIDUALS` 外推为 release-ready / 真车可用 / 三族可演 / Phase2 产品编码全面解冻。
- 禁止仅凭 AF-G0 裁决写「implementation unpaused」或把 G1/G2 首刀外推为 G1–G9 全面解冻。

## Non-claims

- 本页不声称三族可演示、proven>0、模型已接入、真车可用、UI-E2E required 绿、full suite 绿或产品已发布。
- 本页不授予 promotion、公开发布或破坏性 git 权限。
- 本页不声称 AF-G0 alone 已全面解冻 Phase2；G0 COMPLETE 解锁对照冻结 plan 的切片编码（仍 `PHASE2_CODING_GATED`）。
