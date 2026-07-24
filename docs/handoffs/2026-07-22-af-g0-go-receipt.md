---
kind: af-g0-go-receipt
project: MAformac
as_of: 2026-07-22T21:15:24+08:00
head_commit: 769ce3c3d9e4b7fd2fcde3440b1f226d71efd1cc
branch: opt/streamline-macos-20260707
owner: 磊哥
authorization: AF-G0 翻门 +「多路开干」（口头，2026-07-22）；仅 G0 只读 inventory
af_g0_verdict: GO_WITH_RESIDUALS
phase2_product_coding: G0_INVENTORY_AUTHORIZED
phase2_coding_gate: PHASE2_CODING_GATED
subject: tip 769ce3c3 + 2026-07-22 live probes only
proof_class_ceiling: remote_github_actions_verify_success_plus_local_makefile_recipe_and_anti_placebo
predecessor_red_handoff: docs/handoffs/2026-07-22-phase2-grill-freeze-human-review-handoff.md
ballot_receipt: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/PHASE2-BALLOT-RATIFICATION-RECEIPT.md
independent_audit: AF-G0_GO_WITH_RESIDUALS
---

# AF-G0 Receipt — `GO_WITH_RESIDUALS`

## 1. Verdict

**`af_g0_verdict: GO_WITH_RESIDUALS`**（owner=磊哥口头授权翻门；独立审计确认同口径）。

本 receipt **只**关闭 AF-G0 合取门与权威路由翻盘到上述天花板；**不写** Phase2 产品代码。subject 精确到 tip **`769ce3c3`** + 当日 live probes；**不**外推 protected dirty 清理结论，也**不**声称未跑的 full suite 已绿。

本裁决 **alone 不授权** Phase2 产品编码。磊哥另说「多路开干」时，文档区分：

| 字段 | 值 | 含义 |
|---|---|---|
| `af_g0_verdict` | `GO_WITH_RESIDUALS` | AF-G0 门翻到带 residual 的 GO |
| `phase2_product_coding` | `G0_INVENTORY_AUTHORIZED` | 仅授权 G0 只读 inventory（仓外 run-root 产物已有；异源抽核另路） |
| `phase2_coding_gate` | `PHASE2_CODING_GATED` | G1+ 产品改码仍须对照冻结 plan；禁演示 / 抬 proven |

**禁止**裸写 `AF-G0 GO` / `Phase2 GO` / 仅凭 AF-G0 写 `implementation unpaused`。

本 verdict **不等于**：

- 三族可演示 / 可合并；
- `actionDemoProven` 翻格；
- Phase2 全阶段放行或 release-ready；
- full suite / UI-E2E required / 人类亲验已闭；
- Phase2 产品编码全面解冻。

## 2. Live evidence matrix（本机 2026-07-22 重核；subject=`769ce3c3`）

| ID | 断言 | 命令 / 路径 | 结果摘要 | 状态 |
|---|---|---|---|---|
| BF-1 | required remote Verify @ tip | `gh run view 29919618354`；`gh api .../commits/769ce3c3/check-runs` | Verify `conclusion=success`；check-run `verify=success`；run URL https://github.com/rayw-lab/MAformac/actions/runs/29919618354。旧 P0-a「仍红」陈旧句已由本 tip 绿核修正 | **CLOSED** |
| BF-2 / FA-1 | `make verify-e2e` 恢复全类 golden + WP21 | 读 `Makefile:49-64`；`python3 scripts/verify_anti_placebo.py` | recipe=`verify-e2e-product-behavior`（全类 `DemoSliceProductBehaviorGateTests`）+ 三 WP21 filter + anti-placebo；anti-placebo **PASS**（exit 0；sha256 `48cce601486a69f19d65a80ab4fcc70606fc6c98643a9867f8b839eebd688a00` @ `/tmp/af-g0-go-evidence/anti-placebo.txt`） | **CLOSED** |
| FA-2 / BF-5 | CURRENT / demo-script candidate 口径 | `docs/CURRENT.md`；`docs/governance/demo-script-v1.md`；secretary Update 19 | 后三族禁演示/合并/计完成度已级联 | **CLOSED** |
| FA-3 / BF-9 | isolation assertions live 对账 | run-root `isolation/.../post-isolation-negative-assertions.v3.json` | supersedes v2；mounted=5 / matrix=[1,4,31,1972,201]；candidate 禁演示 | **CLOSED** |
| FA-4 / BF-4 | window 行驶安全门（B07=B）**仅本机门** | `contracts/risk-policy.yaml` `window_open_while_moving_or_unsafe_gear`；`Core/Contracts/ContractLookups.swift` `RiskPolicyLookup` gear 闸；commit `3df7c629` | speed>0 refuse；speed=0 仅 P/N。**FA-4 只证本机门**；仍 **禁演示/合并开窗句与后三族** | **CLOSED（本机门）** |
| Ballot B07–B11 | owner 拍板 | run-root `PHASE2-BALLOT-RATIFICATION-RECEIPT.md` | B07=B / B08=B / B09=B / B10=A / B11=A + WP2-4c supersession；批准≠产品编码开工 | **RATIFIED** |
| Proven | canonical 完成度 | `python3` 统计 `contracts/demo-capability-matrix.json` | **`actionDemoProven=0/120`**（true=0 / false=120） | **仍 0/120** |

