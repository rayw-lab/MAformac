# MAformac 文档地图

本页只做 discoverability map，不承载当前阶段、HEAD、运行状态或完成证明。领域 authority 与冲突规则见 `CLAUDE.md §3`；动态真态最终以 live Git/runtime/readback 为准。

## 冷启动入口

| 入口 | 用途 |
|---|---|
| `../CLAUDE.md` | 稳定项目宪法、安全底线、authority matrix |
| `CURRENT.md` | 短当前路由牌：下一读什么、合法下一步、stopline |
| `ACTIVE-LESSONS.md` | 非权威检索索引；按任务去详细 lessons/decisions 搜索 |
| `handoffs/` | 带 predecessor/supersedes 的 session 接力 |
| `operators/agent-orchestration.md` | 稳定 operator 分流原则；不记录动态模型/provider/pane |

## 产品行为与机器事实

| 位置 | 用途 |
|---|---|
| `../openspec/specs/` | 已生效的产品可观察行为 |
| `../openspec/changes/` | proposal/delta；archive 前不自动成为生效规格 |
| `../contracts/` | 可执行语义、策略、schema、机器 registry |
| `../generated/` | 从机器主源生成的派生产物；不能反向成为主源 |
| `../Core/`、`../App/` | 实现事实；行为变化仍需与 spec/decision 对齐 |

## 决策、规划与证据

| 位置 | 用途 |
|---|---|
| `commander-log/decisions.md` | 已锁决策与依据；不承载当前运行状态 |
| `adr/`、`grill-tournament/` | 架构选择与问题裁决的来源材料 |
| `roadmap-2026-07-11-v6-closure-baseline.md` | closure 业务说明与 checker 生成块；canonical 计数只认 generated marker |
| `superpowers/plans/` | implementation plans，不是行为或运行 SSOT |
| `project/phase0/` | route-control manifests；必须按自身 status/retire 元数据解释 |
| `handoffs/`、仓内 receipts | 单次运行证据与接力；只证明 exact subject |

## 调研与历史

| 位置 | 用途 |
|---|---|
| `research/INDEX.md` | 调研与 teardown 索引 |
| `research-archive-*.md`、`tech-baseline-*.md` | 历史研究/技术背景，按 freshness 定向读取 |
| `archive/current/2026-07-14-pre-governance-history-index.md` | CURRENT 收束前历史出口 |
| Git history | 被收束的旧 CURRENT/CLAUDE/README 原始快照 |

历史文档若与 live Git、当前 contracts/checkers、已生效 specs 或更新 decisions 冲突，只作 provenance，不得恢复成当前指令。

## 维护规则

- 新会话不全文读取 `lessons-learned.md` 或全部 handoffs；先走冷启动入口，再按任务检索。
- 当前状态只更新 `CURRENT.md`，采用整体替换，不在本地图追加“当前阶段”历史。
- 文档中的机器计数、digest、HEAD 和 runtime 状态必须绑定可复算来源；旧 prose 不能提升 proof class。
- 公开仓例外只认 `../contracts/governance/public-repo-exceptions.v1.json`。
- 结构卫生运行 `make verify-governance-hygiene`；完整产品/代码门仍按相关 Make/OpenSpec/runtime 合同执行。
