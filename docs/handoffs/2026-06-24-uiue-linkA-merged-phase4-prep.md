# Handoff — UIUE 链路 A 并入 main + Phase 4/5 起点就绪（2026-06-24）

## 本次完成
- **UIUE 链路 A 已并入 main**：PR #5 rebase-merge → `origin/main c1e7d58`（含 D7 7态视觉消费 + D1-D8/DA0-DA8/E0-E8 grill 全收口 + ui-presentation change skeleton，18 commit）。
- **两次 rebase 解撞车**（main 高频动）：① 解 ContentView 唯一冲突（D7 7态视觉 ⊕ main D-domain scoped title **正交合并**——main 管 `key→中文标题`，UIUE 管 `visualState→视觉外观`）；② `git rebase --onto origin/main c2d6402` 处理 **PR#4 rebase-merge 的 SHA 重写**（merge-base 回退 → 只摘 18 UIUE commit，丢 12 旧 default-scope，origin/main 已有审计修复后新版）。
- **验证全绿**：macOS/iOS build SUCCEEDED + swift test 163/0 + 2 check gate + make verify exit 0 + 工作树净。
- **subagent CC 审计 CLEAR**（7 维度实跑复核）+ **CI verify pass**（1m45s）双门。
- **跨窗口协作成果**：catch 到「C3 readback elide 主驾 vs UIUE 裂缝⑤淡显」跨 grill 线口径冲突（GPT 审计看不到）→ 磊哥拍**保留主驾** → domain 吸收 + UIUE 裂缝⑤一致；UI 两条 punch list（lastReadback 用 spokenText / presentation viewmodel）划界 **defer UIUE**；3 个 UIUE 依赖接口（`presentationCells`/`base[scope]`/`init(visualState:)`）未被 domain P0/P1 修复破坏。

## 未完成（Phase 4/5，grill 已拍 + 契约 ready）
- **Phase 4 卡片 scope 呈现**（tasks 7.A2/7.A3/7.A4，裂缝⑤⑥④）：默认 scope = 淡角标「主驾」（非省略）/ 非默认显式 / 全车=1 聚合卡+badge / 多轮升级聚合「前排车窗」。实现锚 = `UIValueTypeMapper` 旁加 scope 呈现派生（读 `default_scope`）。**别用 GPT 建议的 VehiclePresentationCell 4-enum adapter（过度工程化，UIUE 有更轻版）**。
- **Phase 5 思考链路 orb**（DA0-DA8）：orb think 态 + DA0 deny→态，**DA0 待 guard 扩接 C3**（E5 发现主流程占位 → reason→态映射是 guard 扩接 C3 后契约）。
- **3 NIT（非阻塞）**：① ContentView 注释「四态分开」措辞 stale（实际 7态，code 对）；② **grill-master §3 D7 row 仍标「待补」**（code 已实装，Phase 4 顺手改「已实装」）；③ lastReadback 显示 machine key（=Phase 4 task 7.A 已划界 defer）。

## 当前状态
- worktree **MAformac-uiue**（隔离防撞主 worktree 的 codex 训练线），分支 **`uiue/phase4-default-scope-presentation`**（from `origin/main c1e7d58` 含 UIUE），工作树净。
- 备份分支 3 个保留（`backup/uiue-pre-rebase-main`/`rebase1`/`rebase2`，rebase 兜底，可清）。
- main 线（另一窗口）：PR #4 default_scope apply 已并 main + 吸收 GPT P0/P1（state-applier fail-closed/C6 scopeOrigin 单源/C5 全设备 parity/head-bound receipt+CI）。训练线（retrain-c5/rebuild-c6）仍 DEFERRED。

## 相关文件（≤5）
- `docs/grill-tournament/grill-decisions-master.md` §3（UIUE U1-U31 + 裂缝⑤⑥④ + D7 row）
- `openspec/changes/ui-presentation/tasks.md`（7.A 默认主驾展示 + 7.D 多轮/读回）+ `design.md`（AD-8.6 UIUE 边界）
- `App/ContentView.swift`（D7 已实装，Phase 4 在此加 scope 呈现）+ `App/DesignTokens.swift`（CardAppearance）

## 下次第一步
Phase 4 实装卡片 scope 呈现：`UIValueTypeMapper` 旁加 scope 派生（读 `default_scope` 判默认/非默认 → 淡角标/显式/聚合 badge），改 `VehicleStateCard` title 从「scope 拼标题」→「值卡 + 淡角标」（裂缝⑤）。顺手修 NIT2（grill-master D7 row「待补→已实装」）。grill 已拍、契约 ready，可直接 brainstorm→实装。
