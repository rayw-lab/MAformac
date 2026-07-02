---
artifact_kind: e2_subset_grill_worker_2_budget_degrade_decisions
worker: W2-budget-downgrade
scope: D3 8K overlimit fallback + D4 scene macro fallback
id_range: S-101~160
status: proposed_first_round
created: 2026-07-02
proof_class: local_static + local_offline_tokenizer + local_catalog_scene_probe + web_research
non_claims: no_training_no_generation_no_cloud_llm_no_commit
---

# E-2 subset W2 预算降级官决策矩阵

W2 verdict: `PROPOSED_WITH_BUDGET_GATES`。

核心判断：8K 不是“工具 catalog ≤8192 就能跑”。真实慢路预算必须从同一个 tokenizer 实算：

```text
8192
- system prompt
- DialogueState 最近 3 轮
- user utterance
- generation headroom
= tool/schema/grammar 可见面配额
```

本轮一手实算结果：`system=29` tokens；3 轮 `DialogueState=101` tokens；样例用户输入 `我有点冷，屏幕也太暗了=9` tokens；若沿用 home-llm 默认 `max_tokens=512` 作为 generation headroom，则样例工具面真配额为 `7541` tokens。若按 W2 建议的工程保守口径 `user_reserve=64 + digest/trace reserve=128 + generation=512`，工具面 policy cap 应是 `7358` tokens；manifest build gate 建议再向下取整为 `7200`，避免 chat template、NO_TOOL outlet、grammar 包装和轻微状态膨胀吃穿预算。

## P1-P9 防惨败映射

| 代号 | 含义 |
|---|---|
| P1 | Tool surface 单源派生，训练/C6/runtime/grammar 不手写第二套 |
| P2 | Metadata 不是 enforce；需要物理删、物理挂、物理校验 |
| P3 | Label conflict 用实际 prompt/tools/label 检，不信 metadata |
| P4 | Qwen tool-call 渲染保持 name-first，不能被 schema/grammar 改形 |
| P5 | NO_TOOL 与 empty collapse 分开；no-call 不能靠空输出假绿 |
| P6 | Surface + scorer consistency 进机械门 |
| P7 | 审计必须一手复算/实跑，不信 receipt 聚合 |
| P8 | 重大训练/评测前先 grill frame，反例改变结论就改判 |
| P9 | 成功标准先定义，action/no-call/refusal/readback 分轴 |

来源：`docs/c5-recovery-2026-06-22/8d-rootcause.md:97-105`。

## Evidence Ledger

| 类别 | 一手证据 | W2 使用方式 |
|---|---|---|
| 当前边界 | `docs/CURRENT.md:17-32` | 当前为 pre-LoRA HOLD；禁止训练、生成、C6 acceptance、V/S/U-PASS 声称 |
| E-2 seed | `docs/e2-subset-design-package-2026-07-02.md:33-47` | E-lite、8K、降级链、scene macro 是同一 manifest 机制，Phase-1 construction only |
| L4 tokenizer | `L4-e2-subset-materials.md:75-92` | 全族 token 压力：seat/light/screen/ac/volume 不能直接 8K 装载 |
| L4 scene macro | `L4-e2-subset-materials.md:223-246` | scene subset 适合现场兜底，但必须同源 codegen，不手写第二 SSOT |
| C5 system | `Core/Training/C5LoRATraining.swift:2728-2733` | 训练样本实际 system message，离线 tokenizer 实算为 29 tokens |
| home-llm runtime | `docs/research/2026-06-19-home-llm-teardown.md:45-60`, `:81-82` | GBNF、KV 预热、静态前动态后、context 8192、max_tokens 512 |
| home-llm data | `docs/research/2026-06-19-home-llm-teardown-data.md:24-30`, `:48-58` | distractor 训练、只训正确输出、结构化负例，不靠 prompt 元数据 |
| C2 contract | `openspec/specs/scenario-state-protocol/spec.md:6-21`, `tool-execution/spec.md:137-160` | scene macro 只能引用 C2 mock state/readback，不拥有执行边界 |
| demo scenes | `contracts/demo-scenarios.yaml:13-20`, `:29-45`, `:48-156` | scene macro 挂点来自 demo scene/act + C1/C2；当前仍是 C6 seed/interim |
| local probe | `HF_HUB_OFFLINE=1 python3.13` + `generated/D_domain.tools.demo.json` + `contracts/demo-scenarios.yaml` | 实算 8K 拆账与 scene `_sg` union tokens |

