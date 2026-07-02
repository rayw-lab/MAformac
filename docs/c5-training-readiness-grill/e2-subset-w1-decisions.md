---
type: e2_subset_grill_worker_decisions
worker: W1-loading-strategy
id_range: S-001~060
scope: D1 device-group 粒度 + D2 top-2 跨族 + D6 multi-intent 装载
status: PROPOSED_WITH_BUDGET_GATES
date: 2026-07-02
proof_class: local tokenizer + local sqlite readonly stats + local code teardown + web references
non_claims: no training, no generated data, no C6 acceptance, no runtime implementation, no cloud LLM
---

# E-2 subset W1 decisions

## Verdict

W1 verdict: `PROPOSED_WITH_BUDGET_GATES`。

- D1 推荐“两级粒度”：单候选 slow path 可用 seat 功能组；D2 top-2 / cross-family 必须退回精确 `_sg` micro-group + 静态 pair budget。原因是一手 tokenizer 显示粗功能组会爆 8K，而精确 `_sg` 两两组合当前全部低于 8K。
- D2 推荐 top-2 来源先走确定性 NLU/clarifyTag/本地检索 spike，不把 cloud embedding 放进 runtime；top-2 挂载必须由同一 manifest 同源驱动 train / C6 / runtime / grammar / audit。
- D6 推荐“连续两句分句装载”：每句独立 top-k 和 digest；C5 不训练单句 multi-intent。单句跨族歧义归 D2 top-2/clarify，不归 D6 混挂。

硬边界：本文件只给 W1 决策，不生成训练数据、不跑训练、不宣称 E-lite/C6/V-PASS。

## Evidence Ledger

| 类别 | 一手证据 | W1 使用方式 |
| --- | --- | --- |
| 项目 authority | `e2-subset-grill-README.md` frontmatter / D1 / D2 / D6 / matrix 要求；`CLAUDE.md`; `docs/CURRENT.md`; `docs/README.md` | 锁定 R7 construction-only、三层路由、gate3 同源、W1 ID 范围和输出格式 |
| P1-P9 | `docs/c5-recovery-2026-06-22/8d-rootcause.md` | 每个决策行的防惨败约束 |
| L4 实测 | `L4-e2-subset-materials.md` | 继承 562 tools、seat=126、seat family 全量 35,698 token、full compact=126,275 token |
| tokenizer | `HF_HUB_OFFLINE=1 python3.13` + 本机 `mlx-community/Qwen3-1.7B-4bit` cache | 重新计算 seat `_sg` / 候选组 / cross-family top-2 pair tokens |
| bug DB | `~/.bug-skill/data.db` readonly sqlite | 只输出 device co-occurrence 统计，不输出原文 |
| TinyAgent ToolRAG | 本地 clone `Tools/paper-to-skill-gate/paper-repos/TinyAgent` | 拆检索式 tool subset 的可借鉴点和不可直接吸收点 |
| web | 10 条外部源，含 URL + 日期 | 支撑 tool retrieval / function calling / edge embedding 先例，不替代本地 gate |

## D1 Catalog Teardown

### Tokenizer method

本轮使用同 L4 口径重算：

```bash
HF_HUB_OFFLINE=1 python3.13 - <<'PY'
from transformers import AutoTokenizer
tok = AutoTokenizer.from_pretrained("mlx-community/Qwen3-1.7B-4bit", local_files_only=True)
# compact json: sort_keys=True, separators=(",", ":")
# token count: tok.encode(text, add_special_tokens=False)
PY
```

Catalog SHA-256: `22613d496198940bf774ddcaa921c1efa2d92038b85afe18e1c5081e0e9ce012`  
Seat family: `126 tools / 35,698 tool tokens`。System prompt overhead: `29 tokens`。

### Seat `_sg` distribution

| `_sg` | tools | tokens |
| --- | ---: | ---: |
| seat_massage_force | 8 | 3,887 |
| seat_massage_time | 7 | 3,322 |
| seat_ventilation_windspeed | 8 | 2,272 |
| seat_heat_temperature | 8 | 2,136 |
| seat_rhythm_mode | 8 | 1,965 |
| seat_belt_heat_temperature | 8 | 1,790 |
| seat_mode | 5 | 1,564 |
| seat_leg_support | 6 | 1,501 |
| seat_massage_mode | 3 | 1,147 |
| seat_lumbar_support | 4 | 1,090 |
| seat_shoulder_support | 4 | 1,081 |
| seat_feet_support | 4 | 1,076 |
| seat_cushion | 4 | 1,057 |
| seat_position | 4 | 1,057 |
| seat_backrest | 4 | 1,037 |
| headrest_ear_slice_direction | 3 | 826 |
| headrest_direction | 3 | 796 |
| seat_ventilation_mode | 3 | 752 |
| seat_heat_mode | 3 | 724 |
| seat_adjustment_set_interface | 2 | 529 |
| seat_flank | 2 | 474 |
| seat_ventilation | 2 | 471 |
| seat_belt_vibration_alert | 2 | 469 |
| headrest_audio_system_mode | 2 | 460 |
| seat_heat | 2 | 459 |
| seat_folding_lock | 2 | 447 |
| seat_belt_comfort_adjuster | 2 | 441 |
| headrest_directional_broadcast | 2 | 437 |
| headrest_audio_system | 2 | 431 |
| seat_massage | 2 | 425 |
| seat_belt_heat | 2 | 423 |
| headrest_direction_ear_slice_adjust | 1 | 271 |
| headrest_direction_adjust | 1 | 262 |
| seat_position_adjustment | 1 | 254 |
| seat_memory | 1 | 241 |
| seat_memory_bind | 1 | 229 |

