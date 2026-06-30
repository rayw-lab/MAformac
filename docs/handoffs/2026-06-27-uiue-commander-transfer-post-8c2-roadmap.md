---
status: active_handoff_for_new_commander
artifact_kind: commander_handoff
date: 2026-06-27
handoff_owner: Codex commander
target_new_commander_thread: 019f0785-45ee-7012-a5eb-a7ef606ae607
worktree: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
head_at_handoff_probe: 2a3866b
proof_class: local_docs_jsonl_review
language_policy: Chinese by default; keep code/path/API/protocol names as-is.
non_claims:
  - no V-PASS
  - no mobile proof
  - no true-device proof
  - no runtime readiness
  - no voice readiness
  - no A-2 complete
---

# Handoff 2026-06-27 - UIUE 新指挥官授衔交接

> 新指挥官起手不要凭本文件直接继续写代码。先按“起手读链”和“当前活跃线程”重新核 live truth。本文是压缩多轮上下文后的总交接，目的是防止把 8.G 已完成、8.C2 仍 open、roadmap 候选项、Liquid4All 参考和主线 runtime 混成一件事。

## 0. 起手读链

在 `/Users/wanglei/workspace/MAformac-uiue` 先读：

1. `AGENTS.md`
2. `CLAUDE.md`
3. `docs/CURRENT.md`
4. `docs/README.md`
5. 本文件：`docs/handoffs/2026-06-27-uiue-commander-transfer-post-8c2-roadmap.md`
6. 当前路线图基线：`docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`
7. 8.C2 证据包：`docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/README.md`
8. 8.C2 L3 人审记录：`docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l3/human-5gate-verdict.md`
9. OpenSpec tasks：`openspec/changes/ui-presentation/tasks.md`，重点 `8.C2` 和 `8.G`

起手命令：

```bash
cd /Users/wanglei/workspace/MAformac-uiue
pwd
git status --short --branch
git rev-parse --short HEAD
git log --oneline --decorate -35
```

## 1. 总体结论

当前 UIUE 状态是：8.G 已完成，8.C2 仍 open，A-2 仍 PARTIAL，下一步正在由线程 `019f077d-f74d-77c3-89e4-292339d065a9` 执行“8.C2 返修 + 脏区处理收口”。新指挥官第一优先级不是开新功能，而是接管这个活跃返修线程的 verdict，核验它是否真实收口、是否 commit、是否仍保持 `8.C2` open。

路线顺序已经在 `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md` 固化：

1. R0：收当前 8.C2 返修。
2. R1：UIUE Interaction Integrity Hardening，需 grill。
3. R2：重跑 8.C2 L0-L3。
4. R3：只有磊哥 L3 签 `V-PASS` 后才可关闭 8.C2 并做文档级联。
5. R4：UIUE 和主线 bridge contract intersection。
6. R5：runtime / voice / model 分线。

这条路线不是实现计划，不是 OpenSpec SHALL，不是 V-PASS。所有标 `【SHOULD_GRILL】` 的点都必须先 grill / pre-mortem / 决策存档，再进入实现。

## 2. 当前 live truth 快照

本交接前 probe 到：

- worktree：`/Users/wanglei/workspace/MAformac-uiue`
- branch：`uiue/phase4-default-scope-presentation`
- HEAD：`2a3866b`，commit message `test(uiue): add 8c2 visual acceptance evidence package`
- branch ahead：相对 origin ahead 52
- 当前 tracked dirty 包含两类：
  - 8.C2 返修 dirty：`App/`、`Core/`、`Tests/`、`MAformacIOSUITests/`、8.C2 evidence docs。
  - commander 文档 dirty：`docs/CURRENT.md`、`docs/README.md`、`docs/uiue-roadmap-2026-06-23.md`、新增 `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`、新增本 handoff。
- 当前 untracked 包含旧 visual evidence dirs 和计划文档：
  - `docs/research/2026-06-25-a2-execution/visual-diff-v45/`
  - `docs/research/2026-06-25-a2-execution/zone-compare-main-stage-v1/`
  - `docs/research/2026-06-25-a2-execution/zone-compare-phase6-capsule/...`
  - `docs/research/2026-06-25-a2-execution/zone-compare-phase6-route-spike/...`
  - `docs/research/2026-06-26-ios2026-frontend-trends-migration/`
  - `docs/superpowers/plans/2026-06-27-uiue-8c2-l0-l3-visual-acceptance.md`

不要使用 `git add .`。新指挥官必须先重新分类 dirty，不要把不同归属的文件混进同一个 commit。

