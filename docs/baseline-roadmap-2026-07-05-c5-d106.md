---
status: baseline_roadmap_active
artifact_kind: c5_d106_completion_baseline
authority: planning_baseline_not_openspec_contract
created: 2026-07-05
as_of_decision: D-106
branch_at_creation: codex/rebuild-c6-doc-absorption-20260624
proof_class: local_static_artifact_synthesis
supplemented_from:
  - /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness
supersedes_for_c5_lane:
  - docs/CURRENT.md R3-in-flight wording（仅 C5 当前态；CURRENT 仍是 router）
  - docs/baseline-roadmap-2026-07-02-pre-lora.md（仅 C5 训练收口路线；树/PR/M2/M4 历史仍保留溯源价值）
non_claims:
  - not OpenSpec acceptance
  - not runtime implementation authorization
  - not data generation authorization
  - not formal 1800 launch authorization
  - not C5 candidate signoff
  - not C6 acceptance
  - not UIUE merge approval
  - not voice/mobile/true-device/V-PASS
expires_when:
  - D-085 qa gate semantics 被正式重拍
  - R5 one-shot pair-boundary verdict 落地
  - runtime query safety gate OpenSpec 被 propose/apply/archive
  - formal 1800 run 启动/停止/完成
  - C5 candidate signoff 或路线转 C
---

# C5 D-106 后基线：后续做什么、分几 phase 到 C5 结束

> 一句话：**C5 现在不是失败，也不是完成；它卡在“动作语义已可用，query/status 安全边界不能继续交给 adapter 独自判断”的阶段。后续主线应是 `runtime safety gate` 优先，R5 数据法只做一次 one-shot falsification experiment。**

## 0. 读取纪律

本文件是此刻 baseline，不是行为契约事实源。执行前仍按项目宪法读：

