---
kind: af-g0-go-phase2-g0-entry-handoff
project: MAformac
as_of: 2026-07-22
predecessor: docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md
supersedes:
  - docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md
  - docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.receipt.json
supersedes_claim: "AF-G0=RED / Phase2=NO-GO / implementation=PAUSED 的权威路由口径（人审冻结 handoff 仍可作历史 provenance，不得再当 live verdict）"
handoff_status: ACTIVE
product_status: NOT_RELEASE_READY
af_g0_verdict: GO_WITH_RESIDUALS
af_g0_status: GO_WITH_RESIDUALS
phase2_status: CONDITIONAL
phase2_product_coding: G0_INVENTORY_AUTHORIZED
phase2_coding_gate: PHASE2_CODING_GATED
subject: tip 769ce3c3 + 2026-07-22 live probes only
proof_class_ceiling: remote_github_actions_verify_success_plus_local_makefile_recipe_and_anti_placebo
go_receipt: docs/handoffs/2026-07-22-af-g0-go-receipt.md
owner_authorization: 磊哥口头 AF-G0 翻门 +「多路开干」= 仅 G0 只读 inventory；AF-G0 alone 不授权 Phase2 产品编码
independent_audit: AF-G0_GO_WITH_RESIDUALS
---

# AF-G0 `GO_WITH_RESIDUALS` → Phase2 G0 inventory 入口 Handoff

> 本文件 **supersede** 旧 RED 口径：`docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md` 中的 **AF-G0=RED / Phase2=NO-GO / implementation=PAUSED**。
>
> 旧 handoff 仍保留为 Grill 冻结 / Ballot / BF 登记 provenance，**不得再当 live 阶段裁决**。
>
> 措辞天花板：`AF-G0_GO_WITH_RESIDUALS`。**禁止**裸写 `AF-G0 GO` / `Phase2 GO` / `UNPAUSED_FOR_G0` / 仅凭 AF-G0 写 `implementation unpaused`。

## 0. 当前真态（权威）

1. **`af_g0_verdict: GO_WITH_RESIDUALS`**（owner=磊哥；独立审计同口径；证据见 `docs/handoffs/2026-07-22-af-g0-go-receipt.md`）。subject = tip **`769ce3c3`** + 当日 live probes。
2. **Phase2 = CONDITIONAL**：pre-G0 硬门（BF-1/2/4/5/9 + Ballot）已闭；产品实施 **不是** 无条件全开。
3. **`phase2_product_coding: G0_INVENTORY_AUTHORIZED`**；**`PHASE2_CODING_GATED`**：AF-G0 本裁决 **alone 不授权** Phase2 产品编码。磊哥「多路开干」仅覆盖 G0 只读 inventory（仓外 run-root 已落；异源抽核另路）。G1+ 产品改码仍须对照冻结 plan，且不得演示 / 抬 proven。
4. live HEAD：`769ce3c3`；remote Verify **success**（https://github.com/rayw-lab/MAformac/actions/runs/29919618354）。旧 P0-a 陈旧红句已修正。
5. live **mounted=5 / admission=5**；后三族（window / ambient / seat）仍是 **Phase2 越前 candidate**。
6. **`actionDemoProven=0/120`**；`GO_WITH_RESIDUALS` ≠ 三族可演示。
7. **FA-4 只证 window 本机门**；仍禁演示/合并开窗句与后三族。
8. 验收面不变：`文本 → route → C3 → state mutation → readback payload → UI`；ASR/TTS 不进产品门。

## 1. 已闭 / 残留

### 已闭（支撑 `AF-G0_GO_WITH_RESIDUALS`）

- BF-1 remote Verify green @ `769ce3c3`（旧 P0-a 陈旧句已修正）
- BF-2 / FA-1：`make verify-e2e` = 全类 `DemoSliceProductBehaviorGateTests` + WP21 filters + anti-placebo lock（本机 anti-placebo PASS）
- FA-2 / FA-3：文档 candidate 口径、isolation assertions.v3
- FA-4 / BF-4：window risk-policy+Lookup B07=B **本机门**（仍禁演示/合并开窗句与后三族）
- Ballot B07–B11 RATIFIED（run-root `PHASE2-BALLOT-RATIFICATION-RECEIPT.md`）

### Residual 强制清单（诚实账；不阻断 G0 inventory）

- **BF-3**：candidate 冻结继续——禁演示、禁合并、禁计入 proven
- **BF-6**：UI-E2E 同 SHA **cancelled**；未 required
- **BF-7**：C5 / full suite / `verify-ci` 全绿未证（不外推未跑 suite）
- **BF-8**：E3 人类亲验未闭
- **BF-10**：protected dirty 仍在；**勿 commit**；未授权不得动
- **`actionDemoProven=0/120`**

## 2. Phase2 路下一步（唯一入口）

```text
G0 inventory（只读 live 锚 + 异源抽核）  ← G0_INVENTORY_AUTHORIZED
  → G1+ 产品改码仍 PHASE2_CODING_GATED：须对照冻结 plan；禁演示/抬 proven
```

冻结计划仍在 run-root：

- `PROGRAM-WBS-V10-PHASE2-WP2-1-IMPLEMENTATION-PLAN.md`
- `PHASE2-GRILL-REDUCTION-MATRIX.md`
- `PHASE2-GRILL-10-ROUND-DECISION-LEDGER.md`

## 3. Stopline（命中即停写并上抛）

- 演示或合并后三族 candidate；把 candidate 写入 `actionDemoProven` 或对外「已验收」。
- 无证据把 residual BF-3/6/7/8/10 写成已闭；外推未跑 full suite。
- 仅凭 AF-G0 开 G1+ 产品改码，或把本裁决写成全面「implementation unpaused」。
- 同 wave 多人写 shared files（`ContractLookups.swift`、`C3ExecutionPipeline.swift`、`DemoRuntimeSessionRunner.swift`、`ContentView.swift`、Makefile/scripts 等）。
- `git reset` / `checkout --` / `stash` / 整包恢复 quarantine。
- 修改 / commit protected：`CLAUDE.md`、`docs/lessons-learned.md`、`docs/project/collaboration-and-roles.md`、`docs/commander-log/COMMANDER-PLAYBOOK-ma10-ma18-for-codex.md`。
- 把本裁决冒充 release-ready / 真车可用 / 模型已接入 / Phase2 GO。

## 4. Non-claims

- 不声称 Phase2 G1–G9 已完成或可跳步。
- 不声称三族可演示、可合并或 proven>0。
- 不声称 UI-E2E required、full suite 绿、人类亲验完成。
- 不声称 AF-G0 alone 授权 Phase2 产品编码。
- 不授予 push / 改 branch protection / 公开发布权限（除非磊哥另授）。

## 5. 给 Phase2 路的一句话入口

**`AF-G0_GO_WITH_RESIDUALS`；仅 `G0_INVENTORY_AUTHORIZED`，`PHASE2_CODING_GATED`；禁演示后三族、禁抬 proven；residual BF-3/6/7/8/10 另账；勿 commit protected dirty。**
