# MAformac eval 体系鸟瞰与近期 eval repo oracle 归档

日期：2026-06-20  
任务口径：回答“纵观全局，我们的 eval 体系是什么样的”，并把近期三个月活跃 eval repo 的 oracle 搜索结果归档为后续 C6/C5/C4/C7 设计输入。  
本文件是综合归档；两个源发现包见：

- `docs/research/2026-06-20-eval-agent-toolcall-premortem-oracle.md`
- `docs/research/2026-06-20-eval-oracle-blindspots-repo-scan.md`

## 本项目内一手依据

- `CLAUDE.md:30-39`：新路线以 C1/C2 契约 SSOT 为根，C3 执行闭环，C4/C5 语义和 LoRA，C6/C7 作为 bench 与 voice 层。
- `CLAUDE.md:66-80`：Qwen3-1.7B + LoRA 主线、文本先行、mock state/readback、规则 80% / LLM 20%、D35 全集覆盖率双轴 bench。
- `openspec/changes/define-vehicle-tool-bench/specs/vehicle-tool-bench/spec.md:3-126`：C6 是 Mac 开发期文本/transcript bench；四类确定性硬门、judge 边界、replay 指纹、base 先行、must_not_train、覆盖率 + scenario score 双轴。
- `docs/优化待讨论-吸收内化措施38项-2026-06-20.md:49-60`：Mastra eval 形态吸收：TrajectoryExpectation、dataset+pMap、ScoreAccumulator、failure_class、四阶段 scorer、judge 只评主观文本。
- `docs/优化待讨论-吸收内化措施38项-2026-06-20.md:91-97`：#39 Qwen tool-call 格式单一源；#40 replay 可复现。
- `docs/优化待讨论-吸收内化措施38项-2026-06-20.md:123-128`：Q1-Q6 grill 拍板：trace 分层、judge 边界、四硬门、eval_run 指纹、C5 receipt。
- `docs/research/INDEX.md:10-16`：C3-C7 每个 change 解冻前必须显式引用对应 teardown/adopt 指令。

## 总体结论

MAformac 的 eval 不是一个 C6 脚本，而是一条分层闭环：

```text
C1/C2 契约闭合
  -> C3 执行链路确定性测试
  -> C6 vehicle-tool-bench 双轴硬门
  -> C5 base/LoRA diff 与泄漏门
  -> C4 路由/轨迹/澄清评测
  -> C7 语音分层评测
  -> 人工 S-PASS / V-PASS 演示验收
```

其中 C6 是中枢门：它不替代 C4/C5/C7，但它先把“文本/normalized transcript 到 ToolCall、mock state、readback、clarify/refusal”的可复现硬门立住。没有 C6，C5 LoRA 只能说“感觉变好”；有 C6，才能把提升、退步、过拟合、泄漏、格式漂移、no-call 误触发拆开。

## Eval 分层

| 层 | 评什么 | 核心信号 | 当前状态 / 责任 |
|---|---|---|---|
| C1/C2 contract gate | 全集语义、场景端态、range、source_refs、redaction | source_refs 悬空、unclassified、range、risk-policy、state-cells readback | 已 archive，后续只读派生 |
| C3 runtime gate | ToolCallFrame decode -> DemoGuard -> mock execute -> readback -> trace | parser_status、guard_reason、state_delta、readback、五段 trace | 已 apply done，C6 消费其执行链路 |
| C6 vehicle-tool-bench | 文本/transcript 到工具调用和状态读回 | ToolCall set、expect_no_call、state_delta+readback、clarify correctness、IrrelAcc、coverage、scenario score | 第二刀 apply 中；base Qwen3-1.7B 真实跑是硬完成条件 |
| C5 LoRA eval | base vs LoRA 的真实增益和数据卫生 | same harness diff、must_not_train=0、parent_overlap=0、format pass、bucket_counts、variance | 第三刀；必须在 C6 base 之后 |
| C4 route eval | L1 规则快路 / 慢路 Qwen+LoRA / clarify / fallback 的路径正确性 | route_kind、candidate source、expected path、extra/missing/redundant tool call、latency | C6 后解冻；不把 C6 当路由全评 |
| C7 voice eval | audio -> ASR -> normalized transcript -> C6 的分层损耗 | WER/RTF、confidence、hotword/fuzzy、audio_to_text_delta_fail、unsafe after mishear、barge-in | C6 不依赖 ASR；C7 单独立 |
| Human demo gate | TTS 听感、视觉惊艳、现场稳定 | S-PASS、V-PASS、演示脚本 must-pass、人工听感 | 不进 C6 judge；单独验收 |

