# Handoff 2026-06-24 — default_scope apply 长跑指挥官交接

## 当前现场

- Repo: `/Users/wanglei/workspace/MAformac`
- Branch: `main`
- Current HEAD: `8517f70 feat(c2): add default scope to state cells`
- Remote state observed: `main...origin/main [ahead 3]`
- Existing dirty worktree at handoff time:
  - `M Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`
  - `?? Core/Execution/ScopeResolution.swift`
- 这些脏改看起来是另一个窗口正在执行 `default_scope apply` 的 Task 3 resolver 红/绿测试与实现。不要误删、不要 reset、不要覆盖；先读 diff 再接。

## 最近已完成的关键链路

- A2 D-domain code-only 重构已合入 main，范式从 generic frame 转到 D-domain 具名工具；A2 边界是代码对齐，训练/真实评测/voice/demo-golden-run 全部 deferred。
- Phase0 D1-D10 已由用户拍板接受；R-L17 仍 open，same-vendor Codex/Claude 审计只能算 pre-check。
- `define-demo-default-scope` carrier 已 materialize 并获准 apply；Phase -1 closeout 已写入。
- Commit `14060bf docs(default-scope): close phase minus one apply plan` 创建/更新：
  - `docs/project/phase0/phase-minus-one-default-scope-closeout.md`
  - `docs/project/phase0/default-scope-apply-plan-audit-codex-2026-06-24.md`
  - `docs/superpowers/plans/2026-06-24-default-scope-apply.md`
  - `docs/CURRENT.md`
  - `CLAUDE.md`
  - `openspec/changes/define-demo-default-scope/*`
- 后续另一个窗口已经提交：
  - `b8c0387 docs(default-scope): prepare apply gates and receipt schema`
  - `8517f70 feat(c2): add default scope to state cells`

## 当前权威路线

先读：

1. `CLAUDE.md`
2. `docs/CURRENT.md`
3. `docs/project/phase0/phase-minus-one-default-scope-closeout.md`
4. `docs/project/phase0/default-scope-apply-plan-audit-codex-2026-06-24.md`
5. `docs/superpowers/plans/2026-06-24-default-scope-apply.md`
6. `openspec/changes/define-demo-default-scope/{proposal.md,design.md,tasks.md,specs/tool-execution/spec.md}`

执行主线只认 `docs/superpowers/plans/2026-06-24-default-scope-apply.md`。Phase0 umbrella plan 已是溯源，不要从头重跑 Phase -1。

## default_scope apply 当前进度推断

- Task 0: carrier/receipt schema 准备已通过 `b8c0387` 落地。
- Task 1/2: C2 `default_scope` contract/schema/parser/validator 已通过 `8517f70` 落地。
- Task 3: 当前工作树已有 resolver 测试和 `Core/Execution/ScopeResolution.swift`，但未提交。下一窗口应先从这里接，不要回滚。

## 后续必须按顺序推进

1. 完成 Task 3 shared `ScopeResolution` / `ScopeOrigin`，跑 focused C3 resolver tests。
2. Task 4 C3 execution 使用 shared resolution，去掉 `?? "全车"` 路径，把 `ScopeOrigin` 传给 readback。
3. Task 5 state applier 改用 C2 resolution，不再 `scope.first` / `?? "all"`。
4. Task 6 readback `ScopeOrigin` policy，并处理 legacy UI key：`ContentView` 必须读 scoped key 或显式 one-way adapter。
5. Task 7 C5/C2 parity：omitted target 不写 scope arg；explicit scope candidates 从 C2 派生；禁止 `左前/右前/后排` 作为 executable scope。
6. Task 8 C6 default-scope gold：不要手改 JSONL 四行；从 `Core/Bench/C6VehicleToolBench.swift` 源更新后 `swift run C6BenchCLI generate`，再按既有 trap migration。
7. Task 9 三道机械门进 Makefile：`check_default_scope_ssot.py` / `check_c5_c2_scope_parity.py` / `check_scope_origin_single_source.py`。
8. Task 10 全验证 + receipt，receipt 必须记录真实 log、exit_code、sha256、evidence_path，禁止硬编码 pass。

## LoRA deepdive 对后续的影响

`docs/research/2026-06-24-lora-zero-failure-deepdive/` 是 C5 0/34 复盘证据包，不是训练计划。它支持当前顺序：先完成 `default_scope apply`，再做 retrain-c5/rebuild-c6 stop-the-train gates。最有用的后续门：

- L09 样本可观测：从实际 tools 算 target 是否物理存在，禁止 metadata 声称。
- L03 byte-parity：端侧 render dump 必须闭环，不能继续 nil/BLOCKED 当 pass。
- L05 中途行为门：iter50/100/150 行为生成门，不能用 val-loss 冒充。
- L04 C6 四层门：golden/fuzz/unsupported/safety 分层，禁止 overall pass 掩盖。
- L17 人审破框：同厂商审计只算 pre-check，R-L17 不得被关闭。

谨慎点：

- L02 更像必要验证门，不要把它和 L09/L03/L05 一样混成同等级 P0。
- `2602.04998` 在 external verification 中已修正为出现次数，不是 11 个独立 lens。
- “generic frame 学不会”应精确表述为“未做判定面收窄的 generic frame 在 562 规模学不会”。