## 本机 tokenizer 预算拆账

命令口径：

```bash
HF_HUB_OFFLINE=1 python3.13 - <<'PY'
from transformers import AutoTokenizer
tok = AutoTokenizer.from_pretrained("mlx-community/Qwen3-1.7B-4bit", local_files_only=True)
# token count = len(tok.encode(text, add_special_tokens=False))
PY
```

实算结果：

| 项 | tokens | 口径 |
|---|---:|---|
| context cap | 8192 | home-llm 8K / Qwen slow path target |
| system | 29 | `你是 MAformac 离线 mock 车控演示助手。控制路径只输出 tool_call 包裹或 NO_TOOL。` |
| DialogueState 3 轮 | 101 | `active_scene_id/active_zone/state_revision/recent_turns[3]/last_action` compact JSON |
| sample user | 9 | `我有点冷，屏幕也太暗了` |
| generation headroom | 512 | home-llm 默认 max_tokens 512 |
| exact tool budget | 7541 | `8192-29-101-9-512` |
| policy tool budget | 7486 | `8192-29-101-64(user reserve)-512` |
| policy + digest reserve | 7358 | `policy-128` |
| W2 recommended build gate | 7200 | 向下取整，给 chat template / NO_TOOL / trace / grammar 包装留余量 |

反例：W1 的最坏 `_sg` pair `7901 with system` 在“只看 system”时似乎过 8K，但加上 W2 最小真实 overhead 后必爆。故 top-2 或 scene macro 不能以 `tools+system<=8192` 为验收。

## Scene Macro 本机拆账

解析规则：从 `contracts/demo-scenarios.yaml` 的 `c1_ref` / `precondition_action` 映射到 `generated/D_domain.tools.demo.json`，先算精确 expected tool union，再算实际更接近挂载面的 `_sg` union。

| scene | 直接工具数 / tokens | `_sg` union | `_sg` tools / tokens | 加 system+3轮state+user+512 后总量 | verdict |
|---|---:|---|---:|---:|---|
| scene1 听得懂人话 | 4 / 1034 | `ac/ac`, `ac/ac_temperature`, `screen/screen_brightness` | 22 / 6049 | 6700 | pass |
| scene2 一句顶三句 | 5 / 1381 | `ac/ac_temperature`, `light/atmosphere_lamp_brightness`, `light/atmosphere_lamp_color` | 20 / 5893 | 6544 | pass, but has mapping risk |
| scene3 记得上文 | 4 / 896 | `window/window` | 8 / 1757 | 2408 | pass |
| scene4 没教过也会 | 1 / 204 | `window/window` | 8 / 1757 | 2408 | pass |
| scene5 关键时刻拦得住 | 3 / 702 | `door/car_door` | 3 / 702 | 1353 | pass |

重要风险：`scene2` 里 `c1_ref: {device: ac_temperature, primitive: power_on}`（`contracts/demo-scenarios.yaml:84-88`）在当前 catalog 无直接匹配；真正 `open_ac` 是 `device=ac, primitive=power_on`（`generated/D_domain.tools.demo.json:21390-21399`），而同文件 scene1 的 precondition 已写对（`contracts/demo-scenarios.yaml:65-66`）。这不能靠 W2 手写修；scene macro codegen 必须有 C1 bridge/fixup，或 manifest build 标 `missing_expected_in_mounted` fail-closed。

## Web References（抓取日 2026-07-02）

