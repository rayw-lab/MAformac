---
status: baseline_blueprint_active
artifact_kind: pre_lora_to_trained_candidate_loop_blueprint
authority: baseline_birdview（训练闭环鸟瞰权威；单点细节以 grill SSOT / landing-matrix §3 / spec 为准）
created: 2026-07-02
author: claude-commander
as_of: main=ab355f6c + wave-1 分支（gate2 fix `47ca8cda` 双审 CONFIRMED / gate8 `64c6f62f`）
evidence: L2-hf-skills-teardown.md + L3-lora-loop-materials.md（2026-07-02 runs/2026-07-02-baseline-roadmap/）+ commander 亲核（D-015）
companion: docs/baseline-roadmap-2026-07-02-pre-lora.md（树/合并路线，姊妹篇）
caveat: L3 §1 引用的 grill 树 landing-matrix 为 wave-1 前旧快照；本文 gate 现状以主树 landing-matrix §3 reconcile 为准
expires_when: 任一 gate 状态变化 / tiny-ablation 真跑后 / candidate signoff 后必刷
---

# LoRA 训练闭环鸟瞰图（此时此刻 → 训练结束）

> 一句话：闭环 = **「生成→门→小样裁决→正式训→行为中门→C6 四层评→candidate 裁决」的循环**，每一环都有 grill 已决的 fail-closed 门与 0/34+θ-α 防线；模型侧终点 = **signed candidate（C6 action hard_pass 相对 base 10/23 不退化且超越）**，流程侧终点 = 磊哥 candidate signoff。**没有任何一环允许「直接训会成」的信念**（D-003）。

## §0 压舱石：两次惨败 + 北极星

- **0/34（C5 PR5）**：九处失守——假删工具（metadata 声称）/ 检测器读同一 metadata 循环失守 / tool surface 双分叉 / scorer 双口径 / empty=hit / name-last / 数据门缺 label_conflict / spec 只要求 metadata / 审计只审合规。防线映射全表见 L3 §8.1。
- **θ-α**：loss 数值健康但 action 行为全塌（generated-positive 全 checkpoint FAIL）——train-health ≠ model-quality，surface 未同源就训。
- **wave-1 新证**：gate2 masking 假 enforce（loss_mask dead field，0/34 精确同构）被对抗审计在**训练前**拦下 → 修复后双异源 CONFIRMED。**这个循环体系已经证明过一次自己的价值。**
- 北极星（CLAUDE §1）：客户现场 5 分钟，听懂中文、反应快、不崩、断网能跑。LoRA 的唯一使命 = L2-L5 慢路「听懂模糊说」。

## §1 8 gate + 2 裁决门真实态（2026-07-02，以 landing-matrix §3 为准）

| # | 门 | 真实态 | 备注 |
|---|---|---|---|
| gate1 训练循环真跑 | ⚠️ 机制建好，完整实跑 = R7 边界 | `clipped_train` + finite-stop + metrics 就位；formal 真跑等 run-auth |
| gate2 masking enforce | ✅ **fix CONFIRMED**（分支，待 M1-α 合并） | token-level `maformac_masked_loss` 真消费；残留 P1 = 真 Qwen batch dump（R7-gated，fail-closed）+ P2 反向 guard（数据含 loss_mask 而 flag 缺失→fail，合并前建议补） |
| gate3 surface preflight ≥80% | ✅ | exit65 四方同源（θ-α 后立） |
| gate4 scale-authority=20 | ✅ | 工厂 `rank16Mainline` enforce |
| gate5 六轴 held-out | ✅ construction（main `aa1adf8f`） | parent/device/tool/value_type/template/generator_source |
| gate6 C6 四层阈值化 | ✅ construction（main `696676ba`） | 分母 case 覆盖 fail-closed（交叉审抓假绿后修） |
| gate7 云 generator+异源 judge | 🟡 **design merged，代码未闭环** | 唯一剩余大块 R7-safe construction（见 §4 节点 C） |
| gate8 工具数 value-form 实算 | ✅ 562（分支，待 M1-β） | + E-2 硬发现（🔴 2026-07-02 **真 Qwen3-1.7B tokenizer 实测**，商队各估算 74-138k 全部作废）：562 工具目录 compact JSON = **126,275 tokens** / default = **159,899 tokens**（tokenizer 自身报警超 131,072 上限）→ 562 全集**任何** context 配置装不下，10 族 scoped subset + 受限解码是数学必然非取巧 |
| 裁决-A tiny ablation | 🟡 harness 已建（main），**RUN = R7 等磊哥④** | empty 28/34→<5/34 才许声称范式修复 |
| 裁决-B positive-not-diluted | ✅ construction（main，随 gate6） | action 轴独立 fail-closed + OOD 探针 |
| R-L17 | route-only signed（**2026-07-15 到期**）；candidate unsigned | 真训/真生成/真评测全 BLOCKED |