## C6 的硬边界

- C6 输入是中文文本或 normalized transcript，不评 ASR；ASR 属 C7。
- C6 四硬门由确定性逻辑决定：ToolCall 集合、no-call、state_delta+readback、clarify/refusal 正确性。
- judge 只在硬门全过后评 clarify/refusal 文本主观项，不洗白硬失败；TTS 归人工。
- `no-call/无关样本占比 >=20%` 是 eval 集组成门，不是 IrrelAcc 准确率门。
- base Qwen3-1.7B 无 LoRA 先跑；LoRA 后续必须同 harness、同 dataset、同 parser、同 mock state 做 diff。
- `qwen_tool_call_format_version` 取 `contracts/qwen-tool-call-format.yaml` 的内容 hash，防 C3/C5/C6 格式漂移。
- must-pass 子集标 `must_not_train`，给 C5 泄漏门使用。

## 近期活跃 repo 的吸收点

活动快照由 `gh repo view --json nameWithOwner,pushedAt,updatedAt,stargazerCount,description,url` 于 2026-06-20 本机查询。`updatedAt` 可能由 issue/star/metadata 触发，弱于 `pushedAt`。

| Repo | 活跃证据 | 对 MAformac 的吸收 |
|---|---:|---|
| `sierra-research/tau2-bench` | `pushed=2026-06-11` | 状态化 tool-agent-user、voice full-duplex、task quality fixes；C6/C7 要保留任务修正和语音分层 |
| `microsoft/STATE-Bench` | `pushed=2026-06-17` | 每 task 多 run、sandbox DB、最终状态、pass@1/pass^5；C6 base 每 case 多次跑和状态读回是对的 |
| `ShishirPatil/gorilla` / BFCL V4 | `pushed=2026-04-13`，页面 `Last Updated 2026-04-12` | 可执行 function calling、multi-turn、format sensitivity；不能只看 JSON 长得对 |
| `NVIDIA/When2Call` | repo push 不新，但方法关键 | 单独评 when to call / ask follow-up / cannot answer；C6 no-call 和 clarify 必须一等公民 |
| `apple/ToolSandbox` | push 不新，方法关键 | stateful execution、implicit state dependency、milestone/minefield；C6 要测状态依赖而非静态 API |
| `langchain-ai/agentevals` | `pushed=2026-06-17` | 轨迹 strict/unordered/subset/superset；C4/C6 要评路径，不只最终态 |
| `UKGovernmentBEIS/inspect_ai` | `pushed=2026-06-19` | task / solver / scorer 形态；C6 每 case 要有 scorer 和 trace receipt |
| `UKGovernmentBEIS/inspect_evals` | `pushed=2026-06-19` | AgentHarm/AgentThreatBench；risk-policy、工具输出污染、越界请求要进 must-fail |
| `promptfoo/promptfoo` | `pushed=2026-06-20` | regression + redteam + CI 形态；C6 可以用矩阵报告和红队回归思路，但不引入其 runtime |
| `confident-ai/deepeval` | `pushed=2026-06-18` | pytest-like LLM eval；只适合主观文本和回归形态，不可洗白硬门 |
| `xlang-ai/OSWorld` | `pushed=2026-06-10` | 环境/凭证/代理/初始化失败要单独归类；C6 base 真跑要记录环境 receipt |
| `ServiceNow/BrowserGym` | `pushed=2026-03-17`，略早 | reset/action log/reward/terminated/truncated 分离；C6 runner 也要区分 infra failure 和 model failure |
| `holi-lab/SimuHome` | `pushed=2026-04-08` | 智能家居状态随时间演化；C6 后续可加延迟生效/时间推进 case |
| `acon96/home-llm` | `pushed=2026-06-11` | 本地小模型 + 智能家居；已拆出 C3/C5/C6 关键模式，仍是 MAformac 最贴近肩膀之一 |
| `MatthewCYM/VoiceBench` | `pushed=2026-06-11` | 语音 assistant 分层；C7 要比较 audio vs transcript delta |
| `Feiyuzhao25/halluaudio` | `pushed=2026-06-16` | 音频幻觉、yes bias、false refusal；C7 不能只看 WER |
| `MikeVeerman/tool-calling-benchmark` | `pushed=2026-04-01` | 本地小模型多 run 稳定性；C6 要报 variance / reliability，不只单 seed |
| `reinhardjurk/agent-tester` | `pushed=2026-05-20` | 车载 voice assistant case/profile/required/forbidden tool 形态；可借 schema，不借权威数值 |
| `dengky23/nlu-pipeline-vehicle` | `pushed=2026-06-02` | 中文车载 NLU、slot normalization、confidence；C4/C5 可借样本类型 |