1. `CLAUDE.md`
2. `docs/commander-log/decisions.md` 最新 D 条，当前以 `D-106` 为 C5 训练路线最新裁决锚
3. run 目录状态板：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/STATUS-BOARD.md`
4. R5 三件一手产物：`R5-SCANNER-HARDENED.md` / `R5-LABEL-AUTHORITY-AUDIT.md` / `R5-STRATEGY-REDTEAM.md`
5. 本轮递归补读外部研究包：`/Users/wanglei/Projects/agent-tmux-stack-research/` 下与 C5/C6/runtime/UIUE/voice/macro/formal launch 相关的 run 文档；`code-basis-pr38-worktree/` 这类镜像代码树只作 basis 线索，不重复当作独立研究结论。

若本文件与 live repo、最新 D 条、run receipt 或 OpenSpec 冲突，后者胜出，并回写本文件或新 baseline。

### 0.1 本轮补读带来的三条修正

1. **真实链路不是 Phase 6 末尾才想的 UI 问题**：W50 证明当前 app live loop 仍是单 AC 默认闭环，缺 full contract runtime bundle、D-domain app path、concrete Qwen/LoRA backend、10 族 state/display bootstrap 和 `RuntimeAdapterMountReceipt`。因此 Phase 2 的 runtime safety 必须同时处理 mount/basis/10-family payload，不只是 query prompt/harness。
2. **R-L17 要收窄口径**：W48/X2 修正为 `route-only R7 signed; candidate signoff unsigned`。这允许 C6 construction lane 提前推进，但不允许 C6 acceptance/comparison、golden、voice、UIUE、V-PASS 或 C5 candidate 晋级。
3. **C6 是两条 lane**：construction/rebuild 可作为并行工程准备；base-vs-LoRA comparison 和 C6 acceptance 必须等 signed candidate + explicit run authorization。L6/R2b 53-case 只能作 seed evidence，不能原样冒充 C6 denominator。

## 1. 当前真态

### 1.1 状态分层

| 层 | 当前状态 | 结论 |
| --- | --- | --- |
| train_health | R2b/R3/R4 都完成 600/600 级别短训，训练过程健康 | 只能证明训练链路健康，不能证明候选可用 |
| A/B/D 行为面 | R3: A14/B15/D23；R4: A15/B15/D21；D-098 后 R2b 有效面 A15/B15/D19 | **动作语义资产强**，小模型能学 actuation 正例和近邻区分 |
| qa 安全面 | hardened expected-empty adapter any_tool_call_fail: R2b/R3/R4 = 9/9/9 | **adapter-only qa 未破**，不能起 formal、不能 candidate signoff |
| 量尺/authority | D-097 mount-invalid 翻案；D-105 scanner + label authority 翻案 | 量尺自身必须先成为硬门，否则战略会被假数字带偏 |
| product safety | runtime guard 尚未以 OpenSpec/实现/receipt 证明 | 只能说方向成熟，不能说已过 runtime safety |

证据锚：

- D-103 R3：A14/B15/D23、qa fail、训练健康 600/600，见 `docs/commander-log/decisions.md:768-772`。
- D-104 R4：A15/B15/D21、qa fail、T1 失败是工具名幻觉非 over-refusal，见 `docs/commander-log/decisions.md:774-780`。
- D-105：scanner 漏计 invalid tool name + `现在音量是多少` label authority 冲突，见 `docs/commander-log/decisions.md:782-791`。
- D-106：hardened any_tool_call_fail = 9/9/9，qa 是模型固有 actuation prior 硬墙，见 `docs/commander-log/decisions.md:794-800`。
- R5 scanner：expected-empty 下任何 observed tool 都 fail；R2b/R3/R4 adapter any = 9/9/9，见 `R5-SCANNER-HARDENED.md:23-37`。

### 1.2 不能再说的话

- 不能说 “R4 已经 C5 完成”：缺 qa safety、缺 formal、缺 candidate signoff。
- 不能说 “R3 到 R4 qa 恶化 8→10” 作为主叙事：D-105/D-106 已把它改写为 hardened 9/9/9，旧 8 是 scanner 漏计 artifact。
- 不能说 “继续加负例/扩大挂载就能解决”：R3 证伪单纯加量，R4 证伪单纯换 mount。
- 不能说 “runtime 兜底 = LoRA 学会了 qa”：proof class 必须写 `runtime-gated qa safety`，禁写 `adapter learned qa`。
- 不能把 formal 1800 当“多训一会就好”：R4 已证明 train_health + A/B/D 好看不代表 qa safety。

## 2. 大鸟瞰图

```
D-106 baseline
  |
  |-- Phase 0: 冻结当前 truth / 更新路由 / 禁止 formal 误起跑
  |
  |-- Phase 1: 量尺与标签权威修复
  |       - scanner hardening 进入正式 gate
  |       - 6 个 primary label conflicts 消掉
  |       - true query / unsupported / action-question 三类分账
  |
  |-- Phase 2: runtime query safety gate（主线）
  |       - OpenSpec 定义 RuntimeQueryGuard
  |       - unsupported query 不挂 mutating tools
  |       - true query 只挂 query_* 或直走 query route
  |       - action-question 仍放 action path
  |
  |-- Phase 3: R5 pair-boundary one-shot（旁线）
  |       - authority-clean
  |       - same mount / same device / same slot
  |       - 问状态 vs 发操作 成对
  |       - 失败即停止 data-only qa 修复
  |
  |-- Phase 4: D-085 gate semantics 重拍
  |       - adapter-only qa=0?
  |       - runtime-gated qa safety?
  |       - dual-track candidate?
  |
  |-- Phase 5: formal 1800 candidate run（若 Phase 4 允许）
  |       - Launch Packet 六件
  |       - host baseline
  |       - watchdog --armed
  |       - eval manifest freeze
  |
  |-- Phase 6: C5 exit package
          - model candidate / runtime safety / proof class 分层 receipt
          - dynamic/fused/quantized parity 规划
          - handoff to C6 / UIUE / voice / demo-golden
