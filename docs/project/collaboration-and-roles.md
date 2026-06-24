# MAformac 协作分工与推进机制

> 配套 `CLAUDE.md`(项目宪法)。本文件定义**谁干什么、超长任务怎么用 harness 管控、agent 间怎么交接**。状态:candidate(随项目演进更新)。
> 更新:2026-06-17

## 1. 角色分工(磊哥 + 4 agent)

| 角色 | 主职责 | sweet spot | 不可代理 |
|---|---|---|---|
| **磊哥** | 项目总监;唯一拍板;发起 Codex 长跑;现场演示 | 战略/审美/听感判断 | **V-PASS(视觉)/ S-PASS(听感)/ U-PASS(战略)** |
| **Claude (CC)** | 和磊哥聊天/脑暴/规划/综合/跨 PR 元认知;**前端 + 原型设计**;openspec 编排;cross-vendor 二审 | narrative / synthesis / **前端原型 / 视觉** | — |
| **GPT Pro** | 和磊哥聊天/深度推理;heavy producer(one-shot 大产出);云端 GitHub PR 审计 | 深思 / 大体量回稿 / PR 审计 | — |
| **Codex** | **代码开发执行**(长跑,可连续 20h,质量高);boundary 守护;实装 | long runner / 实装 / 边界守护 | — |

**一句话**:磊哥拍板;Claude+GPT Pro 陪磊哥想清楚(what);Claude 出前端原型;Codex 把它写成代码(how);GPT Pro 云端审。

## 2. 协作流(意图 → 代码)

```
磊哥意图/脑暴
  ↔ Claude / GPT Pro   (聊清 what + 定 spec)
        │
        ├─► Claude: 前端 + 原型设计(SwiftUI 原型/视觉稿,给 Codex 视觉参照)
        │
        └─► openspec change(proposal/specs/design/tasks)= Claude/磊哥 ↔ Codex 的契约
                  │
                  └─► Codex: 按 tasks.md 长跑实装(TDD 红绿重构)
                            │
                            └─► GPT Pro / Claude: 审(cross-vendor)+ 磊哥 V/S/U-PASS
```

- **定 what**:磊哥 ↔ Claude/GPT Pro 聊天 → openspec `proposal`/`specs`(行为契约)。
- **前端/原型**:Claude 出 SwiftUI 原型 + 视觉(守审美 5 Gate),作为 Codex 实装的视觉参照。
- **实装**:Codex 按 `tasks.md` 长跑写代码(TDD)。
- **审**:GPT Pro 云端 GitHub PR 审计 + Claude 二审;磊哥最终 V/S/U-PASS。

## 3. 超长任务 harness(Codex 20h 连续跑的护栏)

Codex 可连续跑 20h、质量高——但**长跑必须有 harness 防跑偏**。三层管控:

| harness | 作用 | 谁产出 |
|---|---|---|
| **OpenSpec(SDD)** | change 的 `proposal/specs/design/tasks` = 长跑的 guardrail;Codex 按 `tasks.md` checklist 推进,完成即 `archive` merge 进 specs | Claude/磊哥定,Codex 执行 |
| **TDD** | 红绿重构:测试先行,Codex 实装走 RED→GREEN→REFACTOR,防"跑了 20h 跑歪" | Codex |
| **行为契约(spec)** | agree before build:`specs/`(Requirement+Scenario)先对齐,Codex 不偏离契约 | Claude/磊哥 |

**融合超长任务的方法**:把大目标拆成 openspec change → 每个 change 的 `tasks.md` 是 Codex 一次长跑的工作清单 → Codex 跑完 → archive → 下个 change。**spec/tasks 是 Claude(规划)与 Codex(实装)之间的唯一契约,不靠口头**。

## 4. 交接纪律

- **Claude → Codex**:交付 openspec change(proposal+specs+design+tasks),tasks 必须细到 Codex 可独立执行;前端原型/视觉稿随附。
- **Codex → 审**:产出走 GitHub PR → GPT Pro 云端 connector 审计 + Claude 二审 → 磊哥拍板。
- **跨 vendor 审计**:Codex 一审(boundary)+ Claude/GPT Pro 二审(catch 同 model bias),如本仓 `docs/second-review-2026-06-17/` 即 Codex 对 Claude 的二审范例。Codex subagent 审计只能算 same-vendor pre-check; 高风险 gate/signoff 必须明确是否完成异源/反框审计,或记录磊哥 waiver。
- **状态同步**:重大决策入 `docs/decisions.md`;跨 session 靠 `docs/handoffs/`。

## 4.5 长任务开发规范(Pi 形态吸收 #34-38,模板级,不引入 runtime/DB/hook 系统)

