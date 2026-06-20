# MAformac 综合吸收意见 — 14 repo teardown + Qwen 可行性 (eval / 短时记忆 / voice 深扒)

> 综合研究员: Claude (CC subagent) · 2026-06-20
> 输入: 14 份 repo teardown 的 adopt_map + cross_cutting + 1 份 Qwen3.5-2B 可行性报告
> 红线: 只写 `docs/research/`, 不 commit; 结合已锁决策 (D38 iPhone 4B 天花板 / SRD 三层路由 / C6 已 SOLID 11 Requirement / 单发 MAX_ITER=0 / 安全是代码不是 prompt / Python·Node 零进 iOS); 不降级 (star>1000 工程价值全量吸收, 只 filter 真不适用); Qwen 升级建议过端侧可行性 gate。
> 与已有 `docs/优化待讨论-吸收内化措施38项-2026-06-20.md` 的关系: 那 38 项是 home-llm / Mastra / Pi 三扒的吸收; **本文是另外 14 个 repo (12 个 eval/bench/voice/runtime + Qwen) 的增量吸收**, 不重复 38 项已收的, 只补新增量。

---

## 0. 一句话结论

这 14 份 teardown 的核心价值不是"再发现一个 bench 框架", 而是把 MAformac eval/memory 体系的**外围工程**拆到代码底, 收敛出三件事:

1. **C6 已 SOLID (11 Requirement), 不动它**; 这批 teardown 的 C6 findings 全部归入 **C6.1 扩展包** (run_repetitions/failure-receipt/pass^k/容差 matcher/gold 血缘/feasibility oracle), apply 时机 = C6 base 真跑后, 不在第二刀里塞。
2. **短时记忆 / DialogueState 落 C4 而非新建一层** — livekit/pipecat/ha-core/ovos/hassil 五个生产级 repo 一致证明: 多轮对话可靠 = "可序列化 Session + 单写者 + 帧栈衰减 + 事件驱动状态位 + copy-on-write 改史" 全在确定性 code, 模型只产单跳。这是 SRD §5.1 铁律在**对话状态维度**的工业背书, 直接咬合三层路由, 不需要新 capability。
3. **Qwen3.5-2B 条件升级 (需 spike), 不盲升不轻退** — 端侧硬件过 (RAM 1.28GB / decode 可能更快, 在 4B 天花板 D38 下余量足), 但 GDN runtime + tool-parser 不兼容 (撞 T2 坑并放大) + thinking-loop + demo 命门维度无 2B 实测分四重不确定。**先 S1 (mlx-swift parser 源码 + tool-call 实采) + S2 (iPhone GDN TTFT 真机) 两个死门 spike ≈0.5-1 天再切**, 不先训 LoRA。

---

## 1. adopt_by_layer — 按 C4/C5/C6/C7 归类 (不降级, star>1000 工程价值全量吸收)

### C4 三层路由 + 短时记忆 (DialogueState)

> 元洞察: 五个生产语音 repo (hassil/ha-core/ovos/livekit/pipecat) 一致把"本质有状态的多轮对话"做成"无状态正交对象 + 一根 ID + TTL 级联清理 + 帧栈衰减"。这正是 SRD §5.1「DialogueState/state machine 全在确定性 code, 模型只产单跳」的工业实现。**短时记忆不是新 capability, 是 C4 的 DialogueState 子结构。**

**(a) DialogueState 结构形态 (落 C4, 不新建层)**
- `[ha-core]` 三层正交对象拆会话态 (ChatSession 生命周期 / ChatLog 内容历史 / PipelineConversationData 跨轮路由态), 用 conversation_id (ULID) 关联, cleanup-callback 链级联释放 — 别堆单一大状态机。
- `[ovos-bus-client]` Session 纯数据 (Codable struct) + SessionManager 单例统一读写 + downstream 禁自持 → DialogueStore actor 唯一权威源, UI/路由/mock 都从它读防态分叉。
- `[ha-core]` 4 种 frozen Content + system 永占 slot[0] → DialogueTurn enum (system/user/assistant/toolResult), 落磊哥 immutability 铁律 (Swift enum + struct immutable)。
- `[ovos]` 状态可 serialize/deserialize 全程 → DialogueState 是 state_revision 快照 + LoRA Day1 trace + C6 expected_state_delta 的共同载体。
- `[livekit]` 对外只读 chat_ctx 包装 + copy-on-write 改史 → 杜绝意外原地 mutate (immutability 铁律)。

**(b) 锁域 + 多轮继承 + 意图收缩 (落 C4, 直接对应 SRD「落域」「意图收缩」)**
- `[ha-core]` 三层分诊 trigger→本地意图→LLM (pipeline.py:1235) = C4 三层路由的工业背书; intent_filter 规则层主动让权 (pipeline.py:1251) = SRD「意图收缩」(NLU 弃权模糊说法→慢路) 的现成形态。
- `[ha-core]` continue_conversation_agent 多轮锁域 (追问/澄清回合锁上轮 agent、跳规则分诊) = SRD「落域 + 多轮锁域」现成实现, 不必新发明。
- `[ovos]` active_skills 时间戳栈 (activate 先删再 insert(0)) → 锁域栈最近垂域栈顶;「再高一点」读栈顶域 (passthrough), 不靠 LLM 记上轮。
- `[ovos]` IntentContextManager 帧栈 + TTL + 置信度按深度衰减 + 留最新 → 指代继承槽位补全 + 旧帧降权, 治多步失败 (T7 66% 根因)。
- `[hassil]` intent_context dict 跨调用显式传递 (recognize.py:80) + _copy_and_check_required_context 上下文拷成 slot (recognize.py:517) → DialogueState = 显式可序列化字典, ContextGate.resolveSlots 锁定 domain/device 拷进 ToolCall slot (落域不重说)。
- `[hassil]` requires/excludes_context 两阶段剪枝 + 落地双查 (recognize.py:199) → 上下文门匹配前剪 + DemoGuard 提交前再验 (= 安全是代码门, 非 prompt)。
- `[hassil]` recognize_best 确定性消歧 (精确>模糊、字面多>通配符多, 纯函数可单测) → RuleRouter.pickBest, L1 规则快路的消歧根基。
- `[hassil]` fuzzy 双护栏 (纯设备名无动词判 unmatched + 分数接近判 unmatched) → 置信接近 = 拒识澄清不猜; 纯设备名无动词绝不执行 (车控不丢脸铁律)。

**(c) L1 规则快路命中判据 (落 C4, 对应 SRD L1 秒回不碰模型)**
- `[hassil]` is_match 吃光整句严格判据 (string_matcher.py:142) → L1 必须吃光整句才命中; 剩字下放意图收缩/L2。
- `[hassil]` RangeSlotList 范围即白名单 + 内联 {18..32} (intents.py:50) → 空调 18-32/风量 1-10/车窗 0-100 用范围 slot; 超范围天然落空→clarifyTag (= C2 execution_range 权威)。
- `[ha-core]` LRU IntentCache(128) + 分级匹配 (exposed/unexposed/unknown 三阶) + 失败缓存 (default_agent.py:156) → L1 规则指令缓存秒回, 按全集词表规模调 capacity。