```

## 3. C5 “结束”的定义

这里的 “C5 结束” 定义为 **C5 LoRA 阶段可关闭，并把候选交给后续 C6/端侧/演示验收**，不是项目整体 V-PASS。

### 3.1 C5 结束必须满足

| Gate | 必须证明 | Proof class |
| --- | --- | --- |
| G1 model behavior | A/B/D 达锁定门，且无新增工具名幻觉扩散 | local/integration eval |
| G2 qa safety | adapter-only qa=0，或 D-085 经正式重拍允许 runtime-gated qa safety=0 | local/integration/runtime，按路线分层 |
| G3 authority hygiene | scanner hardening + label authority conflict gate 无 P0 | local/static + targeted tests |
| G4 formal candidate | 若仍需要 formal 1800：正式 run 完成、receipt 完整、eval manifest frozen、host/watchdog 证据齐 | local train/eval artifacts |
| G5 candidate signoff | 明确 `lora_candidate` 状态、adapter sha、basis、non-claims；R-L17 只能从 `candidate signoff unsigned` 变为 signed，不能复用 route-only R7 当 candidate signoff | project decision receipt |
| G6 downstream handoff | C6/UIUE/voice 只拿到分层后的候选，不继承假绿 | docs + receipt |

### 3.2 C5 结束不包含

- 不包含 C6 acceptance。
- 不包含 R-L17 candidate signoff，除非另有候选级 human-owner receipt。
- 不包含 UIUE merge 完成。
- 不包含真实 ASR/TTS、mobile/true-device、live API。
- 不包含 V/S/U-PASS。
- 不包含 “客户现场演示最终体验完成”。

这些是 C5 之后的验收或产品化阶段。

## 4. Phase 0 — 基线冻结与误起跑防线

### Goal

让所有后续 worker、commander、新窗口都从 D-106 后态出发，不再从 `CURRENT.md` 的 R3 in-flight 旧状态出发。

### Scope in

- 更新/引用本 baseline。
- 刷 `docs/CURRENT.md` 的 C5 当前态（若另开任务授权）。
- 在后续派单写明 formal 1800 HOLD。

### Scope out

- 不改代码。
- 不生成新训练数据。
- 不训练。
- 不改 D-085 gate semantics。

### Acceptance

- 新派单必须写：`formal 1800 HOLD pending Phase 1-4`。
- 新 closeout 必须分层：`train_health / behavior gate / candidate-product gate`。
- 引用 qa 数字必须用 hardened 四数，不再单报旧 adapter 8/10。
- R-L17 一律写成 `route-only signed; candidate signoff unsigned`，直到候选级 receipt 改写。

### Evidence

- `docs/CURRENT.md` 当前仍写 R3 in-flight，与 D-106 冲突；因此 CURRENT 只当 router，不作当前事实源。
- D-106 已是 C5 训练路线最新 accepted decision：`docs/commander-log/decisions.md:794-800`。

## 5. Phase 1 — 量尺与标签权威修复

### Goal

先让 “判断系统” 自己可靠，再允许任何新数据或新训练进入主线。

### Work items

1. **Scanner hardening 正式化**  
   把 R5 hardened rule 变成 repo 内可复跑 gate：expected=[] 时任何 observed tool call 都 fail；invalid tool name 与 actuation 分账。

2. **Label authority conflict 清零**  
   先处理 6 个 primary qa/qneg/guard 冲突，尤其 `现在音量是多少`：应走 `query_current_volume`，不是 `NO_TOOL`。  
   R5 authority audit 已给口径：改 absent-query counterfactual 侧，不改 qguard/query 侧。

3. **Default-scope canonical 拍点**  
   天窗/遮阳帘类 no-arg vs `position=全车`、`value=LITTLE` 必须统一；这不是模型能学会的“歧义”，是标签一致性问题。

4. **Default-scope current-head gate**  
   W34 证明 default-scope 核心实现和三道机械门在当时 local pass，但历史 receipt 绑定旧 head 且当前树 dirty。候选晋级前必须在最终 candidate head 重跑 `make verify-default-scope` 或三脚本等价门，并把 runtime `scope_origin` 语义和 R2b data 面分账。

   > 🔴 **AMEND（D-109，2026-07-05）**：本项（W34 current-head 重跑）**归 candidate-promotion gate，不是 Phase 1 completion gate**——Phase 1 时尚无 final candidate head（formal 训练才产），此项在 Phase 1 不可满足。**Phase 1 completion 只负责 default_scope canonical 决策（磊哥 LEIGE_KEY）+ label authority conflict 清零（真 manifest rc0）**；W34 current-head rerun 在 final candidate head/data/adapter sha 冻结后（Phase 5/6 candidate promotion）执行。依据 `redteam/phase1-audit-round2-final.md` E + `grill/phase4b-formal-decompose-grill.md §5`。

5. **Gate 输出四分账**  
   `expected-empty any_tool_call_fail`、`actuation_fail`、`invalid_fail`、`query_expected_actuation` 分开报。

### Stop conditions

- 任何 identical input 在同一 train/eval 面仍有 conflicting expected：停止生成/训练。
- scanner 只能在 run-dir 一次性脚本里跑，未进入可复跑 gate：不能宣称量尺已修。
- default_scope 拍点缺失时，相关 family 的 R5 pair 不得进入训练包。
- default-scope 只引用旧 receipt 或 R2b data_ready，不在 final candidate head 重跑：不得用于 candidate promotion。

### Acceptance

- `R5-SCANNER-HARDENED.md` 的规则被迁入 repo gate 或明确的 run-dir reusable script。
- `R5-LABEL-AUTHORITY-AUDIT.md` 列出的 P0/P1 冲突有裁决表。
- 针对 `现在音量是多少` 的测试能证明 query authority 与 absent-query counterfactual 不再同句冲突。
- final candidate head 上 default-scope 三门或 `make verify-default-scope` 重新通过，并绑定 head/data/receipt。

### Evidence

- Scanner 规则：`R5-SCANNER-HARDENED.md:23-37`。
- Label authority 6 冲突：`R5-LABEL-AUTHORITY-AUDIT.md:7-24`、`R5-LABEL-AUTHORITY-AUDIT.md:73-75`。
- `现在音量是多少` 裁决：`R5-LABEL-AUTHORITY-AUDIT.md:9-24`、`R5-LABEL-AUTHORITY-AUDIT.md:92-110`。
- Default-scope current-head 风险：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W34-DEFAULT-SCOPE-APPLY-STATUS.md:12-15`、`:133-139`。