Primitive / value-type signal：`adjust_to_number=36`, `by_percent=23`, `set_mode=18`, `increase_by_exp=16`; value types top 为 `SPOT=31`, `EXP=30`, `PERCENT=26`。这说明 seat 内部不是单一设备族，粒度必须跟 `_sg/_ir` 绑定。

### Candidate grouping

Reject 粗功能组：

| 候选组 | tools | tokens | verdict |
| --- | ---: | ---: | --- |
| thermal_heat | 23 | 5,520 | 单组可行 |
| ventilation | 13 | 3,489 | 单组可行 |
| massage_rhythm | 28 | 10,734 | reject: 单组 >8K |
| posture_adjust | 40 | 10,357 | reject: 单组 >8K |
| mode_memory_misc | 22 | 5,610 | 单组可行 |

推荐 D1 单候选组：

| 推荐组 | tools | tokens | verdict |
| --- | ---: | ---: | --- |
| seat_massage_force_time | 15 | 7,206 | pass, 但 top-2 不可直接用 |
| seat_posture_back_head | 26 | 6,664 | pass, 但 top-2 不可直接用 |
| seat_heat | 23 | 5,520 | pass |
| seat_posture_base_leg | 21 | 5,404 | pass |
| seat_mode_memory_safety | 15 | 3,902 | pass |
| seat_massage_mode_rhythm | 13 | 3,531 | pass |
| seat_ventilation | 13 | 3,489 | pass |

Top-2 反例：推荐功能组若直接跨族两两挂载，会爆 8K。例：`seat_massage_force_time + volume/volume = 11,220 tokens with system`；`seat_posture_back_head + volume/volume = 10,678 tokens with system`。

因此 D2 top-2 必须使用精确 `_sg` micro-group。全 catalog `191` 个 `_sg` 中没有单 `_sg` 超 8K；精确 `_sg` cross-family pair 当前 `15,867/15,867` 全部 <=8K with system。最坏 pair：

| pair | tokens with system |
| --- | ---: |
| seat_massage_force + volume/volume | 7,901 |
| seat_massage_time + volume/volume | 7,336 |
| light/atmosphere_lamp_brightness + volume/volume | 7,096 |
| light/atmosphere_lamp_brightness + seat_massage_force | 6,995 |

注意：`7,901` 只剩约 `291` tokens 到 8K，不含 DialogueState、user utterance、output schema、grammar、safety hints。W2/W3 必须定义 `top2_tool_token_budget` 和非 tool prompt overhead；否则不能把“<=8K with system”升格成 runtime 可装载。

## D1 Bug DB Co-occurrence

只读 DB: `~/.bug-skill/data.db`。本轮不输出任何原文。

重要 caveat：grill README 提到 bug 库 1730 条，但当前 live DB `bugs` 表为 `0`。可用信号来自 `e3_comments_events` / `analyses` / `ki_chunks` / `baseline_document_cells` 等表，只能作 tie-breaker，不能作 SSOT。

| source table | rows scanned | device-hit rows | top co-occurrence |
| --- | ---: | ---: | --- |
| e3_comments_events | 13,791 | 1,101 | `ac+seat=85`, `seat+window=55`, `ac+window=32`, `seat+volume=28` |
| analyses | 5,324 | 2,096 | `seat+volume=211`, `ac+seat=148`, `screen+volume=115`, `ac+volume=113`, `seat+window=97` |
| ki_chunks | 703 | 85 | `ac+seat=25`, `seat+window=13`, `ac+window=11`, `seat+volume=11` |
| baseline_document_cells | 10,801 | 317 | `ac+seat=10`, `seat+window=10`, `ac+window=7`, `light+seat=7`, `light+sunroof=7` |

Interpretation：历史同句共现支持 D2 必须能处理 `seat+ac`、`seat+volume`、`seat+window` 等跨族 top-2；但它不支持把这些永久合并成一个训练/prompt group。

## TinyAgent ToolRAG Teardown