| ID | 来源 | URL | 日期 | W2 用途 |
|---|---|---|---|---|
| W2-WEB-01 | vLLM Automatic Prefix Caching docs | https://docs.vllm.ai/en/stable/design/prefix_caching/ | 抓取 2026-07-02 | KV block prefix cache 复用相同前缀；支撑“静态 manifest 前置，动态状态后置” |
| W2-WEB-02 | SGLang RadixAttention blog | https://www.lmsys.org/blog/2024-01-17-sglang/ | 2024-01-17 | RadixAttention 复用 common prefix KV cache；支撑 scene/group 切换会影响冷启动 |
| W2-WEB-03 | OpenAI Prompt Caching docs | https://developers.openai.com/api/docs/guides/prompt-caching | 抓取 2026-07-02 | 自动缓存 1024+ token 前缀；支撑大工具前缀稳定才有收益 |
| W2-WEB-04 | OpenAI API Prompt Caching announcement | https://openai.com/index/api-prompt-caching/ | 2024-10-01 | 最长已计算 prefix 按 128-token 增量缓存；支撑“前缀变化导致收益丢失” |
| W2-WEB-05 | Anthropic Prompt Caching docs | https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching | 抓取 2026-07-02 | cache prefix 覆盖 tools → system → messages；说明 tools 变化会影响缓存层级 |
| W2-WEB-06 | Anthropic tool-use docs | https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use | 抓取 2026-07-02 | tool_choice 改变会 invalidate cached message blocks；支撑 runtime 不应频繁动态改挂载策略 |
| W2-WEB-07 | Google Gemini context caching docs | https://ai.google.dev/gemini-api/docs/caching | 抓取 2026-07-02 | implicit/explicit context caching 有最小 token 门槛；支撑长工具前缀缓存但非免费 |
| W2-WEB-08 | TensorRT-LLM KV cache reuse docs | https://nvidia.github.io/TensorRT-LLM/advanced/kv-cache-reuse.html | 抓取 2026-07-02 | 相同 prompt 起始可复用 KV pages 降低 first token latency |
| W2-WEB-09 | Hugging Face KV cache docs | https://huggingface.co/docs/transformers/en/cache_explanation | 抓取 2026-07-02 | KV cache 是 inference 优化，训练不能依赖它；支撑 W2 只谈 runtime 预算，不改训练 |
| W2-WEB-10 | Prompt caching agentic tasks paper | https://arxiv.org/abs/2601.06007 | 2026-01-09 | 动态 tool results/动态内容会破坏缓存收益；支撑 dynamic trim 是缓存和同源双重风险 |

## 决策矩阵

| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line 或 URL+日期) | 状态 | 🔴防惨败列 cite P1-P9 |
|---|---|---|---|---|---|---|
| S-101 | 3a fallback chain 排序 | A 直接 32K；B runtime 动态裁剪；C manifest 静态链：device-group → top-2 `_sg` pair → scene macro → clarify/NO_TOOL | ⭐C | E-lite seed 已写降级链与 scene macro 同 manifest：`docs/e2-subset-design-package-2026-07-02.md:33-43`；L4 指出 8K 只有部分族直装：`L4-e2-subset-materials.md:75-92`。 | proposed | 防 32K 逃避端侧目标、runtime 动态裁剪漂移；P1/P2/P6/P8。 |
| S-102 | 3b 超限检测时点 | A runtime 发现超限后 trim；B manifest build static gate；C 只 warning | ⭐B | Phase-1 是 construction only 且 receipt 必含 digest/失配 BLOCKED：`docs/e2-subset-design-package-2026-07-02.md:43-46`；dynamic trim 会让 train/C6/runtime 面不同。 | proposed | 防 metadata 绿灯、运行时偷删工具；P2/P6/P7/P9。 |
| S-103 | 3c 8K 预算公式 | A 只算 tools+system；B 算 system+tools+user；C 算 system 29 + 3轮 DialogueState 101 + user reserve + generation headroom + digest reserve | ⭐C，build cap=`7200` tool tokens | 本轮离线 tokenizer 实算 exact tool budget `7541`，policy+digest `7358`；home-llm 默认 context 8192 / max_tokens 512：`docs/research/2026-06-19-home-llm-teardown.md:55`。 | proposed | 防“7901 with system”假过 8K；P7/P8/P9。 |
| S-104 | 3d KV 预热与 prefix 稳定 | A 每轮换 group 且期待 cache；B 只预热全量大 prompt；C per manifest/group/macro 预热，静态 tools/system 前置，动态 DialogueState 最后；group 切换视为冷启动/显式重预热 | ⭐C | home-llm `_cache_prompt` 预热系统 prompt+工具+态，且静态前动态后：`docs/research/2026-06-19-home-llm-teardown.md:47-48`, `:81-82`；vLLM/SGLang/OpenAI/Anthropic 均基于稳定 prefix 缓存（W2-WEB-01~06）。 | proposed | 防把缓存收益当免费、把动态 trim 当无代价；P6/P7/P8。 |
| S-105 | 4a scene macro 与 C2 关系 | A scene macro 自己定义状态和执行边界；B demo yaml 手写 tool list；C scene macro 只引用 C2 state-cells + C1/C2 codegen 派生 tool group，manifest 记录 digest | ⭐C | C2 拥有 execution_range/readback：`openspec/specs/scenario-state-protocol/spec.md:6-21`；demo-scenarios 明确 c1_ref 是系统侧 IR，D-domain tool name 后续 codegen 回填，禁止手写：`contracts/demo-scenarios.yaml:13-20`。 | proposed | 防第二 SSOT 和执行边界漂移；P1/P2/P6。 |
| S-106 | 4b scene macro 触发 | A runtime 低置信自动随意切；B 只由 presenter console 强制；C Phase-1 只做 schema/digest；Phase-2 允许 `presenter_forced_scene` 优先，`low_pre_route_confidence` 只进入显式 fallback receipt | ⭐C | 当前 Phase-1 不含 runtime NLU 预路由实装：`docs/e2-subset-design-package-2026-07-02.md:45-47`；demo 5 幕是 must-pass 路径：`openspec/specs/demo-experience/spec.md:33-45`。 | proposed | 防把 construction 文档偷换成 runtime 行为；P6/P8/P9。 |
| S-107 | 4c macro 内容与预算 | A 五幕合成 mega macro；B 每个 scene 只挂 expected tools；C 每 scene/act 挂 `_sg` union，字段含 `scene_id/act_id/group_ids/tool_ids_digest/token_count/required_state_cells/budget_result`，cap=`7200` | ⭐C | 本轮 `_sg` union 实算 scene1=6049、scene2=5893、scene3/4=1757、scene5=702 tool tokens，均可进 7200；L4 要求 scene subset 同源生成 train/eval/runtime：`L4-e2-subset-materials.md:239-246`。 | proposed | 防只挂答案工具训练作弊，也防 mega macro 爆预算；P1/P3/P6/P7。 |
| S-108 | 4d macro-out utterance 边界 | A scene 外一律 global unsupported；B scene 外 runtime 静默重路由；C 三层出口：`group_out_of_mount` 可澄清/切 macro，`mvp_unsupported` 明确 10 族外，`global_unsupported` 非车控；safety 独立更高优先级 | ⭐C | C2/工具执行要求错误不冒充成功、readback 才算成功：`tool-execution/spec.md:137-160`；demo safety scene 要优雅拒识：`contracts/demo-scenarios.yaml:135-150`；W3 同源门也把 NO_TOOL 出口列为核心防线。 | proposed | 防 scene 外误伤成“我不会”，也防重路由假绿；P5/P6/P8/P9。 |

## Landing 草案

推荐 manifest 增加以下 add-only 字段，不在 W2 实现：

```yaml
subset_policy_id: e2-lite-v1
mount_mode: device_group | top2_sg_pair | scene_macro
budget:
  tokenizer_id: mlx-community/Qwen3-1.7B-4bit
  context_cap_tokens: 8192
  system_tokens: 29
  dialogue_state_tokens_budget: 101
  user_tokens_budget: 64
  generation_headroom_tokens: 512
  digest_trace_reserve_tokens: 128
  tool_tokens_cap: 7200
  actual_tool_tokens: 6049
  result: pass | fail_over_budget
cache:
  prefix_order: static_tools_then_system_then_dynamic_state
  prewarm_required: true
  prewarm_scope: per_group_or_scene_macro
scene_macro:
  scene_id: scene1
  act_id: optional
  source_scene_digest: sha256(...)
  required_state_cells: [...]
  c1_refs_digest: sha256(...)
  group_ids: [...]
  mounted_tool_ids_digest: sha256(...)
  missing_expected_in_mounted: false
```

## 残余风险

- 本稿只做文档决策与本机静态/tokenizer 实算，不实现 manifest/codegen/runtime prewarm。
- `DialogueState=101` 是 W2 budget probe 口径，不是已锁 runtime schema；后续若真实 DialogueState 更大，`7200` cap 要重新实算。
- `scene2` 的 `ac_temperature + power_on` 映射风险必须由 codegen/fixup/gate 解决；W2 不手写修源文件。
- Web 证据说明 cache/prefix 稳定原则，不等于 MAformac 端侧 MLX 已具备可用 KV 预热实现；那是 Phase-2 runtime spike。
