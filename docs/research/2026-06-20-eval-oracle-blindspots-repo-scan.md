# MAformac eval oracle 补盲：近期活跃 eval repo/benchmark 扫描

日期：2026-06-20  
活跃窗口：按最近 3 个月计，优先 `pushed_at >= 2026-03-20`。  
任务口径：补 BFCL / home-llm 之外的盲点，覆盖智能家居/车控/IoT、语音 ASR+NLU、中文/本地小模型、tool/no-tool 弃权、状态仿真、数据泄漏/切分卫生。

## 检索说明

已读检索模块：

- `~/.codex/agents/web-search-modules/general-web.md`
- `~/.codex/agents/web-search-modules/github-debug.md`
- `~/.codex/agents/web-search-modules/academic-papers.md`

主要 query 变体：

- `LLM smart home benchmark pushed:>2026-03-20`
- `IoT LLM agent benchmark pushed:>2026-03-20`
- `voice assistant benchmark pushed:>2026-03-20`
- `ASR NLU benchmark Chinese pushed:>2026-03-20`
- `Qwen tool calling benchmark pushed:>2026-03-20`
- `tool use abstention benchmark no tool call hallucination`
- `stateful agent benchmark simulation pushed:>2026-03-20`
- `HomeBench smart home valid invalid instructions GitHub ACL 2025`
- `HalluAudio benchmark GitHub hallucination detection LALM 2026`
- `车载 语音 NLU pushed:>2026-03-20`

## Key Findings

1. **最贴 C6 的新方向不是通用 function calling，而是“状态环境 + 拒识/非法动作 + 端态校验”。** `SimuHome`、`IoTAgentBench`、`tau2-bench` 都把工具调用放进环境状态里评估，比只看 `tool_name/args` 更接近 MAformac 的 mock state/readback。
2. **语音侧要分两层吸收。** `VoiceBench` / `HalluAudio` 适合 C7 的音频鲁棒、误听、幻觉、拒答偏差；`ha-voiceagent-llm-benchmark` 更贴 C6/C7 之间的 normalized transcript → tool-call 评测。
3. **本地小模型评测必须多次重复跑。** `MikeVeerman/tool-calling-benchmark` 显示 3 次多数投票会误判边界 prompt，20 次后 Qwen3-1.7B 排名反转。MAformac C6 不能只跑单 seed 后说 LoRA 提升。
4. **中文/车载强相关源存在，但成熟度低。** `dengky23/nlu-pipeline-vehicle` 和 `agent-safety-bench-zh` 值得借 schema/样本类型，不宜直接当权威 benchmark。
5. **数据切分卫生的最好现成借鉴来自 `tau2-bench`。** 它显式提供 train/test split、base split、任务质量修正记录；MAformac 的 `must_not_train` 和 C5/C6 泄漏门应照这个方向做成可审计字段。

## 候选源