## 6. Phase 2 — Runtime Query Safety Gate（主线）

### Goal

把 query/status 安全边界从 “让 adapter 在大工具面里自判不出手” 改成 “runtime 先裁掉危险 mount 面”。

### Why now

D-106 的核心教训不是 “LoRA 完全不行”，而是 **adapter 的 actuation prior 太强，query/status 安全边界不适合继续只靠 SFT 学**。项目原始铁律也是规则吃 80%、LLM 碰 20%、安全检查是代码。

### Proposed contract

新建或扩展 OpenSpec change，定义 `RuntimeQueryGuard`：

| 输入类型 | Runtime 行为 | Model mount |
| --- | --- | --- |
| true query：C1 有 `query_*` | 直走 query route，或只挂对应 query tool | 不挂同族 mutating tools |
| unsupported status query：C1 无 query 能力 | 返回 unsupported/readback，不让模型看到 mutating tools | 空或安全 fallback |
| action-question：如“能不能帮我打开 X” | 视为 action intent，进入正常 action route | 挂 mutating tools |
| ambiguous query/action | clarify，不默认动作 | 最小安全 mount |

### W50 live-loop supplement

Phase 2 不能只写成 “query guard prompt 改造”。W50 把 main runtime 断点拆得更硬：

- 当前真实 app 闭环只覆盖默认 `打开空调`，不能 claim `UIUE 输入文本 -> Qwen+LoRA -> 10 族正确显示`。
- 最小 runtime 设计是 `DemoNLURouter + full contract runtime bundle + D-domain parser/normalizer + 10-family state/display bootstrap + RuntimeAdapterMountReceipt`。
- 慢路模型加载前必须有 `RuntimeAdapterMountReceipt`：绑定 code/data basis、base/tokenizer/config/tool-catalog/prompt/decode/receipt；缺任一项只能 `BLOCKED/PARTIAL`，不能 fallback 到 base model 或 fake local green。
- UI 手输 10 条可见 card/readback 最高只是 `operator-pass`；不等于 model behavior、LoRA candidate、mobile、true-device 或 V-PASS。

### Work items

1. OpenSpec propose：定义可观察行为、三类 query/action-question 场景、proof class 边界。
2. Runtime route/mount preflight：在模型前过滤或收窄工具面。
3. Harness：用同一组 qa cross-track cases + T1 true_query/action_question 运行 runtime path，而不是只跑 adapter prompt path。
4. Receipt：输出 `runtime-gated qa safety`，并明确 non-claim：`adapter learned qa = false/unknown`。
5. Live-loop 接线：补 full demo bundle、D-domain parser/normalizer、10-family state/display bootstrap、`RuntimeAdapterMountReceipt`，并把 adapter/basis 信息留在 mount receipt，不能塞进 public UI payload。

### Acceptance

- runtime path 下 qa safety total = 0。
- true query guard 达 10/10。
- action-question control 达 18/18 或至少不低于 R3 水位，并解释任何差异。
- A/B/D action path 不因 query guard 被误拒。
- receipt 禁止写 “LoRA 学会 query no-call”。
- 10-family local/integration loop：每族 exactly-one frame，经 C3 写 mock state，payload 有对应 card + 中文 readback。
- slow path 若涉及 LoRA：`RuntimeAdapterMountReceipt.mount_verdict=PASS`，且 basis/sha/manifest 全字段绑定。

### Stop conditions

- 若 OpenSpec 未对 `query_*`、unsupported、action-question 三分给出 SHALL 场景，不实装。
- 若 action-question 被误拒，不能晋级 safety gate。
- 若实现只改 prompt、不改 route/mount，不能算 runtime safety。
- 若 `ContentView` 仍以 `singleCommandDemoDefault` 作为 app 默认，不能 claim 10-family live loop。
- 若训练占卡或 host memory constrained，禁止加载模型/推理；只做静态/path/sha preflight。
- 若 mount receipt 未 PASS，慢路只能 `BLOCKED/PARTIAL`。

### Evidence

