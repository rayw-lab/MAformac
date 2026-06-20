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
| `2026-06-20-pi-teardown-collaboration-layer.md` | Pi 协作层拆解：append-only handoff、七段 compaction、工具前后 hook、headless 状态行；只进长任务规范 | **长任务 handoff / 派单 / 子审计规范** |
| `../优化待讨论-吸收内化措施38项-2026-06-20.md` | 38 项吸收措施 + Q1-Q6 grill 结论 + #39/#40 + 三刀落地顺序 | **C3-C7 任一 change 解冻前**，作为 adopt/backlog 总入口 |

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
