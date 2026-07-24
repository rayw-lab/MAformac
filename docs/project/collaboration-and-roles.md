---
document_role: collaboration_strategy
retire_trigger: Retire when superseded by explicit user decision or a newer collaboration strategy.
updated: 2026-07-14
---

# MAformac 协作分工与推进机制

> 配套 `CLAUDE.md` 的稳定宪法。本文件定义按任务形态组织 controller、producer 与 reviewer 的默认策略；具体模型、provider、席位和命令由本机配置或单次任务合同决定。

## 1. 角色按任务形态分配

| 角色 | 主职责 | 不可替代的边界 |
|---|---|---|
| 磊哥 | 定目标、优先级与产品方向；可随时纠偏 | secrets、付费、对外发布、主观体验拍板等个人权限动作 |
| Controller | 绑定 live authority，拆依赖，分配不重叠写集，整合、验证并终判 | 不替用户执行未授权的不可逆动作 |
| Producer | 在明确 scope 内实现、测试、研究或文档级联 | 不自授越界范围，不以自报替代 PASS |
| Reviewer | 对共享安全/契约 seam 提供反例、finding 与 proof-ceiling 检查 | 不以身份替代机械证据 |

Controller 优先编排、整合和最终判断；极小、低风险、可逆且不会造成 ownership 冲突的修复可以直接完成。这是默认组织策略，不是“controller 永不写代码”的不可变宪法。具体模型不是岗位，审计也不是默认流水线。

## 2. 协作流

```text
用户目标 + live authority + scope/proof ceiling
                    |
                    v
             Controller 拆依赖
              /       |       \
       Producer    Test/probe   可选 reviewer
              \       |       /
             Controller 集成与机械门
                    |
                    v
        exact-subject closeout + non-claims
```

- 目标不清时先 grill；目标、authority 与 stopline 已清楚时直接推进，不为形式反复呈拍。
- 不同写集可并行；同一文件或共享状态保持唯一 writer。
- 测试、build、mutation、runtime/readback 是主证据。agent prose、ack 和 producer 自报只能作线索。
- 普通本地切片不强制异源审；共享 CRITICAL、安全或契约边界可增加一次高价值复核。clean 后停止，不生成重复审计文书。

## 3. 长任务 harness

| harness | 作用 |
|---|---|
| OpenSpec | 固定产品可观察行为和 non-goals；不是逐分钟计划或 agent 排班表 |
| TDD / targeted tests | 在实现面建立 RED→GREEN→REFACTOR 证据 |
| Proof contract | 预先写清 exact subject、hard gates、proof class 与不能声称什么 |
| Recoverable state | 长任务分阶段保存 commit/receipt/log，resume 时重新核 live Git/process/runtime |

任务 DAG 可以按依赖重排；`tasks.md` 不固定厂商、模型、席位或所有步骤顺序。治理/config/lint 修复不应为了形式新建产品 OpenSpec change。

## 4. 交接与恢复

- 新 handoff 必须声明 `predecessor` 与 `supersedes`；旧 handoff 不原地改写。
- 恢复当前态只读 `docs/CURRENT.md` 指向的最新节点，再沿显式链定向追溯；禁止顺读全部 handoff 后自行合成。
- Handoff 至少写 Goal、Constraints、Progress、Key Decisions、Next Steps 和 Critical Context，并绑定 exact subject、关键路径与 proof ceiling；不以固定段数制造形式门。
- Closeout 只引用必要的原始验证，不复制多份 evidence table。报告/receipt 落盘后先核文件、hash、内容，再接受消息层 REPORT。

## 5. 并发、ownership 与 stopline

- 每个 writer 必须有明确 writable paths、no-touch paths 和完成标准；共享工作树中重叠写集只能有一个 owner。
- Producer 完成派单后停止；发现越界问题只登记 residual，不擅自扩大实现。
- Controller 对浏览器登录态、设备、全局配置、发布动作和最终裁决串行管理。
- 具体外部 agent 路由见 `docs/operators/agent-orchestration.md`，但 live model/provider 只由运行时配置确认。

## 6. Authority 与边界

完整 authority matrix 见 `CLAUDE.md §3`。本文件只负责协作策略，不负责产品行为、机器语义或动态运行状态。

所有角色均遵守公开仓 exception registry、mock 车控、安全检查代码化、受限源料不入仓/训练集等边界。低等级 local/mock proof 不得冒充 runtime、operator、device 或 live-api 验收。

## 7. Pocock / OpenSpec / 工程验证

- Pocock 判断任务类型与当前阶段。
- OpenSpec 定义产品行为变化；proposal/change 在 archive 前不自动成为生效规格。
- 工程验证证明实现和治理 claim；先跑针对性检查，再按风险补 integration/build/runtime。
- 完成后通过 sync/archive 处理产品 spec；纯治理收口通过 governance lint、配置解析、引用链检查和 closeout 完成。