## Pre-mortem 三分类

### Tigers

1. **只测 ToolCall AST，漏状态和读回。** 防护：C6 state_delta + readback 硬门，mock state 读回为最终验收。
2. **no-call / clarify 被当边角 case。** 防护：负样本占比、IrrelAcc、expect_no_call、clarify_tag 都是一等字段。
3. **base 没真跑，LoRA 提升不可解释。** 防护：base Qwen3-1.7B 无 LoRA 先跑，记录 model/adapter/checkpoint/prompt/seed/digest。
4. **C5 训练污染 C6 must-pass。** 防护：must_not_train、split whitelist、parent_overlap=0、verification_receipt。
5. **judge 洗白硬失败。** 防护：judge 只评主观文本，硬门失败不可改判。
6. **ASR 噪声混进 C6 结论。** 防护：C6 文本/transcript，C7 单独做 audio delta。
7. **运行环境假绿。** 防护：Metal、模型文件、`mlx-swift-lm`、tool-call format、stdout tail、summary path 都写进 receipt。
8. **repair/fallback 掩盖模型不稳。** 防护：parser_status、repair_used、fallbackCandidate.count、wrong tool histogram 单独报。

### Paper-tigers

1. **必须引入外部 eval 框架。** 不成立。MAformac 需要吸收 task/scorer/trace 形态，本地 Swift/CLI harness 足够，外部框架零进 iOS。
2. **C6 必须等 C5 才有意义。** 不成立。C6 base 是 C5 是否有效的前置判据。
3. **C6 必须接 ASR 才算端到端。** 不成立。C6 是开发期文本/transcript bench；C7 才负责 audio。

### Elephants

1. **dataset 作者纪律比 runner 代码更难。** source_refs、负样本、must-pass、heldout、quarantine、leakage 都要可审。
2. **客户现场“不丢脸”不等于自动化指标全覆盖。** TTS、视觉、演示节奏、冷启动仍要人工 S-PASS/V-PASS。
3. **eval 不是一次性资产。** 每个 C5 checkpoint、C4 route 改动、C7 ASR 更新都要复跑同一套 fingerprinted harness。

## 对后续 change 的落点

- C6 apply：保当前 11 Requirement，不降级；可吸收 `run_repetitions`、failure receipt、wrong-tool histogram、infra/model failure split。
- C5 propose/apply：训练 receipt 必须记录 split whitelist、format contract version、must_not_train、parent overlap、bucket counts。
- C4 propose：把 route_kind / candidate_source / clarify_tag / expected path 作为 golden fixtures；C6 只测终态不够。
- C7 propose：按 audio -> normalized transcript -> C6 的分层，单独记录 ASR 置信、误听后危险动作、barge-in、RTF/latency。
- 长任务规范：每次 eval closeout 必须带 stdout、summary path、git status、环境 receipt、失败 taxonomy。

## Open Questions

1. C6 `run_repetitions` 是否只对 base/边界 case 设 5 次，还是全量 5 次；现 C6 apply dispatch 已拍 base 每 case 5 次均值方差。
2. SimuHome/IoTAgentBench 的状态演化字段是否进入 C6 v1，还是留 C6.1；建议 C6 v1 先不扩，避免第二刀过宽。
3. C7 的 voice full-duplex/barge-in 是否复用 tau2-bench 思路建小型 mock，还是先做 push-to-talk 音频回放；建议后者先行。
4. 红队/安全 eval 是 C6 内置 negative bucket，还是未来单独 risk bench；建议 C6 v1 先覆盖 risk-policy must-fail，复杂 agent security 留后续。

