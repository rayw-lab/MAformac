# Lens 16 — 治理 / 权威 / pass 口径 / stop-the-train / deferred 矩阵（一手档）

> **维度**: 横切治理（P0），本地 read-heavy 为主。把 Phase 0 24 grill 的治理子集（C01-C08 / C21-C24）梳成 5 张矩阵。
> **边界**: pre-propose decision-pack，纯搜证 + 假想验证。治理类产出落 docs/research，不碰 runtime contracts/（acceptance C02 guardrail）。
> **日期**: 2026-06-24 · **核验**: 本地一手源逐文件 read + 2 web 搜证背书 + swift code 锚 + rank16Mainline factory 实读。

---

## 0. 核心结论（3 句）

1. **这套治理 5 矩阵已基本物理化** 在 `docs/project/phase0/`（C02/C03/C04/C05/C06/C07/C24 schema YAML + subagent 审计 CLEAR），我的活 = 把它们当已落地骨架核实 + 补 stop-the-train/deferred 因果链 + web 背书。
2. **治理路本身不直接防 0/34**——它防的是「在错误授权/scope/阶段/假 pass 口径下启动训练」这个**元层 meta-failure**，是 0/34 复发的【组织性闸门/必要条件】，技术闸门（C13/C14/C17/C18）才是直接 prevents。
3. **贯穿风险 = declare≠enforce 缺口**：当前矩阵是 schema skeleton（YAML prose 字段），未接 make verify/CI/cite-verify hook，全靠 agent 自觉读。若不接机械门，治理同 0/34 第10坑（metadata 声称未 code enforce）。

---

## 矩阵 ① — 权威矩阵（谁是 SSOT）

| 文件 | role（C02 role_enum）| allowed_claims | forbidden_claims | banner_action |
|---|---|---|---|---|
| `CLAUDE.md` | current_entrypoint_and_constitution | 项目宪法 + 起手路由 | — | verify_pointer_consistency |
| `docs/grill-tournament/grill-decisions-master.md` | **decision_ssot** | grill 决策唯一权威（§2 状态 + §4 晶体）| 不复制正文 | preserve_as_grill_decision_authority |
| `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` | **surface_authority** | 范式翻案 + D-domain surface 正文权威 | — | preserve |
| `docs/grill-tournament/cascade-inventory.md` | **doc_inventory** | 文档级联总账（哪些文件要改）| **不当 decision_ssot** | preserve_as_inventory_not_decision_ssot |
| `openspec/changes/retrain-c5-lora-d-domain` 等 4 change | **future_contract_carrier** | DRAFT 待 propose | **不当 archived spec** | keep_draft_until_propose |
| `docs/roadmap-2026-06-20-from-c6-done.md` | **historical** | 五件套 harness 骨架溯源 | **不当 live progress SSOT** | ensure_banner_points_to_current_authorities |
| `docs/c5-recovery-2026-06-22/roadmap.md` | **historical** | 上下文 | 不当 live roadmap | add_or_update_historical_banner |
| `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md` | **decision_pack** | pre-propose checklist | **不当 live fact source** | preserve_pre_propose_checklist_boundary |
| `docs/uiue-roadmap-2026-06-23-draft.md` / `uiue/visual-ssot-state-consume` | **branch_consumer** | UIUE 计划 | **不定义 mainline state/C6 ID** | consume_stable_state_and_golden_contracts_only |