## §2 闭环总图

```
【R7-safe 剩余 construction】          【R7-gated 循环体（每步磊哥授权点标 ✍️）】
 M1 consolidation（姊妹篇 §2）
 C: gate7 pipeline 代码闭环 ──┐
 E-2 subset 策略拍板 ─────────┤
                              ▼
              ┌──[✍️ ④ tiny-ablation run-auth]
              │   裁决-A 真跑：20-50 样本，empty 28/34→<5/34
              │   ├─ FAIL → Dim10 failure-branch（F-076~095）：范式归因，禁放宽口径绕过 → 修 → 重跑
              │   └─ PASS → 范式修复声称成立
              ▼
   ┌────────────────────────【数据 wave 循环】────────────────────────┐
   │ ①生成（gate7）：多源 LLM 产 utterance（Claude 主力）              │
   │    label/gold 走 C1 契约 deterministic（D-031）                    │
   │    异源 judge = GPT-5.5，vendor-enum G1 门 judge≠generator（A-096/097）│
   │    quota 混合公式（D-096/097）+ 稀疏族地板 scene-trigger（D-098+E-113）│
   │    precision 门：每族人审 min(50,max(20,10%))，<0.8 停该族（E-098/129）│
   │    旧 3804/4306：TEXT 可救、verdict 作废重判（M4 reconcile）        │
   │    bug 1730 只作 weak shortlist，原文不进 train/云 prompt（E-096/097）│
   │ ②数据门（gate5+2+3）：六轴 held-out 硬切 / must_not_train+C6 保护   │
   │    命中即 blocked / label_conflict P0 / masking preflight fail-closed│
   │    （trainable_tokens=0→exit66）/ surface ≥80% 否则 exit65          │
   └──────────────┬──────────────────────────────────────────────────┘
                  ▼
        [✍️ candidate signoff 前置：8 gate 全✅ + 裁决A/B + 异源审 + 人审清单
         （F-089/091：R1-R6 一手证据 {file:line/row-id,verdict,异源判官}）
         + explicit run auth（F-092/094：4 模型一致 PASS 不自动放行）]
                  ▼
   ┌──────────────【训练→评测循环（获授权的 formal run）】──────────────┐
   │ ③训练（gate1/4）：rank16Mainline（rank16/scale20/LR1e-4/warmup8%/  │
   │    AdamW+wd/gradClip1.0）+ repo loop（preclip/postclip 证据、        │
   │    NONFINITE 熔断=stop 非能力证据 A-065/066）                        │
   │    行为中门（mid-gate）：不用 val loss 当行为绿（θ-α 教训 A-012），  │
   │    checkpoint 生成 C6 样本行为探针，alert→continue/pause/stop        │
   │ ④评测（gate6+裁决B）：C6 四层各自 fail-closed                        │
   │    golden 100% / demo_fuzz 80%（核心族不许全灭）/ unsupported 100% / │
   │    safety 100% 一票否决（E-002~006）                                 │
   │    action 轴独立：ToolCall set exact + state_delta_match（E-007/009）│
   │    positive-not-diluted + OOD 探针（F-043）；judge 不许洗白 hard gate │
   │ ⑤candidate 裁决：base 锚 action hard_pass 10/23，相对不退化且超越；   │
   │    in-memory/reload/fused/4bit/mlx-swift parity（A-081/086）；        │
   │    lora_B norm>0 防 no-op（A-091）                                   │
   │ ⑥FAIL → Dim10 failure-branch 归因（数据?配方?surface?）→ 回①或③     │
   │    禁「放宽阈值/换口径」式收敛                                        │
   └──────────────┬──────────────────────────────────────────────────┘
                  ▼
        ⑦PASS → [✍️ candidate signoff（R-L17 终拍）] → signed candidate
                  = 训练闭环终点；解锁下游（C6 acceptance→golden→voice→UIUE merge，各自独立授权）
```

