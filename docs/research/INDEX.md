# docs/research/ 索引 + 应用机制（防失忆体系）

> 答磊哥三问（2026-06-19）：① 拆解后的东西后续怎么应用 ② 需要索引吗 ③ 热词是数据库吗。
> 一句话：**不建 DB/重索引（solo 轻治理 = over-engineering）；靠 MEMORY 指针 + 本轻量 INDEX + 每个 C-change 的 design.md 显式引对应 teardown（findings→adopt 指令）三层落地。grep/sed 仅 ad-hoc。**

## 调研 / teardown 文档（一行一条 + 何时读 / 哪个 change 用）

| 文档 | 是什么 | 何时读（应用点） |
|---|---|---|
| `2026-06-19-architecture-validity-deepdive.md` | 6 流证据：1.7B 不镜像 8B，走反转架构（规则+窄域LoRA单跳FC+code编排+受限解码）；信心~92% | 起任何 C-change / 质疑架构 / 写 SRD 时 |
| `2026-06-19-home-llm-teardown.md` | home-llm **runtime 工程**：单发旋钮/三层防御解析/双向单位归一化/KV预热/三重白名单/GBNF | **C3 execution + C7 voice 实装**（DemoGuard/GBNF/单发） |
| `2026-06-19-home-llm-teardown-data.md` | home-llm **C5 LoRA 数据配方**：5类样本/模板随机参数/distractor/train_on_turn masking/配比 | **C5 LoRA 实装**（数据生成） |
| `2026-06-19-asr-alignment-research.md` | ASR 选型(sherpa+Paraformer>Whisper)+对齐(拼音fuzzy/LoRA音近)+**跨厂商二审修正(热词transducer-only/D14改)** | **C7 voice 实装** + D14 决策 |
| `2026-06-20-mastra-teardown-workflow-eval-trace.md` | Mastra workflow/eval/trace 形态拆解：冻结图、TrajectoryExpectation、scorer pipeline、span 树；只借形态，不进 runtime | **C4 路由 / C6 bench / C3-C6 trace** 解冻或写设计时 |
| `2026-06-20-maformac-eval-system-overview.md` | MAformac eval 体系鸟瞰 + 近三个月活跃 eval repo oracle 综合：C1/C2→C3→C6→C5→C4→C7→人工门，含 tiger/paper-tiger/elephant | **C6/C5/C4/C7 eval 设计总入口**；回答“我们的 eval 体系是什么样的”时先读 |
| `2026-06-20-eval-oracle-blindspots-repo-scan.md` | 第二 MAformac eval oracle 补盲：近期活跃 eval repo/benchmark 扫描，覆盖 SimuHome / IoTAgentBench / tau2 / VoiceBench / HalluAudio / HA voice / 本地小模型 / 中文车载 NLU | **C6 bench / C7 voice / C5 leakage hygiene** 定 schema、负样本、状态仿真、多 run 稳定性时 |
| `2026-06-20-pi-teardown-collaboration-layer.md` | Pi 协作层拆解：append-only handoff、七段 compaction、工具前后 hook、headless 状态行；只进长任务规范 | **长任务 handoff / 派单 / 子审计规范** |
| `2026-06-20-eval-agent-toolcall-premortem-oracle.md` | C6/C5/C4/C7 eval pre-mortem oracle：近三个月活跃 LLM/agent/tool-call/OS/voice/redteam eval repo 源发现 + failure modes | **C6 bench / C4 路由轨迹 / C5 LoRA 数据 / C7 voice eval** 设计前 |
| `2026-06-20-voice-short-context-memory-oracle.md` | 语音链路短时上下文记忆 oracle：15 个近三个月活跃 repo，覆盖 HA Assist/HassIL、LiveKit、Pipecat、OVOS/Wyoming、LangGraph、Semantic Kernel、Mem0、QwenPaw 等 | **C7 voice / C4 routing / C6 eval** 设计短时 session、指代继承、工具状态读回和上下文裁剪时 |
| `2026-06-20-voice-short-term-memory-oracle.md` | 语音链路短时记忆 pre-mortem 主报告：本仓 scout + repo oracle 归纳，定义 DialogueState / VoiceTurnContext、提交时机、TTL、打断、ASR 污染、状态读回等虎坑 | **C4 三层路由 / C7 voice / C6 bench** 写短时记忆合同、负样本和实现前 |
| `../优化待讨论-吸收内化措施38项-2026-06-20.md` | 38 项吸收措施 + Q1-Q6 grill 结论 + #39/#40 + 三刀落地顺序 | **C3-C7 任一 change 解冻前**，作为 adopt/backlog 总入口 |
| ⭐ `2026-06-20-eval-memory-deepdive-synthesis.md` | **14 repo teardown + Qwen 可行性的综合吸纳意见**：adopt_by_layer(C4/C5/C6/C7)+10 tiger+不降级二筛+synthesis_path；§6 综合官二审补强(C6 现状/陷阱样本/TTL两层) | **第二批吸纳全料**（C4-C7 解冻前读）；HIGH **已由 `roadmap §3`(H1-H7)收敛拍板**,本文作 dated synthesis 保留 |
| `2026-06-20-qwen3.5-2b-vs-1.7b-feasibility.md` | Qwen3.5-2B 升主力可行性：联网核实(确实存在/GDN+VLM/tool-parser坑)+条件升级判定+5 spike 死门(S1 mlx-swift parser 命门) | **大脑选型 / C5 训练前**；H1 **已拍=条件升级**(先 S1/S2 spike 再切,见 `roadmap §3/§4-P1`) |
| `2026-06-20-teardown-{14 repos}.md` | 14 个 eval/bench/voice/runtime repo 逐行深拆(tau2/agentevals/nano-eval/iot-agent/simuhome/hassil/ha-core/ovos/livekit/pipecat/hass-local-openai/ha-voiceagent/agent-tester/tool-calling-bench)；每篇带 file:line + adopt/adapt/drop | 对应 C-change 实装时按 synthesis §1 指引跳读具体篇 |