**(d) 流式 ToolCall 提取 + 上下文卫生 + 后端抽象 (落 C4 runtime)**
- `[hass-local-openai]` 多引擎 tool-call 累积复合键 (tool_key=id+name + args 分片累积) → 走流式 FC 必踩 args 分片 vs 并行调用边界; 单发也要正确累积完整 ToolCall。
- `[hass-local-openai]` 历史裁剪 _trim_history (保 system[0] + 最近 N 轮 + 删孤立 tool result) → demo 短上下文裁剪正确姿势; 删孤立 tool result 防 chat template role 报错。
- `[hass-local-openai]` 注入位置/角色 (date/RAG 不进 system prompt + 注入到 user 前一位 + 注入则删工具) → **KV 缓存友好第一性** (动态内容进 system = 缓存每次失效), 与 home-llm KV 预热互补。
- `[hass-local-openai]` strict JSON-Schema 压平 (全字段 required + nullable + 删 allOf/anyOf/oneOf) → MLX 端 outlines/xgrammar 受限解码需 schema 压平才能稳约束 1.7B 输出 ToolCall。
- `[hass-local-openai]` LLMBackend registry + mixin (dict 派发 + 懒加载 + mixin 只覆写差异点) → MAformac 已锁 LLMBackend 协议的现成实现形态。
- `[hass-local-openai]` model id 防御解析 strip_model_pathing / tool result 非 JSON 兜底 (json.dumps default=str + warning) → 外部脏字符串先归一、mock 车控返回怪类型永不崩 (与 home-llm 防御解析同源)。
- `[hassil]` 中文全角标点 + NFC 归一 (util.py:21) → TextNormalizer: ASR→L1 间必经 (也服务 C7); in→out 归一化是契约一等公民 (value_out + 范围 slot)。

**(e) 路由轨迹评测 (C4 eval, 与 C6 解耦)**
- `[agentevals]` graph_trajectory 步骤图 + __interrupt__ 哨兵 → 三层路由评测模板: 走了哪层记成 steps, clarifyTag/拒识 = __interrupt__ 式显式步骤是一等公民非 fail。
- `[agentevals]` graph_trajectory/strict 步骤序列严格相等 → L1 精确指令必须走规则快路不许误入慢路 = 路由步骤序列死门 (改成三层路由层名序列)。
- `[agentevals]` 图轨迹 judge 无 reference 评连贯性 → 全集 3990 不可能每条有金标轨迹, 无 ref 评步骤逻辑补位。

**(f) 并行抢跑护栏 + 钩子 (C4, 谨慎; 仅当 C4 做"规则快路+模型慢路并行")**
- `[livekit]` temp mutable copy + is_equivalent 投机生成失配护栏 → 若 C4 做规则/模型并行抢跑, is_equivalent 检上下文分叉作废错答是关键护栏。
- `[livekit]` on_user_turn_completed(turn_ctx, new_message) RAG/改写注入钩子 → 意图收缩澄清/落域上下文注入挂此钩子 (用户说完、LLM 应答前的窗口改写)。

### C5 LoRA 数据 (训练-评测物理隔离 + 负样本 + 数据增广信号)

> 38 项 #13-18 已收 home-llm data 配方。本批补"防泄漏 split"与"失败→数据"回流信号。

- `[tau2-bench]` train/test/base split (base=train∪test, 评测跑 base) → C5 训 train / C6 跑 base 全集死门 / test=held-out 防死记; task_id 硬分。这是已锁「C5 must_not_train + parent_overlap=0」的工业出处。
- `[iot-agent-bench]` 梯度 T1-T5 + 安全三子型 (危险参数/越权/无效设备) → 车控难度梯度兼 C5 LoRA 负样本配方。
- `[iot-agent-bench]` gold 从冻结数据确定性算 (idxmax/groupby) 非手写 → 金标从冻结快照确定性派生 (= 契约 codegen 铁律), 可证伪可重算 (也服务 C6)。
- `[nano-eval-harness]` 结构化修复建议 propose_fix (auto_apply:false 只建议不自动改) → ToolCall FAIL→{instruction: 应产 setAirConditioner(temperature=22)} 喂 C5 数据增广或人审, **永不自动改契约/权重**。
- `[ha-voiceagent-bench]` F1-F10 失败分类法 (小模型 tool-call 崩法账本 + 每条缓解 + 实测 delta) → 「一次改一处 + delta」回流 C5 LoRA / C4 规则调参方法学; F1(device code 代友好名)/F2(锁方向/升温语义)/F5(虚假槽) 是车控泛化原样会撞的崩法。
- `[hassil]` fuzzy OOV + 判别词加权 → 跨意图强判别词强化归类; 思想移植到 LoRA/打分, 不借 n-gram 实现。

### C6 vehicle-tool-bench (已 SOLID 11 Requirement, 新 findings 归 C6.1 扩展包)

> ⚠️ **C6 已 archive 不降级 (D35 双轴 + 四硬门 + judge 边界 + replay 指纹 + base 先行 + must_not_train 全在)**。下列是 C6.1 扩展候选, apply 时机 = C6 base Qwen3-1.7B 真跑后, **不在第二刀里塞** (避免第二刀过宽, 呼应 overview Open Question 2)。

**(a) 端态哈希 / no-op 防崩 (扩展 C6「state_delta + readback」硬门)**
- `[tau2-bench]` 端态哈希比对 (gold 重放→hash→比对, 任意路径达同端态即过) → 比 ToolCall 精确匹配更严, 管端态不管调用形态; MAformac「验收读回 mock 态」铁律的工业实现 (evaluator_env.py:81)。
- `[tau2-bench]` 幻觉工具调用作 no-op 重放 (端态分叉自然失败不崩) → DemoGuard 越 L1 allowlist/未知工具 = no-op + TTS 兜底; **不崩靠 no-op 不靠 catch, 错误是数据 (ToolMessage error=True) 不是异常**。
- `[tau2-bench]` 非 mutating 读类工具评测跳过 → 读类 (查温度) 不改 mock 态、bench 跳过避免非确定性。
- `[iot-agent-bench]` 九种端态断言 _check_one_state (含 device_untouched 负向) → 改成车控端态表 (空调温度/车窗%/座椅档/门锁), 与 C2 scenario-state-protocol 同源直接吃; 负向断言一等公民。
- `[simuhome]` 单写者 tick 环 (单 actor 串行落 ToolCall→端态) + 虚拟时间=tick 纯函数 (real-time/fast-forward 共逻辑) → 演示走 real-time、bench 走 fast-forward 同一套; N 分钟后类延迟生效 case 必需 (留 C6.1, overview OQ2 建议 v1 先不扩)。

**(b) 多 run 稳定性 / 方差是一等公民 (扩展, 治"单跑=抛硬币"盲点)**
- `[tau2-bench]` pass^k 多跑方差度量 C(s,k)/C(n,k) → 每 case N trial 报 pass^1 + pass^N, temp 0/0.6 两组测方差。
- `[tool-calling-benchmark]` 20-run majority-vote + Reliability 双指标 → 防小样本假象; N≥10 run、报 per-run reliability、单跑标 preliminary (repo 第二轮全部理由)。
- `[iot-agent-bench]` 多 seed 方差 N_SEEDS=3 + temp=0 → 评测温度 0 求确定性, 多 seed 防假提升 (3HIGH 之一)。
- `[tau2-bench]` INFRASTRUCTURE_ERROR 剔除 + min_k 守护 → 跑飞/超步 trace 不污染覆盖率分数。
- `[tool-calling-benchmark]` / `[ha-voiceagent-bench]` 串行 --max-connections 1 + 剔 first-sample cold-prefill + per-sample timeout + server 三态守护 → 端侧跑 Qwen3-1.7B 测真延迟时复用: 串行测真延迟、剔 KV 冷启动伪 outlier、坏 run 不拖垮矩阵。

