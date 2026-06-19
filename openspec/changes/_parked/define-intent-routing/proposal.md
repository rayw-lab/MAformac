## Why

真实座舱语音是**三层**(规则 NLU / FC 快思考泛化 / 慢思考),MAformac 现有「规则快路径 + LLM 慢路径」**二分漏掉中间 FC 快思考泛化层**(单意图 + 读端状态生成增量,如「我有点冷」读当前温度升温、「大海颜色」→氛围灯色值,NLU 查表做不了但仍快路径,不进 2.5s 慢思考)。本 change 补三层分流 + 端状态参与 + 横切(多模指代/多意图/短期指代),让 demo「懂场景 / 懂安全 / 懂状态」——这是 demo 的装逼核心。经 4 轮 cross-agent grill + pre-mortem(9 坑)收敛,全料见 `docs/intent-routing-explore-2026-06-18.md` + `docs/cockpit-voice-fc-premortem-2026-06-18.md`。

## What Changes

- **IntentRoutingPolicy**:词库决策树判定(**非 LLM 自判 / 非小模型分类器**),`route_kind` 7 态 enum,三层分流。
- **routing_hints**:capabilities.yaml 新增路由特征字段(**与 aliases 分离**,aliases 只管说法回收),走 MODIFIED vehicle-capabilities delta。
- **VehicleStateSnapshot**:端状态统一快照(turnId)+ 双读模式 + safe 谓词三层(YAML 声明 / routing 提示 / DemoGuard 唯一裁决)。
- **demo_scenarios + resolver + DialogueState**:多模指代场景库(**预设座舱感知信号,非真 DMS 实时识别**)+ 短期指代(承接相对量读端当前态)。
- **统一候选门**:三层都产 `ToolCallCandidate` → change3 strict decode + DemoGuard,**routing 不裁决**。
- **planned_stub**:跨域(导航/音乐)留产品路线钩子守红线,**不假执行**。

## Capabilities

### New Capabilities
- `intent-routing`:三层分流 + 端状态参与 + 横切(指代/多意图/短期记忆)+ 统一候选的行为契约。

### Modified Capabilities
- `vehicle-capabilities`:每能力新增 `routing_hints`(路由特征,与 aliases 分离)。

## Non-goals

- ❌ 通用 NLU(L1 只 alias 精确/归一化匹配,hassil 文法 phase2)/ 通用开放词映射(G3 只 `semantic_map` scope=demo_only,未覆盖转 clarify)/ 通用视觉多模(只 ⑤ 场景演示)/ 通用编排 DAG(`dependency_edges` 仅预留,phase1 不实现)/ 长期记忆(demo 豁免)/ 真实 DMS 实时识别(预设信号驱动)。
- ❌ 安全裁决(归 change3 DemoGuard 单一权威);intent-routing 只产**候选**不执行。
- ❌ 二期 domain 真路由(导航/音乐 `planned_stub` 占位,不进 ToolCallFrame)。

## Success Criteria(可验收)

- **5 幕路由正确**:精确指令→`rule_fast`;模糊「我有点冷」→`fc_fast_stateful` 读端当前温度生成增量(升温+座椅);多模「给副驾红衣女性开窗」→指代消解 `position=passenger`;同域多操作「空调和车窗」→`rule_batch_fast`(不升慢);跨域「导航回家放歌调空调」→车控执行 + 导航音乐 `planned_stub`。
- **端状态参与**:同 turn 五环节读同一 `snapshot_id`;「时速120不能开窗」safe 谓词拒 + 二级推荐(降温/通风);trace 含 `state_snapshot_id / route_reason / guard_reason`。
- **golden set 回归**:每能力配 fixture,新增能力不破坏已有路由(本 change 埋 fixture,change6 跑全量评分)。
- **route_kind unknown 不炸 payload**:手写 decode → `RouteKind.unknown` → 策略层转 `reject`,trace `route_reason=unknown_route_kind`。
- (主观信号,**单列非自动化**)demo 现场炸场流畅、客户「哇」或追问合作。

## Impact

- **对 change2 `vehicle-capabilities` ADDED 2 条 Requirement**(路由特征 + 安全前置;走 OpenSpec delta 修改已 archive spec,不另开第二份 yaml)。
- **对接 change3** `execution-contract`(三层产 ToolCallCandidate → 统一候选门 + DemoGuard;candidate `source` 枚举以**本 change 扩展 change3 E1a** 的 contentFallback,本 change 为权威)。
- golden set fixture **喂 change6** `vehicle-tool-bench`(回归门)。
- **⚠️ change6 待对齐(apply 阶段)**:`vehicle-tool-bench/design.md:38 + :46` 的 `route(fast|slow)` 二分会把 `rule_batch_fast`(本 change 明确「不升慢」)误归慢路径 → 套错延迟预算 / fixture expected 对不上 / 砸 must-pass=100% 死门。apply 时 MODIFIED change6 的 route 二分为 `route_kind` 多态。
- 路线 7-change 第 7 个;依赖 change2(capability 定义)+ change3(候选门)。