| Repo / 来源 | 类型 | 近期活跃证据 | eval 机制 | MAformac 吸收建议 / 风险 |
|---|---|---:|---|---|
| https://github.com/holi-lab/SimuHome | 智能家居状态仿真 benchmark | GitHub `pushed_at=2026-04-08`, `updated_at=2026-06-12`; README 标 ICLR 2026 Oral | 基于 Matter 的 time-accelerated simulator；设备动作持续影响温度/湿度等环境变量；支持虚拟时间工作流调度；`eval_spec` 支持 run/resume | **吸收**：给 C6 增加“延迟生效/环境变化/时间推进”的 stateful case 类型。**风险**：License 为 CC BY-NC-ND，方法可借，代码/数据不要复制；README 明说当前 repo 结果不保证复现论文数值。 |
| https://github.com/cdeshpa2/iot-agent-bench | IoT agent benchmark | `pushed_at=2026-04-27`; 0 star 新仓 | 800 tasks，Smart Home + Industrial Predictive Maintenance，5 complexity tiers；schema 有 `gold_tool_calls`、`verifier.kind = numeric/string/set/state/refusal/composite`、`safety_checks`、`forbidden_action`、`is_invalid`；verifier 同时算 state、tool F1、safety score、refusal | **吸收**：C6 `c6-bench-cases.jsonl` 可加 `safety_checks`、`forbidden_action`、`is_invalid`、`verifier_kind`。拒识 case 允许最多一个 read-only 查询的规则，适合“先读状态再拒绝”。**风险**：新仓、合成味重，不能直接采数值结论。 |
| https://github.com/Drizzt321/ha-voiceagent-llm-benchmark | Home Assistant voice LLM benchmark | `pushed_at=2026-05-16`; 仓内有 2026-04 报告 | Inspect AI + llama.cpp/OpenAI-compatible server；给模型暴露 32 个 HA intent tools；`generate(tool_calls="none")` 捕获 tool call 但不执行；报告分 `format_valid`、`hallucinated_tools`、call_count、tool_name 等 | **吸收**：C6 可复用“工具 no-op 捕获”的测试形态，避免 eval 阶段真实执行；C7 可借本地 llama.cpp server 跑 normalized transcript。**风险**：HA 领域，不含端态读回；报告有单 run 样本，不能当统计结论。 |
| https://github.com/sierra-research/tau2-bench | 多轮工具-用户-环境仿真 benchmark | `pushed_at=2026-06-11`, `updated_at=2026-06-20`; 活跃维护 | 支持 text half-duplex、voice full-duplex、knowledge retrieval、Gym interface；README/RELEASE_NOTES 明确 train/test splits；CHANGELOG 有 75+ task fixes、错误 gold 修正、hallucinated tool calls 作为 no-op 回放并靠 DB-state mismatch 失败 | **吸收**：C6/C7 trace 可采用“工具幻觉不算 infra、作为 no-op 继续评分”；C5/C6 泄漏用 train/test/base split + `must_not_train`；语音全双工部分可作为 C7 后续参考。**风险**：客服域，不是车控；复杂度高，不应引入 runtime。 |
| https://github.com/MatthewCYM/VoiceBench | 语音 assistant benchmark | `pushed_at=2026-06-11`; README 更新含 2026-04 HalluAudio 指针；TACL'26 | Hugging Face dataset；同时支持 cascaded ASR+LLM、omni speech-in/out、text-only；包含 open QA、IFEval、AdvBench、harm evaluator、GPT judge 等 | **吸收**：C7 做 audio vs normalized transcript delta，拆出 ASR 错误和 NLU/LLM 错误；增加 refusal_rate / harm 类指标。**风险**：通用 assistant，不测工具执行和车控端态。 |
| https://github.com/Feiyuzhao25/halluaudio | 音频幻觉 benchmark | `pushed_at=2026-06-16`; arXiv 2026-04 | 5,720 human-verified QA pairs；speech/environment/music；指标含 hallucination rate、yes prediction ratio、false refusal rate、adversarial/mixed audio | **吸收**：C7 加“误听后过度肯定”和“可答却拒答”双指标；对车内噪声/混合音频做小型子集。**风险**：代码里有硬编码 Windows 路径，工程质量一般；不含 tool/state。 |
| https://github.com/facebookresearch/WearVox | egocentric multichannel voice assistant benchmark | `pushed_at=2026-04-24`, `updated_at=2026-06-13` | 多通道、穿戴式、近场/环境语音 assistant benchmark；本轮 clone 因大文件/网络未完成，需二次深挖 README/数据 schema | **吸收**：C7 车内多麦/噪声/远近场鲁棒可参考。**风险**：未完成本地代码核验；先列为 follow-up，不进入 C6 硬门依据。 |
| https://github.com/MikeVeerman/tool-calling-benchmark | 本地小模型 tool-call benchmark | `pushed_at=2026-04-01`, `updated_at=2026-06-16`; Round3 报告 | CPU-only，Ollama/llama.cpp，本地小模型；21 models、12 prompts、20 runs；指标含 Action、Restraint、Wrong Tool、Reliability、Agent Score；Qwen3-1.7B / 0.6B / Qwen2.5 小模型都有结果 | **吸收**：C6 base/LoRA diff 每个边界 case 至少多 seed/多 run；报告 `Reliability` 而非只报 majority pass。**风险**：prompt 数少、toy tools、非状态仿真；结果只能指导“重复跑纪律”。 |
| https://github.com/reinhardjurk/agent-tester | 车载 voice assistant agent test framework | `pushed_at=2026-05-20`; 小仓 | 面向 in-vehicle voice assistant；支持 Anthropic/Ollama；case 有 utterances、initial vehicle state、required/forbidden tool calls、acceptable alternatives；per (case, profile) fresh stub registry；全 trace；禁止真实车控 | **吸收**：这是最贴 MAformac 的 case/profile/context bundle 形态。C6 可借 `profile × case` 矩阵、required/forbidden tool、alternatives、trace HTML。**风险**：个人小仓、样本少，不是公认 benchmark。 |
| https://github.com/dengky23/nlu-pipeline-vehicle | 中文车载 NLU pipeline | `pushed_at=2026-06-02` | 中文/中英混合车控 query；JSGF-like rules、intent+slot、slot normalization、confidence、intent accuracy/slot F1；含 data augmentation | **吸收**：C5 数据生成加入中英混说、槽位归一化失败标签；C4 规则快路可借 confidence/top-k 输出。**风险**：不是 benchmark；源码多处 `eval()`，只借思路不借实现。 |
| https://github.com/eggrollofchaos/hpml-assetopsbench-smart-grid-mcp | 工业 IoT / SmartGrid MCP benchmark | `pushed_at=2026-06-17`; artifacts/reports 完整 | SmartGrid transformer maintenance；direct tool vs MCP baseline vs optimized MCP；Agent-as-Tool vs Plan-Execute vs Verified PE；scenario 字段含 `expected_tools`、`ground_truth`、`difficulty`、`domain_tags`；记录 latency、judge score、failure taxonomy | **吸收**：C6/C3 trace 可把 transport/runtime/prompt/quality 分开记录；不要只用一个总分。**风险**：工业电网非车控；judge-heavy，小样本 trial。 |
| https://github.com/uninhibited-scholar/agent-safety-bench-zh | 中文 agent 安全 WIP | GitHub search 显示 `pushed_at=2026-06-20` | 描述为中文 agent 安全评测：危险工具调用、提示注入、机器评分 | **吸收**：C6 no-tool / forbidden tool / prompt injection 中文负样本候选。**风险**：WIP，未深挖，下一轮需 clone/read schema。 |