**循环读法**：内圈「⑥FAIL→归因→回①/③」是常态预期，不是异常——预算里就该有 ≥2 轮数据 wave 的心理准备；每轮 wave 的产物（receipt/metrics/判例）按 §3 receipt 契约落盘，下轮 wave 站在上轮 receipt 上。

## §3 每次 run 的 receipt 契约（借 HF-skills 循环拓扑，本地化）

采纳 L2 §4 六段拓扑：`preflight → run-manifest → monitor → mid-gate → final-eval → writeback`，全部本地落盘（**不 Hub、不云、不 Trackio**）：

```yaml
run_id: c5-<ts>            # 每次 tiny-ablation / formal run 一个不可变目录
proof_class: local
source: {maformac_head, tool_surface_digest, data_digest, mlx_config_digest}
preflight: {dataset_schema, masking_fixture, surface_overlap>=0.8, resource_estimate}   # 任一 blocked 不起跑
train_health: {loss_curve, grad_preclip/postclip, non_finite_guard}                     # 健康≠质量，只作分账
mid_gate: {gate_type: behavioral, decisions: [continue|human_pause|early_stop|blocked]}
final_eval: {c6_four_layer: per-layer pass/fail, action_axis_vs_base_10_23, parity}
writeback: {local_artifact_dir, status: train_health|lora_candidate|blocked}
non_claims: [not_v_pass, not_mobile, not_true_device, not_live_api]                     # 措辞带态
```

alert 语义（借 Trackio 形态，本地 JSONL）：`non_finite_loss / grad_spike / behavior_gate_fail / surface_hash_mismatch / leakage_blocked`。

## §4 从此刻到「按训练键」的节点序（与姊妹篇 M 节点正交）

| 节点 | 内容 | 性质 |
|---|---|---|
| **A**（现在） | 磊哥 5 件决策（①masking 岔口 ②E-2 ③grill lock ④ablation run-auth ⑤consolidation） | ✍️ 全 gated |
| **B** | M1 consolidation（gate2/gate8/文档三支 staged PR） | R7-safe，等⑤ |
| **C** | **gate7 generator pipeline 代码闭环**（design→代码：多源调用编排/vendor-enum G1 门/precision 门/receipt——build 不 run） | 🟡 **剩余最大 R7-safe construction**，可派 3 worker，建议 M1 后立项 |
| **D** | E-2 subset 实装（磊哥②拍板后：场景 scoped 工具面 + 受限解码，10 族 subset 进 prompt surface） | R7-safe construction |
| **E** | 裁决-A tiny ablation 真跑（磊哥④） | ✍️ 第一次真跑，闭环体系首次全链路点火 |
| **F** | 数据 wave-1 真生成（gate7 真跑）+ 数据门 | ✍️ 等 candidate signoff 前置链 |
| **G** | formal 训练 + C6 评测循环（§2 ③-⑥） | ✍️ run auth |
| **H** | candidate signoff → **训练闭环终点** | ✍️ R-L17 终拍 |
| 附注 | R7 route-only **2026-07-15 到期**——若 E 前未续签，先补签 | ✍️ |

