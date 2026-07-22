# Phase 1 整改独立审计包索引

## 文件清单

| 文件 | 内容 | 一手性 |
|---|---|---|
| `README.md` | 九点综合审计、验证记录、NO-GO 裁决 | 综合派生 |
| `lens01-evolving-rescue.md` | Evolving Rescue 初判与动态复判 | 结构化一手摘要 |
| `lens02-core-runtime.md` | COR-2/4/7/8 运行时审计 | 结构化一手摘要 |
| `lens03-ci-fake-green.md` | Make/CI/required/fake-green 审计 | 结构化一手摘要 |
| `lens04-doc-cascade.md` | WBS/handoff/CURRENT 级联漂移 | 结构化一手摘要 |
| `lens05-architecture-entropy.md` | producer/consumer/测试熵 | 结构化一手摘要 |
| `lens06-presentation-truth.md` | orb/voice/proof/schema/UI 真值 | 结构化一手摘要 |
| `lens07-product-truth.md` | 产品能力与 runtime ceiling | 结构化一手摘要 |

## Transcript / Agent 原始指针

| Lens | transcript | 结构化输出 |
|---|---|---|
| 01 | `history://EvolvingRescue` | `agent://EvolvingRescue` |
| 02 | `history://CoreRuntimeAudit` | `agent://CoreRuntimeAudit` |
| 03 | `history://CIFakeGreenAudit` | `agent://CIFakeGreenAudit` |
| 04 | `history://DocCascadeAudit` | `agent://DocCascadeAudit` |
| 05 | `history://ArchitectureEntropy` | `agent://ArchitectureEntropy` |
| 06 | `history://PresentationTruth` | `agent://PresentationTruth` |
| 07 | `history://ProductTruthAudit` | `agent://ProductTruthAudit` |

这些 URI 是最一手过程记录；lens 文件已吸收主线程纠错，不能用 agent 初稿中的撤销项覆盖最终裁决。

## 主线程动态证据

- `make verify-e2e`：12 tests / 0 failures。
- `swift test`：1143 tests / 25 failures / 8 skipped。
- `make verify-anti-placebo`：失败。
- `make verify-ui-e2e`：失败且未有效执行 UI test。
- 直接 P1 XCUITest：1 test / 7 failures；xcresult Failed。
- GitHub：仅 Verify workflow；required 仅 verify。

## 纠错账

已撤销四个外援误判：

1. UI test class“不存在”——实际在 `MAformacIOSUITests/`。
2. `verify-e2e`“未进 verify-ci”——实际已进入。
3. protected 文件“本轮越界”——SHA baseline 证明是继承 dirty。
4. COR-2“无 active tests”——存在 active tests，但没有 mounted backend 覆盖。

## Successor baseline

- Program WBS V10：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/REMEDIATION-WBS-IMPLEMENTATION-PLAN.md`
- Phase1-AppendFix：同目录 `PHASE1-APPENDFIX-IMPLEMENTATION-PLAN.md`
- 当前含义：九点 finding 已全部映射进 V10/AF-0..AF-8；执行仍为 NO-GO，计划存在不等于整改完成。