## LoRA deepdive 18 路待 grill / 待吸收清单

下面不是授权训练，也不是要求重拍已接受的 D1-D10；它是后续 commander 进入 `retrain-c5` / `rebuild-c6` proposal 或 apply 时必须携带的研究 routing ledger。若某项已被 D1-D10/G01-G28 接受，后续动作是写入 acceptance / evidence gate，而不是重新开泛泛讨论。

| Lens | 优先级 | 后续落点 | 待 grill / 待吸收问题 |
|---|---|---|---|
| L01 training stack | P2 | retrain-c5 receipt | 本机 mlx-lm 跑得动是已知前提；只保留 OOM/内存 receipt，不把云 Axolotl 当默认路线。 |
| L02 loss-mask | P0 | retrain-c5 sample/training gate | 单轮 offset 不能外推到多轮；若引入多轮，必须拆样本或证明 `train_on_turn` mask 真生效。 |
| L03 chat-template byte parity | P0 | retrain-c5 parity gate | 端侧 render dump 必须接入 gate；`endpointRendered == nil` 只能是 BLOCKED，不能当 PASS。 |
| L04 C6 four-layer gate | P0 | rebuild-c6 | train-health、model-quality、endpoint、readback 分层验收；action 分母按 schema 字段拆，不用全集稀释。 |
| L05 mid-training behavior gate | P0 | retrain-c5 training loop | iter50/100/150 行为生成门必须 infrastructure-enforced；val-loss 健康不代表行为正确。 |
| L06 endpoint constrained decoding | P1 | later endpoint/golden | XGrammar 只做 escape hatch；grammar 必含 no-op/refusal/unsupported，防“合法但选错”假绿。 |
| L07 data recipe | P0 | retrain-c5 data recipe | 负类不可归零；配比走 spike/hypothesis，不直接把 24% 当生产常量。 |
| L08 leakage | P1 | retrain-c5 data gate | split 必须按 family/parent semantic id，不能只看 exact id；augment-after-split 是硬要求。 |
| L09 sample observability | P0 | retrain-c5 dry-run audit | `no_call_target_present` 必须从样本实际 tools 计算；禁止读取 metadata 自证。 |
| L10 catastrophic forgetting | P1 | retrain-c5 / rebuild-c6 regression | 通用中文混入和 C-Eval/CMMLU 只作为 hypothesis + 回归门，不能抢在 default_scope apply 前执行。 |
| L11 anti-coincidence | P1 | rebuild-c6 / receipt gate | C6 多 seed / pass^k / variance 必须 enforce；只记录 hardPassVariance 不算门。 |
| L12 SFT vs DPO refusal | P1 | retrain-c5 data method | SFT first + DPO deferred 仍需保留 reopen 条件；拒识 0/7 先按数据缺失解释，不把 DPO前置。 |
| L13 LoRA hyperparams | P1 | retrain-c5 config guard | rank16Mainline / LR 1e-4 保持默认；调参前先排除 surface/byte/mid-gate/sample-observability。 |
| L14 PEFT papers | P2 | escape-hatch note | PEFT 新结构不进主线；DoRA-rank8 只作为容量诊断后的 escape hatch 记录。 |
| L15 home-llm teardown | P1 | retrain-c5 data pipeline | 采用 seed→template→distractor→validate 数据链路；拒绝照搬 generic surface/LR2e-4/零通用 eval。 |
| L16 governance matrix | P0 indirect | Phase0/status/CI gates | status vocabulary 必须机械化；`train_health` 不得 imply `model_quality` 或 V-PASS。 |
| L17 human-review deframe | P0 cross-cutting | R-L17 evidence | 7 个人审不可委托点仍 open；Codex/Claude 同厂审计只能 pre-check，不能 certify。 |
| L18 voice side memo | P2 | voice deferred / data hypothesis | 系统 ASR 砍 custom vocabulary 后，音近增广是后续 hypothesis；voice 不进当前 retrain/default_scope 主线。 |

## 禁止动作

- 不启动 LoRA data generation/training。
- 不做 D-domain base recalibration 或真实模型质量评测。
- 不跑 demo-golden-run，不 freeze golden IDs。
- 不做 voice/ASR/TTS readiness。
- 不 merge UIUE，不引用 UIUE file:line 作为 mainline proof。
- 不把 R-L17 写成已过。

## 收口纪律

- 每个 task 先红测或机械门，再实现，再 focused test。
- 完成后安排 Codex subagent 两轮审计，直到无 P0/P1。
- 只在验证全绿后清理脏区、commit、push GitHub。
- 最终报告必须分清：OpenSpec-pass / local-pass / train-health / model-quality / V-PASS，不能互相冒充。

## 建议下个指挥官第一步

1. `git status --short --branch`
2. `git diff -- Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`
3. `sed -n '1,220p' Core/Execution/ScopeResolution.swift`
4. 对照 `docs/superpowers/plans/2026-06-24-default-scope-apply.md` 从 Task 3 继续，而不是重开 Task 0。
