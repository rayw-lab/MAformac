# define-intent-routing — Explore 笔记（grill 累积,2026-06-18）

> ⚠️ **HISTORICAL 快照（2026-06-18）—— 文档级联 banner（2026-06-23）**
> 本文是 intent-routing 早期 explore 笔记（对应 change 已 PARKED，见 `openspec/changes/_parked/README.md`）。三层路由现重定在 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md §4`；范式翻案后 generic-frame intent-routing 已被 supersede（→ D-domain 具名工具）。**活基线** = `CLAUDE.md §9` + `docs/srd-three-layer-intent-routing.md`。正文保留供溯源，勿据此推进。

> brainstorming grill-first 进行中,逐项聊透,**未到 propose**(agree before build)。cross-agent grill 模式:Claude 出问题 → 另一窗口(Codex 系)answer → Claude 辩证吸收。完整三层原理见 `docs/cockpit-voice-fc-premortem-2026-06-18.md`。

## ✅ 已定（grill #1：判定机制）

**采 A,落成 `IntentRoutingPolicy`（不叫"词库决策树"）。** Pre-Mortem:C 裸 LLM 自判 **HIGH no-go**(判定压未验证 base 1.7B,风险叠加);B 小模型首版不划算。外部印证:Qwen 官方"模型选函数、应用执行"(模型**无执行权**)/ Rasa·AWS Lex fallback 靠阈值+测试数据 / Dialogflow 负样本避误匹配。

**四件套物理形态**(非散词库):
1. `capabilities.yaml.aliases` — 只负责**精确/近精确说法回收**(归一化 + ASR 热词),**不混用成感受词库**。
2. **新增 `routing_hints`**(每 capability 下) — 字段:`implicit_tags`(冷/热/闷)/`scene_tags`(下雨/隧道)/`state_reads`(读哪些端状态)/`fc_slots`(开放词槽)/`slow_triggers`(慢思考触发)。例:cabin.ac aliases 放"打开空调/我有点冷",但"冷/热/闷"进 `routing_hints.implicit_tags`。
3. **`route_kind` enum**(替代旧 fast|slow 二分),**7 态**(含 CC 补的 rule_batch_fast):`rule_fast / rule_fast_with_context / rule_batch_fast / fc_fast_stateful / slow_plan / clarify / reject`。
4. **restraint 负样本**(必做,印证 Dialogflow/Rasa)。

**判定顺序**:子句切分 → 精确命令命中 = `rule_fast`;感受词只作 `context_tags` 给参数默认值(不生成第二动作,"有点热打开空调" = `rule_fast_with_context` 不升慢);多意图按 **capability id + domain/exclusive_bus/状态依赖** 判("打开空调和车窗" = 同域 `rule_batch_fast` 不升慢;"导航回家放歌调空调" = 跨域 `slow_plan`;DMS = 多模指代横切)。

**trace 增**:`clause_count / capability_ids / route_kind / route_reason / dependency_edges`(⑤ 场景炫要讲清为什么慢)。

## 🔴 待对齐漂移（intent-routing apply 时处理,跨 change 影响）
- **change6 eval `route(fast|slow)` 二分 → 改 route_kind 多态**:已核实 `define-vehicle-tool-bench/design.md:38 + :46` 真有二分 → 会把 `rule_batch_fast` 误归慢。intent-routing 顺带 MODIFIED change6,或 change6 apply 时对齐。
- **`routing_hints` 加进 capabilities.yaml = MODIFIED change2 已 archive 契约**(openspec MODIFIED delta;连带 vehicle-capabilities spec)。
- 元口径:把"模糊=慢"旧二分从 spec/eval 全清。

## ✅ 已定（grill #2：横切层 demo 落法）

**对方 answer 主体对(收边正确),CC+raw scout 补 6 catch(不迎合)。** 引用核实:agents.yaml:21 / tech-baseline:271 / brainstorm:26 全准。

**收边(对方对,给过)**:多模指代**不建通用系统**,只 `demo_scenarios.yaml → current_scene_id → resolver` 窄链路;"预设座舱感知信号驱动的场景演示"= 真实 DMS 下游接法(真实 DMS 外采独立模块,座舱拿结构化信号,demo 预设 occupants 架构同构);短/长记忆分离 = 真实三层架构;长期记忆 demo 豁免。

**6 catch(raw 真实座舱佐证,按严重度)**:
| # | catch | 级 | 修正 |
|---|---|---|---|
| 3a | **last_frame_summary 不够撑「再调低两度」** | 🔴HIGH | 真实承接控制类 = context rewrite(改写指令再走 NLU)+ 值落端状态;相对量 `current_value ± delta` **必读端 mock 当前态**,非 last_frame 数值运算 |
| 1a | red_clothing=true 布尔失真 | 🟡MED | occupant attrs 结构化 `{seat,gender,clothing_color,clothing_item,age_group}` + 属性匹配(否则现场"蓝衣服"穿帮) |
| 2a | planned_stub 应"诚实抛弃"非 coming soon | 🟡MED | 真实座舱诚实告知"这次做不了"+统一兜底语;话术"导航音乐先不演"不留"啥时候有"钩子 |
| 2b | 漏 priority/conflict 字段 | 🟡MED | 多意图带 `{domain,priority_class,conflict_state}`,同域保最后一个 |
| 3b | "她→passenger" 绕过消解 | 🟡MED | demo 保证维度唯一可判定 + design 标"预设唯一性,非通用消解" |
| 3c | 5min/5轮清空=dead code | 🟢LOW | demo 豁免清空(生产约束误植违轻治理);last_frame 存最近 2 轮对 |
| 1b | schema 只容一维 | 🟢LOW | demo_scenarios occupant 留多维(relation/nickname/clothing/gender/child) |

**横切层第一刀(收边后)**:`demo_scenarios.yaml`(occupants 结构化属性+environment)+ `current_scene_id`(scene picker)+ resolver(属性匹配+唯一性校验)+ `planned_stub`(诚实抛弃+兜底话术)+ `DialogueState.last_frame_summary` **+ 读端当前态**(承接相对量)。刘洋 kb=周报非技术库,印证多意图=Master Agent 编排(demo 规则拆句替代,design 注明)。

## 🔬 spike E3 审计回流（cross-vendor CC 独立审,2026-06-18,数字 100% 复现）

**🎯 CC catch Codex/Bohr 都漏的事实**:**G2 22.5% content 伪工具不是「模型不会调」,是「走错输出通道」**——9 条漏触发 100% 是裸 JSON(无 `<tool_call>` 标签),7/9 语义完全正确。**base 真实意图正确率 = 35/40 = 87.5%,非 77.5%**。根因(读上游源码证实):mlx-swift-lm `.json` parser 只认 `<tool_call>` 标签,裸 JSON 当文本透传不 fallback;base 1.7B 部分能力(screen_brightness 全崩)忘包裹标签。

**落点(实测回流)**:
- 🔴 **change3**:加 **content-fallback 正则**(只兜裸 `{"name":...,"arguments":...}`,**非重建 `<tool_call>` 解析**,守"adopt 上游不自建")→ G1 77.5%→~95%(38/40),LoRA 之前安全网。
- 🔴 **change5 LoRA 重定义**:主要不是"教意图"(已 87.5%),是**"教稳定输出 `<tool_call>` 包裹"**(格式对齐,样本少收敛快);Day1 优先采 screen_brightness 类格式崩塌负样本。
- **spike report 修正**:G5 仅 2 样本=噪声→"参数规划**未验证**"(非"50%");G3 15 负例偏少(正式 benchmark 扩 50+)。

## ✅ 已定（grill #3：端状态全流程 + FC 泛化层）

**核心 = 统一 `VehicleStateSnapshot`(窗口2 强 catch,补 CC 倾向盲点)。** 最大 tiger 不是 phase2 接真实信号,而是 **phase1 多处读状态致同句话内状态不一致** → 一次话轮生成一个 snapshot,五环节读同一 `snapshot_id`。

**端状态模型**:`VehicleStateProvider.snapshot(turnId) -> VehicleStateSnapshot{vehicle_cells(DemoVehicleStateStore,readback 权威) + environment(weather/speed/outside_temp/time) + occupants}`。phase1=DemoScenarioStateProvider(预设+mock车控实时);phase2 换真实源,routing/G4/guard/resolver 只依赖协议。

**5 环节读状态**(同 snapshot_id):①routing(scene_tags/state_reads) ②FC G4(current±delta) ③DemoGuard(safe谓词) ④多模指代(occupants) ⑤二级推荐(极值转替代)。trace 必含 `state_snapshot_id/state_reads/route_reason/guard_reason`。

**safe 谓词三层分工**(YAML 声明,代码裁决,guard 单一权威):`capabilities.yaml.demo_guard.preconditions`(requires_state/predicate_id/alternative_capabilities 数据+阈值)/ `routing_hints.state_reads`(只提示要读状态,**非安全权威**)/ `DemoGuard` 代码(唯一执行 `safe(f,v,env)`)。防"时速120不能开窗"漂成三份规则。

**FC 泛化层**:G4 必做不等 spike(③幕核心,规则化 delta);G3 端侧 `semantic_map` 先行("大海颜色→ambient_light.blue/cyan"、"下雨→window.close+recirculation"),LLM 兜底产候选仍过统一门;补 G5 mini-spike(验开放词映射/状态增量/negative-restraint/候选fallback,门槛 expected_tool_hit/guard_blocked_negative/unsafe_false_pass=0),不阻塞 phase1。

**统一候选门**(对齐 change3 E1a):`.toolCall` + 裸 JSON fallback 都只产 `ToolCallCandidate(source=tool_event|content_json_fallback)` → strict decode → DemoGuard → execute → readback。指标拆 trigger_rate/expected_tool_hit/guard_blocked_restraint/unsafe_false_pass=0。

**CC 补 3 catch(辩证窗口2)**:
- A 🟡 批量多意图 inter-clause 状态依赖:统一 snapshot 防同句飘,但批量执行中车控态变,第二 clause 读 stale 还是实时?→ environment/occupants 锁 turn snapshot;vehicle_cells 决策用起点,批量内显式声明"不保证 inter-clause 可见"。
- B 🟡 G3 semantic_map 覆盖有限 + LLM 兜底不稳(G5 base"夜晚海边→warm"错):demo 限定炸场词在 semantic_map,没覆盖转澄清,标"非通用开放词映射"。
- C 🔴 **planned_stub framing 张力(待磊哥拍)**:grill#2 raw scout="诚实抛弃别留钩子"(量产);grill#3 窗口2 + brainstorm:50="留产品路线钩子"(demo ⑤ 收尾卖产品)。**demo 语境留钩子对(与量产相反),demo vs 量产又一划线**。

## ✅ 已定（grill #4：规则 L1 + 收口 + 边界）+ catch C 拍板

**catch C 拍板(磊哥)**:⑤ 收尾 planned_stub 走「留产品路线钩子」,守红线——不说"已支持导航/音乐"、不假装执行,句式"导航和音乐是下一阶段可接能力,今天先用本地车控把空调调低"(agents:21 enabled:false + demo-experience spec:74 禁声称已支持)。**留钩子可以,冒充完成不行。**

**grill #4 物理形态(窗口 answer + CC catch D/E)**:
- Q1 L1:`aliases → normalized_alias_match → ToolCallCandidate(route_kind=rule_fast, match_source=alias_exact|alias_normalized)`;8 能力 aliases 够 demo 80%,hassil 文法 phase2。
- Q2 批量双读:`BatchCandidate{items[], batch_policy=sequential_best_effort, env_snapshot_id, vehicle_read_mode=latest_before_guard, mutation_index, dependency_edges}`;env/occupants 锁 snapshot,vehicle_cells guard 前读实时。**CC catch D**:dependency_edges/mutation_index 对 demo YAGNI(批量都独立意图)→ 标记预留,phase1 不实现。
- Q3 G3:`routing_hints.fc_slots.semantic_map` 只放 must-pass 炸场词 `{phrase:大海颜色, slot:color, value:blue, scope:demo_only}`;没覆盖 route_kind=clarify。**CC catch E**:clarify 是兜底防崩非炸场,demo 脚本保证炸场词覆盖 + 话术优雅。
- Q4 边界:`ToolCallCandidate{source, route_kind, capability_ids, arguments, slot_sources, resolved_refs, state_snapshot_id, plan_reason}`;routing 填 state_reads/requires_guard,**range/enum/preconditions/restraint 裁决只归 DemoGuard**(单一权威)。
- 元 tiger:把 demo 口径写成通用能力(L1≠完整NLU / G3≠开放词全覆盖 / 多模≠通用视觉 / stub≠已支持)。

## 🔬 Pre-Mortem(propose 前,oracle 联网 7 路,9 新坑超 4 轮 grill)

**🐯 Tiger(4 HIGH,进 design Risks):**
- T1 **Codable unknown enum 炸全 payload**:route_kind YAML 拼错一字符 → 整个 capabilities.yaml 解码失败 → demo 启动黑屏。→ **change3 已有"enum 手写 init(from:)+unknown+禁try!/try?"原则,intent-routing 套用到 route_kind/routing_hints/demo_scenarios**(同源扩用)。源:[Mobimeo](https://medium.com/mobimeo-technology/safely-decoding-enums-in-swift-1df532af9f42)。
- T2 **actor reentrancy 跨 await snapshot 陈旧**(时间一致 ≠ 空间一致):barge-in 打断制造重入,turn N guard 在 await 中被 turn N+1 污染。→ turn 串行化 contract(guard 同步/await 推前/resume re-validate/turn 排队)。源:[Swift Senpai](https://swiftsenpai.com/swift/actor-reentrancy-problem/)。
- T3 **冷启动首推理慢~10x 砸炸场第一句**:MLX 懒加载+Metal shader 首编译+mmap 缺页。→ **与 voice tiger5 warm-up 同源**,归 S5/S6 runtime,warmup contract。源:[arXiv 2511.05502](https://arxiv.org/pdf/2511.05502)。
- T4 **LLM 复演非确定性**(temp=0 也不保证):客户"再演一遍"第二次不同。→ **设计已部分防(规则吃80%)**,炸场脚本核心 query 全走规则化,模型限即兴区。源:[Zansara](https://www.zansara.dev/posts/2026-03-24-temp-0-llm/)。

**🧸 Paper-tiger(设计已削弱,别改):**
- P1 ASR 级联 → 文本先行+push-to-talk+结构化场景三重削弱。
- P2 多意图回滚 → 全 mock 可逆,别引 transaction(补"部分成功展示口径")。

**🐘 Elephant(3,E1 HIGH-ish):**
- E1 **新增 capability 抢路由无 golden set 回归门**:8 条不撞,第9/10条必撞悄悄吸流量。→ **呼应磊哥反 happy-path + 弹药盘点固定演示集回归**,S3 埋 golden set(每样板配 fixture,改 yaml 跑回归)。源:[Cobbai](https://cobbai.com/blog/ai-intent-tagging-support)。
- E2 enum 改名静默破坏序列化 → 显式 CodingKeys + 新增字段 optional(与 T1 同源)。
- E3 切 scene 后 DialogueState 残留 → scene reset contract(清 snapshot+指代栈+相对量基线,留词库)。

**6 HIGH propose 前回应**:T1/T2/T3/T4 + E1 + E2。

## 📐 收敛状态 → ✅ propose done(2026-06-19)
7 段 design 全 approve(磊哥)+ 2 拍板(a routing_hints 走 MODIFIED vehicle-capabilities delta 不另开 yaml / b golden set 本 change 埋 fixture、change6 跑全量)+ 2 收口(dependency_edges 仅预留、clarify 兜底非主路径)。
**propose done**:`openspec validate` ✅,4 artifact——proposal / design(6段决策+9坑Risks带来源+Migration) / specs(intent-routing 9 Req + vehicle-capabilities ADDED delta) / tasks(8 组 20 条)。
路线 **7-change 第 7 个**;依赖 change2(capability)+ change3(候选门)。**apply 待 change3 主体实装(统一候选门)**;routing_hints schema(MODIFIED change2)可先行。