## 方法可借但活跃性不达标或不优先

| 来源 | 状态 | 仍有价值 |
|---|---|---|
| https://github.com/BITHLP/HomeBench | `pushed_at=2025-05-22`，不满足近 3 个月活跃；ACL 2025 | 智能家居 valid/invalid instruction、single/multi-device 设计很贴 C6 负样本，但不要按“近期活跃 repo”引用。 |
| https://github.com/NVIDIA/When2Call | `pushed_at=2025-04-29`，不满足近 3 个月活跃 | “何时不调用工具”的训练/评测思想可借，尤其 cannot_answer / RFI 负样本。 |
| https://github.com/ToolBeHonest/ToolBeHonest | `pushed_at=2024-09-23`，不满足近 3 个月活跃 | Tool hallucination depth/breadth 诊断框架可作为命名参考。 |
| https://github.com/apple/ToolSandbox | `pushed_at=2025-11-07`，但 `updated_at=2026-06-12`；严格不算近期 pushed | 状态快照、milestone/minefield similarity、insufficient information scenarios 很好；本轮只列二线方法源。 |
| https://github.com/mtkresearch/function-calling-leaderboard-for-zhtw | `pushed_at=2024-11-25`，不满足近 3 个月活跃 | 繁中 function calling localized benchmark；中文工具调用方向可扫，但不贴车控。 |

## 对 MAformac 的建议

### C6 `vehicle-tool-bench`

建议把当前 schema 从 `expected_tool_calls / expect_no_call / expected_state_delta / readback_assertion / clarify_tag / failure_class` 扩成可选字段：

```yaml
verifier_kind: tool_call|state|refusal|composite
safety_checks:
  - forbidden_action: string
    severity: low|medium|high
invalid_reason: unsupported_device|unsafe_action|missing_slot|ambiguous_target|irrelevant_domain
allowed_probe_tools: ["read_state"]   # 拒识前最多允许的只读工具
run_repetitions: 5|20                 # 边界 case 必须多次跑
split: must_pass|eval|dev|train_forbidden
source_family: c1_contract|demo_seed|negative_synthetic|voice_normalized|adversarial
```

### C7 voice

- 音频端不要只看 WER；至少加 `audio_to_text_delta_fail`、`false_refusal_rate`、`yes_bias_rate`、`unsafe_action_after_mishear`。
- 先做 normalized transcript → C6 复跑，再做 audio → ASR → normalized transcript → C6 复跑，借 VoiceBench 的 cascaded/text/audio 分层。
- 车内噪声、重叠说话、远近场、方言/口音可从 HalluAudio/WearVox 方法借小型手工集，不直接采通用数据。

### C5/C6 leakage hygiene

- C6 `must_pass` 全部写 `must_not_train=true`，C5 训练 receipt 必须报 `must_not_train_violations=0`。
- 数据集分层建议：`train/dev/eval/must_pass/quarantine`，其中 `must_pass` 永不训练，`quarantine` 不 drop，保留来源和原因。
- 对从 C1/C2 派生的模板样本，记录 `source_family` 和 `source_ref`，避免同一模板变体同时进 train 和 eval。

## 冲突与不确定性

- `HomeBench` 领域最贴，但 repo 不活跃；只能作为论文/方法参考，不能满足“近 3 个月仍活跃”条件。
- `WearVox` 活跃性满足，但本轮 clone 未完成，机制细节需要二次读取后再进入正式 adopt。
- `IoTAgentBench`、`SmartGridBench` 都很新，可能是课程/个人项目；价值在 schema 和 failure taxonomy，不在 leaderboard 数值。
- `MikeVeerman/tool-calling-benchmark` 的 Qwen3-1.7B 结论对 MAformac 有启发，但 prompt 数太少，不能替代项目自建 bench。
- 很多 tool/no-tool 经典源（When2Call、ToolBH、ToolSandbox）不满足近期 pushed；若要严格按“近 3 个月活跃 repo”，只能列入 stale method pool。

## 下一轮建议

1. 深挖 `WearVox`：确认数据 schema、噪声/多通道/评测脚本是否能转成 C7 子集。
2. 深挖 `agent-safety-bench-zh`：确认中文危险工具调用、提示注入、机器评分 schema，判断能否补 C6 no-call/forbidden-action。
3. 对 `SimuHome` 做一次代码级 teardown：只抽 `state tick / schedule workflow / eval resume` 机制，不碰 license 受限代码复用。
4. 对 MAformac C6 增加“多 run 稳定性报告”：每 case 输出 pass rate、wrong tool histogram、no-call false positive count，而不是只输出 pass/fail。
