# MAformac 二次调研校准包

> ⚠️ **HISTORICAL 快照（2026-06-17）—— 文档级联 banner（2026-06-23）**
> 本目录（00-source-ledger ~ 07-roadmap + README，9 文件）是立项早期二次调研校准包历史快照。范式翻案后（generic frame → D-domain 具名工具，见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`）+ 口径终拍 562 + 契约 SSOT 全量重构，本包涉及的 surface 形态 / 口径数字 / 路线部分已过期。**活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/roadmap-2026-06-20-from-c6-done.md`。正文保留供溯源，勿据此推进。

生成日期：2026-06-17

范围：以 Claude Code 基于 38 个参考 repo 和深聊沉淀出的 5 份材料为主基座，补一层官方源、源码级证据、子任务审计结果和 MAformac demo 边界校准。本文档包不是最终 PRD/SRD，也不是代码架构定稿；它是下一步建项和拍板的证据底座。

## 边界硬前提

MAformac = Master Agent for Mac。它是磊哥个人使用、装在自己 Mac/iPhone 上、给客户做方案演示的离线端侧 demo。它不是上车系统，不是真实车辆控制系统，不是量产座舱架构，也不是交付给客户运行的产品。

本文所有“车控”“车设”“执行”“安全”默认都指演示语境：

- 车控 = mock 车控卡片/状态变化，证明语义链路和方案能力。
- 执行 = 改本地 mock state + 展示 trace + 播报/文字反馈。
- 安全 = 演示风控，避免 demo 误导、越界、乱执行；不是 ISO 26262 或真实车辆安全。
- VSS/KUKSA/Canals = 命名和架构参考，不是首版运行依赖。

## 结论索引

| 文件 | 用途 | 当前状态 |
|---|---|---|
| [00-source-ledger.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/00-source-ledger.md) | 本次二次调研用到的一手源、本地源码和本地报告证据索引 | evidence-ledger |
| [01-claude-code-check.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/01-claude-code-check.md) | 对 Claude Code 总结逐条校准，保留主判断并补充边界注记 | verdict=clear_with_scope_notes |
| [02-giants-shoulders-adoption.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/02-giants-shoulders-adoption.md) | “巨人的肩膀”引用意见表，逐组说明借什么、不借什么 | verdict=clear |
| [03-capabilities-catalog.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/03-capabilities-catalog.md) | `capabilities.yaml` 单一事实源的证据、字段和生成物设计 | candidate |
| [04-runtime-model-route.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/04-runtime-model-route.md) | Qwen3、MLX Swift、llama.cpp、Foundation Models 路线复核 | candidate |
| [05-vehicle-execution-vss-kuksa.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/05-vehicle-execution-vss-kuksa.md) | VSS/KUKSA/Canals 对 mock 演示链路的可复用边界 | verdict=clear |
| [06-project-operating-system.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/06-project-operating-system.md) | 项目刚建立时，后续 PRD/SRD/spec/代码架构如何组织推进 | candidate |
| [07-roadmap-next-actions.md](/Users/wanglei/workspace/MAformac/docs/second-review-2026-06-17/07-roadmap-next-actions.md) | 修正后的近端路线图和拍板清单 | candidate |

## 方法说明

- 使用 `pg-deep-research` 的口径：本地报告、repo 源码、官方网页三类证据交叉核验，不把单一 repo README 当最终结论。
- 使用 `subagent-driven-development` 的独立分工思想：拆出三条并行审计线，分别查能力目录、运行时模型、mock 执行协议，再由主线程整合。
- 本次没有跑完整 `research -> research-deep -> research-report` 的 JSON 网格流水线，因为任务对象是已有 38 repo 报告的二次审计，而不是重新铺行业矩阵；但报告采用了同一套“结论必须可追溯”的证据纪律。

## 总体收敛

1. `capabilities.yaml` 是强候选核心资产，Claude Code 对这一点的收敛是对的。落地时要先收敛 `tools.json`、`capabilities.yaml/json`、`vehicle_capabilities.json`、`tool_schemas.json`、`vss_paths.yaml` 等命名，避免同一事实多处维护。
2. “D1-D37 全锁”如果是深聊后的口头结论，需要同步回落盘文档；按当前 [docs/README.md](/Users/wanglei/workspace/MAformac/docs/README.md:16)，仍列 D20/D30/D35/D37 为待拍。
3. 运行时路线建议统一成“1.7B 默认候选、0.6B 轻量 fallback、Foundation Models baseline/逃生口”，保留 benchmark 拍板，不再让 0.6B 主线和 1.7B 主线并列打架。
4. KUKSA Databroker 从“淘汰/后置”提级到 Mac 开发期可选对照环境是合理修正；在 MAformac 首版 demo 里，它只保留为远期对照，不进入 Phase 0-5。
5. 项目现在最缺的不是继续 clone repo，而是轻量项目操作系统：围绕个人自用、客户演示、mock 车控的 PRD、SRD、架构 spec、ADR、能力目录、eval 合同和代码骨架落地顺序。