**(c) 容差 matcher / 集合匹配 (扩展 C6 ToolCall 匹配, 车控容差统一出口)**
- `[agentevals]` _is_trajectory_superset 贪心二部匹配 + 占用集 → ToolCall 集合匹配标准算法, 占用集防重复计数, Swift ~30 行。
- `[agentevals]` 四档 trajectory mode strict/unordered/subset/superset → 客户多说/少说/换序分档评, 非单一 exact。
- `[agentevals]` tool_args_match_overrides per-tool 可插 matcher → **温度±1/风量档/颜色近似/车窗范围容差统一落点, 免每容差写一 scorer (本库最大红利)**。
- `[agent-tester]` RangeMatch + args_match 三态参数匹配 → 对齐 execution_range 18-32/1-10/0-100, 判区间非精确等于。
- `[iot-agent-bench]` Tool-F1 只比 key_args 贪婪一对一 + progress_rate 部分信用 → ToolCall 匹配只看 device×动作×关键槽, 不卡无关参数。
- `[ha-voiceagent-bench]` alternative + quality (optimal/equivalent/acceptable/degraded) 容多正解 → **「不丢脸」精确定义 = 命中 optimal/acceptable 不丢脸、degraded/越界才丢脸**; 金标必带 alt 集 + quality 标签, 否则同句多正解被冤杀。

**(d) 判断 vs 执行双轴 + 拒识 + 安全 (扩展 D35 双轴, 对应风险/不丢脸)**
- `[tool-calling-benchmark]` 判断 vs 执行双轴评分 (Action/Restraint/WrongTool 独立轴) → C6 双轴直接对应; Restraint→拒识、WrongTool→安全门越界。
- `[tool-calling-benchmark]` WrongTool 惩罚 (调错重于漏调) → wrong = 安全门越界/跨域调错 device; 惩罚权重按风险级越界>漏识 ("自信地错"重于"沉默漏")。
- `[ha-voiceagent-bench]` 6 维诊断打分器 (response_type/format_valid/call_count/tool_name/args/no_hallucinated_tools) → 比手搓"集合精确匹配"多 5 个诊断维; 状态机分流进判分维 (response_type 先分流再判其它)。
- `[iot-agent-bench]` headline success 合取 (安全一票否决) + 拒识探针豁免 (≤1 read call) → 安全门铁律评测端落地 + 别机械要求零工具拒识。
- `[iot-agent-bench]` 安全分严重度加权 (low.25/med.5/high.75/critical1.0) → 映射 risk-policy R0-R3 (ASIL/forbidden), critical 一次清零。
- `[ha-voiceagent-bench]` 拒识维 (response_type 零调用 = error/clarification/text_response) → 车控拒识/安全门死门 ("有点冷自动升温吗"、越界"导航去机场" demo 无导航该零调用)。

**(e) 失败收据 / 归因 / 可复现 (扩展 C6 failure receipt, 这是 C6.1 脊柱)**
- `[nano-eval-harness]` 6 字段 case FAIL 收据 schema (failed_check_id/expected/actual/diff_hint/transcript_span/env_delta) + 单 check 7 字段 → **C6 failure receipt 一词直系来源**; failed_check_id 作稳定可 grep 失败指纹、transcript_span 作跳转锚点。
- `[nano-eval-harness]` REGRESSION ≠ FAIL 的 baseline-relative verdict → 新增覆盖 case 红 ≠ 已有能力回归红; 只有绿翻红入回归账 (全集覆盖率双轴判定根基)。
- `[nano-eval-harness]` 4 类归因决策树 (env_delta 驱动: LORA_CHANGED/CONTRACT_FIXTURE_STALE/BASE_MODEL_CHANGED/UNKNOWN_DRIFT) → bench 红先答是谁动了。
- `[nano-eval-harness]` 3 样本字节同一性 flaky 检测 (只 hash 判定字段忽略时间戳) → 端侧小模型采样抖动假报回归; real FAIL (字节同一) 才计回归, 分叉标 flaky。
- `[nano-eval-harness]` rerun affordance (每 FAIL 自带单 case 复现命令) + 机器 JSON + 人读 MD 三段式 → swift run bench --case=<id> --pin-contract=<snapshot>; CI 吃 results.json, 磊哥/审计吃 diff.md。
- `[nano-eval-harness]` 优雅降级文化 (无基线/judge 不可用/未知价/空产物各诚实信号, 否定断言先证产物存在) → 拒识/空匹配 check 不能 vacuous-PASS; 绝无静默成功。
- `[nano-eval-harness]` warn-only→7 天绿→promote→blocking 渐进上牙 + baseline 单写者 → solo 轻治理: bench 先 warn-only 攒信任稳定后当 must-pass 死门, 不 day-1 block。

**(f) gold 血缘 / 正确性自洽守护 (扩展, 防"模型蠢 vs 金标坏")**
- `[iot-agent-bench]` verify_gold 完美 agent 自洽守护 (回放金标轨迹证 verifier 不冤枉) → 防假分数命脉, 区分"模型蠢 vs 金标/judge 坏", **C6 必须有这一步**。
- `[tau2-bench]` TaskIssue 账本 (gold 错误追踪 + PR 链 + 一手源修订, 75+ task fixes) → C6 gold 端态/L1 allowlist 血缘账本; **gold 不是天授会被修订**。
- `[simuhome]` parity 守护 (批进≡逐 tick 字节相等) + git-path-gated 自动门 → mock 演化引入时间推进后必有批进=逐 tick 回归门 (对症 happy-path bias)。
- `[simuhome]` feasibility oracle (确定性可达性→feasible/infeasible 标签) → C6 状态型 case 的 ground truth 标签 + required_actions 派生 (车控版设备能力表×当前端态)。

**(g) bench 工程机制 (扩展 runner/版本门)**
- `[tool-calling-benchmark]` bench_version hash gate (口径变旧分 stale) → 复用 MAformac 冻结快照双 hash; C1 全集变→旧 bench 结果自动失效重跑。
- `[tool-calling-benchmark]` per-run 原始数据落盘 + 聚合下游纯函数 + golden-case 回归测 → 重放/改阈值只改聚合一处; 改评分公式立即报警防 rounding/权重 bug。
- `[tool-calling-benchmark]` model-protocol pair (标 backend mlx/llama.swift + 解码模式 native-FC/GBNF) + Multi-Tool 协议测不了标 N/A → 不裸报模型名, 承认评测边界不造假分。
- `[agent-tester]` fresh registry per-case + 初始态注入 → "读回 mock 态验收"前提 = 端态是本 case 初始态非残留。
- `[agent-tester]` 零依赖自包含 trace HTML (矩阵+条形图+可展开 trace) + tags 切片 → 断网可看; 文件>服务 (轻治理); 双轴 bench 按标签算模糊类/各设备准确率。
- `[agent-tester]` profile 四轴正交矩阵 ({base/LoRA/0.6B/FM}×{规则 on/off}×{prompt}) → 一矩阵验选型; 本地 provider = 离线 bench。
- `[ha-voiceagent-bench]` 判分器 TDD 自验 (每维单测 + 断言工具数 + alternative 匹配) → C6 判分器是契约必须 fixture 自验, 与 codex TDD 长跑分工对齐。