### P1-C 训练 + 选型（2026-06-20 ultracode 7 路深扒，每路≥10 联网搜证，按 7 lens 拆解）
| 文档 | 是什么 | 何时读 |
|---|---|---|
| ⭐ `2026-06-20-p1c-training-backend-deepdive.md` | **训练后端综合**：锁本机 mlx-lm(M5 over-provisioned/<15min/¥0)/omlx=推理GUI坐实/masking 三形态实为两类机制(C5 四flag)/Qwen3-1.7B 配方超参表/2B 降P2/11 tiger/15 轮 grill 弹药 | **P1-C 训练实装起手必读** |
| `2026-06-20-p1c-training-backend-finders-raw.md` | 上篇 **7 路 finder 原始调研**(mac-mlx/云GPU/skills/配方/2B架构/坑点/masking 逐路完整发现+source_url+clone) | 综合版漏的细节回这查 |
| ⭐ `2026-06-20-model-selection-2026-deepdive.md` | **选型综合**：**守 Qwen3-1.7B**(FC+拒识双证据最强/新≠强)+LFM2.5 唯一真新备胎(中文一票否决)+8GB 天花板≤2B+mlx-swift 最优栈+9 tiger | **选型决策事实源**；模型已定守 1.7B(不换 LFM2.5) |
| `2026-06-20-model-selection-2026-finders-raw.md` | 上篇 **7 路 finder 原始调研**(Qwen小dense/Gemma-Llama/Phi-Smol-国产/FC专家/部署框架/skills/iPhone8GB 逐路 39 候选+source+淘汰理由) | 候选细节/淘汰理由回这查 |
| `2026-06-20-p1-b-qwen35-2b-s1-s2-spike.md` | P1-B spike：Qwen3.5-2B S1 8/11 劣于 1.7B 9/11 + S2 无真机 blocked + artifact 实为 VL 多模态 | 选型实证锚点 |
| `2026-06-20-c3-home-llm-adopt-spike.md` | C3 home-llm adopt spike(执行契约层蓝本验证) | C3 实装参考 |

## §1 应用机制（怎么在未来 session 落地，不靠纯 grep）
1. **MEMORY.md 指针**（每 session 自动加载）→ 知道这些 doc 存在 + 一句话要点。
2. **本 INDEX.md**（一行一条 + 何时读）= 轻量索引（README 级，非 DB）。
3. **⭐ 核心：每个 C3-C7 change 的 `design.md` / dispatch "起手读" 显式引对应 teardown** → 把 findings 变成 change spec 里的 **adopt 指令**（teardown 已带 adopt/adapt/drop 表 = 现成桥）。例：C5 dispatch 写"按 teardown-data.md §6 配比 + §5 masking 造数据"；C7 写"按 asr-research 跨厂商修正块选 sherpa+ASRBackend"。
4. grep/sed 用于 ad-hoc 查具体行号/关键词。

## §2 存储原则（答"热词是小型数据库吗"——不是）
- **home-llm 全是 CSV/txt + 内存 dict**（`_piles_cache`），**零数据库**（pile_of_device_names.csv 等）。
- **ASR 热词（仅 sherpa transducer 模型）= `hotwords.txt` 文件 + Aho-Corasick 自动机**（加载时编译），非 DB；**Paraformer 路线根本不用热词**（用拼音 fuzzy）。
- **拼音 fuzzy 词典** = 启动时从封闭车控词表预计算的内存 dict（Apple `CFStringTransform` 生成），非 DB。
- **MAformac 原则**：`capabilities.yaml` = 单一源 → 派生 ASR 词表(transducer时)/拼音字典/LoRA 数据/DemoGuard 白名单（全是生成物，文件+内存）。**封闭词表数十-数百词 → 文件足够，DB 是 over-engineering**（违 fresheveryday 轻治理）。

## §3 home-llm teardown 完整性（拆完，11 文件逐行）
- **runtime 5**：conversation(控制环/单发旋钮) / utils(防御解析) / entity(prompt+提取+单位归一化) / llamacpp(GBNF挂载+KV预热) / const(白名单+qwen3配置)。
- **数据 5**：generate_data(5类样本组装) / prompting(prompt) / devices(设备抽象) / utils(pile类型+随机参数) / synthesize(LLM增广)。
- **tools.py**：工具 JSON schema 定义（TOOL_TURN_ON="HassTurnOn"... + HASS_TOOLS/SERVICE_TOOLS schema，name+description+parameters{enum/type}）= MAformac capabilities.yaml 的工具 schema 映射。
- **train/evaluate.py**：**C6 评测法** = ToolCall 集合**精确匹配(name+args)** + **空匹配(该不调=对/调了=错)=拒识正确性** + **color 容差**(域特定) + 失败分类(extra/missing/invalid/mismatch) + per-checkpoint 选最优防过拟合 + temp 0.1。
- **train.sh**：`scp config + kubectl create training-job.yml`（sed 替换 MODEL_NAME）= axolotl on k8s 训练编排。**LoRA**：evaluate.py 用 PeftModel/PeftConfig 加载（loras/ 目录）。
- **元洞察**：让小模型可靠 = 外围工程（防御解析/单位归一化/白名单/KV预热/单发）+ 结构化数据（5类样本/masking/配比/distractor）+ C6 严格评测（集合匹配+拒识空匹配），不是模型本身。README 看不到，拆到底才得。