> **source**: `docs/project/phase0/c02-authority-matrix.schema.yaml:23-101`（role_enum 10 值 + seed_targets + validation_rules）+ `grill-decisions-master.md:9-18`（SSOT 声明：三份并存 grill 清单 → 单源收口，§35 + Q22 + claim-vs-reality 第10变体）+ `final-list.md:18`（C02 score 21.83 P0）。
> **关键 validation**: `every_seed_target_has_exactly_one_entry` + `historical_must_not_claim_live_progress_ssot` + `decision_pack_must_not_claim_live_fact_source` + `branch_consumer_must_not_define_mainline_state_or_c6_ids`。
> **Web 背书**: SDD 单源权威谱（spec-first → spec-anchored → spec-as-source），ADR 是 living record of intent。[Thoughtworks SDD](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices) · [IBM SDD](https://www.ibm.com/think/topics/spec-driven-development)。
> **vs baseline**: vs 旧 3 份 grill 清单并存（GOV3 实证分叉源 534/418/缺486）= **better**（role_enum 强制每文件一个角色，机械防 dual-SSOT）。

---

## 矩阵 ② — Pocock/OpenSpec stage 矩阵（每 follow-up 阶段 + exit + forbidden_next_action）

**stage_enum（11 态）**: intake / grill / design / spec / propose_ready / apply_ready / apply_in_progress / archive_ready / archived / historical / deferred

**forbidden_next_action_enum（9 项）**: start_retrain / run_base_recalibration / compare_lora_candidate / freeze_data_recipe_values / claim_endpoint_ready / claim_v_pass / execute_demo_golden_run / merge_uiue_mainline / edit_archived_spec_directly

| workstream | carrier_kind | openspec carrier | 当前 stage（待 C05 fill）| forbidden_next_action |
|---|---|---|---|---|
| A2 D-domain surface | merged | PR#3 (main) | archived | edit_archived_spec_directly |
| retrain-c5-lora-d-domain | active_openspec_change | `openspec/changes/retrain-c5-lora-d-domain` | **propose_ready 待 grill**（DRAFT）| **start_retrain**（禁直到 propose+exit_evidence）|
| rebuild-c6-four-layer-bench | active_openspec_change | `openspec/changes/rebuild-c6-four-layer-bench` | propose_ready 待 grill | run_base_recalibration |
| endpoint-parity | not_yet_assigned | TBD | design 待分诊 | claim_endpoint_ready |
| demo-golden-run-entry | active_openspec_change | `define-demo-golden-run-and-voice` | spec 待 | execute_demo_golden_run |
| uiue-state-consumption | future_branch_ref | `uiue/visual-ssot-state-consume` | branch_consumer | merge_uiue_mainline |

> **source**: `docs/project/phase0/c05-pocock-stage-matrix.schema.yaml:23-78` + `final-list.md:21`（C05 P0）+ `grill-decisions-master.md:67`（Q12 Pocock 重新分诊待 grill）。
> **核心作用**: 把『看着决定了→启动训练』的 **0/34 元层根因 GOV6** 机械化拦截——forbidden_next_action 是每 workstream **必填字段**，C05 boundary.not_permission_for 显式列 apply_training/claim_v_pass/run_real_model_quality_eval/execute_demo_golden_run。
> **Web 背书**: ADR 状态机 proposed→accepted，governance ties decisions to enforcement（reviews/tests/CI fitness functions）。[em-tools ADR](https://www.em-tools.io/frameworks/architecture-decision-records) · [AWS ADR process](https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/adr-process.html)。
> **vs baseline**: vs C5 codex 0/34（无 forbidden_next_action，codex 自主跑通宵才暴露）= **better**。

---

## 矩阵 ③ — pass 口径词表（C24 定向蕴含图，禁互相冒充）

**status_ids（11）**: data_ready / train_health / lora_candidate / g6c_diagnostic / c6_model_quality / endpoint_candidate / demo_golden_ready / T_PASS / V_PASS / S_PASS / U_PASS

| status | definition（C24 required）| 实测 evidence | **禁蕴含（not_implies / graph_rules）** | code 锚 |
|---|---|---|---|---|
| **train_health** | 训练跑对了（loss 收敛/无 NaN/infra 稳）| metrics.jsonl + NonFiniteTrainingError 守护 | **不 imply model_quality**（0/34 灾难本体：codex 诚实报 0/34=合规 PASS，没人审此边）| `C5LoRATraining.swift:324` clip |
| **c6_model_quality** | C6 Mac 离线评测（held-out/test）| C6GateResult.hardPass | **不 imply V_PASS / endpoint_candidate** | `C6VehicleToolBench.swift:607` gateResult |
| **g6c_diagnostic** | 根因诊断（区分 surface mismatch vs zero-negative collapse）| θ-α 0/23 anchor | 诊断 ≠ 修复 ≠ pass | — |
| **endpoint_candidate** | 端侧候选 | render_parity_diff=0 + endpoint smoke | **no status may imply endpoint_candidate without endpoint evidence**（真机/parser/whitelist/LoRA load/TTFT-memory receipt）| — |
| **demo_golden_ready** | 五幕 golden 100% 硬门 | contract refs + c6_case_id | **不 imply uiue_acceptance without state_contract** | — |
| readback（嵌 C06）| 端 renderer 出话术 | — | **readback_result 必区分 renderer vs model output**（第7坑变体）| `TraceLogger.swift:17` TraceReadbackResult（pending/failed/unknown/mismatch **不得当 verified**，注释明文）|
| **历史 10/23 anchor** | 旧 base 失败锚 | — | **historical_10_23_anchor_must_not_be_active_candidate_gate**（C17：保留作历史失败证据，不当 D-domain 候选硬门）| — |

> **source**: `docs/project/phase0/c24-status-vocabulary-graph.schema.yaml:25-64`（graph_rules + required_fields_per_status: implies/not_implies/blocks/blocked_by）+ `grill-decisions-master.md:96`（Q41 验收分层禁互相冒充）+ swift code 锚（`DemoVehicleStateStore.swift:17-24` DemoVisualState 7 态 / `TraceLogger.swift:17-27` TraceReadbackResult 6 态 / `C5LoRATraining.swift:3-7` C5RouteTier）。
> **Web 背书（强）**: ML 三层 pass 标准 disambiguation——Train Health=run valid（非 model good）/ Model Quality=best offline（非 deployable）/ Production Readiness=authorized safe。「passing a training run cleanly says nothing about model quality, strong offline model quality says nothing about production readiness」。[evidentlyai model monitoring](https://www.evidentlyai.com/ml-in-production/model-monitoring) · [codecentric quality gates](https://www.codecentric.de/en/knowledge-hub/blog/evaluating-machine-learning-models-quality-gates)。
> **vs baseline**: C24 的 `train_health_must_not_imply_model_quality` 边**就是 0/34 灾难的机械答案**——codex 诚实报 0/34=合规通过审计（train_health PASS），但没一轮审 train_health≠model_quality 直到 C6 暴露。Web 确认这是 MLOps 标准非 MAformac 自创 = **better**。

---

## 矩阵 ④ — stop-the-train 风险矩阵（治理核心交付物，按能否提前阻止 0/34 排序）

> 6/18 路完整（L01/L02/L03/L05/L06/L15），12 行风险 partial。**C14 mid-training gate 四态决策权威 = continue | human_pause | early_stop | blocked + receipt actor/decision/timestamp**。

| # | 风险 | stop 阈值 → 动作 | owner | 需磊哥拍板 | P |
|---|---|---|---|---|---|
| R1 | **中途无行为门，通宵跑完才暴露 0/34**（GOV6 根因）| golden 抽样 0/5 或 fuzz<base 相对门 → **early_stop**；边界(2/5) → **human_pause** | 训练脚本/CI（**infrastructure-enforced 非 codex 自审**）| **是**（C14 阈值/四态/谁有权停）| **P0** |
| R2 | train/eval/runtime tool surface 异源（0/34 真根因）| 三方 surface hash diff≠0 → **blocked** | A2 ToolContractCompiler 消费方 | 否 | P0 |
| R3 | chat-template byte-parity 失守（think 块 offset 漂）| endpointBytes≠trainingBytes → **blocked** | retrain-c5 gate | 否 | P0 |
| R6 | LR 回 2e-4 / 未守 repo-loop clip → loss 尖刺（iter70-80 实测 spike 17-32）| val 非 finite / spike>阈值 → **blocked**（NonFiniteTrainingError 守护）| retrain-c5（配方冻结）| 否 | P0 |
| R7 | 约束解码掩盖语义塌缩（grammar 强制合法但选错工具）| 约束下 action 正确率≪无约束 / 拒识被阉割 → **human_pause** | golden-run（DEFERRED）| **是**（C20 GBNF fallback only）| P1 |
| R9 | 100% 合成数据 model collapse（>30% 自由合成降 8-15%）| 全自由 LLM 生成无确定性 → **human_pause** | retrain-c5 数据 | **是**（C12 配比 hypothesis 待 spike）| P1 |
| R11 | **门本身假绿成第11坑**（receipt 写 PASS 是 metadata）| grader 挂 → candidate UNSIGNED 不降级签（sign-or-block）| CI/harness | 否 | P0 |
| R12 | 训练栈跑不动（OOM）| peak 逼近 32GB → 降 seq/--grad-checkpoint | retrain-c5 | 否（**paper-tiger**，硬件从来非瓶颈）| P2 |

> **source**: `docs/research/2026-06-24-lora-zero-failure-deepdive/stop-the-train-matrix-partial.md:10-23`（R1-R12）+ `acceptance-archive.md:53`（C14 四态 + receipt actor/decision/timestamp）+ `final-list.md:30`（C14 P0）。
> **Web 背书（强）**: 双层 divergence 检测——alert tier（narrow window/low threshold → level-1 notification）/ restart tier（wide window/strict threshold → auto restart），rollback to known-good checkpoint，guard against false positives（high-but-stable plateau）。这**正是 C14 四态的业界映射**（alert tier≈human_pause / restart tier≈early_stop/blocked）。「gate on task accuracy not just perplexity」（over-memorization 使 perplexity 停太早）= R1 禁只读 val_loss。[ByteDance robust training infra](https://arxiv.org/html/2509.16293v4) · [over-memorization in finetuning](https://arxiv.org/pdf/2508.04117) · [GradES early stopping](https://arxiv.org/pdf/2509.01842)。
> **vs baseline**: vs C5 0/34（通宵跑完无中途行为门）= **better**。

---

## 矩阵 ⑤ — D1-D37 决策状态（C07，keep/modify/superseded/defer）

**status_enum**: keep / modify / superseded / defer / historical_anchor / needs_user_decision
**铁律**: `do_not_bulk_reopen_d1_to_d37`（只碰被 D-domain/4层C6/endpoint/state-golden/status 触及的）+ `untouched_decisions_must_not_be_reworded` + `d_domain_surface_changes_must_be_marked_as_surface_not_ir_replacement`

| 决策 | old_claim | 触及 | new_status | 依据 |
|---|---|---|---|---|
| **D14** | ASR sherpa 主 | endpoint/voice | **modified** | 已 amend：SFSpeechRecognizer 系统识别主 + sherpa/Whisper fallback 不砍（`grill-decisions-master.md §4.6`）|
| **D16** | 端态 8→102 原子能力 | D-domain surface | **modified** | 范式翻案：model-visible = D-domain 具名工具，canonical IR 仍 device×action（surface 改非 IR 替换）|
| **D30** | 训练栈 adopt unsloth+Hammer+xLAM | retrain | **modified/defer** | 守本机 mlx-lm 0.31.1 + rank16Mainline（unsloth 要 CUDA，Mac 无 N 卡）|
| **D35** | must-pass → 全集覆盖率双轴 bench | 4 层 C6 | **modified** | C6 四层独立门（golden 100% / fuzz / unsupported / safety），不合 pass_rate |
| **D37** | 安全门 → risk-policy 单源 | safety/F1 | **keep + 强化** | risk 独立不当 model-visible tool（F1 错误增量已撤）|

> **priority_seed**: D14/D16/D30/D35/D37（其余 D 未触及，**不 reopen**）。
> **source**: `docs/project/phase0/c07-decision-lifecycle-manifest.schema.yaml:20-55` + `cascade-inventory.md:122`（D16/D30/D35/D37/D14）+ `grill-decisions-master.md:75`（Q20 D1-D37 manifest 待 grill）+ `CLAUDE.md §4 v2 重审`。
> **Web 背书（强）**: ADR 不可变律——never delete/modify original，supersede via new record，「Update the original ADR's status to superseded by ADR-XXX. This preserves the historical record」。[joelparkerhenderson ADR](https://github.com/joelparkerhenderson/architecture-decision-record) · [MADR 4.0](https://adr.github.io/madr/)。C07 的 `untouched_decisions_must_not_be_reworded` 正是此律。
> **vs baseline**: vs 旧『批量 sed 全仓替换』冲动（doc-cascade-triage 反模式）= **better**（do_not_bulk_reopen 防误改 untouched）。

---

## deferred 边界（哪些 A2 后才能动，不能提前）

| deferred 项 | 边界声明（三处一致）| 解冻 trigger |
|---|---|---|
| **C5 数据生成** | A2 = code-only，不生成语料 | retrain-c5 propose 拍板后 |
| **C5 实际重训** | acceptance 不启动 retrain | held-out 轴 + mid-gate + base anchor + C6 分母全在 |
| **C6 四层门 + 真评测** | 不评测模型性能 | rebuild-c6 propose |
| **demo-golden-run 执行** | entry contract 是 deferred execution | stable tool/IR/state_cell/card/C6 IDs |
| **voice（ASR/TTS）** | A2 后独立立项 | define-demo-golden-run-and-voice propose |
| **受限解码 vendor** | C20 GBNF fallback only | 端侧无 GBNF，先 LoRA 格式 + JSON 三层防御解析 |

> **source**: `acceptance-archive.md:20`（deferred boundaries 6 道）+ `cascade-inventory.md:5`（A2 边界 = code-only，终点落老 C5 训练之前不训练/不评测/不生成语料）+ `final-list.md:64-67`（Do Not Do）+ 各 schema `boundary.not_permission_for`。
> **C11-C12 配比 = hypothesis 待 spike**（positive=20/unsupported=8/safety=4/followup=2 建议起点，不拍死生产值）。
> 🐘 **elephant**: 解冻判据散在 3 处（措辞一致但无单一 deferred-release-criteria manifest），risk = 未来 session 各引一处 drift。建议 C05 补 deferred workstream 的 exit_evidence=解冻判据单源。

---

## 假想验证（5 类越界 + 矩阵如何防）

详见 hypothesis_verification 字段。整体判定 **better**（5 类越界全覆盖 + 0/34 复盘背书 + 业界标准支撑），但贯穿失败模式 = **declare vs enforce 缺口**：当前 5 矩阵是 schema skeleton（CLEAR audit），未接 make verify/CI/cite-verify hook，全靠 agent 自觉读。若不接机械门，治理同 0/34 第10坑。

---

## Pre-mortem 三分类（详见 premortem 字段）

- **Tiger**（3）: ① 治理停 declare 层未 enforce（同第10坑）② C14 stop authority 若 agent 自审/门假绿（R11）③ 562 intent 被当工具数硬编。
- **Paper-tiger**（3）: ① 训练栈 OOM（本机坐实 11.4-12.2GB no_oom，P2）② PEFT 新论文重开配方（任务不同不可跨任务外推，DEFERRED escape-hatch）③ 24 grill 治理膨胀（acceptance 已结构性消解，收敛到先做 7 个）。
- **Elephant**（3）: ① 治理是必要非充分，prevents_0_34 严格 no/间接 ② final sign-off authority（磊哥拍板权）未 schema 化 ③ deferred 解冻判据无单源 manifest。

---

## must_answer 5 答（详见 must_answer 字段）

1. **prevents_0_34**: no（间接）—— 治理是 0/34 的组织性闸门/必要条件，技术闸门（C13/C14/C17/C18）才直接 prevents。
2. **vs_rank16mainline**: support（不碰配方，纯治理；C16 守 rank16Mainline，PEFT 论文是 escape_hatch 不是 reopen 理由）。
3. **requires_a2_surface_change**: no（A2 surface 已合并 main，治理把已做的 surface 改标进决策状态，C07 明文 surface 改非 IR 替换）。
4. **introduces_deferred**: no（本路定义 deferred 边界本身，不执行任何 deferred 内容）。
5. **priority_self**: P0（横切，但 prevents_0_34=间接）。

---

## external_claims（待主线程核 / 已核）

- ✅ **已核（external-claims-verification.md 主线程已亲核）**: ByteDance robust training infra arxiv 2509.16293（双层 tier divergence）/ over-memorization 2508.04117（perplexity 停太早）等本路引用的 web 搜证结果均为 WebSearch 2026-06-24 实搜，非编造。
- ✅ **repo 活跃度已核**: home-llm 1364★ pushedAt 2026-06-11 / mlx-lm 6019★ 2026-06-12 / mlx-swift 1932★ 2026-06-17（external-claims-verification.md:48-58 主线程 gh 核）。
- ⚠️ **本路无新增精确数字声称**：全程守『562=intent 非工具数』『工具数未拍待 value-form 实算』；rank16Mainline 字段（rank16/scale20/LR0.0001/adamw/wd0.01/epochs3/gradClipNorm1.0）= 直读 `C5LoRATraining.swift:1210-1235` factory，非编造。
- 待主线程抽样核：stop-the-train R6『iter70-80 spike 17-32』来自 stop-the-train-matrix-partial（6/18 路），属本机实测引用，建议核 c5_mlx_train_loop.py 历史 receipt。