辅助锚：

- live HEAD：`769ce3c3d9e4b7fd2fcde3440b1f226d71efd1cc`
- branch：`opt/streamline-macos-20260707`
- FA-1..4 合入提交：`3df7c629`（message: close FA-1..4 pre-G0 gates without unpausing Phase2）
- mounted/admission live：5 / 5；matrix `[1,4,31,1972,201]`（`DDomainMountedToolCatalog.swift` / `DemoSliceAdmissionCatalog.swift`）
- G0 inventory：仓外 run-root 已落；异源抽核另路进行中

## 3. Closed vs residual BFs

### Closed for `AF-G0_GO_WITH_RESIDUALS`

| BF | 关闭说明 |
|---|---|
| BF-1 | remote required `verify` success @ `769ce3c3`（旧 P0-a 陈旧红句已修正） |
| BF-2 | 稳定门 recipe 已恢复全类 + WP21，anti-placebo 锁 recipe |
| BF-4 | window risk-policy + Lookup B07=B **本机门**已落地（仍禁演示/合并开窗句与后三族） |
| BF-5 | 文档 candidate 口径已对齐 |
| BF-9 | isolation assertions.v3 对账 live candidate |

### Residual 强制清单（不阻断本裁决；必须诚实披露）

| BF / 项 | Residual |
|---|---|
| BF-3 | 后三族仍是越前 candidate：**冻结纪律继续**；禁演示/合并/计入 proven |
| BF-6 | 独立 UI-E2E workflow 在同 SHA 上为 **cancelled**（run `29919618353`）；**未**成为 required context；release 另账 |
| BF-7 | C5 Python 依赖 / full Swift suite / `verify-ci` 全绿 **未**由本 receipt 证明（subject 不外推未跑 suite） |
| BF-8 | E3 / WP0-7 / M0 人类亲灌句与录像 **未**闭 |
| BF-10 | protected dirty 仍在：`M CLAUDE.md`、`M docs/lessons-learned.md`、`M docs/project/collaboration-and-roles.md`、`?? docs/commander-log/COMMANDER-PLAYBOOK-ma10-ma18-for-codex.md`；**勿 commit**；未授权不得清理/入权威 |
| proven | **`actionDemoProven=0/120`** |
| 旧 P0-a | tip `769ce3c3` Verify 已绿；旧「仍红」陈旧句已修正，不得再当 live |

## 4. Owner / orchestration notes

- **AF-G0 翻门**：磊哥口头授权 → `af_g0_verdict: GO_WITH_RESIDUALS`。
- **「多路开干」**：仅覆盖 **`G0_INVENTORY_AUTHORIZED`**（只读 inventory / 编排入口）；**不是** G1+ 产品改码自动开工，**不是**演示放行，**不是**全面解冻。
- **`PHASE2_CODING_GATED`**：相对旧 RED handoff，权威路由已离开绝对 `PAUSED`；但产品编码仍 gated——G1+ 须对照冻结 plan DAG 与 shared-file owner 纪律。
- 保护文件仍脏：**本 lane 与任何自动流程都勿 commit 它们**。

## 5. Non-claims

- 不声称后三族可演示、可合并或可计入 `actionDemoProven`。
- 不声称 ASR/TTS/真实音频/真车/真机/模型已接入产品执行链。
- 不声称 full `swift test` / `make verify-ci` 全绿（未跑则不外推）。
- 不声称远端 UI-E2E required 或 green（当前同 SHA 为 cancelled）。
- 不声称 E3 人类证据或 release-ready。
- 不声称本 receipt 已自动 push / 已修改 protected 路径。
- 不把 Ballot 已拍、FA 闭合或治理绿灯冒充产品验收。
- 不声称 AF-G0  alone 授权 Phase2 产品编码或「implementation unpaused」。

## 6. Next

1. 权威路由：`docs/CURRENT.md` + handoff `docs/handoffs/2026-07-22-af-g0-go-phase2-g0-entry-handoff.md`。
2. Phase2 路仅从 **G0 inventory（只读锚）** 起手；命中 stopline 立即停写。G1+ 产品改码另对照 plan。
3. residual BF-3/6/7/8/10 + proven=0/120 保持独立账，不混入 G0 完成定义。