## 3. 已提交里程碑

最近关键 commit ledger：

| commit | 含义 |
|---|---|
| `2a3866b` | `test(uiue): add 8c2 visual acceptance evidence package`，生成 8.C2 L0/L1/L2 证据包，但 L3 仍 partial |
| `aef42d8` | `docs(uiue): close 8g9 provenance ledger` |
| `780447c` | `test(uiue): close 8g9b xcuitest l0 harness` |
| `4401f79` | `test(uiue): close 8g9a contracts and hardening` |
| `72328d6` | `docs(uiue): 刷新视觉门8G落地状态` |
| `2959cab` | `feat(uiue): 补齐Reduce Motion静态降级` |
| `b53ae84` | `test(uiue): close ui value type and hvac debt` |
| `6a1b975` | `test(uiue): add visual evidence kind matrix` |
| `38c4931` | `test(uiue): add runtime result VUI matrix` |
| `04f6b84` | `chore(uiue): close visual proof gates and l1 sentinel` |
| `3fb276e` | `docs(uiue): harden heavy-work visual stop rule` |
| `d750314` | 8.G 接手前 handoff 和 lessons |
| `d535b7b` | U32-U37 视觉门 grill 收口 + 3 合一 change artifact |

## 4. 8.G 状态

`openspec/changes/ui-presentation/tasks.md` 当前显示 8.G 全部已勾：

- `8.G1`：L0-L3 视觉门定义落 spec。
- `8.G2`：8 态 VUI 矩阵测试。
- `8.G3`：heavy-work stop rule / proof-class / on-screen simctl 纪律回写。
- `8.G4`：`phase2_zone_compare.py` 从 RMSE 分数导向改为 PASS/WARN/FAIL sentinel。
- `8.G5`：ContentView Grid 固定列，已存在，跳过。
- `8.G6`：`ui_value_type` 消费侧派生 + 清 active `hvac.*`。
- `8.G7`：`VisualEvidenceKind` + 代表族 evidence matrix。
- `8.G8`：Reduce Motion 静态降级。
- `8.G9a`：U14/U15/U16/U18/U44 local/unit hardening。
- `8.G9b`：U17 UI test target + 最小 XCUITest + on-screen simctl L0 harness。

重要边界：8.G 完成只说明 hardening 和局部 L0 smoke 关闭，不关闭 `8.C2`，不声明 L3/V-PASS。

## 5. 8.C2 当前状态

8.C2 证据包在 `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/`。

已知状态：

- verdict：`PARTIAL_PENDING_L3`
- L0：on-screen `xcrun simctl io booted screenshot`，已生成 5 个 case。
- L1：2 PASS + 3 WARN + 0 FAIL，sentinel only。
- L2：OCR + contrast hard gate PASS；SSIM 是 evidence，不是审美裁判。
- L3：磊哥人工发现阻断问题，不能签 V-PASS。

L3 发现包括：

- `cooling + ivory` 视觉与交互 blocker。
- 空调渐变语义不足。
- 玻璃质感不足。
- 氛围灯 8 色选择崩溃。
- 空调模式点击制热后外层仍蓝色。
- badge / toggle / options 存在假 affordance 或 contract 外值风险。
- 直接触摸档位调节问题需要进一步确认：若当前返修线程已实现，必须有 action/writeback/readback proof；若未实现，列入后续 `SHOULD_GRILL` 的 Interaction Integrity 项，不能假装已完成。

8.C2 必须保持 open，直到磊哥重新 L3 5-gate 签核。机器和 Codex 都不能签 `V-PASS`。

## 6. 活跃委派线程

当前活跃线程：

- `019f077d-f74d-77c3-89e4-292339d065a9`
- 任务：冷启动执行 UIUE 8.C2 返修 + 脏区处理收口。
- 派单规则：不写单独计划文件，提示词就是计划；修完后安排 subagent Codex 审计；修复 findings 后 commit。
- jsonl：`/Users/wanglei/.codex/sessions/2026/06/27/rollout-2026-06-27T13-12-03-019f077d-f74d-77c3-89e4-292339d065a9.jsonl`

截至本 handoff 更新，线程 `019f077d` 还没回写最终 verdict。它已经跑过：

- 目标过滤单测。
- `swift test`，日志显示 308 tests / 3 skipped / 0 failures。
- `make verify-all`，日志显示 exit 0。
- `openspec validate ui-presentation --strict`，日志显示 valid。
- `xcodebuild test ... MAformacIOSUITests/UIC2VisualAcceptanceUITests`，日志显示 PASS，8 tests / 0 failures。
- `git diff --check`，重跑通过。

