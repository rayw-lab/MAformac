---
status: active_handoff
artifact_kind: commander_handoff
date: 2026-06-28
source_thread_id: 019f093c-cd80-7f70-9d46-adcec3897a99
target_thread_id: 019f0c15-421a-7601-a6c0-5dfb101b23da
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
head_verified: 4a4aabb
proof_class: docs/local + mainline_readonly_probe + jsonl_review
authority: handoff_not_ssot
---

# UIUE R4 Burndown Commander Handoff

这是一份给新任 commander 的交接文档。它不是 OpenSpec authority，不是 R4 closeout，不是 mainline acceptance。新线程必须先按 live repo truth 复核，再继续派单或审计。

## 必须先纠正的全局背景

- Codex app / target thread metadata 可能显示 cwd 为 `/Users/wanglei/workspace/MAformac`，但本交接的实际工作目录是 `/Users/wanglei/workspace/MAformac-uiue`。
- UIUE 是隔离 worktree：`/Users/wanglei/workspace/MAformac-uiue`，branch `uiue/phase4-default-scope-presentation`。它不是 mainline proof。
- mainline 是 `/Users/wanglei/workspace/MAformac`。当前 read-only probe 显示 mainline branch `codex/rebuild-c6-doc-absorption-20260624`，HEAD `de79c65`，`openspec/changes/define-runtime-presentation-bridge/` 不存在，`docs/CURRENT.md` 仍写 `Runtime-Presentation bridge | not_proposed`。
- UIUE 的 `define-runtime-presentation-bridge` 已在 UIUE lane 中可供 mock visual consumption，但 mainline co-author 尚未接受。不得把 UIUE bridge 写成 mainline shared contract 已接受。
- `8.C2` 已关闭，但只限 UIUE simulator/mock visual-acceptance R3 scope；`8.A` 仍独立 open；A-2 overall 仍不能声明 complete。

## 本轮 live-verified 状态

在 `/Users/wanglei/workspace/MAformac-uiue` 复核：

- branch：`uiue/phase4-default-scope-presentation`
- HEAD：`4a4aabb`
- scoped dirty：`docs/CURRENT.md`、`docs/README.md` 已修改；R4 burndown / mainline co-author request / human review packet 等为 untracked；Reports 在 ignored 路径下但文件存在。重脏树仍存在，不得 `git add .`。
- `openspec/changes/ui-presentation/tasks.md:112` 是 single `[x] 8.C2 ...`。
- `8.A1` 到 `8.A7` 均仍是 `[ ]`。
- `openspec validate ui-presentation --strict` pass。
- `git diff --check` pass。

## 关键证据路径

- R3 closeout：`Reports/uiue-8c2-r3-closeout-20260628/closeout.md`
- R3 evidence index：`docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/pre-human-l3-package/r3-closeout-20260628/r3-evidence-index.md`
- R4 v2 source matrix：`docs/loop-competition/2026-06-28-uiue-r4-bridge-grill-matrix/final-grill-matrix-v2.md`
- R4 classification：`docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md`
- R3 residual routing：`docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md`
- R4 human review packet：`docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md`
- R4 burndown ledger：`docs/grill-tournament/uiue-r4-burndown-2026-06-28.md`
- Mainline co-author request：`docs/grill-tournament/uiue-r4-mainline-coauthor-review-request-2026-06-28.md`
- R4 burndown closeout：`Reports/uiue-r4-burndown-preimplementation-20260628/closeout.md`
- R4 Hermes audit：`Reports/uiue-r4-burndown-preimplementation-20260628/hermes-audit.md`
- Dirty ownership manifest：`Reports/uiue-r4-burndown-preimplementation-20260628/dirty-ownership-manifest.md`

## 本会话 JSONL 回顾

主线程 JSONL：

`/Users/wanglei/.codex/sessions/2026/06/27/rollout-2026-06-27T21-20-07-019f093c-cd80-7f70-9d46-adcec3897a99.jsonl`

我已抽取并回看关键事件：