## §5 巨人肩膀使用矩阵（过去为主 + HF-skills 新增）

> 纪律：⭐>1000 不降级吸收（blueprint-teardown）；**过去已 teardown 的肩膀是主线**，新肩膀只补形态不换 runtime。

### 树内 vendor（`Tools/paper-to-skill-gate/paper-repos/`，代码可直接读）

| 肩膀 | 用在哪环 | 借什么 |
|---|---|---|
| **Hammer**（arxiv 2410.04587） | §2-②masking / gate2 | function/arg masking 思路（比例本地重定）；irrelevance 增广 |
| **xLAM / ActionStudio**（2409.03215 / 2503.22673） | §2-①数据配比 + ③训练编排 | 数据统一格式/train_sft 编排形态（TRL 侧只借形不借栈） |
| **When2Call**（2504.18851） | §2-④评测 no-call 轴 | call/no-call/clarify/cannot-answer 判定拆轴 |
| **SemDeDup**（2303.09540）+ **llm-decontaminator**（2311.04850） | §2-②gate5 held-out | 语义近邻防泄漏 + paraphrase 去污（heldout receipt 用） |
| **TinyAgent** | E-2 subset 参考 | 小模型工具面裁剪先例 |

### raw 只读区（`~/workspace/raw/05-Projects/MAformac/ref-repos/`）

| 肩膀 | 用在哪环 | 借什么 |
|---|---|---|
| **home-llm**（teardown 档 ×2） | §2-①数据配方 **权重最高** | 5 类样本（static/templated/status/failure/refusal）/模板随机参数/distractor/train_on_turn masking/配比倍率 |
| **gorilla（BFCL）** | §2-④C6 覆盖轴 | simple/multiple/parallel/irrelevance/format 类别吸收进 demo_fuzz（**不搬分数**；arxiv 诚实 TODO） |
| **tau2-bench**（2506.07982） | C6 之后多轮/voice（**非 C5 hard gate**） | 后续档 |
| **mlx-swift-lm / mlx-swift-structured** | 端侧 parity（A-081/086） | fused/4bit/mlx-swift 加载一致性 |
| **hf-skills**（⭐10753，pushed 2026-07-01，已增量 fetch 至 `35e8c35`） | §3 receipt 契约 **本次新增** | 见下 |

### HF-skills 新肩膀的裁决（L2 teardown 结论，一句话版）

**借循环拓扑与纪律，不借 runtime**：preflight→manifest→monitor→mid-gate→final-eval→writeback 六段形态 + dataset_inspector 改造成本地 `c5_dataset_inspector`（字段换成 route_tier/masking_stage/train_eligible/tool digest）+ 成本估算器改本地 Apple Silicon 资源门 + Trackio alert 语义改本地 JSONL。**Drop**：hf_jobs 即时提交（R7 违禁）/ Hub push 与 token（隐私+proof-class 混淆）/ Unsloth CUDA 路径（本项目 MLX）/「eval 写回模型主页」当验收（截图宣传语在 repo 一手面只部分成立——不能替代 C6 diff + R-L17）。

### 论文层（Dim5 A-134~150，11 arxiv 全核真）

top10 映射表见 L3 §7（Hammer/lr-matters/When2Call/SemDeDup/decontaminator/GOAT/tau2/hybrid-think/Instruct-SkillMix/ALTO→各自支撑的 gate + 使用边界）。铁律：**论文只支撑纪律与假设，不替代本地 gate**（A-140s 系）；BFCL 无 arxiv 显式 `TODO-no-arxiv-found` 不编号。

## §6 本文的维护（derived-tracking）

- 任一 gate 状态变化 / 节点 A-H 推进 → 刷 §1/§4 + 姊妹篇 §0。
- tiny-ablation 真跑（节点 E）= 里程碑 → receipt 按 §3 落盘 + 本文 §1 裁决-A 行改真实结果。
- candidate signoff（节点 H）→ 本文转 historical，新基线文档接棒。