本地路径：`Tools/paper-to-skill-gate/paper-repos/TinyAgent`。

| file:line | 代码事实 | W1 implication |
| --- | --- | --- |
| `src/tiny_agent/tool_rag/base_tool_rag.py:31` | `BaseToolRAG` 接收 embedding model、available tools、embedding path | ToolRAG 是“查询时检索 subset”，不是训练集改写 |
| `src/tiny_agent/tool_rag/base_tool_rag.py:46` | 默认从 `text-embedding-3-small` embedding pickle 读 examples | 原实现默认依赖预生成 embedding；MAformac runtime 不可直接照搬云 embedding |
| `src/tiny_agent/tool_rag/base_tool_rag.py:77` | `get_top_k_similar_examples` 用 cosine top-k | 可借鉴为本地离线 top-k spike |
| `src/tiny_agent/tool_rag/base_tool_rag.py:105` | 过滤 examples，确保 example tools 都在 available tools | 对应 W1 “gold tool must be mounted” 的 hard gate |
| `src/tiny_agent/tool_rag/simple_tool_rag.py:25` | `SimpleToolRAG.retrieve_tools_from_query` 从 top examples 收集 tool names | 可作为 lexical/embedding retrieval 对照组，不可替代 SSOT group |
| `src/tiny_agent/tool_rag/classifier_tool_rag.py:19` | classifier model 为 `squeeze-ai-lab/TinyAgent-ToolRAG`，threshold `0.5` | 分类器可做 spike，不可直接进 R7 runtime |
| `src/tiny_agent/tool_rag/classifier_tool_rag.py:69` | 先分类 tools，再按 retrieved tools 过滤 embedding | 支持 W1 “先缩 tool pool 再构造 prompt” |
| `src/tiny_agent/tiny_agent.py:129` | 每次 query 检索 examples/tools，再 rebuild prompt with `new_tools` | 对应 D2 manifest runtime 同源挂载点 |
| `src/tiny_agent/model_utils.py:83` | embedding 支持 OpenAI/Azure/local endpoint/SentenceTransformer | MAformac 可只保留 local SentenceTransformer/BM25 spike 路线 |
| `src/tiny_agent/models.py:83` | Mac tools enum 仅 16 个 | TinyAgent 规模远小于 562 D-domain；不能直接外推 C6 pass |

项目已有吸收 ledger 也把 ToolRAG 定位为 optional offline spike：先检索小 D-domain subset，必须记录 `gold miss` / `dangerous distractor`，在 carrier 设计前不得改 runtime / prompt / C5 / C6。

## Web References

| # | Source date | URL | W1 use |
| ---: | --- | --- | --- |
| 1 | 2024-09-01 submitted; 2024-10-25 revised | https://arxiv.org/abs/2409.00608 | TinyAgent: edge assistant uses tool retrieval to reduce prompt length |
| 2 | 2026-04-12 updated | https://gorilla.cs.berkeley.edu/leaderboard.html | BFCL: function-calling benchmark separates native FC vs prompt, tracks cost/latency/format sensitivity |
| 3 | 2026-05-28 updated | https://developers.google.com/edge/mediapipe/solutions/genai/function_calling/android | Google AI Edge: on-device FC formatter/parser/constrained decoding |
| 4 | 2026-04-16 updated | https://ai.google.dev/gemma/docs/functiongemma/model_card | FunctionGemma: lightweight FC model for constrained-resource deployment |
| 5 | 2024-10-04 submitted; 2025-03-29 revised | https://arxiv.org/abs/2410.03439 | ToolGen: treats tools as special tokens; shows large-pool tool calling pressure |
| 6 | 2024-04 arXiv id; captured 2026-07-02 | https://arxiv.org/html/2404.00450v1 | Planning/retrieving/editing tool retrieval: one-shot retrieval is insufficient |
| 7 | 2025-08-01 | https://aclanthology.org/2025.knowllm-1.7.pdf | ToolReAGt: >2,000 tools need retrieval; all-tool prompt is bounded by context |
| 8 | 2026-02 arXiv id; captured 2026-07-02 | https://arxiv.org/html/2602.00933v1 | MCP-Atlas: real MCP tool selection with distractors and multi-call tasks |
| 9 | 2024-10 arXiv id; captured 2026-07-02 | https://arxiv.org/html/2410.04587v1 | Hammer: on-device FC, function masking/irrelevance data, must decline unsuitable functions |
| 10 | captured 2026-07-02 | https://huggingface.co/squeeze-ai-lab/TinyAgent-ToolRAG | TinyAgent ToolRAG classifier card and edge/private positioning |

## Decision Matrix

