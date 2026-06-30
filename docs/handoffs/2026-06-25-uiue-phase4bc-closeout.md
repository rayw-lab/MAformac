# UIUE Phase 4b/4c 实装收口 + codex 异源审（2026-06-25）

## 本次完成
- **gptpro 意见吸收 + 4a 收口 hardening**（commit `c4c3b6a`）：default badge allowlist【修出真 bug `window.lock` 被吞→toggle】/ 提取 `ScopeAggregationResolver` / FamilyPrimaryCell 契约存在性 / phase matrix；沉淀全局 rule `derivation-layer-discipline.md` + lessons #9 + design AD-13（Presentation Contract 三层）。gptpro 第5点 skills拆PR 不采纳（private 仓，磊哥拍）。
- **4b/4c 全部实装**（`2a6bfe1`→`322e101`，spike-first 截图坐实）：ValueControlView 5 类穷尽 switch【`Gauge(.accessoryCircular)` spike 解除 P4-D1 tiger】/ ValueRangeMapper【委托 A2 `StateCellContractLookup` SSOT】/ 触发聚焦展开【FocusController + ZStack overlay + opacityScale 320ms】/ 座椅 composite【stepper×3→percent→badge 行分3类】/ MultiCallSequencer 错峰【220ms 序列化非同时炸，2 帧截图坐实】。
- **codex 异源审 V-HOLD(P1) → 辩证收**（`5b63ea1`）：P1-2 stepper off-by-one【fan「1挡」原亮0格→修后亮1格 spike 坐实】/ P1-1 sequencer cancellation 泄漏 / P1-3 numericValue 下界 fallback / P2-1 AD-12 toggle 措辞 / P2-2 semantic 对齐测试；P2-3 defer（codex 用错 scheme，实 MAformacMac/IOS 我 build 验正确）。
- **验收**：swift test **222/0** · make verify-all exit0 · xcodebuild macOS+iOS SUCCEEDED · push `uiue/phase4-default-scope-presentation`（PR #6）。

## 未完成 / 待磊哥
- 🔴 **合并粒度待拍**：PR #6 含 4a+4b+4c 一个 PR vs 拆小 PR（CURRENT.md「Do not merge UIUE into mainline」+ default-scope reconfirm gated；R-L17 deframing blocker 未全过前训练线 BLOCKED）。
- **4c view 端到端错峰**依赖多意图 splitter runtime 链路（AD-4 锚；sequencer 编排逻辑已做+测试）。
- **DEFERRED harden（design AD-13 phase matrix）**：catalog→A2 lookup 委托消 title/scope/defaultScope 重复 SSOT（上抛磊哥重构范围）/ state-cells bundle 化真机 standalone（4a codex catch，打包阶段）/ fan 10 段 stepper 视觉拥挤 polish（数字主导）/ typed trigger provenance。
- **训练线**（retrain-c5 / rebuild-c6 / voice / demo-golden-run）DEFERRED 独立立项。

## 关键发现（元认知）
- **4a 决策错误「绝不再犯」兑现**（磊哥 CRITICAL）：① 回溯 grill 零自拍（4b 前读 P4-D1/D2/D3+AD-12 承接执行）② 不机械停切片（4b/4c 一体做）③ §28 撞 A2 已有即回退委托不硬造。
- **§28 教训（lessons #10）**：写新类型/解析前 grep 现有 codebase——ValueRangeMapper 重复造 `ExecutionRange` 被 A2 `ContractLookups.swift` 已有 ambiguous catch → 回退委托。认知到≠行为改（刚沉淀 derivation 铁律2 转头造第三份）。
- **codex 异源审价值**：抓 Claude 同源漏的 3 实现层 P1（stepper off-by-one + 测试帮凶 / async cancellation / 坏值回退）；沙箱实跑失败但静态 file:line 审有效（我自己实跑补全）。

## 当前状态
- 分支 `uiue/phase4-default-scope-presentation` @ `5b63ea1`（push，PR #6）；worktree `MAformac-uiue`（防撞主 worktree codex 训练线）。
- swift test 222/0 · xcodebuild 两端 SUCCEEDED · make verify-all exit0 · pre-commit 三门绿。

## 相关文件（≤5）
- `docs/grill-tournament/uiue-phase4-grill-decisions.md`（4a/4b/4c 收口 SSOT，必读第一）
- `openspec/changes/ui-presentation/design.md`（AD-13 Presentation Contract 三层 + 8 点处置 + phase matrix）
- `docs/lessons-learned.md` #9（语义呈现层）/ #10（§28 重复造）
- `~/.claude/rules/derivation-layer-discipline.md`（全局元认知：语义安全带>表现打磨）
- `/Users/wanglei/Downloads/gptpro意见.md`（产品架构意见 8 点，吸收源）

## 下次第一步
等磊哥拍**合并粒度**（merge PR #6 / 拆）→ 按拍执行；或启动 **DEFERRED harden**（catalog→A2 lookup 委托 / bundle 化）/ **训练线立项**（R-L17 过后）。