- R5 redteam 推荐 B runtime guard 主线：`R5-STRATEGY-REDTEAM.md:12-16`、`R5-STRATEGY-REDTEAM.md:100-154`、`R5-STRATEGY-REDTEAM.md:202-232`。
- R5 grill 已把 runtime 兜底列为 R5-2，且要求 proof class 分层：`docs/c5-training-readiness-grill/f044-r5-grill-2026-07-05.md:52-61`。
- W50 live-loop P0 断点与最小设计：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:14-23`。
- W50 mount receipt stopline：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:81-136`。
- W50 proof cap：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:168-199`。

## 7. Phase 3 — R5 Pair-Boundary One-Shot（旁线）

### Goal

给数据-only 路线最后一次公平机会：不是再堆孤立负例，而是验证 “同 mount/同 device/同 slot 下，问状态 vs 发操作的强对比对” 是否能把 qa 拉到 0。

### Hard framing

R5 是 **falsification experiment**，不是新主线。失败后停止 data-only qa 修复，不再 R6/R7 堆量、换 mount、加 epoch。

### Work items

1. Phase 1 authority-clean 后，针对 D-106 失败族生成 pair ledger。
2. 每个 family 至少覆盖：
   - unsupported status-question -> `NO_TOOL` 或 unsupported
   - true query family -> `query_*`
   - same noun imperative/action -> mutating tool
   - action-question control -> mutating tool
3. 同 pair 使用同 mount，同 device，同 slot/同话术邻域，只改可见 discriminator。
4. 加 exact tool-name precision gate：invalid alias、valid-neighbor misroute 分账。
5. 跑一轮 600 iters 短训，保留 R3/R4 同款 knob，除非 Phase 4 重拍。

### Acceptance

- qa adapter expected-empty any_tool_call_fail = 0。
- true_query_guard = 10/10。
- action_question_control 不低于 R3 水位，理想 18/18。
- A/B/D 不跌破 D-085。
- tool-name hallucination 不扩散。

### Stop conditions

- Phase 1 authority 未清零：不生成 R5。
- R5 跑后 qa 未归零：停止 data-only qa 修复。
- T1 比 R3 退化：停止 data-only qa 修复，转 runtime/架构讨论。
- A/B/D 跌破门：R5 不可作为 candidate，保留 R3/R4 asset 复议。

### Evidence

- R5 mechanism 建议：authority-clean、same mount/device/slot、tool-name precision guard，见 `R5-QA-MECHANISM-ATTRIBUTION.md:19`、`R5-QA-MECHANISM-ATTRIBUTION.md:196-248`。
- R5 redteam：Route A 成功率估 35%，只允许一次，见 `R5-STRATEGY-REDTEAM.md:38-90`。

## 8. Phase 4 — D-085 Gate Semantics 重拍

### Goal

正式决定 “C5 candidate 的 qa=0 到底必须由 adapter-only 满足，还是允许 runtime-gated qa safety 满足”。

### Options

| Option | 解释 | 何时成立 | 风险 |
| --- | --- | --- | --- |
| A adapter-only | 维持 D-085 原门：adapter prompt path qa=0 才 candidate | R5 one-shot 成功 | 可能继续被小模型固有 actuation prior 卡死 |
| B runtime-gated | A/B/D 由 model candidate gate 证明，qa 由 runtime safety gate 证明 | Phase 2 runtime guard 过门 | 治理上必须明写 model defect 由 runtime 兜底，不可假装 LoRA 学会 |
| C dual-track | R5 one-shot + runtime guard 同时完成，candidate receipt 分层 | 默认推荐 | 文档/receipt 若写不好会混 proof class |
| D architecture/base switch | 换基座、换架构、call/no-call classifier、constrained decoding、DPO 等 | R5 失败且 runtime gate 被否决 | 重开全链路，成本高 |

### Recommended baseline

默认走 **C dual-track**，但主权重给 **B runtime-gated**：

- R5 是最后一次数据-only 证伪试验。
- runtime guard 是 demo/product safety 正解。
- 若 R5 过，candidate 更干净；若 R5 不过，仍可在 B 口径下推进，但必须诚实写 non-claim。

### Acceptance

- D-085 修订或解释有明确 decision entry。
- Candidate receipt 字段拆分：
  - `model_behavior_gate`
  - `adapter_qa_gate`
  - `runtime_qa_safety_gate`
  - `candidate_status`
  - `non_claims`
- formal 1800 是否仍需跑、跑哪个 adapter/recipe，有明确 basis。
- D-085 重拍不能替代 R-L17 candidate signoff；它只能定义 qa gate 语义，不能签候选。

### Evidence

- D-106 strategy options：A 35%、B 75%、C 双管，见 `docs/commander-log/decisions.md:794-800`。
- R5 redteam 默认路线：先拍 qa 是否允许 runtime-gated safety，见 `R5-STRATEGY-REDTEAM.md:220-232`。

## 9. Phase 5 — Formal 1800 Candidate Run

### Goal

在 gate semantics 明确后，才启动 formal 1800；formal 只验证“被选中的 candidate 配方在长训下是否稳定”，不能拿来赌一个尚未定义清楚的 qa 门。

### Preconditions

- Phase 1 完成：scanner + label authority 清楚。
- Phase 2 完成，或 Phase 3 R5 成功，或 Phase 4 明确允许某一路径进入 formal。
- `FORMAL-LAUNCH-CONDITIONS.md` 六条件全部由 launch owner 填 verdict，且 W27/W47/W52 无 open P0/P1。
- Launch Packet 六件齐：
  - `FORMAL-LAUNCH-CONDITIONS.md`
  - `formal-config.diff`
  - `formal-host-baseline.json`
  - `formal-watchdog-contract.md`
  - `formal-eval-manifest.json`
  - `formal-receipt-template.md`
- host baseline：swap/free 按 D-094/D-102 条款，不可静默放宽。
- watchdog --armed 真 pid，LR 450 schedule rc0；watchdog draft/配置必须部署进 run package，不能只引用未接线草稿。

### Run policy

- 不训中并行推理/eval/browser/Xcode。
- 不用 checkpoint 中测杀训练，除非 watchdog stopline 触发。
- checkpoint 只做 post-run 留档和诊断，不 cherry-pick。
- 任何 host redline、nonfinite、no-progress、memory pressure 触发都记 receipt，不临场改门。
- UN/swap/no-progress 是环境进展 stop，receipt 写 `PARTIAL`，不能误报成 model/train-health fail。

### Acceptance

- formal 1800 完成，train receipt 完整。
- behavior eval 使用 frozen manifest。
- A/B/D pass。
- qa 按 Phase 4 semantics pass。
- T1 true query/action-question pass 或明确分层失败。
- candidate receipt 给出 adapter sha、basis、proof class、non-claims。

### Stop conditions

- Phase 1/2/4 未完成：formal HOLD。
- Launch Packet 缺任一件：formal HOLD。
- host baseline 不达标：按 D-094 上抛，不自改。
- formal 训后 qa/T1/A/B/D 任一 hard gate fail：不得 candidate signoff。

### Evidence

- D-093 起跑硬门与 Launch Packet 六件：`docs/commander-log/decisions.md:706-712`。
- D-094 host 门：`docs/commander-log/decisions.md:714-716`。
- D-100 formal 条件式授权只在 R3 全绿时成立，后续 R4/D-106 已使其 HOLD：`docs/commander-log/decisions.md:750-752`。
- Formal 六条件与 Launch Packet 边界：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/FORMAL-LAUNCH-CONDITIONS.md:10-25`、`:27-36`。
- Watchdog 非授权边界与 host/memory 阈值：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/formal-watchdog-contract.md:12-19`、`:29-33`、`:37-45`。

## 10. Phase 6 — C5 Exit Package

### Goal

把 C5 收成一个可移交的候选包，而不是把短训/运行时/产品验收混成一个模糊 “完成”。

### Deliverables

1. **C5 Candidate Receipt**
   - adapter sha / basis ids / training config / eval manifest
   - model behavior gate
   - adapter qa gate
   - runtime qa safety gate
   - runtime adapter mount receipt（若声称 live-loop slow path）
   - formal run status
   - R-L17 candidate signoff state
   - non-claims

2. **C5 Lessons + Gate Updates**
   - scanner hardening
   - label authority gate
   - query/action-question split
   - pair-boundary one-shot rule
   - proof-class language

3. **Downstream Handoff**
   - to C6 bench：which adapter and which gate semantics
   - to C6 construction：which cases/scorer/BehaviorClass/replay/readback/fingerprint can be built before candidate
   - to C6 comparison：blocked until signed candidate + explicit run authorization
   - to runtime/UIUE：what safety is runtime-owned
   - to voice/live loop：what remains blocked

4. **OpenSpec/Docs Sync**
   - CURRENT route board refreshed
   - decisions D-entry added
   - run-dir status board closed or superseded
   - any active change tasks updated

### C5 Exit Status Vocabulary

| Status | Meaning |
| --- | --- |
| `C5_FORMAL_TRAIN_DONE` | formal run done, not necessarily candidate |
| `C5_MODEL_BEHAVIOR_PASS` | A/B/D pass under frozen eval |
| `C5_RUNTIME_QA_SAFETY_PASS` | runtime guard proves qa safety, not adapter learning |
| `C5_ADAPTER_QA_PASS` | adapter-only qa=0 |
| `C5_CANDIDATE_SIGNED` | project decision says C5 candidate is accepted for downstream |
| `C5_PARTIAL_QA_BLOCKED` | behavior asset strong, qa unresolved |
| `C5_ROUTE_ONLY_READY_FOR_C6_CONSTRUCTION` | route-only R7 allows C6 construction prep, not candidate comparison |

## 11. 并行工作池

### 11.1 可并行，且不抢 C5 训练资源

| Lane | 可做什么 | 禁止什么 | 依赖 |
| --- | --- | --- | --- |
| UIUE merge prep | 按 `docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md` 做 fresh-main selective port 计划、schema/fixture drift 复核 | 不直接 merge UIUE 旧树；不碰 `Core/Training`；不声称 UIUE complete | C5 formal artifacts frozen 前只做 read-only/prep |
| Runtime query guard + live-loop design | OpenSpec propose、harness 设计、case matrix、mount receipt、10-family payload/state/display bootstrap | 未 agree before build 不实装；不把 proof 写成 adapter pass；不在训练占卡时加载模型 | Phase 2 主线 |
| C6 construction prep | 四层 scorer、manifest、case selector、BehaviorClass SSOT、replay/readback/fingerprint、L6 seed recoding方案 | 不跑 C6 acceptance/comparison，不拿 L6/R2b 53-case 原样当 denominator | route-only R7 已允许 construction；model comparison 等 signed candidate |
| Voice C7 design | ASRBackend/TTS 合同、system SFSpeech primary preflight、fake backend、normalizer/confidence gate、TTS premium voice preflight | 不做 dependency adoption；不声称 ASR/TTS ready、offline ready、mobile/true-device/V-PASS | 可 spec-first；真链路等 C7 |
| Live-loop slow path prep | `RuntimeAdapterMountReceipt`、basis registry、Qwen/LoRA load preflight schema、no-fallback wording | 不跑推理；不声称 candidate/model behavior | 等 host 空闲与 adapter basis |
| Macro scene/state | `scenario-macros.yaml`、Core `SceneMacroMatcher`/macro policy、mock state readback、presentation mapping | 不让 LLM 自由多工具规划；不把 UIUE `MultiCallSequencer` 当 Core executor；不把 mock simulator 证据升格 mobile/live | 可独立 spec-first |
| Launch infra | formal packet 模板、watchdog replay、host baseline 命令、receipt schema | 不启动训练；不改 host 门 | Phase 5 前置 |
| Docs/governance | CURRENT 刷新、lessons learned、commander handoff、receipt vocabulary | 不把 stale docs 写成 SSOT | 随时 |
| Data salvage prep | 旧文本 projection ledger、judge rubric、DataGate plan | 不直接混入 R5/正式训练 | Phase 1 后才可进训练候选 |

### 11.2 必须串行或等拍

- D-085 gate semantics 重拍：必须等 Phase 1/2/3 证据，不让 worker 自拍。
- Formal 1800：必须等 Phase 4 + Launch Packet + host baseline。
- UIUE merge 实施：建议等 C5 formal artifacts 或 runtime safety contract 稳定，避免 shared payload 与模型候选同时漂移。
- C6 construction：可在 route-only R7 + accepted OpenSpec 下推进；但 proof cap 是 construction/local/static。
- C6 acceptance/comparison：必须等 C5 candidate signoff + explicit run authorization，不拿 R4/R5 partial 或 L6 seed 直接跑成产品验收。
- Voice implementation/adoption：C7 spec-first 后再做；不能从现有 TTS seam 或 mock UIUE 得出 voice-ready。
- M2 destructive cleanup：需要磊哥明确授权，不在 C5 自动推进里顺手删。

## 12. 建议派工拓扑

| 角色 | 任务 | 输出 |
| --- | --- | --- |
| commander | 维护 D-entry、裁决 Phase 4、亲核 receipts | decisions + final verdict |
| worker-data | Phase 1 label authority + R5 pair ledger | conflict table + pair data spec |
| worker-runtime | Phase 2 OpenSpec + harness + route/mount design | RuntimeQueryGuard proposal + tests |
| worker-eval | scanner hardening + T1/A/B/D/qa harness | reproducible gate scripts |
| worker-infra | Launch Packet + watchdog + host baseline | formal launch packet |
| worker-uiue | UIUE selective-port prep | drift table + no-touch list |
| worker-c6 | C6 construction-only prep | four-layer shape + denominator + no-acceptance receipt |
| worker-voice | C7 voice spec-first | ASRBackend/TTS contract + proof caps |
| worker-macro | SceneMacro spec-first | macro policy + terminal snapshot/readback gates |
| critic/redteam | Phase 2/3/4 对抗审 | risk table + stopline verdict |

并行规则：Phase 1/2/UIUE/infra/docs 可以并行；Phase 3 依赖 Phase 1；Phase 5 依赖 Phase 4；candidate signoff 只能由 commander/磊哥拍，不下放。

## 13. 风险与防线

| Risk | 典型误判 | 防线 |
| --- | --- | --- |
| 训练健康外溢 | loss 好看就写 C5 done | 三层报告：train_health / behavior / candidate |
| 量尺再次错 | scanner 旧口径或 stale bundle 进决策 | scanner hardening + manifest/basis sha |
| label 冲突残留 | 同句双标签让模型背锅 | identical-input expected conflict gate |
| runtime 偷换 proof | runtime guard 过了写成 adapter 学会 | receipt 字段分层 + non-claims |
| live-loop 假绿 | 单 AC app 闭环写成 10-family Qwen+LoRA live loop | W50 10-family gates + `RuntimeAdapterMountReceipt` |
| adapter/basis 漂移 | slow path 载入了不同 code/data/model/tool surface | basis ids + sha + formal manifest fail-closed |
| R5 无限循环 | 失败后继续 R6/R7 堆数据 | one-shot stopline |
| UIUE 抢线 | stale UIUE 树 merge 漂移污染 C5/shared payload | fresh-main selective port + no-touch Core/Training + 10-family consumer smoke |
| formal 误起跑 | 想靠 1800 解决未定义 gate | Phase 4 前 formal HOLD |
| C5/C6 混账 | construction receipt 或 L6 seed 写成 C6 acceptance | construction/comparison 双 lane + signed candidate hard gate |
| voice proof inflation | TTS seam/mock UI 写成 ASR/TTS ready | C7 ASRBackend/TTS 独立 proof，UIUE mock 不替代 voice |
| macro executor 幻觉 | UIUE 展示 sequencer 写成 Core 多步执行 | Core deterministic macro + C3 single-tool gate/readback |

## 14. 今日/下一步最小动作

如果只做最小推进，顺序如下：

1. **把本 baseline 作为新 commander 起手读物**，并标记 `CURRENT.md` C5 状态已 stale（另起小 patch）。
2. **开 Phase 1 单**：port/固化 scanner hardening + label authority 6 冲突裁决表。
3. **开 Phase 2 OpenSpec propose**：`RuntimeQueryGuard`，先定语义与 proof class。
4. **并入 W50 live-loop gates**：把 mount receipt、10-family state/display、D-domain parser/normalizer 作为 Phase 2 的验收补充，不放到 C5 结束后才补。
5. **并行准备 C6 construction-only 单**：只做 shape/denominator/replay/readback/fingerprint，不跑 model comparison。
6. **并行准备 Phase 3 R5 one-shot spec**：只写数据规格和 stopline，等 Phase 1 清零后再生成。
7. **等 Phase 1/2/3 证据后开 Phase 4 裁决**：D-085 是否允许 runtime-gated qa safety。
8. **只有 Phase 4 通过才恢复 formal 1800 Launch Packet 检查**。

当前不建议做：

- 不建议直接训 formal 1800。
- 不建议继续只堆 unsupported-query 负例。
- 不建议继续只换 mount 或扩大 mount。
- 不建议直接 merge UIUE。
- 不建议把 R4/R3 adapter 写成 C5 candidate。
- 不建议把 C6 construction、UIUE fixture、voice/TTS seam 或 macro display proof 写成产品验收。

## 15. References

- `docs/commander-log/decisions.md:650-724` — D-080~D-095：短训门、R2/R2b、正式训练硬门与失败分诊。
- `docs/commander-log/decisions.md:733-800` — D-097~D-106：mount-invalid 翻案、R3/R4、scanner/authority 翻案、D-106 战略拍点。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-SCANNER-HARDENED.md:23-37` — hardened qa 真数。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-LABEL-AUTHORITY-AUDIT.md:7-24` — label authority 主冲突与修法。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-QA-MECHANISM-ATTRIBUTION.md:196-248` — R5 pair-boundary 配方约束。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/R5-STRATEGY-REDTEAM.md:220-232` — 推荐默认路线与禁行路线。
- `docs/c5-training-readiness-grill/f044-r5-grill-2026-07-05.md:35-115` — R5 grill skeleton 与 landing 守门。
- `docs/superpowers/plans/2026-07-05-uiue-merge-battle-plan.md:1-53` — UIUE selective-port 计划边界。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W34-DEFAULT-SCOPE-APPLY-STATUS.md:12-15`、`:133-139` — default-scope current-head promotion 边界。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W48-GRILL-RESIDUAL-SCAN-v2.md:16-20`、`:37-43`、`:98-107` — R-L17 candidate signoff、C6 construction/comparison、UIUE/voice/macro 真未决。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN-v2.md:14-23`、`:81-136`、`:168-199` — live-loop 断点、mount receipt、10-family proof cap。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W28-C6-RESTART-ASSESSMENT.md:198-261` — C6 restart 双 lane、L6 seed claim ceiling、post-candidate worklist。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W24-UIUE-TREE-AUDIT.md:11-22`、`:218-233`、`:259-281` — UIUE stale/high-merge-risk 和 proof cap。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W37-VOICE-ASR-LINE-ASSESSMENT.md:15-21`、`:137-147`、`:157-170` — voice C7 spec-first、ASR/TTS proof cap。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W51-MACRO-SCENE-PRERESEARCH-v2.md:13-23`、`:28-30`、`:151-160`、`:192-199` — deterministic macro route、executor gap、voice/display proof cap、reentrancy gates。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/FORMAL-LAUNCH-CONDITIONS.md:10-25`、`:27-36` — formal 六条件与 packet inventory。
- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/formal-watchdog-contract.md:12-19`、`:29-45`、`:198-213` — watchdog 非授权边界、memory stopline 与部署要求。
