# SimuHome 蓝本 工程/算法 teardown — MAformac C6（状态型 case）的状态引擎 + 时间核 + verifier

> **缘起**：磊哥要求 blueprint-teardown 深扒 `holi-lab/SimuHome`（ICLR26 Oral，pushed=2026-04-08 / updated=2026-06-12，活跃）——MAformac **C6（vehicle-tool-bench）的「状态型 case」蓝本**。本机 clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/simuhome`（CLAUDE §6：只读参考，**不进仓**）。
> **License = CC BY-NC-ND 4.0**：只**抽方法/设计形态翻译成 Swift 思想**，**不复制代码**、不进训练集、不上公开仓。本文所有片段是「机制描述 + 行号锚点」，非可 import 代码。
> **本文 = runtime 状态引擎 + 时间核 + 生成/评测管线逐文件拆解**（带 `file:line`）。前置 SimuHome 已在 `2026-06-20-eval-oracle-blindspots-repo-scan.md` 标为 C6 stateful-case 关键源（item #3 即"对 SimuHome 做代码级 teardown：抽 state tick / schedule workflow / eval resume"），本文交付该项。
> **核心结论**：SimuHome 让"设备动作→环境随时间演化"可信的，**不是物理引擎，而是一组工程旋钮**——**单线程 tick 环 + 虚拟时间与墙钟解耦 + 比例控制+基线回归的环境模型 + fast-forward 批进与逐 tick 环的字节级 parity 守护 + 两段式 verifier（确定性必做动作门 + LLM 裁判面板）+ 时间窗容差校验**。这些恰好是 MAformac C6"状态型 case = 端态随时间演化 / 延迟生效 / 拒识"该抄的工程，且全部可在**纯端侧 Swift mock 内核**复刻（无外部系统方）。

---

## §0 它是什么（一句话定位 + 与 home-llm 的分工）

SimuHome = **时间加速的智能家居模拟器 + LLM agent benchmark**，基于 Matter 协议。设备动作**持续影响环境变量**（温度/湿度/PM10/照度），agent 必须就这些变化推理；支持**虚拟时间工作流调度**（agent 可把多步动作排到未来某时刻执行，与时间敏感目标协调）。任务分 qt1–qt4 × {feasible / infeasible}。

| 蓝本 | 在 MAformac 的角色 | 抄什么 |
|---|---|---|
| **home-llm**（已 teardown） | runtime 推理集成 + C5 LoRA 数据 | 单发旋钮 / 防御解析 / 双向单位归一化 / KV 预热 / 三重白名单 |
| **SimuHome**（本文） | **C6 状态型 case 的状态引擎 + verifier + 时间核** | tick 环 / 虚拟时间 / 环境演化模型 / parity 守护 / 两段式 verifier / 时间窗校验 / feasibility oracle |

> 互补：home-llm 教"模型怎么单跳产 ToolCall + code 归一化"；SimuHome 教"ToolCall 落到 mock 端态后，端态怎么随时间演化、怎么验收（含延迟生效/拒识/时间窗）"。MAformac 的 DemoGuard + mock state + trace（C3）+ bench（C6）正好需要后者。

---

## §1 状态引擎 `src/simulator/domain/home.py`（1424 行）— 单线程 tick 环 + 虚拟时间核

整个模拟器的心脏。**单写者线程 + 队列**架构（不是多线程改共享态），是其确定性的根。

### 🔴 单线程仿真环 `__simulation_loop`（line 171-208）
每 tick 固定四步串行：`__process_time_aware_devices`（设备自演化，如洗衣机倒计时）→ `__process_aggregators`（环境聚合器算 device→env 影响）→ `__process_schedular_queue`（到期工作流派发）→ `__process_api_queue`（处理外部 API）。
- **关键旋钮 `fast_forward`**（line 184-189）：非快进模式 `time.sleep(tick_interval - elapsed)` 把 tick 锁到墙钟节拍；快进模式不 sleep，纯算力推进。→ **同一套逻辑，real-time 演示 vs 批量评测两用**。
- 致命错误捕获（line 201-206）：循环内任何异常 → 存 `_fatal_error` + 停环 + cleanup，不让坏态扩散。

### 🔴 虚拟时间与墙钟解耦（line 41-44, 624-633, 1001-1040）
- `virtual_epoch_seconds`（基准时刻）+ `virtual_offset_seconds` + `current_tick × tick_interval` = 虚拟当前秒（`get_virtual_now_seconds` line 624-627）。**虚拟时间 = tick 计数的纯函数**，与真实耗时无关。
- **`set_tick_interval` 改节拍时保持虚拟时间连续**（line 1019-1023）：`virtual_offset = previous_virtual_now - current_tick × new_interval`——改采样精度不跳时间。这是"时间可变速但单调连续"的工程保证。

### 🔴 外部 API 单写者队列 `queue_api`（line 86-160）
外部请求**不直接改态**，而是入 `api_queue`，由仿真线程在 tick 内消费，回填结果到 `response_results` + `threading.Event` 唤醒调用方。
- 请求状态机：`queued → processing → completed`（line 110, 395, 422），加 `cancelled`（超时，line 145）。
- 超时取消保护（line 141-150）：仅 `queued`（还没开始处理）可取消；已 `processing` 必等完（line 134-136），防半完成态。
- **意义**：所有写经单一队列串行 → 无锁竞争 → 可复现。MAformac mock 内核同理可用「单 actor 串行处理 ToolCall」替代多处直接改 `@Published` 态。

### 🔴 工作流调度 = 优先队列按 due_tick 排（line 47-49, 635-715, 280-305）
- `schedule_workflow`（line 635-715）：把 `start_time` 字符串转 `due_tick = ceil((start_s - offset)/tick_interval)`（line 681-685），入 `PriorityQueue[(due_tick, seq, "workflow", wf_id)]`。`task_seq_counter` 作 FIFO tie-break（line 702）→ 同 tick 多任务稳定顺序。
- **拒绝过去时间**（line 674-679）：`start_time` 必须 > 当前虚拟时间，否则 VALIDATION_ERROR。
- `__process_schedular_queue`（line 280-305）：peek 队头，`due_tick <= current_tick` 才派发，否则原样塞回 break（堆顶没到期，后面更不到期 → 提前退出，O(1) 检查）。
- **工具白名单**（line 647, 732）：workflow step 只允许 `{execute_command, write_attribute}`——调度层也守白名单。
- 两种执行：`schedule_workflow`（排未来）vs `_run_workflow_now`（line 717-797，立即跑，带 `continue_on_error` 续错语义 + 逐 step result）。

### 🔴 环境控制规则 `_get_environment_control_rules`（line 1180-1424）— required/optional 动作配方
给定要控的环境量（temperature/humidity/air_quality/illuminance），返回**每种设备的「required 必做 + optional 可选」动作清单 + note 自然语言说明**。例：降温必须（AC 开机 + SystemMode=Cool=3 + CoolingSetpoint<当前）+ 至少一个 optional（风量非零之一）。
- **这是 verifier 的契约源**：episode 的 `required_actions` 就从这套规则派生。
- **MAformac 直接映射**：MAformac C1 的 `semantic-function-contract`（device×原语×槽）+ C2 `scenario_required` 正好是这层；可借「required + optional + note」三段结构表达「达成端态目标的最小动作集 + 可选增强」。

### fast-forward 批进 `_fast_forward_to`（line 567-622）— 见 §3

---

## §2 环境演化模型 `aggregators/`（base 135 + temperature 280 + humidity 187 + pm10/illuminance）— 比例控制 + 基线回归

让"开了空调温度会慢慢降"可信的核心。**不是真物理，是一组可解释的控制律**，刻意设计成"可批量精确推进"。

### Aggregator 基类双阶段 `on_time_tick`（base.py line 29-47）
每 tick：①首次 sync 环境→设备传感器（line 32-34）②**只轮询「感兴趣设备」且状态变化的**（`_poll_interested_devices_only` line 49-65，靠 `hash(sorted(attrs))` 签名 diff）③有变才 `_recalculate`（懒计算，省算力）④ `_on_time_tick_extra`（积分一步）⑤回写传感器。
- **状态签名 diff（line 67-77）**：`hash(tuple(sorted(get_all_attributes().items())))`——设备态没变就跳过重算，是"只在事件边界重算、其余 tick 只做积分"的关键优化。

### 🔴 温度模型 `temperature.py`（line 89-211）— 比例控制 + 速率封顶 + 基线回归
- **per-device 连续效应** `_calculate_device_effect`（line 94-199）：
  - AC 制冷（SystemMode=0x03，line 177-188）：`temp_diff = (current - cooling_setpoint)/100`（÷100 因 Matter 存 0.01°C 单位），`cooling_rate = min(0.0005, temp_diff×1.0) × fan_intensity`。**比例控制（离目标越远降越快）+ 速率硬封顶（`min(0.0005,…)` 防一 tick 跳变）+ 风量线性缩放**。
  - 热泵制热（0x04，line 189-197）：对称逻辑，向 heating_setpoint 升。
  - 风扇（line 148-161）：只朝 `baseline-200` 的地板降，速率更小（`min(0.0002,…)`）——风扇只能略降不能制冷。
  - **达标即停**：`current <= setpoint` 就 `continuous_effects.pop`（line 186-187）——到点不再施加效应。
- **积分 + 基线回归** `_on_time_tick_extra`（line 201-211）：`current += Σ effects`，再 `current += (baseline - current) × 0.0002 × tick_interval`——**无源时缓慢回归基线**（房间漏热/自然平衡），这步让"关掉设备后温度自己回升"成立。
- **闭环回写** `sync_device_sensor_from_env`（line 273-280）：把房间温度写回设备的 `LocalTemperature`（int 截断）——**传感器读数来自环境，不是设备自己编**。

### 🔴 湿度模型 `humidity.py`（line 73-137）— 效率递减 + 硬钳位
- **效率递减**（line 98, 113）：`efficiency = max(0.1, (9000-current)/9000)`——越接近饱和（90%）加湿越慢（边际递减，更真实），底 0.1 防完全停滞。
- 风量门（line 84-86）：`PercentCurrent==0` 直接无效应（开机但风量零不工作）。
- **硬钳位**（line 137）：`current = max(0, min(10000, current))`——湿度物理边界 0–100%（×100 存）。
- 基线回归率比温度大 10×（0.01 vs 0.0002，line 131）——湿度恢复更快。

### cross-cutting：单位归一化（与 home-llm 同型）
环境量内部一律 **×100 整数存**（温度 2500=25°C、湿度存 0–10000）。`sync_device_sensor_from_env` 截断成 int 回写。这就是 home-llm 的"模型用人类单位、code 转机器值"在 SimuHome 的体现——**MAformac 空调温度 18-32℃ 同样应在内部统一编码，contract 一处定**。

---

## §3 fast-forward 批进 + parity 守护 — SimuHome 最硬的可靠性工程

这是本 repo **最值得抄的一招**：时间加速可信，**靠"批进结果必须字节等同逐 tick 结果"的回归门强制**。

### 🔴 `_fast_forward_to`（home.py line 567-622）— 事件感知的混合批进
要从当前 tick 跳到 target_tick，不是傻跑 N tick：
1. **算到下一个调度事件还差几 tick**（`__steps_until_next_scheduler_event` line 549-557，peek 堆顶 due_tick）。
2. **能批跳就批跳**（line 600-609）：若这段无到期事件 + 无"阻塞批进"的逐 tick 工作（`__has_batch_blocking_tick_work_in_rooms`）+ 所有聚合器支持精确批进（`__can_exact_batch_advance`）→ `__advance_exact_batch`（一次算 N tick，line 522-534）。
3. **否则逐 tick**（line 611-613）：有事件/有阻塞设备的段落老老实实一 tick 一 tick。
- **精确批进** `exact_batch_advance`（temperature.py line 241-266）：因为温度模型是"固定 effect + 线性回归"，可在循环里直接迭代 N 步而不漏算（湿度有钳位则逐步迭代 line 153-162）。**只有"可解析批量推进"的聚合器才允许批跳**，否则 fallback 逐 tick——设计上把"批进安全性"做成每个聚合器的能力声明（`can_exact_batch_advance`）。

### 🔴 parity 守护 `sim_parity_guard_tests.py`（line 232-318）— 字节级 parity 断言
- **测试 1**（line 233-271）：对 benchmark 样本，`_run_reference_loop`（逐 tick 跑到 target）vs `_fast_forward_to(target)`，把两个最终 home_state 用 `_canonical_payload`（`json.dumps(sort_keys, separators)` line 228-229）序列化，**断言完全相等**。→ 批进绝不能与逐 tick 有任何偏差。
- **测试 2**（line 273-318）：选择性快进（只推进相关房间）vs 全量参考，在相关房间投影上字节等同——保证 perf 优化（只算目标房间）不改语义。
- **schema 前置守护**（`_collect_episode_schema_issues` line 106-121）：跑 parity 前先校 benchmark 的每个 attribute path（endpoint.cluster.attr）在当前设备 schema 里存在，否则报"benchmark 与模拟器 schema 不兼容，需重新生成"——**防止旧数据跑新内核出假结果**。

### 🔴 git-path-gated 自动回归 `sim_parity_guard.py`（line 10-138）
- `RELEVANT_PATH_PREFIXES`（line 10-18）：只列 aggregators/devices/clusters/home.py/home_initializer/routes/client 这些"会动语义"的核心路径。
- `main`（line 86-137）：git diff 检测改了哪些文件，**只有命中相关路径才跑 parity 套件**，否则 SKIP（line 121）。可挂 pre-commit（`--staged-only`）。
- **意义**：把"改了仿真核心 → 必须证明批进仍 parity"做成自动门，不靠人记得。MAformac mock 内核若引入"延迟生效/时间推进"，应有同型门（改了端态演化逻辑 → 跑一遍 parity / 黄金轨迹回归）。

---

## §4 两段式 verifier `pipelines/episode_evaluation/`（runner 280 + common 207 + per-qt）

SimuHome 的评测不是单一打分，是**确定性硬门 + LLM 软判 + 时间窗校验**三件组合，按任务类型路由。

### 评测主流程 `runner.py::run_single_config`（line 166-280）
reset 模拟器到 episode 初态（line 194）→ 跑 agent（line 206-213）→ **`time.sleep(0.5)` 让态稳定**（line 219）→ 抓 final_home_state（line 220）→ 按 `(qt, case)` 路由到对应 evaluator（`_EVALUATOR_REGISTRY` line 21-34）。
- **严格响应校验** `_require_ok_response`（line 122-144）：每个模拟器响应必须 status.code==200 + error==null + data 是 dict，否则抛——契约即代码。
- **工具调用序列化** `_serialize_tool_calls`（line 74-119）：把 agent 的工具调用规整成 `{tool, params, outcome:{ok, status_code, error_type}}`，`ok = (200 and no error)`——为 verifier 提供统一可判结构。

### 🔴 第一段：确定性「必做动作」门 `common.py::evaluate_required_actions`（line 22-94）
- **递归子集匹配 `is_subset`**（line 11-19）：required 的 params 必须是 invoked params 的子集（dict 递归 / list 包含 / 标量相等）。**宽容多余参数，只要求期望参数都命中**——容错但不放水。
- 对每个 required action，扫所有 invoked 找 tool 名一致且 params 子集命中的 → 标 `invoked: true/false`。
- 上层（qt1/feasible.py line 30-39）：`tools_ok = all(invoked)`；任一必做动作没做 → 直接 0 分 + `"Required Actions Failure"`，**不进 LLM 裁判**（省钱 + 硬门优先）。

### 🔴 第二段：LLM 裁判面板 `common.py::run_judge_panel`（line 137-184）
- **3 裁判强制**（line 144-149）：必须恰好 3 个 judge LLM，否则 Judge Configuration Error。
- 并行调用（ThreadPoolExecutor line 153-158），每个裁判 `single_judge_call`（line 123-134）**强制输出 A/B 单字母**（取首字母，非 A 即判 B）——把开放裁判压成二元分类，可统计。
- **多数表决**（line 169-178）：A>B → score 1，否则 0。任一裁判 Error → 整体 -1（Judge Error，可识别区分于真 0 分）。
- **MAformac 取舍**：solo demo 端侧无在线 LLM 裁判 → **C6 主用第一段确定性门**（端态读回 + 必做动作集合匹配 + 拒识正确性），LLM 裁判面板可作离线评测期（Mac 上跑 bench 时）的可选第二段，**不进端侧 runtime**。

### feasible vs infeasible 同骨架（qt1/feasible.py vs infeasible.py 几乎同构）
区别仅在 evaluation prompt：feasible 期望"做了正确动作 + 答复对"，infeasible 期望"识别不可行 + 拒绝/解释"。**同一 verifier 框架覆盖「该做」和「该拒」两类**——正是 MAformac"拒识正确性"需要的对称结构。

### 🔴 时间敏感 verifier `qt4/feasible.py`（line 168-283）— 在未来 tick 校验端态
qt4 = 工作流/延迟生效任务，verifier 直接在**未来时刻**验端态：
- 每个 goal 有 `when:{at_tick, tolerance_ticks}` + `targets:[{device_id, asserts}]`。
- **容差窗** `_build_checkpoints`（line 120-127）：`[at_tick-tol, at_tick+tol]` 一串候选 tick，任一命中即算达标（line 248-250）——允许"差不多那个时间到位"。
- **单调游标** `_resolve_monotonic_cursor_tick` + `_apply_monotonic_window`（line 130-165）：时间只能前进，已经 fast-forward 过的 tick 不能回退验（line 160-165 裁掉游标之前的 checkpoint，标 `monotonic_window_missed`）。
- **选择性 fast-forward**（line 198, 225）：只推进 goal 涉及的房间（`_extract_room_ids` line 13-31），靠 §3 parity 守护保证语义不变。
- goal 按 at_tick 排序后顺序验（line 204-205）——时间单调消费。
- **MAformac 直接映射**：C6"延迟生效 case"（如「10 分钟后关空调」）= 同型 verifier——记录 ToolCall 排程 → mock 内核 fast-forward 到目标 tick → 读回端态断言，带 tolerance 窗。

---

## §5 episode 生成管线 `pipelines/episode_generation/`（核心 3728 行）— feasibility oracle + 守护采样

生成 benchmark 的一侧。**核心价值 = feasibility oracle + 守护式随机采样**，让生成的 case 自带 ground truth。

### 🔴 feasibility oracle `shared/feasibility.py`（line 58-267）— case 标签的 ground truth
决定"在当前设备态下，某环境目标是否可达成"——这是 feasible/infeasible 标签的真值来源，**纯确定性规则，不靠 LLM**。
- `METRIC_TO_DEVICE_TYPES` / `DEVICE_TYPE_TO_DIRECTIONS`（line 9-25）：哪些设备能控哪个量、能往哪个方向（AC 只能降温、热泵只能升温、灯可增可减）。
- `check_temperature_feasibility`（line 84-141）等：逐设备查"是否还有可操作空间"（已开+已制冷+满风量+已达标 → 该设备无空间；否则可达成 → 返回 True）。
- `ENV_SEMANTIC_BOUNDS`（line 39-55）+ `check_env_semantic_consistency`（line 58-71）：语义合理性门——比如"降温目标"要求当前温度 > 20°C（已经很冷就别再要求降温，无意义 case）。
- **MAformac 映射**：C6 生成"状态型 case"时，同样需要一个**确定性可达性判定**给 case 打 feasible/infeasible 标签 + 派生 `required_actions`——可借这套"设备能力表 × 当前态 → 可达性"结构。

### 🔴 守护式采样 `core/guard_registry.py`（line 6-153）— value 四件套（= MAformac C1 契约）
生成随机设备初态时的合法性守护，**结构几乎就是 MAformac C1 的 value 契约**：
- `READONLY_ATTRIBUTES_BY_CLUSTER`（line 6-60）：每 cluster 的只读属性（传感器输出，如 LocalTemperature / MeasuredValue / CurrentLevel）——**不可被写**。
- `VALUE_RANGES`（line 63-68）：`(device?, cluster, attr) → (min, max, step)`，如 CoolingSetpoint (1600,3200,50)=16-32°C step0.5（Matter ×100）。
- `VALUE_BINS`（line 71-73）：离散分桶（PercentSetting 分 0 / 1-33 / 34-66 / 67-100 四档）。
- `ENUM_VALUES`（line 76-78）：SystemMode 白名单 (0,1,3,4)。
- `validate_relations`（line 111-140）：**跨属性关系约束**（热泵 AbsMaxPower > AbsMinPower）——对应 thermostat.py line 64-79 的 deadband（Cooling - Heating ≥ 0.25°C）。
- **采样器** `candidate_sampler.py`（908 行）`_pick_from_bins/_pick_from_range`（line 23-49）：从合法集采值，且**刻意避开当前值**（`if current in values: 去掉`，line 32-34, 47-48）——保证采样动作真改变状态（生成有意义的 transition）。
- **MAformac 映射**：这套 readonly + range(min/max/step) + bins + enum + relation 五元守护 = **C1 `semantic-function-contract` 的 `value` 四件套 + risk-policy 雏形**。SimuHome 把它做成 code 注册表（单一源派生采样器/校验器），与 MAformac"契约 SSOT codegen 派生"同构。

### 单位编码确认（thermostat.py line 30-81）
- 内部 ×100 整数（LocalTemperature 2500、Setpoint 700-3200，line 30-36, 56-60）。
- **写时校验三连**（line 46-81）：类型（必须 int）+ 范围（700-3200）+ 关系（deadband ≥25）。LocalTemperature 列入 readonly（line 39）——传感器只读。
- `_setpoint_raise_lower`（line 83-151）：相对调温命令，带钳位（max/min）+ deadband 复检——**相对动作也守边界**。

---

## §6 cross-cutting patterns（横切设计思想，逐条对 MAformac 的启示）

| # | SimuHome 模式 | 在哪 | 横切启示 |
|---|---|---|---|
| 1 | **单写者串行 tick 环** | home.py 单线程 loop + api_queue | 所有写经单一 actor 串行 → 无锁、可复现。MAformac mock 内核同理（单 actor 处理 ToolCall，不到处改 @Published） |
| 2 | **虚拟时间 = tick 的纯函数** | home.py line 624-633 | 时间可变速但单调连续；演示（real-time）与评测（fast-forward）共用一套逻辑 |
| 3 | **环境演化 = 比例控制 + 速率封顶 + 基线回归** | aggregators | 不需真物理；"离目标越远变越快 + 一 tick 不跳变 + 无源回归基线"三律就够可信。MAformac 延迟生效/端态演化可借 |
| 4 | **懒计算（状态签名 diff）** | base.py line 49-65 | 只在设备态变化的事件边界重算，其余 tick 只积分 → 省算力（端侧关键） |
| 5 | **批进必与逐 tick 字节 parity + git-gated 自动门** | parity_guard(_tests) | 任何性能优化（批进/选择性房间）必须证明语义不变；改核心文件自动触发回归。MAformac 端态演化逻辑同型守护 |
| 6 | **两段式 verifier：确定性硬门 → LLM 软判** | common.py + qt1 | 硬门（必做动作 + 端态读回）优先且省钱；LLM 裁判只在硬门过后兜语义。MAformac C6 主用硬门，LLM 判离线可选 |
| 7 | **递归子集匹配（容多余、卡缺失）** | is_subset line 11-19 | required params 是 invoked 的子集即过 → 容错但不放水。MAformac ToolCall 集合匹配可借 |
| 8 | **feasible/infeasible 同骨架** | qt*/feasible vs infeasible | 同一框架覆盖"该做"和"该拒"→ 拒识正确性天然纳入。MAformac 安全门拒识 case 同构 |
| 9 | **时间窗容差 + 单调游标校验** | qt4/feasible.py | 延迟生效验收：未来 tick 读回端态 + [at±tol] 窗 + 时间不回退。MAformac"N 分钟后做 X"case 直接套 |
| 10 | **value 守护 = code 注册表单一源** | guard_registry.py | readonly/range/bins/enum/relation 五元在 code 一处定，派生采样器+校验器 = MAformac C1 契约 SSOT codegen |
| 11 | **feasibility oracle = 确定性可达性判定** | feasibility.py | case 标签 ground truth 不靠 LLM，靠"设备能力表 × 当前态"规则。MAformac C6 case 生成同需 |
| 12 | **契约即代码（严格响应校验）** | _require_ok_response | 每个边界响应硬校 status/error/data 形状，不信任 → fail-fast。与 MAformac"错误用枚举 + 读回校验"一致 |

---

## §7 adopt / adapt / drop 映射 → MAformac C6（状态型 case），兼及 C3/C4/C7

> 形态全量吸收（不降级）；drop 仅限"载体不适合纯端侧 Swift mock + solo demo 轻治理"。

| 发现（form） | 动作 | C 层 | 为什么 |
|---|---|---|---|
| 单写者 tick 环（单 actor 串行处理动作 + 队列） | **copy概念** | C3 | mock 内核用单 Swift actor 串行落 ToolCall→端态，天然可复现；替代到处改 @Published |
| 虚拟时间 = tick 纯函数（real-time / fast-forward 共逻辑） | **copy概念** | C6/C3 | 演示走 real-time、bench 走 fast-forward 同一套；"N 分钟后"类 case 必需 |
| 环境演化三律（比例控制 + 速率封顶 + 基线回归） | **adapt** | C6/C3 | 车控端态（空调温度→车内温感、车窗开度→噪声）可借三律做"延迟生效/渐变"mock；车场景比家居简化（少量量） |
| 环境控制规则 required+optional+note 三段配方 | **adapt** | C1/C6 | 表达"达成端态目标的最小动作集 + 可选增强"；喂 C1 contract 的 scenario_required + verifier required_actions |
| fast-forward 事件感知批进 | **copy概念** | C6 | 延迟生效 case 批量推进到目标 tick 验端态，不傻跑每 tick |
| **parity 守护（批进≡逐tick 字节相等）+ git-path-gated 自动门** | **copy概念** | C6 | MAformac mock 演化逻辑一旦引入时间推进，必须有"批进=逐tick"回归门 + 改核心文件自动触发；防假结果（与 pre-mortem happy-path bias 对症） |
| 两段式 verifier（确定性必做动作门 → LLM 裁判面板） | **adapt** | C6 | **端侧主用第一段确定性门**（端态读回 + 必做动作集合匹配 + 拒识）；LLM 裁判面板移到 Mac 离线评测期可选，不进 runtime |
| 递归子集匹配 is_subset（required ⊆ invoked） | **copy概念** | C6 | ToolCall 参数匹配容多余、卡缺失，正合 MAformac 集合精确匹配 |
| feasibility oracle（确定性可达性 → feasible/infeasible 标签） | **adapt** | C6 | C6 状态型 case 生成需 ground truth 标签 + required_actions 派生；车控版"设备能力表 × 当前端态" |
| 时间窗容差 + 单调游标（未来 tick 读回端态验） | **copy概念** | C6 | "10 分钟后关空调"类延迟 case 验收：fast-forward + [at±tol] 窗 + 时间不回退 |
| 守护注册表 value 五件套（readonly/range/bins/enum/relation） | **copy概念** | C1 | 直接对应 C1 `value` 四件套 + risk-policy；code 单一源派生采样器+校验器（= contract SSOT codegen） |
| 单位 ×100 内部编码 + 写时三连校验（类型/范围/关系/deadband/钳位） | **copy概念** | C1/C3 | 与 home-llm 双向单位归一化同型；空调温度 18-32℃ contract 一处定、写时校边界 |
| 严格响应契约校验 _require_ok_response（fail-fast 形状门） | **copy概念** | C3 | 边界响应硬校 + 错误枚举，与 MAformac 铁律"错误用枚举 / 读回校验"同 |
| 守护采样"避开当前值"（保证 transition 有意义） | **adapt** | C6/C5 | 生成状态 case / LoRA 状态读回样本时，确保动作真改变端态（非 no-op） |
| Matter 47 cluster / 80+ docs 全协议建模 | **drop** | — | 量产协议广度，MAformac 只需车控少量 device×原语；过度 |
| Python/threading runtime + FastAPI（routes.py 403 行）+ HTTP client | **drop** | — | 纯端侧 Swift mock 无后端无网络；翻译成 actor + 进程内调用，不 import |
| OpenAI/OpenRouter agent provider（react/hi_agent strategies） | **drop** | — | MAformac 端侧 Qwen3+LoRA（home-llm 路线），不用云 agent 框架 |
| parallel_model_evaluation 1445 行（多模型云评测编排） | **drop** | — | solo demo 单模型；Mac 离线评测用轻量脚本即可，过度编排 |

---

## §8 一句话

> **SimuHome 给 MAformac C6 的，不是物理引擎，是一套"让 mock 端态随时间可信演化、且能被严格验收"的工程骨架**——单写者 tick 环 + 虚拟时间纯函数 + 比例控制/速率封顶/基线回归三律 + **批进必与逐 tick 字节 parity 的自动回归门** + 两段式 verifier（确定性硬门优先、LLM 软判兜底）+ 时间窗容差校验 + feasibility oracle + value 五件套守护注册表。**抄形态、翻成 Swift actor，drop 掉 Python/网络/云 agent 载体**；其中 parity 守护（批进≡逐tick）和确定性 verifier 第一段，是 C6"状态型/延迟生效/拒识 case 不丢脸"的直接答案。

---

> 关联：`2026-06-20-eval-oracle-blindspots-repo-scan.md`（item #3 即本 teardown 委托）/ `2026-06-20-maformac-eval-system-overview.md`（C6 总入口）/ `2026-06-19-home-llm-teardown.md`（双向单位归一化、单发旋钮——与本文 §2/§5 互印证）。License：CC BY-NC-ND，本文只抽方法形态，未复制代码。
