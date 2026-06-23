# A2 后路线图深度审计 + home-llm 源码 teardown 对照

> **as-of**: 2026-06-23 · 综合 Hermes (glm-latest) + Codex 双源审计 · 全部声称已 cite-verify
> **范围**: MAformac A2 (`migrate-d-domain-tool-surface` PR #3 合并后) 之后的训练/评测路线（除 UI/UE）— 即磊哥引的 3 步:① C5 数据 (`retrain-c5 §2.2`) → ② C5 实跑 (`retrain-c5 §3` 守 rank16Mainline + LR 1e-4) → ③ C6 四层评测 (`rebuild-c6 §3` candidate vs base 10/23 不退化)
> **方法**: 实读 4 份基线文档 + 实读 `acon96/home-llm` (1364★ · 2026-06-23 仍活, develop 分支) 全核心面源码 (`train/` + `data/` + `docs/`, ~110KB), 双源 verdict 融合 + cite-verify
> **🔴 身份定位（Codex 2026-06-23 二审纠偏后明确）**: 本文 = **post-A2 C5/C6 model-quality decision pack + pre-propose checklist**, **不是 SSOT, 不是 live fact source, 不是路线图**。SSOT 仍 = `docs/grill-tournament/grill-decisions-master.md` (41 题) + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` (范式权威)。本档 §1 所谓"3 步 = 当前唯一活的事实源"是**对那 3 步技术方向认可**的措辞, 不等于"3 步就是下一步要做的事"——下一步是 **Phase 0 路线债清理 (non-UIUE P0 grill Q04/Q08/Q12/Q16-Q21/Q06↑/Q24)**, 不是 retrain propose。本档 7 项 gate (§4) 必须在 propose 启动时**写进 OpenSpec change tasks**, 不是单独执行的 spike 项。

---

## §0 TL;DR (一段读完)

磊哥引的 3 步 = **A2 后路线唯一活的事实源**, 双源一致认可方向 (顺序对/守配方对/4 层门对). 但 retrain-c5 启动前**必须显式拍 7 件事**, 否则 0/34 灾难重演风险高:

1. **训练栈 spike** (本机 mlx-lm vs 云 Axolotl — home-llm 实证 24GB VRAM Docker 默认)
2. **base recalibration on D-domain** (10/23 锚是 generic frame 时代的, A2 后失效)
3. **训练中途 C6 抽样 gate** (`§15 GOV6` 未拍, 0/34 教训直接需求)
4. **iOS 真机 endpoint 与 retrain 并行启动** (串行 = demo 前一周炸场)
5. **失败/错误恢复类: 砍还是纳入第五类?** (home-llm `train_on_turn=False` 实证, MAformac 当前 4 类 silent drop)
6. **四类配比 factors** (home-llm 实证 templated 10-25x ≫ status 8-18x ≫ refusal 3-8x ≫ failure 1-2x, MAformac 未定)
7. **数据合成双腿: 模板确定性 + 云生成自然中文** (home-llm 纯模板法证明确定性必要, 当前 §2.2 纯云 generator 不可控)

**核心灵魂**: 「核心不省, 工程砍」demo 铁律 — 可砍的是全覆盖/全链路/真控, **不可砍**的是 masking/负例/配比这些让小模型可靠的内核 (home-llm §11 元洞察 = MAformac oracle 3HIGH).

---

## §1 基线 SSOT 实读: 你引的 3 步 = 当前唯一活的事实源 (认可)

实读 4 份基线文档后确认这 3 步是当前**唯一活的事实源**, 没分叉:

| 引用 | 实读 file:line | 状态 |
|---|---|---|
| ① **C5 数据** `retrain-c5 §2.2` D-domain 四类自然中文语料 (云 generator + 异源 judge) | `c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:213` (C1 ✅ grill 拍): 云多源 generator + 异源 judge + contract 定标签 + 原文 oracle 非训练集(红线) + 单语中文 + 四类数据(positive / followup / unsupported_refusal / safety_refusal) + distractor-in-prompt | ✅ grill 拍 |
| ② **C5 实跑** `retrain-c5 §3` 守 rank16Mainline + LR 1e-4 | `paradigm-amend.md:391` (C3 ✅ 拍): 守 rank16Mainline (`C5LoRATraining.swift:1175-1188`), baseline 不动 (G6-C 只比 50/100/150 早期曲线); 新增 `verify-tool-surface-parity` (train/eval/runtime 三处从 A2 单源 = TRN2 防 0/34 复发) | ✅ grill 拍 |
| ③ **C6 四层评测** `rebuild-c6 §3` candidate vs base 10/23 不退化 → 目标提升 (四层独立门) | `paradigm-amend.md:267` (C4 ✅ 拍): 4 层独立门 golden_demo (炸场剧本 **100% 硬门**) / demo_fuzz / unsupported / safety **各设阈值不合一个 pass_rate** (旧 0/23 教训=聚合数掩盖分轴) + `:393` (D2 ✅ 拍): 多条件 AND 门 + IrrelAcc demo 口径单定 | ✅ grill 拍 |

**OpenSpec change 4 个 skeleton 已就位** (`handoffs/2026-06-23-doc-cascade-pushed-a2-refactor-dispatch.md:7`):
- `migrate-d-domain-tool-surface` ← A2 当前 PR #3 (✅ APPROVE — 见 [`pr_audit_3.md`](../../pr_audit_3.md))
- `retrain-c5-lora-d-domain` ← 你的 ①② (**DEFERRED**, 本文核心审计对象)
- `rebuild-c6-four-layer-bench` ← 你的 ③ (DEFERRED, 本文核心审计对象)
- `define-demo-golden-run-and-voice` ← UI/UE 那条 (本文不论, 见 UIUE U1-U31)

**A2 边界铁律** (`paradigm-amend.md:418` / dispatch:19-22) 明确「**训练 + 后端 DEFERRED 延后不排期** / A2 之后独立重新立项」= 你引的 3 步本身**故意未排 ETA**, 是「先把代码改对, 再回来谈训」的纪律决策, **不是漏排**.

### 🔑 磊哥那句备注 = 整条路线最关键的一句

> 「不是 A2 完直接训, 先得有 D-domain 对齐的语料」

这句是 0/34 灾难的根因课的**精炼一句话**: A2 只迁了 surface (代码说 D-domain), 训练 DATA 还在旧 frame 形态 = train/eval 又异源 = 0/34 复发. **① 是 ②③ 的载重前置**, 顺序对 (≡ 旧 H4「先数据门 vs 先训 → 先数据门」, `roadmap-2026-06-20:103`).

---

## §2 home-llm 源码 teardown (1364★ · 2026-06-23 仍活 · 产业第二证据)

实读: `acon96/home-llm` · `develop` 分支 · `train/` + `data/` + `docs/` 全核心面 · 3 份 README + `evaluate.py` (15.8KB) + `tools.py` (28KB) + `generate_data.py` (41KB) + 2 份 Axolotl config + 5 份 Jinja chat template. **GitHub API 实读, 非凭记忆**.

### 2.1 工程范式速览

| 维度 | home-llm 做法 | 证据 |
|---|---|---|
| **工具范式** | D-domain 具名 (24 个 Hass*: HassTurnOn / HassLightSet / HassClimateSetTemperature ...) + 隐式 `SERVICE_TO_TOOL_MAP` 字典层 | `tools.py:1-25, 28-32` |
| **训练栈** | **Axolotl Docker** + CUDA + **24GB VRAM 最低** + 三种粒度 Full/LoRA/QLoRA | `train/README.md:13-14, 42-44` (镜像 `axolotlai/axolotl-cloud:main-py3.11-cu128-2.8.0`) |
| **数据合成** | 程序化拼 piles CSV (`generate_data.py` 41K) + LLM 续生 piles (`synthesize.py` 43K) + 跨 5 语言 (English/German/French/Spanish/Polish) + 多 persona | `data/README.md:14-18, 60-72` |
| **chat template** | Jinja `gemma3_withtools.j2` 用 `<tool_call>...</tool_call>` + 4 special tokens (`<tool_call>` / `</tool_call>` / `<tool_result>` / `</tool_result>`) | `train/configs/gemma3-270m.yml:62-66` |
| **训练 recipe** | lr=2e-4 / batch=16 (ga16×mb1) / 1 epoch / cosine / warmup=0.1 / seq=4096 / sample_packing=true / adamw_bnb_8bit | `train/configs/gemma3-270m.yml:78-100` |
| **loss masking** | `roles_to_train: [assistant]` 全 assistant turn 训 (**粗粒度**) | `gemma3-270m.yml:78` |
| **评测口径** | 单一 `accuracy = correct/total` + rgb_color 单点容差 (**没有分层独立门**) | `evaluate.py:90-208` |

### 2.2 🔴 home-llm 五类数据 + 配比 factors (Codex 头号洞察, 已 cite-verify)

实读 `data/generate_data.py` 锁死 home-llm 是**五类数据**, 不是 MAformac 文档里隐含的"四类":

| 类 | 生成函数 | train_on_turn | 用途 |
|---|---|---|---|
| **static** (具体指令) | `generate_static_example` `:32` | True | 正例 |
| **templated** (模板参数化) | `generate_templated_example` `:181` | True | **正例 + 参数泛化主力** |
| **status_request** (状态读回) | `generate_status_request` `:370` | True | 教模型生成读回话术 |
| **refusal** (拒识) — 含两个 reason_type | `generate_refusal_example` `:563`, `reason_type = refusal_case.get("reason_type", "not_available")` `:569` | True | `not_available`(族外拒) + `already_state`(状态拒, 如"已关→已经关了") |
| **failure** (错误恢复, 3-turn) | `generate_tool_failure_example` `:468`, multi-turn 失败步 `train_on_turn=False` `:542 / :616 / :621 / :629 / :684 / :690` | **False** (失败步) | 学「恢复」不学「产生错误」 |

**配比 factors 四档 (实证, 不是猜测)** `generate_data.py:853-859`:

| 档 | static | templated | status | refusal | failure | template/failure 比 |
|---|---|---|---|---|---|---|
| sample | 1 | 1 | 1 | 1 | 1 | 1x |
| small | 1 | **10** | 8 | 3 | 1 | 10x |
| medium | 5 | **15** | 12 | 5 | 1 | 15x |
| large | 5 | **20** | 15 | 6 | 1 | 20x |
| xl | 7 | **25** | 18 | 8 | 2 | 12.5x |
| **test** | 0.25 | 1 | 2 | 1 | 1 | — |

**精确实证**: templated 10-25x ≫ status 8-18x ≫ refusal 3-8x ≫ failure 1-2x. **泛化类最重**, failure 最轻但**绝不为 0**. 这是 home-llm 1364★ 验证过的工程智慧, **不是配置文件的随意值**.

### 2.3 home-llm 工程智慧 (MAformac 应吸收但当前 skeleton 未显式继承)

| 智慧 | home-llm 实证 | MAformac 状态 |
|---|---|---|
| **failure 步 masking** | `:542 train_on_turn=False` 失败步不算 loss, 只算「恢复 turn」 | ❌ 当前 4 类无 failure 类 |
| **templated 占位 + random_parameter** | `:181-360` 模板里 `<device_name>` / `<color>` / `<temperature>` 占位 → 同步替换 question/answer/tool_args 三处 → **确定性参数泛化** | ⚠️ A2 已有 `dDomainToolCallArguments` (slotAssignments 值随机化) 但未被 retrain-c5 §2.2 引为生成腿 |
| **refusal 双 reason_type** | `:569` `not_available`(族外) vs `already_state`(状态感知) | ⚠️ 当前 unsupported 只覆盖 `not_available`, `already_state` 没归类 |
| **4 档配比 + test 集 factor 倒置** (`:863` test static=0.25) | 训练堆 templated 泛化, 测试反转 | ❌ 当前未定 |
| **multi-turn assistant 训练** | `:639 train_on_turn=turn.get("train_on_turn", True)` 每个 turn 单独标 | ⚠️ MAformac C2 masking ✅ 拍了 token 级, 但 multi-turn 设计未明 |

### 2.4 home-llm 评测的"软肋" (MAformac 的相对优势)

`evaluate.py:90-208` 实读: home-llm 是**单一 accuracy = correct_answers / total_answers**, 唯一容差是 `rgb_color` 单点 (`:193-203`). **没有分层独立门**, 没有 alternatives 多正解, 没有 AND 多条件门, 没有 IrrelAcc 单独阈值.

→ 这是 MAformac 4 层独立门 + AND 门 + alternatives + IrrelAcc demo 口径 (`paradigm-amend.md:267, 393`) **远超 home-llm** 的地方, 也是 0/34/0/23 灾难买的纪律红利. home-llm 任务简单 (HA 域内 24 个工具) 不亏, MAformac 562 intent 复杂度 23x **必须**这级评测纪律.

---

## §3 双源融合: 5 类 vs 4 类对齐表 + GAP 分析

> 综合 Hermes 第一轮 + Codex 第一轮, cite-verify 后融合.

| home-llm 5 类 (1364★ 配方) | MAformac 4 类 (retrain-c5 §2.2) | 对齐情况 | 决策建议 |
|---|---|---|---|
| **static + templated** (正例 + 参数泛化) | **正样本** (D-domain 具名工具) | 🟢 对齐 | MAformac 用 dDomainToolCallArguments 模板腿补 templated |
| **refusal.not_available** (族外拒) | **unsupported_refusal** (族外兜底) | 🟢 对齐 | — |
| **refusal.already_state** (状态感知拒, 如"空调已关→已经关了") | **safety_refusal** (L4 安全拒识 ASIL/forbidden) | 🟡 **不完全等价** | already_state 是「已在目标态」感知拒, 与 ASIL 安全拒**不同性质**, 当前 silent drop |
| **status_request** (状态读回训模型生成话术) | readback **走方案 P 端 renderer** (`grill-decisions.md` ε 拍 P, 不进训练 hard_pass) | 🟡 **分歧但 MAformac 更省** | 端确定性 renderer 出话术, 不训模型 — demo 取巧合理 (减小模型负担), **但要意识到这是主动砍** |
| **failure** (错误恢复 3-turn, 失败步 `train_on_turn=False`) | ❌ **当前 4 类无对应** | 🔴 **GAP 1** | 必须显式决策: 砍 (demo 约定收窄) or 纳入第五类 |
| (home-llm `data/README.md` 末「TODO 多意图」自承没做) | **followup** (多意图连续两句, `H 组 §12`) | 🟢 **MAformac 补了 home-llm 没做的** | — |

### 🔴 3 个 GAP — home-llm 证明的工程智慧, MAformac skeleton 当前未继承

#### GAP 1: 错误恢复类丢失 (silent drop)

- **home-llm 实证**: failure 样本是小模型可靠性关键 — 学「恢复」不学「产生错误」, 失败步 `train_on_turn=False` 防止学坏 (`generate_data.py:542 / :616 / :621 / :629 / :684 / :690`).
- **MAformac 风险**: 当前 4 类 silent drop, 不是显式决策. demo「现场只说 10 族 + 约定收窄输入」**可能可砍** (错误场景少, 演示约定消除), 但**必须显式拍**, 不能默认遗漏.
- **⭐ 倾向**: **砍 + 显式记录决策**「demo 约定收窄, 错误场景由现场约定消除, 不引入 failure 类」(对齐 `blueprint-teardown` demo 取巧铁律). 但如果端侧 LoRA 加载/解析偶发失败 (B1 mlx-swift JSON 三层防御解析未完全可控), failure 类应该保留一点最小种子 (像 home-llm xl 档也只 factor=2, 不重).

#### GAP 2: 配比 factors 未定

- **home-llm 实证** (`:853-859`): templated 10-25x ≫ status 8-18x ≫ refusal 3-8x ≫ failure 1-2x. **泛化类最重是数据量主来源**.
- **MAformac 风险**: retrain-c5 §2.2 列了 4 类**但没定配比**. 不定配比 = 训练时一类压倒一类 = 假提升或假坍缩.
- **⭐ 建议配比** (参考 home-llm 但因 MAformac 砍 status/failure 调整):
  - **正样本 (D-domain 具名) ≫ unsupported_refusal ≫ safety_refusal ≫ followup**
  - 数值建议: positive=20 / unsupported=8 / safety=4 / followup=2 (参考 home-llm large 档 templated=20 锚定)
  - 必须**实跑 spike 验证** + 训练中途 gate (见 §4 补强 3) 监控.

#### GAP 3: 数据生成法 — 云 generator 自然中文 vs home-llm 模板法

- **home-llm 实证**: `generate_data.py:181-360` 是「模板占位 + `random_parameter()` + 同步替换 question/answer/tool_args 三处」= **确定性、可控、参数泛化覆盖保证**.
- **MAformac §2.2**: 云 generator 生成自然中文 (北极星: 听懂中文) — **更自然但质量靠异源 judge 把关** (judge 也会漏, claim-vs-reality 第 N 变体).
- **⭐ 建议双腿**:
  - **腿 A (确定性)**: A2 已有的 `C5LoRATraining.swift:2029-2056 dDomainToolCallArguments` (slotAssignments 值随机化) = **模板法**确定性兜底, 保证参数泛化全覆盖 + arg key 同源 enforce (TRN2 防 0/34)
  - **腿 B (自然度)**: 云 generator 加自然中文变体, 异源 judge 把关
  - **配比建议**: 模板腿 70% + 云腿 30% (模板兜底保覆盖率, 云加 demo 现场口语自然度), 不纯靠云 (不可控、judge 会漏).

---

## §4 7 项必须显式拍板 (retrain-c5 / rebuild-c6 propose 前置)

> 综合 Hermes 4 处补强 + Codex 3 个拍板 = 7 项. **每项含: 问题 / 证据 / 建议 / 物理落点**.

### ⭐ P0-1: 训练栈 spike (云 GPU Axolotl vs 本机 mlx-lm)

- **问题**: `c5-recovery/roadmap.md:99-100` + `roadmap-2026-06-20:137` 双 BLOCKED — unsloth 要 CUDA / Mac M5 无 N 卡 / mlx-lm 本机能力边界未测 (`§15 TRN7`).
- **home-llm 实证**: Axolotl Docker + CUDA + 24GB VRAM 是产业默认 (`train/README.md:13-14, 42-44`), 270m 都跑 1 epoch / batch=16 / seq=4096 (`gemma3-270m.yml:78-100`). MAformac Qwen3-1.7B **大 6x**, 本机不一定撑得动.
- **建议**: retrain-c5 启动前必须 spike — mlx-lm 本机 LoRA 跑 Qwen3-1.7B 一个 tiny epoch (rank=16 / 200 sample / seq=2048) → 测显存 / 速度 / loss 曲线 → **决策表驱动**选栈. 不能等数据生成完才发现训不动.
- **落点**: `docs/spikes/2026-06-2X-mlx-lm-vs-cloud-gpu-training-stack-spike.md` + 加入 retrain-c5 OpenSpec change `tasks.md` 第一项硬前置.

### ⭐ P0-2: base recalibration on D-domain surface

- **问题**: base 锚 **10/23** (`grill-decisions.md:120-123`) 是 **generic frame 时代** Qwen3-1.7B 跑出来的. A2 后 model-visible surface 已迁 D-domain, **同 base 模型在新 surface 下的 hard_fail 数会变** (具名工具拆小判定面 → base 大概率更好或更差), 现在的 10/23 锚**已是旧基准**.
- **建议**: A2 PR #3 合并 + C6 bench 迁 D-domain expected 完成后 (PR #3 已做) → **跑一次 base Qwen3-1.7B 在 D-domain surface 下的 baseline** (4 层独立门各跑一次) → 锁新 anchor `base_d_domain_anchor.yaml` → 这才是 candidate vs base 的诚实 diff 基准.
- **依据**: `c5-recovery/roadmap.md:78` M4 「Base C6 v2 baseline」就是这一步, **别遗漏**.
- **落点**: `rebuild-c6-four-layer-bench` change `tasks.md` 第一项 (在 candidate train 启动之前).

### ⭐ P0-3: iOS 真机 endpoint 与 retrain-c5 并行启动

- **问题**: `roadmap-2026-06-20:20` 🔴 无 target iOS device + endpoint V-PASS 阻塞链. retrain-c5 在云上训完 → C6 4 层在 Mac 上评完 → 才发现端侧 mlx-swift LoRA 加载 / 受限解码 / 防御解析 / TTFT / OOM 全部炸 = **串行炸场风险**.
- **建议**: iOS 真机采购/借测**与 retrain-c5 并行启动**, 不等. C5 PR3 端侧 parity (`§16 C5 ✅拍` 拆 `render_parity_diff=0` + `endpoint_decode_spike`) 必须在 ③ C6 评测之前完成端侧 LoRA spike + 防御解析 spike.
- **风险**: 串行 = 演示前一周才发现端侧炸 = 灾难.
- **落点**: `procurement/2026-06-XX-iphone-target-device.md` (备机/借测) + 加入 retrain-c5 启动 checklist「真机 endpoint spike: 与训练并行进行」.

### P1-4: 训练中途 C6 抽样 gate (home-llm 不需要 MAformac 必须)

- **问题**: `§15 GOV6` 「0/34+0/23 灾难根因之一 = codex 自主跑无中途验证 gate」**未拍**.
- **home-llm 对照**: `gemma3-270m.yml:90` `saves_per_epoch: 1` (一轮才 save 一次) = 任务简单不亏. MAformac 562 intent / 4 类数据 / 8 lens × 79 finding 复杂度 23x → 一轮才看一次 = **重蹈 0/34 覆辙**.
- **建议**: retrain-c5 spec 必须含 `mid_training_gate.yaml`:
  - **iter50/100/150** (`§14 D1` 已锁的密 checkpoint 节奏) 抽样跑 C6 第一层 golden + 第二层 fuzz **各 N=5**
  - 不达 `trigger_recovery_threshold` (e.g. golden ≥ 60% / fuzz ≥ 40%) **立即停**
  - 不练完 600 才发现全 0
- **落点**: retrain-c5 change `design.md` 新增「mid_training_gate」段 + Superpowers subagent-driven-development hook.

### P1-5: 错误恢复类显式决策 (GAP 1)

- **问题**: home-llm 5 类含 failure, MAformac 4 类没 — silent drop **不是显式决策**.
- **⭐ 倾向**: 砍 + 显式记 (demo 约定收窄, 错误场景由现场约定消除).
- **若保留**: 最小 factor=2 (参考 home-llm xl 档), 端侧 LoRA 加载偶发失败的 recovery, 失败步 `train_on_turn=False`.
- **落点**: retrain-c5 change `proposal.md` 「why not 5 categories: failure class」段, 显式记录 delta.

### P1-6: 四类配比 factors (GAP 2)

- **问题**: §2.2 列 4 类**没定配比**, 风险见 §3 GAP 2.
- **建议初值**: `positive=20 / unsupported=8 / safety=4 / followup=2` (参考 home-llm large 档 templated=20 锚定).
- **必做**: 配比 spike (200 sample 跑 small/medium/large 三档观察 loss 曲线 + 4 层独立门 base 各档表现) → 拍 production 配比.
- **落点**: retrain-c5 change `data_recipe.yaml` `category_factors` 字段 + spike 报告.

### P1-7: 数据合成双腿 (GAP 3)

- **问题**: §2.2 当前纯云 generator, 不可控 + judge 会漏.
- **建议**: 模板腿 (A2 `dDomainToolCallArguments` 复用) 70% + 云腿 (云 generator 异源 judge) 30%.
- **落点**: retrain-c5 change `data_recipe.yaml` 双腿配比字段 + 模板腿 reuse A2 已有产物 (零额外代码).

---

## §5 与旧路线图对照: 一致 + 一处 re-categorization drift (Codex 抓到)

| 路线图 | 形态 | A2 后状态 |
|---|---|---|
| `roadmap-2026-06-20-from-c6-done.md` | P0 C6 收尾 → P1-A 数据门 → P1-B Qwen spike → P1-C train → P2 C4/C7 | 顶部 banner 已标 **D-domain 翻案 supersede** (`:3-6`) |
| `c5-recovery-2026-06-22/roadmap.md` M0→M8 | M0 决策 → M1 Compiler → M2-3 Surface/Gold → **M3.5 tiny-overfit ablation** → M4 base baseline → **M5-6 Data v2 + LoRA** → M7 Parity → M8 异构审计 | M1-M3 ≈ A2 当前 PR #3; **M5-M6 = 你的 ①②**; **M4 base recalib 隐性前置 = P0-2**; M7 = 端侧 parity = P0-3; M8 = 异构审计 |
| `final-grill-list.md` 41 题 (grill SSOT) | Q01/Q02/Q05/Q39 已转 A2 派单合同; **A2 边界外 GOV/CAS/TRN/UIX 35 项待 grill** | 训练中途 gate / 真机 endpoint / C5↔C6 base recalib **都在 35 项里** |

### 5.1 ✅ 一致项 (双源都认同)

- **H4 先数据门 vs 先训 → 先数据门**: ①在②前, 完全一致 (数据门模型无关可先做, `roadmap-2026-06-20:103`).
- **C5 3HIGH 防死记三件套** (`masking + heldout / 同harness 去污 / IrrelAcc≥20%`): retrain-c5 §2.4 + §4.3 heldout/OOD + rebuild-c6 unsupported 门**全对齐没丢**.
- **base hard_fail 诚实锚**: 旧 IrrelAcc 0.789 → 现在 action hard_pass base 10/23 (按 case schema 拆, 非整体 7/57) = **口径细化更严**不洗白, 对齐 claim-vs-reality.
- **③ 四层门 > 旧双轴 bench**: 旧「全集覆盖+must-pass 双轴」→ 现「golden/demo_fuzz/unsupported/safety 四层独立门, 禁互相冒充」(Q41) — 比双轴**更严**, 对齐「防假绿」. ✅ 升级.

### 5.2 🟡 一处 re-categorization drift (Codex 抓到的纪律问题)

- **drift**: 旧 roadmap (范式翻案前) 直接 adopt home-llm **5 类**; 范式翻案后 re-categorize 成「4 类」(按 demo 灵魂: 安全拒识/ASR 澄清/多意图).
- **re-categorization 本身合理** (demo-tailored), 但**丢了 failure 类** (GAP 1) + status 改端 renderer (主动砍), 这两个是从「home-llm 5 类」到「4 类」的 **delta**, 该有显式记录.
- **当前 skeleton 只列 4 类, 没说「为什么不是 5 类」**.
- **修复**: retrain-c5 change `proposal.md` 必须含「why 4 categories not 5 (delta from home-llm baseline)」段 — 记两件事:
  1. failure 类砍掉的理由 (demo 约定收窄)
  2. status_request 改端 renderer 的理由 (端确定性, 不进训练 hard_pass)
- **claim-vs-reality**: 文档先行铁律 (CLAUDE §7) — 不记录的决策 = 未来 grill 时被当事实, 像 534 vs 562 口径反复一样.

---

## §6 home-llm §11 元洞察 = MAformac oracle 3HIGH (核心不省, 工程砍)

home-llm 1364★ 五年迭代沉淀的**元洞察** = 跟 MAformac 0/34 教训殊途同归:

| home-llm 工程智慧 | MAformac oracle 3HIGH 对应 | 核心 / 工程 |
|---|---|---|
| 5 类数据完整 (failure 实证可靠性) | masking + 4 类 + 配比 | **核心不省** ⛔ |
| 配比 factors 实证 (templated 10-25x ≫) | 配比 spike (P1-6) | **核心不省** ⛔ |
| 失败步 `train_on_turn=False` | C2 token 级 masking ✅ 已拍 | **核心不省** ⛔ |
| 模板占位 + random_parameter 确定性 | dDomainToolCallArguments 模板腿 (P1-7) | **核心不省** ⛔ |
| 异源 judge | 异源 judge + judge_family != generator | **核心不省** ⛔ |
| Axolotl Docker 24GB VRAM | 训练栈 spike (P0-1) | **核心不省** ⛔ |
| 5 语言全覆盖 | 单语中文 (现场单语) | 工程砍 ✂️ |
| status_request 训模型生成话术 | 端 renderer 不训 | 工程砍 ✂️ |
| 全 HA 域工具 | 10 族 562 intent (现场约定) | 工程砍 ✂️ |
| FC→NLU→DS→DM 全链路 | FC→mock 端态 | 工程砍 ✂️ |
| 真控 HA 服务器 | mock 端态自包含 | 工程砍 ✂️ |

**铁律**: 可砍的是「全覆盖 / 全链路 / 真控」(对应 demo 取巧 = 演示约定收窄消除全集需求); **不可砍**的是「masking / 负例 / 配比 / 双腿数据生成 / 异源 judge / 24GB 训练栈」这些让小模型可靠的内核.

→ **demo 取巧 ≠ 配方取巧**. 配方 (rank16Mainline + LR1e-4) 已 ✅ 拍守, 数据合成配方 / 配比 / 训练栈也**必须**比 home-llm 严, 不能 demo 借口砍.

---

## §7 整体认可度 + 优先级矩阵

| 项 | 双源认可度 | 优先级 | 理由 |
|---|---|---|---|
| ① 云 generator + 异源 judge + 4 类中文语料 | ✅✅ STRONG | P1 (`retrain-c5 §2.2`) | home-llm + 真实座舱 + grill 三源认证, **但需双腿+配比+失败类决策见 P1-5/6/7** |
| ② 守 rank16Mainline + LR 1e-4 配方零碰 | ✅✅ STRONG | P1 (`retrain-c5 §3`) | A2 是 surface 迁移非配方问题 (`§17:438` 锁定); A2 PR #3 已 `Package.swift +1/-0` 实证零碰 |
| ③ C6 四层独立门 + AND 多条件 + alternatives | ✅✅✅ STRONG | P1 (`rebuild-c6 §3`) | 远超 home-llm 单一 accuracy, 0/23 教训买的纪律红利 |
| **P0-1 训练栈 spike** | 🔴 必加 | **P0** (①前置) | home-llm 实证 Axolotl Docker 24GB 默认, 本机不一定撑得动 1.7B |
| **P0-2 base recalibration** | 🔴 必加 | **P0** (①②间) | 10/23 是 generic frame 时代锚, A2 后失效, ≡ M4 |
| **P0-3 iOS 真机并行** | 🔴 必加 | **P0** (与②并行) | 串行炸场风险 = demo 前一周才发现 |
| **P1-4 训练中途 gate** | 🔴 必加 | P1 (②内) | 0/34 教训直接需求, home-llm 不需要 MAformac 必须 |
| **P1-5 错误恢复类决策** | 🔴 显式拍 | P1 (①proposal) | GAP 1, silent drop ≠ 决策 |
| **P1-6 四类配比** | 🔴 必加 | P1 (①spike) | GAP 2, home-llm 实证 templated 10-25x ≫ |
| **P1-7 数据合成双腿** | 🔴 必加 | P1 (①spike) | GAP 3, 纯云不可控 + judge 漏 |

---

## §8 物理落点 (写盘建议)

> 本研究档不直接改 SSOT, 但派生以下产物供后续 propose / spike 用.

### 8.1 retrain-c5 OpenSpec change (DEFERRED → propose 启动前必读本文)

```
openspec/changes/retrain-c5-lora-d-domain/
├── proposal.md          # 含「why 4 categories not 5」delta 段 (§5.2)
├── design.md            # 含 mid_training_gate (P1-4) + 双腿合成 (P1-7)
├── data_recipe.yaml     # category_factors (P1-6) + 模板/云双腿配比 (P1-7) + 失败类决策 (P1-5)
└── tasks.md             # 第一项硬前置: P0-1 训练栈 spike
```

### 8.2 rebuild-c6-four-layer-bench OpenSpec change (DEFERRED → propose 启动前必读本文)

```
openspec/changes/rebuild-c6-four-layer-bench/
├── proposal.md
├── design.md
└── tasks.md             # 第一项硬前置: P0-2 base recalibration on D-domain
```

### 8.3 配套 spike 报告 (回写本文 §4 决策)

- `docs/spikes/2026-06-2X-mlx-lm-vs-cloud-gpu-training-stack-spike.md` (P0-1)
- `docs/spikes/2026-06-2X-base-d-domain-recalibration.md` (P0-2)
- `docs/spikes/2026-06-2X-ios-target-device-endpoint-spike.md` (P0-3)
- `docs/spikes/2026-06-2X-c5-data-recipe-factors-spike.md` (P1-6 + P1-7)

### 8.4 配套 procurement

- iOS 真机采购单 (P0-3) — 与 retrain-c5 启动并行, 不等.

---

## §9 双源审计 meta

| 字段 | 值 |
|---|---|
| 审计时间 | 2026-06-23 (Asia/Shanghai) |
| 审计模型 (源 1) | Hermes glm-latest (custom provider) |
| 审计模型 (源 2) | Codex (磊哥独立问同题, 内容已 cite-verify 全部属实) |
| 融合方法 | claim-vs-reality 双源对账 — Codex 7 声称 (5 类入口 / failure mask / 4 档 factors / reason_type / templated 占位 / status train 话术 / re-cat drift) 全部经 `gh api repos/acon96/home-llm/contents/...` 实读源码 cite-verify 通过 |
| home-llm 实读 | `train/README.md` (7.7K) + `data/README.md` (5.1K) + `generate_data.py` (41K, line 32/181/370/468/542/563/569/616/621/629/684/690/853-859 全核) + `evaluate.py` (15.8K) + `tools.py` (28K) + `devices.py` (12K) + `gemma3-270m.yml` (3.1K) + `functiongemma-270m.yml` (16.1K) + `docs/Model Prompting.md` (10.6K) + `docs/Setup.md` (13.3K) |
| MAformac 实读基线 | `roadmap-2026-06-20-from-c6-done.md` (24.9K, 232 line) + `c5-recovery-2026-06-22/roadmap.md` (8.9K, 114 line) + `paradigm-amend.md` (63.7K, 496 line — 含 §14 562 终拍 / §16 4 批 grill / §17 A2 codex check / §18 锦标赛拍板) + `handoffs/2026-06-23-doc-cascade-pushed-a2-refactor-dispatch.md` (4.2K, 27 line) |
| A2 PR #3 状态 | OPEN · MERGEABLE · 22 commits · 348 文件 · +70,084/-46,241 · APPROVE (有条件) — 见 `pr_audit_3.md` |
| Head SHA (A2) | `80dba834165faf96e3d62cc49ccb1c0afb399f31` |
| 本档定位 | retrain-c5 / rebuild-c6 propose 启动前的研究档 + 决策弹药. **非 SSOT 改写**. |

---

## §10 起手第一步 (本档读完后 — Codex 2026-06-23 二审纠偏)

> 🔴 **顺序铁律**: A2 已结束 ≠ Phase 0 路线债已清。下一步**不是 retrain propose, 不是 base recalibration spike**, 而是 **Phase 0 清 non-UIUE P0 grill 债**, 否则复刻 0/34 大败逃模式（"文档看起来已经拍板, 所以直接进入训练"）。

### Phase 0 — 立即做, 防止路线错误（**1-2 周内, 不开训**）

1. **确认本档身份**: research / pre-propose checklist, 不是 SSOT（已加 banner, 见文首）。
2. **清 non-UIUE P0 grill 8 题**（按依赖序）:
   - **Q04** full/demo codegen artifact 边界 — `grill-master.md:59`
   - **Q08** archived specs MODIFY 判定 — `grill-master.md:63`
   - **Q12** Pocock 各阶段重新分诊 — `grill-master.md:67`
   - **Q16/Q17/Q18** SRD CAS2 / L1-L2 action matrix / runtime outcome 字段 — `grill-master.md:71-73`
   - **Q20** D1-D37 manifest keep/modify/superseded/defer — `grill-master.md:75`
   - **Q21** baseline-semantic-protocol MASTER banner — `grill-master.md:76`
   - **Q06↑** mid-training gate 物理化（Codex 升 P0, 防 0/34 直接刹车）— `grill-master.md:61`
   - **Q24** held-out 多轴切分 — `grill-master.md:79`
3. **P1 收尾**: Q07 stale anchors grep / Q09 verify-cross-section 扩 / Q23 frozen recipe evidence。
4. **本档 7 项 gate 转写**: §4 P0-1~P1-7 写进 `retrain-c5` / `rebuild-c6` OpenSpec change `proposal.md` + `tasks.md`, **不要作为单独 spike 项**（Codex 纠偏: 它们是 propose 的内容, 不是 propose 的前置）。

### Phase 1 — 主线必须闭环（Phase 0 完成后才启动）

5. 重写 `retrain-c5-lora-d-domain` / `rebuild-c6-four-layer-bench` 执行顺序: **D-domain base recalibration 先于 LoRA candidate** + **training stack tiny spike 先于正式训练** + **endpoint/iOS smoke 并行不污染 data recipe**。
6. A2 PR #3 闭合 P1-CI / P1-Receipt（见 `pr_audit_3.md`）— 与 Phase 0 并行, 不阻塞。

### Phase 2 — C5/C6 恢复与验证

7. D-domain data recipe: template leg + cloud leg + factors + held-out split (§4 P1-5/6/7)。
8. LoRA 训练用 mid-gate 50/100/150 异常即停 (§4 P1-4)。
9. C6 four-layer bench: train-health / model-quality / endpoint / readback **分开签**, 不混成一个 V-PASS。

### Phase 3 — 真实训练 / 真实评测 / demo-golden-run

10. 只有 C5/C6 contract 绿后才进入真实训练 / 真实评测 / voice / demo-golden-run。
11. A2 deferred 项不要提前当遗漏修。

### Phase 4 — UIUE 合流条件

12. UIUE 只在 state contract 对齐后合流。合流前确认 `tool → IR → state_cell → card → patch` 链路一致。
13. golden-run IDs 与 C6 case IDs 稳定后再让 UIUE 承接演示层。

### 关键纠偏（Codex 二审）

- **base 10/23 处理**: 不是"完全失效", 是"**不再作为 D-domain candidate gate, 但保留作历史失败 anchor**"。新增 D-domain base anchor (P0-2) **并行存在**, 不抹掉旧锚——否则丢"为什么败"对照证据。
- **mid-training gate 升 P0**: §4 P1-4 升级为 retrain hard gate 前置, 不要等训练完才审计（0/34 大败逃直接刹车）。
- **C5 recovery roadmap 拆 3 份**（Codex §6 建议）: C5 技术恢复 + post-A2 model-quality (本档) + UIUE 分支。旧 `c5-recovery-2026-06-22/roadmap.md` 顶部加 historical banner, 指向 grill-master + 新 OpenSpec changes（**纳入 Phase 0**）。

> **铁律提醒** (claim-vs-reality + 文档先行):
> - 不记录的决策 = 未来 grill 时被当事实 (像 534 vs 562 反复)
> - 训练数据 SSOT 同源 = 防 0/34 复发的命门, 不可缺
> - demo 取巧 ≠ 配方取巧 — 砍全覆盖可以, 砍 masking/配比/双腿/异源 judge 不行
> - "声称完成" ≠ "事实完成" — 每个 spike 必须实跑产物文本, 不接受 metadata 声称
> - 🔴 **最危险的坑**: "文档看起来已经拍板, 所以直接进入训练" — 这正是 C5 0/34 败逃的模式（Codex catch）

---

**END — 全文 ~6500 字, 双源融合, 全部 file:line cite-verify pass.**
