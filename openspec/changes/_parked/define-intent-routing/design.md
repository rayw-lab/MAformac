## Context

intent-routing 补 MAformac 二分→三分(规则 NLU / FC 快思考泛化 / 慢思考)。真实座舱三层原理 + 端状态参与 + 横切(多模指代/多意图/短期指代)。经 4 轮 cross-agent grill(判定 / 横切 / 端状态+FC泛化 / 规则L1+边界)+ pre-mortem(9 坑)收敛。三层都产候选 → change3 统一门消费;**intent-routing 不裁决,安全单一权威在 change3 DemoGuard**。依赖 change2(capability + routing_hints)+ change3(候选门)。全料 `docs/intent-routing-explore-2026-06-18.md`。

> **demo 边界元 tiger(贯穿)**:L1≠完整 NLU / G3≠开放词全覆盖 / 多模≠通用视觉 / stub≠已支持 / 编排≠通用 DAG。

## Goals / Non-Goals

**Goals:** 三层分流(route_kind 7 态)+ routing_hints + 端状态统一快照 + safe 谓词三层 + 多模指代场景库 + 统一候选门 + planned_stub 守红线 + golden set 回归门。
**Non-Goals:** 通用 NLU / 开放词全覆盖 / 通用视觉 / 编排 DAG / 长期记忆 / 真实 DMS;安全裁决(归 change3);二期真路由。

## Decisions

### ① IntentRoutingPolicy(判定机制,地基)
**词库决策树**(非 LLM 自判 / 非小模型分类器)。判定顺序:子句切分 → 精确 alias 命中=`rule_fast` → 感受词作 `context_tags`(不生第二动作)=`rule_fast_with_context` → 多意图按 capability+domain+exclusive_bus 判(同域=`rule_batch_fast` / 跨域=`slow_plan`)→ 开放词命中 semantic_map=`fc_fast_stateful` / 未覆盖=`clarify` → restraint 反例=`reject`。
**`route_kind` 7 态 enum**:rule_fast / rule_fast_with_context / rule_batch_fast / fc_fast_stateful / slow_plan / clarify / reject。
**T1 防护(套 change3 enum 原则)**:手写 `init(from:)`,`RouteKind.unknown` 解码成功 → 策略层转 `reject`,trace `route_reason=unknown_route_kind`;禁 `try!`/`try?`(防 YAML 拼错一字符炸全 payload → 启动黑屏)。

### ② routing_hints(capabilities.yaml 新增,MODIFIED vehicle-capabilities)
每 capability 下(**与 aliases 分离**):`implicit_tags`(冷/热/闷)/ `scene_tags`(下雨/隧道)/ `state_reads`(读哪些端状态)/ `fc_slots.semantic_map`(开放词→枚举 `{phrase, slot, value, scope:demo_only}`)/ `slow_triggers`。aliases 继续只管说法回收(归一化 + ASR 热词),**不当感受词库**。

### ③ ToolCallCandidate(统一候选门,对齐 change3 E1a)
三层都产候选(**不裁决**):`ToolCallCandidate{source(tool_event|content_json_fallback|rule_alias|fc_semantic), route_kind, capability_ids, arguments, slot_sources, resolved_refs, state_snapshot_id, plan_reason}`。**不加 `confidence` 字段**(避免候选误写成裁决)。候选 → change3 strict decode → DemoGuard(range/enum/preconditions/restraint 单一权威)→ execute → readback。指标拆 `trigger_rate / expected_tool_hit / guard_blocked_restraint / unsafe_false_pass=0`。

### ④ VehicleStateSnapshot(端状态,装逼核心)
`VehicleStateProvider.snapshot(turnId) -> {vehicle_cells(readback 权威) + environment(weather/speed/outside_temp/time) + occupants}`。phase1=DemoScenarioStateProvider;phase2 换真实源,routing/G4/guard/resolver 只依赖协议。
**双读模式**:environment/occupants 锁 snapshot;vehicle_cells guard 前读实时 store(防执行中漂)。
**5 环节读同一 `snapshot_id`**:routing / FC G4(current±delta) / DemoGuard(safe 谓词) / 多模指代(occupants) / 二级推荐。trace 含 `state_snapshot_id/state_reads/route_reason/guard_reason`。
**safe 谓词三层**:`capabilities.yaml.demo_guard.preconditions`(声明 requires_state/predicate_id/alternative_capabilities)/ `routing_hints.state_reads`(只提示,**非安全权威**)/ **DemoGuard 代码(唯一裁决 `safe(f,v,env)`)**——「时速120不能开窗」不漂三份规则。
**T2 防护**:turn 串行化 contract(guard 全程同步 / await 推到最前 / barge-in 取消 clean / resume re-validate)防 actor reentrancy 跨 await snapshot 陈旧。**进 risk,S5/S6 实装,不进本 change 实现 task**。

### ⑤ demo_scenarios + resolver + DialogueState(横切)
`demo_scenarios.yaml{id, display_zh, occupants[{seat,gender,clothing_color,clothing_item,age_group}], environment, scope:demo}` + scene picker 切 `current_scene_id`。resolver:属性匹配 + 唯一性校验(「她」→维度唯一可判定,**非通用消解**;demo 保证目标 occupant 在所用维度唯一)。
`DialogueState.last_frame_summary{capability_id, slots, resolved_zone, executed}` **+ 读端当前态**(「再调低两度」= current±delta,非 last_frame 数值运算)。
**E3 防护**:`scene_reset()` 清 `snapshot_id / resolved_refs / relative_delta_base / topic_stack`,**保留 semantic_map + aliases**;长期记忆 demo 豁免。

