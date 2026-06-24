# Handoff 2026-06-24 — Post-PR4 / UIUE / C5-C6 下一阶段交接

## 当前实况

- Repo: `/Users/wanglei/workspace/MAformac`
- 当前 worktree branch: `codex/pr4-architecture-absorption-20260624`
- 当前 HEAD: `a9ce7cf115d4b4f724370026201687d8be420000`
- `main == origin/main == a9ce7cf`
- 当前未提交改动:
  - `docs/research/2026-06-24-pr4-gptpro-architecture-absorption.md`
  - `docs/research/INDEX.md`
  - 本 handoff 文件
- PR #4: **MERGED** via GitHub rebase-merge, URL `https://github.com/rayw-lab/MAformac/pull/4`
- main CI: GitHub Verify run `28093487850` success, head `a9ce7cf`
- OpenSpec live check: `openspec validate --all --strict` exit 0, 14 passed / 0 failed.

## 重要纠偏

用户截图显示 UIUE 已 rebase 到正式 `origin/main`，并给出 macOS/iOS build、swift test、platform/no-binary guards、make verify 全绿。但本窗口 live 核查 GitHub PR 列表时只看到 PR #4 已 merge，**没有看到 UIUE PR #5 或 UIUE merge 记录**。

因此当前应写成：

- UIUE 本地 worktree 已 rebase-ready。
- 还不能写成 UIUE 已 live-verified 合入 `origin/main`。
- 下一步建议走 **B1: 开 UIUE PR #5**，而不是 B2 直接 fast-forward/push main。理由是 PR #4 刚用 GitHub merge path 修复了 head-bound receipt / CI / review trail，UIUE 也应保留同样证据链。

UIUE worktree live state:

