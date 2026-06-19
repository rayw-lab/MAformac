> 范围:7-change 第 7 个 `define-intent-routing`。三层分流(规则 NLU / FC 快思考泛化 / 慢思考)+ 端状态 + 横切 + 统一候选门。**routing 产候选不裁决,安全归 change3 DemoGuard**。依赖 change2(capability)+ change3(候选门)。全料 `docs/intent-routing-explore-2026-06-18.md`。demo 边界:L1≠NLU / G3≠全覆盖 / 多模≠视觉 / stub≠已支持。

## 1. routing_hints schema(MODIFIED change2 vehicle-capabilities)

- [ ] 1.1 `contracts/capabilities.yaml` 每能力加 `routing_hints`(implicit_tags / scene_tags / state_reads / fc_slots.semantic_map[scope:demo_only] / slow_triggers),**与 aliases 分离**。验收:8 能力 routing_hints 齐 + aliases 不混感受词 + yaml 合法。
- [ ] 1.2 `demo_guard.preconditions` 扩 safe 谓词声明(requires_state / predicate_id / alternative_capabilities)。验收:带安全前置能力(cabin.window)声明 speed 谓词 + 替代能力。

## 2. IntentRoutingPolicy(route_kind 7 态 + 手写 decode)

- [ ] 2.1 `RouteKind` 7 态 enum + **手写 `init(from:)`**:unknown 值解码成功 → 策略层转 `reject`,trace `route_reason=unknown_route_kind`;**禁 try!/try?**(T1 防 YAML 拼错炸全 payload)。验收:未知 route_kind 不抛 dataCorrupted、不崩。**叠加 code review checklist**。
- [ ] 2.2 三层分流判定:子句切分 → alias 命中=rule_fast / 感受词 context_tags=rule_fast_with_context / 同域批量=rule_batch_fast / 跨域=slow_plan / semantic_map 命中=fc_fast_stateful / 未覆盖=clarify / restraint=reject。验收:5 幕话术路由正确(精确 / 模糊 / 同域批量 / 跨域)。**叠加 Superpowers: TDD**。
- [ ] 2.3 L1 规则快路径:`aliases → normalized_alias_match → ToolCallCandidate(rule_fast)`(8 能力 aliases 够;**hassil 文法 phase2 不做**)。验收:精确指令直出候选不经模型。

## 3. ToolCallCandidate(统一候选门,对接 change3)

- [ ] 3.1 `ToolCallCandidate{source / route_kind / capability_ids / arguments / slot_sources / resolved_refs / state_snapshot_id / plan_reason}`,**不加 confidence**(避免候选误写裁决)。验收:三层产同构候选 + 字段齐。
- [ ] 3.2 对接 change3 候选门:候选 → strict decode → DemoGuard,routing **不裁决**。验收:routing 产候选,range/enum/preconditions/restraint 裁决全在 DemoGuard。

## 4. VehicleStateSnapshot(端状态 + safe 谓词三层)

- [ ] 4.1 `VehicleStateProvider.snapshot(turnId) -> {vehicle_cells / environment / occupants}`,phase1=DemoScenarioStateProvider(phase2 换真实源不改逻辑)。验收:一次话轮一个 snapshot。
- [ ] 4.2 双读模式 + 5 环节读同一 snapshot_id;trace 含 state_snapshot_id / state_reads / route_reason / guard_reason。验收:同句话内状态一致(environment/occupants 锁 snapshot,vehicle_cells guard 前读实时)。
- [ ] 4.3 FC G4 状态增量(规则化 delta):「我有点冷」读温度升温+座椅、「再调低两度」current±delta。验收:增量基于端当前值,非 last_frame 直接运算。
- [ ] 4.4 safe 谓词三层:preconditions 声明 + routing_hints.state_reads 提示 + **DemoGuard 唯一裁决**。验收:「时速120不能开窗」guard 拒 + 二级推荐(降温/通风);safe 逻辑不在 routing。

## 5. demo_scenarios + resolver + DialogueState(横切)

- [ ] 5.1 `contracts/demo_scenarios.yaml`(id / display_zh / occupants[结构化属性 seat/gender/clothing_color/clothing_item/age_group] / environment / scope:demo)+ scene picker。验收:N 场景预设 + 切 current_scene_id。
- [ ] 5.2 resolver 多模指代:属性匹配 + 唯一性校验(「她/副驾红衣女性」→ position=passenger,**非通用消解**)。验收:demo 场景目标 occupant 维度唯一可判定。
- [ ] 5.3 DialogueState 短期指代:last_frame_summary + 读端当前态;`scene_reset()` 清 snapshot_id / resolved_refs / relative_delta_base / topic_stack,**留 semantic_map + aliases**(E3)。验收:demo 2 轮指代;切 scene 无残留污染。

## 6. BatchCandidate + planned_stub(多意图)

- [ ] 6.1 `BatchCandidate{items / batch_policy:sequential_best_effort / vehicle_read_mode:latest_before_guard / conflict_policy:keep_last}`;**dependency_edges 仅 optional 预留(不实现编排 DAG)、mutation_index 仅 trace 序号**(收口 catch D);同域冲突 `conflict_policy:keep_last` 兜底(catch 2b,不引 priority 全套)。验收:同域批量执行;独立意图无 inter-clause 依赖;同域冲突(如同 turn「开/关空调」)保最后一个。
- [ ] 6.2 planned_stub:跨域子句**不进 ToolCallCandidate,只进 response plan**;留产品路线钩子守红线(禁「已支持」)。验收:「导航回家放歌调空调」车控执行 + 导航/音乐占位话术「下一阶段可接」。

## 7. golden set 回归门(本 change 埋 fixture,E1)

- [ ] 7.1 `fixtures/intent-routing/*.yaml`(utterance / expected_route_kind / expected_capability_ids / expected_candidate_or_stub / scene_id?),每能力配 fixture。验收:8 能力 + 5 幕话术有 fixture;change6 后续消费跑回归门。**叠加 Superpowers: verification**。

## 8. 验证与 demo 边界守护

- [ ] 8.1 `openspec validate define-intent-routing` 通过;route_kind unknown 不炸;clarify 兜底话术(「这个颜色我先不猜,可以选大海蓝/暖白」,**非主展示路径**)。验收:validate pass + clarify 防崩。
- [ ] 8.2 脱敏:demo_scenarios occupants/environment 无真实车型/客户/PII(预设抽象)。验收:脱敏 validator(fail-closed)通过。
- [ ] 8.3 demo 边界守护:L1 不写完整 NLU / G3 不写开放词全覆盖 / 多模不写通用视觉 / stub 不写已支持。验收:design Non-goals 全守。
- [ ] 8.4 异常路径失败口径:snapshot 取不到 / resolver 唯一性校验失败 / semantic_map 命中但 value 非法 等,统一写 trace failure(risk_state 枚举 + 实际异常),不静默吞。验收:5+ 异常路径有 failure receipt(table-driven test)。

> 跨 change(apply 阶段):**change6 `vehicle-tool-bench/design.md:38/:46` route(fast|slow) 二分 → MODIFIED 为 route_kind 多态**(防 rule_batch_fast 误归慢,见 proposal Impact)。
> T2 turn 串行化 + T3 warmup 进 design risk,**S5/S6 runtime 实装,不在本 change task**。