| ID | 议题 | 选项 | ⭐推荐 | 依据 | status | 防惨败列 |
| --- | --- | --- | --- | --- | --- | --- |
| S-001 | D1.1 seat group 基础粒度 | A 全部精确 `_sg`; B 粗功能组; C 单候选功能组 + top-2 `_sg` micro-group | C | 粗 `massage_rhythm=10,734` / `posture_adjust=10,357` 爆 8K；精确 `_sg` pair 全过 8K，但最坏 7,901 | proposed | P1/P6/P8：同一 ToolContract/训练/C6/runtime，禁止各层自造粒度 |
| S-002 | D1.1 seat 单候选推荐组 | 7 组：heat / ventilation / massage_force_time / massage_mode_rhythm / posture_back_head / posture_base_leg / mode_memory_safety | 接受，限单候选 slow path | 7 组均 <=7,206 tokens；比全 seat 35,698 可控 | proposed | P7/P9：先 token 实测再定 scorer；不能靠直觉分组 |
| S-003 | D1.1 粗功能组 | 允许 `massage_rhythm` / `posture_adjust` 合组，或继续切分 | reject 粗组 | 两组单组已 >8K，top-2 更不可能稳态 | decided-for-W1 | P7/P8：真实数据重算；训练/eval/runtime 同一问题框架 |
| S-004 | D1.2 group SSOT | A 手写 group 表; B 从 `generated/D_domain.tools.demo.json` 的 `_domain/_sg/_ir` codegen manifest | B | `ToolContractCompiler` 读取 generated catalog；`gen_tool_contract.py` 已产 `_ir.device/_domain/_sg` | proposed | P1/P2/P6：单一 compiler，物理删不该出现的 tools，训练==C6==runtime |
| S-005 | D1.3 too fine vs too coarse 判据 | A 只看单组 token; B 加 max pair token + miss risk + co-occurrence | B | 单组 pass 不能推出 top-2 pass；功能组 pair 已爆 10K+ | proposed | P3/P7/P9：label conflict hard gate；用真实 score 判断 |
| S-006 | D1.4 bug DB co-occurrence | A 当 group authority; B 只当 tie-breaker/telemetry | B | live `bugs` 表 0；其它表显示 `seat+ac/volume/window` 高频但不是 SSOT | proposed | P7/P8 + raw 边界：只用统计，不把原文带入产出 |
| S-007 | D2.1 top-2 来源 | A 云 embedding; B deterministic NLU/clarifyTag; C 本地 lexical/embedding spike | B 为主，C 可 spike；A 禁 runtime | R7 no cloud；TinyAgent 证明 retrieval 可行但默认 embedding 不适配端侧 | proposed | P1/P8：retrieval 只能服务同源 manifest，不另立 prompt/tools |
| S-008 | D2.2 top-2 budget | A 推荐功能组 pair; B 精确 `_sg` pair + static budget fail-closed | B | 精确 `_sg` pair 最坏 7,901 with system；功能组 pair 最坏 11,220 | proposed | P5/P6/P7：NO_TOOL/empty collapse 防线；训练/C6/runtime 同预算 |
| S-009 | D2.3 train 同源 | A 训练 prompt 自己选 distractors; B manifest 决定 target + optional second-family distractors + digest | B | C5 `sameFamilyDistractors` 已按 `_sg/_domain` 逐级选 distractors；TinyAgent 也要求 retrieved tools 覆盖 gold | proposed | P1/P2/P3/P6：gold tool missing 必须 hard fail |
| S-010 | D2.4 wrong-family recovery | A runtime 静默裁剪; B 记录 `routing_miss`，一次 retry/clarify，禁止假绿 | B | Hammer/BFCL 都显示 irrelevant/wrong function 是核心风险；项目 P5 禁混淆 NO_TOOL | proposed | P5/P7/P9：错误要可观测，scorer 不能把错族当成功 |
| S-011 | D6 multi-intent 装载 | A 单句 multi-intent 训练; B 连续两句分句独立装载; C 单句跨族走 D2 top-2/clarify | B + C | E-024 已锁 C5 前不训练 one-sentence multi-intent；D6 README 要 splitter per sentence 和 per-step digest | proposed | P6/P8/P9：连续任务只验装载链路，不偷换为 C5 多意图训练 |

## Handoff To W2/W3

- W2 必须给出 `top2_tool_token_budget`，不能只说 “8K 内”。当前最坏 `_sg` pair `7,901` with system，留给 state/user/schema/grammar 的余量过低。
- W3 manifest 至少需要：`utterance_id`, `step_id`, `selected_group_ids`, `tool_names_digest`, `tool_prompt_digest`, `grammar_digest`, `expected_tool`, `routing_source`, `budget_result`。
- Gate3 同源门建议 hard assert：`train target tool names ⊆ train prompt tools ≡ C6 expected ≡ runtime prompt tools ≡ grammar allowed ≡ model actual 审计集`。任何一轴缺 digest，只能 `PARTIAL/BLOCKED`。