- Path: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/visual-ssot-state-consume`
- HEAD: `3c5500e602bde5190f3cac37c6f8b9be028b6ff5`
- Local branch visible, no `origin/uiue/...` remote branch observed in this repo fetch.
- Screenshot says final state: ahead 18 / behind 0 on top of `origin/main(a9ce7cf)`, validation matrix green. Treat screenshot as user-provided evidence, not this window rerun proof.

## 已完成主线

### PR #4 default_scope apply

已合入 `origin/main`:

- C2 `default_scope`
- C3 shared `ScopeResolution` / `ScopeOrigin`
- state applier fail-closed
- C6 consumes `applyWithEvidence` scope-origin evidence, no C6-side recompute
- C5 scope candidates from C2/device-cell mapping, no longer window-only
- default scope readback 保留“主驾”，与 UIUE “默认淡显非完全省略”口径一致
- GitHub Verify + local raw-bound receipt + source-free CI receipt

不要再把 PR #4 当待 merge 阻塞。

### GPT Pro 两份审计吸收

已有两份吸收文档:

- P0/P1/P2 修复吸收: `docs/research/2026-06-24-pr4-gptpro-audit-absorption.md`
- 下半段架构建议吸收: `docs/research/2026-06-24-pr4-gptpro-architecture-absorption.md`

第二份是本窗口新增，尚未提交。它的核心结论:

- PR #4 已完成止血版，不等于完整 contract spine。
- 后续应把 `default_scope` 收敛为薄主干:
  `ScopedStateKey / TargetResolution -> PlannedEffect / StateApplyDiagnostics -> ContractReplayEngine / ReadbackRenderer -> PresentationAdapter / C5-C6 gates -> head-bound receipt`
- 不要一次性大爆炸重构。
- 不把 `presentationPolicy` 混进 C2 状态事实；UI 淡显/聚合属于 channel policy。
- 不让 C6 architecture debt 阻断 UIUE rebase/PR。

## UIUE 下一步

推荐路线: **B1 开 PR #5**。

PR #5 描述需要包含:

- base: `main` at `a9ce7cf`
- head: `uiue/visual-ssot-state-consume` at `3c5500e`
- 说明 rebase 策略: PR #4 rebase-merge 重写 SHA 后，UIUE 用 `git rebase --onto origin/main c2d6402` 摘取 18 个 UIUE commit，丢弃旧 default-scope commits，保留主线审计修复。
- 验证矩阵来自 UIUE 窗口截图:
  - macOS Debug build succeeded
  - iOS Debug build succeeded
  - `swift test` 163/0
  - `check-no-binary-visualstate` exit 0
  - `check-platform-vs-version-guard` exit 0
  - `make verify` exit 0 + worktree clean
- 口径确认: origin/main readback 保留“主驾”，UIUE 默认 scope 淡显/非省略策略一致。

不要直接 B2 fast-forward main，除非用户明确拍板跳过 PR trail。

## OpenSpec 状态

Live `openspec list`:

- `define-demo-default-scope`: Complete
- `define-lora-data-gate`: Complete
- `retrain-c5-lora-d-domain`: 0/33 tasks
- `rebuild-c6-four-layer-bench`: 0/28 tasks
- `define-demo-golden-run-and-voice`: 0/17 tasks
- `run-lora-candidate-training`: 20/23 tasks, historical/problematic

建议下一步:

1. UIUE 走 PR #5 并入主线。
2. default_scope apply 可准备 archive / CURRENT 路由牌更新，但不要在 UIUE 未稳前改动大范围路线。
3. 之后再立 `harden-contract-runtime-spine` 或等价 OpenSpec change，承接 GPT Pro 架构吸收文档。
4. 再进入 `rebuild-c6-four-layer-bench` 与 `retrain-c5-lora-d-domain`。

## Tools/paper-to-skill-gate 状态

路径: `Tools/paper-to-skill-gate/`

边界:

- 不是 runtime。
- 不是训练授权。
- 不是 C6 rebuild 授权。
- 不是 D1-D37 重拍。
- 输出只能作为后续 `retrain-c5` / `rebuild-c6` / `tool-surface-retrieval-spike` / OpenSpec proposal 输入。

关键文件:

- `Tools/paper-to-skill-gate/README.md`
- `Tools/paper-to-skill-gate/pipeline.md`
- `Tools/paper-to-skill-gate/maformac-integration-map.md`
- `Tools/paper-to-skill-gate/trial-runs/2026-06-24-p0-five-pack-index.md`

Trial packet 路由:

| Packet | Gate status | 后续用途 |
|---|---|---|
| `in-vehicle-function-calling-p0` | `retrain_c5_input` | 车载 FC 领域相关，但 paper-only / Qwen3 转移风险，不能直接训练。 |
| `when2call-tool-decision-p0` | `rebuild_c6_input` | C6 no-call/refusal/clarify/tool-call 分层，防 tool hallucination。 |
| `abc-rigorous-agentic-benchmarks-p0` | `rebuild_c6_input` | 防 C6 aggregate pass 掩盖 hard layer failure。 |
| `function-calling-data-generation-pack-p0` | `retrain_c5_input` | C5 数据生成、负类比例、lineage、masking 候选。 |
| `leakage-decontamination-pack-p0` | `retrain_c5_input` | 语义泄漏/near-duplicate，不允许 exact-ID split 假绿。 |
| `learning-rate-matters-vanilla-lora-may-suffice` | `retrain_c5_input` | LR sweep 进入 C5 proposal；不能直接改 LR。 |
| `internalizing-tool-knowledge-in-slms-via-qlora` | `retrain_c5_input` | tool knowledge internalization 候选；无官方 repo，Qwen3 retention 风险。 |
| `tinyagent-function-calling-at-the-edge` | `spike_only` | D-domain tool subset retrieval spike；不改 runtime。 |

后续 grill/吸收重点:

- C5: LR sweep receipt、负类不可归零、semantic leakage scan、tool-knowledge vs prompt-schema vs retrieved-schema 三分支比较。
- C6: no-call/refusal/clarify/tool-call 分层，benchmark hard layer 不允许 aggregate 绿掩盖红，tool retrieval miss/parser miss failure taxonomy。
- Tool surface: TinyAgent-style ToolRAG 只做 offline spike，先测 retrieved subset 是否覆盖 gold tool 且排除危险 distractor。
- Evidence: 每篇 paper absorption 必须有 gate packet、official repo branch（若存在）、stop conditions、proof class，不得从 paper 直接跳实现。

## 后续待办清单

### P0 / 合并纪律

- [ ] 不要把 UIUE 写成已合主线，除非 GitHub PR/merge live verified。
- [ ] UIUE 推荐开 PR #5，保留 review/CI trail。
- [ ] 本窗口新增架构吸收文档需要 commit/push 或随 handoff 一起交给下一窗口处理。
- [ ] 任何 merge 前都确认 `git status --short --branch`，不用 `git add .`。

### P1 / default_scope 架构债

- [ ] 把 `docs/research/2026-06-24-pr4-gptpro-architecture-absorption.md` 转成后续 OpenSpec proposal 候选。
- [ ] 建议 change 名: `harden-contract-runtime-spine`。
- [ ] Scope: `ScopedStateKey`、`TargetResolution`、state apply diagnostics、readback fact split。
- [ ] Non-goal: UIUE layout、C6 acceptance、training。

### P1 / rebuild-c6

- [ ] `ContractReplayEngine` 提案化。
- [ ] C6 manifest: generator hash、trap migration hash、output JSONL hash。
- [ ] C6 exact delta + unexpected mutation + scope evidence + readback compare。
- [ ] 融合 `ABC`、`When2Call` 两个 paper-to-skill gate packet。

### P1 / retrain-c5

- [ ] 进入训练前先吸收 18 路 LoRA deepdive ledger，不重开泛讨论。
- [ ] 重点 gate: L02/L03/L04/L05/L07/L08/L09/L16/L17。
- [ ] 融合 `function-calling-data-generation-pack`、`leakage-decontamination-pack`、`learning-rate-matters`、`internalizing-tool-knowledge`。
- [ ] 不启动训练，直到 `retrain-c5` OpenSpec 明确授权。

### P2 / UIUE presentation

- [ ] UIUE 后续消费 structured facts，不长期 parse `base[scope]` 生成展示事实。
- [ ] 但不要在 domain PR 里抢改 `ContentView`。
- [ ] 保持三接口兼容: `presentationCells`、`base[scope]`、`DemoVehicleStateCell.init(...visualState:)`。

### P2 / governance

- [ ] receipt schema 后续加入 `receipt_version`、`contract_bundle_fingerprint`。
- [ ] 区分 PR synthetic merge ref、feature push head、main push head。
- [ ] branch protection / required checks 需要 GitHub settings 核实，不能靠 workflow 文件自称。

## 禁止动作

- 不启动 LoRA data generation/training。
- 不跑真实模型质量评测。
- 不跑 demo-golden-run，不 freeze golden IDs。
- 不做 voice/ASR/TTS readiness。
- 不把 local/CI 结果写成 C6 acceptance、model-quality、mobile、true-device 或 V-PASS。
- 不关闭 R-L17；同厂商审计仍只算 pre-check。
- 不把 `Tools/paper-to-skill-gate` 的 gate packet 当实现授权。

## 下个窗口起手建议

1. `git status --short --branch`
2. `gh pr list --state all --limit 20 --json number,title,state,headRefName,mergedAt,url`
3. `git -C /Users/wanglei/workspace/MAformac-uiue status --short --branch`
4. 若继续 UIUE: 走 PR #5，不直接推 main。
5. 若继续架构吸收: 先读 `docs/research/2026-06-24-pr4-gptpro-architecture-absorption.md`，再起 OpenSpec proposal。
6. 若继续 C5/C6: 先读 `Tools/paper-to-skill-gate/trial-runs/2026-06-24-p0-five-pack-index.md` 和 `docs/handoffs/2026-06-24-default-scope-commander-handoff.md` 的 18 路 ledger。