### C7 voice (barge-in 打断 + 短时 history + 响应性度量 + 幻觉检测)

> 38 项 C7 多数已锁 (D14 sherpa+ASRBackend / 文本先行 / 按钮打断 D13)。本批补"打断写史合同"与"全双工/响应性度量"的工业实现。

**(a) 打断写史合同 (C7 首版即用最高优先, DialogueState 根)**
- `[livekit]` 打断写史 = 实播文本 (synchronized_transcript) + interrupted 标记, 被打断不写 LLM 生成全文 (issue #3760) → **DialogueState 打断写史合同的根**; mock TTS 须回报播放位置, 被打断只把已念那截 + interrupted=true 写史, 否则 history 撒谎。
- `[pipecat]` 助手流式累加→中断即提交已播出的 + 函数调用发出即写 IN_PROGRESS 占位结果就地替换 → 上下文永无孤儿 tool_call 喂 Qwen 不崩; **上下文=事实账本非意图账本** (只写实际播出/实际发生)。
- `[ha-core]` 工具失败 error→{error:type} 喂回历史 → DemoGuard 工具失败→error 帧回历史下轮可纠正 (= home-llm as_tool_messages 二次印证)。

**(b) barge-in 打断机制 (C7 第二刀 = 语音自动打断; 首版按钮打断 D13 可不要)**
- `[livekit]` SpeechHandle INTERRUPTION_TIMEOUT=5.0 超时兜底 → barge-in 包裹防卡死, demo 现场最怕卡死, 直接落 Swift 打断超时兜底 (C7 首版即用)。
- `[livekit]` barge-in 双门 min_duration(VAD)∩min_words(STT) → 中文词数门需改中文分词/字数门; 防咳嗽/单字 backchannel 误打断 (C7 第二刀)。
- `[livekit]` pause-not-kill + false-interruption timer resume → 疑似打断先压低/暂停 TTS, 确认有效指令才真停, 误报 (咳嗽/呃) resume; 比一刀切 kill 体验好 (C7 第二刀)。
- `[ovos]` is_speaking/is_recording 事件驱动 + wait_while_speaking → barge-in 判据 = 状态位不是 timer; mock 多阶等播报完再下一步。
- `[pipecat]` system frame 永不被业务门阻塞 → barge-in 打断信号不能被任何队列/门延迟, 控制帧优先级最高。

**(c) 短时 history 裁剪 (C7, 与 C4 (d) 共享)**
- `[livekit]` truncate(max_items) 三防御 (保 system + 尾 N 滑窗 + 不以孤儿 function_call 开头) → C7 短时 history 裁剪直接抄; 孤儿 fc 边界是 home-llm 没覆盖的。
- `[pipecat]` 压缩前未解析函数调用序列保护 (留最近 N 轮裁剪必避 ToolCall 未回结果窗口) + token 纯字符估算 len//4 → 端侧无 tokenizer 也知上下文多大 (多轮锁域累积), 零依赖直接用。
- `[ha-core]` continue_conversation 中文？启发式 (助手回复以？结尾→自动续听) → 现场中文演示直接受益。

**(d) 全双工 + 响应性度量 (C7 第二刀, voice eval)**
- `[tau2-bench]` Tick 全双工 + 双方同 tick 交换 chunk (barge-in 内生) + 工具结果延后一 tick 投递 (保音频不断) → 用户可同帧打断 agent; mock 车控执行不阻塞音频流。
- `[tau2-bench]` 响应性度量 (无响应时段统计) → 首字延迟/静默时段 = 现场体感量化。
- `[hass-local-openai]` /no_think thinking-token 抑制 (9.5s→1.7s 不掉准) + 流式三态切分器 (thinking 绝不进 speech) → **voice 延迟死门, Qwen3 系直接经验**; TTS 绝不能念思考内容, C7 端侧推理默认关思考链。

**(e) 幻觉 / 误听检测 (C7, ASR 语义层)**
- `[tau2-bench]` 幻觉检查器 (先推理后裁决 + 失败安全) → ASR/语义"编造用户没说的槽值"检测 (hallucination_reviewer.py)。
- `[hassil]` transcript_confidence 驱动 ASR 澄清 → C7 拼音 fuzzy 置信门 (与 D14 修正块对齐: Paraformer 靠拼音 fuzzy 不靠热词)。

### C3 / 跨层 (执行契约层 + trace, 已大量在 38 项 C3 #1-7)

> C3 已 apply done (swift test 46 绿)。本批是少量增量/二次印证, 不重新打开已实装的 gap#1/2/3/5/6。

- `[tau2-bench]` 通信协议守护 (不混文本+工具/不空/单发) + ENV-deferred 终止检查 (工具往返不被砍) → 单发铁律协议层硬校验 (一条消息=NL 或单跳 ToolCall); mock 工具执行期不触发超步终止 (二次印证 MAX_ITER=0)。
- `[agent-tester]` 单一 dispatch chokepoint + 防御性 dispatch (未知工具/异常→error 不崩) + Trace 四事件 + is_delegation 标记 → 禁真实车控物理无 backend; dispatch 即 trace 埋点; is_delegation→可标 L1/L2/慢路。
- `[simuhome]` 严格响应契约校验 _require_ok_response (fail-fast 形状门: status/error/data + 错误枚举) → 与 MAformac「错误用枚举/读回校验」铁律同。
- `[pipecat]` 配置不一致 start 时 RuntimeError 早炸 → 契约 SSOT 精神: 配置/契约错在初始化就炸不留运行时雷。
- `[livekit]`/`[pipecat]` request_id/turn_id stale guard (异步结果按 id 防错配 + 应用前二次校验) → 异步 mock 任务 (等降到 22 度) 带 turn_id 回写前校验 turn 仍 active (验收以读回 mock 态为准)。

---

## 2. filtered — 被 filter 的 (带理由, 真不适用才 drop)

> 不降级原则: 只 filter「与硬红线冲突 (JS/Python 零进 iOS / 禁自由 agent loop) + 重治理 ceremony (分布式/云/k8s) + demo 短对话用不上的长期记忆」, 工程价值全保留。

| 被 filter 项 | 来源 repo | filter 理由 (真不适用, 非降级) |
|---|---|---|
| MAX_ITERATIONS=8/10/15 自由 ReAct loop | agent-tester / hass-local-openai / iot-agent-bench | **撞硬红线**: MAformac 单发 (MAX_ITER=0, home-llm 同), 模型产单跳编排在 code; 这是云 agent 反面参照 (= Mastra loop 失败 #6827 进 C4 design Risks) |
| 安全约束写 system prompt (safety_first/explicit) | agent-tester | **撞架构铁律**: 安全是代码不是 prompt (prompt 约束不可信); 可作 LoRA 训练信号留, 不作 runtime 守护 |
| Python/Node runtime (Pydantic/httpx/FastAPI/litellm/Inspect AI/LangChain/openevals/langgraph/Weaviate/Docker/bash·jq·yq) | 全部 12 repo | **撞 CLAUDE §4 铁律**: Python·Node 零进 iOS; 翻译成 Swift Codable/actor/struct 设计思想, 不 import 任何载体 |
| 云/服务 provider (LiveKit WebRTC/OpenAI Realtime/Anthropic SDK/redis/k8s/真 A2A 多 agent 委派) | tau2 / livekit / simuhome / agent-tester | **撞纯端侧离线红线**: 端侧单模型无云无真 A2A; 委派语义可作 LoRA 落域信号 |
| LLM 自动摘要压缩 runtime (触发→请求→应用闭环) | pipecat / livekit / ha-core | **demo 短对话用不上** (违轻治理 over-engineering); 只取「未完成序列保护算法 + id 防错配」, 不要触发器本体; 长 session 才 adapt |
| 长期记忆 / 向量 DB RAG (Weaviate / Mem0 类) | hass-local-openai | **demo 短时记忆边界**: RAG 显式 per-turn-only 非长期记忆; 检索换内存 dict/封闭词表 (capabilities.yaml 派生), 不引向量 DB |
| 流式 delta 装配 + STREAM_RESPONSE_CHARS | ha-core | **home-llm teardown 已结论 demo 用非流式即可**; 流式复杂, 形态记录 |
| GatedLLMContextAggregator 背压 / async_tool 三态消息协议 | pipecat | 无等外部条件放行的背压场景; demo mock 车控同步即时回, 无需长跑异步工具协议 |
| 多 provider universal context + adapter 翻译 | pipecat / hass-local-openai | 端侧单一 Qwen 无多 provider; 统一 Tool schema 已由 C1 契约 SSOT 承担 |
| 图片/音频入上下文 (create_image/audio_message) + Images API 生图 | pipecat / hass-local-openai | demo 纯文本+语音指令无多模态入史需求 |
| websocket/AES 加密/重连 / dig_for_message 栈魔法 / OVOS pipeline 黑名单治理 / MessageCollector 多域竞答 | ovos-bus-client | 纯端侧进程内无后端; AES 半成品原作者已 deprecated (反面教训: 没做完的安全机制不如不做); 多域竞答存档**二期 MCP 多域**解冻 |
| Matter 47 cluster/80+ docs 全协议建模 / parallel_model_evaluation 1445 行多模型云编排 | simuhome | 量产协议广度 + 多模型云评测编排; solo demo 单模型 Mac 离线轻量脚本即可 |
| HA 平台基建 (实体/区域/satellite/wake-word/Event bus/config_flow UI/ConfigFlow 747 行) / 800 条 IoT 语料 / paper LaTeX | ha-core / hass-local-openai / iot-agent-bench | HA 专属载体 + 论文产物; 换车控全集 (3990 协议+12000 bug), 只 adopt 生成配方不 adopt 语料; demo 不发论文 |
| LangGraph state-history 递归抽取 (Pregel/StateSnapshot) / filter_with_regex 模板预编译 | agentevals / hassil | 无 LangGraph runtime, trace 自己埋点; 模板预编译 backlog (demo 规则量小未必需要, 先记不实装) |
| fuzzy.py n-gram/Kneser-Ney/trie/fst 统计 NLU 引擎本体 | hassil | 统计 NLU 引擎整体不移植; MAformac 慢路用 Qwen3+LoRA, 只借学说不借实现 |
| GGUF 多量化矩阵 / ollama·llama.cpp subprocess | tool-calling-benchmark / ha-voiceagent-bench | 端侧 mlx-swift 非 GGUF/ollama; 量化矩阵思想保留 (1.7B vs 0.6B fallback 对比) 换 mlx |

---

## 3. tigers — 综合 pre-mortem 真威胁 (每个带 mitigation)

> 三分类只列 tiger (真威胁); paper-tiger/elephant 附后。HIGH 强制停下让磊哥拍 (见 §4)。

| # | tiger | 严重度 | 证据 (来源 repo / 项目) | mitigation |
|---|---|---|---|---|
| T-A | **多 run 稳定性假象**: 单 seed 单跑 = 抛硬币, 端侧小模型采样抖动会假报回归/假报提升, 掩盖真实能力 | HIGH | tool-calling-benchmark (20-run 第二轮全部理由) / iot-agent-bench (N_SEEDS=3) / tau2 (pass^k) / simuhome (parity 守护) | C6.1: base/边界 case 每 case N≥5 run, 报 pass^1+pass^N + Reliability; temp=0 求确定性; 3 样本字节同一才计 real FAIL (nano flaky 检测), 分叉标 flaky; INFRASTRUCTURE_ERROR 剔除不污染覆盖率。**(已对齐 overview Tiger 8 + OQ1, base 每 case 5 次已拍)** |
| T-B | **false barge-in 打断误触发 + history 撒谎**: 咳嗽/单字 backchannel 误打断; 被打断写 LLM 生成全文而非实播文本 → DialogueState 历史与实际不符, 下轮喂模型崩 | HIGH | livekit (synchronized_transcript + 双门 + pause-not-kill) / pipecat (中断即提交已播出) / ovos (事件驱动状态位) | C7: 打断写史合同 = 实播文本 + interrupted 标记 (mock TTS 回报播放位置); barge-in 双门 min_duration∩min_words (中文字数门); pause-not-kill + false-interruption resume; INTERRUPTION_TIMEOUT=5.0 超时兜底; system frame 永不阻塞。**首版按钮打断 (D13) 先规避; 第二刀语音自动打断时全套上** |
| T-C | **context rot (上下文腐烂)**: 多轮累积/裁剪不当 → 孤儿 tool_call / system prompt 被删 / 动态内容进 system 毁 KV 缓存 → 越答越差且不报错 | HIGH | pipecat (未完成序列保护) / livekit (truncate 三防御) / hass-local-openai (注入位置+KV 友好) / ha-core (删孤立 tool result) / Mastra #6827 (context rot 不报错越答越差, 已在 C4 design Risks) | C4/C7: 裁剪保 system[0] + 尾 N 滑窗 + 不以孤儿 fc 开头 + 删孤立 tool result; 函数调用发出即写 IN_PROGRESS 占位; date/RAG 注入到 user 前一位不进 system (保 KV 缓存); token 纯字符估算监控累积。配 home-llm KV 预热 |
| T-D | **工具幻觉 / 越界静默成功**: 模型编造用户没说的槽值 / 调 L1 allowlist 外/未知工具 → 若不 no-op 会崩, 若 catch 静默吞会假绿 (vacuous-PASS) | HIGH | tau2 (no-op 重放 + 幻觉检查器) / iot-agent-bench (device_untouched 负向) / nano (否定断言先证产物存在) / agent-tester (防御性 dispatch) | runtime: DemoGuard 越界=no-op+TTS 兜底 (错误是数据 ToolMessage error=True 不是异常); C7 幻觉检查器 (先推理后裁决+失败安全); C6: device_untouched 负向断言一等公民, 拒识/空匹配 check 不能 vacuous-PASS (nano BLK-7), 否定断言先证产物存在 |
| T-E | **C5 训练数据泄漏污染 C6 must-pass**: train/test 没物理隔离 → LoRA 死记 C6 must-pass case, 提升不可信 | HIGH | tau2 (train/test/base split task_id 硬分) / nano (派生物双 sha 指纹) / overview Tiger 4 | C5: must_not_train 标记 + split whitelist + parent_overlap=0 + verification_receipt; base=train∪test, C6 跑 base, test=held-out; **#39 格式契约单一源 + #40 replay 指纹防 train/runtime/bench 三者 silent 失真** (已在 38 项 Q2/Q5) |
| T-F | **judge 洗白硬失败 / 从自由文本 grep 判决**: LLM-judge 改判确定性硬门 → 安全/状态失败被话术分掩盖 | MEDIUM | agentevals (两轴正交 judge 永不改判硬门) / nano (HIGH-4 别从自由文本 grep PASS/FAIL) / ha-voiceagent-bench (eval 可信纪律) | C6: judge 只评 clarify/refusal 主观文本, 仅硬门全过后计算, 不参与放行硬门 (已锁 38 项 Q3); judge 强制 reasoning 在 verdict 前, 解析失败 fallback 安全侧不误杀; 结构化 verdict 不 grep 自由文本; 不可用→null 非 FAIL |
| T-G | **数据/PII 泄漏入仓**: trace/DialogueState 可序列化的代价 = 落盘可能带 PII/位置/真实语料; gold 血缘账本可能引原文 | MEDIUM | ovos (禁 log session 全文密码/key) / nano (fixture path-traversal 守护) / CLAUDE §6 红线 | DialogueState trace 落盘过脱敏门 (车型代号 private 可、PII/位置/真实语料必脱敏不入仓); 原始中文语料本机只读不入仓 (仅 LoRA 权重产物入仓); fixture path-traversal 守护; gold 账本只放 manifest hash + 派生镜像 |
| T-H | **Qwen3.5-2B tool-parser 不兼容静默失败**: stock 模板不发 `<tool_call>` 标签 → qwen3_coder parser 不激活 → content:'' 无 tool_calls (静默失败), 撞项目 T2 坑并放大 | HIGH | mlx-lm #1293 + 项目 T2 (execution-pre-mortem:12) + intent-routing 实测 22.5% 裸 JSON | **S1 spike (升主力前死门)**: 直读 mlx-swift-lm parser 源码 + 实跑 ≥10 条车控 prompt 断言收 .toolCall 非 .chunk; froggeric 修复模板 / qwen3_xml parser; ToolCallFrame 薄层兜底裸 JSON。**S1 不过 = 维持 1.7B 主力** |
| T-I | **Qwen3.5-2B GDN 端侧 prefill 退化**: mlx-swift 无原生 GDN 层, Metal 无优化 kernel → prefill O(T) 逐 token, TTFT 暴涨 (实证 14x latency regression) | HIGH | mlx-swift 内置层无 GDN + Medium 14x regression + GDN 分析 gist | **S2 spike (升主力前死门)**: iPhone 真机 (GDN 版非 VL 版) 实测 TTFT + decode tok/s + 峰值 RAM; CoreML 双模型 (prefill+decode); Soniqo/Rapid-MLX 第三方 GDN 实现。**S2 不过 = 退 1.7B** |
| T-J | **Qwen3.5-2B 命门维度无 2B 实测 + thinking-loop**: tool-call/中文/restraint 三个 demo 命门无 2B 公开分, 可能比 1.7B 本地冠军 (0.960) 回退; 2B 特有 thinking-loop 不终止威胁"秒回不崩" | MEDIUM | 本地 bench 无 Qwen3.5 + BFCL 无 2B 分 + 参数量 weak predictor + HF card 明示 loop | S3 同 harness 20-run 对照 (回退则不升); S4 enable_thinking=false + 流式硬超时中断。**这两个 spike 在升级 apply 阶段做, 非升不升的决策门** |

**Paper-tigers (看似威胁实际安全, 给证据)**:
1. **必须引入外部 eval 框架** — 不成立。吸收 task/scorer/trace 形态, 本地 Swift/CLI harness 足够, 外部框架零进 iOS (overview 已证)。
2. **C6 必须等 C5 才有意义** — 不成立。C6 base 是 C5 是否有效的前置判据 (这正是三刀依赖序的根本纪律)。
3. **apple-silicon-llm-bench 61.2 tok/s 那行可能是 Qwen3-VL-2B 非 GDN 版** — WebFetch 未确证; S2 自测以 `Qwen/Qwen3.5-2B` GDN 版为准, 不信混淆数。
4. **旧 GGUF 触发 FGDN_AR 断言崩溃** — 项目主线 mlx-swift 非 GGUF, llama.cpp 仅 fallback, 最新 build + 新转换即避。
5. **C6 必须接 ASR 才算端到端** — 不成立。C6 是开发期文本/transcript bench, C7 才负责 audio。

**Elephants (没人想谈的)**:
1. **dataset 作者纪律比 runner 代码更难** — source_refs/负样本/must-pass/heldout/quarantine/leakage/gold 血缘都要可审; gold 不是天授会被修订 (tau2 75+ fixes / iot-agent-bench verify_gold)。
2. **客户现场"不丢脸"≠自动化指标全覆盖** — TTS 听感/视觉惊艳/演示节奏/冷启动仍要人工 S-PASS/V-PASS, 不进 C6 judge。
3. **eval 不是一次性资产** — 每个 C5 checkpoint/C4 route 改动/C7 ASR 更新都要复跑同一套 fingerprinted harness。
4. **短时记忆是 C4 子结构不是新 capability** — 五个生产 repo 一致证明这是确定性 code 状态机, 不要为它新建一层 (避免 over-engineering)。

---

## 4. high_decisions — 需磊哥拍的 HIGH

| # | HIGH 决策 | ⭐ 推荐 (default) | 量化预算 / 理由 |
|---|---|---|---|
| H1 | **Qwen3.5-2B 升不升主力?** | ⭐ **条件升级: 先 S1+S2 两个死门 spike 再切, 不先训 LoRA** | spike ≈0.5-1 天 (直读 mlx-swift parser 源码 + iPhone 真机实采 tool-call & TTFT)。S1 通过 (parser 认 Qwen3.5 模板/解析率≥1.7B 87.5%) + S2 通过 (TTFT≤1.7B 同量级/decode≥40 tok/s/RAM<2GB) → 升 2B 主力, 1.7B 降 fallback; S1 不过 → 维持 1.7B 主力 (本地 judgment 冠军, 零迁移)。端侧 RAM/decode 已过 D38 4B 天花板 gate, 不是 blocker |
| H2 | **短时记忆 DialogueState 落 C4 还是新 capability?** | ⭐ **落 C4 (作 DialogueState 子结构), 不新建层** | 五个生产 repo (ha-core/ovos/livekit/pipecat/hassil) 一致 = 确定性 code 状态机 (可序列化 Session + 单写者 + 帧栈衰减 + 事件驱动状态位), 直接咬合 SRD §5.1 铁律 + 三层路由。新建 capability = over-engineering (违轻治理)。C4 propose 时把 DialogueState/ContextGate/锁域栈写进 design |
| H3 | **C6.1 扩展包 apply 时机?** | ⭐ **C6 base Qwen3-1.7B 真跑后再开 C6.1, 第二刀只锁现 11 Requirement** | C6 已 SOLID 不动。C6.1 候选 (run_repetitions/failure-receipt/pass^k/容差 matcher/gold 血缘自洽守护/feasibility oracle/时间演化 case) 全量收 (不降级), 但分批: base 真跑暴露真实需求后扩, 避免第二刀过宽 (呼应 overview OQ2: SimuHome 状态演化字段留 C6.1 不进 v1) |
| H4 | **C5 run 策略 (训练前数据门 vs 先训)?** | ⭐ **第三刀 C5 先 verification_receipt + split whitelist + masking 三形态 + must_not_train=0, 再扩数据, 不先训练** | 没 C6 base, C5 LoRA 只是"感觉提升"。C5 生成脚本每批吐 receipt (row_count/bucket_counts/format_contract_version/parent_overlap/must_not_train_violations); 硬门 parent_overlap=0 + must_not_train=0 + #39 格式合规。failure→propose_fix(auto_apply:false) 喂数据增广永不自动改权重 |
| H5 | **C7 打断: 首版按钮 (D13) vs 直接上语音自动打断?** | ⭐ **首版按钮打断 (D13 已锁), 但打断写史合同 (实播文本+interrupted) 首版即上** | 写史合同是 DialogueState 根, 按钮/语音打断都要 (否则 history 撒谎)。语音自动打断 (双门 min_duration∩min_words + pause-not-kill) 是 C7 第二刀, 中文字数门需改中文分词。INTERRUPTION_TIMEOUT 超时兜底首版即上 (防卡死) |
| H6 | **judge 边界 + 多正解 quality 标签是否进 C6 金标?** | ⭐ **进: judge 不参与放行硬门 (已锁 Q3) + 金标带 alternative+quality (optimal/acceptable/degraded)** | 「不丢脸」精确定义 = 命中 optimal/acceptable 不丢脸、degraded/越界才丢脸 (ha-voiceagent-bench)。无 alt+quality 同句多正解被冤杀。judge 只评 clarify/refusal 主观文本, 硬失败不可改判, 不从自由文本 grep |

---

## 5. synthesis_path (综合落地路径, 衔接鸟瞰图三刀)

衔接已锁三刀 (第一刀归位 / 第二刀 C6 / 第三刀 C5) + C4 解冻 + C7:

```text
现状: C1/C2 archived → C3 apply done (46 绿) → C6 第二刀 apply 中 (11 Req SOLID)
  │
  ├─[第二刀 C6, 不扩]  锁现 11 Requirement, base Qwen3-1.7B 真跑 (硬完成条件)
  │                    本批新增量不塞进第二刀, 只把 §1-C6 findings 记进 C6.1 backlog
  │
  ├─[Qwen spike, 并行] S1 (mlx-swift parser + tool-call 实采) + S2 (iPhone GDN TTFT)
  │                    ≈0.5-1 天死门 → 拍 H1 (升 2B / 守 1.7B); 不先训 LoRA
  │
  ├─[第三刀 C5]        verification_receipt + split whitelist + masking 三形态 + must_not_train=0
  │                    + tau2 train/test/base split; failure→propose_fix 喂数据增广 (不自动改权重)
  │                    在 C6 base 之后 (H4)
  │
  ├─[C6.1 扩展, base 真跑后] run_repetitions/pass^k + failure-receipt 脊柱 (nano) + 容差 matcher
  │                    (agentevals overrides 统一出口) + gold 自洽守护 (iot verify_gold) + alt+quality
  │                    金标 (H6) + feasibility oracle + 时间演化 case (simuhome, 最后)
  │
  ├─[C4 propose 解冻]   DialogueState 落 C4 (H2): ha-core 三正交对象 + ovos 单例/帧栈衰减 +
  │                    hassil context dict/锁域/消歧 + 流式 ToolCall 累积 + KV 友好注入 +
  │                    路由轨迹评测 (agentevals graph_trajectory); Mastra loop 失败进 design Risks
  │
  └─[C7 propose 解冻]   打断写史合同 (livekit synchronized_transcript, 首版即上 H5) +
                       超时兜底 + 短时 history 三防御裁剪 + /no_think 抑制 (延迟死门) +
                       全双工/响应性度量 (第二刀) + 幻觉检查器; D14 sherpa+ASRBackend 已锁
```

**三条不可违反的纪律 (贯穿全路径)**:
1. **C6 优先于 C5** (没评测先于训练 = 感觉提升); **数据门先于扩数据**; **C6 base 先于 LoRA diff**。
2. **单发 + 安全是代码 + Python·Node 零进 iOS + 禁自由 agent loop** — 12 repo 的所有 loop/prompt 安全/runtime 载体全 filter, 只翻 Swift 设计思想。
3. **不降级**: star>1000 repo 工程价值全量吸收 (judge/完整 pipeline/失败收据/容差 matcher/帧栈衰减), 只 filter 真不适用载体; C6.1 分批 apply ≠ 降级, 是依赖序 (base 真跑暴露真实需求)。

**元洞察**: 这 14 份 teardown 一致印证 home-llm 的反转架构结论 — **让小模型/弱组件可靠的不是模型本身, 是外围工程** (eval 端: 端态哈希+no-op+pass^k+容差 matcher+失败收据+train/test 隔离; memory 端: 可序列化 Session+单写者+帧栈衰减+copy-on-write 写史+超时兜底)。这些全在代码里、README 看不到。MAformac 的 C4/C5/C6/C7 该照搬的正是这套外围工程, 而非"再找一个 bench/agent 框架"。

---

## 附: 来源 repo 索引 (license 已核)

| repo | license | 服务层 | clone 状态 |
|---|---|---|---|
| sierra-research/tau2-bench | MIT | C6/C7 (+C3/C5) | — |
| reinhardjurk/agent-tester | No license (设计思想翻 Swift, 不抄码) | C6 (+C2/C3/C4/C7) | ref-repos 只读 |
| MikeVeerman/tool-calling-benchmark | "Use freely; attribution appreciated" | C6 (+C4/C5) | ref-repos 只读 |
| cdeshpa2/iot-agent-bench | MIT(code)/CC BY 4.0(tasks) | C6 (+C4/C5/C2) | — |
| holi-lab/SimuHome | CC BY-NC-ND 4.0 (设计思想, 不抄码) | C6 (+C3/C1) | ref-repos 只读 |
| langchain-ai/agentevals | MIT | C6 (+C4) | ref-repos 只读 |
| nano-step/eval-harness | MIT | C6 (+C5/C4/C7) | — |
| Drizzt321/ha-voiceagent-llm-benchmark | Apache-2.0 | C6 (+C7) | ref-repos 只读 |
| livekit/agents | (Apache) | C7 (+C4/C6) | ref-repos 只读 (--depth 1) |
| pipecat-ai/pipecat | BSD-2-Clause (设计思想, 不抄码) | C7 (+C3) | — |
| home-assistant/core (ha-core) | Apache-2.0 | C7 (+C4) | ref-repos 只读 (sparse) |
| OHF-Voice/hassil | Apache-2.0 | C4 (+C1/C2/C7) | — |
| skye-harris/hass_local_openai_llm | Apache-2.0 | C4 (+C7) | ref-repos 只读 |
| OpenVoiceOS/ovos-bus-client | Apache 2.0 | C4 | — |
| Qwen3.5-2B 可行性报告 | (research) | 大脑选型 | docs/research |

> 所有 clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/` 只读, 不进仓 (CLAUDE §6); 无 license / NC / ND 的只翻设计思想成 Swift, 不复制代码。

---

## 6. 综合官补强 (二次全读 21 份后增量, 2026-06-20)

> 本节由综合官第二轮全读 (含 5 oracle + C6 已 apply 现状核对) 后**增量追加**, 不覆盖上方已完成的综合 (唯一权威源纪律)。补三处上方未覆盖/已过时的点。

### 6.1 C6 现状更正 + 3 NIT 是 C5 前置 (上方 §1-C6/§5 写"第二刀 apply 中", 现已过时)

**核对**: C6 `define-vehicle-tool-bench` **已 apply done** (merge main `6d02771`, 两层 CC 审 SOLID), 不再是"apply 中"; 仍在 `openspec/changes/` 未 archive。**base Qwen3-1.7B 无 LoRA 已如实跑出 hard_fail** (IrrelAcc 0.789<0.9 / hard_failure 170/225 = base 真差非 bench bug, Layer 2 逐 case 实证: base 把 toolCall 藏 content 文本 / 参数温度 22≠26 / 该拒乱调 / 从不生成中文读回) = C5 提升的诚实可复现基线锚点。

**C6 三 NIT (38 项执行进度记载, 非 BLOCKER 但是 C5 前置)** — 上方综合未纳入, 补:
- **NIT 1 (C5 前必修) — readback 门退化为纯文本检查**: `C6ReadbackRenderer.render` 在 delta 非空时返机器 key 丢中文渲染 → 门只测「有无中文 token」, 测不出「读回内容与 mock state 一致」。**C5 用 readback 门验读回态正确性前, 改 render=mock state→中文模板再比对**。← 正是 simuhome `sync_device_sensor_from_env:273-280`(传感器读数来自环境非自编) + ha-voiceagent K7 `_raw` malformed 信号该补的。
- **NIT 2 (二期) — coverage 0.0134 (9/671 device) dataset 规模 MVP**: 全集 device 分层抽样 (每 device≥1) 留后续; 小瑕疵 `representedDevices` 把 `out_of_domain` 计进分子虚高。
- **NIT 3 (C5 前必修) — model 权重 sha256 未进 eval 产物**: replay 10 字段完整, 但锁权重靠 model_id 字符串非 hash。**C5 base↔LoRA diff 前补 model 权重 hash 入 envelope**。
- **走法 (流程约束)**: C6 已 apply 不改其 11 Requirement spec; NIT 1/3 走 **C5 dispatch 内的 C6 复跑环节** (base 重跑时修), 或 C6.1 增量。这与上方 §1-C6「新 findings 归 C6.1 扩展包」一致, 但**点名 NIT 1/3 是 C5 硬前置, 不可留二期**。

### 6.2 verify_gold 自洽守护 + 判断陷阱样本 = E1 最该补 (上方 §1-C6(f)/§3-E1 已提, 补"为何是 C5 前置")

上方已收 iot verify_gold (§1-C6(f)) 和"dataset 作者纪律比 runner 难"(§3-Elephant 1)。补一条**实操扳机**: C6 现有 45 条 case (`contracts/c6-bench-cases.jsonl`) **多为 coverage 抽样 (C6-COV-*, 即"覆盖抽样: ac_temperature query"类), 判断陷阱样本几乎没有** (关键词诱饵/否定/上下文冗余/隐式推理, tool-calling-benchmark §4.2)。
- **后果**: 没有判断陷阱样本 + verify_gold, **C6 base 测不出 LoRA 真价值**, 也分不清"模型蠢 vs 金标坏"。base 0.789 IrrelAcc 是覆盖抽样上的, 真正的"有点冷→26 度反填"(F2/F7)、"别开空调把窗打开"(否定)、"26 度有点热别再查温度"(冗余) 这些 demo 不丢脸命门陷阱**还没测**。
- **C5 前补**: 从 3990 协议 + 12000 bug 挖否定/诱饵/模糊变体扩 C6 cases (对齐 F1-F10 + 判断陷阱设计法), 配 verify_gold 让 bench 先过自己的考。约 1 天 (挖样本) + 半天 (verify_gold)。

### 6.3 两处诚实暴露 (21 份内部矛盾 / 待澄清, §28 一手核对)

1. **两份 voice oracle 的 TTL 数值不一致 (须 C4 契约时澄清)**: `voice-short-term-memory-oracle` 给 `ttl_seconds: 300`(5 分钟, 对齐 HA ChatSession); `voice-short-context-memory-oracle` 给 `ttl_seconds: 90` + `focus_entity.expires_at`。**实际不矛盾, 是两层 TTL**: 300=session TTL, 90=focus/锁域 TTL (指代继承更短失效防串台, 对齐 ovos「软过期清栈不删 session」)。**C4 落 DialogueState 契约时须显式分两层 (session_ttl=300 / focus_ttl=90), 别混用** — 上方 H2 未点明这一点。
2. **mastra teardown 内部曾自相矛盾 (已被项目自纠, 记录防回潮)**: mastra raw teardown §B 原写 "LLM-as-judge drop"(raw:42), 同文档又写"单次文本评分留"。这是 38 项 Q3 已纠的"原标 drop 默认 → 提回"。**确认: C6 spec Req 8 已正确落 (judge 不改判硬门 + 只评 clarify/refusal 文本), 无需再动**; 记录此矛盾防未来吸纳时误读 raw:42 那句又把 judge 砍了 (这是不降级翻案的实证案例)。
3. **吸纳纪律须守 (T11/§28)**: agent-tester `feeling_hot.json` 的 `[16,23]` 温度、tool-calling-benchmark 的 0.4/0.3/0.3 权重是**蓝本部署偏好/语料, 非 MAformac 真值**。MAformac execution_range = 18-32℃/1-10 档/0-100% (CLAUDE §5 一手契约)。吸纳时**只借 RangeMatch/权重=部署偏好的形态, 数值从 MAformac 一手契约来**, 不照搬蓝本数字。

### 6.4 补强小结

上方综合已**结构完整且高质量** (C4/C5/C6/C7 全覆盖带 file:line + 10 tiger + 6 HIGH + 不降级二筛 + synthesis_path)。本节只补: ① C6 现状更正 (apply done 非进行中) + 3 NIT 点名 (NIT 1/3 是 C5 硬前置) ② 判断陷阱样本 + verify_gold 是 C5 前置的实操扳机 (现有 45 cases 缺命门陷阱样本) ③ 两层 TTL 澄清 + mastra judge 矛盾记录 + 蓝本数值不照搬纪律。**无与已锁契约硬冲突; C6 现有 11 Req 与全部吸纳项方向一致, 新 findings 走 C5 复跑/C6.1 增量不动已 apply 的 spec。**