- JSONL 1039-1083：executor 回写 `PASS_WITH_NOTES / R3_8C2_closed`；commander 接受为新真态，但明确 proof scope 只到 simulator/mock visual acceptance，不外推到 runtime/voice/mobile/V-PASS。
- JSONL 1089-1118：用户要求回顾 R4 前工作；commander 判断不必把所有 residual 做完才 grill，必须补的是 authority 冲突、分类、residual routing、review packet。
- JSONL 1124-1143：向 executor `019f09a0-a489-7061-bcc2-4178476de0ad` 派发 R4 pre-grill 文档级联任务，要求使用 `executing-plans`。
- JSONL 1148-1175：executor 回写 `PASS_WITH_NOTES / R4_PREGRILL_PACKET_READY`；commander read-only 复核通过。
- JSONL 1181-1217：用户补充人审通过，并要求这个会话用 superpowers；commander核到 R4 human review packet 可进入 burndown 立项，但不能进入 R4 implementation/closeout。
- JSONL 1223-1250：用户要求把五个硬项融合为 dispatch 并安排 Hermes 审计；commander 发送融合派单给 executor `019f09a0...`。
- JSONL 1255-1284：executor 回写 `PASS_WITH_NOTES / R4_BURNDOWN_LEDGER_READY`；commander read-only 复核了 C01-C50 计数、8.C2/8.A、mainline co-author truth、Hermes P0/P1、OpenSpec 和 diff check，接受该 verdict。
- JSONL 1290 之后：用户要求写本 handoff 并发送给新任 commander `019f0c15-421a-7601-a6c0-5dfb101b23da`。

相关 executor 线程：

- R1/R2b first slice executor：`019f0915-dedd-7623-9fbf-89614088f16e`
- R3/R4 executor：`019f09a0-a489-7061-bcc2-4178476de0ad`
- 新任 commander target：`019f0c15-421a-7601-a6c0-5dfb101b23da`

## 已完成的工作

1. R3 `8.C2` closeout：
   - verdict：`PASS_WITH_NOTES / R3_8C2_closed`
   - `8.C2` single `[x]`
   - 双审计 SAFE_TO_CLOSE / P0/P1 none
   - full `swift test` 315 tests / 0 failures / 3 skipped
   - 不声明 V-PASS/mobile/true_device/runtime-ready/voice-ready/A-2 complete

2. R4 grill matrix：
   - 最初按 loop-competition 做 30 条。
   - 用户提醒不要局限提示词，必须覆盖 4 个 zone、动效、触摸、长按 1.5s、演绎控制台、顶部车辆样式切换等细节。
   - 又补一轮 C31-C50，最终 `final-grill-matrix-v2.md` 是 50 条。
   - 两轮共 6 个 subagent 盲评均有中文 Markdown 留痕；最终要看合并后的 v2，不要重新造第三套 50。

3. R4 pre-grill 文档级联：
   - verdict：`PASS_WITH_NOTES / R4_PREGRILL_PACKET_READY`
   - 修正 `docs/CURRENT.md` 旧 `8.C2 open` authority 冲突。
   - 生成 C01-C50 分类表、R3 residual routing、R4 human review packet。
   - `docs/README.md` 已级联入口。

4. R4 human review 后的非代码前置融合：
   - verdict：`PASS_WITH_NOTES / R4_BURNDOWN_LEDGER_READY`
   - 生成 R4 burndown ledger。
   - 生成 mainline co-author review request。
   - 具体化 owner / artifact / fail-closed / status。
   - 记录 `scope_origin = missing` 未锁。
   - 建 dirty ownership manifest。
   - Hermes audit：P0=0，P1=0，P2=2，confidence high。

## 当前严禁误读的边界

- `PASS_WITH_NOTES / R4_BURNDOWN_LEDGER_READY` 不是 R4 implementation，绝不是 R4 closeout。
- `8.C2` closed 不等于 `8.A` closed，不等于 A-2 complete。
- R3 四态 proof 只证明 `SnapshotPreset -> PresentationSnapshot.orbState -> DemoOrbView caption/visual` 的 presentation/mock binding；不证明 ASR/LLM/intent-router/tool execution/runtime-driven binding。
- 复杂推理进入 `think` 仍待 runtime presentation bridge 验证。
- 长按 1.5 秒进入演绎控制台未实现/未证明；现有 `MicDock` long press 是 `minimumDuration: 0.05` press feedback，`演绎控制台` 是 Settings panel button。
- Reduce Motion proof 是 `simulator_debug_override`，不是真机系统设置 proof。
- R2b white-edge threshold 仍是 `WARN` accepted-with-notes，不是 clean formal threshold PASS。
- capsule final-art、44pt/VoiceOver、完整 10-family interaction matrix、summary direct-control、gear direct touch 都是 residual/deferred，不得假绿。
- R4 P1 的 C22/C30 是 `accepted_with_notes_by_human`，不能被读成 mainline accepted；P0 C01/C03/C06/C18 才是 mainline co-author hard blockers。

## Mainline co-author 当前真态

当前状态：`pending_mainline_coauthor_receipt`。

Live probe 结论：

- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/` 不存在。
- `/Users/wanglei/workspace/MAformac/docs/CURRENT.md` 仍写 `Runtime-Presentation bridge | not_proposed`。
- R4 ledger 中 C01/C03/C06/C18 是 `blocked_by_mainline_coauthor`。

下任 commander 不得自己替 mainline 接受 UIUE bridge。必须拿到真实 mainline owner receipt，或者派发 mainline co-author review。

## `scope_origin = missing`

当前 Core `ScopeOrigin` live-verified 只有：

```swift
case defaulted
case explicit
case fanout
```

`missing` 只是 bridge-proposed future addition，未锁。R4 可选项仍是：

- 扩 Core enum；
- 建 presentation-only enum；
- 删除 bridge `missing`，改用现有 origin + explicit fail reason；
- defer to R5，并带 non-claim / fail-closed rule。

没有 mainline co-author receipt 前，C06 继续 blocked。

## Dirty tree / Git 纪律

- 当前 UIUE worktree heavy dirty，且包含大量 preexisting/unowned dirty/untracked。
- 本轮 docs/reports 多数未 stage。
- 不得 `git add .`。
- 若未来要提交，先读 `Reports/uiue-r4-burndown-preimplementation-20260628/dirty-ownership-manifest.md`，再 fresh `git status --short`，按 exact pathspec staged。
- Reports 路径通常 ignored，但文件存在；如果要提交 evidence，需要先明确是否进入仓库。
- 不得 revert 或 overwrite unrelated dirty hunks，尤其 App/Swift/UI tests/assets 里的旧改动。

## 建议的下一步

1. 先对新任 commander 线程做 read-only 真态复核：
   - `cd /Users/wanglei/workspace/MAformac-uiue`
   - `git branch --show-current`
   - `git rev-parse --short HEAD`
   - `rg -n '^- \\[[ x]\\] 8\\.(C2|A)' openspec/changes/ui-presentation/tasks.md`
   - `python3` 机械数 C01-C50 source/classification/burndown
   - `openspec validate ui-presentation --strict`
   - `git diff --check`

2. 下一件真正有价值的工作是 mainline co-author：
   - 给 mainline commander/runtime contract owner 派审 `docs/grill-tournament/uiue-r4-mainline-coauthor-review-request-2026-06-28.md`。
   - 要求明确：是否接受 UIUE bridge 为 shared contract，是否复制/迁移/引用，冲突时谁是 SSOT，是否禁止第二份同义 bridge，`scope_origin=missing` 如何处置。
   - 没有 receipt 前，不要推动 R4 exit。

3. 若继续 R4 非代码收口：
   - 用 `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md` 作为待消减 ledger。
   - 先减少 mainline blockers 和 `scope_origin` blocker，再拆 visual policy / evidence checklist / bridge schema 三线。
   - 每个 reducer 都必须更新 ledger status，不能只写旁路 notes。

4. 若进入 R4 implementation，必须另起实施计划：
   - 明确 writable paths。
   - 把 App/Swift/assets/tests 改动范围和现有 dirty ownership 分离。
   - 对 UIUE visual policy/evidence checklist 的实现，不得宣称 runtime/mobile/true-device。
   - R4 implementation 前建议新建 worktree 或先做 pathspec manifest 审计，避免踩共享脏树。

5. R5 / later 分线建议：
   - runtime-driven orb binding
   - 复杂推理 -> `think`
   - 1.5 秒长按进入演绎控制台的产品决策与实现
   - full a11y/VoiceOver/44pt
   - 10-family interaction matrix
   - summary/gear direct touch
   - capsule final-art / white-edge formal threshold
   - mobile / true_device / voice / model / golden / endpoint readiness

## 推荐下任会话使用的技能

- `handoff`：继续交接或压缩上下文。
- `using-superpowers`：先核源、再执行，避免把讨论结论当 proof。
- `executing-plans`：只有在需要派 executor 落文档或代码时使用。
- `bug-iceberg-teardown`：凡是发现 UI 截图看似过、但交互/runtime/a11y/证据链可能没真的过时使用。
- `hermes-cli-glm52-code`：跨厂商审计，尤其 R4/R5 closeout 前。
- `openspec-explore` / `openspec-propose` / `openspec-apply-change`：若要把 mainline bridge 或 R4 implementation 转成 OpenSpec work。

## 给新任 commander 的最短口径

你接手的是 UIUE 隔离分支，不是 mainline。当前 R3 `8.C2` 已 closed with notes；R4 50 条已人审并转成 burndown ledger；R4 非代码前置已 `PASS_WITH_NOTES / R4_BURNDOWN_LEDGER_READY`，Hermes P0/P1 none。下一步不是写 Swift，而是拿 mainline co-author receipt，特别是 bridge SSOT 与 `scope_origin=missing`。在此之前，不得声明 R4 closeout、runtime-ready、mobile、true_device、V-PASS、A-2 complete。