它还做了两个重要补记：

- `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/README.md`：补上整组 UI test 8/0、8.C2 仍 open、直接触摸挡位本轮未实现。
- `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/LESSONS.md`：补上去掉嵌套 `Button`、模式选项分行、直接触摸挡位进入后续 `SHOULD_GRILL`。

它已启动只读审计子代理：

- agent id：`019f0788-ec3e-70a0-924a-c76cb93bf295`
- nickname：`Bernoulli`
- 任务：审计 8.C2 返修 dirty diff、fake affordance、proof claim、unowned docs/evidence 混入风险。

新指挥官第一动作：等 `019f077d` verdict，或直接读它的最新 jsonl tail。没有最终 verdict 前，不要重复开第二个 8.C2 返修实现线程。

## 7. 本轮新增 roadmap 文档

本轮 commander 新增：

- `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`

并级联更新：

- `docs/CURRENT.md`
- `docs/README.md`
- `docs/uiue-roadmap-2026-06-23.md`

该 roadmap 的核心是：

- 下一阶段不是 runtime，而是先收 8.C2 返修，再做交互真值门，再重跑 L0-L3。
- Liquid4All 是 `PARTIAL_ADOPT` / `RESEARCH_ONLY`，只吸收 proof/harness/bridge 形态，禁止直搬 H5/FastAPI/Liquid schema/LFM runner。
- `【SHOULD_GRILL】` 是候选决策标记，不是实现授权。所有带标记的点必须先 grill。

这些 docs 目前是 commander-owned dirty。不要混入 8.C2 返修 commit，除非新指挥官明确做单独 docs/provenance commit。

## 8. Liquid4All 10-agent 调研结论

研究产物在：

- `/Users/wanglei/Projects/Liquid4All-cookbook/research/maformac-transfer-2026-06-27/final-synthesis.md`

关键 verdict：

- UIUE：`PARTIAL_ADOPT`
- Mainline：`PARTIAL_ADOPT`
- Liquid4All runtime/model：`RESEARCH_ONLY`
- 代码/资产/license transfer：direct copy reject

能吸收：

- caption/debug overlay 的 proof 形态。
- bridge/readback/proof harness 的事件形态。
- `/ws-audio` 作为 local runtime teardown 灵感。
- agent-tmux 的 output-dir truth、file:line content audit、post-goal review。

不能吸收：

- H5 截图作为 UIUE L0/L3。
- H5 `functions.json` 或 fullState 作为 MAformac SSOT。
- FastAPI/Python backend。
- Liquid schema。
- LFM runner/模型权重。
- 深色 cyan palette 直接复制。

任何 Liquid4All 反哺进入 UIUE 或主线前，都标 `【SHOULD_GRILL】`。

## 9. 主线与 UIUE 的边界

UIUE 是隔离 presentation lane。当前证明 class 主要是：

- `local`
- `unit`
- `simulator_l0_runtime_truth`
- `XCUITest`

它不是：

- mainline proof
- backend proof
- runtime proof
- mobile proof
- true-device proof
- voice-ready proof
- model-ready proof

主线后续应该先走 `Runtime -> Presentation` bridge contract，核心自有契约是：

- `PresentationSnapshot`
- `DemoRuntimeResult`
- `proofClass`
- `readbacks`
- `scopeOrigins`
- `traceId`
- `VisualEvidenceKind`

不要因为 UIUE 视觉返修推进，就自动接真 ASR/LLM/TTS/LoRA/backend。

## 10. Dirty 区分类建议

新指挥官接手时，把 dirty 分三类：

1. `owned_by_019f077d_8c2_repair`
   - `App/ContentView.swift`
   - `App/DesignTokens.swift`
   - `App/ExpandedFamilyCard.swift`
   - `App/ValueControlView.swift`
   - `Core/Presentation/AmbientBurstColorMapper.swift`
   - `Core/Presentation/ExpandedFamilyDisplay.swift`
   - `Core/Presentation/SemanticColorMapper.swift`
   - `Core/Presentation/UIValueTypeMapper.swift`
   - `Core/Presentation/ValueRangeMapper.swift`
   - `Core/State/DemoVehicleStateStore.swift`
   - `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`
   - `Tests/MAformacCoreTests/*` 相关 8.C2 返修测试
   - `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/*`