> 深扒 Pi(earendil-works/pi ⭐64k)协作层 → 吸收 3 个工程形态为长任务纪律(star>1000 不降级)。**只落模板级,零行代码进产品 runtime**(Pi 是 Node/agent loop,与 MAformac「三层路由+单发」runtime 哲学相反,只站它「让长任务可靠」的工程肩膀)。来源 `docs/research/2026-06-20-pi-teardown-collaboration-layer.md`。

1. **handoff append-only(事件溯源)**:`docs/handoffs/` **永不回改旧 handoff**,每 session 只 append 一条;当前状态 = 顺读全部 handoff 重放(不依赖记忆/快照)。治本反复失忆。
2. **七段 session-closure 硬模板**:每次收工 handoff 用固定七段——`Goal / Constraints & Preferences / Progress(Done/In Progress/Blocked) / Key Decisions / Next Steps / Critical Context`,**强令保留精确 `file:line` + 报错原文 + 碰过的文件血缘**。让任意 LLM/agent 无缝接力长任务。
3. **派单 before/after gate**:dispatch 验收门把「prevent rule」写进 schema 而非靠执行端自觉——**before**(动手前 grep 一手源、block 越界 / 禁区不改)+ **after**(动完读回 mock 态校验 / 报告附 ground-truth `swift test`+`git status`+`make verify` stdout)。落地 codex-metacognition §5。

> 边界:**不引入 Pi 的 Node runtime / agent loop / session DB / hook 系统**;不考虑 sandbox/隔离(内部 demo 本机单人)。

## 5. 边界(各角色都守)

- Codex 实装守 `CLAUDE.md` 边界:客户名一律「某车厂」、全 mock 车控、Python 零进 iOS、安全检查是代码不是 prompt。
- Claude 前端原型守**审美 5 Gate**(层级/对齐/遮挡/字体/重量)。
- 客户原始协议(讯飞表格等)+ 源 xlsx 冻结快照 **不进仓、不上云**;只抽象进 **C1 `contracts/semantic-function-contract.jsonl`**(源行级 SSOT,v2;旧 `capabilities.yaml` 已被 supersede),冻结快照在外部 raw 只读 + manifest 锚 content_digest。

## 6. 与 CLAUDE.md / openspec 的关系

本文件是**协作层**(谁干什么);`CLAUDE.md` 是**宪法层**(项目是什么+技术锁定);openspec 是**执行层**(change 怎么推进)。三者配套:宪法定边界,本文件定分工,openspec 管落地。

## 7. 想清楚 → 执行:Pocock / OpenSpec / Superpowers 三工具协作

> 磊哥 2026-06-17 定调。三者不冲突,是一条流水线;别一上来乱用技能,也别跳过"想清楚"直奔 propose。

| 工具 | 管什么 | 一句话 |
|---|---|---|
| **Pocock**(`~/.codex/skills/pocock`) | **现在处在哪一阶段** | 现有仓库二开的路由器:先分诊(S0 intake / S1 grill / S2 design / S3 spec / S4 build / S5 diagnose / S6 close),**只推荐一个主技能**,grill-first,写入门禁(dry-run)。 |
| **OpenSpec** | **做什么** | 变更与行为契约的事实源。车控 demo / 能力 schema / 安全门控 / LoRA trace 都先进 `openspec/changes/<change>/` 再落 `specs/`。 |
| **Superpowers** | **怎么高质量执行** | brainstorming / writing-plans / TDD / systematic-debugging / verification 等纪律技能,保证实现·测试·验证不虚。 |

```
Pocock 先判断这是什么活
   ↓
OpenSpec 把要做的行为 / 变更写成契约
   ↓
Superpowers 按工程纪律执行、验证、收口
```

**MAformac 推荐流水线**:
1. 模糊想法:`pocock` 分诊 + `openspec-explore` 拆问题(+ `superpowers:brainstorming` 设计探索)
2. 方向清楚:`/opsx:propose <change>` 生成 proposal / design / tasks / specs；AD 级决策进 `design.md` Architecture Decisions, `tasks.md` 只放执行步骤与证据 artifact
3. 实现:`/opsx:apply <change>` + 按需叠加 Superpowers(TDD / 调试 / 验证)
4. 做完:`openspec-sync-specs` 合 delta 回主规格 → `openspec-archive-change` 归档
5. 涉分支 / PR:Superpowers 收口类(verification / finishing-branch)+ GPT Pro 云端审

**铁律(2026-06-17 教训)**:起任何 change 前,**Pocock 先判断要不要先 grill / 设计拷打**;不跳过"想清楚"直奔 propose。