### ⑥ BatchCandidate + planned_stub(多意图)
`BatchCandidate{items[], batch_policy:sequential_best_effort, vehicle_read_mode:latest_before_guard, conflict_policy:keep_last}`。**`dependency_edges` 仅 optional 预留字段(phase1 不实现编排 DAG),`mutation_index` 仅 trace 执行序号**(收口 catch D);**同域冲突(罕见,如同 turn「开空调+关空调」)用 `conflict_policy:keep_last` 兜底,不引 priority_class 全套**(catch 2b 轻量回应——demo 批量多为独立意图)。批量内某子句 guard reject → 部分成功展示口径(前面已执行 UI 保留,mock 可逆)。
跨域子句(导航/音乐)→ `planned_stub`(**不进 ToolCallCandidate,只进 response plan**)→ 留产品路线钩子守红线(catch C):句式「导航和音乐是下一阶段可接能力,今天先把空调调低」,**禁说「已支持」**(demo-experience spec 禁声称二期已支持)。

### 待解冻 adopt:端到端 span 分层(Q1)
Mastra trace teardown 已归档到 `docs/research/2026-06-20-mastra-teardown-workflow-eval-trace.md`,38 项 backlog 归档到 `docs/优化待讨论-吸收内化措施38项-2026-06-20.md`。C4 解冻时 SHALL 产路由上层 span,挂同一个 `runId/traceId` 树；C3 五段仍只保留 `decode/plan/guard/execute/readback`,作为 C4 路由 span 的子树,不得把 `route/asr/understand` 塞进 C3 stage enum。Swift 侧显式传 `parentSpanId`,不采用 TS Proxy context 形态。

## Risks / Trade-offs(4 轮 grill catch + pre-mortem 9 坑,带来源)

- [grill catch 已落 Decisions] 二分→三分 / last_frame 读端态 / red_clothing→结构化属性 / 指代非通用消解 / G3 demo_only 覆盖(未覆盖 clarify 话术「这个颜色我先不猜,可以选大海蓝/暖白」,不说「不懂」)/ 统一 snapshot 一致性 / safe 谓词单一权威。
- [🔴T1 Codable unknown enum 炸全 payload] → 手写 `init(from:)`+unknown→reject(套 change3)。源:[Mobimeo](https://medium.com/mobimeo-technology/safely-decoding-enums-in-swift-1df532af9f42)。
- [🔴T2 actor reentrancy 跨 await snapshot 陈旧(barge-in 重入)] → turn 串行化 contract(进 risk,S5/S6 实装)。源:[Swift Senpai](https://swiftsenpai.com/swift/actor-reentrancy-problem/) / [SE-0306](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)。
- [🔴T3 冷启动首推理慢~10x 砸炸场第一句] → warmup contract(归 S5/S6 runtime risk,与 voice tiger5 同源)。源:[arXiv 2511.05502](https://arxiv.org/pdf/2511.05502)。
- [🔴T4 LLM 复演非确定性(temp=0 也不保证)] → 规则吃 80% + 炸场脚本核心走规则化,模型限即兴区。源:[Non-Determinism 2408.04667](https://arxiv.org/html/2408.04667v5) / [Zansara](https://www.zansara.dev/posts/2026-03-24-temp-0-llm/)。
- [🔴E1 新增 capability 抢路由无 golden set] → 本 change 埋 fixture,change6 跑回归门(呼应反 happy-path)。源:[Cobbai](https://cobbai.com/blog/ai-intent-tagging-support)。
- [E2 enum 改名破坏序列化] → 显式 CodingKeys + 新增关联值字段 optional(与 T1 同源)。源:[SE-0295](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0295-codable-synthesis-for-enums-with-associated-values.md)。
- [E3 切 scene DialogueState 残留] → `scene_reset()` contract(已落 ⑤)。
- [P1/P2 paper-tiger ASR 级联 / 多意图回滚] → 文本先行+push-to-talk / 全 mock 可逆 已结构性削弱,**不引 ASR 鲁棒层 / transaction**(YAGNI)。

## Migration Plan

新增 `intent-routing` capability + **对 change2 `vehicle-capabilities` ADDED 2 条 Requirement**(路由特征 + 安全前置,走 OpenSpec delta 改已 archive spec,不另开第二份 yaml)。三层产候选对接 change3 候选门(candidate `source` 枚举以本 change 扩展 change3 E1a 的 contentFallback)。golden set fixture(`fixtures/intent-routing/*.yaml`)喂 change6。**⚠️ change6 `vehicle-tool-bench/design.md:38 + :46` 的 `route(fast|slow)` 二分需 MODIFIED 为 `route_kind` 多态(防 `rule_batch_fast` 误归慢路径砸 must-pass 死门),apply 阶段处理**。回滚 git revert。

## Open Questions

- hassil Swift 迷你版 phase2 触发条件(demo 指令集扩大到 alias 匹配不够时)。
- G5 mini-spike(验 G3 开放词映射 / 状态增量 / negative-restraint / 候选 fallback,门槛 expected_tool_hit/guard_blocked_negative/unsafe_false_pass=0)排期(不阻塞 phase1 design)。
- planned_stub 批量「部分成功」的 UI 展示细节(已执行保留 vs 全有/全无)留 S2 UI 实装定。