2. `owned_by_commander_docs`
   - `docs/CURRENT.md`
   - `docs/README.md`
   - `docs/uiue-roadmap-2026-06-23.md`
   - `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`
   - 本 handoff

3. `ignore_or_review_later_untracked`
   - 旧 `docs/research/2026-06-25-a2-execution/...` visual evidence dirs
   - `docs/research/2026-06-26-ios2026-frontend-trends-migration/`
   - `docs/superpowers/plans/2026-06-27-uiue-8c2-l0-l3-visual-acceptance.md`

提交建议：

- 如果 `019f077d` 成功：先做 8.C2 repair commit，只 stage owned repair files。
- roadmap/handoff/docs 另做 docs commit，commit message 可用 `docs(uiue): hand off post 8c2 commander state`。
- 如果 `019f077d` partial：不要提交半成品为 DONE；先修或记录 blocker。

## 11. 下一任指挥官第一轮动作

1. 读本 handoff 和 route docs。
2. `git status --short --branch` 重新核 dirty。
3. 读取 `019f077d` 最新输出：

```bash
tail -160 /Users/wanglei/.codex/sessions/2026/06/27/rollout-2026-06-27T13-12-03-019f077d-f74d-77c3-89e4-292339d065a9.jsonl
```

4. 如果 `019f077d` 已回 `verdict: DONE`：
   - 核 commit sha 是否存在。
   - 核 changed files 是否只属于 8.C2 repair。
   - 核 `8.C2` 是否仍 open。
   - 核 validation 是否真实。
   - 核 worktree 是否还有 commander docs dirty。
5. 如果 `019f077d` 未完成：
   - 待命或询问该线程状态，不要开第二套实现。
6. 如果 `019f077d` `PARTIAL/BLOCKED`：
   - 先审计原因，再决定由新指挥官修复还是重新派单。

## 12. 后续路线

8.C2 repair commit 后，不要马上开 runtime。后续顺序：

1. 请磊哥重新做 L3 5-gate 或至少确认是否进入重跑证据包。
2. 若 L3 仍 partial，继续返修循环。
3. 若 L3 通过，再做 R3 文档级联和关闭 `8.C2`。
4. 之后才进入 R1/R2 之外的 Interaction Integrity hardening 计划和 grill，尤其是 10 族直接触摸调节矩阵。
5. Bridge/runtime/voice/model 分线必须独立 grill，不和 UIUE 视觉过门混。

## 13. 禁线

- 不使用 `git add .`。
- 不 `git reset --hard`。
- 不 `git checkout --` 回退别的窗口改动。
- 不把 L1/L2 机器指标写成 L3 审美通过。
- 不声明 `V-PASS`、`mobile`、`true_device`、`runtime-ready`、`voice-ready`、`A-2 complete`。
- 不重开投屏/AirPlay/1080p 外屏验收。
- 不接真 NLU/ASR/TTS/LoRA/backend。
- 不把 `【SHOULD_GRILL】` 当已拍板。
- 不让 subagent prose 替代 controller 对 repo/commands/files 的复核。

## 14. 关键 jsonl 索引

当前主指挥线和历史线索：

- 主指挥/本轮长上下文候选：`/Users/wanglei/.codex/sessions/2026/06/27/rollout-2026-06-27T00-50-26-019f04d7-000c-7301-ad2a-c6651ee80b49.jsonl`
- 活跃 8.C2 返修执行线：`/Users/wanglei/.codex/sessions/2026/06/27/rollout-2026-06-27T13-12-03-019f077d-f74d-77c3-89e4-292339d065a9.jsonl`
- 新指挥官目标线：`/Users/wanglei/.codex/sessions/2026/06/27/rollout-2026-06-27T13-20-02-019f0785-45ee-7012-a5eb-a7ef606ae607.jsonl`
- 8.G / visual gate 相关历史可用 `rg '019f0313|8\\.G|8\\.C2|Liquid4All|SHOULD_GRILL' /Users/wanglei/.codex/sessions/2026/06/27`

外部调研产物：

- Liquid4All final synthesis：`/Users/wanglei/Projects/Liquid4All-cookbook/research/maformac-transfer-2026-06-27/final-synthesis.md`

## 15. 给新指挥官的压缩口令

你是 UIUE 新指挥官。你的首要任务不是直接编码，而是接管当前活跃的 8.C2 返修收口：先读本 handoff，核 live status，等待或读取 `019f077d` verdict，确认是否 commit、是否仍保持 `8.C2` open、是否没有 fake V-PASS。之后再决定是否需要修复、提交 docs handoff/roadmap 或进入下一轮 grill。
